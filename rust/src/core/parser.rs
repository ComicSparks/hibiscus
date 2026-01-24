// HTML 解析模块
// 参考 Han1meViewer 的 Parser.kt 实现

use anyhow::Result;
use once_cell::sync::Lazy;
use regex::Regex;
use scraper::{ElementRef, Html, Selector};
use serde_json::Value;

// ============================================================================
// 正则表达式
// ============================================================================

static VIDEO_SOURCE_REGEX: Lazy<Regex> =
    Lazy::new(|| Regex::new(r#"const source = '([^']+)'"#).unwrap());

static VIEW_AND_DATE_REGEX: Lazy<Regex> =
    Lazy::new(|| Regex::new(r#"(觀看次數|观看次数)：(.+?)次\s*(\d{4}-\d{2}-\d{2})"#).unwrap());

static VIDEO_CODE_REGEX: Lazy<Regex> = Lazy::new(|| Regex::new(r#"watch\?v=(\d+)"#).unwrap());

static DIGITS_REGEX: Lazy<Regex> = Lazy::new(|| Regex::new(r#"\d+"#).unwrap());

// ============================================================================
// 内部数据结构
// ============================================================================

/// 视频卡片信息（内部使用）
#[derive(Debug, Clone)]
pub(crate) struct VideoCard {
    pub id: String,
    pub title: String,
    pub cover_url: String,
    pub duration: String,
    pub views: String,
    pub artist: Option<String>,
    pub upload_time: Option<String>,
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
    pub chinese_title: Option<String>,
    pub description: String,
    pub cover_url: String,
    pub duration: Option<String>,
    pub tags: Vec<String>,
    pub views: String,
    pub likes_count: Option<u32>,
    pub dislikes_count: Option<u32>,
    pub like_percent: Option<u32>,
    pub upload_date: String,
    pub video_sources: Vec<VideoSource>,
    pub related_videos: Vec<VideoCard>,
    pub creator: Option<Creator>,
    pub form_token: Option<String>,
    pub current_user_id: Option<String>,
    pub is_fav: bool,
    pub fav_times: Option<i32>,
    pub playlist: Option<Playlist>,
    pub my_list: Option<MyListInfo>,
}

#[derive(Debug, Clone)]
pub(crate) struct ParsedComment {
    pub id: String,
    pub user_name: String,
    pub user_avatar: Option<String>,
    pub time: String,
    pub content: String,
    pub likes: u32,
    pub has_more_replies: bool,
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
    pub genre: Option<String>,
    pub is_subscribed: bool,
}

/// 播放列表信息
#[derive(Debug, Clone)]
pub(crate) struct Playlist {
    pub name: Option<String>,
    pub videos: Vec<VideoCard>,
}

/// 我的列表信息
#[derive(Debug, Clone)]
pub(crate) struct MyListInfo {
    pub is_watch_later: bool,
    pub items: Vec<MyListItem>,
}

#[derive(Debug, Clone)]
pub(crate) struct MyListItem {
    pub code: String,
    pub title: String,
    pub is_selected: bool,
}

/// 首页数据
#[derive(Debug, Clone)]
pub(crate) struct HomePage {
    pub form_token: Option<String>,
    pub avatar_url: Option<String>,
    pub username: Option<String>,
    pub banner: Option<Banner>,
    pub latest_release: Vec<VideoCard>,
    pub latest_upload: Vec<VideoCard>,
    pub sections: Vec<(String, Vec<VideoCard>)>,
}

#[derive(Debug, Clone)]
pub(crate) struct Banner {
    pub title: String,
    pub description: Option<String>,
    pub pic_url: String,
    pub video_code: Option<String>,
}

/// 收藏列表项
#[derive(Debug, Clone)]
pub(crate) struct MyListItems {
    pub videos: Vec<VideoCard>,
    pub form_token: Option<String>,
    pub description: Option<String>,
}

// ============================================================================
// 解析函数
// ============================================================================

/// 解析搜索结果页面
pub fn parse_search_page(html: &str) -> Result<SearchPageResult> {
    let document = Html::parse_document(html);

    // 尝试解析正常版视频列表
    let content_selector = Selector::parse(".content-padding-new").unwrap();
    if let Some(content) = document.select(&content_selector).next() {
        return parse_search_normal(&content, &document);
    }

    // 尝试解析简化版视频列表
    let simplified_selector = Selector::parse(".home-rows-videos-wrapper").unwrap();
    if let Some(content) = document.select(&simplified_selector).next() {
        return parse_search_simplified(&content, &document);
    }

    Ok(SearchPageResult {
        videos: vec![],
        total_pages: 1,
        current_page: 1,
        has_next: false,
    })
}

/// 解析正常版搜索结果
fn parse_search_normal(content: &ElementRef, document: &Html) -> Result<SearchPageResult> {
    let card_selector = Selector::parse("div[class^=horizontal-card]").unwrap();
    let mut videos = Vec::new();

    for card in content.select(&card_selector) {
        if let Some(video) = parse_normal_video_item(&card) {
            videos.push(video);
        }
    }

    let (current_page, total_pages, has_next) = parse_pagination(document);

    Ok(SearchPageResult {
        videos,
        total_pages,
        current_page,
        has_next,
    })
}

/// 解析简化版搜索结果
fn parse_search_simplified(content: &ElementRef, document: &Html) -> Result<SearchPageResult> {
    let a_selector = Selector::parse("a").unwrap();
    let mut videos = Vec::new();

    for item in content.select(&a_selector) {
        if let Some(video) = parse_simplified_video_item(&item) {
            videos.push(video);
        }
    }

    let (current_page, total_pages, has_next) = parse_pagination(document);

    Ok(SearchPageResult {
        videos,
        total_pages,
        current_page,
        has_next,
    })
}

/// 解析正常版视频卡片
fn parse_normal_video_item(card: &ElementRef) -> Option<VideoCard> {
    // 标题
    let title_selector = Selector::parse("div[class=title]").unwrap();
    let title = card
        .select(&title_selector)
        .next()
        .map(|el| el.text().collect::<String>().trim().to_string())?;

    // 封面
    let img_selector = Selector::parse("img").unwrap();
    let cover_url = card
        .select(&img_selector)
        .next()
        .and_then(|img| {
            img.value()
                .attr("src")
                .or_else(|| img.value().attr("data-src"))
        })
        .map(|s| make_absolute_url(s))?;

    // 视频链接和 ID
    let a_selector = Selector::parse("a").unwrap();
    let href = card
        .select(&a_selector)
        .next()
        .and_then(|a| a.value().attr("href"))?;
    let id = extract_video_code(href)?;

    // 时长和播放量
    let thumb_selector = Selector::parse("div[class^=thumb-container]").unwrap();
    let (duration, views) = if let Some(thumb) = card.select(&thumb_selector).next() {
        let duration_selector = Selector::parse("div[class^=duration]").unwrap();
        let duration = thumb
            .select(&duration_selector)
            .next()
            .map(|el| el.text().collect::<String>().trim().to_string())
            .unwrap_or_default();

        let stat_selector = Selector::parse("div[class^=stat-item]").unwrap();
        let stats: Vec<_> = thumb.select(&stat_selector).collect();
        let views = stats
            .get(1)
            .map(|el| el.text().collect::<String>().trim().to_string())
            .unwrap_or_default();

        (duration, views)
    } else {
        (String::new(), String::new())
    };

    // 作者和上传时间
    let subtitle_selector = Selector::parse("div.subtitle a").unwrap();
    let subtitle_text = card
        .select(&subtitle_selector)
        .next()
        .map(|el| el.text().collect::<String>().trim().to_string())
        .unwrap_or_default();

    let (artist, upload_time) = if subtitle_text.contains('•') {
        let parts: Vec<_> = subtitle_text
            .split('•')
            .map(|s| s.trim().to_string())
            .collect();
        (parts.get(0).cloned(), parts.get(1).cloned())
    } else {
        (Some(subtitle_text).filter(|s| !s.is_empty()), None)
    };

    Some(VideoCard {
        id,
        title,
        cover_url,
        duration,
        views,
        artist,
        upload_time,
        tags: vec![],
        upload_date: None,
    })
}

/// 解析简化版视频卡片
fn parse_simplified_video_item(item: &ElementRef) -> Option<VideoCard> {
    let href = item.value().attr("href")?;
    let id = extract_video_code(href)?;

    let img_selector = Selector::parse("img").unwrap();
    let cover_url = item
        .select(&img_selector)
        .next()
        .and_then(|img| img.value().attr("src"))
        .map(|s| make_absolute_url(s))?;

    let title_selector = Selector::parse("div.home-rows-videos-title").unwrap();
    let title = item
        .select(&title_selector)
        .next()
        .map(|el| el.text().collect::<String>().trim().to_string())?;

    Some(VideoCard {
        id,
        title,
        cover_url,
        duration: String::new(),
        views: String::new(),
        artist: None,
        upload_time: None,
        tags: vec![],
        upload_date: None,
    })
}

/// 解析分页信息
fn parse_pagination(document: &Html) -> (i32, i32, bool) {
    let pagination_selector = Selector::parse(".pagination").unwrap();

    if let Some(pagination) = document.select(&pagination_selector).next() {
        let active_selector = Selector::parse(".active").unwrap();
        let current = pagination
            .select(&active_selector)
            .next()
            .map(|el| {
                el.text()
                    .collect::<String>()
                    .trim()
                    .parse::<i32>()
                    .unwrap_or(1)
            })
            .unwrap_or(1);

        let link_selector = Selector::parse("a").unwrap();
        let max_page = pagination
            .select(&link_selector)
            .filter_map(|a| a.text().collect::<String>().trim().parse::<i32>().ok())
            .max()
            .unwrap_or(1);
        let has_next = current < max_page;

        (current, max_page, has_next)
    } else {
        (1, 1, false)
    }
}

/// 解析视频详情页面
pub fn parse_video_detail(html: &str) -> Result<VideoDetail> {
    let document = Html::parse_document(html);

    // HTML 表单 token：input[name=_token]
    let token_selector_subscribe =
        Selector::parse("#video-subscribe-form input[name=_token]").unwrap();
    let token_selector_any = Selector::parse("input[name=_token]").unwrap();
    let form_token = document
        .select(&token_selector_subscribe)
        .next()
        .or_else(|| document.select(&token_selector_any).next())
        .and_then(|el| el.value().attr("value"))
        .map(|s| s.to_string());

    // 当前用户 ID
    let user_id_selector_subscribe =
        Selector::parse("#video-subscribe-form input[name=subscribe-user-id]").unwrap();
    let user_id_selector_like = Selector::parse("input[name=like-user-id]").unwrap();
    let current_user_id = document
        .select(&user_id_selector_subscribe)
        .next()
        .or_else(|| document.select(&user_id_selector_like).next())
        .and_then(|el| el.value().attr("value"))
        .map(|s| s.to_string());

    // 标题
    let title_selector = Selector::parse("#shareBtn-title").unwrap();
    let title = document
        .select(&title_selector)
        .next()
        .map(|el| el.text().collect::<String>().trim().to_string())
        .unwrap_or_default();

    // 收藏状态
    let like_status_selector = Selector::parse("[name=like-status]").unwrap();
    let is_fav = document
        .select(&like_status_selector)
        .next()
        .and_then(|el| el.value().attr("value"))
        .and_then(|v| v.parse::<i32>().ok())
        .map(|v| v == 1)
        .unwrap_or(false);

    // 收藏数
    let likes_count_selector = Selector::parse("input[name=likes-count]").unwrap();
    let fav_times = document
        .select(&likes_count_selector)
        .next()
        .and_then(|el| el.value().attr("value"))
        .and_then(|v| v.parse::<i32>().ok());

    // 视频详情区域
    let detail_wrapper_selector = Selector::parse("div.video-details-wrapper").unwrap();
    let (chinese_title, description) =
        if let Some(wrapper) = document.select(&detail_wrapper_selector).next() {
            parse_video_details_caption(&wrapper)
        } else {
            (None, String::new())
        };

    let (views, upload_date) = parse_views_and_upload_date(&document);

    // 时长（秒）
    let duration = parse_duration(&document);

    // 点赞/踩（计数 + 百分比）
    let (likes_count, dislikes_count, like_percent) = parse_like_stats(&document);

    // 封面
    let cover_selector = Selector::parse("meta[property='og:image']").unwrap();
    let cover_url = document
        .select(&cover_selector)
        .next()
        .and_then(|el| el.value().attr("content"))
        .map(|s| s.to_string())
        .unwrap_or_default();

    // 标签
    let tag_selector = Selector::parse(".single-video-tag a").unwrap();
    let tags: Vec<String> = document
        .select(&tag_selector)
        .map(|el| {
            let text = el.text().collect::<String>();
            // 移除括号内的数字，如 "標籤 (123)" -> "標籤"
            text.split('(')
                .next()
                .unwrap_or(&text)
                .trim()
                .trim_start_matches('#')
                .to_string()
        })
        .filter(|s| !s.is_empty())
        .collect();

    // 视频源
    let video_sources = parse_video_sources(&document, html);

    // 创作者
    let creator = parse_creator(&document);

    // 相关视频
    let related_videos = parse_related_videos(&document);

    // 播放列表
    let playlist = parse_playlist(&document);

    // 我的列表
    let my_list = parse_my_list(&document);

    // 从 URL 中获取 ID
    let url_selector = Selector::parse("meta[property='og:url']").unwrap();
    let id = document
        .select(&url_selector)
        .next()
        .and_then(|el| el.value().attr("content"))
        .and_then(|url| extract_video_code(url))
        .unwrap_or_default();

    Ok(VideoDetail {
        id,
        title,
        chinese_title,
        description,
        cover_url,
        tags,
        duration,
        views,
        likes_count,
        dislikes_count,
        like_percent,
        upload_date,
        video_sources,
        related_videos,
        creator,
        form_token,
        current_user_id,
        is_fav,
        fav_times,
        playlist,
        my_list,
    })
}

/// 解析视频详情信息（标题/简介）
fn parse_video_details_caption(wrapper: &ElementRef) -> (Option<String>, String) {
    let caption_selector = Selector::parse("div[class^=video-caption-text]").unwrap();

    let (chinese_title, description) =
        if let Some(caption) = wrapper.select(&caption_selector).next() {
            let desc = caption.text().collect::<String>().trim().to_string();
            // 中文标题在 caption 的前一个兄弟元素
            let chinese_title = None; // 需要更复杂的逻辑来获取
            (chinese_title, desc)
        } else {
            (None, String::new())
        };
    (chinese_title, description)
}

fn parse_views_and_upload_date(document: &Html) -> (String, String) {
    let sel = Selector::parse("div.video-details-wrapper").unwrap();
    for el in document.select(&sel) {
        let text = el.text().collect::<String>().replace('\u{a0}', " ");
        if let Some(caps) = VIEW_AND_DATE_REGEX.captures(&text) {
            let views = caps
                .get(2)
                .map(|m| m.as_str().trim().to_string())
                .unwrap_or_default();
            let date = caps
                .get(3)
                .map(|m| m.as_str().trim().to_string())
                .unwrap_or_default();
            if !views.is_empty() || !date.is_empty() {
                return (views, date);
            }
        }
    }
    (String::new(), String::new())
}

fn parse_duration(document: &Html) -> Option<String> {
    let sel = Selector::parse("meta[property='og:video:duration']").unwrap();
    let secs = document
        .select(&sel)
        .next()
        .and_then(|el| el.value().attr("content"))
        .and_then(|v| v.trim().parse::<u32>().ok());
    secs.map(format_duration)
}

fn format_duration(secs: u32) -> String {
    let h = secs / 3600;
    let m = (secs % 3600) / 60;
    let s = secs % 60;
    if h > 0 {
        format!("{h}:{m:02}:{s:02}")
    } else {
        format!("{m}:{s:02}")
    }
}

fn parse_like_stats(document: &Html) -> (Option<u32>, Option<u32>, Option<u32>) {
    let like_form = Selector::parse("#video-like-form").unwrap();
    let input_like = Selector::parse("input[name=likes-count]").unwrap();
    let input_unlike = Selector::parse("input[name=unlikes-count]").unwrap();
    if let Some(form) = document.select(&like_form).next() {
        let likes = form
            .select(&input_like)
            .next()
            .and_then(|el| el.value().attr("value"))
            .and_then(|v| v.parse::<u32>().ok());
        let unlikes = form
            .select(&input_unlike)
            .next()
            .and_then(|el| el.value().attr("value"))
            .and_then(|v| v.parse::<u32>().ok());
        let percent = match (likes, unlikes) {
            (Some(l), Some(u)) if l + u > 0 => {
                Some(((l as f64) * 100.0 / ((l + u) as f64)).round() as u32)
            }
            _ => None,
        };
        return (likes, unlikes, percent);
    }
    (None, None, None)
}

pub(crate) fn parse_video_comments(
    body: &str,
) -> Result<(Option<String>, Option<String>, Vec<ParsedComment>)> {
    let json: Value = serde_json::from_str(body)?;
    let comments_html = json
        .get("comments")
        .and_then(|v| v.as_str())
        .unwrap_or_default();
    let fragment = Html::parse_fragment(comments_html);

    let token_sel = Selector::parse("input[name=_token]").unwrap();
    let csrf_token = fragment
        .select(&token_sel)
        .next()
        .and_then(|el| el.value().attr("value"))
        .map(|s| s.to_string());

    let user_id_sel = Selector::parse("input[name=comment-user-id]").unwrap();
    let current_user_id = fragment
        .select(&user_id_sel)
        .next()
        .and_then(|el| el.value().attr("value"))
        .map(|s| s.to_string());

    let child_sel = Selector::parse("#comment-start > *").unwrap();
    let children: Vec<_> = fragment.select(&child_sel).collect();
    let mut comments = Vec::new();
    for chunk in children.chunks(4) {
        let combined = chunk.iter().map(|el| el.html()).collect::<String>();
        let doc = Html::parse_fragment(&combined);
        if let Some(c) = parse_single_comment(&doc) {
            comments.push(c);
        }
    }

    Ok((csrf_token, current_user_id, comments))
}

pub(crate) fn parse_comment_replies(body: &str) -> Result<Vec<ParsedComment>> {
    let json: Value = serde_json::from_str(body)?;
    let replies_html = json
        .get("replies")
        .and_then(|v| v.as_str())
        .unwrap_or_default();
    let fragment = Html::parse_fragment(replies_html);

    let child_sel = Selector::parse("div[id^='reply-start'] > div").unwrap();
    let children: Vec<_> = fragment.select(&child_sel).collect();
    let mut replies = Vec::new();
    let mut i = 0;
    while i + 1 < children.len() {
        let combined = format!("{}{}", children[i].html(), children[i + 1].html());
        let doc = Html::parse_fragment(&combined);
        if let Some(c) = parse_single_reply(&doc) {
            replies.push(c);
        }
        i += 2;
    }
    Ok(replies)
}

fn parse_single_comment(doc: &Html) -> Option<ParsedComment> {
    let avatar_sel = Selector::parse("img").ok()?;
    let avatar = doc
        .select(&avatar_sel)
        .next()
        .and_then(|img| img.value().attr("src"))
        .map(make_absolute_url);

    let text_sel = Selector::parse(".comment-index-text").ok()?;
    let texts: Vec<_> = doc.select(&text_sel).collect();
    let (user_name, time) = if let Some(first) = texts.first() {
        let name_sel = Selector::parse("a").ok()?;
        let user_name = first
            .select(&name_sel)
            .next()
            .map(|a| a.text().collect::<String>().trim().to_string())
            .unwrap_or_default();
        let span_sel = Selector::parse("span").ok()?;
        let time = first
            .select(&span_sel)
            .next()
            .map(|s| s.text().collect::<String>().trim().to_string())
            .unwrap_or_default();
        (user_name, time)
    } else {
        (String::new(), String::new())
    };

    let content = texts
        .get(1)
        .map(|el| el.text().collect::<String>().trim().to_string())
        .unwrap_or_default();

    let id_sel = Selector::parse("div[id^='reply-section-wrapper']").ok()?;
    let id = doc
        .select(&id_sel)
        .next()
        .and_then(|el| el.value().attr("id"))
        .and_then(|raw| raw.rsplit('-').next())
        .unwrap_or("-1")
        .to_string();

    let has_more_sel = Selector::parse("div[class^='load-replies-btn']").ok()?;
    let has_more_replies = doc.select(&has_more_sel).next().is_some();

    let like_sel = Selector::parse("#comment-like-form-wrapper span[style]").ok()?;
    let like_text = doc
        .select(&like_sel)
        .nth(1)
        .map(|el| el.text().collect::<String>())
        .unwrap_or_default();
    let likes = DIGITS_REGEX
        .find(&like_text)
        .and_then(|m| m.as_str().parse::<u32>().ok())
        .unwrap_or(0);

    Some(ParsedComment {
        id,
        user_name,
        user_avatar: avatar,
        time,
        content,
        likes,
        has_more_replies,
    })
}

fn parse_single_reply(doc: &Html) -> Option<ParsedComment> {
    // Reply HTML is similar; best-effort reuse selectors.
    let avatar_sel = Selector::parse("img").ok()?;
    let avatar = doc
        .select(&avatar_sel)
        .next()
        .and_then(|img| img.value().attr("src"))
        .map(make_absolute_url);

    let text_sel = Selector::parse(".comment-index-text").ok()?;
    let texts: Vec<_> = doc.select(&text_sel).collect();
    let (user_name, time) = if let Some(first) = texts.first() {
        let name_sel = Selector::parse("a").ok()?;
        let user_name = first
            .select(&name_sel)
            .next()
            .map(|a| a.text().collect::<String>().trim().to_string())
            .unwrap_or_default();
        let span_sel = Selector::parse("span").ok()?;
        let time = first
            .select(&span_sel)
            .next()
            .map(|s| s.text().collect::<String>().trim().to_string())
            .unwrap_or_default();
        (user_name, time)
    } else {
        (String::new(), String::new())
    };

    let content = texts
        .get(1)
        .map(|el| el.text().collect::<String>().trim().to_string())
        .unwrap_or_default();

    let like_sel = Selector::parse("span[style]").ok()?;
    let like_text = doc
        .select(&like_sel)
        .nth(1)
        .map(|el| el.text().collect::<String>())
        .unwrap_or_default();
    let likes = DIGITS_REGEX
        .find(&like_text)
        .and_then(|m| m.as_str().parse::<u32>().ok())
        .unwrap_or(0);

    Some(ParsedComment {
        id: "-1".to_string(),
        user_name,
        user_avatar: avatar,
        time,
        content,
        likes,
        has_more_replies: false,
    })
}

/// 解析视频源
fn parse_video_sources(document: &Html, html: &str) -> Vec<VideoSource> {
    let mut sources = Vec::new();

    // 方式1: 从 <video> 标签的 <source> 子元素获取
    let video_selector = Selector::parse("video#player").unwrap();
    if let Some(video) = document.select(&video_selector).next() {
        let source_selector = Selector::parse("source").unwrap();
        for source in video.select(&source_selector) {
            let size = source.value().attr("size").unwrap_or("");
            let src = source.value().attr("src").unwrap_or("");
            let video_type = source.value().attr("type").unwrap_or("video/mp4");

            if !src.is_empty() {
                sources.push(VideoSource {
                    quality: if size.is_empty() {
                        "auto".to_string()
                    } else {
                        format!("{}P", size)
                    },
                    url: make_absolute_url(src),
                    format: if video_type.contains("mp4") {
                        "mp4".to_string()
                    } else {
                        "m3u8".to_string()
                    },
                });
            }
        }
    }

    // 方式2: 如果没有 <source>，从 JavaScript 中提取
    if sources.is_empty() {
        if let Some(caps) = VIDEO_SOURCE_REGEX.captures(html) {
            if let Some(url) = caps.get(1) {
                sources.push(VideoSource {
                    quality: "auto".to_string(),
                    url: url.as_str().to_string(),
                    format: if url.as_str().contains(".m3u8") {
                        "m3u8".to_string()
                    } else {
                        "mp4".to_string()
                    },
                });
            }
        }
    }

    sources
}

/// 解析创作者信息
fn parse_creator(document: &Html) -> Option<Creator> {
    let name_selector = Selector::parse("#video-artist-name").unwrap();
    let name = document
        .select(&name_selector)
        .next()
        .map(|el| el.text().collect::<String>().trim().to_string())?;

    // 头像
    let avatar_selector = Selector::parse(
        "div.video-details-wrapper > div > a > div > img[style*='border-radius: 50%']",
    )
    .unwrap();
    let avatar_url = document
        .select(&avatar_selector)
        .next()
        .and_then(|el| el.value().attr("src"))
        .map(|s| make_absolute_url(s));

    // 类型
    let genre = None; // 在 name 的下一个兄弟元素中

    // ID (从订阅表单中获取)
    let form_selector =
        Selector::parse("#video-subscribe-form input[name=subscribe-artist-id]").unwrap();
    let id = document
        .select(&form_selector)
        .next()
        .and_then(|el| el.value().attr("value"))
        .map(|s| s.to_string())
        .unwrap_or_default();

    // 是否已订阅（从订阅表单 hidden input value 判断，未订阅时通常为空）
    let subscribed_selector =
        Selector::parse("#video-subscribe-form input[name=subscribe-status]").unwrap();
    let subscribed_value = document
        .select(&subscribed_selector)
        .next()
        .and_then(|el| el.value().attr("value"))
        .unwrap_or("")
        .trim();
    let is_subscribed = subscribed_value == "1";

    Some(Creator {
        id,
        name,
        avatar_url,
        genre,
        is_subscribed,
    })
}

/// 解析相关视频
fn parse_related_videos(document: &Html) -> Vec<VideoCard> {
    let mut videos = Vec::new();

    let related_selector = Selector::parse("#related-tabcontent").unwrap();
    if let Some(related) = document.select(&related_selector).next() {
        // 检查是否是简化版
        let simplified_selector = Selector::parse(".home-rows-videos-div").unwrap();
        let is_simplified = related.select(&simplified_selector).next().is_some();

        if is_simplified {
            let a_selector = Selector::parse("a").unwrap();
            for link in related.select(&a_selector) {
                let href = link.value().attr("href").unwrap_or("");
                if let Some(id) = extract_video_code(href) {
                    let div_selector = Selector::parse(".home-rows-videos-div").unwrap();
                    if let Some(div) = link.select(&div_selector).next() {
                        let img_selector = Selector::parse("img").unwrap();
                        let cover_url = div
                            .select(&img_selector)
                            .next()
                            .and_then(|img| img.value().attr("src"))
                            .map(|s| make_absolute_url(s))
                            .unwrap_or_default();

                        let title_selector = Selector::parse("div[class$=title]").unwrap();
                        let title = div
                            .select(&title_selector)
                            .next()
                            .map(|el| el.text().collect::<String>().trim().to_string())
                            .unwrap_or_default();

                        videos.push(VideoCard {
                            id,
                            title,
                            cover_url,
                            duration: String::new(),
                            views: String::new(),
                            artist: None,
                            upload_time: None,
                            tags: vec![],
                            upload_date: None,
                        });
                    }
                }
            }
        } else {
            // 正常版
            let card_selector = Selector::parse("div[class^=horizontal-card]").unwrap();
            for card in related.select(&card_selector) {
                if let Some(video) = parse_normal_video_item(&card) {
                    videos.push(video);
                }
            }
        }
    }

    videos
}

/// 解析播放列表
fn parse_playlist(document: &Html) -> Option<Playlist> {
    let wrapper_selector = Selector::parse("#video-playlist-wrapper").unwrap();
    let wrapper = document.select(&wrapper_selector).next()?;

    let name_selector = Selector::parse("div > div > h4").unwrap();
    let name = wrapper
        .select(&name_selector)
        .next()
        .map(|el| el.text().collect::<String>().trim().to_string());

    let scroll_selector = Selector::parse("#playlist-scroll").unwrap();
    let scroll = wrapper.select(&scroll_selector).next()?;

    let mut videos = Vec::new();
    for child in scroll.children() {
        if let Some(element) = child.value().as_element() {
            if element.name() == "a" {
                continue; // 跳过链接
            }
        }

        // 解析每个播放列表项
        if let Some(element) = ElementRef::wrap(child) {
            let a_selector = Selector::parse("div > a").unwrap();
            if let Some(link) = element.select(&a_selector).next() {
                let href = link.value().attr("href").unwrap_or("");
                if let Some(id) = extract_video_code(href) {
                    let img_selector = Selector::parse("img").unwrap();
                    let img = element
                        .select(&img_selector)
                        .nth(1)
                        .or_else(|| element.select(&img_selector).next());

                    let cover_url = img
                        .and_then(|i| i.value().attr("src"))
                        .map(|s| make_absolute_url(s))
                        .unwrap_or_default();

                    let title = img
                        .and_then(|i| i.value().attr("alt"))
                        .map(|s| s.to_string())
                        .unwrap_or_default();

                    let duration_selector =
                        Selector::parse("div[class*=card-mobile-duration]").unwrap();
                    let durations: Vec<_> = element.select(&duration_selector).collect();
                    let duration = durations
                        .first()
                        .map(|el| el.text().collect::<String>().trim().to_string())
                        .unwrap_or_default();

                    videos.push(VideoCard {
                        id,
                        title,
                        cover_url,
                        duration,
                        views: String::new(),
                        artist: None,
                        upload_time: None,
                        tags: vec![],
                        upload_date: None,
                    });
                }
            }
        }
    }

    Some(Playlist { name, videos })
}

/// 解析我的列表信息
fn parse_my_list(document: &Html) -> Option<MyListInfo> {
    let wrapper_selector = Selector::parse("div[class~=playlist-checkbox-wrapper]").unwrap();
    let wrappers: Vec<_> = document.select(&wrapper_selector).collect();

    if wrappers.is_empty() {
        return None;
    }

    let mut items = Vec::new();
    for wrapper in wrappers {
        let title_selector = Selector::parse("span").unwrap();
        let title = wrapper
            .select(&title_selector)
            .next()
            .map(|el| el.text().collect::<String>().trim().to_string());

        let input_selector = Selector::parse("input").unwrap();
        let input = wrapper.select(&input_selector).next();

        let code = input
            .and_then(|i| i.value().attr("id"))
            .map(|s| s.to_string());

        let is_selected = input
            .map(|i| i.value().attr("checked").is_some())
            .unwrap_or(false);

        if let (Some(code), Some(title)) = (code, title) {
            items.push(MyListItem {
                code,
                title,
                is_selected,
            });
        }
    }

    // 稍后观看
    let watch_later_selector = Selector::parse("#playlist-save-checkbox input").unwrap();
    let is_watch_later = document
        .select(&watch_later_selector)
        .next()
        .map(|i| i.value().attr("checked").is_some())
        .unwrap_or(false);

    Some(MyListInfo {
        is_watch_later,
        items,
    })
}

/// 解析首页
pub fn parse_homepage(html: &str) -> Result<HomePage> {
    let document = Html::parse_document(html);

    // CSRF Token
    let token_selector = Selector::parse("input[name=_token]").unwrap();
    let form_token = document
        .select(&token_selector)
        .next()
        .and_then(|el| el.value().attr("value"))
        .map(|s| s.to_string());

    // 用户信息
    let user_selector = Selector::parse("#user-modal-dp-wrapper").unwrap();
    let (avatar_url, username) = if let Some(user_modal) = document.select(&user_selector).next() {
        let img_selector = Selector::parse("img").unwrap();
        let avatar = user_modal
            .select(&img_selector)
            .next()
            .and_then(|img| img.value().attr("src"))
            .map(|s| make_absolute_url(s));

        let name_selector = Selector::parse("#user-modal-name").unwrap();
        let name = user_modal
            .select(&name_selector)
            .next()
            .map(|el| el.text().collect::<String>().trim().to_string());

        (avatar, name)
    } else {
        (None, None)
    };

    // Banner
    let banner = parse_banner(&document, html);

    // 各分区视频
    let rows_selector = Selector::parse("#home-rows-wrapper > div").unwrap();
    let rows: Vec<_> = document.select(&rows_selector).collect();

    let latest_release = rows
        .get(0)
        .map(|r| extract_videos_from_row(r))
        .unwrap_or_default();

    let latest_upload = rows
        .get(1)
        .map(|r| extract_videos_from_row(r))
        .unwrap_or_default();

    // 其他分区
    let mut sections = Vec::new();
    let section_names = [
        "裏番",
        "泡麵番",
        "",
        "Motion Anime",
        "3DCG",
        "2.5D",
        "2D動畫",
        "",
        "AI生成",
        "MMD",
        "Cosplay",
        "他們在看",
    ];

    for (i, name) in section_names.iter().enumerate() {
        if name.is_empty() {
            continue;
        }
        if let Some(row) = rows.get(i + 2) {
            let videos = extract_videos_from_row(row);
            if !videos.is_empty() {
                sections.push((name.to_string(), videos));
            }
        }
    }

    Ok(HomePage {
        form_token,
        avatar_url,
        username,
        banner,
        latest_release,
        latest_upload,
        sections,
    })
}

/// 解析 Banner
fn parse_banner(document: &Html, html: &str) -> Option<Banner> {
    let banner_selector = Selector::parse("#home-banner-wrapper").unwrap();
    let banner_wrapper = document.select(&banner_selector).next()?;

    // 标题
    let title_selector = Selector::parse("h4").unwrap();
    let description = banner_wrapper
        .select(&title_selector)
        .next()
        .map(|el| el.text().collect::<String>().trim().to_string());

    // 图片
    let img_selector = Selector::parse("img").unwrap();
    // Banner 图片通常在 wrapper 的前一个兄弟元素
    let pic_url = document
        .select(
            &Selector::parse("#home-banner-wrapper ~ div img, #home-banner-wrapper + div img")
                .unwrap(),
        )
        .next()
        .or_else(|| document.select(&img_selector).next())
        .and_then(|img| {
            img.value()
                .attr("src")
                .or_else(|| img.value().attr("data-src"))
        })
        .map(|s| make_absolute_url(s))?;

    let title = document
        .select(&Selector::parse("img[alt]").unwrap())
        .next()
        .and_then(|img| img.value().attr("alt"))
        .map(|s| s.to_string())
        .unwrap_or_else(|| "Featured".to_string());

    // 视频代码
    let video_code = VIDEO_CODE_REGEX
        .captures(html)
        .and_then(|caps| caps.get(1))
        .map(|m| m.as_str().to_string());

    Some(Banner {
        title,
        description,
        pic_url,
        video_code,
    })
}

/// 从行中提取视频列表
fn extract_videos_from_row(row: &ElementRef) -> Vec<VideoCard> {
    let card_selector = Selector::parse("div[class^=horizontal-card]").unwrap();
    let mut videos = Vec::new();

    for card in row.select(&card_selector) {
        if let Some(video) = parse_normal_video_item(&card) {
            videos.push(video);
        }
    }

    videos
}

/// 解析收藏/稍后观看列表
pub fn parse_my_list_items(html: &str) -> Result<MyListItems> {
    let document = Html::parse_document(html);

    // CSRF Token
    let token_selector = Selector::parse("input[name=_token]").unwrap();
    let form_token = document
        .select(&token_selector)
        .next()
        .and_then(|el| el.value().attr("value"))
        .map(|s| s.to_string());

    // 描述
    let desc_selector = Selector::parse("#playlist-show-description").unwrap();
    let description = document
        .select(&desc_selector)
        .next()
        .map(|el| el.text().collect::<String>().trim().to_string());

    // 视频列表
    let wrapper_selector = Selector::parse(".home-rows-videos-wrapper").unwrap();
    let mut videos = Vec::new();

    if let Some(wrapper) = document.select(&wrapper_selector).next() {
        for child in wrapper.children() {
            if let Some(element) = ElementRef::wrap(child) {
                let title_selector = Selector::parse(".home-rows-videos-title").unwrap();
                let title = element
                    .select(&title_selector)
                    .next()
                    .map(|el| el.text().collect::<String>().trim().to_string());

                let img_selector = Selector::parse("img").unwrap();
                let imgs: Vec<_> = element.select(&img_selector).collect();
                let cover_url = imgs
                    .get(1)
                    .or(imgs.first())
                    .and_then(|img| img.value().attr("src"))
                    .map(|s| make_absolute_url(s));

                let link_selector = Selector::parse(".playlist-show-links").unwrap();
                let id = element
                    .select(&link_selector)
                    .next()
                    .and_then(|a| a.value().attr("href"))
                    .and_then(|href| extract_video_code(href));

                if let (Some(id), Some(title), Some(cover_url)) = (id, title, cover_url) {
                    videos.push(VideoCard {
                        id,
                        title,
                        cover_url,
                        duration: String::new(),
                        views: String::new(),
                        artist: None,
                        upload_time: None,
                        tags: vec![],
                        upload_date: None,
                    });
                }
            }
        }
    }

    Ok(MyListItems {
        videos,
        form_token,
        description,
    })
}

/// 解析订阅页（订阅作者 + 订阅更新视频）
pub fn parse_subscriptions_page(
    html: &str,
) -> Result<(Vec<(String, Option<String>)>, Vec<VideoCard>, u32)> {
    let document = Html::parse_document(html);

    // 解析最大页数
    let page_re = Regex::new(r"\?page=(\d+)").unwrap();
    let page_link_sel = Selector::parse("ul.pagination a.page-link[href]").unwrap();
    let mut max_page: u32 = 1;
    for a in document.select(&page_link_sel) {
        if let Some(href) = a.value().attr("href") {
            if let Some(caps) = page_re.captures(href) {
                if let Some(m) = caps.get(1) {
                    if let Ok(v) = m.as_str().parse::<u32>() {
                        max_page = max_page.max(v);
                    }
                }
            }
        }
    }

    // 解析作者
    let mut authors: Vec<(String, Option<String>)> = Vec::new();
    let nav_sel = Selector::parse("div.subscriptions-nav").unwrap();
    let artist_card_sel = Selector::parse("div.subscriptions-artist-card").unwrap();
    let artist_name_sel = Selector::parse("div.card-mobile-title").unwrap();
    let img_sel = Selector::parse("img").unwrap();
    if let Some(nav) = document.select(&nav_sel).next() {
        for card in nav.select(&artist_card_sel) {
            let name = card
                .select(&artist_name_sel)
                .next()
                .map(|e| e.text().collect::<String>().trim().to_string());
            let imgs: Vec<_> = card.select(&img_sel).collect();
            let avatar = imgs
                .get(1)
                .or(imgs.first())
                .and_then(|img| img.value().attr("src"))
                .map(make_absolute_url);
            if let Some(name) = name {
                if !name.is_empty() {
                    authors.push((name, avatar));
                }
            }
        }
    }

    // 解析视频
    let mut videos: Vec<VideoCard> = Vec::new();
    let content_sel = Selector::parse("div.content-padding-new").unwrap();
    let video_sel = Selector::parse("div[class^=video-item-container]").unwrap();
    let link_sel = Selector::parse("a[class^=video-link]").unwrap();
    let cover_sel = Selector::parse("img[class^=main-thumb]").unwrap();
    let thumb_sel = Selector::parse("div[class^=thumb-container]").unwrap();
    let duration_sel = Selector::parse("div[class^=duration]").unwrap();
    let stat_sel = Selector::parse("div[class^=stat-item]").unwrap();
    let subtitle_sel = Selector::parse("div.subtitle a").unwrap();

    if let Some(root) = document.select(&content_sel).next() {
        for item in root.select(&video_sel) {
            let href = item
                .select(&link_sel)
                .next()
                .and_then(|a| a.value().attr("href"))
                .unwrap_or("");
            let id = extract_video_code(href);

            let cover_url = item
                .select(&cover_sel)
                .next()
                .and_then(|img| img.value().attr("src"))
                .map(make_absolute_url);

            let title = item
                .value()
                .attr("title")
                .map(|s| s.trim().to_string())
                .filter(|s| !s.is_empty());

            let thumb = item.select(&thumb_sel).next();
            let duration = thumb
                .as_ref()
                .and_then(|t| t.select(&duration_sel).next())
                .map(|d| d.text().collect::<String>().trim().to_string())
                .unwrap_or_default();
            let views = thumb
                .as_ref()
                .map(|t| t.select(&stat_sel).collect::<Vec<_>>())
                .and_then(|stats| {
                    stats
                        .get(1)
                        .map(|e| e.text().collect::<String>().trim().to_string())
                })
                .unwrap_or_default();

            let subtitle = item
                .select(&subtitle_sel)
                .next()
                .map(|e| e.text().collect::<String>().trim().to_string())
                .unwrap_or_default();
            let (artist, upload_time) = if subtitle.contains('•') {
                let parts: Vec<_> = subtitle.split('•').map(|s| s.trim().to_string()).collect();
                let a = parts.get(0).cloned().filter(|s| !s.is_empty());
                let u = parts.get(1).cloned().filter(|s| !s.is_empty());
                (a, u)
            } else {
                (None, None)
            };

            if let (Some(id), Some(title), Some(cover_url)) = (id, title, cover_url) {
                videos.push(VideoCard {
                    id,
                    title,
                    cover_url,
                    duration,
                    views,
                    artist,
                    upload_time: upload_time.clone(),
                    tags: vec![],
                    upload_date: upload_time,
                });
            }
        }
    }

    Ok((authors, videos, max_page))
}

// ============================================================================
// 工具函数
// ============================================================================

/// 从 URL 中提取视频代码
fn extract_video_code(url: &str) -> Option<String> {
    if url.contains("watch?v=") {
        url.split("v=")
            .nth(1)
            .map(|s| s.split('&').next().unwrap_or(s).to_string())
    } else if url.contains("/watch/") {
        url.split("/watch/")
            .nth(1)
            .map(|s| s.split('/').next().unwrap_or(s).to_string())
    } else {
        None
    }
}

/// 将相对 URL 转换为绝对 URL
fn make_absolute_url(url: &str) -> String {
    if url.starts_with("http") {
        url.to_string()
    } else if url.starts_with("//") {
        format!("https:{}", url)
    } else if url.starts_with('/') {
        format!("https://hanime1.me{}", url)
    } else {
        url.to_string()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_extract_video_code() {
        assert_eq!(
            extract_video_code("https://hanime1.me/watch?v=12345"),
            Some("12345".to_string())
        );
        assert_eq!(
            extract_video_code("/watch?v=12345&foo=bar"),
            Some("12345".to_string())
        );
        assert_eq!(extract_video_code("invalid"), None);
    }

    #[test]
    fn test_make_absolute_url() {
        assert_eq!(
            make_absolute_url("https://example.com/img.jpg"),
            "https://example.com/img.jpg"
        );
        assert_eq!(
            make_absolute_url("//example.com/img.jpg"),
            "https://example.com/img.jpg"
        );
        assert_eq!(make_absolute_url("/img.jpg"), "https://hanime1.me/img.jpg");
    }

    #[test]
    fn parse_video_sources_from_video_tag() {
        let html = r#"
                <html>
                    <body>
                        <video id="player">
                            <source size="720" type="video/mp4" src="https://cdn.example.com/video720.mp4" />
                        </video>
                    </body>
                </html>
                "#;

        let doc = Html::parse_document(html);
        let sources = parse_video_sources(&doc, html);
        assert_eq!(sources.len(), 1);
        assert_eq!(sources[0].quality, "720P");
        assert_eq!(sources[0].url, "https://cdn.example.com/video720.mp4");
        assert_eq!(sources[0].format, "mp4");
    }

    #[test]
    fn parse_video_sources_from_script() {
        let html = r#"
                <html>
                    <body>
                        <script>const source = 'https://cdn.example.com/master.m3u8'</script>
                    </body>
                </html>
                "#;

        let doc = Html::parse_document(html);
        let sources = parse_video_sources(&doc, html);
        assert_eq!(sources.len(), 1);
        assert_eq!(sources[0].quality, "auto");
        assert_eq!(sources[0].url, "https://cdn.example.com/master.m3u8");
        assert_eq!(sources[0].format, "m3u8");
    }

    #[test]
    fn parse_video_detail_basic() {
        let html = r#"
                <html>
                    <head>
                        <meta property="og:image" content="https://cdn.example.com/cover.jpg" />
                        <meta property="og:url" content="https://hanime1.me/watch?v=123456" />
                    </head>
                    <body>
                        <input name="_token" value="csrf123" />
                        <input name="like-user-id" value="100" />
                        <input name="like-status" value="1" />
                        <input name="likes-count" value="42" />
                        <div id="shareBtn-title">Test Title</div>
                        <div class="video-details-wrapper">
                            <div><div><div>觀看次數：123次 2024-01-01</div></div></div>
                            <div class="video-caption-text">Test Description</div>
                        </div>
                        <div class="single-video-tag"><a>#tag1</a></div>
                        <video id="player">
                            <source size="1080" type="video/mp4" src="https://cdn.example.com/video1080.mp4" />
                        </video>
                    </body>
                </html>
                "#;

        let detail = parse_video_detail(html).expect("parse_video_detail failed");
        assert_eq!(detail.id, "123456");
        assert_eq!(detail.title, "Test Title");
        assert_eq!(detail.cover_url, "https://cdn.example.com/cover.jpg");
        assert_eq!(detail.tags, vec!["tag1".to_string()]);
        assert_eq!(detail.video_sources.len(), 1);
        assert_eq!(detail.video_sources[0].quality, "1080P");
    }
}
