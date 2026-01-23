// Flutter 路由配置
// 使用 go_router 实现声明式路由

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hibiscus/src/ui/pages/home_page.dart';
import 'package:hibiscus/src/ui/pages/video_detail_page.dart';
import 'package:hibiscus/src/ui/pages/downloads_page.dart';
import 'package:hibiscus/src/ui/pages/history_page.dart';
import 'package:hibiscus/src/ui/pages/favorites_page.dart';
import 'package:hibiscus/src/ui/pages/watch_later_page.dart';
import 'package:hibiscus/src/ui/pages/subscriptions_page.dart';
import 'package:hibiscus/src/ui/pages/settings_page.dart';
import 'package:hibiscus/src/ui/shell/app_shell.dart';

/// 路由路径常量
class AppRoutes {
  static const String home = '/';
  static const String search = '/search';
  static const String videoDetail = '/video/:id';
  static const String downloads = '/downloads';
  static const String history = '/history';
  static const String favorites = '/favorites';
  static const String watchLater = '/watch-later';
  static const String subscriptions = '/subscriptions';
  static const String settings = '/settings';
}

/// 创建路由配置
GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      // 带侧栏的 Shell 路由
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const HomePage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.downloads,
            name: 'downloads',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const DownloadsPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.history,
            name: 'history',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const HistoryPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.favorites,
            name: 'favorites',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const FavoritesPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.watchLater,
            name: 'watchLater',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const WatchLaterPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.subscriptions,
            name: 'subscriptions',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SubscriptionsPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SettingsPage(),
            ),
          ),
        ],
      ),
      // 视频详情页（全屏，不带侧栏）
      GoRoute(
        path: AppRoutes.videoDetail,
        name: 'videoDetail',
        builder: (context, state) {
          final videoId = state.pathParameters['id'] ?? '';
          return VideoDetailPage(videoId: videoId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('页面不存在: ${state.uri}'),
      ),
    ),
  );
}

/// 路由扩展方法
extension GoRouterExtension on BuildContext {
  /// 导航到视频详情页
  void goToVideo(String videoId) {
    go('/video/$videoId');
  }

  /// 导航到搜索（带查询参数）
  void goToSearch({String? query, String? tag}) {
    final params = <String, String>{};
    if (query != null) params['q'] = query;
    if (tag != null) params['tag'] = tag;
    
    if (params.isEmpty) {
      go(AppRoutes.home);
    } else {
      final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
      go('${AppRoutes.home}?$queryString');
    }
  }
}
