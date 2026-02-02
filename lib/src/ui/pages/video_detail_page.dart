// 视频详情页

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals/signals_flutter.dart';
import 'package:hibiscus/src/router/router.dart';
import 'package:hibiscus/browser/browser_state.dart';
import 'package:hibiscus/src/rust/api/video.dart' as video_api;
import 'package:hibiscus/src/rust/api/download.dart' as download_api;
import 'package:hibiscus/src/rust/api/user.dart' as user_api;
import 'package:hibiscus/src/rust/api/models.dart';
import 'package:hibiscus/src/state/search_state.dart';
import 'package:hibiscus/src/state/settings_state.dart';
import 'package:hibiscus/src/state/download_state.dart';
import 'package:hibiscus/src/state/user_state.dart';
import 'package:hibiscus/src/state/host_state.dart';
import 'package:hibiscus/src/ui/pages/login_page.dart';
import 'package:hibiscus/src/ui/widgets/cached_image.dart' as rust_image;
import 'package:hibiscus/src/services/webdav_sync_service.dart';
import 'package:hibiscus/src/services/player/player.dart';
import 'package:url_launcher/url_launcher.dart';

/// 视频详情状态
class _VideoDetailState {
  final videoDetail = signal<ApiVideoDetail?>(null);
  final isLoading = signal(false);
  final error = signal<String?>(null);
  final selectedQuality = signal<String?>(null);
  final downloadQuality = signal<String?>(null);
  final videoUrl = signal<String?>(null);

  Future<void> loadVideoDetail(String videoId) async {
    isLoading.value = true;
    error.value = null;

    try {
      final detail = await video_api.getVideoDetail(videoId: videoId);
      videoDetail.value = detail;
      
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
    selectedQuality.value = null;
    downloadQuality.value = null;
    videoUrl.value = null;
  }
}

class VideoDetailPage extends StatefulWidget {
  final String videoId;

  const VideoDetailPage({
    super.key,
    required this.videoId,
  });

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  final _state = _VideoDetailState();
  late final PlayerService _player;
  bool _hasOpened = false;
  Orientation _lastOrientation = Orientation.portrait;
  bool _didInitialResumeSeek = false;

  final _comments = signal<List<ApiComment>>([]);
  final _isCommentsLoading = signal(false);
  final _commentsError = signal<String?>(null);
  final _commentController = TextEditingController();

  StreamSubscription<PlayerState>? _stateSub;
  Timer? _historyTimer;
  Duration _lastPos = Duration.zero;
  Duration _lastDur = Duration.zero;
  int _lastSavedAtMs = 0;

  static const _kFallbackUserAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  Map<String, String> get _headersForPlayer {
    final hostInfo = activeHostState.activeHost.value;
    final ua = browserState.userAgent.value ?? _kFallbackUserAgent;
    return {
      'User-Agent': ua,
      'Referer': hostInfo.referer,
    };
  }

  @override
  void initState() {
    super.initState();
    // 使用单例管理器获取播放器，避免重复创建
    _player = PlayerManager.instance.acquire();
    _setupPlayerListeners();
    _loadDetail(autoPlay: true);

    _historyTimer = Timer.periodic(const Duration(seconds: 5), (_) => _flushHistory());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WebDavSyncService.autoSyncIfNeeded(context: context);
    });
  }

  void _setupPlayerListeners() {
    _stateSub = _player.stateStream.listen((state) {
      _lastPos = state.position;
      _lastDur = state.duration;
      if (mounted) setState(() {});
    });
  }

  @override
  @override
  void dispose() {
    _flushHistory(force: true);
    WebDavSyncService.autoSyncIfNeeded();
    _historyTimer?.cancel();
    _stateSub?.cancel();
    _state.reset();
    _commentController.dispose();
    
    // 释放播放器引用（单例管理）
    PlayerManager.instance.release();
    
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
    await _loadComments();
  }

  Future<void> _loadComments() async {
    _isCommentsLoading.value = true;
    _commentsError.value = null;
    try {
      final list = await video_api.getVideoComments(videoId: widget.videoId, page: 1);
      _comments.value = list.comments;
    } catch (e) {
      _commentsError.value = e.toString();
    } finally {
      _isCommentsLoading.value = false;
    }
  }

  Future<void> _loadReplies(ApiComment parent) async {
    try {
      final replies = await video_api.getCommentReplies(commentId: parent.id);
      final list = [..._comments.value];
      final idx = list.indexWhere((c) => c.id == parent.id);
      if (idx >= 0) {
        list[idx] = list[idx].copyWith(replies: replies, hasMoreReplies: false);
        _comments.value = list;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载回复失败：$e')),
      );
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    try {
      await video_api.postComment(videoId: widget.videoId, content: text, replyTo: null);
      _commentController.clear();
      await _loadComments();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('评论已发送')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发送失败：$e')),
      );
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
    debugPrint('Opening video URL: $url');
    _didInitialResumeSeek = false;
    
    // 先设置 _hasOpened 并更新 UI，移除封面
    if (!_hasOpened) {
      _hasOpened = true;
      if (mounted) setState(() {});
    }
    
    await _player.openUrl(url, headers: _headersForPlayer, autoPlay: true);
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
    // 切换清晰度时优先保持当前进度；首次播放则尝试从历史记录恢复。
    final currentPos = _lastPos;
    final seekFromCurrent =
        currentPos > Duration.zero ? currentPos : await _loadResumePosition(detail.id);
    await _openUrlWithResume(url, seekFromCurrent);
  }

  Future<Duration?> _loadResumePosition(String videoId) async {
    try {
      final history = await user_api.getVideoProgress(videoId: videoId);
      if (history == null) return null;
      final duration = history.duration;
      if (duration <= 0) return null;
      final seconds = (history.progress.clamp(0.0, 1.0) * duration).round();
      if (seconds < 3) return null;
      if (seconds >= duration - 3) return null;
      return Duration(seconds: seconds);
    } catch (_) {
      return null;
    }
  }

  Future<void> _openUrlWithResume(String url, Duration? resumeAt) async {
    if (resumeAt == null) {
      await _openUrl(url);
      return;
    }
    if (_state.videoUrl.value == url && _didInitialResumeSeek) {
      await _player.play();
      return;
    }

    _state.videoUrl.value = url;
    debugPrint('Opening video URL: $url (resume at ${resumeAt.inSeconds}s)');
    _didInitialResumeSeek = true;
    
    // 先设置 _hasOpened 并更新 UI，移除封面
    if (!_hasOpened) {
      _hasOpened = true;
      if (mounted) setState(() {});
    }
    
    await _player.openUrl(
      url,
      headers: _headersForPlayer,
      autoPlay: true,
      startPosition: resumeAt,
    );
  }

  @override
  Widget build(BuildContext context) {
    _lastOrientation = MediaQuery.of(context).orientation;
    // 更新播放器方向
    if (_player is MediaKitPlayer) {
      (_player as MediaKitPlayer).updateOrientation(_lastOrientation);
    } else if (_player is BetterPlayerAdapter) {
      (_player as BetterPlayerAdapter).updateOrientation(_lastOrientation);
    }

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
              onPressed: () => _loadDetail(autoPlay: true),
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
                if (detail.duration != null || detail.likePercent != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    [
                      if (detail.duration != null && detail.duration!.isNotEmpty)
                        '时长 ${detail.duration}',
                      if (detail.likePercent != null)
                        '👍 ${detail.likePercent}% (${detail.likesCount ?? 0}/${(detail.likesCount ?? 0) + (detail.dislikesCount ?? 0)})',
                    ].join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],

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
                  const SizedBox(height: 24),
                ],

                Text('评论', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                _buildComments(context, theme),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComments(BuildContext context, ThemeData theme) {
    return Watch((context) {
      final isLoading = _isCommentsLoading.value;
      final error = _commentsError.value;
      final comments = _comments.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (userState.isLoggedIn) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: '写下你的评论…',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: isLoading ? null : _submitComment,
                  child: const Text('发送'),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ] else ...[
            OutlinedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
                await userState.checkLoginStatus();
              },
              icon: const Icon(Icons.login),
              label: const Text('登录后发表评论'),
            ),
            const SizedBox(height: 12),
          ],
          if (isLoading && comments.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
          else if (error != null && comments.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('加载评论失败：$error', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _loadComments,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重试'),
                ),
              ],
            )
          else if (comments.isEmpty)
            Text('暂无评论', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))
          else ...[
            ...comments.map((c) => _buildCommentItem(context, theme, c)),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ],
      );
    });
  }

  Widget _buildCommentItem(BuildContext context, ThemeData theme, ApiComment c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                backgroundImage: (c.userAvatar != null && c.userAvatar!.isNotEmpty)
                    ? NetworkImage(c.userAvatar!)
                    : null,
                child: (c.userAvatar == null || c.userAvatar!.isEmpty)
                    ? const Icon(Icons.person_outline, size: 18)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.userName, style: theme.textTheme.titleSmall),
                    Text(
                      c.time,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (c.likes > 0)
                Text(
                  '👍 ${c.likes}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(c.content, style: theme.textTheme.bodyMedium),
          if (c.replies.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...c.replies.map((r) => Padding(
                  padding: const EdgeInsets.only(left: 36, top: 8),
                  child: _buildReplyItem(context, theme, r),
                )),
          ],
          if (c.hasMoreReplies) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: TextButton.icon(
                onPressed: () => _loadReplies(c),
                icon: const Icon(Icons.subdirectory_arrow_right),
                label: const Text('加载回复'),
              ),
            ),
          ],
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildReplyItem(BuildContext context, ThemeData theme, ApiComment c) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          backgroundImage: (c.userAvatar != null && c.userAvatar!.isNotEmpty)
              ? NetworkImage(c.userAvatar!)
              : null,
          child: (c.userAvatar == null || c.userAvatar!.isEmpty)
              ? const Icon(Icons.person_outline, size: 16)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.userName, style: theme.textTheme.bodyMedium),
              if (c.time.isNotEmpty)
                Text(
                  c.time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 4),
              Text(c.content, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayer(BuildContext context, ApiVideoDetail detail) {
    final state = _player.currentState;
    final isPlaying = state.isPlaying;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 视频区域
          _player.buildVideoWidget(),

          // 封面占位
          if (!_hasOpened)
            GestureDetector(
              onTap: () async {
                await _playSelectedQuality(detail);
              },
              child: Stack(children: [
                Positioned.fill(
                  child: rust_image.CachedNetworkImage(
                    imageUrl: detail.coverUrl,
                    fit: BoxFit.cover,
                    errorWidget: const SizedBox(),
                  ),
                ),
                Center(
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _buildAuthorInfo(BuildContext context, ApiAuthorInfo author) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // 头像 - 点击搜索作者
        InkWell(
          onTap: () => context.pushDiscoverWithQuery(
            author.name,
            title: '作者: ${author.name}',
          ),
          borderRadius: BorderRadius.circular(20),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: theme.colorScheme.primaryContainer,
            backgroundImage:
                author.avatarUrl != null ? NetworkImage(author.avatarUrl!) : null,
            child: author.avatarUrl == null ? const Icon(Icons.person) : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () => context.pushDiscoverWithQuery(
              author.name,
              title: '作者: ${author.name}',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(author.name, style: theme.textTheme.titleSmall),
                Text(
                  '点击查看更多',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        FilledButton.tonal(
          onPressed: () async {
            final detail = _state.videoDetail.value;
            if (detail == null) return;
            await _toggleSubscribe(detail);
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
            // 导航到独立的发现页
            context.pushDiscoverWithTags([tag], title: tag);
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
                              ? rust_image.CachedNetworkImage(
                                  imageUrl: video.coverUrl,
                                  fit: BoxFit.cover,
                                  borderRadius: BorderRadius.circular(6),
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
                  ? rust_image.CachedNetworkImage(
                      imageUrl: video.coverUrl,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(8),
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
    final hostInfo = activeHostState.activeHost.value;
    final url = '${hostInfo.baseUrl}/watch?v=${widget.videoId}';
    if (!mounted) return;
    final rootContext = context;
    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('复制链接'),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: url));
                if (!context.mounted) return;
                Navigator.pop(context);
                if (!rootContext.mounted) return;
                ScaffoldMessenger.of(rootContext).showSnackBar(
                  const SnackBar(content: Text('链接已复制')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.open_in_browser),
              title: const Text('在浏览器打开'),
              onTap: () async {
                final uri = Uri.parse(url);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleSubscribe(ApiVideoDetail detail) async {
    final author = detail.author;
    if (author == null || author.id.isEmpty) return;

    if (userState.loginStatus.value == LoginStatus.unknown) {
      await userState.checkLoginStatus();
    }

    if (!userState.isLoggedIn) {
      if (!mounted) return;
      final goLogin = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('需要登录'),
          content: const Text('订阅功能需要登录账号。'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('去登录')),
          ],
        ),
      );
      if (goLogin == true && mounted) {
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()));
        await userState.checkLoginStatus();
        await _state.loadVideoDetail(widget.videoId);
      }
      return;
    }

    ApiVideoDetail latest = detail;
    var formToken = latest.formToken;
    var userId = latest.currentUserId;
    if (formToken == null || formToken.isEmpty || userId == null || userId.isEmpty) {
      await _state.loadVideoDetail(widget.videoId);
      latest = _state.videoDetail.value ?? latest;
      formToken = latest.formToken;
      userId = latest.currentUserId;
      if (formToken == null || formToken.isEmpty || userId == null || userId.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('登录信息缺失，请刷新页面后重试')));
        return;
      }
    }

    final formTokenValue = formToken;
    final userIdValue = userId;

    try {
      final curAuthor = latest.author;
      if (curAuthor == null) return;

      if (curAuthor.isSubscribed) {
        await user_api.unsubscribeAuthor(
          artistId: curAuthor.id,
          userId: userIdValue,
          formToken: formTokenValue,
          xCsrfToken: formTokenValue,
        );
        _state.videoDetail.value =
            latest.copyWith(author: curAuthor.copyWith(isSubscribed: false));
      } else {
        await user_api.subscribeAuthor(
          artistId: curAuthor.id,
          userId: userIdValue,
          formToken: formTokenValue,
          xCsrfToken: formTokenValue,
        );
        _state.videoDetail.value =
            latest.copyWith(author: curAuthor.copyWith(isSubscribed: true));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
