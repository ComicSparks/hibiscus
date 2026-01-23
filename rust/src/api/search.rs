// 搜索相关 API

use flutter_rust_bridge::frb;
use chrono::Datelike;
use crate::api::models::{ApiSearchResult, ApiSearchFilters, ApiFilterOptions, ApiVideoCard, ApiFilterOption, ApiTagGroup};
use crate::core::network;
use crate::core::parser;

const BASE_URL: &str = "https://hanime1.me";

/// 构建搜索 URL
fn build_search_url(filters: &ApiSearchFilters) -> String {
    let mut url = format!("{}/search?", BASE_URL);
    let mut params = vec![];
    
    // 搜索关键词
    if let Some(ref query) = filters.query {
        params.push(format!("query={}", urlencoding::encode(query)));
    }
    
    // 影片類型
    if let Some(ref genre) = filters.genre {
        params.push(format!("genre={}", urlencoding::encode(genre)));
    }
    
    // 標籤
    for tag in &filters.tags {
        params.push(format!("tags[]={}", urlencoding::encode(tag)));
    }
    
    // 廣泛配對
    if filters.broad_match {
        params.push("broad=1".to_string());
    }
    
    // 排序
    if let Some(ref sort) = filters.sort {
        params.push(format!("sort={}", urlencoding::encode(sort)));
    }
    
    // 日期（快速选项或年月）
    if let Some(ref date) = filters.date {
        params.push(format!("date={}", urlencoding::encode(date)));
    } else {
        // 年份 + 月份
        let mut date_str = String::new();
        if let Some(ref year) = filters.year {
            date_str.push_str(year);
        }
        if let Some(ref month) = filters.month {
            if !date_str.is_empty() {
                date_str.push(' ');
            }
            date_str.push_str(month);
        }
        if !date_str.is_empty() {
            params.push(format!("date={}", urlencoding::encode(&date_str)));
        }
    }
    
    // 時長
    if let Some(ref duration) = filters.duration {
        params.push(format!("duration={}", urlencoding::encode(duration)));
    }
    
    // 頁碼
    if filters.page > 1 {
        params.push(format!("page={}", filters.page));
    }
    
    url.push_str(&params.join("&"));
    url
}

/// 执行搜索
#[frb]
pub async fn search(filters: ApiSearchFilters) -> anyhow::Result<ApiSearchResult> {
    let url = build_search_url(&filters);
    tracing::info!("Search URL: {}", url);
    
    // 尝试发起网络请求
    match network::get(&url).await {
        Ok(html) => {
            // 解析 HTML
            let result = parser::parse_search_page(&html)?;
            
            // 转换为 API 模型
            let videos: Vec<ApiVideoCard> = result.videos.into_iter().map(|v| ApiVideoCard {
                id: v.id,
                title: v.title,
                cover_url: v.cover_url,
                duration: Some(v.duration).filter(|s| !s.is_empty()),
                views: Some(v.views).filter(|s| !s.is_empty()),
                upload_date: v.upload_date,
                tags: v.tags,
            }).collect();
            
            Ok(ApiSearchResult {
                videos,
                total: (result.total_pages * 20) as u32, // 估算
                page: result.current_page as u32,
                has_next: result.has_next,
            })
        }
        Err(e) => {
            let err_str = e.to_string();
            
            // 检查是否需要 Cloudflare 验证
            if err_str.contains("CLOUDFLARE_CHALLENGE") {
                return Err(anyhow::anyhow!("CLOUDFLARE_CHALLENGE"));
            }
            
            // 其他错误，返回模拟数据用于开发
            tracing::warn!("Network error, returning mock data: {}", err_str);
            
            Ok(ApiSearchResult {
                videos: vec![
                    ApiVideoCard {
                        id: "1".to_string(),
                        title: "示例视频 1 - 这是一个很长的标题用于测试文本溢出效果".to_string(),
                        cover_url: "".to_string(),
                        duration: Some("24:30".to_string()),
                        views: Some("12.3K".to_string()),
                        upload_date: Some("2024-01-15".to_string()),
                        tags: vec!["無碼".to_string(), "中文字幕".to_string()],
                    },
                    ApiVideoCard {
                        id: "2".to_string(),
                        title: "示例视频 2".to_string(),
                        cover_url: "".to_string(),
                        duration: Some("18:45".to_string()),
                        views: Some("8.7K".to_string()),
                        upload_date: Some("2024-01-10".to_string()),
                        tags: vec!["JK".to_string()],
                    },
                    ApiVideoCard {
                        id: "3".to_string(),
                        title: "示例视频 3".to_string(),
                        cover_url: "".to_string(),
                        duration: Some("32:15".to_string()),
                        views: Some("15.2K".to_string()),
                        upload_date: Some("2024-01-08".to_string()),
                        tags: vec!["純愛".to_string(), "巨乳".to_string()],
                    },
                ],
                total: 100,
                page: filters.page,
                has_next: filters.page < 10,
            })
        }
    }
}

/// 获取过滤选项（从网页实际提取的数据）
#[frb]
pub async fn get_filter_options() -> anyhow::Result<ApiFilterOptions> {
    Ok(ApiFilterOptions {
        genres: vec![
            ApiFilterOption { value: "".to_string(), label: "全部".to_string() },
            ApiFilterOption { value: "裏番".to_string(), label: "裏番".to_string() },
            ApiFilterOption { value: "泡麵番".to_string(), label: "泡麵番".to_string() },
            ApiFilterOption { value: "Motion Anime".to_string(), label: "Motion Anime".to_string() },
            ApiFilterOption { value: "3DCG".to_string(), label: "3DCG".to_string() },
            ApiFilterOption { value: "2.5D".to_string(), label: "2.5D".to_string() },
            ApiFilterOption { value: "2D動畫".to_string(), label: "2D動畫".to_string() },
            ApiFilterOption { value: "AI生成".to_string(), label: "AI生成".to_string() },
            ApiFilterOption { value: "MMD".to_string(), label: "MMD".to_string() },
            ApiFilterOption { value: "Cosplay".to_string(), label: "Cosplay".to_string() },
        ],
        tags: vec![
            ApiTagGroup {
                name: "影片屬性".to_string(),
                tags: vec![
                    ApiFilterOption { value: "無碼".to_string(), label: "無碼".to_string() },
                    ApiFilterOption { value: "AI解碼".to_string(), label: "AI解碼".to_string() },
                    ApiFilterOption { value: "中文字幕".to_string(), label: "中文字幕".to_string() },
                    ApiFilterOption { value: "中文配音".to_string(), label: "中文配音".to_string() },
                    ApiFilterOption { value: "同人作品".to_string(), label: "同人作品".to_string() },
                    ApiFilterOption { value: "斷面圖".to_string(), label: "斷面圖".to_string() },
                    ApiFilterOption { value: "ASMR".to_string(), label: "ASMR".to_string() },
                    ApiFilterOption { value: "1080p".to_string(), label: "1080p".to_string() },
                    ApiFilterOption { value: "60FPS".to_string(), label: "60FPS".to_string() },
                ],
            },
            ApiTagGroup {
                name: "人物關係".to_string(),
                tags: vec![
                    ApiFilterOption { value: "近親".to_string(), label: "近親".to_string() },
                    ApiFilterOption { value: "姐".to_string(), label: "姐".to_string() },
                    ApiFilterOption { value: "妹".to_string(), label: "妹".to_string() },
                    ApiFilterOption { value: "母".to_string(), label: "母".to_string() },
                    ApiFilterOption { value: "女兒".to_string(), label: "女兒".to_string() },
                    ApiFilterOption { value: "師生".to_string(), label: "師生".to_string() },
                    ApiFilterOption { value: "情侶".to_string(), label: "情侶".to_string() },
                    ApiFilterOption { value: "青梅竹馬".to_string(), label: "青梅竹馬".to_string() },
                    ApiFilterOption { value: "同事".to_string(), label: "同事".to_string() },
                ],
            },
            // 更多标签组...（完整数据在 Flutter 端的 FilterOptions 类中）
        ],
        sorts: vec![
            ApiFilterOption { value: "".to_string(), label: "排序方式".to_string() },
            ApiFilterOption { value: "最新上市".to_string(), label: "最新上市".to_string() },
            ApiFilterOption { value: "最新上傳".to_string(), label: "最新上傳".to_string() },
            ApiFilterOption { value: "本日排行".to_string(), label: "本日排行".to_string() },
            ApiFilterOption { value: "本週排行".to_string(), label: "本週排行".to_string() },
            ApiFilterOption { value: "本月排行".to_string(), label: "本月排行".to_string() },
            ApiFilterOption { value: "觀看次數".to_string(), label: "觀看次數".to_string() },
            ApiFilterOption { value: "讚好比例".to_string(), label: "讚好比例".to_string() },
            ApiFilterOption { value: "時長最長".to_string(), label: "時長最長".to_string() },
            ApiFilterOption { value: "他們在看".to_string(), label: "他們在看".to_string() },
        ],
        years: {
            let current_year = chrono::Utc::now().year();
            let mut years = vec![ApiFilterOption { value: "".to_string(), label: "全部年份".to_string() }];
            for year in (1990..=current_year).rev() {
                years.push(ApiFilterOption {
                    value: format!("{} 年", year),
                    label: format!("{} 年", year),
                });
            }
            years
        },
        durations: vec![
            ApiFilterOption { value: "".to_string(), label: "全部".to_string() },
            ApiFilterOption { value: "1 分鐘 +".to_string(), label: "1 分鐘 +".to_string() },
            ApiFilterOption { value: "5 分鐘 +".to_string(), label: "5 分鐘 +".to_string() },
            ApiFilterOption { value: "10 分鐘 +".to_string(), label: "10 分鐘 +".to_string() },
            ApiFilterOption { value: "20 分鐘 +".to_string(), label: "20 分鐘 +".to_string() },
            ApiFilterOption { value: "30 分鐘 +".to_string(), label: "30 分鐘 +".to_string() },
            ApiFilterOption { value: "60 分鐘 +".to_string(), label: "60 分鐘 +".to_string() },
            ApiFilterOption { value: "0 - 10 分鐘".to_string(), label: "0 - 10 分鐘".to_string() },
            ApiFilterOption { value: "0 - 20 分鐘".to_string(), label: "0 - 20 分鐘".to_string() },
        ],
    })
}

/// 获取首页推荐（默认搜索结果）
#[frb]
pub async fn get_home_videos(page: u32) -> anyhow::Result<ApiSearchResult> {
    search(ApiSearchFilters {
        page,
        ..Default::default()
    }).await
}
