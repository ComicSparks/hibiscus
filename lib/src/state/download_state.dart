// 下载状态管理

import 'package:signals/signals_flutter.dart';

/// 下载任务状态
enum DownloadTaskStatus {
  pending,    // 等待中
  downloading, // 下载中
  paused,     // 已暂停
  completed,  // 已完成
  failed,     // 失败
}

/// 下载任务
class DownloadTask {
  final String id;
  final String videoId;
  final String title;
  final String coverUrl;
  final String videoUrl;
  final int totalBytes;
  final int downloadedBytes;
  final DownloadTaskStatus status;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;
  
  const DownloadTask({
    required this.id,
    required this.videoId,
    required this.title,
    required this.coverUrl,
    required this.videoUrl,
    this.totalBytes = 0,
    this.downloadedBytes = 0,
    this.status = DownloadTaskStatus.pending,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
  });
  
  /// 下载进度 (0.0 - 1.0)
  double get progress {
    if (totalBytes == 0) return 0;
    return downloadedBytes / totalBytes;
  }
  
  /// 进度百分比文本
  String get progressText => '${(progress * 100).toStringAsFixed(1)}%';
  
  /// 已下载大小文本
  String get downloadedText => _formatBytes(downloadedBytes);
  
  /// 总大小文本
  String get totalText => _formatBytes(totalBytes);
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
  
  DownloadTask copyWith({
    int? totalBytes,
    int? downloadedBytes,
    DownloadTaskStatus? status,
    String? errorMessage,
    DateTime? completedAt,
  }) {
    return DownloadTask(
      id: id,
      videoId: videoId,
      title: title,
      coverUrl: coverUrl,
      videoUrl: videoUrl,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// 下载状态
class DownloadState {
  // 单例
  static final DownloadState _instance = DownloadState._();
  factory DownloadState() => _instance;
  DownloadState._();
  
  // 所有下载任务
  final tasks = signal<List<DownloadTask>>([]);
  
  // 最大并发下载数
  final maxConcurrent = signal(3);
  
  /// 下载中的任务
  List<DownloadTask> get downloadingTasks => 
      tasks.value.where((t) => t.status == DownloadTaskStatus.downloading).toList();
  
  /// 等待中的任务
  List<DownloadTask> get pendingTasks =>
      tasks.value.where((t) => t.status == DownloadTaskStatus.pending).toList();
  
  /// 已完成的任务
  List<DownloadTask> get completedTasks =>
      tasks.value.where((t) => t.status == DownloadTaskStatus.completed).toList();
  
  /// 添加下载任务
  Future<void> addTask({
    required String videoId,
    required String title,
    required String coverUrl,
    required String videoUrl,
  }) async {
    // 检查是否已存在
    final exists = tasks.value.any((t) => t.videoId == videoId);
    if (exists) return;
    
    final task = DownloadTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      videoId: videoId,
      title: title,
      coverUrl: coverUrl,
      videoUrl: videoUrl,
      createdAt: DateTime.now(),
    );
    
    tasks.value = [...tasks.value, task];
    
    // TODO: 保存到数据库
    // TODO: 开始下载
    _processQueue();
  }
  
  /// 暂停任务
  void pauseTask(String taskId) {
    tasks.value = tasks.value.map((t) {
      if (t.id == taskId && t.status == DownloadTaskStatus.downloading) {
        return t.copyWith(status: DownloadTaskStatus.paused);
      }
      return t;
    }).toList();
    
    // TODO: 通知 Rust 暂停下载
    _processQueue();
  }
  
  /// 恢复任务
  void resumeTask(String taskId) {
    tasks.value = tasks.value.map((t) {
      if (t.id == taskId && t.status == DownloadTaskStatus.paused) {
        return t.copyWith(status: DownloadTaskStatus.pending);
      }
      return t;
    }).toList();
    
    _processQueue();
  }
  
  /// 删除任务
  void removeTask(String taskId) {
    tasks.value = tasks.value.where((t) => t.id != taskId).toList();
    
    // TODO: 从数据库删除
    // TODO: 删除已下载的文件
  }
  
  /// 重试失败的任务
  void retryTask(String taskId) {
    tasks.value = tasks.value.map((t) {
      if (t.id == taskId && t.status == DownloadTaskStatus.failed) {
        return t.copyWith(
          status: DownloadTaskStatus.pending,
          errorMessage: null,
          downloadedBytes: 0,
        );
      }
      return t;
    }).toList();
    
    _processQueue();
  }
  
  /// 暂停所有
  void pauseAll() {
    tasks.value = tasks.value.map((t) {
      if (t.status == DownloadTaskStatus.downloading ||
          t.status == DownloadTaskStatus.pending) {
        return t.copyWith(status: DownloadTaskStatus.paused);
      }
      return t;
    }).toList();
  }
  
  /// 恢复所有
  void resumeAll() {
    tasks.value = tasks.value.map((t) {
      if (t.status == DownloadTaskStatus.paused) {
        return t.copyWith(status: DownloadTaskStatus.pending);
      }
      return t;
    }).toList();
    
    _processQueue();
  }
  
  /// 清除已完成
  void clearCompleted() {
    tasks.value = tasks.value
        .where((t) => t.status != DownloadTaskStatus.completed)
        .toList();
  }
  
  /// 更新任务进度
  void updateProgress(String taskId, int downloaded, int total) {
    tasks.value = tasks.value.map((t) {
      if (t.id == taskId) {
        return t.copyWith(
          downloadedBytes: downloaded,
          totalBytes: total,
          status: DownloadTaskStatus.downloading,
        );
      }
      return t;
    }).toList();
  }
  
  /// 任务完成
  void completeTask(String taskId) {
    tasks.value = tasks.value.map((t) {
      if (t.id == taskId) {
        return t.copyWith(
          status: DownloadTaskStatus.completed,
          completedAt: DateTime.now(),
        );
      }
      return t;
    }).toList();
    
    _processQueue();
  }
  
  /// 任务失败
  void failTask(String taskId, String error) {
    tasks.value = tasks.value.map((t) {
      if (t.id == taskId) {
        return t.copyWith(
          status: DownloadTaskStatus.failed,
          errorMessage: error,
        );
      }
      return t;
    }).toList();
    
    _processQueue();
  }
  
  /// 处理下载队列
  void _processQueue() {
    final downloading = downloadingTasks.length;
    final canStart = maxConcurrent.value - downloading;
    
    if (canStart <= 0) return;
    
    final toStart = pendingTasks.take(canStart).toList();
    
    for (final task in toStart) {
      // 更新状态为下载中
      tasks.value = tasks.value.map((t) {
        if (t.id == task.id) {
          return t.copyWith(status: DownloadTaskStatus.downloading);
        }
        return t;
      }).toList();
      
      // TODO: 调用 Rust 开始下载
      _startDownload(task);
    }
  }
  
  /// 开始下载任务
  Future<void> _startDownload(DownloadTask task) async {
    // TODO: 调用 Rust API 下载
    // 这里模拟下载进度
    
    for (var i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      
      // 检查是否暂停
      final current = tasks.value.firstWhere(
        (t) => t.id == task.id,
        orElse: () => task,
      );
      if (current.status != DownloadTaskStatus.downloading) return;
      
      updateProgress(task.id, i * 1024 * 1024, 100 * 1024 * 1024);
    }
    
    completeTask(task.id);
  }
  
  /// 从数据库加载任务
  Future<void> loadTasks() async {
    // TODO: 从 Rust/SQLite 加载
  }
}

/// 全局下载状态实例
final downloadState = DownloadState();
