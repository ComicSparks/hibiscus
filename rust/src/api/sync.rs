// WebDAV 同步 API
// 用于同步浏览历史到 WebDAV 服务器

use crate::core::{storage, webdav};
use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};

/// WebDAV 设置
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ApiWebDavSettings {
    pub url: String,
    pub username: String,
    pub password: String,
    /// 加密密钥，为空时使用默认值 "hibiscus"
    pub encryption_key: String,
    /// 启动时自动同步
    pub auto_sync_on_start: bool,
    /// 自动同步间隔（分钟），0 为不自动同步
    pub auto_sync_interval: i32,
}

impl Default for ApiWebDavSettings {
    fn default() -> Self {
        Self {
            url: String::new(),
            username: String::new(),
            password: String::new(),
            encryption_key: String::new(),
            auto_sync_on_start: false,
            auto_sync_interval: 0,
        }
    }
}

/// 同步状态
#[derive(Debug, Clone)]
pub enum ApiSyncStatus {
    /// 同步成功
    Success { merged_count: i32, uploaded: bool },
    /// 解密失败，需要用户确认
    DecryptionFailed,
    /// 需要输入新密钥
    NeedNewKey,
    /// 网络错误
    NetworkError { message: String },
    /// 配置未设置
    NotConfigured,
}

/// 同步进度
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiSyncProgress {
    pub stage: String,
    pub progress: f32,
    pub message: String,
}

/// 获取 WebDAV 设置
#[frb]
pub async fn get_webdav_settings() -> anyhow::Result<ApiWebDavSettings> {
    let json = storage::get_setting("webdav_settings")?;
    match json {
        Some(j) => Ok(serde_json::from_str(&j)?),
        None => Ok(ApiWebDavSettings::default()),
    }
}

/// 保存 WebDAV 设置
#[frb]
pub async fn save_webdav_settings(settings: ApiWebDavSettings) -> anyhow::Result<bool> {
    let json = serde_json::to_string(&settings)?;
    storage::save_setting("webdav_settings", &json)?;
    Ok(true)
}

/// 测试 WebDAV 连接
#[frb]
pub async fn test_webdav_connection(
    url: String,
    username: String,
    password: String,
) -> anyhow::Result<bool> {
    let client = webdav::WebDavClient::new(&url, &username, &password);
    client.test_connection().await?;
    Ok(true)
}

/// 执行同步
#[frb]
pub async fn sync_history(force_upload: bool) -> anyhow::Result<ApiSyncStatus> {
    // 获取设置
    let settings = get_webdav_settings().await?;
    if settings.url.is_empty() {
        return Ok(ApiSyncStatus::NotConfigured);
    }

    let client = webdav::WebDavClient::new(&settings.url, &settings.username, &settings.password);
    let encryption_key = &settings.encryption_key;

    // 1. 下载并解析远程历史
    let (remote_records, decrypt_ok) =
        match webdav::download_and_parse_history(&client, encryption_key).await {
            Ok(r) => r,
            Err(e) => {
                return Ok(ApiSyncStatus::NetworkError {
                    message: e.to_string(),
                })
            }
        };

    if !decrypt_ok && !force_upload {
        return Ok(ApiSyncStatus::DecryptionFailed);
    }

    // 2. 合并远程记录到本地
    let mut merged_count = 0;
    for remote in &remote_records {
        storage::merge_history_record(
            &remote.video_id,
            &remote.title,
            &remote.cover_url,
            &remote.duration,
            remote.watch_progress,
            remote.total_duration,
            remote.watched_at,
            remote.deleted_at,
        )?;
        merged_count += 1;
    }

    // 4. 重新获取合并后的本地历史
    let final_records = storage::get_all_history_for_sync()?;
    let sync_records: Vec<webdav::SyncHistoryRecord> = final_records
        .into_iter()
        .map(|r| webdav::SyncHistoryRecord {
            video_id: r.video_id,
            title: r.title,
            cover_url: r.cover_url,
            duration: r.duration,
            watch_progress: r.watch_progress,
            total_duration: r.total_duration,
            watched_at: r.watched_at,
            deleted_at: r.deleted_at,
        })
        .collect();

    // 5. 上传到云端
    let new_filename = match webdav::upload_history(&client, &sync_records, encryption_key).await {
        Ok(f) => f,
        Err(e) => {
            return Ok(ApiSyncStatus::NetworkError {
                message: e.to_string(),
            })
        }
    };

    // 6. 清理旧文件
    let _ = webdav::cleanup_old_files(&client, &new_filename).await;

    Ok(ApiSyncStatus::Success {
        merged_count: merged_count as i32,
        uploaded: true,
    })
}

/// 强制上传本地历史到云端（覆盖）
#[frb]
pub async fn force_upload_history() -> anyhow::Result<ApiSyncStatus> {
    sync_history(true).await
}

/// 清理过期的已删除历史记录
#[frb]
pub async fn cleanup_expired_history() -> anyhow::Result<i64> {
    let count = storage::cleanup_expired_history()?;
    Ok(count as i64)
}

/// 获取上次同步时间
#[frb]
pub async fn get_last_sync_time() -> anyhow::Result<Option<i64>> {
    let time = storage::get_setting("last_sync_time")?;
    Ok(time.and_then(|t| t.parse().ok()))
}

/// 更新上次同步时间
#[frb]
pub async fn update_last_sync_time() -> anyhow::Result<bool> {
    let now = chrono::Utc::now().timestamp();
    storage::save_setting("last_sync_time", &now.to_string())?;
    Ok(true)
}

/// 检查是否需要自动同步
#[frb]
pub async fn should_auto_sync() -> anyhow::Result<bool> {
    let settings = get_webdav_settings().await?;

    // 未配置
    if settings.url.is_empty() {
        return Ok(false);
    }

    // 未启用自动同步
    if settings.auto_sync_interval <= 0 {
        return Ok(false);
    }

    // 检查上次同步时间
    let last_sync = get_last_sync_time().await?.unwrap_or(0);
    let now = chrono::Utc::now().timestamp();
    let interval_seconds = settings.auto_sync_interval as i64 * 60;

    Ok(now - last_sync >= interval_seconds)
}
