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
    const padding = EdgeInsets.all(12);
    const spacing = 12.0;
    
    // 显示空状态或加载中
    if (videos.isEmpty) {
      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return _buildEmptyState(context);
    }

    final showViews = videos.any((v) => v.views != null);

    return LayoutBuilder(
      builder: (context, constraints) {
        final childAspectRatio = _calculateChildAspectRatio(
          context: context,
          columns: columns,
          maxWidth: constraints.maxWidth,
          padding: padding,
          spacing: spacing,
          showViews: showViews,
        );

        return GridView.builder(
          controller: controller,
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
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
      },
    );
  }

  double _calculateChildAspectRatio({
    required BuildContext context,
    required int columns,
    required double maxWidth,
    required EdgeInsets padding,
    required double spacing,
    required bool showViews,
  }) {
    if (columns <= 0 || maxWidth <= 0) return 1.0;

    final available = maxWidth - padding.horizontal - spacing * (columns - 1);
    final itemWidth = available / columns;
    if (itemWidth <= 0) return 1.0;

    // 卡片高度 = 封面(16:9) + 信息区(文字+padding)
    final coverHeight = itemWidth * 9 / 16;
    final infoHeight = _estimateInfoHeight(context, showViews: showViews);
    final itemHeight = coverHeight + infoHeight + 4;

    return itemWidth / itemHeight;
  }

  double _estimateInfoHeight(BuildContext context, {required bool showViews}) {
    const paddingVertical = 8.0 * 2;
    const betweenText = 4.0;

    final theme = Theme.of(context);
    final scaler = MediaQuery.textScalerOf(context);

    double lineHeight(TextStyle? style, double fallback) {
      final fontSize = style?.fontSize ?? fallback;
      final heightFactor = style?.height ?? 1.2;
      final scaledFontSize = scaler.scale(fontSize);
      return scaledFontSize * heightFactor;
    }

    final titleLine = lineHeight(theme.textTheme.bodyMedium, 14);
    final viewsLine = showViews ? lineHeight(theme.textTheme.bodySmall, 12) : 0.0;

    return paddingVertical + titleLine + (showViews ? (betweenText + viewsLine) : 0.0);
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
            color: theme.colorScheme.onSurfaceVariant.withAlpha(128),
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
              color: theme.colorScheme.onSurfaceVariant.withAlpha(179),
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
