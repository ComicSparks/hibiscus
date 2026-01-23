// 收藏/稍后观看/订阅状态管理

import 'package:signals/signals_flutter.dart';
import 'package:hibiscus/src/rust/api/user.dart' as user_api;
import 'package:hibiscus/src/rust/api/models.dart';

/// 订阅频道
class Subscription {
  final String id;
  final String name;
  final String? avatarUrl;
  final int videoCount;
  final DateTime subscribedAt;

  const Subscription({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.videoCount = 0,
    required this.subscribedAt,
  });
}

/// 收藏状态
class FavoritesState {
  static final FavoritesState _instance = FavoritesState._();
  factory FavoritesState() => _instance;
  FavoritesState._();

  // 收藏的视频
  final videos = signal<List<ApiVideoCard>>([]);

  // 是否正在加载
  final isLoading = signal(false);
  final hasMore = signal(true);
  final error = signal<String?>(null);

  int _currentPage = 1;

  /// 加载收藏视频
  Future<void> load({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
    }

    isLoading.value = true;
    error.value = null;

    try {
      final result = await user_api.getFavorites(page: _currentPage);

      if (refresh) {
        videos.value = result.videos;
      } else {
        videos.value = [...videos.value, ...result.videos];
      }

      hasMore.value = result.hasNext;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (isLoading.value || !hasMore.value) return;
    _currentPage++;
    await load();
  }

  /// 添加收藏
  Future<bool> addFavorite(String videoId) async {
    try {
      // TODO: 调用 API 添加收藏
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 移除收藏
  Future<bool> removeFavorite(String videoId) async {
    try {
      // TODO: 调用 API 移除收藏
      videos.value = videos.value.where((v) => v.id != videoId).toList();
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// 稍后观看状态
class WatchLaterState {
  static final WatchLaterState _instance = WatchLaterState._();
  factory WatchLaterState() => _instance;
  WatchLaterState._();

  final videos = signal<List<ApiVideoCard>>([]);
  final isLoading = signal(false);
  final hasMore = signal(true);
  final error = signal<String?>(null);

  int _currentPage = 1;

  /// 加载稍后观看
  Future<void> load({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
    }

    isLoading.value = true;
    error.value = null;

    try {
      final result = await user_api.getWatchLater(page: _currentPage);

      if (refresh) {
        videos.value = result.videos;
      } else {
        videos.value = [...videos.value, ...result.videos];
      }

      hasMore.value = result.hasNext;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (isLoading.value || !hasMore.value) return;
    _currentPage++;
    await load();
  }

  /// 添加到稍后观看
  Future<bool> add(String videoId) async {
    try {
      // TODO: 调用 API
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 从稍后观看移除
  Future<bool> remove(String videoId) async {
    try {
      // TODO: 调用 API
      videos.value = videos.value.where((v) => v.id != videoId).toList();
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// 订阅状态
class SubscriptionsState {
  static final SubscriptionsState _instance = SubscriptionsState._();
  factory SubscriptionsState() => _instance;
  SubscriptionsState._();

  final authors = signal<List<ApiAuthorInfo>>([]);
  final isLoading = signal(false);
  final error = signal<String?>(null);

  /// 加载订阅列表
  Future<void> load() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = null;

    try {
      final result = await user_api.getSubscribedAuthors();
      authors.value = result;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// 订阅
  Future<bool> subscribe(String authorId) async {
    try {
      await user_api.subscribeAuthor(authorId: authorId);
      await load();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 取消订阅
  Future<bool> unsubscribe(String authorId) async {
    try {
      await user_api.unsubscribeAuthor(authorId: authorId);
      authors.value = authors.value.where((a) => a.id != authorId).toList();
      return true;
    } catch (e) {
      return false;
    }
  }
}

// 全局实例
final favoritesState = FavoritesState();
final watchLaterState = WatchLaterState();
final subscriptionsState = SubscriptionsState();
