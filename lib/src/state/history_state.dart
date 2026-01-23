// 播放历史状态管理

import 'package:signals/signals_flutter.dart';
import 'package:hibiscus/src/rust/api/user.dart' as user_api;
import 'package:hibiscus/src/rust/api/models.dart';

/// 播放历史状态
class HistoryState {
  static final HistoryState _instance = HistoryState._();
  factory HistoryState() => _instance;
  HistoryState._();

  final items = signal<List<ApiPlayHistory>>([]);
  final isLoading = signal(false);
  final hasMore = signal(true);
  final error = signal<String?>(null);

  int _currentPage = 1;
  static const _pageSize = 20;

  /// 加载历史记录
  Future<void> load({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
    }

    isLoading.value = true;
    error.value = null;

    try {
      final result = await user_api.getPlayHistory(
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (refresh) {
        items.value = result.items;
      } else {
        items.value = [...items.value, ...result.items];
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

  /// 更新播放进度
  Future<void> updateProgress({
    required String videoId,
    required String title,
    required String coverUrl,
    required double progress,
    required int duration,
  }) async {
    try {
      await user_api.updatePlayHistory(
        videoId: videoId,
        title: title,
        coverUrl: coverUrl,
        progress: progress,
        duration: duration,
      );
    } catch (e) {
      // 忽略错误
    }
  }

  /// 删除单条记录
  Future<void> delete(String videoId) async {
    try {
      await user_api.deletePlayHistory(videoId: videoId);
      items.value = items.value.where((i) => i.videoId != videoId).toList();
    } catch (e) {
      // 忽略错误
    }
  }

  /// 清空历史
  Future<void> clearAll() async {
    try {
      await user_api.clearPlayHistory();
      items.value = [];
    } catch (e) {
      // 忽略错误
    }
  }
}

// 全局实例
final historyState = HistoryState();
