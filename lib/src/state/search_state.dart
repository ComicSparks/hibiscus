// 搜索状态管理

import 'package:signals/signals_flutter.dart';
import '../ui/widgets/video_grid.dart';

/// 搜索过滤条件
class SearchFilters {
  final String? query;
  final String? genre;
  final List<String> tags;
  final bool broadMatch;
  final String? sort;
  final String? year;
  final String? month;
  final String? date;
  final String? duration;
  
  const SearchFilters({
    this.query,
    this.genre,
    this.tags = const [],
    this.broadMatch = false,
    this.sort,
    this.year,
    this.month,
    this.date,
    this.duration,
  });
  
  SearchFilters copyWith({
    String? query,
    String? genre,
    List<String>? tags,
    bool? broadMatch,
    String? sort,
    String? year,
    String? month,
    String? date,
    String? duration,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      genre: genre ?? this.genre,
      tags: tags ?? this.tags,
      broadMatch: broadMatch ?? this.broadMatch,
      sort: sort ?? this.sort,
      year: year ?? this.year,
      month: month ?? this.month,
      date: date ?? this.date,
      duration: duration ?? this.duration,
    );
  }
  
  bool get hasActiveFilters {
    return genre != null ||
        tags.isNotEmpty ||
        sort != null ||
        year != null ||
        month != null ||
        date != null ||
        duration != null;
  }
  
  SearchFilters clear() {
    return SearchFilters(query: query); // 保留搜索词
  }
}

/// 搜索状态
class SearchState {
  // 单例
  static final SearchState _instance = SearchState._();
  factory SearchState() => _instance;
  SearchState._();
  
  // 过滤条件
  final filters = signal(const SearchFilters());
  
  // 视频列表
  final videos = signal<List<VideoItem>>([]);
  
  // 加载状态
  final isLoading = signal(false);
  final isLoadingMore = signal(false);
  final hasMore = signal(true);
  
  // 错误信息
  final error = signal<String?>(null);
  
  // 当前页码
  final _page = signal(1);
  
  /// 执行搜索
  Future<void> search({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;
    
    if (refresh) {
      _page.value = 1;
      hasMore.value = true;
    }
    
    isLoading.value = true;
    error.value = null;
    
    try {
      // TODO: 调用 Rust API
      // final result = await searchApi(filters.value, _page.value);
      
      // 模拟数据
      await Future.delayed(const Duration(milliseconds: 500));
      final mockVideos = List.generate(
        20,
        (i) => VideoItem(
          id: 'video_${_page.value}_$i',
          title: '視頻標題 ${_page.value * 20 + i} - 這是一個很長的標題用於測試文本溢出效果',
          coverUrl: '',
          duration: '${(i + 1) * 2}:${(i * 7) % 60}'.padLeft(5, '0'),
          views: '${(i + 1) * 1000}',
          tags: ['標籤${i % 5}'],
        ),
      );
      
      if (refresh) {
        videos.value = mockVideos;
      } else {
        videos.value = [...videos.value, ...mockVideos];
      }
      
      hasMore.value = _page.value < 5; // 模拟 5 页
      
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 加载更多
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    
    isLoadingMore.value = true;
    _page.value++;
    
    try {
      await search();
    } finally {
      isLoadingMore.value = false;
    }
  }
  
  /// 更新过滤条件并重新搜索
  void updateFilters(SearchFilters newFilters) {
    filters.value = newFilters;
    search(refresh: true);
  }
  
  /// 更新搜索关键词
  void updateQuery(String query) {
    filters.value = filters.value.copyWith(query: query.isEmpty ? null : query);
    search(refresh: true);
  }
  
  /// 清除过滤条件
  void clearFilters() {
    filters.value = filters.value.clear();
    search(refresh: true);
  }
}

/// 全局搜索状态实例
final searchState = SearchState();
