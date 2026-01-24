// Flutter 路由配置
// 使用原生 Navigator (MaterialPageRoute)

import 'package:flutter/material.dart';
import 'package:hibiscus/src/rust/api/models.dart';
import 'package:hibiscus/src/ui/pages/download_detail_page.dart';
import 'package:hibiscus/src/ui/pages/video_detail_page.dart';
import 'package:hibiscus/src/ui/shell/app_shell.dart';

/// 路由路径常量
class AppRoutes {
  static const String home = '/';
  static const String search = '/search';
  static const String videoDetail = '/video/:id';
  static const String downloads = '/downloads';
  static const String history = '/history';
  static const String favorites = '/favorites';
  static const String subscriptions = '/subscriptions';
  static const String settings = '/settings';
}

/// 路由构建
Route<dynamic> onGenerateRoute(RouteSettings settings) {
  final name = settings.name ?? AppRoutes.home;

  int initialIndex = 0;
  switch (name) {
    case AppRoutes.home:
      initialIndex = 0;
      break;
    case AppRoutes.downloads:
      initialIndex = 3;
      break;
    case AppRoutes.history:
      initialIndex = 2;
      break;
    case AppRoutes.favorites:
      initialIndex = 1;
      break;
    case AppRoutes.subscriptions:
      initialIndex = 4;
      break;
    case AppRoutes.settings:
      initialIndex = 5;
      break;
    default:
      initialIndex = 0;
  }

  return MaterialPageRoute(
    settings: RouteSettings(name: name),
    builder: (context) => AppShell(initialIndex: initialIndex),
  );
}

/// 路由扩展方法
extension NavigatorExtension on BuildContext {
  /// 导航到视频详情页
  void pushVideo(String videoId) {
    Navigator.of(this).push(
      MaterialPageRoute(
        builder: (context) => VideoDetailPage(videoId: videoId),
      ),
    );
  }

  /// 导航到下载详情页（本地/在线播放）
  void pushDownloadDetail(ApiDownloadTask task) {
    Navigator.of(this).push(
      MaterialPageRoute(
        builder: (context) => DownloadDetailPage(task: task),
      ),
    );
  }

  /// 导航到首页（并重置为首页）
  void goHome() {
    Navigator.of(this).pushReplacementNamed(AppRoutes.home);
  }
}
