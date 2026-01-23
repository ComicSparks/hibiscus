// 初始化和系统相关 API

use flutter_rust_bridge::frb;
use crate::core::{network, storage};

/// 初始化应用（在 Flutter 启动时调用）
#[frb]
pub async fn init_app(data_path: String) -> anyhow::Result<()> {
    // 初始化日志
    tracing_subscriber::fmt::init();
    
    // 初始化数据库
    let db_path = format!("{}/data.db", data_path);
    storage::init_db(Some(&db_path))?;
    
    // 加载保存的 Cookies
    load_saved_cookies().await?;
    
    tracing::info!("App initialized with data path: {}", data_path);
    Ok(())
}

/// 加载保存的 Cookies
async fn load_saved_cookies() -> anyhow::Result<()> {
    let cookies = storage::get_cookies("hanime1.me")?;
    
    if !cookies.is_empty() {
        let cookie_str: String = cookies
            .iter()
            .map(|(k, v)| format!("{}={}", k, v))
            .collect::<Vec<_>>()
            .join("; ");
        
        network::set_cookies(&cookie_str)?;
        tracing::info!("Loaded {} cookies from storage", cookies.len());
    }
    
    Ok(())
}

/// 设置 Cookies（从 WebView 获取后调用）
#[frb]
pub async fn set_cookies(cookie_string: String) -> anyhow::Result<()> {
    // 设置到网络模块
    network::set_cookies(&cookie_string)?;
    
    // 解析并保存到数据库
    for part in cookie_string.split(';') {
        let trimmed = part.trim();
        if let Some(idx) = trimmed.find('=') {
            let name = &trimmed[..idx].trim();
            let value = &trimmed[idx + 1..].trim();
            
            storage::save_cookie(
                "hanime1.me",
                name,
                value,
                "/",
                None, // TODO: 解析过期时间
            )?;
        }
    }
    
    tracing::info!("Cookies saved");
    Ok(())
}

/// 检查是否需要 Cloudflare 验证
#[frb]
pub async fn check_cloudflare() -> anyhow::Result<bool> {
    // 尝试访问首页
    let needs_challenge = !network::check_access().await;
    
    if needs_challenge {
        tracing::info!("Cloudflare challenge required");
    } else {
        tracing::info!("No Cloudflare challenge needed");
    }
    
    Ok(needs_challenge)
}

/// 清除所有 Cookies（登出时调用）
#[frb]
pub async fn clear_cookies() -> anyhow::Result<()> {
    storage::clear_cookies()?;
    tracing::info!("All cookies cleared");
    Ok(())
}

/// 获取应用版本
#[frb]
pub fn get_version() -> String {
    env!("CARGO_PKG_VERSION").to_string()
}

/// 检查网络连接
#[frb]
pub async fn check_network() -> anyhow::Result<bool> {
    match reqwest::get("https://www.google.com").await {
        Ok(_) => Ok(true),
        Err(_) => {
            // 尝试备用地址
            match reqwest::get("https://www.baidu.com").await {
                Ok(_) => Ok(true),
                Err(_) => Ok(false),
            }
        }
    }
}
