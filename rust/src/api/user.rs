// 用户相关 API

use flutter_rust_bridge::frb;
use crate::api::models::{ApiUserInfo, ApiFavoriteList, ApiPlayHistoryList, ApiPlayHistory, ApiVideoCard, ApiCloudflareChallenge};
use crate::core::network;
use crate::core::parser;

/// 列表类型常量
pub const LIST_TYPE_LIKE: &str = "LL";       // 喜欢的影片
pub const LIST_TYPE_WATCH_LATER: &str = "WL"; // 稍后观看
pub const LIST_TYPE_SAVE: &str = "SL";        // 已保存

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

/// 获取收藏列表 (喜欢的影片)
#[frb]
pub async fn get_favorites(page: u32) -> anyhow::Result<ApiFavoriteList> {
    get_my_list(LIST_TYPE_LIKE.to_string(), page).await
}

/// 获取稍后观看列表
#[frb]
pub async fn get_watch_later(page: u32) -> anyhow::Result<ApiFavoriteList> {
    get_my_list(LIST_TYPE_WATCH_LATER.to_string(), page).await
}

/// 获取我的列表
#[frb]
pub async fn get_my_list(list_type: String, page: u32) -> anyhow::Result<ApiFavoriteList> {
    let url = format!("{}/playlist?list={}&page={}", network::BASE_URL, list_type, page);
    tracing::info!("Getting my list: {}", url);
    
    match network::get(&url).await {
        Ok(html) => {
            let result = parser::parse_my_list_items(&html)?;
            
            let videos: Vec<ApiVideoCard> = result.videos.into_iter().map(|v| ApiVideoCard {
                id: v.id,
                title: v.title,
                cover_url: v.cover_url,
                duration: Some(v.duration).filter(|s| !s.is_empty()),
                views: Some(v.views).filter(|s| !s.is_empty()),
                upload_date: v.upload_date,
                tags: v.tags,
            }).collect();
            
            let has_next = videos.len() >= 20; // 假设每页20个
            
            Ok(ApiFavoriteList {
                videos,
                total: 0, // 无法从页面获取总数
                page,
                has_next,
            })
        }
        Err(e) => {
            let err_str = e.to_string();
            if err_str.contains("CLOUDFLARE_CHALLENGE") {
                return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
            }
            
            Ok(ApiFavoriteList {
                videos: vec![],
                total: 0,
                page,
                has_next: false,
            })
        }
    }
}

/// 添加到收藏
#[frb]
pub async fn add_to_favorites(video_code: String, csrf_token: String, user_id: String) -> anyhow::Result<bool> {
    let url = format!("{}/like", network::BASE_URL);
    let body = format!(
        "like-foreign-id={}&like-status=1&_token={}&like-user-id={}&like-is-positive=1",
        video_code, csrf_token, user_id
    );
    
    match network::post_with_csrf(&url, &body, &csrf_token).await {
        Ok(_) => Ok(true),
        Err(e) => {
            let err_str = e.to_string();
            if err_str.contains("CLOUDFLARE_CHALLENGE") {
                return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
            }
            Err(e)
        }
    }
}

/// 从收藏移除
#[frb]
pub async fn remove_from_favorites(video_code: String, csrf_token: String, user_id: String) -> anyhow::Result<bool> {
    let url = format!("{}/like", network::BASE_URL);
    let body = format!(
        "like-foreign-id={}&like-status=0&_token={}&like-user-id={}&like-is-positive=1",
        video_code, csrf_token, user_id
    );
    
    match network::post_with_csrf(&url, &body, &csrf_token).await {
        Ok(_) => Ok(true),
        Err(e) => {
            let err_str = e.to_string();
            if err_str.contains("CLOUDFLARE_CHALLENGE") {
                return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
            }
            Err(e)
        }
    }
}

/// 添加/移除稍后观看
#[frb]
pub async fn toggle_watch_later(
    video_code: String, 
    list_code: String,
    is_checked: bool,
    csrf_token: String,
    user_id: String,
) -> anyhow::Result<bool> {
    let url = format!("{}/save", network::BASE_URL);
    let body = format!(
        "_token={}&input_id={}&video_id={}&is_checked={}&user_id={}",
        csrf_token, list_code, video_code, is_checked, user_id
    );
    
    match network::post_with_csrf(&url, &body, &csrf_token).await {
        Ok(_) => Ok(true),
        Err(e) => {
            let err_str = e.to_string();
            if err_str.contains("CLOUDFLARE_CHALLENGE") {
                return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
            }
            Err(e)
        }
    }
}

/// 从列表删除视频
#[frb]
pub async fn delete_from_list(
    list_type: String,
    video_code: String,
    csrf_token: String,
) -> anyhow::Result<bool> {
    let url = format!("{}/deletePlayitem", network::BASE_URL);
    let body = format!(
        "playlist_id={}&video_id={}&count=1",
        list_type, video_code
    );
    
    match network::post_with_csrf(&url, &body, &csrf_token).await {
        Ok(_) => Ok(true),
        Err(e) => {
            let err_str = e.to_string();
            if err_str.contains("CLOUDFLARE_CHALLENGE") {
                return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
            }
            Err(e)
        }
    }
}

/// 获取订阅作者列表
#[frb]
pub async fn get_subscribed_authors(page: u32) -> anyhow::Result<Vec<crate::api::models::ApiAuthorInfo>> {
    let url = format!("{}/subscriptions?page={}", network::BASE_URL, page);
    tracing::info!("Getting subscriptions: {}", url);
    
    // TODO: 实现解析订阅页面
    match network::get(&url).await {
        Ok(_html) => {
            // TODO: 解析订阅列表
            Ok(vec![])
        }
        Err(e) => {
            let err_str = e.to_string();
            if err_str.contains("CLOUDFLARE_CHALLENGE") {
                return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
            }
            Ok(vec![])
        }
    }
}

/// 订阅作者
#[frb]
pub async fn subscribe_author(
    artist_id: String,
    user_id: String,
    csrf_token: String,
) -> anyhow::Result<bool> {
    let url = format!("{}/subscribe", network::BASE_URL);
    let body = format!(
        "_token={}&subscribe-user-id={}&subscribe-artist-id={}&subscribe-status=1",
        csrf_token, user_id, artist_id
    );
    
    match network::post_with_csrf(&url, &body, &csrf_token).await {
        Ok(_) => Ok(true),
        Err(e) => {
            let err_str = e.to_string();
            if err_str.contains("CLOUDFLARE_CHALLENGE") {
                return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
            }
            Err(e)
        }
    }
}

/// 取消订阅作者
#[frb]
pub async fn unsubscribe_author(
    artist_id: String,
    user_id: String,
    csrf_token: String,
) -> anyhow::Result<bool> {
    let url = format!("{}/subscribe", network::BASE_URL);
    let body = format!(
        "_token={}&subscribe-user-id={}&subscribe-artist-id={}&subscribe-status=0",
        csrf_token, user_id, artist_id
    );
    
    match network::post_with_csrf(&url, &body, &csrf_token).await {
        Ok(_) => Ok(true),
        Err(e) => {
            let err_str = e.to_string();
            if err_str.contains("CLOUDFLARE_CHALLENGE") {
                return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
            }
            Err(e)
        }
    }
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
    network::set_cookies(&format!("cf_clearance={}", cookie_value))?;
    Ok(true)
}

/// 获取需要 Cloudflare 验证时的 URL 和 User-Agent
#[frb]
pub async fn get_cloudflare_challenge_info() -> anyhow::Result<Option<ApiCloudflareChallenge>> {
    // TODO: 返回当前需要验证的信息
    Ok(Some(ApiCloudflareChallenge {
        url: network::BASE_URL.to_string(),
        user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36".to_string(),
    }))
}

// ============================================================================
// 登录相关
// ============================================================================

/// 获取登录页面的 CSRF Token
#[frb]
pub async fn get_login_csrf_token() -> anyhow::Result<String> {
    let url = format!("{}/login", network::BASE_URL);
    tracing::info!("Getting login page: {}", url);
    
    match network::get(&url).await {
        Ok(html) => {
            // 解析 _token
            let document = scraper::Html::parse_document(&html);
            let selector = scraper::Selector::parse("input[name=_token]").unwrap();
            
            let token = document.select(&selector).next()
                .and_then(|el| el.value().attr("value"))
                .map(|s| s.to_string())
                .ok_or_else(|| anyhow::anyhow!("Cannot find CSRF token"))?;
            
            Ok(token)
        }
        Err(e) => {
            let err_str = e.to_string();
            if err_str.contains("CLOUDFLARE_CHALLENGE") {
                return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
            }
            Err(e)
        }
    }
}

/// 登录
#[frb]
pub async fn login(email: String, password: String, csrf_token: String) -> anyhow::Result<bool> {
    let url = format!("{}/login", network::BASE_URL);
    let body = format!(
        "_token={}&email={}&password={}",
        urlencoding::encode(&csrf_token),
        urlencoding::encode(&email),
        urlencoding::encode(&password)
    );
    
    match network::post_with_csrf(&url, &body, &csrf_token).await {
        Ok(_) => {
            // 检查是否登录成功（再次访问 /login 应该返回 404 或重定向）
            match network::get(&format!("{}/login", network::BASE_URL)).await {
                Ok(html) => {
                    // 如果还能看到登录表单，说明登录失败
                    if html.contains("input[name=_token]") {
                        Ok(false)
                    } else {
                        Ok(true)
                    }
                }
                Err(_) => Ok(true), // 404 或重定向说明已登录
            }
        }
        Err(e) => {
            let err_str = e.to_string();
            if err_str.contains("CLOUDFLARE_CHALLENGE") {
                return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
            }
            Err(e)
        }
    }
}
