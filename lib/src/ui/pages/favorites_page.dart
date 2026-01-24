// 收藏页

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:hibiscus/src/rust/api/user.dart' as user_api;
import 'package:hibiscus/src/rust/api/models.dart';
import 'package:hibiscus/src/ui/widgets/video_grid.dart';
import 'package:hibiscus/src/state/user_state.dart';
import 'package:hibiscus/src/ui/pages/login_page.dart';

/// 收藏页状态
class _FavoritesState {
  final videos = signal<List<ApiVideoCard>>([]);
  final isLoading = signal(false);
  final hasMore = signal(true);
  final error = signal<String?>(null);
  int _currentPage = 1;

  Future<void> load({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
    }

    isLoading.value = true;
    error.value = null;

    try {
      final result = await user_api.getFavorites(page: _currentPage);

      if (refresh) {
        videos.value = result.videos;
      } else {
        videos.value = [...videos.value, ...result.videos];
      }

      hasMore.value = result.hasNext;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value || !hasMore.value) return;
    _currentPage++;
    await load();
  }

  void reset() {
    videos.value = [];
    isLoading.value = false;
    hasMore.value = true;
    error.value = null;
    _currentPage = 1;
  }
}

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _state = _FavoritesState();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (userState.loginStatus.value == LoginStatus.unknown) {
      userState.checkLoginStatus().then((_) {
        if (mounted && userState.isLoggedIn) {
          _state.load(refresh: true);
        }
      });
    } else if (userState.isLoggedIn) {
      _state.load(refresh: true);
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _state.reset();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _state.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
      ),
      body: Watch((context) {
        final loginStatus = userState.loginStatus.value;
        if (loginStatus != LoginStatus.loggedIn) {
          return _buildNeedLogin(context, theme, loginStatus);
        }

        final videos = _state.videos.value;
        final isLoading = _state.isLoading.value;
        final error = _state.error.value;
        final hasMore = _state.hasMore.value;

        if (isLoading && videos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (error != null && videos.isEmpty) {
          return _buildErrorState(context, error);
        }

        if (videos.isEmpty) {
          return _buildEmptyState(context, theme);
        }

        return RefreshIndicator(
          onRefresh: () => _state.load(refresh: true),
          child: VideoGrid(
            controller: _scrollController,
            videos: videos,
            isLoading: isLoading,
            hasMore: hasMore,
          ),
        );
      }),
    );
  }

  Widget _buildNeedLogin(BuildContext context, ThemeData theme, LoginStatus status) {
    final subtitle = switch (status) {
      LoginStatus.unknown => '正在检查登录状态…',
      LoginStatus.loggedOut => '登录后才能查看收藏列表',
      LoginStatus.loggedIn => '',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 64, color: theme.colorScheme.onSurfaceVariant.withAlpha(128)),
            const SizedBox(height: 16),
            Text('需要登录', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: status == LoginStatus.unknown
                  ? null
                  : () async {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()));
                      await userState.checkLoginStatus();
                      if (mounted && userState.isLoggedIn) {
                        await _state.load(refresh: true);
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

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无收藏',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '浏览视频时点击收藏按钮添加',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
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
              onPressed: () => _state.load(refresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}
