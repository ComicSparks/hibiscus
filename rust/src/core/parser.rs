// HTML 解析模块

use scraper::{Html, Selector};
use anyhow::Result;

/// 视频卡片信息（内部使用）
#[derive(Debug, Clone)]
pub(crate) struct VideoCard {
    pub id: String,
    pub title: String,
    pub cover_url: String,
    pub duration: String,
    pub views: String,
    pub tags: Vec<String>,
    pub upload_date: Option<String>,
}

/// 搜索结果（内部使用）
#[derive(Debug, Clone)]
pub(crate) struct SearchPageResult {
    pub videos: Vec<VideoCard>,
    pub total_pages: i32,
    pub current_page: i32,
    pub has_next: bool,
}

/// 视频详情（内部使用）
#[derive(Debug, Clone)]
pub(crate) struct VideoDetail {
    pub id: String,
    pub title: String,
    pub description: String,
    pub cover_url: String,
    pub tags: Vec<String>,
    pub views: String,
    pub likes: String,
    pub upload_date: String,
    pub video_sources: Vec<VideoSource>,
    pub related_videos: Vec<VideoCard>,
    pub creator: Option<Creator>,
}

/// 视频源（内部使用）
#[derive(Debug, Clone)]
pub(crate) struct VideoSource {
    pub quality: String,
    pub url: String,
    pub format: String,
}

/// 创作者信息（内部使用）
#[derive(Debug, Clone)]
pub(crate) struct Creator {
    pub id: String,
    pub name: String,
    pub avatar_url: Option<String>,
}

/// 解析搜索结果页面
pub fn parse_search_page(html: &str) -> Result<SearchPageResult> {
    let document = Html::parse_document(html);
    
    // 选择器
    let video_card_selector = Selector::parse(".content-padding-new .card").unwrap();
    let title_selector = Selector::parse(".card-mobile-title, .card-title").unwrap();
    let cover_selector = Selector::parse("img").unwrap();
    let duration_selector = Selector::parse(".card-video-duration").unwrap();
    let views_selector = Selector::parse(".card-views").unwrap();
    let tag_selector = Selector::parse(".card-tag, .single-video-tag").unwrap();
    let pagination_selector = Selector::parse(".pagination").unwrap();
    
    let mut videos = Vec::new();
    
    for card in document.select(&video_card_selector) {
        // 获取链接和 ID
        let link = card.select(&Selector::parse("a").unwrap())
            .next()
            .and_then(|a| a.value().attr("href"));
        
        let id = link
            .and_then(|href| {
                // 从 /watch?v=xxx 提取 ID
                if href.contains("watch?v=") {
                    href.split("v=").nth(1).map(|s| s.split('&').next().unwrap_or(s))
                } else {
                    href.split('/').last()
                }
            })
            .unwrap_or("")
            .to_string();
        
        if id.is_empty() {
            continue;
        }
        
        // 标题
        let title = card.select(&title_selector)
            .next()
            .map(|el| el.text().collect::<String>().trim().to_string())
            .unwrap_or_default();
        
        // 封面
        let cover_url = card.select(&cover_selector)
            .next()
            .and_then(|img| {
                img.value().attr("data-src")
                    .or_else(|| img.value().attr("src"))
            })
            .unwrap_or("")
            .to_string();
        
        // 时长
        let duration = card.select(&duration_selector)
            .next()
            .map(|el| el.text().collect::<String>().trim().to_string())
            .unwrap_or_default();
        
        // 播放量
        let views = card.select(&views_selector)
            .next()
            .map(|el| el.text().collect::<String>().trim().to_string())
            .unwrap_or_default();
        
        // 标签
        let tags: Vec<String> = card.select(&tag_selector)
            .map(|el| el.text().collect::<String>().trim().to_string())
            .filter(|s| !s.is_empty())
            .collect();
        
        videos.push(VideoCard {
            id,
            title,
            cover_url,
            duration,
            views,
            tags,
            upload_date: None,
        });
    }
    
    // 解析分页
    let (current_page, total_pages, has_next) = if let Some(pagination) = document.select(&pagination_selector).next() {
        let active_selector = Selector::parse(".active").unwrap();
        let current = pagination.select(&active_selector)
            .next()
            .map(|el| el.text().collect::<String>().trim().parse::<i32>().unwrap_or(1))
            .unwrap_or(1);
        
        let page_link_selector = Selector::parse("a").unwrap();
        let max_page = pagination.select(&page_link_selector)
            .filter_map(|a| a.text().collect::<String>().trim().parse::<i32>().ok())
            .max()
            .unwrap_or(1);
        
        let next_selector = Selector::parse(".next:not(.disabled)").unwrap();
        let has_next = pagination.select(&next_selector).next().is_some();
        
        (current, max_page, has_next)
    } else {
        (1, 1, false)
    };
    
    Ok(SearchPageResult {
        videos,
        total_pages,
        current_page,
        has_next,
    })
}

/// 解析视频详情页面
pub fn parse_video_detail(html: &str) -> Result<VideoDetail> {
    let document = Html::parse_document(html);
    
    // 标题
    let title_selector = Selector::parse("h3.video-details-title, .video-title").unwrap();
    let title = document.select(&title_selector)
        .next()
        .map(|el| el.text().collect::<String>().trim().to_string())
        .unwrap_or_default();
    
    // 描述
    let desc_selector = Selector::parse(".video-details-description, .video-description").unwrap();
    let description = document.select(&desc_selector)
        .next()
        .map(|el| el.text().collect::<String>().trim().to_string())
        .unwrap_or_default();
    
    // 封面
    let cover_selector = Selector::parse("meta[property='og:image']").unwrap();
    let cover_url = document.select(&cover_selector)
        .next()
        .and_then(|el| el.value().attr("content"))
        .unwrap_or("")
        .to_string();
    
    // 标签
    let tag_selector = Selector::parse(".single-video-tag a, .video-tag").unwrap();
    let tags: Vec<String> = document.select(&tag_selector)
        .map(|el| el.text().collect::<String>().trim().to_string())
        .filter(|s| !s.is_empty())
        .collect();
    
    // 播放量和点赞
    let views_selector = Selector::parse(".video-views, .fa-eye").unwrap();
    let views = document.select(&views_selector)
        .next()
        .map(|el| {
            el.parent()
                .and_then(|p| p.value().as_element())
                .map(|_| el.text().collect::<String>().trim().to_string())
                .unwrap_or_default()
        })
        .unwrap_or_default();
    
    let likes_selector = Selector::parse(".video-likes, .fa-heart").unwrap();
    let likes = document.select(&likes_selector)
        .next()
        .map(|el| el.text().collect::<String>().trim().to_string())
        .unwrap_or_default();
    
    // 上传日期
    let date_selector = Selector::parse(".video-upload-date, .upload-date").unwrap();
    let upload_date = document.select(&date_selector)
        .next()
        .map(|el| el.text().collect::<String>().trim().to_string())
        .unwrap_or_default();
    
    // 视频源 - 从 JavaScript 或 data 属性中提取
    let video_sources = extract_video_sources(html);
    
    // 相关视频
    let related_selector = Selector::parse(".related-videos .card, .sidebar-video-card").unwrap();
    let related_videos = parse_video_cards(&document, &related_selector);
    
    // 创作者
    let creator_selector = Selector::parse(".video-creator a, .creator-link").unwrap();
    let creator = document.select(&creator_selector).next().map(|el| {
        Creator {
            id: el.value().attr("href")
                .unwrap_or("")
                .split('/')
                .last()
                .unwrap_or("")
                .to_string(),
            name: el.text().collect::<String>().trim().to_string(),
            avatar_url: None,
        }
    });
    
    // 从 URL 提取 ID
    let id_selector = Selector::parse("meta[property='og:url']").unwrap();
    let id = document.select(&id_selector)
        .next()
        .and_then(|el| el.value().attr("content"))
        .and_then(|url| url.split("v=").nth(1))
        .map(|s| s.split('&').next().unwrap_or(s))
        .unwrap_or("")
        .to_string();
    
    Ok(VideoDetail {
        id,
        title,
        description,
        cover_url,
        tags,
        views,
        likes,
        upload_date,
        video_sources,
        related_videos,
        creator,
    })
}

/// 从 HTML 中提取视频源 URL
fn extract_video_sources(html: &str) -> Vec<VideoSource> {
    let mut sources = Vec::new();
    
    // 尝试从 JavaScript 变量中提取
    // 常见模式: var videos = [...] 或 sources: [...]
    
    // 查找 m3u8 链接
    let m3u8_pattern = regex::Regex::new(r#"["']([^"']*\.m3u8[^"']*)["']"#).ok();
    if let Some(re) = m3u8_pattern {
        for cap in re.captures_iter(html) {
            if let Some(url) = cap.get(1) {
                let url_str = url.as_str().to_string();
                if !sources.iter().any(|s: &VideoSource| s.url == url_str) {
                    sources.push(VideoSource {
                        quality: guess_quality_from_url(&url_str),
                        url: url_str,
                        format: "m3u8".to_string(),
                    });
                }
            }
        }
    }
    
    // 查找 mp4 链接
    let mp4_pattern = regex::Regex::new(r#"["']([^"']*\.mp4[^"']*)["']"#).ok();
    if let Some(re) = mp4_pattern {
        for cap in re.captures_iter(html) {
            if let Some(url) = cap.get(1) {
                let url_str = url.as_str().to_string();
                if !sources.iter().any(|s: &VideoSource| s.url == url_str) {
                    sources.push(VideoSource {
                        quality: guess_quality_from_url(&url_str),
                        url: url_str,
                        format: "mp4".to_string(),
                    });
                }
            }
        }
    }
    
    sources
}

/// 从 URL 猜测视频质量
fn guess_quality_from_url(url: &str) -> String {
    if url.contains("1080") {
        "1080p".to_string()
    } else if url.contains("720") {
        "720p".to_string()
    } else if url.contains("480") {
        "480p".to_string()
    } else if url.contains("360") {
        "360p".to_string()
    } else {
        "auto".to_string()
    }
}

/// 解析视频卡片列表
fn parse_video_cards(document: &Html, selector: &Selector) -> Vec<VideoCard> {
    let title_selector = Selector::parse(".card-mobile-title, .card-title, .video-title").unwrap();
    let cover_selector = Selector::parse("img").unwrap();
    let duration_selector = Selector::parse(".card-video-duration, .duration").unwrap();
    
    let mut videos = Vec::new();
    
    for card in document.select(selector) {
        let link = card.select(&Selector::parse("a").unwrap())
            .next()
            .and_then(|a| a.value().attr("href"));
        
        let id = link
            .and_then(|href| {
                if href.contains("watch?v=") {
                    href.split("v=").nth(1).map(|s| s.split('&').next().unwrap_or(s))
                } else {
                    href.split('/').last()
                }
            })
            .unwrap_or("")
            .to_string();
        
        if id.is_empty() {
            continue;
        }
        
        let title = card.select(&title_selector)
            .next()
            .map(|el| el.text().collect::<String>().trim().to_string())
            .unwrap_or_default();
        
        let cover_url = card.select(&cover_selector)
            .next()
            .and_then(|img| img.value().attr("data-src").or_else(|| img.value().attr("src")))
            .unwrap_or("")
            .to_string();
        
        let duration = card.select(&duration_selector)
            .next()
            .map(|el| el.text().collect::<String>().trim().to_string())
            .unwrap_or_default();
        
        videos.push(VideoCard {
            id,
            title,
            cover_url,
            duration,
            views: String::new(),
            tags: Vec::new(),
            upload_date: None,
        });
    }
    
    videos
}

/// 解析首页
pub fn parse_homepage(html: &str) -> Result<Vec<(String, Vec<VideoCard>)>> {
    let document = Html::parse_document(html);
    let mut sections = Vec::new();
    
    // 解析各个分区
    let section_selector = Selector::parse(".home-rows-videos-wrapper, .video-section").unwrap();
    let section_title_selector = Selector::parse("h4, .section-title").unwrap();
    let card_selector = Selector::parse(".card, .video-card").unwrap();
    
    for section in document.select(&section_selector) {
        let title = section.select(&section_title_selector)
            .next()
            .map(|el| el.text().collect::<String>().trim().to_string())
            .unwrap_or_else(|| "推薦".to_string());
        
        let videos = parse_video_cards(&Html::parse_fragment(&section.html()), &card_selector);
        
        if !videos.is_empty() {
            sections.push((title, videos));
        }
    }
    
    Ok(sections)
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_guess_quality() {
        assert_eq!(guess_quality_from_url("video_1080p.mp4"), "1080p");
        assert_eq!(guess_quality_from_url("video_720.m3u8"), "720p");
        assert_eq!(guess_quality_from_url("video.mp4"), "auto");
    }
}
