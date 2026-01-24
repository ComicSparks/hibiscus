// Hibiscus 数据模型
// 通过 FRB dart_metadata 注解，自动生成 Dart freezed 类
// 所有模型以 Api 前缀命名，避免与内部模型冲突

use flutter_rust_bridge::frb;

// ============================================================================
// 视频相关模型
// ============================================================================

/// 视频卡片信息（列表展示用）
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiVideoCard {
    pub id: String,
    pub title: String,
    pub cover_url: String,
    pub duration: Option<String>,
    pub views: Option<String>,
    pub upload_date: Option<String>,
    pub tags: Vec<String>,
}

/// 视频详情信息
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiVideoDetail {
    pub id: String,
    pub title: String,
    pub chinese_title: Option<String>,
    pub cover_url: String,
    pub description: Option<String>,
    pub duration: Option<String>,
    pub views: Option<String>,
    pub likes: Option<String>,
    pub upload_date: Option<String>,
    pub author: Option<ApiAuthorInfo>,
    pub tags: Vec<String>,
    pub qualities: Vec<ApiVideoQuality>,
    pub series: Option<ApiSeriesInfo>,
    pub related_videos: Vec<ApiVideoCard>,
    /// HTML 表单 hidden input `_token`（Laravel 表单 token）
    pub form_token: Option<String>,
    pub current_user_id: Option<String>,
    pub is_fav: bool,
    pub fav_times: Option<i32>,
    pub playlist: Option<ApiPlaylistInfo>,
    pub my_list: Option<ApiMyListInfo>,
}

/// 视频清晰度
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiVideoQuality {
    pub quality: String, // "1080p", "720p", "480p", "360p"
    pub url: String,
}

/// 作者信息
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiAuthorInfo {
    pub id: String,
    pub name: String,
    pub avatar_url: Option<String>,
    pub is_subscribed: bool,
}

/// 我的订阅页数据
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiSubscriptionsPage {
    pub authors: Vec<ApiAuthorInfo>,
    pub videos: Vec<ApiVideoCard>,
    pub page: u32,
    pub has_next: bool,
}

/// 系列信息
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiSeriesInfo {
    pub id: String,
    pub title: String,
    pub videos: Vec<ApiSeriesVideo>,
    pub current_index: u32,
}

/// 系列中的单个视频
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiSeriesVideo {
    pub id: String,
    pub title: String,
    pub cover_url: String,
    pub episode: String,
}

/// 播放列表信息
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiPlaylistInfo {
    pub name: Option<String>,
    pub videos: Vec<ApiVideoCard>,
}

/// 我的列表信息（收藏、稍后观看等）
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiMyListInfo {
    pub is_watch_later: bool,
    pub items: Vec<ApiMyListItem>,
}

/// 我的列表项
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiMyListItem {
    pub code: String,
    pub title: String,
    pub is_selected: bool,
}

// ============================================================================
// 首页相关模型
// ============================================================================

/// 首页数据
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiHomePage {
    /// HTML 表单 hidden input `_token`（Laravel 表单 token）
    pub form_token: Option<String>,
    pub avatar_url: Option<String>,
    pub username: Option<String>,
    pub banner: Option<ApiBanner>,
    pub latest_release: Vec<ApiVideoCard>,
    pub latest_upload: Vec<ApiVideoCard>,
    pub sections: Vec<ApiHomeSection>,
}

/// Banner 信息
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiBanner {
    pub title: String,
    pub description: Option<String>,
    pub pic_url: String,
    pub video_code: Option<String>,
}

/// 首页分区
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiHomeSection {
    pub name: String,
    pub videos: Vec<ApiVideoCard>,
}

// ============================================================================
// 搜索相关模型
// ============================================================================

/// 搜索结果
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiSearchResult {
    pub videos: Vec<ApiVideoCard>,
    pub total: u32,
    pub page: u32,
    pub has_next: bool,
}

/// 搜索过滤条件
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiSearchFilters {
    pub query: Option<String>,
    pub genre: Option<String>,       // 影片類型: 裏番, 泡麵番, Motion Anime, 3DCG, 2.5D, 2D動畫, AI生成, MMD, Cosplay
    pub tags: Vec<String>,           // 內容標籤
    pub broad_match: bool,           // 廣泛配對
    pub sort: Option<String>,        // 排序: 最新上市, 最新上傳, 本日排行, 本週排行, 本月排行, 觀看次數, 讚好比例, 時長最長, 他們在看
    pub year: Option<String>,        // 年份: "2024 年"
    pub month: Option<String>,       // 月份: "1 月"
    pub date: Option<String>,        // 快速日期: 過去 24 小時, 過去 2 天, 過去 1 週, 過去 1 個月, 過去 3 個月, 過去 1 年
    pub duration: Option<String>,    // 時長: 1 分鐘 +, 5 分鐘 +, 10 分鐘 +, 20 分鐘 +, 30 分鐘 +, 60 分鐘 +, 0 - 10 分鐘, 0 - 20 分鐘
    pub page: u32,
}

impl Default for ApiSearchFilters {
    fn default() -> Self {
        Self {
            query: None,
            genre: None,
            tags: vec![],
            broad_match: false,
            sort: None,
            year: None,
            month: None,
            date: None,
            duration: None,
            page: 1,
        }
    }
}

/// 过滤选项（从网页解析）
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiFilterOptions {
    pub genres: Vec<ApiFilterOption>,
    pub tags: Vec<ApiTagGroup>,
    pub sorts: Vec<ApiFilterOption>,
    pub years: Vec<ApiFilterOption>,
    pub durations: Vec<ApiFilterOption>,
}

/// 单个过滤选项
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiFilterOption {
    pub value: String,
    pub label: String,
}

/// 标签分组
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiTagGroup {
    pub name: String,
    pub tags: Vec<ApiFilterOption>,
}

// ============================================================================
// 评论相关模型
// ============================================================================

/// 评论
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiComment {
    pub id: String,
    pub user_name: String,
    pub user_avatar: Option<String>,
    pub content: String,
    pub time: String,
    pub likes: u32,
    pub dislikes: u32,
    pub replies: Vec<ApiComment>,
    pub has_more_replies: bool,
}

/// 评论列表结果
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiCommentList {
    pub comments: Vec<ApiComment>,
    pub total: u32,
    pub page: u32,
    pub has_next: bool,
}

// ============================================================================
// 用户相关模型
// ============================================================================

/// 用户信息
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiUserInfo {
    pub id: String,
    pub name: String,
    pub avatar_url: Option<String>,
    pub is_logged_in: bool,
}

/// 收藏/稀后观看列表结果
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiFavoriteList {
    pub videos: Vec<ApiVideoCard>,
    pub total: u32,
    pub page: u32,
    pub has_next: bool,
}

// ============================================================================
// 下载相关模型
// ============================================================================

/// 下载任务
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiDownloadTask {
    pub id: String,
    pub video_id: String,
    pub title: String,
    pub cover_url: String,
    pub cover_path: Option<String>,
    pub author_id: Option<String>,
    pub author_name: Option<String>,
    pub author_avatar_url: Option<String>,
    pub author_avatar_path: Option<String>,
    pub quality: String,
    pub description: Option<String>,
    pub tags: Vec<String>,
    pub status: ApiDownloadStatus,
    pub progress: f32,
    pub downloaded_bytes: u64,
    pub total_bytes: u64,
    pub speed: u64,
    pub created_at: i64,
    pub file_path: Option<String>,
}

/// 下载状态
#[derive(Debug, Clone)]
pub enum ApiDownloadStatus {
    Pending,
    Downloading,
    Paused,
    Completed,
    Failed { error: String },
}

// ============================================================================
// 播放历史模型
// ============================================================================

/// 播放历史记录
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiPlayHistory {
    pub video_id: String,
    pub title: String,
    pub cover_url: String,
    pub progress: f32, // 0.0 - 1.0
    pub duration: u32,
    pub last_played_at: i64,
}

/// 播放历史列表
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiPlayHistoryList {
    pub items: Vec<ApiPlayHistory>,
    pub total: u32,
    pub page: u32,
    pub has_next: bool,
}

// ============================================================================
// 设置相关模型
// ============================================================================

/// 应用设置
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiAppSettings {
    pub default_quality: String,
    pub download_concurrent: u32,
    pub proxy_url: Option<String>,
    pub theme_mode: String, // "system", "light", "dark"
    pub language: String,
}

impl Default for ApiAppSettings {
    fn default() -> Self {
        Self {
            default_quality: "1080p".to_string(),
            download_concurrent: 2,
            proxy_url: None,
            theme_mode: "system".to_string(),
            language: "zh".to_string(),
        }
    }
}

// ============================================================================
// 网络状态模型
// ============================================================================

/// 网络请求结果
#[derive(Debug, Clone)]
pub enum ApiResult<T> {
    Ok(T),
    Error { code: i32, message: String },
    NeedCloudflare { url: String },
    NeedLogin,
}

/// Cloudflare 验证请求
#[frb(dart_metadata=("freezed"))]
#[derive(Debug, Clone)]
pub struct ApiCloudflareChallenge {
    pub url: String,
    pub user_agent: String,
}
