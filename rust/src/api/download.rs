// 下载管理 API

use flutter_rust_bridge::frb;
use crate::frb_generated::StreamSink;
use crate::api::models::{ApiDownloadTask, ApiDownloadStatus};
use crate::core::{storage, network, parser, runtime};
use std::path::PathBuf;
use std::sync::OnceLock;
use std::collections::HashMap;
use tokio::sync::broadcast;
use tokio::sync::{watch, Mutex};
use tokio::sync::Semaphore;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum DownloadControl {
    Running,
    Paused,
    Canceled,
}

fn task_controls() -> &'static Mutex<HashMap<String, watch::Sender<DownloadControl>>> {
    static MAP: OnceLock<Mutex<HashMap<String, watch::Sender<DownloadControl>>>> = OnceLock::new();
    MAP.get_or_init(|| Mutex::new(HashMap::new()))
}

fn download_semaphore() -> &'static Semaphore {
    static SEM: OnceLock<Semaphore> = OnceLock::new();
    SEM.get_or_init(|| {
        // 固定 2 个 permit，通过 acquire_many 实现 1/2 并发动态切换
        Semaphore::new(2)
    })
}

fn current_download_concurrency() -> u32 {
    storage::get_setting("download_concurrent")
        .ok()
        .flatten()
        .and_then(|v| v.parse::<u32>().ok())
        .unwrap_or(1)
        .clamp(1, 2)
}

/// 添加下载任务
#[frb]
pub async fn add_download(
    video_id: String,
    title: String,
    cover_url: String,
    quality: String,
    description: Option<String>,
    tags: Vec<String>,
) -> anyhow::Result<ApiDownloadTask> {
    if let Ok(Some(record)) = storage::get_download_by_video_id(&video_id) {
        if record.cover_path.is_none() && !record.cover_url.trim().is_empty() {
            if let Ok(Some(cover_path)) = download_cover(&record.video_id, &record.cover_url).await {
                let _ = storage::update_download_cover_path(&record.video_id, &cover_path);
            }
        }
        let record = storage::get_download_by_video_id(&video_id)?.unwrap_or(record);
        let task = map_record(record.clone());
        if matches!(record.status, storage::DownloadStatus::Queued | storage::DownloadStatus::Failed | storage::DownloadStatus::Paused) {
            if let Some(save_path) = record.save_path.clone() {
                storage::update_download_status(&record.video_id, storage::DownloadStatus::Queued, None)?;
                spawn_download(record.video_id, PathBuf::from(save_path));
            }
        }
        return Ok(task);
    }

    let watch_url = format!("{}/watch?v={}", network::BASE_URL, video_id);
    let cover_path = download_cover(&video_id, &cover_url).await.ok().flatten();
    storage::add_download(
        &video_id,
        &title,
        &cover_url,
        &watch_url,
        &quality,
        description.as_deref(),
        &tags,
        cover_path.as_deref(),
        None,
        None,
        None,
        None,
    )?;
    storage::update_download_status(&video_id, storage::DownloadStatus::Queued, None)?;

    spawn_download(video_id.clone(), PathBuf::new());

    let task = ApiDownloadTask {
        id: video_id.clone(),
        video_id,
        title,
        cover_url,
        cover_path,
        author_id: None,
        author_name: None,
        author_avatar_url: None,
        author_avatar_path: None,
        quality,
        description,
        tags,
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
    if let Some(tx) = task_controls().lock().await.get(&task_id).cloned() {
        let _ = tx.send(DownloadControl::Paused);
    }
    Ok(true)
}

/// 继续下载
#[frb]
pub async fn resume_download(task_id: String) -> anyhow::Result<bool> {
    storage::update_download_status(&task_id, storage::DownloadStatus::Queued, None)?;
    if let Ok(Some(record)) = storage::get_download_by_video_id(&task_id) {
        if let Some(save_path) = record.save_path.clone() {
            spawn_download(record.video_id, PathBuf::from(save_path));
        } else {
            spawn_download(record.video_id, PathBuf::new());
        }
    }
    Ok(true)
}

/// 取消/删除下载
#[frb]
pub async fn delete_download(task_id: String, delete_file: bool) -> anyhow::Result<bool> {
    if let Some(tx) = task_controls().lock().await.remove(&task_id) {
        let _ = tx.send(DownloadControl::Canceled);
    }
    if delete_file {
        if let Ok(Some(record)) = storage::get_download_by_video_id(&task_id) {
            if let Some(path) = record.save_path {
                let _ = std::fs::remove_file(path);
            }
            if let Some(path) = record.cover_path {
                let _ = std::fs::remove_file(path);
            }
            if let Some(path) = record.author_avatar_path {
                let _ = std::fs::remove_file(path);
            }
        }
    }
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
            if let Some(tx) = task_controls().lock().await.get(&record.video_id).cloned() {
                let _ = tx.send(DownloadControl::Paused);
            }
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
            storage::update_download_status(&record.video_id, storage::DownloadStatus::Queued, None)?;
            if let Some(save_path) = record.save_path.clone() {
                spawn_download(record.video_id, PathBuf::from(save_path));
            } else {
                spawn_download(record.video_id, PathBuf::new());
            }
        }
    }
    Ok(true)
}

/// 监听下载进度更新
#[frb]
pub fn subscribe_download_progress(sink: StreamSink<ApiDownloadTask>) {
    let mut rx = progress_sender().subscribe();
    std::thread::spawn(move || {
        if let Ok(records) = storage::get_downloads() {
            for record in records {
                let _ = sink.add(map_record(record));
            }
        }
        loop {
            match rx.blocking_recv() {
                Ok(item) => {
                    let _ = sink.add(item);
                }
                Err(broadcast::error::RecvError::Closed) => break,
                Err(broadcast::error::RecvError::Lagged(_)) => continue,
            }
        }
    });
}

/// 获取已下载视频的本地播放路径
#[frb]
pub async fn get_local_video_path(video_id: String) -> anyhow::Result<Option<String>> {
    let records = storage::get_downloads()?;
    let record = records.into_iter().find(|r| r.video_id == video_id);
    Ok(record.and_then(|r| {
        if r.status == storage::DownloadStatus::Completed { r.save_path } else { None }
    }))
}

pub(crate) async fn resume_queued_downloads() -> anyhow::Result<()> {
    let records = storage::get_downloads()?;
    for record in records {
        if record.status != storage::DownloadStatus::Queued {
            continue;
        }

        if let Some(path) = record.save_path.clone() {
            spawn_download(record.video_id, PathBuf::from(path));
        } else {
            spawn_download(record.video_id, PathBuf::new());
        }
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
        cover_path: record.cover_path,
        author_id: record.author_id,
        author_name: record.author_name,
        author_avatar_url: record.author_avatar_url,
        author_avatar_path: record.author_avatar_path,
        quality: record.quality.unwrap_or_else(|| "1080P".to_string()),
        description: record.description,
        tags: record.tags,
        status,
        progress,
        downloaded_bytes: record.downloaded_bytes as u64,
        total_bytes: record.total_bytes as u64,
        speed: 0,
        created_at: record.created_at,
        file_path: record.save_path,
    }
}

fn build_download_path(video_id: &str, quality: &str, ext: &str) -> anyhow::Result<PathBuf> {
    let mut base = storage::get_data_dir()?;
    base.push("downloads");
    std::fs::create_dir_all(&base)?;

    let file_name = format!("{}_{}.{}", video_id, quality.replace(' ', ""), ext);
    base.push(file_name);
    Ok(base)
}

async fn download_author_avatar(author_id: &str, avatar_url: &str) -> anyhow::Result<Option<String>> {
    if avatar_url.trim().is_empty() || author_id.trim().is_empty() {
        return Ok(None);
    }
    let mut dir = storage::get_data_dir()?;
    dir.push("download_avatars");
    std::fs::create_dir_all(&dir)?;

    let ext = {
        let cleaned = avatar_url
            .split(['?', '#'])
            .next()
            .unwrap_or(avatar_url)
            .trim();
        let ext = cleaned
            .rsplit_once('.')
            .map(|(_, e)| e.to_ascii_lowercase())
            .unwrap_or_else(|| "jpg".to_string());
        match ext.as_str() {
            "jpg" | "jpeg" | "png" | "webp" => ext,
            _ => "jpg".to_string(),
        }
    };
    let mut file_path = dir;
    file_path.push(format!("{}.{}", author_id, ext));

    let client = network::get_client();
    let bytes = client.get(avatar_url).send().await?.bytes().await?;
    tokio::fs::write(&file_path, &bytes).await?;
    Ok(Some(file_path.to_string_lossy().to_string()))
}

async fn download_cover(video_id: &str, cover_url: &str) -> anyhow::Result<Option<String>> {
    if cover_url.trim().is_empty() {
        return Ok(None);
    }
    let mut dir = storage::get_data_dir()?;
    dir.push("download_covers");
    std::fs::create_dir_all(&dir)?;

    let ext = {
        let cleaned = cover_url
            .split(['?', '#'])
            .next()
            .unwrap_or(cover_url)
            .trim();
        let ext = cleaned
            .rsplit_once('.')
            .map(|(_, e)| e.to_ascii_lowercase())
            .unwrap_or_else(|| "jpg".to_string());
        match ext.as_str() {
            "jpg" | "jpeg" | "png" | "webp" => ext,
            _ => "jpg".to_string(),
        }
    };
    let mut file_path = dir;
    file_path.push(format!("{}.{}", video_id, ext));

    let client = network::get_client();
    let bytes = client.get(cover_url).send().await?.bytes().await?;
    tokio::fs::write(&file_path, &bytes).await?;
    Ok(Some(file_path.to_string_lossy().to_string()))
}

fn spawn_download(video_id: String, save_path_hint: PathBuf) {
    runtime::spawn(async move {
        // 全局并发控制（最多同时下载不同视频）
        let permits_needed = if current_download_concurrency() <= 1 { 2 } else { 1 };
        let permit = match download_semaphore().acquire_many(permits_needed).await {
            Ok(p) => p,
            Err(_) => return,
        };

        let mut map = task_controls().lock().await;
        if map.contains_key(&video_id) {
            drop(permit);
            return;
        }
        let (tx, rx) = watch::channel(DownloadControl::Running);
        map.insert(video_id.clone(), tx);
        drop(map);

        let result = run_download(video_id.clone(), save_path_hint, rx).await;
        let _ = task_controls().lock().await.remove(&video_id);
        drop(permit);

        if let Ok(Some(record)) = storage::get_download_by_video_id(&video_id) {
            let task = map_record(record);
            let _ = progress_sender().send(task);
        }
        if let Err(e) = result {
            let _ = storage::update_download_status(&video_id, storage::DownloadStatus::Failed, Some(&e.to_string()));
            if let Ok(Some(record)) = storage::get_download_by_video_id(&video_id) {
                let task = map_record(record);
                let _ = progress_sender().send(task);
            }
        }
    });
}

async fn run_download(
    video_id: String,
    save_path_hint: PathBuf,
    mut ctrl_rx: watch::Receiver<DownloadControl>,
) -> anyhow::Result<()> {
    let Some(record) = storage::get_download_by_video_id(&video_id)? else {
        return Ok(());
    };

    // 如果在开始前已经被暂停（例如排队中立即点击暂停），则不要继续下载。
    if record.status == storage::DownloadStatus::Paused {
        return Ok(());
    }

    let quality = record.quality.clone().unwrap_or_else(|| "1080P".to_string());

    // 模拟播放：访问 watch 页获取链接 + 元数据
    let watch_url = format!("{}/watch?v={}", network::BASE_URL, video_id);
    let html = network::get(&watch_url).await?;
    let detail = parser::parse_video_detail(&html)?;

    if record.description.as_deref().unwrap_or("").trim().is_empty() && !detail.description.trim().is_empty() {
        let _ = storage::update_download_description_and_tags(&video_id, Some(detail.description.trim()), None);
    }
    if record.tags.is_empty() && !detail.tags.is_empty() {
        let _ = storage::update_download_description_and_tags(&video_id, None, Some(&detail.tags));
    }

    // 尝试补齐作者信息（用于离线展示）
    if let Some(creator) = detail.creator.clone() {
        let avatar_path = if record.author_avatar_path.is_none() {
            download_author_avatar(&creator.id, creator.avatar_url.as_deref().unwrap_or("")).await.ok().flatten()
        } else {
            record.author_avatar_path.clone()
        };
        let _ = storage::update_download_author(
            &video_id,
            Some(&creator.id),
            Some(&creator.name),
            creator.avatar_url.as_deref(),
            avatar_path.as_deref(),
        );
        if let Ok(Some(updated)) = storage::get_download_by_video_id(&video_id) {
            let _ = progress_sender().send(map_record(updated));
        }
    }

    let q_norm = quality.to_ascii_lowercase();
    let pick = detail.video_sources.iter().find(|s| s.quality.to_ascii_lowercase() == q_norm)
        .or_else(|| detail.video_sources.iter().find(|s| s.quality.to_ascii_lowercase() == "auto"))
        .or_else(|| detail.video_sources.first())
        .ok_or_else(|| anyhow::anyhow!("No playable source"))?;
    let url = pick.url.clone();
    let format = pick.format.clone();
    let ext = if format.to_ascii_lowercase().contains("m3u8") || url.contains(".m3u8") {
        "m3u8"
    } else {
        "mp4"
    };

    let save_path = if save_path_hint.as_os_str().is_empty() {
        let p = build_download_path(&video_id, &quality, ext)?;
        storage::update_download_save_path(&video_id, p.to_string_lossy().as_ref())?;
        p
    } else {
        save_path_hint
    };

    storage::update_download_status(&video_id, storage::DownloadStatus::Downloading, None)?;

    let mut downloaded: u64 = if save_path.exists() {
        std::fs::metadata(&save_path).map(|m| m.len()).unwrap_or(0)
    } else {
        0
    };

    // 如果数据库里记录的进度比文件大，信任文件
    let db_downloaded = record.downloaded_bytes.max(0) as u64;
    if db_downloaded > downloaded {
        downloaded = db_downloaded;
    }

    let client = network::get_client();
    let mut req = client.get(&url);
    if downloaded > 0 {
        req = req.header(reqwest::header::RANGE, format!("bytes={}-", downloaded));
    }
    let resp = req.send().await?;

    // range 可能不被支持，回退为重新下载
    let status = resp.status();
    if downloaded > 0 && status != reqwest::StatusCode::PARTIAL_CONTENT {
        downloaded = 0;
        let _ = tokio::fs::remove_file(&save_path).await;
    }

    let total_size = resp.content_length().unwrap_or(0);
    let total = if downloaded > 0 { downloaded + total_size } else { total_size };

    use tokio::io::AsyncWriteExt;
    let mut file = if downloaded > 0 {
        tokio::fs::OpenOptions::new().create(true).append(true).open(&save_path).await?
    } else {
        tokio::fs::File::create(&save_path).await?
    };

    let mut stream = resp.bytes_stream();
    use futures_util::StreamExt;

    loop {
        tokio::select! {
            changed = ctrl_rx.changed() => {
                let _ = changed;
                match *ctrl_rx.borrow() {
                    DownloadControl::Paused => {
                        storage::update_download_status(&video_id, storage::DownloadStatus::Paused, None)?;
                        return Ok(());
                    }
                    DownloadControl::Canceled => {
                        return Ok(());
                    }
                    DownloadControl::Running => {}
                }
            }
            chunk = stream.next() => {
                match chunk {
                    Some(Ok(bytes)) => {
                        file.write_all(&bytes).await?;
                        downloaded += bytes.len() as u64;
                        let _ = storage::update_download_progress(&video_id, downloaded as i64, total as i64);
                        if let Ok(Some(record)) = storage::get_download_by_video_id(&video_id) {
                            let task = map_record(record);
                            let _ = progress_sender().send(task);
                        }
                    }
                    Some(Err(e)) => return Err(e.into()),
                    None => break,
                }
            }
        }
    }

    file.flush().await?;
    storage::update_download_status(&video_id, storage::DownloadStatus::Completed, None)?;
    Ok(())
}

fn progress_sender() -> &'static broadcast::Sender<ApiDownloadTask> {
    static CHANNEL: OnceLock<broadcast::Sender<ApiDownloadTask>> = OnceLock::new();
    CHANNEL.get_or_init(|| {
        let (tx, _) = broadcast::channel(100);
        tx
    })
}
