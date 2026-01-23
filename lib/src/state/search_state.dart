// 搜索状态管理

import 'package:flutter/foundation.dart';
import 'package:signals/signals_flutter.dart';
import 'package:hibiscus/src/rust/api/search.dart' as search_api;
import 'package:hibiscus/src/rust/api/models.dart';

/// 搜索状态
class SearchState {
  // 单例
  static final SearchState _instance = SearchState._();
  factory SearchState() => _instance;
  SearchState._();

  // 过滤条件
  final filters = signal<ApiSearchFilters?>(null);

  // 可用的过滤选项（从网站获取）
  final filterOptions = signal<ApiFilterOptions?>(null);

  // 视频列表
  final videos = signal<List<ApiVideoCard>>([]);

  // 加载状态
  final isLoading = signal(false);
  final isLoadingMore = signal(false);
  final hasMore = signal(true);

  // 错误信息
  final error = signal<String?>(null);

  // 需要 Cloudflare 验证
  final needsCloudflare = signal(false);

  // 当前页码
  int _currentPage = 1;

  /// 初始化默认过滤条件
  Future<void> init() async {
    if (filters.value != null) return;
    
    try {
      filters.value = await ApiSearchFilters.default_();
    } catch (e) {
      debugPrint('Failed to init filters: $e');
      // 使用本地默认值
      filters.value = const ApiSearchFilters(
        query: null,
        genre: null,
        tags: [],
        broadMatch: false,
        sort: null,
        year: null,
        month: null,
        date: null,
        duration: null,
        page: 1,
      );
    }
  }

  /// 加载过滤选项
  Future<void> loadFilterOptions() async {
    if (filterOptions.value != null) return;

    try {
      filterOptions.value = await search_api.getFilterOptions();
    } catch (e) {
      debugPrint('Failed to load filter options: $e');
    }
  }

  /// 执行搜索
  Future<void> search({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    // 确保已初始化
    await init();

    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
      needsCloudflare.value = false;
    }

    isLoading.value = true;
    error.value = null;

    try {
      final currentFilters = filters.value!.copyWith(page: _currentPage);
      final result = await search_api.search(filters: currentFilters);

      if (refresh) {
        videos.value = result.videos;
      } else {
        videos.value = [...videos.value, ...result.videos];
      }

      hasMore.value = result.hasNext;
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('CLOUDFLARE_CHALLENGE')) {
        needsCloudflare.value = true;
        error.value = '需要完成 Cloudflare 验证';
      } else {
        error.value = errorStr;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// 获取首页视频
  Future<void> loadHomeVideos({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
      needsCloudflare.value = false;
    }

    isLoading.value = true;
    error.value = null;

    try {
      debugPrint('Loading home videos, page: $_currentPage');
      final result = await search_api.getHomeVideos(page: _currentPage);
      debugPrint('Got ${result.videos.length} videos');

      if (refresh) {
        videos.value = result.videos;
      } else {
        videos.value = [...videos.value, ...result.videos];
      }

      hasMore.value = result.hasNext;
    } catch (e) {
      debugPrint('Load home videos error: $e');
      final errorStr = e.toString();
      if (errorStr.contains('CLOUDFLARE_CHALLENGE')) {
        needsCloudflare.value = true;
        error.value = '需要完成 Cloudflare 验证';
      } else {
        error.value = errorStr;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value || isLoading.value) return;

    isLoadingMore.value = true;
    _currentPage++;

    try {
      // 根据当前是否有搜索条件决定调用哪个 API
      if (filters.value?.query != null && filters.value!.query!.isNotEmpty) {
        await search();
      } else {
        await loadHomeVideos();
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 更新过滤条件并重新搜索
  void updateFilters(ApiSearchFilters newFilters) {
    filters.value = newFilters;
    search(refresh: true);
  }

  /// 更新搜索关键词
  void updateQuery(String query) {
    if (filters.value == null) return;
    filters.value = filters.value!.copyWith(
      query: query.isEmpty ? null : query,
    );
    search(refresh: true);
  }

  /// 更新类型
  void updateGenre(String? genre) {
    if (filters.value == null) return;
    filters.value = filters.value!.copyWith(genre: genre);
    search(refresh: true);
  }

  /// 更新标签
  void updateTags(List<String> tags) {
    if (filters.value == null) return;
    filters.value = filters.value!.copyWith(tags: tags);
    search(refresh: true);
  }

  /// 切换标签
  void toggleTag(String tag) {
    if (filters.value == null) return;
    final currentTags = List<String>.from(filters.value!.tags);
    if (currentTags.contains(tag)) {
      currentTags.remove(tag);
    } else {
      currentTags.add(tag);
    }
    filters.value = filters.value!.copyWith(tags: currentTags);
    search(refresh: true);
  }

  /// 更新排序
  void updateSort(String? sort) {
    if (filters.value == null) return;
    filters.value = filters.value!.copyWith(sort: sort);
    search(refresh: true);
  }

  /// 更新年份
  void updateYear(String? year) {
    if (filters.value == null) return;
    filters.value = filters.value!.copyWith(year: year);
    search(refresh: true);
  }

  /// 更新时长
  void updateDuration(String? duration) {
    if (filters.value == null) return;
    filters.value = filters.value!.copyWith(duration: duration);
    search(refresh: true);
  }

  /// 切换宽松匹配
  void toggleBroadMatch() {
    if (filters.value == null) return;
    filters.value = filters.value!.copyWith(
      broadMatch: !filters.value!.broadMatch,
    );
    search(refresh: true);
  }

  /// 清除过滤条件（保留搜索词）
  void clearFilters() {
    if (filters.value == null) return;
    filters.value = ApiSearchFilters(
      query: filters.value!.query,
      genre: null,
      tags: const [],
      broadMatch: false,
      sort: null,
      year: null,
      month: null,
      date: null,
      duration: null,
      page: 1,
    );
    search(refresh: true);
  }

  /// 完全重置
  void reset() {
    filters.value = const ApiSearchFilters(
      query: null,
      genre: null,
      tags: [],
      broadMatch: false,
      sort: null,
      year: null,
      month: null,
      date: null,
      duration: null,
      page: 1,
    );
    videos.value = [];
    error.value = null;
    hasMore.value = true;
    needsCloudflare.value = false;
    _currentPage = 1;
  }

  /// 是否有激活的过滤条件
  bool get hasActiveFilters {
    final f = filters.value;
    if (f == null) return false;
    return f.genre != null ||
        f.tags.isNotEmpty ||
        f.sort != null ||
        f.year != null ||
        f.duration != null;
  }
}

/// 全局搜索状态实例
final searchState = SearchState();
