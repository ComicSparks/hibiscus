// 播放历史页

import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Mock 历史记录数据
    final historyGroups = <_HistoryGroup>[
      _HistoryGroup(
        date: '今天',
        items: List.generate(3, (i) => _mockHistoryItem(i)),
      ),
      _HistoryGroup(
        date: '昨天',
        items: List.generate(5, (i) => _mockHistoryItem(i + 3)),
      ),
      _HistoryGroup(
        date: '2024年1月15日',
        items: List.generate(2, (i) => _mockHistoryItem(i + 8)),
      ),
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('播放历史'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _showClearHistoryDialog(context);
            },
            tooltip: '清除历史',
          ),
        ],
      ),
      body: historyGroups.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无播放记录',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: historyGroups.length,
              itemBuilder: (context, index) {
                final group = historyGroups[index];
                return _HistorySection(group: group);
              },
            ),
    );
  }
  
  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除播放历史'),
        content: const Text('确定要清除所有播放历史吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 清除历史
            },
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }
}

_HistoryItem _mockHistoryItem(int index) {
  return _HistoryItem(
    videoId: 'video_$index',
    title: '视频标题 $index - 这是一个很长的标题用于测试文本溢出效果',
    coverUrl: '',
    duration: '12:34',
    watchedAt: DateTime.now().subtract(Duration(hours: index)),
    progress: 0.3 + (index * 0.1) % 0.7,
  );
}

class _HistoryGroup {
  final String date;
  final List<_HistoryItem> items;
  
  _HistoryGroup({required this.date, required this.items});
}

class _HistoryItem {
  final String videoId;
  final String title;
  final String coverUrl;
  final String duration;
  final DateTime watchedAt;
  final double progress; // 0.0 - 1.0
  
  _HistoryItem({
    required this.videoId,
    required this.title,
    required this.coverUrl,
    required this.duration,
    required this.watchedAt,
    required this.progress,
  });
}

class _HistorySection extends StatelessWidget {
  final _HistoryGroup group;
  
  const _HistorySection({required this.group});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            group.date,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ...group.items.map((item) => _HistoryListTile(item: item)),
      ],
    );
  }
}

class _HistoryListTile extends StatelessWidget {
  final _HistoryItem item;
  
  const _HistoryListTile({required this.item});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        // TODO: 跳转到视频详情
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 缩略图
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 68,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.movie_outlined, size: 32),
                ),
                // 进度条
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    child: LinearProgressIndicator(
                      value: item.progress,
                      minHeight: 3,
                      backgroundColor: Colors.black26,
                      valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                    ),
                  ),
                ),
                // 时长
                Positioned(
                  right: 4,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      item.duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // 信息
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
                    _formatWatchedAt(item.watchedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // 删除按钮
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                // TODO: 删除单条记录
              },
              tooltip: '删除',
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatWatchedAt(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} 分钟前';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} 小时前';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
