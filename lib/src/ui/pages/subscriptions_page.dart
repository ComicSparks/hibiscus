// 订阅页

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:hibiscus/src/state/subscriptions_state.dart';
import 'package:hibiscus/src/state/user_state.dart';
import 'package:hibiscus/src/state/settings_state.dart';
import 'package:hibiscus/src/ui/pages/login_page.dart';
import 'package:hibiscus/src/ui/widgets/video_grid.dart';
import 'package:hibiscus/src/rust/api/models.dart';
import 'package:hibiscus/src/rust/api/download.dart' as download_api;

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  final _scrollController = ScrollController();
  final _isMultiSelect = signal(false);
  final _selectedIds = signal<Set<String>>(<String>{});
  final _selectedQuality = signal('1080P');

  @override
  void initState() {
    super.initState();
    if (userState.loginStatus.value == LoginStatus.unknown) {
      userState.checkLoginStatus().then((_) {
        if (mounted && userState.isLoggedIn) {
          subscriptionsState.load(refresh: true);
        }
      });
    } else if (userState.isLoggedIn) {
      subscriptionsState.load(refresh: true);
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    subscriptionsState.reset();
    super.dispose();
  }

  void _enterMultiSelect() {
    _selectedIds.value = <String>{};
    _selectedQuality.value = settingsState.settings.value.defaultDownloadQuality;
    _isMultiSelect.value = true;
  }

  void _exitMultiSelect() {
    _isMultiSelect.value = false;
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
    _selectedIds.value = {for (final v in subscriptionsState.videos.value) v.id};
  }

  Future<void> _batchDownloadSelected() async {
    final ids = _selectedIds.value.toList();
    if (ids.isEmpty) return;

    final quality = _selectedQuality.value;
    final videosById = {for (final v in subscriptionsState.videos.value) v.id: v};

    int done = 0;
    int ok = 0;
    bool canceled = false;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final progress = ids.isEmpty ? 0.0 : (done / ids.length).clamp(0.0, 1.0);
          return AlertDialog(
            title: const Text('加入下载'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 12),
                Text('已处理：$done/${ids.length} · 成功：$ok'),
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
      ),
    );

    for (final id in ids) {
      if (canceled) break;
      final v = videosById[id];
      if (v == null) {
        done++;
        continue;
      }
      try {
        await download_api.addDownload(
          videoId: v.id,
          title: v.title,
          coverUrl: v.coverUrl,
          quality: quality,
          description: null,
          tags: v.tags,
        );
        ok++;
      } catch (_) {
        // ignore per-item failure
      }
      done++;
    }

    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    final total = done;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已加入下载：$ok/$total')),
    );
    _exitMultiSelect();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      subscriptionsState.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Watch((_) {
          final selecting = _isMultiSelect.value;
          final count = _selectedIds.value.length;
          return Text(selecting ? '已选择 $count' : '我的订阅');
        }),
        actions: [
          Watch((context) {
            if (!_isMultiSelect.value) return const SizedBox.shrink();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: '全选',
                  icon: const Icon(Icons.select_all),
                  onPressed: _selectAllVisible,
                ),
              ],
            );
          }),
        ],
      ),
      body: Watch((context) {
        final loginStatus = userState.loginStatus.value;
        if (loginStatus != LoginStatus.loggedIn) {
          return _buildNeedLogin(context, theme, loginStatus);
        }

        final authors = subscriptionsState.authors.value;
        final videos = subscriptionsState.videos.value;
        final isLoading = subscriptionsState.isLoading.value;
        final error = subscriptionsState.error.value;
        final hasMore = subscriptionsState.hasMore.value;

        if (isLoading && videos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (error != null && videos.isEmpty) {
          return _buildErrorState(context, error);
        }

        final isMultiSelect = _isMultiSelect.value;
        final selectedCount = _selectedIds.value.length;
        final quality = _selectedQuality.value;

        return RefreshIndicator(
          onRefresh: () => subscriptionsState.load(refresh: true),
          child: Column(
            children: [
              if (authors.isNotEmpty) _buildAuthorsStrip(context, authors),
              if (isMultiSelect)
                _buildMultiSelectBar(
                  context,
                  theme,
                  selectedCount: selectedCount,
                  quality: quality,
                ),
              Expanded(
                child: VideoGrid(
                  controller: _scrollController,
                  videos: videos,
                  isLoading: isLoading,
                  hasMore: hasMore,
                  selectionMode: isMultiSelect,
                  selectedIds: _selectedIds.value,
                  onToggleSelect: (video) => _toggleSelected(video.id),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAuthorsStrip(BuildContext context, List<ApiAuthorInfo> authors) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 88,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: authors.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Watch((context) {
              final selecting = _isMultiSelect.value;
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: selecting ? _exitMultiSelect : _enterMultiSelect,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(selecting ? Icons.close : Icons.checklist),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 64,
                      child: Text(
                        selecting ? '取消' : '多选',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              );
            });
          }

          final a = authors[index - 1];
          final name = a.name;
          final avatarUrl = a.avatarUrl;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null ? const Icon(Icons.person) : null,
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 64,
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMultiSelectBar(
    BuildContext context,
    ThemeData theme, {
    required int selectedCount,
    required String quality,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: _exitMultiSelect,
            icon: const Icon(Icons.close),
            label: const Text('取消'),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            tooltip: '下载清晰度',
            onSelected: (value) => _selectedQuality.value = value,
            itemBuilder: (context) {
              const items = ['1080P', '720P', '480P', '360P', 'auto'];
              return items
                  .map((q) => PopupMenuItem(
                        value: q,
                        child: Row(
                          children: [
                            if (q == quality) const Icon(Icons.check, size: 18),
                            if (q == quality) const SizedBox(width: 8),
                            Text(q),
                          ],
                        ),
                      ))
                  .toList();
            },
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.high_quality),
              label: Text(quality),
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: selectedCount == 0 ? null : _batchDownloadSelected,
            icon: const Icon(Icons.download),
            label: Text('下载($selectedCount)'),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedLogin(BuildContext context, ThemeData theme, LoginStatus status) {
    final subtitle = switch (status) {
      LoginStatus.unknown => '正在检查登录状态…',
      LoginStatus.loggedOut => '登录后才能查看订阅更新',
      LoginStatus.loggedIn => '',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant.withAlpha(128)),
            const SizedBox(height: 16),
            Text('需要登录', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: status == LoginStatus.unknown
                  ? null
                  : () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                      await userState.checkLoginStatus();
                      if (mounted && userState.isLoggedIn) {
                        await subscriptionsState.load(refresh: true);
                      }
                    },
              icon: const Icon(Icons.login),
              label: const Text('去登录'),
            ),
          ],
        ),
      ),
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
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('加载失败', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => subscriptionsState.load(refresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}
