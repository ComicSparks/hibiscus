// 下载管理页

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:hibiscus/src/rust/api/download.dart' as download_api;
import 'package:hibiscus/src/rust/api/download_folders.dart' as folder_api;
import 'package:hibiscus/src/rust/api/models.dart';
import 'package:hibiscus/src/state/download_state.dart';
import 'package:hibiscus/src/router/router.dart';
import 'package:hibiscus/src/platform/gallery_export.dart';
import 'package:share_plus/share_plus.dart';

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
  final _folders = signal<List<ApiDownloadFolder>>([]);
  final _currentFolderId = signal<String?>(null); // null 表示"全部"
  late final void Function() _refreshDispose;
  StreamSubscription<ApiDownloadTask>? _sub;

  @override
  void initState() {
    super.initState();
    _loadFolders();
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

  Future<void> _loadFolders() async {
    try {
      final folders = await folder_api.getDownloadFolders();
      _folders.value = folders;
    } catch (e) {
      // ignore folder loading errors
    }
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
    final filteredItems = _getFilteredItems();
    final next = <String>{...filteredItems.map((e) => e.id)};
    _selectedIds.value = next;
  }

  List<ApiDownloadTask> _getFilteredItems() {
    final folderId = _currentFolderId.value;
    if (folderId == null) {
      return _items.value;
    }
    return _items.value.where((e) => e.folderId == folderId).toList();
  }

  Future<void> _moveSelectedToFolder(String? folderId) async {
    final ids = _selectedIds.value.toList();
    if (ids.isEmpty) return;

    _isOperating.value = true;
    try {
      await folder_api.moveDownloadsToFolder(videoIds: ids, folderId: folderId);
      await _loadDownloads();
      _exitSelectionMode();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(folderId == null ? '已移出文件夹' : '已移动到文件夹')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('移动失败：$e')),
      );
    } finally {
      _isOperating.value = false;
    }
  }

  void _showMoveToFolderSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _MoveToFolderSheet(
        folders: _folders.value,
        onSelect: (folderId) {
          Navigator.of(context).pop();
          _moveSelectedToFolder(folderId);
        },
        onCreateFolder: () async {
          Navigator.of(context).pop();
          await _showCreateFolderDialog();
          _showMoveToFolderSheet();
        },
      ),
    );
  }

  void _showFolderManagementSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FolderManagementSheet(
        folders: _folders.value,
        currentFolderId: _currentFolderId.value,
        onSelectFolder: (folderId) {
          Navigator.of(context).pop();
          _currentFolderId.value = folderId;
        },
        onEditFolder: (folder) async {
          Navigator.of(context).pop();
          await _showEditFolderDialog(folder);
        },
        onDeleteFolder: (folder) async {
          Navigator.of(context).pop();
          await _confirmDeleteFolder(folder);
        },
        onCreateFolder: () async {
          Navigator.of(context).pop();
          await _showCreateFolderDialog();
        },
      ),
    );
  }

  Future<void> _showCreateFolderDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建文件夹'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '文件夹名称',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      try {
        await folder_api.createDownloadFolder(name: result);
        await _loadFolders();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败：$e')),
        );
      }
    }
  }

  Future<void> _showEditFolderDialog(ApiDownloadFolder folder) async {
    final controller = TextEditingController(text: folder.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名文件夹'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '文件夹名称',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && result != folder.name) {
      try {
        await folder_api.renameDownloadFolder(folderId: folder.id, name: result);
        await _loadFolders();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('重命名失败：$e')),
        );
      }
    }
  }

  Future<void> _confirmDeleteFolder(ApiDownloadFolder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除文件夹'),
        content: Text('确定删除文件夹"${folder.name}"吗？\n文件夹内的视频不会被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await folder_api.deleteDownloadFolder(folderId: folder.id);
        if (_currentFolderId.value == folder.id) {
          _currentFolderId.value = null;
        }
        await _loadFolders();
        await _loadDownloads();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败：$e')),
        );
      }
    }
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

  Future<void> _shareSelected(BuildContext context) async {
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text('Web 暂不支持分享文件')),
      );
      return;
    }

    final selected = _items.value
        .where((e) => _selectedIds.value.contains(e.id))
        .where((e) => e.status is ApiDownloadStatus_Completed)
        .where((e) => e.filePath != null && e.filePath!.isNotEmpty)
        .where((e) => File(e.filePath!).existsSync())
        .toList();

    if (selected.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text('请选择已完成且文件存在的下载任务')),
      );
      return;
    }

    final shareOrigin = _shareOriginFromContext(context);
    final files = selected.map((e) => XFile(e.filePath!)).toList();

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: files,
          subject: 'Hibiscus downloads',
          text: 'Hibiscus 下载文件',
          sharePositionOrigin: shareOrigin,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('分享失败：$e')),
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

  Future<void> _exportSelectedToFiles() async {
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Web 暂不支持导出')),
      );
      return;
    }

    final ids = _selectedIds.value.toList();
    if (ids.isEmpty) return;

    final completedIds = _items.value
        .where((e) => _selectedIds.value.contains(e.id) && e.status is ApiDownloadStatus_Completed)
        .map((e) => e.id)
        .toList();
    if (completedIds.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择已完成的下载任务')),
      );
      return;
    }

    String? destDir;
    if (Platform.isIOS) {
      final base = await getApplicationDocumentsDirectory();
      destDir = Directory('${base.path}/Hibiscus').path;
    } else {
      destDir = await FilePicker.getDirectoryPath(dialogTitle: '选择导出文件夹');
    }
    if (destDir == null || destDir.isEmpty) return;

    ApiExportProgress? latest;
    int errorCount = 0;
    StreamSubscription<ApiExportProgress>? sub;
    void Function(void Function())? dialogSetState;
    BuildContext? dialogContext;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        dialogContext = context;
        return StatefulBuilder(
          builder: (context, setState) {
            dialogSetState ??= setState;
          final p = latest;
          final overall = (p == null || p.totalFiles == 0) ? null : (p.doneFiles / p.totalFiles).clamp(0.0, 1.0);
          final curTotal = p?.currentTotalBytes ?? BigInt.zero;
          final curDone = p?.currentBytes ?? BigInt.zero;
          final current = (p == null || curTotal == BigInt.zero)
              ? null
              : (curDone.toDouble() / curTotal.toDouble()).clamp(0.0, 1.0);

            return AlertDialog(
              title: const Text('导出到文件'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: overall),
                  const SizedBox(height: 12),
                  if (p != null) ...[
                    Text('进度：${p.doneFiles}/${p.totalFiles}  错误：$errorCount'),
                    if ((p.currentFile ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        p.currentFile!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: current),
                  ] else ...[
                    const Text('准备中…'),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await sub?.cancel();
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
              ],
            );
          },
        );
      },
    );

    sub = download_api
        .exportDownloadsToDir(taskIds: completedIds, destDir: destDir)
        .listen((event) {
      latest = event;
      if (event.error != null) {
        errorCount++;
      }
      dialogSetState?.call(() {});
      if (event.done) {
        final dc = dialogContext;
        if (dc != null && Navigator.of(dc).canPop()) {
          Navigator.of(dc).pop();
        }
      }
    }, onError: (e) {
      if (!mounted) return;
      final dc = dialogContext;
      if (dc != null && Navigator.of(dc).canPop()) {
        Navigator.of(dc).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出失败：$e')),
      );
    });

    await sub.asFuture<void>().catchError((_) {});
    await sub.cancel();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('导出完成：${completedIds.length} 个任务（错误：$errorCount）')),
    );
    _exitSelectionMode();
  }

  String _sanitizeFilename(String input) {
    final buf = StringBuffer();
    for (final ch in input.runes) {
      final c = String.fromCharCode(ch);
      final invalid = c == '<' ||
          c == '>' ||
          c == ':' ||
          c == '"' ||
          c == '/' ||
          c == '\\' ||
          c == '|' ||
          c == '?' ||
          c == '*' ||
          ch < 32;
      buf.write(invalid ? '_' : c);
    }
    final out = buf.toString().trim().replaceAll(RegExp(r'^[. ]+|[. ]+$'), '');
    return out.isEmpty ? '_' : out;
  }

  Future<void> _exportSelectedToAlbum() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('当前平台不支持导出到相册')),
      );
      return;
    }

    final selected = _items.value
        .where((e) => _selectedIds.value.contains(e.id))
        .where((e) => e.status is ApiDownloadStatus_Completed)
        .where((e) => e.filePath != null && e.filePath!.isNotEmpty && File(e.filePath!).existsSync())
        .toList();
    if (selected.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择已完成的下载任务')),
      );
      return;
    }

    int done = 0;
    int ok = 0;
    bool canceled = false;
    void Function(void Function())? dialogSetState;
    BuildContext? dialogContext;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        dialogContext = context;
        return StatefulBuilder(
          builder: (context, setState) {
            dialogSetState ??= setState;
          final progress = (done / selected.length).clamp(0.0, 1.0);
          return AlertDialog(
            title: const Text('导出到相册'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 12),
                Text('已处理：$done/${selected.length} · 成功：$ok'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  canceled = true;
                  Navigator.of(context).pop();
                },
                child: const Text('取消'),
              ),
            ],
          );
        },
        );
      },
    );

    for (final item in selected) {
      if (canceled) break;
      final path = item.filePath!;
      final ext = path.split('.').last.toLowerCase();
      if (ext == 'm3u8') {
        done++;
        continue;
      }
      final author = (item.authorName ?? '').trim().isEmpty ? 'Unknown' : item.authorName!.trim();
      final name = '[${_sanitizeFilename(author)}]${_sanitizeFilename(item.title)}.$ext';
      try {
        await GalleryExport.saveVideoToGallery(path: path, name: name);
        ok++;
      } catch (_) {
        // ignore per item
      }
      done++;
      dialogSetState?.call(() {});
    }

    if (!mounted) return;
    final dc = dialogContext;
    if (dc != null && Navigator.of(dc).canPop()) {
      Navigator.of(dc).pop();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已导出到相册：$ok/$done')),
    );
    _exitSelectionMode();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Watch((_) {
          final selecting = _isSelectionMode.value;
          final count = _selectedIds.value.length;
          final folderId = _currentFolderId.value;
          final folders = _folders.value;
          if (selecting) {
            return Text('已选择 $count');
          }
          if (folderId != null) {
            final folder = folders.where((f) => f.id == folderId).firstOrNull;
            return Text(folder?.name ?? '下载管理');
          }
          return const Text('下载管理');
        }),
        actions: [
          Watch((context) {
            final selecting = _isSelectionMode.value;
            if (selecting) {
              final selected = _selectedIds.value;
              final hasSharable = _items.value.any(
                (e) =>
                    selected.contains(e.id) &&
                    e.status is ApiDownloadStatus_Completed &&
                    (e.filePath ?? '').isNotEmpty &&
                    File(e.filePath!).existsSync(),
              );
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: '全选',
                    icon: const Icon(Icons.select_all),
                    onPressed: _selectAllVisible,
                  ),
                  IconButton(
                    tooltip: '移动到文件夹',
                    icon: const Icon(Icons.folder_copy_outlined),
                    onPressed: _selectedIds.value.isEmpty ? null : _showMoveToFolderSheet,
                  ),
                  IconButton(
                    tooltip: '分享文件',
                    icon: const Icon(Icons.share_outlined),
                    onPressed: hasSharable ? () => _shareSelected(context) : null,
                  ),
                  IconButton(
                    tooltip: Platform.isIOS ? '导出到文件（Documents）' : '导出到文件',
                    icon: const Icon(Icons.save_alt_outlined),
                    onPressed: _selectedIds.value.isEmpty ? null : _exportSelectedToFiles,
                  ),
                  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                    IconButton(
                      tooltip: '导出到相册',
                      icon: const Icon(Icons.photo_library_outlined),
                      onPressed: _selectedIds.value.isEmpty ? null : _exportSelectedToAlbum,
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

            final folderId = _currentFolderId.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: '文件夹',
                  icon: Icon(
                    folderId != null ? Icons.folder : Icons.folder_outlined,
                    color: folderId != null ? Theme.of(context).colorScheme.primary : null,
                  ),
                  onPressed: _showFolderManagementSheet,
                ),
                IconButton(
                  tooltip: '多选',
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
        final folderId = _currentFolderId.value;

        // 根据当前文件夹过滤
        final filteredItems = folderId == null
            ? items
            : items.where((e) => e.folderId == folderId).toList();

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
        } else if (filteredItems.isEmpty) {
          child = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  folderId != null ? Icons.folder_open_outlined : Icons.download_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  folderId != null ? '该文件夹为空' : '暂无下载任务',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        } else {
          child = _buildList(context, filteredItems, isSelectionMode, selectedIds);
        }

        if (!isOperating) return child;
        return Stack(
          children: [
            child,
            Positioned.fill(
              child: ColoredBox(
                color: theme.colorScheme.surface.withValues(alpha: 0.4),
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

    const tileHeight = 96.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: tileHeight,
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      // aspectRatio: 16 / 9,
                      aspectRatio: 4 / 3,
                      child: _buildCoverWithSelection(theme),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.title,
                              style: theme.textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if ((item.authorName ?? '').trim().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              _buildAuthorLine(theme),
                            ] else ...[
                              const SizedBox(height: 6),
                            ],
                            Text(
                              '${item.quality} · $sizeText',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: _buildTrailing(context),
                    ),
                  ],
                ),
                if (item.status is! ApiDownloadStatus_Completed)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: LinearProgressIndicator(
                      value: item.progress <= 0 ? null : item.progress,
                      minHeight: 3,
                      backgroundColor: Colors.black26,
                    ),
                  ),
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
        Positioned.fill(child: _buildCover(theme)),
        if (isSelectionMode)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: isSelected ? 1 : 0,
              duration: const Duration(milliseconds: 120),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
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

/// 文件夹管理 BottomSheet
class _FolderManagementSheet extends StatelessWidget {
  final List<ApiDownloadFolder> folders;
  final String? currentFolderId;
  final void Function(String?) onSelectFolder;
  final void Function(ApiDownloadFolder) onEditFolder;
  final void Function(ApiDownloadFolder) onDeleteFolder;
  final VoidCallback onCreateFolder;

  const _FolderManagementSheet({
    required this.folders,
    required this.currentFolderId,
    required this.onSelectFolder,
    required this.onEditFolder,
    required this.onDeleteFolder,
    required this.onCreateFolder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '文件夹',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onCreateFolder,
                    icon: const Icon(Icons.add),
                    label: const Text('新建'),
                  ),
                ],
              ),
            ),
            const Divider(),
            // "全部" 选项
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('全部'),
              selected: currentFolderId == null,
              selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              trailing: currentFolderId == null
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () => onSelectFolder(null),
            ),
            // 文件夹列表
            if (folders.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    '暂无文件夹',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...folders.map((folder) => ListTile(
                    leading: const Icon(Icons.folder),
                    title: Text(folder.name),
                    selected: currentFolderId == folder.id,
                    selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (currentFolderId == folder.id)
                          Icon(Icons.check, color: theme.colorScheme.primary),
                        PopupMenuButton<String>(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit_outlined),
                                title: Text('重命名'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete_outline),
                                title: Text('删除'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              onEditFolder(folder);
                            } else if (value == 'delete') {
                              onDeleteFolder(folder);
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () => onSelectFolder(folder.id),
                  )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// 移动到文件夹 BottomSheet
class _MoveToFolderSheet extends StatelessWidget {
  final List<ApiDownloadFolder> folders;
  final void Function(String?) onSelect;
  final VoidCallback onCreateFolder;

  const _MoveToFolderSheet({
    required this.folders,
    required this.onSelect,
    required this.onCreateFolder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '移动到文件夹',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onCreateFolder,
                    icon: const Icon(Icons.add),
                    label: const Text('新建'),
                  ),
                ],
              ),
            ),
            const Divider(),
            // "移出文件夹" 选项
            ListTile(
              leading: const Icon(Icons.folder_off_outlined),
              title: const Text('移出文件夹'),
              subtitle: const Text('从当前文件夹移出'),
              onTap: () => onSelect(null),
            ),
            // 文件夹列表
            if (folders.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    '暂无文件夹，请先创建',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...folders.map((folder) => ListTile(
                    leading: const Icon(Icons.folder),
                    title: Text(folder.name),
                    onTap: () => onSelect(folder.id),
                  )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
