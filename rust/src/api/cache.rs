// 缓存相关 API（暴露给 Flutter）

use crate::core::cache::{
    image_cache, utils, web_cache, IMAGE_CACHE_EXPIRE_MS, WEB_CACHE_EXPIRE_MS,
};
use flutter_rust_bridge::frb;

/// 缓存大小信息
#[frb]
#[derive(Debug, Clone, Default)]
pub struct CacheSize {
    /// 图片缓存大小（字节）
    pub image_cache_bytes: u64,
    /// 图片缓存文件数量
    pub image_cache_count: u64,
    /// Web 缓存条目数量
    pub web_cache_count: u64,
}

/// 自动清理缓存（启动时调用）
/// - web_expire_ms: Web 缓存过期时间（毫秒），默认 10 分钟
/// - image_expire_ms: 图片缓存过期时间（毫秒），默认 3 天
#[frb]
pub async fn auto_clean_cache(
    web_expire_ms: Option<i64>,
    image_expire_ms: Option<i64>,
) -> anyhow::Result<()> {
    let now = chrono::Local::now().timestamp_millis();

    // 清理 Web 缓存
    let web_expire = web_expire_ms.unwrap_or(WEB_CACHE_EXPIRE_MS);
    let web_before = now - web_expire;
    let web_cleaned = web_cache::clean_expired(web_before)?;
    tracing::info!("Auto cleaned {} web cache entries", web_cleaned);

    // 清理图片缓存
    let image_expire = image_expire_ms.unwrap_or(IMAGE_CACHE_EXPIRE_MS);
    let image_before = now - image_expire;
    let (records, files) = image_cache::clean_expired(image_before)?;
    tracing::info!(
        "Auto cleaned {} image cache records, {} files",
        records,
        files
    );

    // VACUUM 数据库
    utils::vacuum_database()?;

    Ok(())
}

/// 清理所有缓存
#[frb]
pub async fn clear_all_cache() -> anyhow::Result<()> {
    // 清理 Web 缓存
    let web_cleaned = web_cache::clean_all()?;
    tracing::info!("Cleared {} web cache entries", web_cleaned);

    // 清理图片缓存
    let (records, files) = image_cache::clean_all()?;
    tracing::info!("Cleared {} image cache records, {} files", records, files);

    // VACUUM 数据库
    utils::vacuum_database()?;

    Ok(())
}

/// 仅清理图片缓存
#[frb]
pub async fn clear_image_cache() -> anyhow::Result<()> {
    let (records, files) = image_cache::clean_all()?;
    tracing::info!("Cleared {} image cache records, {} files", records, files);
    utils::vacuum_database()?;
    Ok(())
}

/// 仅清理 Web 缓存
#[frb]
pub async fn clear_web_cache() -> anyhow::Result<()> {
    let cleaned = web_cache::clean_all()?;
    tracing::info!("Cleared {} web cache entries", cleaned);
    utils::vacuum_database()?;
    Ok(())
}

/// 获取缓存大小信息
#[frb]
pub fn get_cache_size() -> anyhow::Result<CacheSize> {
    let image_bytes = image_cache::get_cache_size()?;
    let image_count = image_cache::get_cache_count()?;

    // 获取 web 缓存数量
    let db = crate::core::storage::get_db()?;
    let web_count: i64 = db.query_row("SELECT COUNT(1) FROM web_cache", [], |row| row.get(0))?;

    Ok(CacheSize {
        image_cache_bytes: image_bytes,
        image_cache_count: image_count,
        web_cache_count: web_count as u64,
    })
}

/// 加载缓存图片（如果不存在则下载）
/// 返回本地文件路径
#[frb]
pub async fn load_cached_image(url: String) -> anyhow::Result<String> {
    image_cache::load_cached_image(&url).await
}

/// VACUUM 数据库
#[frb]
pub fn vacuum_database() -> anyhow::Result<()> {
    utils::vacuum_database()
}
