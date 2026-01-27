// 下载文件夹管理 API
// 文件夹仅用于过滤分类，删除文件夹不影响已下载的视频

use crate::api::models::ApiDownloadFolder;
use crate::core::storage;
use flutter_rust_bridge::frb;
use uuid::Uuid;

/// 获取所有下载文件夹
#[frb]
pub async fn get_download_folders() -> anyhow::Result<Vec<ApiDownloadFolder>> {
    let records = storage::get_download_folders()?;
    Ok(records
        .into_iter()
        .map(|r| ApiDownloadFolder {
            id: r.id,
            name: r.name,
            created_at: r.created_at,
        })
        .collect())
}

/// 创建下载文件夹
#[frb]
pub async fn create_download_folder(name: String) -> anyhow::Result<ApiDownloadFolder> {
    let id = Uuid::new_v4().to_string();
    let now = chrono::Utc::now().timestamp();
    storage::create_download_folder(&id, &name)?;
    Ok(ApiDownloadFolder {
        id,
        name,
        created_at: now,
    })
}

/// 重命名下载文件夹
#[frb]
pub async fn rename_download_folder(folder_id: String, name: String) -> anyhow::Result<bool> {
    storage::update_download_folder_name(&folder_id, &name)?;
    Ok(true)
}

/// 删除下载文件夹（视频不会被删除，仅清除视频的文件夹关联）
#[frb]
pub async fn delete_download_folder(folder_id: String) -> anyhow::Result<bool> {
    storage::delete_download_folder(&folder_id)?;
    Ok(true)
}

/// 将视频移动到文件夹
#[frb]
pub async fn move_downloads_to_folder(
    video_ids: Vec<String>,
    folder_id: Option<String>,
) -> anyhow::Result<bool> {
    storage::update_downloads_folder(&video_ids, folder_id.as_deref())?;
    Ok(true)
}
