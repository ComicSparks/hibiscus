// 下载管理页

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:hibiscus/src/rust/api/download.dart' as download_api;
import 'package:hibiscus/src/rust/api/models.dart';
import 'package:hibiscus/src/state/download_state.dart';
import 'package:hibiscus/src/router/router.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  final _items = signal<List<ApiDownloadTask>>([]);
  final _isLoading = signal(false);
  final _error = signal<String?>(null);
  late final void Function() _refreshDispose;

  @override
  void initState() {
    super.initState();
    _loadDownloads();
    _refreshDispose = effect(() {
      downloadState.refreshTick.value;
      _loadDownloads();
    });
  }

  @override
  void dispose() {
    _refreshDispose();
    super.dispose();
  }

  Future<void> _loadDownloads() async {
    _isLoading.value = true;
    _error.value = null;
    try {
      final items = await download_api.getAllDownloads();
      _items.value = items;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _pauseAll() async {
    await download_api.pauseAllDownloads();
    await _loadDownloads();
  }

  Future<void> _resumeAll() async {
    await download_api.resumeAllDownloads();
    await _loadDownloads();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('下载管理'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pause_all',
                child: ListTile(
                  leading: Icon(Icons.pause),
                  title: Text('全部暂停'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'resume_all',
                child: ListTile(
                  leading: Icon(Icons.play_arrow),
                  title: Text('全部恢复'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            onSelected: (value) async {
              switch (value) {
                case 'pause_all':
                  await _pauseAll();
                  break;
                case 'resume_all':
                  await _resumeAll();
                  break;
              }
            },
          ),
        ],
      ),
      body: Watch((context) {
        final items = _items.value;
        final isLoading = _isLoading.value;
        final error = _error.value;

        if (isLoading && items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (error != null && items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
                  const SizedBox(height: 8),
                  Text(error, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _loadDownloads,
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          );
        }

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无下载任务',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return _buildList(context, items);
      }),
    );
  }

  Widget _buildList(BuildContext context, List<ApiDownloadTask> items) {
    if (items.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return RefreshIndicator(
      onRefresh: _loadDownloads,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _DownloadListTile(
            item: item,
            onTap: () => context.pushVideo(item.videoId),
            onPause: () async {
              await download_api.pauseDownload(taskId: item.id);
              await _loadDownloads();
            },
            onResume: () async {
              await download_api.resumeDownload(taskId: item.id);
              await _loadDownloads();
            },
            onDelete: () async {
              await download_api.deleteDownload(taskId: item.id, deleteFile: false);
              await _loadDownloads();
            },
          );
        },
      ),
    );
  }
}

class _DownloadListTile extends StatelessWidget {
  final ApiDownloadTask item;
  final VoidCallback onTap;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onDelete;

  const _DownloadListTile({
    required this.item,
    required this.onTap,
    required this.onPause,
    required this.onResume,
    required this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 缩略图占位
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      width: 80,
                      height: 45,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.movie_outlined, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.quality} · ${_formatSize(item.downloadedBytes, item.totalBytes)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusButton(context),
                ],
              ),
              if (item.status is! ApiDownloadStatus_Completed) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: item.progress <= 0 ? null : item.progress,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusButton(BuildContext context) {
    if (item.status is ApiDownloadStatus_Downloading) {
        return IconButton(
          icon: const Icon(Icons.pause),
          onPressed: onPause,
          tooltip: '暂停',
        );
    }
    if (item.status is ApiDownloadStatus_Paused) {
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: onResume,
          tooltip: '恢复',
        );
    }
    if (item.status is ApiDownloadStatus_Completed) {
        return IconButton(
          icon: const Icon(Icons.play_circle_filled),
        onPressed: onTap,
          tooltip: '播放',
        );
    }
    if (item.status is ApiDownloadStatus_Pending) {
        return IconButton(
          icon: const Icon(Icons.hourglass_empty),
          onPressed: null,
          tooltip: '等待中',
        );
    }
    if (item.status is ApiDownloadStatus_Failed) {
        return IconButton(
          icon: const Icon(Icons.error_outline, color: Colors.red),
          onPressed: onResume,
          tooltip: '重试',
        );
    }
    return IconButton(
      icon: const Icon(Icons.more_horiz),
      onPressed: onDelete,
      tooltip: '删除',
    );
  }
}

String _formatSize(BigInt downloaded, BigInt total) {
  String fmt(BigInt bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    int unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(size < 10 ? 1 : 0)} ${units[unitIndex]}';
  }

  if (total == BigInt.zero) {
    return fmt(downloaded);
  }
  return '${fmt(downloaded)} / ${fmt(total)}';
}
