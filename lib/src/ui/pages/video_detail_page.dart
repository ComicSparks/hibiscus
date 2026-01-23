// 视频详情页

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import 'package:hibiscus/src/rust/api/video.dart' as video_api;
import 'package:hibiscus/src/rust/api/models.dart';
import 'package:hibiscus/src/state/search_state.dart';

/// 视频详情状态
class _VideoDetailState {
  final videoDetail = signal<ApiVideoDetail?>(null);
  final isLoading = signal(false);
  final error = signal<String?>(null);
  final isFavorite = signal(false);
  final selectedQuality = signal<String?>(null);
  final videoUrl = signal<String?>(null);

  Future<void> loadVideoDetail(String videoId) async {
    isLoading.value = true;
    error.value = null;

    try {
      final detail = await video_api.getVideoDetail(videoId: videoId);
      videoDetail.value = detail;
      
      // 默认选择第一个清晰度
      if (detail.qualities.isNotEmpty) {
        selectedQuality.value = detail.qualities.first.quality;
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// 从已加载的 qualities 中获取视频 URL
  String? getVideoUrlForQuality(String? quality) {
    final detail = videoDetail.value;
    if (detail == null || quality == null) return null;
    
    for (final q in detail.qualities) {
      if (q.quality == quality) {
        return q.url;
      }
    }
    // 如果找不到对应清晰度，返回第一个
    return detail.qualities.isNotEmpty ? detail.qualities.first.url : null;
  }

  Future<void> toggleFavorite(String videoId) async {
    try {
      if (isFavorite.value) {
        await video_api.removeFromFavorites(videoId: videoId);
        isFavorite.value = false;
      } else {
        await video_api.addToFavorites(videoId: videoId);
        isFavorite.value = true;
      }
    } catch (e) {
      // 忽略错误
    }
  }

  Future<void> addToWatchLater(String videoId) async {
    try {
      await video_api.addToWatchLater(videoId: videoId);
    } catch (e) {
      // 忽略错误
    }
  }

  void reset() {
    videoDetail.value = null;
    isLoading.value = false;
    error.value = null;
    isFavorite.value = false;
    selectedQuality.value = null;
    videoUrl.value = null;
  }
}

class VideoDetailPage extends StatefulWidget {
  final String videoId;

  const VideoDetailPage({super.key, required this.videoId});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  final _state = _VideoDetailState();

  @override
  void initState() {
    super.initState();
    _state.loadVideoDetail(widget.videoId);
  }

  @override
  void dispose() {
    _state.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () => _showDownloadDialog(context),
            tooltip: '加入下载',
          ),
        ],
      ),
      body: Watch((context) {
        final isLoading = _state.isLoading.value;
        final error = _state.error.value;
        final detail = _state.videoDetail.value;

        if (isLoading && detail == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (error != null && detail == null) {
          return _buildErrorState(context, error);
        }

        if (detail == null) {
          return const Center(child: Text('视频不存在'));
        }

        return _buildContent(context, detail);
      }),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text('加载失败', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _state.loadVideoDetail(widget.videoId),
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ApiVideoDetail detail) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 播放器区域
          _buildPlayer(context, detail),

          // 视频信息
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Text(detail.title, style: theme.textTheme.titleLarge),

                const SizedBox(height: 8),

                // 统计信息
                Text(
                  '${detail.views ?? "0"} 次播放 · ${detail.uploadDate ?? "未知"}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 16),

                // 作者信息
                if (detail.author != null) _buildAuthorInfo(context, detail.author!),

                const SizedBox(height: 16),

                // 操作按钮
                _buildActionButtons(context),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // 标签
                if (detail.tags.isNotEmpty) ...[
                  Text('标签', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  _buildTags(context, detail.tags),
                  const SizedBox(height: 24),
                ],

                // 系列信息
                if (detail.series != null) ...[
                  Text('系列', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  _buildSeriesInfo(context, detail.series!),
                  const SizedBox(height: 24),
                ],

                // 相关视频
                if (detail.relatedVideos.isNotEmpty) ...[
                  Text('相关视频', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _buildRelatedVideos(context, detail.relatedVideos),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer(BuildContext context, ApiVideoDetail detail) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 封面或视频
          Container(
            color: Colors.black,
            child: detail.coverUrl.isNotEmpty
                ? Image.network(
                    detail.coverUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  )
                : null,
          ),
          // 播放按钮
          Center(
            child: IconButton.filled(
              onPressed: () {
                // 直接从 qualities 获取视频 URL
                final url = _state.getVideoUrlForQuality(_state.selectedQuality.value);
                if (url != null && url.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('视频播放器开发中...\\n视频URL: ${url.length > 60 ? "${url.substring(0, 60)}..." : url}'),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('无法获取视频链接'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.play_arrow, size: 48),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.9),
                foregroundColor: Colors.black,
              ),
            ),
          ),
          // 时长
          if (detail.duration != null)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  detail.duration!,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAuthorInfo(BuildContext context, ApiAuthorInfo author) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage:
              author.avatarUrl != null ? NetworkImage(author.avatarUrl!) : null,
          child: author.avatarUrl == null ? const Icon(Icons.person) : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(author.name, style: theme.textTheme.titleSmall),
            ],
          ),
        ),
        FilledButton.tonal(
          onPressed: () {
            // TODO: 订阅/取消订阅
          },
          child: Text(author.isSubscribed ? '已订阅' : '订阅'),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Watch((context) {
      final isFavorite = _state.isFavorite.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: isFavorite ? Icons.favorite : Icons.favorite_outline,
            label: '收藏',
            isActive: isFavorite,
            onPressed: () => _state.toggleFavorite(widget.videoId),
          ),
          _ActionButton(
            icon: Icons.watch_later_outlined,
            label: '稀后观看',
            onPressed: () => _state.addToWatchLater(widget.videoId),
          ),
          _ActionButton(
            icon: Icons.share_outlined,
            label: '分享',
            onPressed: () {
              // TODO: 分享功能
            },
          ),
        ],
      );
    });
  }

  Widget _buildTags(BuildContext context, List<String> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        return ActionChip(
          label: Text(tag),
          onPressed: () {
            // 用标签搜索
            searchState.toggleTag(tag);
            context.go('/');
          },
        );
      }).toList(),
    );
  }

  Widget _buildSeriesInfo(BuildContext context, ApiSeriesInfo series) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(series.title, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: series.videos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final video = series.videos[index];
              final isCurrent = index == series.currentIndex;

              return GestureDetector(
                onTap: isCurrent
                    ? null
                    : () => context.go('/video/${video.id}'),
                child: SizedBox(
                  width: 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: isCurrent
                                ? Border.all(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: video.coverUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    video.coverUrl,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Center(
                                  child: Text(video.episode),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        video.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isCurrent
                              ? theme.colorScheme.primary
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedVideos(BuildContext context, List<ApiVideoCard> videos) {
    final theme = Theme.of(context);

    return Column(
      children: videos.take(5).map((video) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: video.coverUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(video.coverUrl, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.video_library_outlined),
            ),
          ),
          title: Text(
            video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(video.views ?? ''),
          onTap: () => context.go('/video/${video.id}'),
        );
      }).toList(),
    );
  }

  void _showDownloadDialog(BuildContext context) {
    final detail = _state.videoDetail.value;
    if (detail == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择清晰度'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: detail.qualities.map((quality) {
            return ListTile(
              title: Text(quality.quality),
              leading: const Icon(Icons.hd),
              onTap: () {
                Navigator.pop(context);
                // TODO: 添加下载任务
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('已添加下载: ${quality.quality}')),
                );
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}

/// 操作按钮
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
