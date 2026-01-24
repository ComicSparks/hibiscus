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
fn get_db() -> Result<std::sync::MutexGuard<'static, Connection>> {
    DB.get()
        .ok_or_else(|| anyhow::anyhow!("Database not initialized"))?
        .lock()
        .map_err(|e| anyhow::anyhow!("Failed to lock database: {}", e))
}

// (schema handled by refinery migrations)

// ========== 历史记录 ==========

/// 历史记录项
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

    db.execute(
        r#"
        INSERT INTO history (video_id, title, cover_url, duration, watch_progress, total_duration, watched_at)
        VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)
        ON CONFLICT(video_id) DO UPDATE SET
            title = excluded.title,
            cover_url = excluded.cover_url,
            duration = excluded.duration,
            watch_progress = excluded.watch_progress,
            total_duration = excluded.total_duration,
            watched_at = excluded.watched_at
        "#,
        params![video_id, title, cover_url, duration, watch_progress, total_duration, now],
    )?;

    Ok(())
}

/// 获取历史记录列表
pub fn get_history(limit: i32, offset: i32) -> Result<Vec<HistoryRecord>> {
    let db = get_db()?;
    let mut stmt = db.prepare(
        "SELECT id, video_id, title, cover_url, duration, watch_progress, total_duration, watched_at 
         FROM history ORDER BY watched_at DESC LIMIT ?1 OFFSET ?2"
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
        })
    })?;

    let mut result = Vec::new();
    for record in records {
        result.push(record?);
    }

    Ok(result)
}

/// 获取历史记录总数
pub fn get_history_count() -> Result<i64> {
    let db = get_db()?;
    let mut stmt = db.prepare("SELECT COUNT(1) FROM history")?;
    let count: i64 = stmt.query_row([], |row| row.get(0))?;
    Ok(count)
}

/// 获取单条历史记录
pub fn get_history_by_video_id(video_id: &str) -> Result<Option<HistoryRecord>> {
    let db = get_db()?;
    let mut stmt = db.prepare(
        "SELECT id, video_id, title, cover_url, duration, watch_progress, total_duration, watched_at 
         FROM history WHERE video_id = ?1 LIMIT 1"
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
        }))
    } else {
        Ok(None)
    }
}

/// 删除历史记录
pub fn delete_history(video_id: &str) -> Result<()> {
    let db = get_db()?;
    db.execute("DELETE FROM history WHERE video_id = ?1", params![video_id])?;
    Ok(())
}

/// 清空历史记录
pub fn clear_history() -> Result<()> {
    let db = get_db()?;
    db.execute("DELETE FROM history", [])?;
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
    pub save_path: Option<String>,
    pub total_bytes: i64,
    pub downloaded_bytes: i64,
    pub status: DownloadStatus,
    pub error_message: Option<String>,
    pub created_at: i64,
    pub completed_at: Option<i64>,
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
pub fn get_download_by_video_id(video_id: &str) -> Result<Option<DownloadRecord>> {
    let db = get_db()?;
    let mut stmt = db.prepare(
        "SELECT id, video_id, title, cover_url, video_url, quality, description, tags, cover_path,
                author_id, author_name, author_avatar_url, author_avatar_path,
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
            save_path: row.get(13)?,
            total_bytes: row.get(14)?,
            downloaded_bytes: row.get(15)?,
            status: DownloadStatus::from(row.get::<_, i32>(16)?),
            error_message: row.get(17)?,
            created_at: row.get(18)?,
            completed_at: row.get(19)?,
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
pub fn update_download_status(
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
pub fn get_downloads() -> Result<Vec<DownloadRecord>> {
    let db = get_db()?;
    let mut stmt = db.prepare(
        "SELECT id, video_id, title, cover_url, video_url, quality, description, tags, cover_path,
        author_id, author_name, author_avatar_url, author_avatar_path,
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
            save_path: row.get(13)?,
            total_bytes: row.get(14)?,
            downloaded_bytes: row.get(15)?,
            status: DownloadStatus::from(row.get::<_, i32>(16)?),
            error_message: row.get(17)?,
            created_at: row.get(18)?,
            completed_at: row.get(19)?,
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
pub fn clear_cookies() -> Result<()> {
    let db = get_db()?;
    db.execute("DELETE FROM cookies", [])?;
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
