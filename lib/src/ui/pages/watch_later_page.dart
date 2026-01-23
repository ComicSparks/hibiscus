// 稍后观看页

import 'package:flutter/material.dart';
import '../widgets/video_grid.dart';

class WatchLaterPage extends StatelessWidget {
  const WatchLaterPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('稍后观看'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _showClearDialog(context);
            },
            tooltip: '清空列表',
          ),
        ],
      ),
      body: _buildContent(context, theme),
    );
  }
  
  Widget _buildContent(BuildContext context, ThemeData theme) {
    // Mock 数据 - 空状态
    const isEmpty = false;
    
    if (isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.watch_later_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '稀后观看列表为空',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '浏览视频时点击稀后观看按钮添加',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }
    
    // Mock 稍后观看列表
    final mockWatchLater = List.generate(8, (index) => VideoItem(
      id: 'wl_$index',
      title: '稀后观看的视频 $index - 这是一个很长的标题',
      coverUrl: '',
      duration: '${(index + 1) * 3}:${(index * 11) % 60}'.padLeft(5, '0'),
      views: '${(index + 1) * 500}',
    ));
    
    return VideoGrid(videos: mockWatchLater);
  }
  
  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空稀后观看'),
        content: const Text('确定要清空稀后观看列表吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 清空列表
            },
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }
}
