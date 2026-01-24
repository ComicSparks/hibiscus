// 首页（搜索页）
// 参考官方布局，包含搜索框、过滤条件、视频列表

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:hibiscus/src/state/search_state.dart';
import 'package:hibiscus/src/state/settings_state.dart';
import 'package:hibiscus/src/ui/widgets/video_grid.dart';
import 'package:hibiscus/src/ui/widgets/filter_bar.dart';
import 'package:hibiscus/src/rust/api/download.dart' as download_api;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // 加载首页数据
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await searchState.init();
    await searchState.loadFilterOptions();
    _searchController.text = searchState.filters.value?.query ?? '';
    if (searchState.videos.value.isEmpty) {
      searchState.loadHomeVideos(refresh: true);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // 滚动到底部时加载更多
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      searchState.loadMore();
    }
  }

  void _onSearch(String query) {
    searchState.updateQuery(query);
  }

  Future<void> _onRefresh() async {
    final query = searchState.filters.value?.query;
    if (query != null && query.isNotEmpty) {
      await searchState.search(refresh: true);
    } else {
      await searchState.loadHomeVideos(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Watch((context) {
      final isMultiSelect = searchState.isMultiSelectMode.value;
      final selectedCount = searchState.selectedVideoIds.value.length;

      return Scaffold(
        appBar: AppBar(
          title: isMultiSelect
              ? Text('已选择 $selectedCount')
              : _buildSearchField(context),
          titleSpacing: 16,
        ),
        body: Column(
          children: [
            // 过滤条件栏
            FilterBar(
              onEnterMultiSelect: () {
                FocusScope.of(context).unfocus();
                searchState.enterMultiSelect(
                  defaultQuality: settingsState.settings.value.defaultDownloadQuality,
                );
              },
              onBatchDownload: _batchDownloadSelected,
            ),

            // 视频列表
            Expanded(
              child: Watch((context) {
                final videos = searchState.videos.value;
                final isLoading = searchState.isLoading.value;
                final hasMore = searchState.hasMore.value;
                final error = searchState.error.value;
                final needsCloudflare = searchState.needsCloudflare.value;

                // 显示 Cloudflare 验证提示
                if (needsCloudflare) {
                  return _buildCloudflarePrompt(context);
                }

                // 显示错误
                if (error != null && videos.isEmpty) {
                  return _buildErrorState(context, error);
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: VideoGrid(
                    controller: _scrollController,
                    videos: videos,
                    isLoading: isLoading,
                    hasMore: hasMore,
                    selectionMode: isMultiSelect,
                    selectedIds: searchState.selectedVideoIds.value,
                    onToggleSelect: (video) => searchState.toggleSelected(video.id),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: '搜索视频...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  searchState.reset();
                  searchState.loadHomeVideos(refresh: true);
                  setState(() {});
                },
              )
            : null,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: _onSearch,
      onChanged: (value) => setState(() {}),
    );
  }

  Future<void> _batchDownloadSelected() async {
    final ids = searchState.selectedVideoIds.value.toList();
    if (ids.isEmpty) return;

    final quality = searchState.multiSelectQuality.value;
    final videosById = {for (final v in searchState.videos.value) v.id: v};

    int ok = 0;
    for (final id in ids) {
      final v = videosById[id];
      if (v == null) continue;
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
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已加入下载：$ok/${ids.length}')),
    );
    searchState.exitMultiSelect();
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
            Text(
              '加载失败',
              style: theme.textTheme.titleLarge,
            ),
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
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudflarePrompt(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '需要验证',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '请完成 Cloudflare 安全验证后继续',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // TODO: 打开 WebView 进行验证
              },
              icon: const Icon(Icons.open_in_browser),
              label: const Text('开始验证'),
            ),
          ],
        ),
      ),
    );
  }
}
