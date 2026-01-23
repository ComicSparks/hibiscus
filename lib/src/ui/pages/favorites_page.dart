// 收藏页

import 'package:flutter/material.dart';
import '../widgets/video_grid.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
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
              Icons.favorite_outline,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无收藏',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '浏览视频时点击收藏按钮添加',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }
    
    // Mock 收藏列表
    final mockFavorites = List.generate(12, (index) => VideoItem(
      id: 'fav_$index',
      title: '收藏的视频 $index - 这是一个很长的标题用于测试文本溢出效果',
      coverUrl: '',
      duration: '${(index + 1) * 5}:${(index * 7) % 60}'.padLeft(5, '0'),
      views: '${(index + 1) * 1000}',
    ));
    
    return VideoGrid(videos: mockFavorites);
  }
}
