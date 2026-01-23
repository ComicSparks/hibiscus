// App Shell - 包含侧栏的布局容器
// 根据屏幕尺寸自动切换 Drawer / NavigationRail / 常驻侧栏

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hibiscus/src/ui/theme/app_theme.dart';
import 'package:hibiscus/src/ui/widgets/app_drawer.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  
  const AppShell({super.key, required this.child});
  
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);
    final isTablet = Breakpoints.isTablet(context);
    
    // 桌面端：常驻侧栏
    if (isDesktop) {
      return Row(
        children: [
          const AppDrawer(isPermanent: true),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: widget.child),
        ],
      );
    }
    
    // 平板/手机：使用 Drawer
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(isPermanent: false),
      body: widget.child,
    );
  }
}

/// 用于在子页面中打开侧栏的 Mixin
mixin AppShellMixin<T extends StatefulWidget> on State<T> {
  void openDrawer() {
    Scaffold.of(context).openDrawer();
  }
}

/// 提供打开侧栏功能的 InheritedWidget
class AppShellScope extends InheritedWidget {
  final VoidCallback openDrawer;
  
  const AppShellScope({
    super.key,
    required this.openDrawer,
    required super.child,
  });
  
  static AppShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppShellScope>();
  }
  
  static AppShellScope of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No AppShellScope found in context');
    return result!;
  }
  
  @override
  bool updateShouldNotify(AppShellScope oldWidget) {
    return openDrawer != oldWidget.openDrawer;
  }
}
