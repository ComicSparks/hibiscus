// 下载管理页

import 'package:flutter/material.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Mock 下载任务数据
    final downloads = <_DownloadItem>[
      _DownloadItem(
        title: '视频标题 1',
        quality: '1080p',
        progress: 0.75,
        status: _DownloadStatus.downloading,
        size: '128 MB / 170 MB',
      ),
      _DownloadItem(
        title: '视频标题 2',
        quality: '720p',
        progress: 0.3,
        status: _DownloadStatus.paused,
        size: '45 MB / 150 MB',
      ),
      _DownloadItem(
        title: '视频标题 3',
        quality: '1080p',
        progress: 1.0,
        status: _DownloadStatus.completed,
        size: '200 MB',
      ),
      _DownloadItem(
        title: '视频标题 4',
        quality: '480p',
        progress: 0.0,
        status: _DownloadStatus.waiting,
        size: '等待中',
      ),
    ];
    
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
              const PopupMenuItem(
                value: 'clear_completed',
                child: ListTile(
                  leading: Icon(Icons.clear_all),
                  title: Text('清除已完成'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            onSelected: (value) {
              // TODO: 处理菜单操作
            },
          ),
        ],
      ),
      body: downloads.isEmpty
          ? Center(
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
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: downloads.length,
              itemBuilder: (context, index) {
                final item = downloads[index];
                return _DownloadListTile(item: item);
              },
            ),
    );
  }
}

enum _DownloadStatus { downloading, paused, completed, waiting, error }

class _DownloadItem {
  final String title;
  final String quality;
  final double progress;
  final _DownloadStatus status;
  final String size;
  
  _DownloadItem({
    required this.title,
    required this.quality,
    required this.progress,
    required this.status,
    required this.size,
  });
}

class _DownloadListTile extends StatelessWidget {
  final _DownloadItem item;
  
  const _DownloadListTile({required this.item});
  
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
                  Container(
                    width: 80,
                    height: 45,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.movie_outlined, size: 24),
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
                          '${item.quality} · ${item.size}',
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
              if (item.status != _DownloadStatus.completed) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: item.progress,
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
    switch (item.status) {
      case _DownloadStatus.downloading:
        return IconButton(
          icon: const Icon(Icons.pause),
          onPressed: () {},
          tooltip: '暂停',
        );
      case _DownloadStatus.paused:
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () {},
          tooltip: '恢复',
        );
      case _DownloadStatus.completed:
        return IconButton(
          icon: const Icon(Icons.play_circle_filled),
          onPressed: () {},
          tooltip: '播放',
        );
      case _DownloadStatus.waiting:
        return IconButton(
          icon: const Icon(Icons.hourglass_empty),
          onPressed: null,
          tooltip: '等待中',
        );
      case _DownloadStatus.error:
        return IconButton(
          icon: const Icon(Icons.error_outline, color: Colors.red),
          onPressed: () {},
          tooltip: '重试',
        );
    }
  }
}
