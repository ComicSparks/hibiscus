// 网络请求模块

use crate::core::storage;
use anyhow::Result;
use reqwest::cookie::Jar;
use reqwest::dns::{Name, Resolve, Resolving};
use reqwest::Client;
use std::net::{IpAddr, SocketAddr};
use std::sync::Arc;
use std::sync::OnceLock;
use std::time::Duration;

/// 全局 HTTP 客户端
static CLIENT: OnceLock<Client> = OnceLock::new();

/// Cookie 存储
static COOKIE_JAR: OnceLock<Arc<Jar>> = OnceLock::new();

/// 基础 URL
pub const BASE_URL: &str = "https://hanime1.me";

/// 支持的域名列表
const HANIME_HOSTNAMES: &[&str] = &["hanime1.me", "hanime1.com", "hanimeone.me", "javchu.com"];

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
            if HANIME_HOSTNAMES
                .iter()
                .any(|h| name_str == *h || name_str.ends_with(&format!(".{}", h)))
            {
                tracing::info!("Using built-in IPs for {}", name_str);

                // 使用内置 IP
                let addrs: Vec<SocketAddr> = CLOUDFLARE_IPS
                    .iter()
                    .filter_map(|ip| ip.parse::<IpAddr>().ok())
                    .map(|ip| SocketAddr::new(ip, 0))
                    .collect();

                if !addrs.is_empty() {
                    return Ok(
                        Box::new(addrs.into_iter()) as Box<dyn Iterator<Item = SocketAddr> + Send>
                    );
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

/// 清除关键会话 Cookies（尽力而为）
pub fn clear_cookies() -> Result<()> {
    let jar = get_cookie_jar();
    let url = BASE_URL.parse::<reqwest::Url>()?;

    // 通过 Max-Age=0 让 Cookie 过期；Jar 会按域名/路径匹配
    jar.add_cookie_str(
        "hanime1_session=; Max-Age=0; Path=/; Domain=.hanime1.me",
        &url,
    );
    jar.add_cookie_str("cf_clearance=; Max-Age=0; Path=/; Domain=.hanime1.me", &url);
    jar.add_cookie_str("XSRF-TOKEN=; Max-Age=0; Path=/; Domain=.hanime1.me", &url);
    Ok(())
}

/// 发送 GET 请求
pub async fn get(url: &str) -> Result<String> {
    tracing::info!("GET request: {}", url);
    let client = get_client();

    match client.get(url).send().await {
        Ok(response) => {
            persist_response_cookies(&response);
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
    persist_response_cookies(&response);

    if response.status() == 403 || response.status() == 503 {
        return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
    }

    let text = response.text().await?;
    Ok(text)
}

/// 发送带 `X-CSRF-TOKEN` header 的 POST 请求
pub async fn post_with_x_csrf_token(url: &str, body: &str, x_csrf_token: &str) -> Result<String> {
    let client = get_client();
    tracing::info!(
        "POST (X-CSRF-TOKEN) url={} x_csrf_token_len={} body_len={}",
        url,
        x_csrf_token.len(),
        body.len()
    );
    let response = client
        .post(url)
        .header("Content-Type", "application/x-www-form-urlencoded")
        .header("X-CSRF-TOKEN", x_csrf_token)
        .body(body.to_string())
        .send()
        .await?;
    persist_response_cookies(&response);

    if response.status() == 403 || response.status() == 503 {
        return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
    }

    let status = response.status();
    let text = response.text().await?;
    let snippet: String = text.chars().take(240).collect();
    tracing::info!(
        "POST (X-CSRF-TOKEN) resp status={} len={} snippet={:?}",
        status.as_u16(),
        text.len(),
        snippet
    );
    Ok(text)
}

/// 兼容旧名字：这里的参数是 `X-CSRF-TOKEN` header 值，不是表单 `_token`
pub async fn post_with_csrf(url: &str, body: &str, csrf_token: &str) -> Result<String> {
    post_with_x_csrf_token(url, body, csrf_token).await
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

fn persist_response_cookies(response: &reqwest::Response) {
    use reqwest::header::SET_COOKIE;

    let url = match reqwest::Url::parse(BASE_URL) {
        Ok(u) => u,
        Err(_) => return,
    };

    for value in response.headers().get_all(SET_COOKIE).iter() {
        let Ok(raw) = value.to_str() else {
            continue;
        };
        // keep jar updated (Domain/Path/Expires handling is done by the cookie parser inside)
        get_cookie_jar().add_cookie_str(raw, &url);
        // best-effort persist for next launch
        persist_set_cookie_to_db(raw);
    }
}

fn persist_set_cookie_to_db(set_cookie: &str) {
    let mut last_expires: Option<i64> = None;
    let mut last_domain: Option<String> = None;
    let mut last_path: Option<String> = None;

    // very small parser: "name=value; Expires=...; Max-Age=...; Path=/; Domain=.hanime1.me; ..."
    for part in set_cookie.split(';') {
        let trimmed = part.trim();
        if trimmed.is_empty() {
            continue;
        }

        let lower = trimmed.to_ascii_lowercase();
        if lower.starts_with("expires=") {
            let value = trimmed[8..].trim();
            if let Ok(time) = chrono::DateTime::parse_from_rfc2822(value) {
                last_expires = Some(time.timestamp());
            }
            continue;
        }
        if lower.starts_with("max-age=") {
            if let Ok(age) = trimmed[8..].trim().parse::<i64>() {
                last_expires = Some(chrono::Utc::now().timestamp() + age);
            }
            continue;
        }
        if lower.starts_with("domain=") {
            last_domain = Some(trimmed[7..].trim().trim_start_matches('.').to_string());
            continue;
        }
        if lower.starts_with("path=") {
            last_path = Some(trimmed[5..].trim().to_string());
            continue;
        }
        if lower == "httponly" || lower == "secure" || lower.starts_with("samesite=") {
            continue;
        }

        if let Some(idx) = trimmed.find('=') {
            let name = trimmed[..idx].trim();
            let value = trimmed[idx + 1..].trim();
            let domain = last_domain.as_deref().unwrap_or("hanime1.me");
            let path = last_path.as_deref().unwrap_or("/");
            let _ = storage::save_cookie(domain, name, value, path, last_expires);
            // reset per-cookie attributes
            last_expires = None;
            last_domain = None;
            last_path = None;
        }
    }
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
    #[ignore]
    fn test_get_client() {
        let _client = get_client();
    }
}
