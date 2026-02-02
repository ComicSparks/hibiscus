// WebDAV 同步模块
// 用于同步浏览历史到 WebDAV 服务器

use aes_gcm::{
    aead::{Aead, KeyInit},
    Aes256Gcm, Nonce,
};
use anyhow::{anyhow, Result};
use flate2::{read::GzDecoder, write::GzEncoder, Compression};
use reqwest_dav::{Auth, Client as DavClient, ClientBuilder, Depth};
use serde::{Deserialize, Serialize};
use std::io::{Read, Write};
use urlencoding::decode;

/// 默认加密密钥
const DEFAULT_KEY: &str = "hibiscus";

/// 文件结束标记
const FILE_END_MARKER: &str = "<<HIBISCUS_SYNC_END>>";

/// 同步文件名前缀
const SYNC_FILE_PREFIX: &str = "hibiscus_history_";

/// 历史记录同步格式
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SyncHistoryRecord {
    pub video_id: String,
    pub title: String,
    pub cover_url: String,
    pub duration: String,
    pub watch_progress: i32,
    pub total_duration: i32,
    pub watched_at: i64,
    pub deleted_at: Option<i64>,
}

/// WebDAV 客户端
pub struct WebDavClient {
    client: DavClient,
}

impl WebDavClient {
    pub fn new(base_url: &str, username: &str, password: &str) -> Self {
        // reqwest_dav 的 host 是 “基地址 + 路径前缀”，这里保持与原实现一致，确保以 / 结尾。
        let base_url = if base_url.ends_with('/') {
            base_url.to_string()
        } else {
            format!("{}/", base_url)
        };

        // 与旧逻辑一致：默认 Basic；留空也允许（有些服务端匿名可访问）。
        let auth = if username.is_empty() && password.is_empty() {
            Auth::Anonymous
        } else {
            Auth::Basic(username.to_string(), password.to_string())
        };

        let client = ClientBuilder::new()
            .set_host(base_url.clone())
            .set_auth(auth)
            .build()
            .expect("Failed to build reqwest_dav client");

        Self { client }
    }

    /// 列出目录中的文件
    pub async fn list_files(&self) -> Result<Vec<String>> {
        let entities = self
            .client
            .list("", Depth::Number(1))
            .await
            .map_err(|e| anyhow!("WebDAV PROPFIND failed: {e:?}"))?;

        let mut files = Vec::new();
        for entity in entities {
            let href = match entity {
                reqwest_dav::list_cmd::ListEntity::File(f) => f.href,
                reqwest_dav::list_cmd::ListEntity::Folder(_) => continue,
            };
            let href_trimmed = href.trim();
            let decoded = decode(href_trimmed).unwrap_or_else(|_| href_trimmed.into());
            let filename = decoded.rsplit('/').next().unwrap_or("").trim();
            if filename.starts_with(SYNC_FILE_PREFIX) && filename.ends_with(".gz.enc") {
                files.push(filename.to_string());
            }
        }

        files.sort();
        files.dedup();
        Ok(files)
    }

    /// 下载文件
    pub async fn download(&self, filename: &str) -> Result<Vec<u8>> {
        let response = self
            .client
            .get(filename)
            .await
            .map_err(|e| anyhow!("WebDAV download failed: {e:?}"))?;
        Ok(response.bytes().await?.to_vec())
    }

    /// 上传文件
    pub async fn upload(&self, filename: &str, data: &[u8]) -> Result<()> {
        self.client
            .put(filename, data.to_vec())
            .await
            .map_err(|e| anyhow!("WebDAV upload failed: {e:?}"))?;
        Ok(())
    }

    /// 删除文件
    pub async fn delete(&self, filename: &str) -> Result<()> {
        let response = self
            .client
            .delete_raw(filename)
            .await
            .map_err(|e| anyhow!("WebDAV delete failed: {e:?}"))?;
        // 404 也认为成功（文件不存在）
        if response.status() == reqwest::StatusCode::NOT_FOUND {
            return Ok(());
        }
        if !response.status().is_success() {
            return Err(anyhow!("WebDAV delete failed: {}", response.status()));
        }
        Ok(())
    }

    /// 测试连接
    pub async fn test_connection(&self) -> Result<()> {
        self.client
            .list("", Depth::Number(0))
            .await
            .map_err(|e| anyhow!("WebDAV connection test failed: {e:?}"))?;
        Ok(())
    }
}

/// 从密钥字符串派生 AES-256 密钥
fn derive_key(password: &str) -> [u8; 32] {
    let password = if password.is_empty() {
        DEFAULT_KEY
    } else {
        password
    };

    // 使用简单的 PBKDF-like 派生（多次 SHA256）
    let mut key = [0u8; 32];
    let hash = md5::compute(format!("hibiscus_sync_{}_salt", password).as_bytes());
    key[..16].copy_from_slice(&hash.0);
    let hash2 = md5::compute(format!("{}_{:x}", password, hash).as_bytes());
    key[16..].copy_from_slice(&hash2.0);
    key
}

/// AES-GCM 加密
pub fn encrypt(plaintext: &[u8], password: &str) -> Result<Vec<u8>> {
    let key = derive_key(password);
    let cipher =
        Aes256Gcm::new_from_slice(&key).map_err(|e| anyhow!("Invalid key length: {:?}", e))?;

    // 生成随机 nonce
    let mut nonce_bytes = [0u8; 12];
    use rand::RngCore;
    rand::thread_rng().fill_bytes(&mut nonce_bytes);
    let nonce = Nonce::from_slice(&nonce_bytes);

    let ciphertext = cipher
        .encrypt(nonce, plaintext)
        .map_err(|e| anyhow!("Encryption failed: {}", e))?;

    // 返回 nonce + ciphertext
    let mut result = nonce_bytes.to_vec();
    result.extend(ciphertext);
    Ok(result)
}

/// AES-GCM 解密
pub fn decrypt(ciphertext: &[u8], password: &str) -> Result<Vec<u8>> {
    if ciphertext.len() < 12 {
        return Err(anyhow!("Ciphertext too short"));
    }

    let key = derive_key(password);
    let cipher =
        Aes256Gcm::new_from_slice(&key).map_err(|e| anyhow!("Invalid key length: {:?}", e))?;

    let nonce = Nonce::from_slice(&ciphertext[..12]);
    let plaintext = cipher
        .decrypt(nonce, &ciphertext[12..])
        .map_err(|_| anyhow!("Decryption failed: invalid key or corrupted data"))?;

    Ok(plaintext)
}

/// GZIP 压缩
pub fn compress(data: &[u8]) -> Result<Vec<u8>> {
    let mut encoder = GzEncoder::new(Vec::new(), Compression::default());
    encoder.write_all(data)?;
    Ok(encoder.finish()?)
}

/// GZIP 解压
pub fn decompress(data: &[u8]) -> Result<Vec<u8>> {
    let mut decoder = GzDecoder::new(data);
    let mut decompressed = Vec::new();
    decoder.read_to_end(&mut decompressed)?;
    Ok(decompressed)
}

/// 序列化历史记录为同步格式（每行一个 JSON + 结束标记）
pub fn serialize_history(records: &[SyncHistoryRecord]) -> String {
    let mut lines: Vec<String> = records
        .iter()
        .filter_map(|r| serde_json::to_string(r).ok())
        .collect();
    lines.push(FILE_END_MARKER.to_string());
    lines.join("\n")
}

/// 反序列化历史记录
/// 返回 (records, is_complete) - is_complete 表示文件是否有结束标记
pub fn deserialize_history(content: &str) -> (Vec<SyncHistoryRecord>, bool) {
    let mut records = Vec::new();
    let mut is_complete = false;

    for line in content.lines() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }
        if line == FILE_END_MARKER {
            is_complete = true;
            break;
        }
        if let Ok(record) = serde_json::from_str::<SyncHistoryRecord>(line) {
            records.push(record);
        }
    }

    (records, is_complete)
}

/// 生成同步文件名
pub fn generate_sync_filename() -> String {
    let timestamp = chrono::Utc::now().timestamp_millis();
    format!("{}{}.gz.enc", SYNC_FILE_PREFIX, timestamp)
}

/// 从文件名提取时间戳
pub fn extract_timestamp(filename: &str) -> Option<i64> {
    let name = filename
        .strip_prefix(SYNC_FILE_PREFIX)?
        .strip_suffix(".gz.enc")?;
    name.parse().ok()
}

/// 同步结果
#[derive(Debug, Clone)]
pub enum SyncResult {
    /// 同步成功
    Success { merged_count: usize, uploaded: bool },
    /// 解密失败，需要用户确认
    DecryptionFailed,
    /// 网络错误
    NetworkError(String),
}

/// 执行历史记录同步
/// 返回 (需要合并的远程记录, 是否解密成功)
pub async fn download_and_parse_history(
    client: &WebDavClient,
    password: &str,
) -> Result<(Vec<SyncHistoryRecord>, bool)> {
    // 列出所有同步文件
    let files = client.list_files().await?;
    if files.is_empty() {
        tracing::info!("WebDAV sync: no remote files found");
        return Ok((Vec::new(), true));
    }
    tracing::info!("WebDAV sync: found {} remote files", files.len());

    // 按时间戳排序（降序）
    let mut files_with_ts: Vec<(String, i64)> = files
        .into_iter()
        .filter_map(|f| {
            let ts = extract_timestamp(&f)?;
            Some((f, ts))
        })
        .collect();
    files_with_ts.sort_by(|a, b| b.1.cmp(&a.1));

    // 递归查找有效的完整文件（优先最新；若不完整/损坏则向前找）
    let mut saw_decrypt_failure = false;
    for (filename, _ts) in &files_with_ts {
        tracing::info!("WebDAV sync: trying remote file {filename}");
        let data = match client.download(filename).await {
            Ok(d) => d,
            Err(_) => continue,
        };

        // 尝试解密
        let decrypted = match decrypt(&data, password) {
            Ok(d) => d,
            Err(_) => {
                // 可能是密钥不正确，也可能是文件未完整上传/损坏；
                // 先尝试更旧的文件，若全部失败再提示 UI 处理。
                saw_decrypt_failure = true;
                tracing::warn!("WebDAV sync: decrypt failed for {filename}");
                continue;
            }
        };

        // 解压
        let decompressed = match decompress(&decrypted) {
            Ok(d) => d,
            Err(e) => {
                tracing::warn!("WebDAV sync: decompress failed for {filename}: {e}");
                continue;
            }
        };

        // 解析
        let content = String::from_utf8_lossy(&decompressed);
        let (records, is_complete) = deserialize_history(&content);

        if is_complete {
            tracing::info!(
                "WebDAV sync: using remote file {filename} with {} records",
                records.len()
            );
            return Ok((records, true));
        }
        // 如果不完整，继续查找更旧的文件
        tracing::warn!("WebDAV sync: remote file {filename} missing end marker, fallback");
    }

    // 没有找到完整文件
    tracing::warn!("WebDAV sync: no complete file found");
    Ok((Vec::new(), !saw_decrypt_failure))
}

/// 上传历史记录
pub async fn upload_history(
    client: &WebDavClient,
    records: &[SyncHistoryRecord],
    password: &str,
) -> Result<String> {
    // 序列化
    let content = serialize_history(records);

    // 压缩
    let compressed = compress(content.as_bytes())?;

    // 加密
    let encrypted = encrypt(&compressed, password)?;

    // 生成文件名
    let filename = generate_sync_filename();

    // 上传
    client.upload(&filename, &encrypted).await?;

    Ok(filename)
}

/// 清理旧的同步文件（保留最新的）
pub async fn cleanup_old_files(client: &WebDavClient, keep_latest: &str) -> Result<()> {
    let files = client.list_files().await?;

    for file in files {
        if file != keep_latest {
            let _ = client.delete(&file).await;
        }
    }

    Ok(())
}
