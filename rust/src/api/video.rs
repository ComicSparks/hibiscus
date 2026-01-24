// 视频详情相关 API

use crate::api::models::{
    ApiAuthorInfo, ApiComment, ApiCommentList, ApiMyListInfo, ApiMyListItem, ApiPlaylistInfo,
    ApiVideoCard, ApiVideoDetail, ApiVideoQuality,
};
use crate::core::{network, parser};
use flutter_rust_bridge::frb;
use urlencoding::encode;

/// 获取视频详情
#[frb]
pub async fn get_video_detail(video_id: String) -> anyhow::Result<ApiVideoDetail> {
    let url = format!("{}/watch?v={}", network::BASE_URL, video_id);
    tracing::info!("Getting video detail: {}", url);

    // 尝试发起网络请求
    match network::get(&url).await {
        Ok(html) => {
            // 解析 HTML
            let detail = parser::parse_video_detail(&html)?;

            // 转换为 API 模型
            Ok(ApiVideoDetail {
                id: detail.id,
                title: detail.title,
                chinese_title: detail.chinese_title,
                cover_url: detail.cover_url,
                description: Some(detail.description).filter(|s| !s.is_empty()),
                duration: detail.duration,
                views: Some(detail.views).filter(|s| !s.is_empty()),
                like_percent: detail.like_percent,
                dislike_percent: detail.like_percent.map(|p| 100u32.saturating_sub(p)),
                likes_count: detail.likes_count,
                dislikes_count: detail.dislikes_count,
                upload_date: Some(detail.upload_date).filter(|s| !s.is_empty()),
                author: detail.creator.map(|c| ApiAuthorInfo {
                    id: c.id,
                    name: c.name,
                    avatar_url: c.avatar_url,
                    is_subscribed: c.is_subscribed,
                }),
                tags: detail.tags,
                qualities: detail
                    .video_sources
                    .into_iter()
                    .map(|s| ApiVideoQuality {
                        quality: s.quality,
                        url: s.url,
                    })
                    .collect(),
                series: None,
                related_videos: detail
                    .related_videos
                    .into_iter()
                    .map(|v| ApiVideoCard {
                        id: v.id,
                        title: v.title,
                        cover_url: v.cover_url,
                        duration: Some(v.duration).filter(|s| !s.is_empty()),
                        views: Some(v.views).filter(|s| !s.is_empty()),
                        upload_date: v.upload_date,
                        author_name: v.artist,
                        tags: v.tags,
                    })
                    .collect(),
                form_token: detail.form_token,
                current_user_id: detail.current_user_id,
                is_fav: detail.is_fav,
                fav_times: detail.fav_times,
                playlist: detail.playlist.map(|p| ApiPlaylistInfo {
                    name: p.name,
                    videos: p
                        .videos
                        .into_iter()
                        .map(|v| ApiVideoCard {
                            id: v.id,
                            title: v.title,
                            cover_url: v.cover_url,
                            duration: Some(v.duration).filter(|s| !s.is_empty()),
                            views: Some(v.views).filter(|s| !s.is_empty()),
                            upload_date: v.upload_date,
                            author_name: v.artist,
                            tags: v.tags,
                        })
                        .collect(),
                }),
                my_list: detail.my_list.map(|m| ApiMyListInfo {
                    is_watch_later: m.is_watch_later,
                    items: m
                        .items
                        .into_iter()
                        .map(|i| ApiMyListItem {
                            code: i.code,
                            title: i.title,
                            is_selected: i.is_selected,
                        })
                        .collect(),
                }),
            })
        }
        Err(e) => {
            let err_str = e.to_string();

            // 检查是否需要 Cloudflare 验证
            if err_str.contains("CLOUDFLARE_CHALLENGE") {
                return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
            }

            // 返回真实错误
            tracing::error!("Video detail error: {}", err_str);
            Err(e)
        }
    }
}

/// 获取视频评论
#[frb]
pub async fn get_video_comments(video_id: String, page: u32) -> anyhow::Result<ApiCommentList> {
    let url = format!(
        "{}/loadComment?type=video&id={}",
        network::BASE_URL,
        encode(&video_id)
    );
    tracing::info!("Getting video comments: {}", url);
    let body = network::get(&url).await?;
    let (_csrf_token, _current_user_id, comments) = parser::parse_video_comments(&body)?;

    let mapped = comments
        .into_iter()
        .map(|c| ApiComment {
            id: c.id,
            user_name: c.user_name,
            user_avatar: c.user_avatar,
            content: c.content,
            time: c.time,
            likes: c.likes,
            dislikes: 0,
            replies: vec![],
            has_more_replies: c.has_more_replies,
        })
        .collect::<Vec<_>>();

    Ok(ApiCommentList {
        total: mapped.len() as u32,
        comments: mapped,
        page,
        has_next: false,
    })
}

/// 获取评论的回复
#[frb]
pub async fn get_comment_replies(comment_id: String) -> anyhow::Result<Vec<ApiComment>> {
    let url = format!(
        "{}/loadReplies?id={}",
        network::BASE_URL,
        encode(&comment_id)
    );
    tracing::info!("Getting comment replies: {}", url);
    let body = network::get(&url).await?;
    let replies = parser::parse_comment_replies(&body)?;
    Ok(replies
        .into_iter()
        .map(|c| ApiComment {
            id: c.id,
            user_name: c.user_name,
            user_avatar: c.user_avatar,
            content: c.content,
            time: c.time,
            likes: c.likes,
            dislikes: 0,
            replies: vec![],
            has_more_replies: false,
        })
        .collect())
}

/// 获取视频播放地址
#[frb]
pub async fn get_video_url(video_id: String, quality: String) -> anyhow::Result<String> {
    // TODO: 实现实际的播放地址获取逻辑
    Ok(format!(
        "https://example.com/video/{}/{}.m3u8",
        video_id, quality
    ))
}

/// 添加视频到收藏
#[frb]
pub async fn add_to_favorites(video_id: String) -> anyhow::Result<bool> {
    // TODO: 实现实际的收藏逻辑
    Ok(true)
}

/// 从收藏移除视频
#[frb]
pub async fn remove_from_favorites(video_id: String) -> anyhow::Result<bool> {
    // TODO: 实现实际的移除收藏逻辑
    Ok(true)
}

/// 点赞评论
#[frb]
pub async fn like_comment(comment_id: String) -> anyhow::Result<bool> {
    // TODO: 实现实际的点赞逻辑
    Ok(true)
}

/// 发表评论
#[frb]
pub async fn post_comment(
    video_id: String,
    content: String,
    reply_to: Option<String>,
) -> anyhow::Result<ApiComment> {
    if let Some(reply_id) = reply_to.filter(|s| !s.trim().is_empty()) {
        let watch_url = format!("{}/watch?v={}", network::BASE_URL, video_id);
        let html = network::get(&watch_url).await?;
        let detail = parser::parse_video_detail(&html)?;
        let Some(form_token) = detail.form_token else {
            return Err(anyhow::anyhow!("Missing form token"));
        };
        let body = format!(
            "_token={}&reply-comment-id={}&reply-comment-text={}",
            encode(&form_token),
            encode(&reply_id),
            encode(&content)
        );
        let _ = network::post_with_x_csrf_token(
            &format!("{}/replyComment", network::BASE_URL),
            &body,
            &form_token,
        )
        .await?;
        return Ok(ApiComment {
            id: "reply".to_string(),
            user_name: "你".to_string(),
            user_avatar: None,
            content,
            time: "刚刚".to_string(),
            likes: 0,
            dislikes: 0,
            replies: vec![],
            has_more_replies: false,
        });
    }

    // 发布主评论：需要当前用户 id 与 form token（来自 watch 页面）
    let watch_url = format!("{}/watch?v={}", network::BASE_URL, video_id);
    let html = network::get(&watch_url).await?;
    let detail = parser::parse_video_detail(&html)?;
    let Some(form_token) = detail.form_token else {
        return Err(anyhow::anyhow!("Missing form token"));
    };
    let Some(current_user_id) = detail.current_user_id else {
        return Err(anyhow::anyhow!("Not logged in"));
    };

    let body = format!(
        "_token={}&comment-user-id={}&comment-type=video&comment-foreign-id={}&comment-text={}&comment-count=1&comment-is-political=0",
        encode(&form_token),
        encode(&current_user_id),
        encode(&detail.id),
        encode(&content),
    );
    let _ = network::post_with_x_csrf_token(
        &format!("{}/createComment", network::BASE_URL),
        &body,
        &form_token,
    )
    .await?;

    Ok(ApiComment {
        id: "new".to_string(),
        user_name: "你".to_string(),
        user_avatar: None,
        content,
        time: "刚刚".to_string(),
        likes: 0,
        dislikes: 0,
        replies: vec![],
        has_more_replies: false,
    })
}
