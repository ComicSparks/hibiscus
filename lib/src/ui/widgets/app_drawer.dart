// 应用侧栏 Drawer
// 包含 Profile 区域、功能入口、设置入口

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hibiscus/src/router/router.dart';

class AppDrawer extends StatelessWidget {
  final bool isPermanent;
  
  const AppDrawer({super.key, this.isPermanent = false});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final content = SafeArea(
      child: Column(
        children: [
          // Profile 区域
          _buildProfileSection(context),
          
          const Divider(height: 1),
          
          // 功能入口
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                
                _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: '首页',
                  route: AppRoutes.home,
                ),
                
                _NavItem(
                  icon: Icons.favorite_outline,
                  selectedIcon: Icons.favorite,
                  label: '我的收藏',
                  route: AppRoutes.favorites,
                  requireLogin: true,
                ),
                
                _NavItem(
                  icon: Icons.watch_later_outlined,
                  selectedIcon: Icons.watch_later,
                  label: '稀后观看',
                  route: AppRoutes.watchLater,
                  requireLogin: true,
                ),
                
                _NavItem(
                  icon: Icons.history_outlined,
                  selectedIcon: Icons.history,
                  label: '播放历史',
                  route: AppRoutes.history,
                ),
                
                _NavItem(
                  icon: Icons.download_outlined,
                  selectedIcon: Icons.download,
                  label: '下载管理',
                  route: AppRoutes.downloads,
                ),
                
                _NavItem(
                  icon: Icons.subscriptions_outlined,
                  selectedIcon: Icons.subscriptions,
                  label: '订阅作者',
                  route: AppRoutes.subscriptions,
                  requireLogin: true,
                ),
                
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                
                _NavItem(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: '设置',
                  route: AppRoutes.settings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
    
    // 常驻侧栏 vs Drawer
    if (isPermanent) {
      return SizedBox(
        width: 280,
        child: Material(
          color: colorScheme.surface,
          child: content,
        ),
      );
    }
    
    return Drawer(
      child: content,
    );
  }
  
  Widget _buildProfileSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // TODO: 从状态管理获取用户信息
    const isLoggedIn = false;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: isLoggedIn
          ? _buildLoggedInProfile(context)
          : _buildLoginPrompt(context),
    );
  }
  
  Widget _buildLoggedInProfile(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.person,
            size: 32,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '用户名',
                style: theme.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '已登录',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoginPrompt(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.person_outline,
            size: 32,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '未登录',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              FilledButton.tonal(
                onPressed: () {
                  // TODO: 打开登录页面
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('登录'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 导航项
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
  final bool requireLogin;
  
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
    this.requireLogin = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    final isSelected = currentLocation == route || 
        (route == AppRoutes.home && currentLocation == '/');
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
        ),
        title: Text(
          label,
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
        onTap: () {
          if (requireLogin) {
            // TODO: 检查登录状态
            // 暂时直接跳转
          }
          context.go(route);
        },
      ),
    );
  }
}
