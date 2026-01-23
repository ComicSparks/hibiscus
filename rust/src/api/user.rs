// 用户相关 API

use flutter_rust_bridge::frb;
use crate::api::models::{ApiUserInfo, ApiFavoriteList, ApiPlayHistoryList, ApiPlayHistory};

/// 获取当前用户信息
#[frb]
pub async fn get_current_user() -> anyhow::Result<Option<ApiUserInfo>> {
    // TODO: 从持久化存储获取用户信息
    Ok(None)
}

/// 检查登录状态
#[frb]
pub async fn is_logged_in() -> anyhow::Result<bool> {
    // TODO: 检查 Cookie 是否有效
    Ok(false)
}

/// 登出
#[frb]
pub async fn logout() -> anyhow::Result<bool> {
    // TODO: 清除登录 Cookie
    Ok(true)
}

/// 获取收藏列表
#[frb]
pub async fn get_favorites(page: u32) -> anyhow::Result<ApiFavoriteList> {
    // TODO: 从 API 获取收藏列表
    Ok(ApiFavoriteList {
        videos: vec![],
        total: 0,
        page,
        has_next: false,
    })
}

/// 获取稀后观看列表
#[frb]
pub async fn get_watch_later(page: u32) -> anyhow::Result<ApiFavoriteList> {
    // TODO: 从 API 获取稀后观看列表
    Ok(ApiFavoriteList {
        videos: vec![],
        total: 0,
        page,
        has_next: false,
    })
}

/// 获取订阅作者列表
#[frb]
pub async fn get_subscribed_authors() -> anyhow::Result<Vec<crate::api::models::ApiAuthorInfo>> {
    // TODO: 从 API 获取订阅作者列表
    Ok(vec![])
}

/// 订阅作者
#[frb]
pub async fn subscribe_author(author_id: String) -> anyhow::Result<bool> {
    // TODO: 实现订阅逻辑
    Ok(true)
}

/// 取消订阅作者
#[frb]
pub async fn unsubscribe_author(author_id: String) -> anyhow::Result<bool> {
    // TODO: 实现取消订阅逻辑
    Ok(true)
}

// ============================================================================
// 播放历史（本地存储）
// ============================================================================

/// 获取播放历史
#[frb]
pub async fn get_play_history(page: u32, page_size: u32) -> anyhow::Result<ApiPlayHistoryList> {
    // TODO: 从本地数据库获取播放历史
    Ok(ApiPlayHistoryList {
        items: vec![],
        total: 0,
        page,
        has_next: false,
    })
}

/// 添加/更新播放历史
#[frb]
pub async fn update_play_history(
    video_id: String,
    title: String,
    cover_url: String,
    progress: f32,
    duration: u32,
) -> anyhow::Result<bool> {
    // TODO: 保存到本地数据库
    Ok(true)
}

/// 删除单条播放历史
#[frb]
pub async fn delete_play_history(video_id: String) -> anyhow::Result<bool> {
    // TODO: 从数据库删除
    Ok(true)
}

/// 清空播放历史
#[frb]
pub async fn clear_play_history() -> anyhow::Result<bool> {
    // TODO: 清空数据库表
    Ok(true)
}

/// 获取视频的播放进度
#[frb]
pub async fn get_video_progress(video_id: String) -> anyhow::Result<Option<ApiPlayHistory>> {
    // TODO: 从数据库查询
    Ok(None)
}

// ============================================================================
// Cookie 管理
// ============================================================================

/// 设置 Cookie（从 WebView 导入）
#[frb]
pub async fn set_cookies(cookies: Vec<(String, String)>) -> anyhow::Result<bool> {
    // TODO: 保存 Cookie 到持久化存储，并注入 reqwest CookieJar
    Ok(true)
}

/// 设置 Cloudflare Cookie
#[frb]
pub async fn set_cf_clearance(cookie_value: String) -> anyhow::Result<bool> {
    // TODO: 保存 cf_clearance Cookie
    Ok(true)
}

/// 获取需要 Cloudflare 验证时的 URL 和 User-Agent
#[frb]
pub async fn get_cloudflare_challenge_info() -> anyhow::Result<Option<crate::api::models::ApiCloudflareChallenge>> {
    // TODO: 返回当前需要验证的信息
    Ok(None)
}
