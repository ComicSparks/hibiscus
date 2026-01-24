import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hibiscus/src/router/router.dart';
import 'package:hibiscus/src/rust/api/models.dart';
import 'package:hibiscus/src/state/settings_state.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class DownloadDetailPage extends StatefulWidget {
  final ApiDownloadTask task;

  const DownloadDetailPage({super.key, required this.task});

  @override
  State<DownloadDetailPage> createState() => _DownloadDetailPageState();
}

class _DownloadDetailPageState extends State<DownloadDetailPage> {
  late final Player _player;
  late final VideoController _controller;

  bool _hasOpened = false;
  String? _error;
  Orientation _lastOrientation = Orientation.portrait;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _open();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    try {
      _error = null;
      final localPath = widget.task.filePath;
      if (localPath != null && localPath.isNotEmpty && File(localPath).existsSync()) {
        await _player.open(Media(localPath), play: true);
        _hasOpened = true;
        if (mounted) setState(() {});
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final task = widget.task;
    _lastOrientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('下载详情'),
        actions: [
          IconButton(
            tooltip: '溯源',
            icon: const Icon(Icons.travel_explore),
            onPressed: () => context.pushVideo(task.videoId),
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
                Container(
                  color: Colors.black,
                  child: Video(
                    controller: _controller,
                    onEnterFullscreen: _enterFullscreen,
                    onExitFullscreen: _exitFullscreen,
                  ),
                ),
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
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                if (task.description != null && task.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(task.description!, style: theme.textTheme.bodyMedium),
                ],
                if (task.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: task.tags.map((t) => Chip(label: Text(t))).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enterFullscreen() async {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      return defaultEnterNativeFullscreen();
    }

    final mode = settingsState.settings.value.fullscreenOrientationMode;
    final isPortrait = _lastOrientation == Orientation.portrait;
    final w = _player.state.width ?? 0;
    final h = _player.state.height ?? 0;
    final isLandscapeVideo = w > 0 && h > 0 && w >= h;

    final orientations = switch (mode) {
      FullscreenOrientationMode.keepCurrent => isPortrait
          ? <DeviceOrientation>[DeviceOrientation.portraitUp]
          : <DeviceOrientation>[
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ],
      FullscreenOrientationMode.portrait => <DeviceOrientation>[
          DeviceOrientation.portraitUp,
        ],
      FullscreenOrientationMode.landscape => <DeviceOrientation>[
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      FullscreenOrientationMode.byVideoSize => isLandscapeVideo
          ? <DeviceOrientation>[
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          : <DeviceOrientation>[DeviceOrientation.portraitUp],
    };

    await Future.wait(
      [
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.immersiveSticky,
          overlays: const [],
        ),
        SystemChrome.setPreferredOrientations(orientations),
      ],
    );
  }

  Future<void> _exitFullscreen() async {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      return defaultExitNativeFullscreen();
    }
    await Future.wait(
      [
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        ),
        SystemChrome.setPreferredOrientations(const []),
      ],
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
