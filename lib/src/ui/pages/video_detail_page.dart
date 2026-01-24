// 视频详情页

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:signals/signals_flutter.dart';
import 'package:hibiscus/src/router/router.dart';
import 'package:hibiscus/src/rust/api/video.dart' as video_api;
import 'package:hibiscus/src/rust/api/download.dart' as download_api;
import 'package:hibiscus/src/rust/api/user.dart' as user_api;
import 'package:hibiscus/src/rust/api/models.dart';
import 'package:hibiscus/src/state/search_state.dart';
import 'package:hibiscus/src/state/settings_state.dart';
import 'package:hibiscus/src/state/download_state.dart';
import 'package:hibiscus/src/state/user_state.dart';
import 'package:hibiscus/src/ui/pages/login_page.dart';

/// 视频详情状态
class _VideoDetailState {
  final videoDetail = signal<ApiVideoDetail?>(null);
  final isLoading = signal(false);
  final error = signal<String?>(null);
  final isFavorite = signal(false);
  final selectedQuality = signal<String?>(null);
  final downloadQuality = signal<String?>(null);
  final videoUrl = signal<String?>(null);

  Future<void> loadVideoDetail(String videoId) async {
    isLoading.value = true;
    error.value = null;

    try {
      final detail = await video_api.getVideoDetail(videoId: videoId);
      videoDetail.value = detail;
      isFavorite.value = detail.isFav;
      
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

  // 收藏/分享/登录相关逻辑在页面层处理

  void reset() {
    videoDetail.value = null;
    isLoading.value = false;
    error.value = null;
    isFavorite.value = false;
    selectedQuality.value = null;
    downloadQuality.value = null;
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
  late final Player _player;
  late final VideoController _controller;
  bool _hasOpened = false;

  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  Timer? _historyTimer;
  Duration _lastPos = Duration.zero;
  Duration _lastDur = Duration.zero;
  int _lastSavedAtMs = 0;

  static const Map<String, String> _kDefaultHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Referer': 'https://hanime1.me/',
  };

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _loadDetail(autoPlay: settingsState.settings.value.autoPlay);

    _posSub = _player.stream.position.listen((d) => _lastPos = d);
    _durSub = _player.stream.duration.listen((d) => _lastDur = d);
    _historyTimer = Timer.periodic(const Duration(seconds: 5), (_) => _flushHistory());
  }

  @override
  void dispose() {
    _flushHistory(force: true);
    _historyTimer?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _state.reset();
    _player.dispose();
    super.dispose();
  }

  Future<void> _flushHistory({bool force = false}) async {
    final detail = _state.videoDetail.value;
    if (detail == null) return;
    if (_lastDur <= Duration.zero) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (!force && now - _lastSavedAtMs < 4000) return;

    final durMs = _lastDur.inMilliseconds;
    if (durMs <= 0) return;
    final posMs = _lastPos.inMilliseconds.clamp(0, durMs);
    final progress = (posMs / durMs).clamp(0.0, 1.0);
    if (!force && progress <= 0) return;

    _lastSavedAtMs = now;
    try {
      await user_api.updatePlayHistory(
        videoId: detail.id,
        title: detail.title,
        coverUrl: detail.coverUrl,
        progress: progress,
        duration: _lastDur.inSeconds,
      );
    } catch (_) {
      // ignore
    }
  }

  Future<void> _loadDetail({bool autoPlay = false}) async {
    await _state.loadVideoDetail(widget.videoId);
    final detail = _state.videoDetail.value;
    if (detail == null || detail.qualities.isEmpty) return;

    final playDefault = _pickQuality(
      detail.qualities,
      settingsState.settings.value.defaultPlayQuality,
    );
    final downloadDefault = _pickQuality(
      detail.qualities,
      settingsState.settings.value.defaultDownloadQuality,
    );

    _state.selectedQuality.value ??= playDefault;
    _state.downloadQuality.value ??= downloadDefault;

    if (autoPlay) {
      await _playSelectedQuality(detail);
    }
  }

  String _pickQuality(List<ApiVideoQuality> qualities, String preferred) {
    String normalize(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');
    final preferredNorm = normalize(preferred);
    for (final q in qualities) {
      if (normalize(q.quality) == preferredNorm && preferredNorm.isNotEmpty) {
        return q.quality;
      }
    }
    return qualities.first.quality;
  }

  Future<void> _openUrl(String url) async {
    if (_state.videoUrl.value == url) {
      await _player.play();
      return;
    }
    _state.videoUrl.value = url;
    _hasOpened = true;
    await _player.open(
      Media(url, httpHeaders: _kDefaultHeaders),
      play: true,
    );
  }

  Future<void> _playSelectedQuality(ApiVideoDetail detail) async {
    final url = _state.getVideoUrlForQuality(_state.selectedQuality.value);
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('无法获取视频链接'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    await _openUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
            } else {
              navigator.pushReplacementNamed(AppRoutes.home);
            }
          },
        ),
        actions: [
          _buildQualityAction(),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: '分享',
            onPressed: _shareCurrent,
          ),
          Watch((context) {
            final isFav = _state.isFavorite.value;
            return IconButton(
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_outline),
              tooltip: isFav ? '取消收藏' : '收藏',
              onPressed: () async {
                final detail = _state.videoDetail.value;
                if (detail == null) return;
                await _toggleFavorite(detail);
              },
            );
          }),
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
              onPressed: () => _loadDetail(autoPlay: settingsState.settings.value.autoPlay),
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
                  '${detail.views ?? "0次"} 播放 · ${detail.uploadDate ?? "未知"}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 16),

                // 作者信息
                if (detail.author != null) _buildAuthorInfo(context, detail.author!),

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
          // 视频区域
          Container(
            color: Colors.black,
            child: Video(controller: _controller),
          ),
          // 封面占位
          StreamBuilder<bool>(
            stream: _player.stream.playing,
            builder: (context, snapshot) {
              final isPlaying = snapshot.data ?? false;
              if (_hasOpened || isPlaying || detail.coverUrl.isEmpty) {
                return const SizedBox();
              }
              return GestureDetector(
                onTap: () async {
                  await _playSelectedQuality(detail);
                },
                child: Stack(children: [                
                Positioned.fill(
                  child: Image.network(
                    detail.coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
                Center(
                  child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 48,
                          color: Colors.white.withOpacity(0.9),
                        ),      
                                  ),
              ])
              );
            },
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
            context.goHome();
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
                  : () => context.pushVideo(video.id),
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
          onTap: () => context.pushVideo(video.id),
        );
      }).toList(),
    );
  }

  Widget _buildQualityAction() {
    return Watch((context) {
      final detail = _state.videoDetail.value;
      if (detail == null || detail.qualities.isEmpty) {
        return const SizedBox.shrink();
      }

      return PopupMenuButton<String>(
        tooltip: '清晰度',
        onSelected: (value) async {
          _state.selectedQuality.value = value;
          settingsState.setDefaultPlayQuality(value);
          await _playSelectedQuality(detail);
        },
        itemBuilder: (context) {
          return detail.qualities
              .map(
                (quality) => PopupMenuItem<String>(
                  value: quality.quality,
                  child: Text(quality.quality),
                ),
              )
              .toList();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              const Icon(Icons.hd_outlined),
              const SizedBox(width: 4),
              Text(_state.selectedQuality.value ?? 'auto'),
            ],
          ),
        ),
      );
    });
  }

  void _showDownloadDialog(BuildContext context) {
    final rootContext = context;
    final detail = _state.videoDetail.value;
    if (detail == null) return;

    String selected = _state.downloadQuality.value ?? detail.qualities.first.quality;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('选择清晰度'),
          content: DropdownButton<String>(
            value: selected,
            isExpanded: true,
            items: detail.qualities
                .map(
                  (quality) => DropdownMenuItem<String>(
                    value: quality.quality,
                    child: Text(quality.quality),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => selected = value);
              _state.downloadQuality.value = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await download_api.addDownload(
                  videoId: detail.id,
                  title: detail.title,
                  coverUrl: detail.coverUrl,
                  quality: selected,
                  description: detail.description,
                  tags: detail.tags,
                );
                downloadState.refreshTick.value++;
                await settingsState.setDefaultDownloadQuality(selected);
                if (!rootContext.mounted) return;
                ScaffoldMessenger.of(rootContext).showSnackBar(
                  SnackBar(content: Text('已添加下载: $selected')),
                );
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareCurrent() async {
    final url = 'https://hanime1.me/watch?v=${widget.videoId}';
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('链接已复制')));
  }

  Future<void> _toggleFavorite(ApiVideoDetail detail) async {
    if (userState.loginStatus.value == LoginStatus.unknown) {
      await userState.checkLoginStatus();
    }

    if (!userState.isLoggedIn) {
      if (!mounted) return;
      final goLogin = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('需要登录'),
          content: const Text('收藏功能需要登录账号。'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('去登录')),
          ],
        ),
      );
      if (goLogin == true && mounted) {
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()));
        await userState.checkLoginStatus();
      }
      return;
    }

    final csrf = detail.csrfToken;
    final userId = detail.currentUserId;
    if (csrf == null || csrf.isEmpty || userId == null || userId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('登录信息缺失，请刷新页面后重试')));
      return;
    }

    try {
      if (_state.isFavorite.value) {
        await user_api.removeFromFavorites(videoCode: detail.id, csrfToken: csrf, userId: userId);
        _state.isFavorite.value = false;
      } else {
        await user_api.addToFavorites(videoCode: detail.id, csrfToken: csrf, userId: userId);
        _state.isFavorite.value = true;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
