// 下载管理 API

use flutter_rust_bridge::frb;
use crate::frb_generated::StreamSink;
use crate::api::models::{ApiDownloadTask, ApiDownloadStatus};

/// 添加下载任务
#[frb]
pub async fn add_download(
    video_id: String,
    title: String,
    cover_url: String,
    quality: String,
    url: String,
) -> anyhow::Result<ApiDownloadTask> {
    // TODO: 实现实际的下载添加逻辑
    let task = ApiDownloadTask {
        id: uuid::Uuid::new_v4().to_string(),
        video_id,
        title,
        cover_url,
        quality,
        status: ApiDownloadStatus::Pending,
        progress: 0.0,
        downloaded_bytes: 0,
        total_bytes: 0,
        speed: 0,
        created_at: chrono::Utc::now().timestamp(),
        file_path: None,
    };
    Ok(task)
}

/// 获取所有下载任务
#[frb]
pub async fn get_all_downloads() -> anyhow::Result<Vec<ApiDownloadTask>> {
    // TODO: 从数据库获取所有下载任务
    Ok(vec![])
}

/// 获取指定状态的下载任务
#[frb]
pub async fn get_downloads_by_status(status: String) -> anyhow::Result<Vec<ApiDownloadTask>> {
    // TODO: 从数据库获取指定状态的下载任务
    Ok(vec![])
}

/// 暂停下载
#[frb]
pub async fn pause_download(task_id: String) -> anyhow::Result<bool> {
    // TODO: 实现暂停逻辑
    Ok(true)
}

/// 继续下载
#[frb]
pub async fn resume_download(task_id: String) -> anyhow::Result<bool> {
    // TODO: 实现继续下载逻辑
    Ok(true)
}

/// 取消/删除下载
#[frb]
pub async fn delete_download(task_id: String, delete_file: bool) -> anyhow::Result<bool> {
    // TODO: 实现删除逻辑
    Ok(true)
}

/// 批量暂停下载
#[frb]
pub async fn pause_all_downloads() -> anyhow::Result<bool> {
    // TODO: 实现批量暂停
    Ok(true)
}

/// 批量继续下载
#[frb]
pub async fn resume_all_downloads() -> anyhow::Result<bool> {
    // TODO: 实现批量继续
    Ok(true)
}

/// 监听下载进度更新
#[frb]
pub fn subscribe_download_progress(sink: StreamSink<ApiDownloadTask>) {
    // TODO: 实现进度推送
    // 使用 FRB Stream 向 Flutter 推送下载进度更新
}

/// 获取已下载视频的本地播放路径
#[frb]
pub async fn get_local_video_path(video_id: String) -> anyhow::Result<Option<String>> {
    // TODO: 从数据库查询本地文件路径
    Ok(None)
}
