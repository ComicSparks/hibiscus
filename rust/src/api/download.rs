// 下载管理 API

use flutter_rust_bridge::frb;
use crate::frb_generated::StreamSink;
use crate::api::models::{ApiDownloadTask, ApiDownloadStatus};
use crate::core::{storage, network};
use std::path::PathBuf;
use std::sync::OnceLock;
use tokio::sync::broadcast;

/// 添加下载任务
#[frb]
pub async fn add_download(
    video_id: String,
    title: String,
    cover_url: String,
    quality: String,
    url: String,
) -> anyhow::Result<ApiDownloadTask> {
    if let Ok(Some(record)) = storage::get_download_by_video_id(&video_id) {
        let task = map_record(record.clone());
        if matches!(record.status, storage::DownloadStatus::Queued | storage::DownloadStatus::Failed | storage::DownloadStatus::Paused) {
            if let Some(save_path) = record.save_path.clone() {
                storage::update_download_status(&record.video_id, storage::DownloadStatus::Downloading, None)?;
                spawn_download(record.video_id, record.video_url, PathBuf::from(save_path));
            }
        }
        return Ok(task);
    }

    storage::add_download(&video_id, &title, &cover_url, &url, &quality)?;
    let save_path = build_download_path(&video_id, &quality, &url)?;
    storage::update_download_save_path(&video_id, save_path.to_string_lossy().as_ref())?;
    storage::update_download_status(&video_id, storage::DownloadStatus::Downloading, None)?;

    spawn_download(video_id.clone(), url.clone(), save_path);

    let task = ApiDownloadTask {
        id: video_id.clone(),
        video_id,
        title,
        cover_url,
        quality,
        status: ApiDownloadStatus::Downloading,
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
    let records = storage::get_downloads()?;
    Ok(records.into_iter().map(map_record).collect())
}

/// 获取指定状态的下载任务
#[frb]
pub async fn get_downloads_by_status(status: String) -> anyhow::Result<Vec<ApiDownloadTask>> {
    let records = storage::get_downloads()?;
    let filtered = records
        .into_iter()
        .filter(|task| match (task.status, status.as_str()) {
            (storage::DownloadStatus::Queued, "pending") => true,
            (storage::DownloadStatus::Downloading, "downloading") => true,
            (storage::DownloadStatus::Paused, "paused") => true,
            (storage::DownloadStatus::Completed, "completed") => true,
            (storage::DownloadStatus::Failed, "failed") => true,
            _ => false,
        })
        .map(map_record)
        .collect::<Vec<_>>();
    Ok(filtered)
}

/// 暂停下载
#[frb]
pub async fn pause_download(task_id: String) -> anyhow::Result<bool> {
    storage::update_download_status(&task_id, storage::DownloadStatus::Paused, None)?;
    Ok(true)
}

/// 继续下载
#[frb]
pub async fn resume_download(task_id: String) -> anyhow::Result<bool> {
    storage::update_download_status(&task_id, storage::DownloadStatus::Downloading, None)?;
    if let Ok(Some(record)) = storage::get_download_by_video_id(&task_id) {
        if let Some(save_path) = record.save_path.clone() {
            spawn_download(record.video_id, record.video_url, PathBuf::from(save_path));
        }
    }
    Ok(true)
}

/// 取消/删除下载
#[frb]
pub async fn delete_download(task_id: String, delete_file: bool) -> anyhow::Result<bool> {
    let _ = delete_file;
    storage::delete_download(&task_id)?;
    Ok(true)
}

/// 批量暂停下载
#[frb]
pub async fn pause_all_downloads() -> anyhow::Result<bool> {
    let records = storage::get_downloads()?;
    for record in records {
        if matches!(record.status, storage::DownloadStatus::Downloading | storage::DownloadStatus::Queued) {
            storage::update_download_status(&record.video_id, storage::DownloadStatus::Paused, None)?;
        }
    }
    Ok(true)
}

/// 批量继续下载
#[frb]
pub async fn resume_all_downloads() -> anyhow::Result<bool> {
    let records = storage::get_downloads()?;
    for record in records {
        if matches!(record.status, storage::DownloadStatus::Paused) {
            storage::update_download_status(&record.video_id, storage::DownloadStatus::Downloading, None)?;
        }
    }
    Ok(true)
}

/// 监听下载进度更新
#[frb]
pub fn subscribe_download_progress(sink: StreamSink<ApiDownloadTask>) {
    let mut rx = progress_sender().subscribe();
    tokio::spawn(async move {
        while let Ok(item) = rx.recv().await {
            let _ = sink.add(item);
        }
    });
}

/// 获取已下载视频的本地播放路径
#[frb]
pub async fn get_local_video_path(video_id: String) -> anyhow::Result<Option<String>> {
    let records = storage::get_downloads()?;
    let record = records.into_iter().find(|r| r.video_id == video_id);
    Ok(record.and_then(|r| r.save_path))
}

pub(crate) async fn resume_queued_downloads() -> anyhow::Result<()> {
    let records = storage::get_downloads()?;
    for record in records {
        if record.status != storage::DownloadStatus::Queued {
            continue;
        }

        let save_path = if let Some(path) = record.save_path.clone() {
            PathBuf::from(path)
        } else {
            let quality = record.quality.clone().unwrap_or_else(|| "1080P".to_string());
            let path = build_download_path(&record.video_id, &quality, &record.video_url)?;
            storage::update_download_save_path(&record.video_id, path.to_string_lossy().as_ref())?;
            path
        };

        storage::update_download_status(&record.video_id, storage::DownloadStatus::Downloading, None)?;
        spawn_download(record.video_id, record.video_url, save_path);
    }
    Ok(())
}

fn map_record(record: storage::DownloadRecord) -> ApiDownloadTask {
    let status = match record.status {
        storage::DownloadStatus::Queued => ApiDownloadStatus::Pending,
        storage::DownloadStatus::Downloading => ApiDownloadStatus::Downloading,
        storage::DownloadStatus::Paused => ApiDownloadStatus::Paused,
        storage::DownloadStatus::Completed => ApiDownloadStatus::Completed,
        storage::DownloadStatus::Failed => ApiDownloadStatus::Failed { error: record.error_message.unwrap_or_default() },
    };

    let progress = if record.total_bytes > 0 {
        record.downloaded_bytes as f32 / record.total_bytes as f32
    } else {
        0.0
    };

    ApiDownloadTask {
        id: record.video_id.clone(),
        video_id: record.video_id,
        title: record.title,
        cover_url: record.cover_url,
        quality: record.quality.unwrap_or_else(|| "1080P".to_string()),
        status,
        progress,
        downloaded_bytes: record.downloaded_bytes as u64,
        total_bytes: record.total_bytes as u64,
        speed: 0,
        created_at: record.created_at,
        file_path: record.save_path,
    }
}

fn build_download_path(video_id: &str, quality: &str, url: &str) -> anyhow::Result<PathBuf> {
    let mut base = storage::get_data_dir()?;
    base.push("downloads");
    std::fs::create_dir_all(&base)?;

    let ext = if url.contains(".m3u8") { "m3u8" } else { "mp4" };
    let file_name = format!("{}_{}.{}", video_id, quality.replace(' ', ""), ext);
    base.push(file_name);
    Ok(base)
}

fn spawn_download(video_id: String, url: String, save_path: PathBuf) {
    tokio::spawn(async move {
        let path_str = save_path.to_string_lossy().to_string();
        let result = network::download_file(&url, &path_str, |downloaded, total| {
            let _ = storage::update_download_progress(&video_id, downloaded as i64, total as i64);
            if let Ok(Some(record)) = storage::get_download_by_video_id(&video_id) {
                let task = map_record(record);
                let _ = progress_sender().send(task);
            }
        })
        .await;

        match result {
            Ok(_) => {
                let _ = storage::update_download_status(&video_id, storage::DownloadStatus::Completed, None);
                if let Ok(Some(record)) = storage::get_download_by_video_id(&video_id) {
                    let task = map_record(record);
                    let _ = progress_sender().send(task);
                }
            }
            Err(e) => {
                let _ = storage::update_download_status(&video_id, storage::DownloadStatus::Failed, Some(&e.to_string()));
                if let Ok(Some(record)) = storage::get_download_by_video_id(&video_id) {
                    let task = map_record(record);
                    let _ = progress_sender().send(task);
                }
            }
        }
    });
}

fn progress_sender() -> &'static broadcast::Sender<ApiDownloadTask> {
    static CHANNEL: OnceLock<broadcast::Sender<ApiDownloadTask>> = OnceLock::new();
    CHANNEL.get_or_init(|| {
        let (tx, _) = broadcast::channel(100);
        tx
    })
}
