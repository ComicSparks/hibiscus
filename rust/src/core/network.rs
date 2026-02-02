// 网络请求模块

use crate::core::storage;
use anyhow::{anyhow, Result};
use reqwest::{
    cookie::Jar,
    dns::{Name, Resolve, Resolving},
    header::{HeaderMap, HeaderName, HeaderValue, CONTENT_TYPE, REFERER, USER_AGENT},
    Client, RequestBuilder, Url,
};
use std::net::{IpAddr, SocketAddr};
use std::sync::{Arc, OnceLock, RwLock};
use std::time::Duration;

/// 全局 HTTP 客户端
static CLIENT: OnceLock<Client> = OnceLock::new();

/// Cookie 存储
static COOKIE_JAR: OnceLock<Arc<Jar>> = OnceLock::new();

/// 缓存的 UserAgent
static CACHED_USER_AGENT: OnceLock<RwLock<Option<String>>> = OnceLock::new();

/// 支持的域名列表
pub(crate) const HANIME_HOSTNAMES: &[&str] =
    &["hanime1.me", "hanime1.com", "hanimeone.me", "javchu.com"];

/// 内置的 Cloudflare IP（来自 Han1meViewer）
const CLOUDFLARE_IPS: &[&str] = &[
    "172.64.229.154",
    "104.25.254.167",
    "172.67.75.184",
    "104.21.7.20",
    "172.67.187.141",
];

/// 浏览器保存的 UserAgent 的 key（与 Flutter 端一致）
const BROWSER_USER_AGENT_KEY: &str = "hibiscus_browser_user_agent";

/// 默认 UserAgent（当数据库中没有保存时使用）
const DEFAULT_USER_AGENT: &str = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";

// 注意：不要手动设置 accept-encoding，让 reqwest 自动处理 gzip/deflate/br 解压
const COMMON_HEADER_PAIRS: &[(&str, &str)] = &[
    (
        "accept",
        "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
    ),
    ("accept-language", "en-US,en;q=0.9"),
    ("cache-control", "max-age=0"),
    ("connection", "keep-alive"),
    ("sec-fetch-site", "none"),
    ("sec-fetch-mode", "navigate"),
    ("sec-fetch-dest", "document"),
    ("sec-fetch-user", "?1"),
];

#[derive(Copy, Clone)]
enum BrowserFamily {
    Chrome,
    Firefox,
    Safari,
}

#[derive(Clone)]
pub struct ActiveDomain {
    pub host: String,
    pub use_custom_dns: bool,
}

impl ActiveDomain {
    fn base_url(&self) -> String {
        format!("https://{}", self.host)
    }

    #[allow(dead_code)]
    fn login_url(&self) -> String {
        format!("{}/login", self.base_url())
    }

    fn referer(&self) -> String {
        format!("{}/", self.base_url())
    }

    pub fn cookie_domain(&self) -> &str {
        &self.host
    }
}

const ACTIVE_DOMAIN_HOST_KEY: &str = "network.active_host";
const ACTIVE_DOMAIN_CUSTOM_DNS_KEY: &str = "network.use_custom_dns";
const DEFAULT_ACTIVE_HOST: &str = "hanime1.me";
const DEFAULT_USE_CUSTOM_DNS: bool = true;

fn read_active_domain_from_storage() -> ActiveDomain {
    let host = storage::get_setting(ACTIVE_DOMAIN_HOST_KEY)
        .unwrap_or_else(|_| None)
        .and_then(|v| {
            let trimmed = v.trim();
            if trimmed.is_empty() {
                None
            } else {
                Some(trimmed.to_string())
            }
        })
        .unwrap_or_else(|| DEFAULT_ACTIVE_HOST.to_string());

    let use_custom = storage::get_setting(ACTIVE_DOMAIN_CUSTOM_DNS_KEY)
        .unwrap_or_else(|_| None)
        .and_then(|v| v.parse::<bool>().ok())
        .unwrap_or(DEFAULT_USE_CUSTOM_DNS);

    ActiveDomain {
        host,
        use_custom_dns: use_custom,
    }
}

pub fn get_active_domain() -> ActiveDomain {
    read_active_domain_from_storage()
}

pub fn base_url() -> String {
    get_active_domain().base_url()
}

pub fn referer() -> String {
    get_active_domain().referer()
}

/// 自定义 DNS 解析器
struct CustomDnsResolver;

impl Resolve for CustomDnsResolver {
    fn resolve(&self, name: Name) -> Resolving {
        let name_str = name.as_str().to_string();

        Box::pin(async move {
            let active_domain = get_active_domain();
            if active_domain.use_custom_dns
                && HANIME_HOSTNAMES
                    .iter()
                    .any(|h| name_str == *h || name_str.ends_with(&format!(".{}", h)))
            {
                tracing::info!("Using built-in IPs for {}", name_str);

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

            tracing::debug!("Using system DNS for {}", name_str);

            let addrs = tokio::net::lookup_host(format!("{}:0", name_str))
                .await
                .map_err(|e| -> Box<dyn std::error::Error + Send + Sync> { Box::new(e) })?
                .collect::<Vec<_>>();

            Ok(Box::new(addrs.into_iter()) as Box<dyn Iterator<Item = SocketAddr> + Send>)
        })
    }
}

/// 获取缓存的 UserAgent 锁
fn get_ua_cache() -> &'static RwLock<Option<String>> {
    CACHED_USER_AGENT.get_or_init(|| RwLock::new(None))
}

/// 从数据库读取 UserAgent
fn read_user_agent_from_db() -> Result<Option<String>> {
    if let Some(value) = storage::get_setting(BROWSER_USER_AGENT_KEY)? {
        let trimmed = value.trim();
        if !trimmed.is_empty() {
            return Ok(Some(trimmed.to_string()));
        }
    }
    Ok(None)
}

/// 获取 UserAgent（优先使用缓存，否则从数据库读取）
pub fn get_or_init_user_agent() -> Result<String> {
    // 先尝试从缓存读取
    {
        let cache = get_ua_cache().read().map_err(|e| anyhow!("Failed to read UA cache: {}", e))?;
        if let Some(ref ua) = *cache {
            return Ok(ua.clone());
        }
    }

    // 从数据库读取
    let ua = read_user_agent_from_db()?.unwrap_or_else(|| DEFAULT_USER_AGENT.to_string());

    // 更新缓存
    {
        let mut cache = get_ua_cache().write().map_err(|e| anyhow!("Failed to write UA cache: {}", e))?;
        *cache = Some(ua.clone());
    }

    Ok(ua)
}

/// 重新加载 UserAgent（当 Flutter 端保存了新的 UA 后调用）
pub fn reload_user_agent() -> Result<String> {
    let ua = read_user_agent_from_db()?.unwrap_or_else(|| DEFAULT_USER_AGENT.to_string());

    // 更新缓存
    {
        let mut cache = get_ua_cache().write().map_err(|e| anyhow!("Failed to write UA cache: {}", e))?;
        *cache = Some(ua.clone());
    }

    tracing::info!("UserAgent reloaded: {}", ua);
    Ok(ua)
}

struct SecChHeaders {
    ua: String,
    mobile: String,
    platform: String,
    platform_version: String,
}

fn detect_platform_info(ua: &str) -> (&'static str, &'static str, bool) {
    if ua.contains("Android") {
        ("Android", "13.0.0", true)
    } else if ua.contains("iPhone") || ua.contains("iPad") {
        ("iOS", "17.0.0", true)
    } else if ua.contains("Macintosh") {
        ("macOS", "13.5.0", false)
    } else if ua.contains("Windows") {
        ("Windows", "10.0.0", false)
    } else {
        ("Linux", "1.0.0", ua.contains("Mobile"))
    }
}

fn parse_major_version(ua: &str, marker: &str) -> Option<u16> {
    ua.split(marker)
        .nth(1)
        .and_then(|rest| rest.split('.').next())
        .and_then(|num| num.parse::<u16>().ok())
}

fn build_sec_ch_headers(user_agent: &str) -> SecChHeaders {
    let has_firefox = user_agent.contains("Firefox/");
    let has_safari = user_agent.contains("Safari/") && user_agent.contains("Version/");
    let family = if has_firefox {
        BrowserFamily::Firefox
    } else if has_safari {
        BrowserFamily::Safari
    } else {
        BrowserFamily::Chrome
    };

    let major = match family {
        BrowserFamily::Chrome => parse_major_version(user_agent, "Chrome/"),
        BrowserFamily::Firefox => parse_major_version(user_agent, "Firefox/"),
        BrowserFamily::Safari => parse_major_version(user_agent, "Version/"),
    }
    .unwrap_or(120);

    let (platform, platform_version, is_mobile) = detect_platform_info(user_agent);

    let ua_value = match family {
        BrowserFamily::Chrome => {
            format!(
                "\"Chromium\";v=\"{major}\", \"Google Chrome\";v=\"{major}\", \"Not A(Brand\";v=\"99\""
            )
        }
        BrowserFamily::Firefox => format!(
            "\"Chromium\";v=\"{major}\", \"Firefox\";v=\"{major}\", \"Not A(Brand\";v=\"99\""
        ),
        BrowserFamily::Safari => format!(
            "\"Not A(Brand\";v=\"99\", \"Safari\";v=\"{major}\", \"Chromium\";v=\"{major}\""
        ),
    };

    SecChHeaders {
        ua: ua_value,
        mobile: if is_mobile {
            "?1".to_string()
        } else {
            "?0".to_string()
        },
        platform: format!("\"{platform}\""),
        platform_version: format!("\"{platform_version}\""),
    }
}

fn ensure_cookies_loaded(domain: &str) {
    let jar = get_cookie_jar();
    let url = match Url::parse(&format!("https://{}", domain)) {
        Ok(u) => u,
        Err(_) => return,
    };

    match storage::get_cookies(domain) {
        Ok(cookies) => {
            log::info!(
                "domain: {}, cookies: {:?}",
                domain,
                cookies.iter().map(|(name, value)| format!("{}={}", name, value)).collect::<Vec<_>>().join("; ")
            );
            for (name, value) in cookies {
                let cookie = format!("{}={}", name, value);
                jar.add_cookie_str(&cookie, &url);
            }
        }
        Err(e) => tracing::warn!("Failed to load cookies for {}: {}", domain, e),
    }
}

fn build_default_header_map(active: &ActiveDomain) -> Result<HeaderMap> {
    let user_agent = get_or_init_user_agent()?;
    let mut headers = HeaderMap::with_capacity(COMMON_HEADER_PAIRS.len() + 4);
    headers.insert(
        USER_AGENT,
        HeaderValue::from_str(&user_agent).map_err(|e| anyhow!("Invalid User-Agent: {}", e))?,
    );
    for (name, value) in COMMON_HEADER_PAIRS {
        let header_name = HeaderName::from_lowercase(name.as_bytes())
            .map_err(|e| anyhow!("Invalid header name {}: {}", name, e))?;
        headers.insert(header_name, HeaderValue::from_static(value));
    }

    headers.insert(
        REFERER,
        HeaderValue::from_str(&active.referer())
            .map_err(|e| anyhow!("Invalid referer {}: {}", active.referer(), e))?,
    );

    let sec_ch = build_sec_ch_headers(&user_agent);
    headers.insert(
        HeaderName::from_static("sec-ch-ua"),
        HeaderValue::from_str(&sec_ch.ua).map_err(|e| anyhow!("Invalid Sec-CH-UA: {}", e))?,
    );
    headers.insert(
        HeaderName::from_static("sec-ch-ua-mobile"),
        HeaderValue::from_str(&sec_ch.mobile)
            .map_err(|e| anyhow!("Invalid Sec-CH-UA-Mobile: {}", e))?,
    );
    headers.insert(
        HeaderName::from_static("sec-ch-ua-platform"),
        HeaderValue::from_str(&sec_ch.platform)
            .map_err(|e| anyhow!("Invalid Sec-CH-UA-Platform: {}", e))?,
    );
    headers.insert(
        HeaderName::from_static("sec-ch-ua-platform-version"),
        HeaderValue::from_str(&sec_ch.platform_version)
            .map_err(|e| anyhow!("Invalid Sec-CH-UA-Platform-Version: {}", e))?,
    );

    Ok(headers)
}

fn apply_default_headers(builder: RequestBuilder, active: &ActiveDomain) -> Result<RequestBuilder> {
    ensure_cookies_loaded(active.cookie_domain());
    let headers = build_default_header_map(active)?;
    Ok(builder.headers(headers))
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
            .dns_resolver(Arc::new(CustomDnsResolver))
            .build()
            .expect("Failed to create HTTP client")
    })
}

/// 设置 Cookies（从 WebView 获取后调用）
pub fn set_cookies(cookies: &str, domain: Option<&str>) -> Result<()> {
    let jar = get_cookie_jar();
    let active = get_active_domain();
    let host = domain.unwrap_or(active.cookie_domain());
    let url = Url::parse(&format!("https://{}", host))?;

    for cookie_pair in cookies.split(';') {
        let trimmed = cookie_pair.trim();
        if trimmed.is_empty() {
            continue;
        }
        if let Some(idx) = trimmed.find('=') {
            let name = trimmed[..idx].trim();
            let value = trimmed[idx + 1..].trim();
            if name.is_empty() {
                continue;
            }

            let cookie_str = format!("{}={}", name, value);
            jar.add_cookie_str(&cookie_str, &url);
            if let Err(e) = storage::save_cookie(host, name, value, "/", None) {
                tracing::warn!("Failed to persist cookie {} for {}: {}", name, host, e);
            }
        }
    }

    Ok(())
}

/// 清除关键会话 Cookies（尽力而为）
pub fn clear_cookies(domain: Option<&str>) -> Result<()> {
    let jar = get_cookie_jar();
    let active = get_active_domain();
    let host = domain.unwrap_or(active.cookie_domain());
    let url = Url::parse(&format!("https://{}", host))?;

    let cookie_domain = format!(".{}", host);

    jar.add_cookie_str(
        &format!(
            "hanime1_session=; Max-Age=0; Path=/; Domain={}",
            cookie_domain
        ),
        &url,
    );
    jar.add_cookie_str(
        &format!("cf_clearance=; Max-Age=0; Path=/; Domain={}", cookie_domain),
        &url,
    );
    jar.add_cookie_str(
        &format!("XSRF-TOKEN=; Max-Age=0; Path=/; Domain={}", cookie_domain),
        &url,
    );
    Ok(())
}

/// 发送 GET 请求
pub async fn get(url: &str) -> Result<String> {
    tracing::info!("GET request: {}", url);
    let client = get_client();

    let active = get_active_domain();
    let request = apply_default_headers(client.get(url), &active)?;
    match request.send().await {
        Ok(response) => {
            let domain = active.cookie_domain().to_string();
            persist_response_cookies(&response, &domain);
            let status = response.status();
            tracing::info!("Response status: {}", status);

            // 检查是否需要 Cloudflare 验证
            if status == 403 || status == 503 {
                // 返回特殊错误，让 Flutter 端知道需要 WebView 验证
                return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
            }

            let text = response.text().await?;
            log::info!(
                "url: {}, code: {}, response: {:?}",
                url,
                status.as_u16(),
                text
            );
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
    let active = get_active_domain();
    let response = apply_default_headers(client.post(url), &active)?
        .header(CONTENT_TYPE, "application/x-www-form-urlencoded")
        .body(body.to_string())
        .send()
        .await?;
    let domain = active.cookie_domain().to_string();
    persist_response_cookies(&response, &domain);

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
    let active = get_active_domain();
    let response = apply_default_headers(client.post(url), &active)?
        .header(CONTENT_TYPE, "application/x-www-form-urlencoded")
        .header("X-CSRF-TOKEN", x_csrf_token)
        .body(body.to_string())
        .send()
        .await?;
    let domain = active.cookie_domain().to_string();
    persist_response_cookies(&response, &domain);

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
    let active = get_active_domain();
    let response = apply_default_headers(client.get(url), &active)?
        .send()
        .await?;
    let domain = active.cookie_domain().to_string();

    persist_response_cookies(&response, &domain);
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

fn persist_response_cookies(response: &reqwest::Response, domain: &str) {
    use reqwest::header::SET_COOKIE;

    let url = match reqwest::Url::parse(&format!("https://{}", domain)) {
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
        persist_set_cookie_to_db(raw, domain);
    }
}

fn persist_set_cookie_to_db(set_cookie: &str, fallback_domain: &str) {
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
            let domain = last_domain.as_deref().unwrap_or(fallback_domain);
            let path = last_path.as_deref().unwrap_or("/");
            let _ = storage::save_cookie(domain, name, value, path, last_expires);
            // reset per-cookie attributes
            last_expires = None;
            last_domain = None;
            last_path = None;
        }
    }
}

/// 发送 GET 请求，返回字节数据（用于下载图片等）
pub async fn get_bytes(url: &str) -> Result<Vec<u8>> {
    tracing::debug!("GET bytes: {}", url);
    let client = get_client();

    let active = get_active_domain();
    let response = apply_default_headers(client.get(url), &active)?
        .send()
        .await?;
    let domain = active.cookie_domain().to_string();
    persist_response_cookies(&response, &domain);

    let status = response.status();
    if status == 403 || status == 503 {
        return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
    }

    let bytes = response.bytes().await?;
    Ok(bytes.to_vec())
}

/// 检查是否可以直接访问（无需 Cloudflare 验证）
pub async fn check_access() -> bool {
    match get(&format!("{}/", base_url())).await {
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
