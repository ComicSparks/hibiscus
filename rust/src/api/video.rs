// 视频详情相关 API

use flutter_rust_bridge::frb;
use crate::api::models::{
    ApiVideoDetail, ApiVideoQuality, ApiAuthorInfo, ApiCommentList, 
    ApiComment, ApiVideoCard, ApiPlaylistInfo, ApiMyListInfo, ApiMyListItem
};
use crate::core::network;
use crate::core::parser;

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
                duration: None, // 从页面解析
                views: Some(detail.views).filter(|s| !s.is_empty()),
                likes: Some(detail.likes).filter(|s| !s.is_empty()),
                upload_date: Some(detail.upload_date).filter(|s| !s.is_empty()),
                author: detail.creator.map(|c| ApiAuthorInfo {
                    id: c.id,
                    name: c.name,
                    avatar_url: c.avatar_url,
                    is_subscribed: false,
                }),
                tags: detail.tags,
                qualities: detail.video_sources.into_iter().map(|s| ApiVideoQuality {
                    quality: s.quality,
                    url: s.url,
                }).collect(),
                series: None,
                related_videos: detail.related_videos.into_iter().map(|v| ApiVideoCard {
                    id: v.id,
                    title: v.title,
                    cover_url: v.cover_url,
                    duration: Some(v.duration).filter(|s| !s.is_empty()),
                    views: Some(v.views).filter(|s| !s.is_empty()),
                    upload_date: v.upload_date,
                    tags: v.tags,
                }).collect(),
                csrf_token: detail.csrf_token,
                current_user_id: detail.current_user_id,
                is_fav: detail.is_fav,
                fav_times: detail.fav_times,
                playlist: detail.playlist.map(|p| ApiPlaylistInfo {
                    name: p.name,
                    videos: p.videos.into_iter().map(|v| ApiVideoCard {
                        id: v.id,
                        title: v.title,
                        cover_url: v.cover_url,
                        duration: Some(v.duration).filter(|s| !s.is_empty()),
                        views: Some(v.views).filter(|s| !s.is_empty()),
                        upload_date: v.upload_date,
                        tags: v.tags,
                    }).collect(),
                }),
                my_list: detail.my_list.map(|m| ApiMyListInfo {
                    is_watch_later: m.is_watch_later,
                    items: m.items.into_iter().map(|i| ApiMyListItem {
                        code: i.code,
                        title: i.title,
                        is_selected: i.is_selected,
                    }).collect(),
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
    // TODO: 实现实际的评论获取逻辑
    Ok(ApiCommentList {
        comments: vec![
            ApiComment {
                id: "c1".to_string(),
                user_name: "用户1".to_string(),
                user_avatar: Some("https://via.placeholder.com/50x50".to_string()),
                content: "这是一条评论内容".to_string(),
                time: "2小时前".to_string(),
                likes: 10,
                dislikes: 1,
                replies: vec![],
                has_more_replies: false,
            },
        ],
        total: 50,
        page,
        has_next: page < 5,
    })
}

/// 获取视频播放地址
#[frb]
pub async fn get_video_url(video_id: String, quality: String) -> anyhow::Result<String> {
    // TODO: 实现实际的播放地址获取逻辑
    Ok(format!("https://example.com/video/{}/{}.m3u8", video_id, quality))
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

/// 添加视频到稀后观看
#[frb]
pub async fn add_to_watch_later(video_id: String) -> anyhow::Result<bool> {
    // TODO: 实现实际的稀后观看逻辑
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
pub async fn post_comment(video_id: String, content: String, reply_to: Option<String>) -> anyhow::Result<ApiComment> {
    // TODO: 实现实际的发表评论逻辑
    Ok(ApiComment {
        id: "new_comment".to_string(),
        user_name: "当前用户".to_string(),
        user_avatar: None,
        content,
        time: "刚刚".to_string(),
        likes: 0,
        dislikes: 0,
        replies: vec![],
        has_more_replies: false,
    })
}
