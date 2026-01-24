// 视频卡片组件

import 'package:flutter/material.dart';
import 'package:hibiscus/src/rust/api/models.dart';

class VideoCard extends StatelessWidget {
  final ApiVideoCard video;
  final VoidCallback? onTap;
  final double sizeScale;
  final bool selectionMode;
  final bool selected;
  
  const VideoCard({
    super.key,
    required this.video,
    this.onTap,
    this.sizeScale = 1.0,
    this.selectionMode = false,
    this.selected = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    TextStyle? scaled(TextStyle? style, double fallback) {
      final base = style?.fontSize ?? fallback;
      return (style ?? const TextStyle()).copyWith(fontSize: base * sizeScale);
    }
    
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: selected
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colorScheme.primary, width: 2),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 封面
                  _buildCover(context),

                  // 多选状态标记
                  if (selectionMode)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 28 * sizeScale,
                        height: 28 * sizeScale,
                        decoration: BoxDecoration(
                          color: selected ? colorScheme.primary : Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          selected ? Icons.check : Icons.circle_outlined,
                          size: 18 * sizeScale,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  
                  // 时长标签
                  if (video.duration != null)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6 * sizeScale,
                          vertical: 2 * sizeScale,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4 * sizeScale),
                        ),
                        child: Text(
                          video.duration!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12 * sizeScale,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // 信息区域
            Padding(
              padding: EdgeInsets.all(8 * sizeScale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题
                  Text(
                    video.title,
                    style: scaled(theme.textTheme.bodyMedium, 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4 * sizeScale),
                  // 播放量
                  if (video.views != null)
                    Text(
                      '${video.views} 播放',
                      style: scaled(theme.textTheme.bodySmall, 12)?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCover(BuildContext context) {
    final theme = Theme.of(context);
    
    // 使用占位图，后续替换为 cached_network_image
    if (video.coverUrl.isEmpty || video.coverUrl.startsWith('https://via.placeholder')) {
      return Container(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.video_library_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
        ),
      );
    }
    
    return Image.network(
      video.coverUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}
