// 本地存储模块 (SQLite)

use anyhow::Result;
use refinery::embed_migrations;
use rusqlite::{params, Connection};
use std::path::PathBuf;
use std::sync::Mutex;
use std::sync::OnceLock;

embed_migrations!("migrations");

/// 数据库连接
static DB: OnceLock<Mutex<Connection>> = OnceLock::new();
static DATA_DIR: OnceLock<PathBuf> = OnceLock::new();

/// 获取数据库路径
fn get_db_path() -> PathBuf {
    // TODO: 从 Flutter 传入应用数据目录
    let home = std::env::var("HOME").unwrap_or_else(|_| ".".to_string());
    PathBuf::from(home).join(".hibiscus").join("data.db")
}

/// 初始化数据库
pub fn init_db(db_path: Option<&str>) -> Result<()> {
    let path = db_path.map(PathBuf::from).unwrap_or_else(get_db_path);

    // 确保目录存在
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent)?;
        let _ = DATA_DIR.set(parent.to_path_buf());
    }

    let mut conn = Connection::open(&path)?;

    migrations::runner().run(&mut conn)?;
    DB.get_or_init(|| Mutex::new(conn));

    Ok(())
}

/// 获取应用数据目录
pub fn get_data_dir() -> Result<PathBuf> {
    DATA_DIR
        .get()
        .cloned()
        .ok_or_else(|| anyhow::anyhow!("Data dir not initialized"))
}

/// 获取数据库连接
pub fn get_db() -> Result<std::sync::MutexGuard<'static, Connection>> {
    DB.get()
        .ok_or_else(|| anyhow::anyhow!("Database not initialized"))?
        .lock()
        .map_err(|e| anyhow::anyhow!("Failed to lock database: {}", e))
}

/// VACUUM 数据库（压缩回收空间）
pub fn vacuum() -> Result<()> {
    let db = get_db()?;
    db.execute("VACUUM", [])?;
    tracing::info!("Database vacuumed");
    Ok(())
}

// (schema handled by refinery migrations)

// ========== 历史记录 ==========
// 逻辑删除：
// - deleted_at 为 NULL：未删除
// - deleted_at < watched_at：删除后又观看过（视为未删除）
// - deleted_at >= watched_at：已删除

/// 历史记录项
#[allow(dead_code)]
#[derive(Debug, Clone)]
pub(crate) struct HistoryRecord {
    pub id: i64,
    pub video_id: String,
    pub title: String,
    pub cover_url: String,
    pub duration: String,
    pub watch_progress: i32,
    pub total_duration: i32,
    pub watched_at: i64,
    pub deleted_at: Option<i64>,
}

impl HistoryRecord {
    /// 判断记录是否已删除
    #[allow(dead_code)]
    pub fn is_deleted(&self) -> bool {
        match self.deleted_at {
            None => false,
            Some(deleted) => deleted >= self.watched_at,
        }
    }
}

/// 添加/更新历史记录
pub fn upsert_history(
    video_id: &str,
    title: &str,
    cover_url: &str,
    duration: &str,
    watch_progress: i32,
    total_duration: i32,
) -> Result<()> {
    let db = get_db()?;
    let now = chrono::Utc::now().timestamp();

    // 插入或更新，同时清除删除标记（因为用户观看了）
    db.execute(
        r#"
        INSERT INTO history (video_id, title, cover_url, duration, watch_progress, total_duration, watched_at, deleted_at)
        VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, NULL)
        ON CONFLICT(video_id) DO UPDATE SET
            title = excluded.title,
            cover_url = excluded.cover_url,
            duration = excluded.duration,
            watch_progress = excluded.watch_progress,
            total_duration = excluded.total_duration,
            watched_at = excluded.watched_at,
            deleted_at = NULL
        "#,
        params![video_id, title, cover_url, duration, watch_progress, total_duration, now],
    )?;

    Ok(())
}

/// 获取历史记录列表（不包含已删除的）
pub(crate) fn get_history(limit: i32, offset: i32) -> Result<Vec<HistoryRecord>> {
    let db = get_db()?;
    let mut stmt = db.prepare(
        "SELECT id, video_id, title, cover_url, duration, watch_progress, total_duration, watched_at, deleted_at 
         FROM history 
         WHERE deleted_at IS NULL OR deleted_at < watched_at
         ORDER BY watched_at DESC LIMIT ?1 OFFSET ?2"
    )?;

    let records = stmt.query_map(params![limit, offset], |row| {
        Ok(HistoryRecord {
            id: row.get(0)?,
            video_id: row.get(1)?,
            title: row.get(2)?,
            cover_url: row.get(3)?,
            duration: row.get(4)?,
            watch_progress: row.get(5)?,
            total_duration: row.get(6)?,
            watched_at: row.get(7)?,
            deleted_at: row.get(8)?,
        })
    })?;

    let mut result = Vec::new();
    for record in records {
        result.push(record?);
    }

    Ok(result)
}

/// 获取所有历史记录（包含已删除的，用于同步）
pub(crate) fn get_all_history_for_sync() -> Result<Vec<HistoryRecord>> {
    let db = get_db()?;
    let mut stmt = db.prepare(
        "SELECT id, video_id, title, cover_url, duration, watch_progress, total_duration, watched_at, deleted_at 
         FROM history ORDER BY watched_at DESC"
    )?;

    let records = stmt.query_map([], |row| {
        Ok(HistoryRecord {
            id: row.get(0)?,
            video_id: row.get(1)?,
            title: row.get(2)?,
            cover_url: row.get(3)?,
            duration: row.get(4)?,
            watch_progress: row.get(5)?,
            total_duration: row.get(6)?,
            watched_at: row.get(7)?,
            deleted_at: row.get(8)?,
        })
    })?;

    let mut result = Vec::new();
    for record in records {
        result.push(record?);
    }

    Ok(result)
}

/// 获取历史记录总数（不包含已删除的）
pub(crate) fn get_history_count() -> Result<i64> {
    let db = get_db()?;
    let mut stmt = db.prepare(
        "SELECT COUNT(1) FROM history WHERE deleted_at IS NULL OR deleted_at < watched_at",
    )?;
    let count: i64 = stmt.query_row([], |row| row.get(0))?;
    Ok(count)
}

/// 获取单条历史记录（不包含已删除的）
pub(crate) fn get_history_by_video_id(video_id: &str) -> Result<Option<HistoryRecord>> {
    let db = get_db()?;
    let mut stmt = db.prepare(
        "SELECT id, video_id, title, cover_url, duration, watch_progress, total_duration, watched_at, deleted_at 
         FROM history WHERE video_id = ?1 AND (deleted_at IS NULL OR deleted_at < watched_at) LIMIT 1"
    )?;

    let mut rows = stmt.query(params![video_id])?;
    if let Some(row) = rows.next()? {
        Ok(Some(HistoryRecord {
            id: row.get(0)?,
            video_id: row.get(1)?,
            title: row.get(2)?,
            cover_url: row.get(3)?,
            duration: row.get(4)?,
            watch_progress: row.get(5)?,
            total_duration: row.get(6)?,
            watched_at: row.get(7)?,
            deleted_at: row.get(8)?,
        }))
    } else {
        Ok(None)
    }
}

/// 逻辑删除历史记录
pub fn delete_history(video_id: &str) -> Result<()> {
    let db = get_db()?;
    let now = chrono::Utc::now().timestamp();
    db.execute(
        "UPDATE history SET deleted_at = ?1 WHERE video_id = ?2",
        params![now, video_id],
    )?;
    Ok(())
}

/// 逻辑清空历史记录（标记所有记录为已删除）
pub fn clear_history() -> Result<()> {
    let db = get_db()?;
    let now = chrono::Utc::now().timestamp();
    db.execute("UPDATE history SET deleted_at = ?1", params![now])?;
    Ok(())
}

/// 清理过期的已删除记录（保留1个月内的）
pub fn cleanup_expired_history() -> Result<u64> {
    let db = get_db()?;
    let one_month_ago = chrono::Utc::now().timestamp() - 30 * 24 * 60 * 60;

    // 删除已逻辑删除超过1个月的记录
    let deleted = db.execute(
        "DELETE FROM history WHERE deleted_at IS NOT NULL AND deleted_at >= watched_at AND deleted_at < ?1",
        params![one_month_ago],
    )?;

    if deleted > 0 {
        tracing::info!("Cleaned up {} expired history records", deleted);
    }

    Ok(deleted as u64)
}

/// 合并同步的历史记录（用于 WebDAV 同步）
/// 规则：
/// - 浏览进度以 watched_at 最大的为准
/// - watched_at 和 deleted_at 都取最大值
pub fn merge_history_record(
    video_id: &str,
    title: &str,
    cover_url: &str,
    duration: &str,
    watch_progress: i32,
    total_duration: i32,
    watched_at: i64,
    deleted_at: Option<i64>,
) -> Result<()> {
    let db = get_db()?;

    // 先查询现有记录
    let mut stmt = db.prepare(
        "SELECT watched_at, deleted_at, watch_progress, total_duration FROM history WHERE video_id = ?1"
    )?;
    let mut rows = stmt.query(params![video_id])?;

    if let Some(row) = rows.next()? {
        let local_watched_at: i64 = row.get(0)?;
        let local_deleted_at: Option<i64> = row.get(1)?;
        let local_watch_progress: i32 = row.get(2)?;
        let local_total_duration: i32 = row.get(3)?;
        drop(rows);
        drop(stmt);

        // 合并逻辑
        let final_watched_at = local_watched_at.max(watched_at);
        let final_deleted_at = match (local_deleted_at, deleted_at) {
            (Some(a), Some(b)) => Some(a.max(b)),
            (Some(a), None) => Some(a),
            (None, Some(b)) => Some(b),
            (None, None) => None,
        };

        // 浏览进度以 watched_at 最大的为准
        let (final_progress, final_total_duration) = if watched_at > local_watched_at {
            (watch_progress, total_duration)
        } else {
            (local_watch_progress, local_total_duration)
        };

        db.execute(
            "UPDATE history SET title = ?1, cover_url = ?2, duration = ?3, 
             watch_progress = ?4, total_duration = ?5, watched_at = ?6, deleted_at = ?7 
             WHERE video_id = ?8",
            params![
                title,
                cover_url,
                duration,
                final_progress,
                final_total_duration,
                final_watched_at,
                final_deleted_at,
                video_id
            ],
        )?;
    } else {
        drop(rows);
        drop(stmt);
        // 插入新记录
        db.execute(
            "INSERT INTO history (video_id, title, cover_url, duration, watch_progress, total_duration, watched_at, deleted_at)
             VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)",
            params![video_id, title, cover_url, duration, watch_progress, total_duration, watched_at, deleted_at],
        )?;
    }

    Ok(())
}

// ========== 下载任务 ==========

/// 下载任务状态（内部使用，持久化）
#[repr(i32)]
#[derive(Debug, Clone, Copy, PartialEq)]
pub(crate) enum DownloadStatus {
    Queued = 0,
    Downloading = 1,
    Paused = 2,
    Completed = 3,
    Failed = 4,
}

impl From<i32> for DownloadStatus {
    fn from(v: i32) -> Self {
        match v {
            0 => DownloadStatus::Queued,
            1 => DownloadStatus::Downloading,
            2 => DownloadStatus::Paused,
            3 => DownloadStatus::Completed,
            4 => DownloadStatus::Failed,
            _ => DownloadStatus::Queued,
        }
    }
}

/// 下载记录（内部使用）
#[allow(dead_code)]
#[derive(Debug, Clone)]
pub(crate) struct DownloadRecord {
    pub id: i64,
    pub video_id: String,
    pub title: String,
    pub cover_url: String,
    pub video_url: String,
    pub quality: Option<String>,
    pub description: Option<String>,
    pub tags: Vec<String>,
    pub cover_path: Option<String>,
    pub author_id: Option<String>,
    pub author_name: Option<String>,
    pub author_avatar_url: Option<String>,
    pub author_avatar_path: Option<String>,
    pub folder_id: Option<String>,
    pub save_path: Option<String>,
    pub total_bytes: i64,
    pub downloaded_bytes: i64,
    pub status: DownloadStatus,
    pub error_message: Option<String>,
    pub created_at: i64,
    pub completed_at: Option<i64>,
}

/// 下载文件夹记录（内部使用）
#[allow(dead_code)]
#[derive(Debug, Clone)]
pub(crate) struct DownloadFolderRecord {
    pub id: String,
    pub name: String,
    pub created_at: i64,
}

/// 添加下载任务
pub fn add_download(
    video_id: &str,
    title: &str,
    cover_url: &str,
    video_url: &str,
    quality: &str,
    description: Option<&str>,
    tags: &[String],
    cover_path: Option<&str>,
    author_id: Option<&str>,
    author_name: Option<&str>,
    author_avatar_url: Option<&str>,
    author_avatar_path: Option<&str>,
) -> Result<i64> {
    let db = get_db()?;
    let now = chrono::Utc::now().timestamp();
    let tags_json = serde_json::to_string(tags).unwrap_or_else(|_| "[]".to_string());

    db.execute(
        r#"
        INSERT OR IGNORE INTO downloads (
            video_id, title, cover_url, video_url, quality, description, tags, cover_path,
            author_id, author_name, author_avatar_url, author_avatar_path,
            created_at
        )
        VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13)
        "#,
        params![
            video_id,
            title,
            cover_url,
            video_url,
            quality,
            description,
            tags_json,
            cover_path,
            author_id,
            author_name,
            author_avatar_url,
            author_avatar_path,
            now
        ],
    )?;

    Ok(db.last_insert_rowid())
}

/// 获取单个下载任务（按 video_id）
pub(crate) fn get_download_by_video_id(video_id: &str) -> Result<Option<DownloadRecord>> {
    let db = get_db()?;
    let mut stmt = db.prepare(
        "SELECT id, video_id, title, cover_url, video_url, quality, description, tags, cover_path,
                author_id, author_name, author_avatar_url, author_avatar_path, folder_id,
                save_path, total_bytes, downloaded_bytes, status, error_message, created_at, completed_at
         FROM downloads WHERE video_id = ?1 LIMIT 1"
    )?;

    let mut rows = stmt.query(params![video_id])?;
    if let Some(row) = rows.next()? {
        let tags_json: Option<String> = row.get(7)?;
        let tags = tags_json
            .as_deref()
            .and_then(|s| serde_json::from_str::<Vec<String>>(s).ok())
            .unwrap_or_default();
        Ok(Some(DownloadRecord {
            id: row.get(0)?,
            video_id: row.get(1)?,
            title: row.get(2)?,
            cover_url: row.get(3)?,
            video_url: row.get(4)?,
            quality: row.get(5)?,
            description: row.get(6)?,
            tags,
            cover_path: row.get(8)?,
            author_id: row.get(9)?,
            author_name: row.get(10)?,
            author_avatar_url: row.get(11)?,
            author_avatar_path: row.get(12)?,
            folder_id: row.get(13)?,
            save_path: row.get(14)?,
            total_bytes: row.get(15)?,
            downloaded_bytes: row.get(16)?,
            status: DownloadStatus::from(row.get::<_, i32>(17)?),
            error_message: row.get(18)?,
            created_at: row.get(19)?,
            completed_at: row.get(20)?,
        }))
    } else {
        Ok(None)
    }
}

/// 更新下载保存路径
pub fn update_download_save_path(video_id: &str, save_path: &str) -> Result<()> {
    let db = get_db()?;
    db.execute(
        "UPDATE downloads SET save_path = ?1 WHERE video_id = ?2",
        params![save_path, video_id],
    )?;
    Ok(())
}

/// 更新下载封面本地路径
pub fn update_download_cover_path(video_id: &str, cover_path: &str) -> Result<()> {
    let db = get_db()?;
    db.execute(
        "UPDATE downloads SET cover_path = ?1 WHERE video_id = ?2",
        params![cover_path, video_id],
    )?;
    Ok(())
}

/// 更新下载作者信息
pub fn update_download_author(
    video_id: &str,
    author_id: Option<&str>,
    author_name: Option<&str>,
    author_avatar_url: Option<&str>,
    author_avatar_path: Option<&str>,
) -> Result<()> {
    let db = get_db()?;
    db.execute(
        "UPDATE downloads SET author_id = ?1, author_name = ?2, author_avatar_url = ?3, author_avatar_path = ?4 WHERE video_id = ?5",
        params![author_id, author_name, author_avatar_url, author_avatar_path, video_id],
    )?;
    Ok(())
}

/// 更新下载进度
pub fn update_download_progress(video_id: &str, downloaded: i64, total: i64) -> Result<()> {
    let db = get_db()?;
    db.execute(
        "UPDATE downloads SET downloaded_bytes = ?1, total_bytes = ?2, status = ?3 WHERE video_id = ?4",
        params![downloaded, total, DownloadStatus::Downloading as i32, video_id],
    )?;
    Ok(())
}

/// 更新下载状态
pub(crate) fn update_download_status(
    video_id: &str,
    status: DownloadStatus,
    error: Option<&str>,
) -> Result<()> {
    let db = get_db()?;
    let completed_at = if status == DownloadStatus::Completed {
        Some(chrono::Utc::now().timestamp())
    } else {
        None
    };

    db.execute(
        "UPDATE downloads SET status = ?1, error_message = ?2, completed_at = ?3 WHERE video_id = ?4",
        params![status as i32, error, completed_at, video_id],
    )?;
    Ok(())
}

pub fn update_download_description_and_tags(
    video_id: &str,
    description: Option<&str>,
    tags: Option<&[String]>,
) -> Result<()> {
    let db = get_db()?;
    let tags_json = tags.map(|t| serde_json::to_string(t).unwrap_or_else(|_| "[]".to_string()));
    db.execute(
        "UPDATE downloads SET description = COALESCE(?1, description), tags = COALESCE(?2, tags) WHERE video_id = ?3",
        params![description, tags_json, video_id],
    )?;
    Ok(())
}

/// 获取下载列表
pub(crate) fn get_downloads() -> Result<Vec<DownloadRecord>> {
    let db = get_db()?;
    let mut stmt = db.prepare(
        "SELECT id, video_id, title, cover_url, video_url, quality, description, tags, cover_path,
        author_id, author_name, author_avatar_url, author_avatar_path, folder_id,
        save_path, total_bytes, downloaded_bytes, status, error_message, created_at, completed_at
         FROM downloads ORDER BY created_at DESC",
    )?;

    let records = stmt.query_map([], |row| {
        let tags_json: Option<String> = row.get(7)?;
        let tags = tags_json
            .as_deref()
            .and_then(|s| serde_json::from_str::<Vec<String>>(s).ok())
            .unwrap_or_default();
        Ok(DownloadRecord {
            id: row.get(0)?,
            video_id: row.get(1)?,
            title: row.get(2)?,
            cover_url: row.get(3)?,
            video_url: row.get(4)?,
            quality: row.get(5)?,
            description: row.get(6)?,
            tags,
            cover_path: row.get(8)?,
            author_id: row.get(9)?,
            author_name: row.get(10)?,
            author_avatar_url: row.get(11)?,
            author_avatar_path: row.get(12)?,
            folder_id: row.get(13)?,
            save_path: row.get(14)?,
            total_bytes: row.get(15)?,
            downloaded_bytes: row.get(16)?,
            status: DownloadStatus::from(row.get::<_, i32>(17)?),
            error_message: row.get(18)?,
            created_at: row.get(19)?,
            completed_at: row.get(20)?,
        })
    })?;

    let mut result = Vec::new();
    for record in records {
        result.push(record?);
    }

    Ok(result)
}

/// 应用启动时修正状态（崩溃恢复）
pub fn reset_running_downloads() -> Result<()> {
    let db = get_db()?;
    db.execute(
        "UPDATE downloads SET status = ?1 WHERE status = ?2",
        params![
            DownloadStatus::Queued as i32,
            DownloadStatus::Downloading as i32
        ],
    )?;
    Ok(())
}

/// 删除下载任务
pub fn delete_download(video_id: &str) -> Result<()> {
    let db = get_db()?;
    db.execute(
        "DELETE FROM downloads WHERE video_id = ?1",
        params![video_id],
    )?;
    Ok(())
}

/// 更新下载的文件夹ID
pub fn update_download_folder(video_id: &str, folder_id: Option<&str>) -> Result<()> {
    let db = get_db()?;
    db.execute(
        "UPDATE downloads SET folder_id = ?1 WHERE video_id = ?2",
        params![folder_id, video_id],
    )?;
    Ok(())
}

/// 批量更新下载的文件夹ID
pub fn update_downloads_folder(video_ids: &[String], folder_id: Option<&str>) -> Result<()> {
    let db = get_db()?;
    for video_id in video_ids {
        db.execute(
            "UPDATE downloads SET folder_id = ?1 WHERE video_id = ?2",
            params![folder_id, video_id],
        )?;
    }
    Ok(())
}

// ========== 下载文件夹 ==========

/// 创建下载文件夹
pub fn create_download_folder(id: &str, name: &str) -> Result<()> {
    let db = get_db()?;
    let now = chrono::Utc::now().timestamp();
    db.execute(
        "INSERT INTO download_folders (id, name, created_at) VALUES (?1, ?2, ?3)",
        params![id, name, now],
    )?;
    Ok(())
}

/// 获取所有下载文件夹
pub(crate) fn get_download_folders() -> Result<Vec<DownloadFolderRecord>> {
    let db = get_db()?;
    let mut stmt =
        db.prepare("SELECT id, name, created_at FROM download_folders ORDER BY created_at ASC")?;

    let records = stmt.query_map([], |row| {
        Ok(DownloadFolderRecord {
            id: row.get(0)?,
            name: row.get(1)?,
            created_at: row.get(2)?,
        })
    })?;

    let mut result = Vec::new();
    for record in records {
        result.push(record?);
    }

    Ok(result)
}

/// 更新下载文件夹名称
pub fn update_download_folder_name(id: &str, name: &str) -> Result<()> {
    let db = get_db()?;
    db.execute(
        "UPDATE download_folders SET name = ?1 WHERE id = ?2",
        params![name, id],
    )?;
    Ok(())
}

/// 删除下载文件夹（不影响视频，仅清除视频的 folder_id）
pub fn delete_download_folder(id: &str) -> Result<()> {
    let db = get_db()?;
    // 先清除所有关联视频的 folder_id
    db.execute(
        "UPDATE downloads SET folder_id = NULL WHERE folder_id = ?1",
        params![id],
    )?;
    // 再删除文件夹
    db.execute("DELETE FROM download_folders WHERE id = ?1", params![id])?;
    Ok(())
}

// ========== 设置 ==========

/// 保存设置
pub fn save_setting(key: &str, value: &str) -> Result<()> {
    let db = get_db()?;
    db.execute(
        "INSERT OR REPLACE INTO settings (key, value) VALUES (?1, ?2)",
        params![key, value],
    )?;
    Ok(())
}

/// 获取设置
pub fn get_setting(key: &str) -> Result<Option<String>> {
    let db = get_db()?;
    let mut stmt = db.prepare("SELECT value FROM settings WHERE key = ?1")?;
    let mut rows = stmt.query(params![key])?;

    if let Some(row) = rows.next()? {
        Ok(Some(row.get(0)?))
    } else {
        Ok(None)
    }
}

/// 删除设置
pub fn delete_setting(key: &str) -> Result<()> {
    let db = get_db()?;
    db.execute("DELETE FROM settings WHERE key = ?1", params![key])?;
    Ok(())
}

// ========== Telemetry Queue (OTLP) ==========

#[derive(Debug, Clone)]
pub(crate) struct TelemetryRecord {
    pub id: i64,
    pub payload_base64: String,
    pub _retry_count: i32,
}

pub(crate) fn enqueue_telemetry(payload_base64: &str) -> Result<()> {
    let db = get_db()?;
    let now = chrono::Utc::now().timestamp();
    db.execute(
        "INSERT INTO telemetry_queue (payload_base64, retry_count, created_at) VALUES (?1, 0, ?2)",
        params![payload_base64, now],
    )?;
    Ok(())
}

pub(crate) fn dequeue_telemetry_batch(limit: u32) -> Result<Vec<TelemetryRecord>> {
    let db = get_db()?;
    let mut stmt = db.prepare(
        "SELECT id, payload_base64, retry_count
         FROM telemetry_queue
         ORDER BY created_at ASC
         LIMIT ?1",
    )?;
    let rows = stmt.query_map(params![limit], |row| {
        Ok(TelemetryRecord {
            id: row.get(0)?,
            payload_base64: row.get(1)?,
            _retry_count: row.get(2)?,
        })
    })?;
    let mut out = Vec::new();
    for r in rows {
        out.push(r?);
    }
    Ok(out)
}

pub(crate) fn delete_telemetry_by_ids(ids: &[i64]) -> Result<()> {
    if ids.is_empty() {
        return Ok(());
    }
    let db = get_db()?;
    let mut sql = String::from("DELETE FROM telemetry_queue WHERE id IN (");
    for (i, _) in ids.iter().enumerate() {
        if i > 0 {
            sql.push(',');
        }
        sql.push('?');
        sql.push_str(&(i + 1).to_string());
    }
    sql.push(')');
    let params = rusqlite::params_from_iter(ids.iter());
    db.execute(&sql, params)?;
    Ok(())
}

pub(crate) fn increment_telemetry_retry_count(ids: &[i64]) -> Result<()> {
    if ids.is_empty() {
        return Ok(());
    }
    let db = get_db()?;
    let mut sql =
        String::from("UPDATE telemetry_queue SET retry_count = retry_count + 1 WHERE id IN (");
    for (i, _) in ids.iter().enumerate() {
        if i > 0 {
            sql.push(',');
        }
        sql.push('?');
        sql.push_str(&(i + 1).to_string());
    }
    sql.push(')');
    let params = rusqlite::params_from_iter(ids.iter());
    db.execute(&sql, params)?;
    Ok(())
}

pub(crate) fn delete_telemetry_exceeded_retry(max_retry: i32) -> Result<usize> {
    let db = get_db()?;
    Ok(db.execute(
        "DELETE FROM telemetry_queue WHERE retry_count > ?1",
        params![max_retry],
    )?)
}

pub(crate) fn telemetry_count() -> Result<i64> {
    let db = get_db()?;
    let mut stmt = db.prepare("SELECT COUNT(1) FROM telemetry_queue")?;
    Ok(stmt.query_row([], |row| row.get(0))?)
}

pub(crate) fn cleanup_telemetry_keep_latest(max_records: i64) -> Result<usize> {
    if max_records <= 0 {
        return Ok(0);
    }
    let db = get_db()?;
    Ok(db.execute(
        r#"
        DELETE FROM telemetry_queue
        WHERE id IN (
          SELECT id FROM telemetry_queue
          ORDER BY created_at DESC
          LIMIT -1 OFFSET ?1
        )
        "#,
        params![max_records],
    )?)
}

// ========== Cookies ==========

/// 保存 Cookie
pub fn save_cookie(
    domain: &str,
    name: &str,
    value: &str,
    path: &str,
    expires: Option<i64>,
) -> Result<()> {
    let db = get_db()?;
    db.execute(
        "INSERT OR REPLACE INTO cookies (domain, name, value, path, expires) VALUES (?1, ?2, ?3, ?4, ?5)",
        params![domain, name, value, path, expires],
    )?;
    Ok(())
}

/// 获取域名的所有 Cookies
pub fn get_cookies(domain: &str) -> Result<Vec<(String, String)>> {
    let db = get_db()?;
    let now = chrono::Utc::now().timestamp();

    let mut stmt = db.prepare(
        "SELECT name, value FROM cookies WHERE domain = ?1 AND (expires IS NULL OR expires > ?2)",
    )?;

    let cookies = stmt.query_map(params![domain, now], |row| {
        Ok((row.get::<_, String>(0)?, row.get::<_, String>(1)?))
    })?;

    let mut result = Vec::new();
    for cookie in cookies {
        result.push(cookie?);
    }

    Ok(result)
}

/// 清除所有 Cookies
pub fn clear_cookies(domain: Option<&str>) -> Result<()> {
    let db = get_db()?;
    if let Some(domain) = domain {
        db.execute("DELETE FROM cookies WHERE domain = ?1", params![domain])?;
    } else {
        db.execute("DELETE FROM cookies", [])?;
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_init_db() {
        let temp_dir = std::env::temp_dir();
        let db_path = temp_dir.join("test_hibiscus.db");

        // 清理旧文件
        let _ = std::fs::remove_file(&db_path);

        // 初始化
        init_db(Some(db_path.to_str().unwrap())).unwrap();

        // 测试历史记录
        upsert_history(
            "video1",
            "Test Video",
            "http://example.com/cover.jpg",
            "10:00",
            300,
            600,
        )
        .unwrap();
        let history = get_history(10, 0).unwrap();
        assert_eq!(history.len(), 1);
        assert_eq!(history[0].video_id, "video1");

        // 清理
        let _ = std::fs::remove_file(&db_path);
    }
}
