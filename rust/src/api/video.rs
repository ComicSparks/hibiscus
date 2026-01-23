// 视频详情相关 API

use flutter_rust_bridge::frb;
use crate::api::models::{ApiVideoDetail, ApiVideoQuality, ApiAuthorInfo, ApiCommentList, ApiComment, ApiVideoCard};
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
            })
        }
        Err(e) => {
            let err_str = e.to_string();
            
            // 检查是否需要 Cloudflare 验证
            if err_str.contains("CLOUDFLARE_CHALLENGE") {
                return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
            }
            
            // 其他错误，返回模拟数据
            tracing::warn!("Network error, returning mock data: {}", err_str);
            
            Ok(ApiVideoDetail {
                id: video_id.clone(),
                title: "示例视频标题".to_string(),
                cover_url: "https://via.placeholder.com/640x360".to_string(),
                description: Some("这是视频的详细描述内容...".to_string()),
                duration: Some("24:30".to_string()),
                views: Some("12.3K".to_string()),
                likes: Some("1.2K".to_string()),
                upload_date: Some("2024-01-15".to_string()),
                author: Some(ApiAuthorInfo {
                    id: "author1".to_string(),
                    name: "示例作者".to_string(),
                    avatar_url: Some("https://via.placeholder.com/100x100".to_string()),
                    is_subscribed: false,
                }),
                tags: vec!["标签1".to_string(), "标签2".to_string(), "标签3".to_string()],
                qualities: vec![
                    ApiVideoQuality {
                        quality: "1080p".to_string(),
                        url: "https://example.com/video_1080p.m3u8".to_string(),
                    },
                    ApiVideoQuality {
                        quality: "720p".to_string(),
                        url: "https://example.com/video_720p.m3u8".to_string(),
                    },
                ],
                series: None,
                related_videos: vec![],
            })
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
