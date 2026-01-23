// 本地存储模块 (SQLite)

use std::path::PathBuf;
use std::sync::OnceLock;
use rusqlite::{Connection, params};
use anyhow::Result;
use std::sync::Mutex;

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
    let path = db_path
        .map(PathBuf::from)
        .unwrap_or_else(get_db_path);
    
    // 确保目录存在
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent)?;
        let _ = DATA_DIR.set(parent.to_path_buf());
    }
    
    let conn = Connection::open(&path)?;
    
    // 创建表
    conn.execute_batch(
        r#"
        -- 历史记录表
        CREATE TABLE IF NOT EXISTS history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            video_id TEXT NOT NULL UNIQUE,
            title TEXT NOT NULL,
            cover_url TEXT,
            duration TEXT,
            watch_progress INTEGER DEFAULT 0,
            total_duration INTEGER DEFAULT 0,
            watched_at INTEGER NOT NULL
        );
        
        -- 创建索引
        CREATE INDEX IF NOT EXISTS idx_history_watched_at ON history(watched_at DESC);
        CREATE INDEX IF NOT EXISTS idx_history_video_id ON history(video_id);
        
        -- 下载任务表
        CREATE TABLE IF NOT EXISTS downloads (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            video_id TEXT NOT NULL UNIQUE,
            title TEXT NOT NULL,
            cover_url TEXT,
            video_url TEXT NOT NULL,
            quality TEXT,
            save_path TEXT,
            total_bytes INTEGER DEFAULT 0,
            downloaded_bytes INTEGER DEFAULT 0,
            status INTEGER DEFAULT 0,
            error_message TEXT,
            created_at INTEGER NOT NULL,
            completed_at INTEGER
        );
        
        CREATE INDEX IF NOT EXISTS idx_downloads_status ON downloads(status);
        
        -- 稍后观看表
        CREATE TABLE IF NOT EXISTS watch_later (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            video_id TEXT NOT NULL UNIQUE,
            title TEXT NOT NULL,
            cover_url TEXT,
            duration TEXT,
            added_at INTEGER NOT NULL
        );
        
        CREATE INDEX IF NOT EXISTS idx_watch_later_added_at ON watch_later(added_at DESC);
        
        -- 设置表
        CREATE TABLE IF NOT EXISTS settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
        );
        
        -- Cookies 表
        CREATE TABLE IF NOT EXISTS cookies (
            domain TEXT NOT NULL,
            name TEXT NOT NULL,
            value TEXT NOT NULL,
            path TEXT DEFAULT '/',
            expires INTEGER,
            PRIMARY KEY (domain, name, path)
        );
        "#
    )?;
    
    let _ = ensure_download_columns(&conn);
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

fn ensure_download_columns(conn: &Connection) -> Result<()> {
    let mut stmt = conn.prepare("PRAGMA table_info(downloads)")?;
    let columns = stmt
        .query_map([], |row| Ok(row.get::<_, String>(1)?))?
        .collect::<Result<Vec<_>, _>>()?;

    if !columns.iter().any(|c| c == "quality") {
        let _ = conn.execute("ALTER TABLE downloads ADD COLUMN quality TEXT", []);
    }
    Ok(())
}

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
) -> Result<i64> {
    let db = get_db()?;
    let now = chrono::Utc::now().timestamp();
    
    db.execute(
        r#"
        INSERT OR IGNORE INTO downloads (video_id, title, cover_url, video_url, quality, created_at)
        VALUES (?1, ?2, ?3, ?4, ?5, ?6)
        "#,
        params![video_id, title, cover_url, video_url, quality, now],
    )?;
    
    Ok(db.last_insert_rowid())
}

/// 获取单个下载任务（按 video_id）
pub fn get_download_by_video_id(video_id: &str) -> Result<Option<DownloadRecord>> {
    let db = get_db()?;
    let mut stmt = db.prepare(
        "SELECT id, video_id, title, cover_url, video_url, quality, save_path, 
                total_bytes, downloaded_bytes, status, error_message, created_at, completed_at
         FROM downloads WHERE video_id = ?1 LIMIT 1"
    )?;

    let mut rows = stmt.query(params![video_id])?;
    if let Some(row) = rows.next()? {
        Ok(Some(DownloadRecord {
            id: row.get(0)?,
            video_id: row.get(1)?,
            title: row.get(2)?,
            cover_url: row.get(3)?,
            video_url: row.get(4)?,
            quality: row.get(5)?,
            save_path: row.get(6)?,
            total_bytes: row.get(7)?,
            downloaded_bytes: row.get(8)?,
            status: DownloadStatus::from(row.get::<_, i32>(9)?),
            error_message: row.get(10)?,
            created_at: row.get(11)?,
            completed_at: row.get(12)?,
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
pub fn update_download_status(video_id: &str, status: DownloadStatus, error: Option<&str>) -> Result<()> {
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

/// 获取下载列表
pub fn get_downloads() -> Result<Vec<DownloadRecord>> {
    let db = get_db()?;
    let mut stmt = db.prepare(
    "SELECT id, video_id, title, cover_url, video_url, quality, save_path, 
        total_bytes, downloaded_bytes, status, error_message, created_at, completed_at
         FROM downloads ORDER BY created_at DESC"
    )?;
    
    let records = stmt.query_map([], |row| {
        Ok(DownloadRecord {
            id: row.get(0)?,
            video_id: row.get(1)?,
            title: row.get(2)?,
            cover_url: row.get(3)?,
            video_url: row.get(4)?,
            quality: row.get(5)?,
            save_path: row.get(6)?,
            total_bytes: row.get(7)?,
            downloaded_bytes: row.get(8)?,
            status: DownloadStatus::from(row.get::<_, i32>(9)?),
            error_message: row.get(10)?,
            created_at: row.get(11)?,
            completed_at: row.get(12)?,
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
        params![DownloadStatus::Queued as i32, DownloadStatus::Downloading as i32],
    )?;
    Ok(())
}

/// 删除下载任务
pub fn delete_download(video_id: &str) -> Result<()> {
    let db = get_db()?;
    db.execute("DELETE FROM downloads WHERE video_id = ?1", params![video_id])?;
    Ok(())
}

// ========== 稍后观看 ==========

/// 稍后观看记录（内部使用）
#[derive(Debug, Clone)]
pub(crate) struct WatchLaterRecord {
    pub id: i64,
    pub video_id: String,
    pub title: String,
    pub cover_url: String,
    pub duration: String,
    pub added_at: i64,
}

/// 添加到稍后观看
pub fn add_watch_later(
    video_id: &str,
    title: &str,
    cover_url: &str,
    duration: &str,
) -> Result<()> {
    let db = get_db()?;
    let now = chrono::Utc::now().timestamp();
    
    db.execute(
        "INSERT OR IGNORE INTO watch_later (video_id, title, cover_url, duration, added_at) VALUES (?1, ?2, ?3, ?4, ?5)",
        params![video_id, title, cover_url, duration, now],
    )?;
    
    Ok(())
}

/// 获取稍后观看列表
pub fn get_watch_later() -> Result<Vec<WatchLaterRecord>> {
    let db = get_db()?;
    let mut stmt = db.prepare(
        "SELECT id, video_id, title, cover_url, duration, added_at 
         FROM watch_later ORDER BY added_at DESC"
    )?;
    
    let records = stmt.query_map([], |row| {
        Ok(WatchLaterRecord {
            id: row.get(0)?,
            video_id: row.get(1)?,
            title: row.get(2)?,
            cover_url: row.get(3)?,
            duration: row.get(4)?,
            added_at: row.get(5)?,
        })
    })?;
    
    let mut result = Vec::new();
    for record in records {
        result.push(record?);
    }
    
    Ok(result)
}

/// 从稍后观看移除
pub fn remove_watch_later(video_id: &str) -> Result<()> {
    let db = get_db()?;
    db.execute("DELETE FROM watch_later WHERE video_id = ?1", params![video_id])?;
    Ok(())
}

/// 清空稍后观看
pub fn clear_watch_later() -> Result<()> {
    let db = get_db()?;
    db.execute("DELETE FROM watch_later", [])?;
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
pub fn save_cookie(domain: &str, name: &str, value: &str, path: &str, expires: Option<i64>) -> Result<()> {
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
        "SELECT name, value FROM cookies WHERE domain = ?1 AND (expires IS NULL OR expires > ?2)"
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
        upsert_history("video1", "Test Video", "http://example.com/cover.jpg", "10:00", 300, 600).unwrap();
        let history = get_history(10, 0).unwrap();
        assert_eq!(history.len(), 1);
        assert_eq!(history[0].video_id, "video1");
        
        // 清理
        let _ = std::fs::remove_file(&db_path);
    }
}
