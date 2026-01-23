// App Shell - 包含自适应导航的布局容器
// 手机：底部导航栏 (BottomNavigationBar)
// 平板：侧边导航栏 (NavigationRail)
// 桌面：常驻侧栏 (NavigationDrawer)

import 'package:flutter/material.dart';
import 'package:hibiscus/src/router/router.dart';
import 'package:hibiscus/src/ui/theme/app_theme.dart';
import 'package:hibiscus/src/ui/pages/home_page.dart';
import 'package:hibiscus/src/ui/pages/favorites_page.dart';
import 'package:hibiscus/src/ui/pages/watch_later_page.dart';
import 'package:hibiscus/src/ui/pages/history_page.dart';
import 'package:hibiscus/src/ui/pages/downloads_page.dart';
import 'package:hibiscus/src/ui/pages/subscriptions_page.dart';
import 'package:hibiscus/src/ui/pages/settings_page.dart';

/// 导航项配置
class _NavDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
  
  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}

/// 主要导航项（显示在底部栏）
const _primaryDestinations = [
  _NavDestination(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: '首页',
    route: AppRoutes.home,
  ),
  _NavDestination(
    icon: Icons.favorite_outline,
    selectedIcon: Icons.favorite,
    label: '收藏',
    route: AppRoutes.favorites,
  ),
  _NavDestination(
    icon: Icons.history_outlined,
    selectedIcon: Icons.history,
    label: '历史',
    route: AppRoutes.history,
  ),
  _NavDestination(
    icon: Icons.download_outlined,
    selectedIcon: Icons.download,
    label: '下载',
    route: AppRoutes.downloads,
  ),
  _NavDestination(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: '设置',
    route: AppRoutes.settings,
  ),
];

/// 完整导航项（显示在侧栏）
const _allDestinations = [
  _NavDestination(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: '首页',
    route: AppRoutes.home,
  ),
  _NavDestination(
    icon: Icons.favorite_outline,
    selectedIcon: Icons.favorite,
    label: '我的收藏',
    route: AppRoutes.favorites,
  ),
  _NavDestination(
    icon: Icons.watch_later_outlined,
    selectedIcon: Icons.watch_later,
    label: '稍后观看',
    route: AppRoutes.watchLater,
  ),
  _NavDestination(
    icon: Icons.history_outlined,
    selectedIcon: Icons.history,
    label: '播放历史',
    route: AppRoutes.history,
  ),
  _NavDestination(
    icon: Icons.download_outlined,
    selectedIcon: Icons.download,
    label: '下载管理',
    route: AppRoutes.downloads,
  ),
  _NavDestination(
    icon: Icons.subscriptions_outlined,
    selectedIcon: Icons.subscriptions,
    label: '订阅作者',
    route: AppRoutes.subscriptions,
  ),
  _NavDestination(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: '设置',
    route: AppRoutes.settings,
  ),
];

class AppShell extends StatefulWidget {
  final int initialIndex;

  const AppShell({super.key, this.initialIndex = 0});
  
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final PageController _pageController;
  late int _pageIndex;

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _pageIndex);
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _pageIndex = widget.initialIndex;
      _pageController.jumpToPage(_pageIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  int _getSelectedIndex(String location, List<_NavDestination> destinations) {
    for (int i = 0; i < destinations.length; i++) {
      if (location == destinations[i].route || 
          (destinations[i].route == AppRoutes.home && location == '/')) {
        return i;
      }
    }
    return 0;
  }

  int _getPrimaryIndexFromAll(int allIndex) {
    switch (_allDestinations[allIndex].route) {
      case AppRoutes.home:
        return 0;
      case AppRoutes.favorites:
        return 1;
      case AppRoutes.history:
        return 2;
      case AppRoutes.downloads:
        return 3;
      case AppRoutes.settings:
        return 4;
      default:
        return 0;
    }
  }
  
  void _onDestinationSelected(int index, List<_NavDestination> destinations) {
    final targetIndex = _getSelectedIndex(destinations[index].route, _allDestinations);
    setState(() => _pageIndex = targetIndex);
    _pageController.jumpToPage(targetIndex);
  }
  
  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);
    final isTablet = Breakpoints.isTablet(context);
    final location = _allDestinations[_pageIndex].route;
    
    // 桌面端：常驻侧栏 (NavigationDrawer 样式)
    if (isDesktop) {
      return _buildDesktopLayout(location);
    }
    
    // 平板：NavigationRail
    if (isTablet) {
      return _buildTabletLayout(location);
    }
    
    // 手机：底部导航栏
    return _buildMobileLayout(location);
  }
  
  /// 桌面端布局：常驻宽侧栏
  Widget _buildDesktopLayout(String location) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedIndex = _getSelectedIndex(location, _allDestinations);
    
    return Row(
      children: [
        // 常驻侧栏
        SizedBox(
          width: 280,
          child: Material(
            color: colorScheme.surface,
            child: SafeArea(
              child: Column(
                children: [
                  // Logo / 标题区域
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_florist,
                          size: 32,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Hibiscus',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // 导航项
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _allDestinations.length,
                      itemBuilder: (context, index) {
                        final dest = _allDestinations[index];
                        final isSelected = index == selectedIndex;
                        
                        // 在设置项前添加分隔线
                        if (dest.route == AppRoutes.settings) {
                          return Column(
                            children: [
                              const Divider(height: 16),
                              _buildNavTile(dest, isSelected, index),
                            ],
                          );
                        }
                        
                        return _buildNavTile(dest, isSelected, index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        // 主内容
        Expanded(child: _buildPageView()),
      ],
    );
  }
  
  /// 导航列表项
  Widget _buildNavTile(_NavDestination dest, bool isSelected, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(
          isSelected ? dest.selectedIcon : dest.icon,
          color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
        ),
        title: Text(
          dest.label,
          style: TextStyle(
            color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: colorScheme.secondaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        onTap: () => _onDestinationSelected(index, _allDestinations),
      ),
    );
  }
  
  /// 平板布局：NavigationRail
  Widget _buildTabletLayout(String location) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedIndex = _getSelectedIndex(location, _allDestinations);
    
    return Row(
      children: [
        NavigationRail(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) => _onDestinationSelected(index, _allDestinations),
          labelType: NavigationRailLabelType.all,
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Icon(
              Icons.local_florist,
              size: 32,
              color: colorScheme.primary,
            ),
          ),
          destinations: _allDestinations.map((dest) {
            return NavigationRailDestination(
              icon: Icon(dest.icon),
              selectedIcon: Icon(dest.selectedIcon),
              label: Text(dest.label),
            );
          }).toList(),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(child: _buildPageView()),
      ],
    );
  }
  
  /// 手机布局：底部导航栏
  Widget _buildMobileLayout(String location) {
    final selectedIndex = _getPrimaryIndexFromAll(_pageIndex);
    
    return Scaffold(
      body: _buildPageView(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _onDestinationSelected(index, _primaryDestinations),
        destinations: _primaryDestinations.map((dest) {
          return NavigationDestination(
            icon: Icon(dest.icon),
            selectedIcon: Icon(dest.selectedIcon),
            label: dest.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPageView() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        HomePage(),
        FavoritesPage(),
        WatchLaterPage(),
        HistoryPage(),
        DownloadsPage(),
        SubscriptionsPage(),
        SettingsPage(),
      ],
    );
  }
}
