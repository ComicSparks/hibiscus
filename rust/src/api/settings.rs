// 设置相关 API

use crate::api::models::ApiAppSettings;
use crate::core::storage;
use flutter_rust_bridge::frb;
use std::path::PathBuf;

/// 获取应用设置
#[frb]
pub async fn get_settings() -> anyhow::Result<ApiAppSettings> {
    let default = ApiAppSettings::default();
    let theme_mode = storage::get_setting("theme_mode")?.unwrap_or(default.theme_mode);
    let default_quality =
        storage::get_setting("default_quality")?.unwrap_or(default.default_quality);
    let download_concurrent = storage::get_setting("download_concurrent")?
        .and_then(|v| v.parse::<u32>().ok())
        .unwrap_or(default.download_concurrent);
    let proxy_url = storage::get_setting("proxy_url")?;
    let language = storage::get_setting("language")?.unwrap_or(default.language);

    Ok(ApiAppSettings {
        default_quality,
        download_concurrent,
        proxy_url,
        theme_mode,
        language,
    })
}

/// 保存应用设置
#[frb]
pub async fn save_settings(settings: ApiAppSettings) -> anyhow::Result<bool> {
    storage::save_setting("default_quality", &settings.default_quality)?;
    storage::save_setting(
        "download_concurrent",
        &settings.download_concurrent.to_string(),
    )?;
    storage::save_setting("theme_mode", &settings.theme_mode)?;
    storage::save_setting("language", &settings.language)?;
    if let Some(url) = settings.proxy_url.as_deref() {
        storage::save_setting("proxy_url", url)?;
    } else {
        storage::delete_setting("proxy_url")?;
    }
    Ok(true)
}

/// 设置默认清晰度
#[frb]
pub async fn set_default_quality(quality: String) -> anyhow::Result<bool> {
    storage::save_setting("default_quality", &quality)?;
    Ok(true)
}

/// 设置下载并发数
#[frb]
pub async fn set_download_concurrent(count: u32) -> anyhow::Result<bool> {
    storage::save_setting("download_concurrent", &count.to_string())?;
    Ok(true)
}

/// 设置代理
#[frb]
pub async fn set_proxy(proxy_url: Option<String>) -> anyhow::Result<bool> {
    if let Some(url) = proxy_url.as_deref() {
        storage::save_setting("proxy_url", url)?;
    } else {
        storage::delete_setting("proxy_url")?;
    }
    Ok(true)
}

/// Flutter 侧 settingsState 的持久化（JSON string）
#[frb]
pub async fn get_flutter_settings() -> anyhow::Result<Option<String>> {
    Ok(storage::get_setting("flutter_settings_v1")?)
}

/// Flutter 侧 settingsState 的持久化（JSON string）
#[frb]
pub async fn save_flutter_settings(json: String) -> anyhow::Result<bool> {
    storage::save_setting("flutter_settings_v1", &json)?;
    Ok(true)
}

/// 获取缓存大小
#[frb]
pub async fn get_cache_size() -> anyhow::Result<CacheInfo> {
    let cover_cache_size = dir_size(storage::get_data_dir()?.join("download_covers"));
    let avatar_cache_size = dir_size(storage::get_data_dir()?.join("download_avatars"));
    let total_size = cover_cache_size.saturating_add(avatar_cache_size);
    Ok(CacheInfo {
        cover_cache_size: cover_cache_size.saturating_add(avatar_cache_size),
        video_cache_size: 0,
        total_size,
    })
}

/// 清理视频缓存（临时缓存，不含下载）
#[frb]
pub async fn clear_video_cache() -> anyhow::Result<bool> {
    Ok(true)
}

/// 清理所有缓存
#[frb]
pub async fn clear_all_cache() -> anyhow::Result<bool> {
    clear_cover_cache().await?;
    clear_video_cache().await?;
    Ok(true)
}

/// 获取数据目录路径（用于桌面端打开数据存储目录）
#[frb]
pub async fn get_data_dir_path() -> anyhow::Result<String> {
    Ok(storage::get_data_dir()?.to_string_lossy().to_string())
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
    log::info!(
        "Initializing app with data_dir: {}, cache_dir: {}",
        data_dir,
        cache_dir
    );
    Ok(true)
}

/// 获取应用版本信息
#[frb]
pub fn get_app_version() -> String {
    env!("CARGO_PKG_VERSION").to_string()
}

fn dir_size(path: PathBuf) -> u64 {
    fn walk(p: &std::path::Path) -> u64 {
        let mut total = 0u64;
        let Ok(rd) = std::fs::read_dir(p) else {
            return 0;
        };
        for entry in rd.flatten() {
            let Ok(meta) = entry.metadata() else {
                continue;
            };
            if meta.is_file() {
                total = total.saturating_add(meta.len());
            } else if meta.is_dir() {
                total = total.saturating_add(walk(&entry.path()));
            }
        }
        total
    }
    walk(&path)
}
