// 初始化和系统相关 API

use crate::api::{cache, download};
use crate::core::{network, otlp, storage};
use flutter_rust_bridge::frb;
use std::fs;
use std::io;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::sync::{Arc, Mutex, OnceLock};
use tracing_subscriber::fmt::MakeWriter;
use zip::write::FileOptions;

static INIT_GUARD: OnceLock<Mutex<bool>> = OnceLock::new();
static LOG_WRITER: OnceLock<RotatingMakeWriter> = OnceLock::new();

const LOG_FILE_MAX_BYTES: u64 = 1_000_000;
const LOG_TOTAL_MAX_BYTES_DEFAULT: u64 = 10 * 1024 * 1024;
const LOG_MAX_FILES_DEFAULT: usize = 30;
const LOG_MAX_AGE_DAYS_DEFAULT: i64 = 7;

/// 初始化应用（在 Flutter 启动时调用）
#[frb]
pub async fn init_app(data_path: String) -> anyhow::Result<()> {
    let guard = INIT_GUARD.get_or_init(|| Mutex::new(false));
    if *guard.lock().unwrap() {
        return Ok(());
    }

    // 初始化日志（默认 info），写入到 data_path/logs，并按 1 天或 1MB 轮转
    let log_dir = PathBuf::from(&data_path).join("logs");
    if let Err(e) = init_logging(&log_dir) {
        tracing::error!("Failed to initialize logging: {e:?}");
    }
    if let Err(e) = cleanup_logs_internal(
        &log_dir,
        LOG_TOTAL_MAX_BYTES_DEFAULT,
        LOG_MAX_FILES_DEFAULT,
        LOG_MAX_AGE_DAYS_DEFAULT,
    ) {
        tracing::warn!("Log cleanup failed: {e:?}");
    }
    if let Err(e) = cleanup_export_zips_internal(&PathBuf::from(&data_path).join("tmp")) {
        tracing::warn!("Export zip cleanup failed: {e:?}");
    }

    // 初始化数据库
    let db_path = format!("{}/data.db", data_path);
    storage::init_db(Some(&db_path))?;
    storage::reset_running_downloads()?;
    download::resume_queued_downloads().await?;

    if let Err(e) = otlp::init().await {
        tracing::debug!("OTLP init failed: {e:?}");
    }

    // 加载保存的 Cookies
    load_saved_cookies().await?;

    // 自动清理过期缓存并 VACUUM
    if let Err(e) = cache::auto_clean_cache(None, None).await {
        tracing::warn!("Auto clean cache failed: {}", e);
    }

    // 清理过期的已删除历史记录（保留1个月）
    if let Err(e) = storage::cleanup_expired_history() {
        tracing::warn!("Cleanup expired history failed: {}", e);
    }

    *guard.lock().unwrap() = true;
    tracing::info!("App initialized with data path: {}", data_path);
    Ok(())
}

fn init_logging(log_dir: &Path) -> anyhow::Result<()> {
    let writer = match LOG_WRITER.get() {
        Some(writer) => writer.clone(),
        None => {
            let writer = RotatingMakeWriter::new(log_dir.to_path_buf())?;
            if LOG_WRITER.set(writer.clone()).is_err() {
                // 可能存在并发初始化，直接复用已设置的实例
                LOG_WRITER
                    .get()
                    .expect("LOG_WRITER should be initialized")
                    .clone()
            } else {
                writer
            }
        }
    };

    let log_init = tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        .with_target(false)
        .with_ansi(false)
        .with_writer(writer.clone())
        .try_init();

    if let Err(e) = log_init {
        // 多次初始化时会返回 Err；记录到 stderr 即可，避免递归写日志。
        eprintln!("Logging already initialized or failed to init: {e:?}");
    } else {
        tracing::info!("Logging initialized at {}", log_dir.display());
    }

    std::panic::set_hook(Box::new(|info| {
        tracing::error!(target: "panic", "panic: {info}");
    }));

    Ok(())
}

/// 加载保存的 Cookies
async fn load_saved_cookies() -> anyhow::Result<()> {
    for host in network::HANIME_HOSTNAMES {
        let cookies = storage::get_cookies(host)?;
        if cookies.is_empty() {
            continue;
        }

        let cookie_str = cookies
            .iter()
            .map(|(k, v)| format!("{}={}", k, v))
            .collect::<Vec<_>>()
            .join("; ");

        if !cookie_str.is_empty() {
            network::set_cookies(&cookie_str, Some(host))?;
            tracing::info!("Loaded {} cookies for {}", cookies.len(), host);
        }
    }

    Ok(())
}

/// 设置 Cookies（从 WebView 获取后调用）
/// domain: 可选的域名，如果不提供则使用当前活跃域名
#[frb]
pub async fn set_cookies(cookie_string: String, domain: Option<String>) -> anyhow::Result<()> {
    // 使用传入的域名或当前活跃域名
    let host = domain.unwrap_or_else(|| network::get_active_domain().host.clone());
    
    // 设置到网络模块
    network::set_cookies(&cookie_string, Some(&host))?;

    // 解析并保存到数据库
    let mut last_expires: Option<i64> = None;

    for part in cookie_string.split(';') {
        let trimmed = part.trim();
        if trimmed.is_empty() {
            continue;
        }

        let lower = trimmed.to_ascii_lowercase();
        if lower.starts_with("expires=") {
            let value = trimmed[8..].trim();
            if let Ok(time) = chrono::DateTime::parse_from_rfc2822(value) {
                last_expires = Some(time.timestamp());
            }
            continue;
        }
        if lower.starts_with("max-age=") {
            if let Ok(age) = trimmed[8..].trim().parse::<i64>() {
                last_expires = Some(chrono::Utc::now().timestamp() + age);
            }
            continue;
        }
        if lower.starts_with("path=")
            || lower.starts_with("domain=")
            || lower == "httponly"
            || lower == "secure"
        {
            continue;
        }

        if let Some(idx) = trimmed.find('=') {
            let name = trimmed[..idx].trim();
            let value = trimmed[idx + 1..].trim();
            storage::save_cookie(&host, name, value, "/", last_expires)?;
            last_expires = None;
        }
    }

    tracing::info!("Cookies saved");
    Ok(())
}

/// 检查是否需要 Cloudflare 验证
#[frb]
pub async fn check_cloudflare() -> anyhow::Result<bool> {
    // 尝试访问首页
    let needs_challenge = !network::check_access().await;

    if needs_challenge {
        tracing::info!("Cloudflare challenge required");
    } else {
        tracing::info!("No Cloudflare challenge needed");
    }

    Ok(needs_challenge)
}

/// 清除所有 Cookies（登出时调用）
#[frb]
pub async fn clear_cookies() -> anyhow::Result<()> {
    let host = network::get_active_domain().cookie_domain().to_string();
    storage::clear_cookies(Some(&host))?;
    let _ = network::clear_cookies(Some(&host));
    tracing::info!("All cookies cleared");
    Ok(())
}

/// Flutter 侧遇到错误时调用，把错误信息写入 Rust 日志
#[frb]
pub fn report_flutter_error(message: String, stack: Option<String>) {
    report_flutter_log("error".to_string(), message, None, stack);
}

/// Flutter 侧日志（不限 error 级别）
///
/// `level` 支持：`trace|debug|info|warn|error`（大小写不敏感），其他值默认按 `info` 处理。
#[frb]
pub fn report_flutter_log(
    level: String,
    message: String,
    tag: Option<String>,
    stack: Option<String>,
) {
    let level = level.to_ascii_lowercase();
    let tag = tag.unwrap_or_else(|| "app".to_string());

    let stack = stack.unwrap_or_default();
    if !stack.is_empty() {
        match level.as_str() {
            "trace" => {
                tracing::trace!(target: "flutter", tag = %tag, msg = %message, stack = %stack)
            }
            "debug" => {
                tracing::debug!(target: "flutter", tag = %tag, msg = %message, stack = %stack)
            }
            "info" => tracing::info!(target: "flutter", tag = %tag, msg = %message, stack = %stack),
            "warn" | "warning" => {
                tracing::warn!(target: "flutter", tag = %tag, msg = %message, stack = %stack)
            }
            "error" => {
                tracing::error!(target: "flutter", tag = %tag, msg = %message, stack = %stack)
            }
            _ => tracing::info!(target: "flutter", tag = %tag, msg = %message, stack = %stack),
        }
    } else {
        match level.as_str() {
            "trace" => tracing::trace!(target: "flutter", tag = %tag, msg = %message),
            "debug" => tracing::debug!(target: "flutter", tag = %tag, msg = %message),
            "info" => tracing::info!(target: "flutter", tag = %tag, msg = %message),
            "warn" | "warning" => tracing::warn!(target: "flutter", tag = %tag, msg = %message),
            "error" => tracing::error!(target: "flutter", tag = %tag, msg = %message),
            _ => tracing::info!(target: "flutter", tag = %tag, msg = %message),
        }
    }
}

/// 为“分享日志”做准备：强制切换到新日志文件，并返回“已封存”的日志文件路径列表（不会再被追加）。
///
/// Flutter 侧应先调用该接口，再读取/打包返回的文件，从而避免分享过程中日志继续追加到同一批文件里。
#[frb]
pub fn prepare_logs_for_sharing() -> anyhow::Result<Vec<String>> {
    let writer = LOG_WRITER
        .get()
        .ok_or_else(|| anyhow::anyhow!("logging not initialized"))?;
    writer.force_rotate()?;
    let files = writer.list_sealed_log_files()?;
    Ok(files
        .into_iter()
        .map(|p| p.to_string_lossy().into_owned())
        .collect())
}

/// Rust 侧创建日志 zip（Flutter 仅负责分享这个 zip）
///
/// - 文件放在 `{data_dir}/tmp/hibiscus_logs_*.zip`
/// - 会先轮转一次，保证打包的文件不会再被追加
#[frb]
pub fn export_logs_zip() -> anyhow::Result<String> {
    let writer = LOG_WRITER
        .get()
        .ok_or_else(|| anyhow::anyhow!("logging not initialized"))?;

    // 轮转并拿到“封存”日志：轮转后，新的 current_path 会继续被写入，因此不能打包；
    // 我们只打包轮转前的旧文件（以及更早的文件）。
    writer.force_rotate()?;
    let (log_dir, current_path) = {
        let state = writer.inner.lock().unwrap();
        (state.dir.clone(), state.current_path.clone())
    };

    let data_dir = storage::get_data_dir()?;
    let tmp_dir = data_dir.join("tmp");
    fs::create_dir_all(&tmp_dir)?;

    let ts = chrono::Local::now().format("%Y%m%d_%H%M%S").to_string();
    let zip_path = tmp_dir.join(format!("hibiscus_logs_{ts}.zip"));
    let file = fs::File::create(&zip_path)?;
    let mut zip = zip::ZipWriter::new(file);

    let mut sealed: Vec<PathBuf> = vec![];
    for entry in fs::read_dir(&log_dir)? {
        let entry = entry?;
        let path = entry.path();
        if path == current_path {
            continue;
        }
        let Some(name) = path.file_name().and_then(|s| s.to_str()) else {
            continue;
        };
        if !name.starts_with("hibiscus_")
            || path.extension().and_then(|s| s.to_str()) != Some("log")
        {
            continue;
        }
        let meta = entry.metadata()?;
        if !meta.is_file() {
            continue;
        }
        sealed.push(path);
    }

    sealed.sort();

    if sealed.is_empty() {
        // 理论上轮转后至少会有一个旧文件；如果因为异常/清理导致没有，就把 current_path
        // 复制出一个快照文件再打包（快照不会继续被追加，符合“不打包正在写入的文件”）。
        let snapshot = tmp_dir.join(format!("hibiscus_snapshot_{ts}.log"));
        let _ = fs::copy(&current_path, &snapshot);
        zip.start_file("hibiscus_snapshot.log", FileOptions::default())?;
        let mut f = fs::File::open(&snapshot)?;
        io::copy(&mut f, &mut zip)?;
    } else {
        for path in sealed.iter() {
            let name = path
                .file_name()
                .and_then(|s| s.to_str())
                .unwrap_or("log.log");
            zip.start_file(name, FileOptions::default())?;
            let mut f = fs::File::open(path)?;
            io::copy(&mut f, &mut zip)?;
        }
    }
    zip.finish()?;

    // 打包完成后再清理日志，避免“刚轮转的第一条”在打包前被删掉。
    let _ = cleanup_logs_internal(
        &log_dir,
        LOG_TOTAL_MAX_BYTES_DEFAULT,
        LOG_MAX_FILES_DEFAULT,
        LOG_MAX_AGE_DAYS_DEFAULT,
    );
    let _ = cleanup_export_zips_internal(&tmp_dir);

    Ok(zip_path.to_string_lossy().to_string())
}

/// 清理日志文件（按总大小/数量/时间）
#[frb]
pub fn cleanup_logs(
    data_path: String,
    max_total_bytes: Option<u64>,
    max_files: Option<u32>,
    max_age_days: Option<i64>,
) -> anyhow::Result<()> {
    let log_dir = PathBuf::from(&data_path).join("logs");
    cleanup_logs_internal(
        &log_dir,
        max_total_bytes.unwrap_or(LOG_TOTAL_MAX_BYTES_DEFAULT),
        max_files
            .map(|v| v as usize)
            .unwrap_or(LOG_MAX_FILES_DEFAULT),
        max_age_days.unwrap_or(LOG_MAX_AGE_DAYS_DEFAULT),
    )?;
    Ok(())
}

/// 获取应用版本
#[frb]
pub fn get_version() -> String {
    env!("CARGO_PKG_VERSION").to_string()
}

/// 检查网络连接
#[frb]
pub async fn check_network() -> anyhow::Result<bool> {
    match reqwest::get("https://www.bing.com").await {
        Ok(_) => Ok(true),
        Err(_) => {
            // 尝试备用地址
            match reqwest::get("https://www.google.com").await {
                Ok(_) => Ok(true),
                Err(_) => Ok(false),
            }
        }
    }
}

#[derive(Clone)]
struct RotatingMakeWriter {
    inner: Arc<Mutex<RotatingState>>,
}

struct RotatingState {
    dir: PathBuf,
    current_path: PathBuf,
    current_date: chrono::NaiveDate,
    seq: u32,
    file: fs::File,
    size: u64,
}

impl RotatingMakeWriter {
    fn new(dir: PathBuf) -> io::Result<Self> {
        fs::create_dir_all(&dir)?;
        let now = chrono::Local::now();
        let current_date = now.date_naive();
        let (current_path, file) = open_new_log_file(&dir, 0)?;
        let size = file.metadata().map(|m| m.len()).unwrap_or(0);
        Ok(Self {
            inner: Arc::new(Mutex::new(RotatingState {
                dir,
                current_path,
                current_date,
                seq: 0,
                file,
                size,
            })),
        })
    }

    fn force_rotate(&self) -> io::Result<()> {
        let mut state = self.inner.lock().unwrap();
        rotate_locked(&mut state, true, 0)?;
        Ok(())
    }

    fn list_sealed_log_files(&self) -> io::Result<Vec<PathBuf>> {
        let state = self.inner.lock().unwrap();
        let mut paths = vec![];
        for entry in fs::read_dir(&state.dir)? {
            let entry = entry?;
            let path = entry.path();
            if path == state.current_path {
                continue;
            }
            if let Some(name) = path.file_name().and_then(|s| s.to_str()) {
                if !name.starts_with("hibiscus_") {
                    continue;
                }
            }
            if path.extension().and_then(|s| s.to_str()) != Some("log") {
                continue;
            }
            paths.push(path);
        }
        paths.sort();
        Ok(paths)
    }
}

struct LockedWriter<'a> {
    state: std::sync::MutexGuard<'a, RotatingState>,
}

impl<'a> Write for LockedWriter<'a> {
    fn write(&mut self, buf: &[u8]) -> io::Result<usize> {
        rotate_locked(&mut self.state, false, buf.len() as u64)?;
        let written = self.state.file.write(buf)?;
        self.state.size = self.state.size.saturating_add(written as u64);
        Ok(written)
    }

    fn flush(&mut self) -> io::Result<()> {
        self.state.file.flush()
    }
}

impl<'a> MakeWriter<'a> for RotatingMakeWriter {
    type Writer = LockedWriter<'a>;

    fn make_writer(&'a self) -> Self::Writer {
        LockedWriter {
            state: self.inner.lock().unwrap(),
        }
    }
}

fn rotate_locked(state: &mut RotatingState, force: bool, incoming_len: u64) -> io::Result<()> {
    let today = chrono::Local::now().date_naive();
    let need_new_day = today != state.current_date;
    let need_new_size = state.size.saturating_add(incoming_len) > LOG_FILE_MAX_BYTES;
    if !force && !need_new_day && !need_new_size {
        return Ok(());
    }

    // 确保被“封存”的旧文件落盘，避免导出时缺少尾部日志。
    let _ = state.file.flush();

    state.seq = state.seq.saturating_add(1);
    let (path, file) = open_new_log_file(&state.dir, state.seq)?;
    state.current_path = path;
    state.file = file;
    state.size = state.file.metadata().map(|m| m.len()).unwrap_or(0);
    state.current_date = today;
    Ok(())
}

fn open_new_log_file(dir: &Path, seq: u32) -> io::Result<(PathBuf, fs::File)> {
    let ts = chrono::Local::now().format("%Y%m%d_%H%M%S").to_string();
    let filename = format!("hibiscus_{ts}_{seq}.log");
    let path = dir.join(filename);
    let file = fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open(&path)?;
    Ok((path, file))
}

fn cleanup_logs_internal(
    log_dir: &Path,
    max_total_bytes: u64,
    max_files: usize,
    max_age_days: i64,
) -> anyhow::Result<()> {
    fs::create_dir_all(log_dir)?;

    let cutoff = chrono::Utc::now() - chrono::Duration::days(max_age_days);
    let mut entries: Vec<(PathBuf, std::time::SystemTime, u64)> = vec![];

    for entry in fs::read_dir(log_dir)? {
        let entry = entry?;
        let path = entry.path();
        let Some(name) = path.file_name().and_then(|s| s.to_str()) else {
            continue;
        };
        if !name.starts_with("hibiscus_")
            || path.extension().and_then(|s| s.to_str()) != Some("log")
        {
            continue;
        }
        let meta = match entry.metadata() {
            Ok(m) => m,
            Err(_) => continue,
        };
        let modified = meta.modified().unwrap_or(std::time::SystemTime::UNIX_EPOCH);
        let size = meta.len();
        entries.push((path, modified, size));
    }

    entries.sort_by_key(|(_, modified, _)| *modified);

    // 先按时间删除
    for (path, modified, _) in entries.iter() {
        let modified_utc: chrono::DateTime<chrono::Utc> = (*modified).into();
        if modified_utc < cutoff {
            let _ = fs::remove_file(path);
        }
    }

    // 重新扫描并按大小/数量删除
    let mut entries: Vec<(PathBuf, std::time::SystemTime, u64)> = vec![];
    for entry in fs::read_dir(log_dir)? {
        let entry = entry?;
        let path = entry.path();
        let Some(name) = path.file_name().and_then(|s| s.to_str()) else {
            continue;
        };
        if !name.starts_with("hibiscus_")
            || path.extension().and_then(|s| s.to_str()) != Some("log")
        {
            continue;
        }
        let meta = match entry.metadata() {
            Ok(m) => m,
            Err(_) => continue,
        };
        let modified = meta.modified().unwrap_or(std::time::SystemTime::UNIX_EPOCH);
        let size = meta.len();
        entries.push((path, modified, size));
    }
    entries.sort_by_key(|(_, modified, _)| *modified);

    let mut total: u64 = entries.iter().map(|(_, _, size)| *size).sum();
    let mut count = entries.len();

    for (path, _, size) in entries {
        if count <= max_files && total <= max_total_bytes {
            break;
        }
        let current_path = LOG_WRITER
            .get()
            .map(|w| w.inner.lock().unwrap().current_path.clone());
        if let Some(p) = current_path.as_ref() {
            if *p == path {
                continue;
            }
        }
        if fs::remove_file(&path).is_ok() {
            count = count.saturating_sub(1);
            total = total.saturating_sub(size);
        }
    }

    Ok(())
}

fn cleanup_export_zips_internal(tmp_dir: &Path) -> anyhow::Result<()> {
    fs::create_dir_all(tmp_dir)?;
    let cutoff = chrono::Utc::now() - chrono::Duration::days(1);

    for entry in fs::read_dir(tmp_dir)? {
        let entry = entry?;
        let path = entry.path();
        let Some(name) = path.file_name().and_then(|s| s.to_str()) else {
            continue;
        };
        if !name.starts_with("hibiscus_logs_")
            || path.extension().and_then(|s| s.to_str()) != Some("zip")
        {
            continue;
        }
        let meta = match entry.metadata() {
            Ok(m) => m,
            Err(_) => continue,
        };
        let modified = meta.modified().unwrap_or(std::time::SystemTime::UNIX_EPOCH);
        let modified_utc: chrono::DateTime<chrono::Utc> = modified.into();
        if modified_utc < cutoff {
            let _ = fs::remove_file(path);
        }
    }

    Ok(())
}
