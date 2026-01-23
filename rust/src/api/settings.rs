// 设置相关 API

use flutter_rust_bridge::frb;
use crate::api::models::ApiAppSettings;

/// 获取应用设置
#[frb]
pub async fn get_settings() -> anyhow::Result<ApiAppSettings> {
    // TODO: 从数据库读取设置
    Ok(ApiAppSettings::default())
}

/// 保存应用设置
#[frb]
pub async fn save_settings(settings: ApiAppSettings) -> anyhow::Result<bool> {
    // TODO: 保存到数据库
    Ok(true)
}

/// 设置默认清晰度
#[frb]
pub async fn set_default_quality(quality: String) -> anyhow::Result<bool> {
    // TODO: 保存设置
    Ok(true)
}

/// 设置下载并发数
#[frb]
pub async fn set_download_concurrent(count: u32) -> anyhow::Result<bool> {
    // TODO: 保存设置并更新下载管理器
    Ok(true)
}

/// 设置代理
#[frb]
pub async fn set_proxy(proxy_url: Option<String>) -> anyhow::Result<bool> {
    // TODO: 保存设置并更新 HTTP 客户端
    Ok(true)
}

/// 获取缓存大小
#[frb]
pub async fn get_cache_size() -> anyhow::Result<CacheInfo> {
    // TODO: 计算缓存大小
    Ok(CacheInfo {
        cover_cache_size: 0,
        video_cache_size: 0,
        total_size: 0,
    })
}

/// 清理封面缓存
#[frb]
pub async fn clear_cover_cache() -> anyhow::Result<bool> {
    // TODO: 清理封面缓存目录
    Ok(true)
}

/// 清理视频缓存（临时缓存，不含下载）
#[frb]
pub async fn clear_video_cache() -> anyhow::Result<bool> {
    // TODO: 清理视频临时缓存目录
    Ok(true)
}

/// 清理所有缓存
#[frb]
pub async fn clear_all_cache() -> anyhow::Result<bool> {
    clear_cover_cache().await?;
    clear_video_cache().await?;
    Ok(true)
}

/// 缓存信息
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct CacheInfo {
    pub cover_cache_size: u64,
    pub video_cache_size: u64,
    pub total_size: u64,
}

/// 初始化应用（启动时调用）
#[frb]
pub async fn init_app(data_dir: String, cache_dir: String) -> anyhow::Result<bool> {
    // TODO: 
    // 1. 初始化数据库
    // 2. 运行数据库迁移
    // 3. 加载 Cookie
    // 4. 初始化 HTTP 客户端
    // 5. 清理过期的临时缓存
    log::info!("Initializing app with data_dir: {}, cache_dir: {}", data_dir, cache_dir);
    Ok(true)
}

/// 获取应用版本信息
#[frb]
pub fn get_app_version() -> String {
    env!("CARGO_PKG_VERSION").to_string()
}
