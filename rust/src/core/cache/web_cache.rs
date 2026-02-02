// Web 接口缓存
// 用于缓存 API 响应，默认 10 分钟过期

use super::utils::hash_lock;
use anyhow::Result;
use rusqlite::params;
use serde::{de::DeserializeOwned, Serialize};
use std::future::Future;
use std::time::Duration;

/// 缓存优先模式：先查缓存，过期则请求网络并更新缓存
pub async fn cache_first<T, F, Fut>(key: &str, expire: Duration, fetch: F) -> Result<T>
where
    T: Serialize + DeserializeOwned,
    F: FnOnce() -> Fut,
    Fut: Future<Output = Result<T>>,
{
    let _lock = hash_lock(key).await;
    let now = chrono::Local::now().timestamp_millis();
    let expire_ms = expire.as_millis() as i64;

    // 尝试从缓存读取
    if let Some((content, cache_time)) = get_cache(key)? {
        if now < cache_time + expire_ms {
            // 缓存未过期，反序列化返回
            if let Ok(data) = serde_json::from_str::<T>(&content) {
                tracing::debug!("Cache hit for key: {}", key);
                return Ok(data);
            }
        }
    }

    // 缓存不存在或已过期，请求网络
    tracing::debug!("Cache miss for key: {}, fetching...", key);
    let data = fetch().await?;

    // 序列化并保存到缓存
    let content = serde_json::to_string(&data)?;
    set_cache(key, &content, now)?;

    Ok(data)
}

/// 获取缓存
fn get_cache(key: &str) -> Result<Option<(String, i64)>> {
    let db = crate::core::storage::get_db()?;
    let mut stmt =
        db.prepare_cached("SELECT cache_content, cache_time FROM web_cache WHERE cache_key = ?1")?;
    let mut rows = stmt.query(params![key])?;

    if let Some(row) = rows.next()? {
        let content: String = row.get(0)?;
        let cache_time: i64 = row.get(1)?;
        Ok(Some((content, cache_time)))
    } else {
        Ok(None)
    }
}

/// 设置缓存
fn set_cache(key: &str, content: &str, cache_time: i64) -> Result<()> {
    let db = crate::core::storage::get_db()?;
    db.execute(
        "INSERT OR REPLACE INTO web_cache (cache_key, cache_content, cache_time) VALUES (?1, ?2, ?3)",
        params![key, content, cache_time],
    )?;
    Ok(())
}

/// 清理过期缓存
pub fn clean_expired(before_time: i64) -> Result<u64> {
    let db = crate::core::storage::get_db()?;
    let count = db.execute(
        "DELETE FROM web_cache WHERE cache_time < ?1",
        params![before_time],
    )?;
    tracing::info!("Cleaned {} expired web cache entries", count);
    Ok(count as u64)
}

/// 按键前缀清理缓存
pub fn clean_by_key_prefix(prefix: &str) -> Result<u64> {
    let db = crate::core::storage::get_db()?;
    let pattern = format!("{}%", prefix);
    let count = db.execute(
        "DELETE FROM web_cache WHERE cache_key LIKE ?1",
        params![pattern],
    )?;
    Ok(count as u64)
}

/// 清理所有 web 缓存
pub fn clean_all() -> Result<u64> {
    let db = crate::core::storage::get_db()?;
    let count = db.execute("DELETE FROM web_cache", [])?;
    tracing::info!("Cleaned all {} web cache entries", count);
    Ok(count as u64)
}
