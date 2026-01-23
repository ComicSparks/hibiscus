// 网络请求模块

use std::sync::OnceLock;
use std::time::Duration;
use reqwest::cookie::Jar;
use reqwest::Client;
use std::sync::Arc;
use anyhow::Result;

/// 全局 HTTP 客户端
static CLIENT: OnceLock<Client> = OnceLock::new();

/// Cookie 存储
static COOKIE_JAR: OnceLock<Arc<Jar>> = OnceLock::new();

/// 基础 URL
pub const BASE_URL: &str = "https://hanime1.me";

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
    let client = get_client();
    let response = client.get(url).send().await?;
    
    // 检查是否需要 Cloudflare 验证
    if response.status() == 403 || response.status() == 503 {
        // 返回特殊错误，让 Flutter 端知道需要 WebView 验证
        return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
    }
    
    let text = response.text().await?;
    Ok(text)
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
