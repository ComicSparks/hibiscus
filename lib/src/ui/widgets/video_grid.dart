// 视频网格组件

import 'package:flutter/material.dart';
import 'package:hibiscus/src/router/router.dart';
import 'package:hibiscus/src/rust/api/models.dart';
import 'package:hibiscus/src/ui/theme/app_theme.dart';
import 'package:hibiscus/src/ui/widgets/video_card.dart';

class VideoGrid extends StatelessWidget {
  final ScrollController? controller;
  final List<ApiVideoCard> videos;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  
  const VideoGrid({
    super.key,
    this.controller,
    required this.videos,
    this.isLoading = false,
    this.hasMore = true,
    this.onLoadMore,
  });
  
  @override
  Widget build(BuildContext context) {
    final columns = Breakpoints.getGridColumns(context);
    
    // 显示空状态或加载中
    if (videos.isEmpty) {
      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return _buildEmptyState(context);
    }
    
    return GridView.builder(
      controller: controller,
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        // 宽高比 = 宽度/高度，越大高度越小
        // 16:9 封面需要 height = width * 9/16
        // 标题区约 60-70px
        childAspectRatio: 1.2,
      ),
      itemCount: videos.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // 加载更多指示器
        if (index >= videos.length) {
          return _buildLoadingIndicator();
        }
        
        final video = videos[index];
        return VideoCard(
          video: video,
          onTap: () => context.pushVideo(video.id),
        );
      },
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无视频',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '试试其他搜索条件',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ),
    );
  }
}
