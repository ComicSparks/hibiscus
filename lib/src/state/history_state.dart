// 历史记录状态管理

import 'package:signals/signals_flutter.dart';
import '../ui/widgets/video_grid.dart';

/// 历史记录项
class HistoryItem {
  final String videoId;
  final String title;
  final String coverUrl;
  final String duration;
  final DateTime watchedAt;
  final int watchProgress; // 观看进度（秒）
  final int totalDuration; // 总时长（秒）
  
  const HistoryItem({
    required this.videoId,
    required this.title,
    required this.coverUrl,
    required this.duration,
    required this.watchedAt,
    this.watchProgress = 0,
    this.totalDuration = 0,
  });
  
  /// 观看进度百分比
  double get progressPercent {
    if (totalDuration == 0) return 0;
    return watchProgress / totalDuration;
  }
  
  /// 转换为 VideoItem
  VideoItem toVideoItem() {
    return VideoItem(
      id: videoId,
      title: title,
      coverUrl: coverUrl,
      duration: duration,
      views: '',
      tags: [],
    );
  }
  
  HistoryItem copyWith({
    DateTime? watchedAt,
    int? watchProgress,
    int? totalDuration,
  }) {
    return HistoryItem(
      videoId: videoId,
      title: title,
      coverUrl: coverUrl,
      duration: duration,
      watchedAt: watchedAt ?? this.watchedAt,
      watchProgress: watchProgress ?? this.watchProgress,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }
}

/// 历史记录状态
class HistoryState {
  // 单例
  static final HistoryState _instance = HistoryState._();
  factory HistoryState() => _instance;
  HistoryState._();
  
  // 历史记录列表
  final items = signal<List<HistoryItem>>([]);
  
  // 是否正在加载
  final isLoading = signal(false);
  
  /// 加载历史记录
  Future<void> load() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    
    try {
      // TODO: 从 SQLite 加载
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 模拟数据
      items.value = List.generate(
        10,
        (i) => HistoryItem(
          videoId: 'video_$i',
          title: '歷史視頻 $i',
          coverUrl: '',
          duration: '${20 + i}:00',
          watchedAt: DateTime.now().subtract(Duration(hours: i)),
          watchProgress: 300 + i * 60,
          totalDuration: 1200 + i * 60,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 添加/更新历史记录
  Future<void> add({
    required String videoId,
    required String title,
    required String coverUrl,
    required String duration,
    int watchProgress = 0,
    int totalDuration = 0,
  }) async {
    // 移除旧记录（如果存在）
    final filtered = items.value.where((i) => i.videoId != videoId).toList();
    
    // 添加到列表开头
    items.value = [
      HistoryItem(
        videoId: videoId,
        title: title,
        coverUrl: coverUrl,
        duration: duration,
        watchedAt: DateTime.now(),
        watchProgress: watchProgress,
        totalDuration: totalDuration,
      ),
      ...filtered,
    ];
    
    // TODO: 保存到 SQLite
  }
  
  /// 更新观看进度
  Future<void> updateProgress(String videoId, int progress, int total) async {
    items.value = items.value.map((item) {
      if (item.videoId == videoId) {
        return item.copyWith(
          watchedAt: DateTime.now(),
          watchProgress: progress,
          totalDuration: total,
        );
      }
      return item;
    }).toList();
    
    // TODO: 保存到 SQLite
  }
  
  /// 删除历史记录
  Future<void> remove(String videoId) async {
    items.value = items.value.where((i) => i.videoId != videoId).toList();
    
    // TODO: 从 SQLite 删除
  }
  
  /// 清空历史记录
  Future<void> clear() async {
    items.value = [];
    
    // TODO: 清空 SQLite 表
  }
  
  /// 检查是否有该视频的历史记录
  HistoryItem? getByVideoId(String videoId) {
    try {
      return items.value.firstWhere((i) => i.videoId == videoId);
    } catch (_) {
      return null;
    }
  }
}

/// 全局历史记录状态实例
final historyState = HistoryState();
