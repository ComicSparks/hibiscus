import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hibiscus/src/router/router.dart';
import 'package:hibiscus/src/rust/api/models.dart';
import 'package:hibiscus/src/rust/api/video.dart' as video_api;
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

      final detail = await video_api.getVideoDetail(videoId: widget.task.videoId);
      final picked = detail.qualities
          .where((q) => q.quality.toLowerCase() == widget.task.quality.toLowerCase())
          .cast<ApiVideoQuality?>()
          .firstOrNull ??
          detail.qualities.firstOrNull;
      final url = picked?.url;
      if (url == null || url.isEmpty) {
        throw Exception('无法获取播放链接');
      }
      await _player.open(Media(url), play: true);
      _hasOpened = true;
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
                Container(color: Colors.black, child: Video(controller: _controller)),
                if (!_hasOpened)
                  Positioned.fill(
                    child: task.coverUrl.isEmpty
                        ? const SizedBox()
                        : Image.network(
                            task.coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const SizedBox(),
                          ),
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
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
