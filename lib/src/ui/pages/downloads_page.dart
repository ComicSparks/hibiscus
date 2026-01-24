// 下载管理页

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:signals/signals_flutter.dart';
import 'package:hibiscus/src/rust/api/download.dart' as download_api;
import 'package:hibiscus/src/rust/api/models.dart';
import 'package:hibiscus/src/state/download_state.dart';
import 'package:hibiscus/src/router/router.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  final _items = signal<List<ApiDownloadTask>>([]);
  final _isLoading = signal(false);
  final _isOperating = signal(false);
  final _error = signal<String?>(null);
  final _isSelectionMode = signal(false);
  final _selectedIds = signal<Set<String>>(<String>{});
  late final void Function() _refreshDispose;
  StreamSubscription<ApiDownloadTask>? _sub;

  @override
  void initState() {
    super.initState();
    _loadDownloads();
    _sub = download_api.subscribeDownloadProgress().listen((event) {
      final list = _items.value;
      final idx = list.indexWhere((t) => t.id == event.id);
      if (idx >= 0) {
        final next = [...list];
        next[idx] = event;
        _items.value = next;
      } else {
        _items.value = [event, ...list];
      }
    });
    _refreshDispose = effect(() {
      downloadState.refreshTick.value;
      _loadDownloads();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _refreshDispose();
    super.dispose();
  }

  Future<void> _loadDownloads() async {
    _isLoading.value = true;
    _error.value = null;
    try {
      final items = await download_api.getAllDownloads();
      _items.value = items;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _pauseAll() async {
    await download_api.pauseAllDownloads();
    await _loadDownloads();
  }

  Future<void> _resumeAll() async {
    await download_api.resumeAllDownloads();
    await _loadDownloads();
  }

  void _exitSelectionMode() {
    _isSelectionMode.value = false;
    _selectedIds.value = <String>{};
  }

  void _toggleSelected(String id) {
    final next = {..._selectedIds.value};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    _selectedIds.value = next;
  }

  void _selectAllVisible() {
    final next = <String>{..._items.value.map((e) => e.id)};
    _selectedIds.value = next;
  }

  Future<void> _deleteSelected() async {
    final ids = _selectedIds.value.toList();
    if (ids.isEmpty) return;

    bool deleteFile = true;
    final hasInProgress = _items.value.any(
      (e) => _selectedIds.value.contains(e.id) && e.status is! ApiDownloadStatus_Completed,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('删除下载任务'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('将删除 ${ids.length} 个任务。'),
                  if (hasInProgress) ...[
                    const SizedBox(height: 8),
                    Text(
                      '包含下载中/暂停/失败的任务，删除后将无法继续。',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: deleteFile,
                    onChanged: (v) => setState(() => deleteFile = v ?? true),
                    title: const Text('同时删除已下载文件（含未完成的临时文件）'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('删除'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    _isOperating.value = true;
    try {
      for (final id in ids) {
        await download_api.deleteDownload(taskId: id, deleteFile: deleteFile);
      }
      _exitSelectionMode();
      await _loadDownloads();
    } finally {
      _isOperating.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Watch((_) {
          final selecting = _isSelectionMode.value;
          final count = _selectedIds.value.length;
          return Text(selecting ? '已选择 $count' : '下载管理');
        }),
        actions: [
          Watch((context) {
            final selecting = _isSelectionMode.value;
            if (selecting) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: '全选',
                    icon: const Icon(Icons.select_all),
                    onPressed: _selectAllVisible,
                  ),
                  IconButton(
                    tooltip: '删除',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _selectedIds.value.isEmpty ? null : _deleteSelected,
                  ),
                  IconButton(
                    tooltip: '取消',
                    icon: const Icon(Icons.close),
                    onPressed: _exitSelectionMode,
                  ),
                ],
              );
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: '多选删除',
                  icon: const Icon(Icons.checklist),
                  onPressed: () => _isSelectionMode.value = true,
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'pause_all',
                      child: ListTile(
                        leading: Icon(Icons.pause),
                        title: Text('全部暂停'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'resume_all',
                      child: ListTile(
                        leading: Icon(Icons.play_arrow),
                        title: Text('全部恢复'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    switch (value) {
                      case 'pause_all':
                        await _pauseAll();
                        break;
                      case 'resume_all':
                        await _resumeAll();
                        break;
                    }
                  },
                ),
              ],
            );
          }),
        ],
      ),
      body: Watch((context) {
        final items = _items.value;
        final isLoading = _isLoading.value;
        final error = _error.value;
        final isOperating = _isOperating.value;
        final isSelectionMode = _isSelectionMode.value;
        final selectedIds = _selectedIds.value;

        Widget child;
        if (isLoading && items.isEmpty) {
          child = const Center(child: CircularProgressIndicator());
        } else if (error != null && items.isEmpty) {
          child = Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
                  const SizedBox(height: 8),
                  Text(error, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _loadDownloads,
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          );
        } else if (items.isEmpty) {
          child = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无下载任务',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        } else {
          child = _buildList(context, items, isSelectionMode, selectedIds);
        }

        if (!isOperating) return child;
        return Stack(
          children: [
            child,
            Positioned.fill(
              child: ColoredBox(
                color: theme.colorScheme.surface.withOpacity(0.4),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<ApiDownloadTask> items,
    bool isSelectionMode,
    Set<String> selectedIds,
  ) {
    if (items.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return RefreshIndicator(
      onRefresh: _loadDownloads,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final selected = selectedIds.contains(item.id);
          return _DownloadListTile(
            item: item,
            isSelectionMode: isSelectionMode,
            isSelected: selected,
            onTap: () {
              if (isSelectionMode) {
                _toggleSelected(item.id);
              } else {
                context.pushDownloadDetail(item);
              }
            },
            onPause: () async {
              await download_api.pauseDownload(taskId: item.id);
              await _loadDownloads();
            },
            onResume: () async {
              await download_api.resumeDownload(taskId: item.id);
              await _loadDownloads();
            },
          );
        },
      ),
    );
  }
}

class _DownloadListTile extends StatelessWidget {
  final ApiDownloadTask item;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onPause;
  final VoidCallback onResume;

  const _DownloadListTile({
    required this.item,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onPause,
    required this.onResume,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizeText = _formatSizeDisplay(item);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 缩略图占位
                    _buildCoverWithSelection(theme),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if ((item.authorName ?? '').trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            _buildAuthorLine(theme),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            '${item.quality} · $sizeText',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildTrailing(context),
                  ],
                ),
                if (item.status is! ApiDownloadStatus_Completed) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: item.progress <= 0 ? null : item.progress,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverWithSelection(ThemeData theme) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 45,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
          child: _buildCover(theme),
        ),
        if (isSelectionMode)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: isSelected ? 1 : 0,
              duration: const Duration(milliseconds: 120),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Icon(Icons.check_circle, color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTrailing(BuildContext context) {
    if (isSelectionMode) {
      return Checkbox(
        value: isSelected,
        onChanged: (_) => onTap(),
      );
    }
    return _buildStatusButton(context);
  }
  
  Widget _buildStatusButton(BuildContext context) {
    if (item.status is ApiDownloadStatus_Downloading) {
        return IconButton(
          icon: const Icon(Icons.pause),
          onPressed: onPause,
          tooltip: '暂停',
        );
    }
    if (item.status is ApiDownloadStatus_Paused) {
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: onResume,
          tooltip: '恢复',
        );
    }
    if (item.status is ApiDownloadStatus_Completed) {
      return const SizedBox.shrink();
    }
    if (item.status is ApiDownloadStatus_Pending) {
        return IconButton(
          icon: const Icon(Icons.hourglass_empty),
          onPressed: null,
          tooltip: '等待中',
        );
    }
    if (item.status is ApiDownloadStatus_Failed) {
        return IconButton(
          icon: const Icon(Icons.error_outline, color: Colors.red),
          onPressed: onResume,
          tooltip: '重试',
        );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCover(ThemeData theme) {
    final local = item.coverPath;
    if (local != null && local.isNotEmpty && File(local).existsSync()) {
      return Image.file(
        File(local),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackCover(theme),
      );
    }
    if (item.coverUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: item.coverUrl,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => _fallbackCover(theme),
      );
    }
    return _fallbackCover(theme);
  }

  Widget _buildAuthorLine(ThemeData theme) {
    final name = item.authorName ?? '';
    final local = item.authorAvatarPath;
    final url = item.authorAvatarUrl;

    Widget avatar;
    if (local != null && local.isNotEmpty && File(local).existsSync()) {
      avatar = ClipOval(
        child: Image.file(
          File(local),
          width: 18,
          height: 18,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackAvatar(theme),
        ),
      );
    } else if (url != null && url.isNotEmpty) {
      avatar = ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: 18,
          height: 18,
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
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _fallbackAvatar(ThemeData theme) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: 12,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _fallbackCover(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.movie_outlined, size: 24),
    );
  }
}

String _formatSize(BigInt downloaded, BigInt total) {
  String fmt(BigInt bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    int unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(size < 10 ? 1 : 0)} ${units[unitIndex]}';
  }

  if (total == BigInt.zero) {
    return fmt(downloaded);
  }
  return '${fmt(downloaded)} / ${fmt(total)}';
}

String _formatSizeDisplay(ApiDownloadTask item) {
  if (item.status is ApiDownloadStatus_Completed) {
    final total = item.totalBytes;
    if (total == BigInt.zero) {
      return _formatSize(item.downloadedBytes, BigInt.zero);
    }
    return _formatSize(total, BigInt.zero);
  }
  return _formatSize(item.downloadedBytes, item.totalBytes);
}
