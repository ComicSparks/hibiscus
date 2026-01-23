// 网络请求模块

use std::sync::OnceLock;
use std::time::Duration;
use std::net::{SocketAddr, IpAddr};
use reqwest::cookie::Jar;
use reqwest::Client;
use reqwest::dns::{Resolve, Resolving, Name};
use std::sync::Arc;
use anyhow::Result;

/// 全局 HTTP 客户端
static CLIENT: OnceLock<Client> = OnceLock::new();

/// Cookie 存储
static COOKIE_JAR: OnceLock<Arc<Jar>> = OnceLock::new();

/// 基础 URL
pub const BASE_URL: &str = "https://hanime1.me";

/// 支持的域名列表
const HANIME_HOSTNAMES: &[&str] = &[
    "hanime1.me", "hanime1.com", "hanimeone.me", "javchu.com"
];

/// 内置的 Cloudflare IP（来自 Han1meViewer）
const CLOUDFLARE_IPS: &[&str] = &[
    "172.64.229.154", 
    "104.25.254.167", 
    "172.67.75.184", 
    "104.21.7.20", 
    "172.67.187.141",
];

/// 自定义 DNS 解析器
struct CustomDnsResolver;

impl Resolve for CustomDnsResolver {
    fn resolve(&self, name: Name) -> Resolving {
        let name_str = name.as_str().to_string();
        
        Box::pin(async move {
            // 检查是否是 hanime 相关域名
            if HANIME_HOSTNAMES.iter().any(|h| name_str == *h || name_str.ends_with(&format!(".{}", h))) {
                tracing::info!("Using built-in IPs for {}", name_str);
                
                // 使用内置 IP
                let addrs: Vec<SocketAddr> = CLOUDFLARE_IPS.iter()
                    .filter_map(|ip| ip.parse::<IpAddr>().ok())
                    .map(|ip| SocketAddr::new(ip, 0))
                    .collect();
                
                if !addrs.is_empty() {
                    return Ok(Box::new(addrs.into_iter()) as Box<dyn Iterator<Item = SocketAddr> + Send>);
                }
            }
            
            // 其他域名使用系统 DNS
            tracing::debug!("Using system DNS for {}", name_str);
            
            // 使用 tokio 的 DNS 解析
            let addrs = tokio::net::lookup_host(format!("{}:0", name_str))
                .await
                .map_err(|e| -> Box<dyn std::error::Error + Send + Sync> { Box::new(e) })?
                .collect::<Vec<_>>();
            
            Ok(Box::new(addrs.into_iter()) as Box<dyn Iterator<Item = SocketAddr> + Send>)
        })
    }
}

/// 获取 Cookie Jar
pub fn get_cookie_jar() -> Arc<Jar> {
    COOKIE_JAR.get_or_init(|| Arc::new(Jar::default())).clone()
}

/// 获取 HTTP 客户端
pub fn get_client() -> &'static Client {
    CLIENT.get_or_init(|| {
        let jar = get_cookie_jar();
        
        Client::builder()
            .cookie_store(true)
            .cookie_provider(jar)
            .timeout(Duration::from_secs(30))
            .user_agent("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
            .dns_resolver(Arc::new(CustomDnsResolver))
            .build()
            .expect("Failed to create HTTP client")
    })
}

/// 设置 Cookies（从 WebView 获取后调用）
pub fn set_cookies(cookies: &str) -> Result<()> {
    let jar = get_cookie_jar();
    let url = BASE_URL.parse::<reqwest::Url>()?;
    
    for cookie_str in cookies.split(';') {
        let trimmed = cookie_str.trim();
        if !trimmed.is_empty() {
            jar.add_cookie_str(trimmed, &url);
        }
    }
    
    Ok(())
}

/// 发送 GET 请求
pub async fn get(url: &str) -> Result<String> {
    tracing::info!("GET request: {}", url);
    let client = get_client();
    
    match client.get(url).send().await {
        Ok(response) => {
            let status = response.status();
            tracing::info!("Response status: {}", status);
            
            // 检查是否需要 Cloudflare 验证
            if status == 403 || status == 503 {
                // 返回特殊错误，让 Flutter 端知道需要 WebView 验证
                return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
            }
            
            let text = response.text().await?;
            tracing::debug!("Response length: {} bytes", text.len());
            Ok(text)
        }
        Err(e) => {
            tracing::error!("Request failed: {}", e);
            Err(e.into())
        }
    }
}

/// 发送 POST 请求
pub async fn post(url: &str, body: &str) -> Result<String> {
    let client = get_client();
    let response = client
        .post(url)
        .header("Content-Type", "application/x-www-form-urlencoded")
        .body(body.to_string())
        .send()
        .await?;
    
    if response.status() == 403 || response.status() == 503 {
        return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
    }
    
    let text = response.text().await?;
    Ok(text)
}

/// 发送带 CSRF Token 的 POST 请求
pub async fn post_with_csrf(url: &str, body: &str, csrf_token: &str) -> Result<String> {
    let client = get_client();
    let response = client
        .post(url)
        .header("Content-Type", "application/x-www-form-urlencoded")
        .header("X-CSRF-TOKEN", csrf_token)
        .body(body.to_string())
        .send()
        .await?;
    
    if response.status() == 403 || response.status() == 503 {
        return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
    }
    
    let text = response.text().await?;
    Ok(text)
}

/// 下载文件到指定路径
pub async fn download_file(
    url: &str,
    path: &str,
    on_progress: impl Fn(u64, u64) + Send + Sync,
) -> Result<()> {
    use tokio::io::AsyncWriteExt;
    
    let client = get_client();
    let response = client.get(url).send().await?;
    
    let total_size = response.content_length().unwrap_or(0);
    let mut downloaded: u64 = 0;
    
    let mut file = tokio::fs::File::create(path).await?;
    let mut stream = response.bytes_stream();
    
    use futures_util::StreamExt;
    
    while let Some(chunk) = stream.next().await {
        let chunk = chunk?;
        file.write_all(&chunk).await?;
        downloaded += chunk.len() as u64;
        on_progress(downloaded, total_size);
    }
    
    file.flush().await?;
    Ok(())
}

/// 检查是否可以直接访问（无需 Cloudflare 验证）
pub async fn check_access() -> bool {
    match get(&format!("{}/", BASE_URL)).await {
        Ok(_) => true,
        Err(e) => !e.to_string().contains("CLOUDFLARE_CHALLENGE"),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_get_client() {
        let client = get_client();
        assert!(client.cookie_store());
    }
}
