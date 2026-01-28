import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hibiscus/src/router/router.dart';
import 'package:hibiscus/src/rust/api/download.dart' as download_api;
import 'package:hibiscus/src/rust/api/models.dart';
import 'package:hibiscus/src/rust/api/user.dart' as user_api;
import 'package:hibiscus/src/services/player/player.dart';
import 'package:share_plus/share_plus.dart';

class DownloadDetailPage extends StatefulWidget {
  final ApiDownloadTask task;

  const DownloadDetailPage({super.key, required this.task});

  @override
  State<DownloadDetailPage> createState() => _DownloadDetailPageState();
}

class _DownloadDetailPageState extends State<DownloadDetailPage> {
  late final PlayerService _player;

  bool _hasOpened = false;
  String? _error;
  Orientation _lastOrientation = Orientation.portrait;

  StreamSubscription<PlayerState>? _stateSub;
  Timer? _historyTimer;
  Duration _lastPos = Duration.zero;
  Duration _lastDur = Duration.zero;
  int _lastSavedAtMs = 0;

  @override
  void initState() {
    super.initState();
    // 使用单例管理器获取播放器，避免重复创建
    _player = PlayerManager.instance.acquire();
    _setupListeners();
    _open();
  }

  void _setupListeners() {
    _stateSub = _player.stateStream.listen((state) {
      _lastPos = state.position;
      _lastDur = state.duration;
      if (state.error != null) {
        _error = state.error;
      }
      if (mounted) setState(() {});
    });
    _historyTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => _flushHistory());
  }

  @override
  void dispose() {
    _flushHistory(force: true);
    _historyTimer?.cancel();
    _stateSub?.cancel();
    
    // 释放播放器引用（单例管理）
    PlayerManager.instance.release();
    
    super.dispose();
  }

  Future<void> _open() async {
    try {
      _error = null;
      var localPath = widget.task.filePath;
      if (localPath == null || localPath.isEmpty) {
        try {
          final all = await download_api.getAllDownloads();
          for (final t in all) {
            if (t.id == widget.task.id || t.videoId == widget.task.videoId) {
              localPath = t.filePath;
              break;
            }
          }
        } catch (_) {
          // ignore
        }
      }
      if (localPath != null && localPath.isNotEmpty && File(localPath).existsSync()) {
        final resumeAt = await _loadResumePosition(widget.task.videoId);
        
        // 先设置 _hasOpened 并更新 UI，移除封面
        _hasOpened = true;
        if (mounted) setState(() {});
        
        await _player.openFile(
          localPath,
          autoPlay: true,
          startPosition: resumeAt,
        );
        await _flushHistory(force: true);
        return;
      }
      _error = widget.task.status is ApiDownloadStatus_Completed
          ? '本地文件不存在'
          : '下载未完成，无法播放本地文件';
      if (mounted) setState(() {});
    } catch (e) {
      _error = e.toString();
      if (mounted) setState(() {});
    }
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

  Future<void> _flushHistory({bool force = false}) async {
    if (!_hasOpened) return;
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
        videoId: widget.task.videoId,
        title: widget.task.title,
        coverUrl: widget.task.coverUrl,
        progress: progress,
        duration: _lastDur.inSeconds,
      );
    } catch (_) {
      // ignore
    }
  }

  Future<void> _showTaskMenu() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.travel_explore),
              title: const Text('溯源'),
              onTap: () => Navigator.pop(context, 'source'),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('分享'),
              onTap: () => Navigator.pop(context, 'share'),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error),
              title: Text('删除',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;
    if (action == 'source') {
      context.pushVideo(widget.task.videoId);
      return;
    }
    if (action == 'share') {
      await _shareFile();
      return;
    }
    if (action == 'delete') {
      await _confirmDelete();
      return;
    }
  }

  Future<void> _shareFile() async {
    final localPath = widget.task.filePath;
    if (localPath == null || localPath.isEmpty || !File(localPath).existsSync()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('本地文件不存在，无法分享')),
      );
      return;
    }

    final shareOrigin = _shareOriginFromContext(context);
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(localPath)],
          subject: 'Hibiscus download',
          text: widget.task.title,
          sharePositionOrigin: shareOrigin,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('分享失败：$e')),
      );
    }
  }

  Future<void> _confirmDelete() async {
    bool deleteFile = true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('删除下载任务'),
          content: CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: deleteFile,
            onChanged: (v) => setState(() => deleteFile = v ?? true),
            title: const Text('同时删除已下载文件（含未完成的临时文件）'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('删除'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    try {
      await download_api.deleteDownload(
        taskId: widget.task.id,
        deleteFile: deleteFile,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(deleteFile ? '已删除文件' : '已移除任务')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败：$e')),
      );
    }
  }

  Rect _shareOriginFromContext(BuildContext context) {
    final renderObject = context.findRenderObject();
    final box = renderObject is RenderBox ? renderObject : null;
    if (box == null || !box.hasSize || box.size.isEmpty) {
      return const Rect.fromLTWH(1, 1, 1, 1);
    }
    final origin = box.localToGlobal(Offset.zero);
    final rect = origin & box.size;
    if (rect.isEmpty) return const Rect.fromLTWH(1, 1, 1, 1);
    return rect;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final task = widget.task;
    _lastOrientation = MediaQuery.of(context).orientation;

    // 更新播放器方向
    if (_player is MediaKitPlayer) {
      (_player as MediaKitPlayer).updateOrientation(_lastOrientation);
    } else if (_player is BetterPlayerAdapter) {
      (_player as BetterPlayerAdapter).updateOrientation(_lastOrientation);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('下载详情'),
        actions: [
          IconButton(
            tooltip: '溯源',
            icon: const Icon(Icons.travel_explore),
            onPressed: () => context.pushVideo(task.videoId),
          ),
          IconButton(
            tooltip: '更多',
            icon: const Icon(Icons.more_vert),
            onPressed: _showTaskMenu,
          ),
        ],
      ),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _player.buildVideoWidget(),
                if (!_hasOpened)
                  Positioned.fill(
                    child: _buildCover(task),
                  ),
                if (_error != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _error!,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((task.authorName ?? '').trim().isNotEmpty) ...[
                      _buildAuthor(task, theme),
                      const SizedBox(height: 12),
                    ],
                    Text(task.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      '${task.quality} · ${task.status.map(pending: (_) => "等待中", downloading: (_) => "下载中", paused: (_) => "已暂停", completed: (_) => "已完成", failed: (_) => "失败")}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(task.description!, style: theme.textTheme.bodyMedium),
                    ],
                    if (task.tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            task.tags.map((t) => Chip(label: Text(t))).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover(ApiDownloadTask task) {
    final local = task.coverPath;
    if (local != null && local.isNotEmpty && File(local).existsSync()) {
      return Image.file(File(local), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox());
    }
    if (task.coverUrl.isEmpty) return const SizedBox();
    return CachedNetworkImage(
      imageUrl: task.coverUrl,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) => const SizedBox(),
    );
  }

  Widget _buildAuthor(ApiDownloadTask task, ThemeData theme) {
    final name = task.authorName ?? '';
    final local = task.authorAvatarPath;
    final url = task.authorAvatarUrl;

    Widget avatar;
    if (local != null && local.isNotEmpty && File(local).existsSync()) {
      avatar = ClipOval(
        child: Image.file(
          File(local),
          width: 28,
          height: 28,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackAvatar(theme),
        ),
      );
    } else if (url != null && url.isNotEmpty) {
      avatar = ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: 28,
          height: 28,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _fallbackAvatar(theme),
        ),
      );
    } else {
      avatar = _fallbackAvatar(theme);
    }

    return Row(
      children: [
        avatar,
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: theme.textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _fallbackAvatar(ThemeData theme) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, size: 18, color: theme.colorScheme.onSurfaceVariant),
    );
  }
}
