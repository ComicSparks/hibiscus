// 设置页

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:hibiscus/src/state/settings_state.dart';
import 'package:hibiscus/src/state/user_state.dart';
import 'package:hibiscus/src/ui/pages/login_page.dart';
import 'package:hibiscus/src/rust/api/settings.dart' as settings_api;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    if (userState.loginStatus.value == LoginStatus.unknown) {
      userState.checkLoginStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Watch((context) {
        final settings = settingsState.settings.value;
        final loginStatus = userState.loginStatus.value;
        final user = userState.userInfo.value;

        return ListView(
          children: [
            _buildUserHeader(context, theme, loginStatus, user),
            const Divider(),

            // 外观设置
            _SectionHeader(title: '外观'),
            ListTile(
              title: const Text('主题模式'),
              subtitle: Text(_themeModeLabel(settings.themeMode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemeModePicker(context, settings.themeMode),
            ),
            
            const Divider(),
            
            // 播放设置
            _SectionHeader(title: '播放'),
            SwitchListTile(
              title: const Text('自动播放'),
              subtitle: const Text('打开视频后自动开始播放'),
              value: settings.autoPlay,
              onChanged: (value) => settingsState.setAutoPlay(value),
            ),
            if (Platform.isAndroid || Platform.isIOS)
              ListTile(
                title: const Text('全屏方向'),
                subtitle: Text(_fullscreenOrientationLabel(settings.fullscreenOrientationMode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showFullscreenOrientationPicker(
                  context,
                  settings.fullscreenOrientationMode,
                ),
              ),
          
            const Divider(),
          
            // 下载设置
            _SectionHeader(title: '下载'),
            ListTile(
              title: const Text('最大并发下载数'),
              subtitle: Text('${settings.maxConcurrentDownloads}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showConcurrentPicker(context, settings.maxConcurrentDownloads),
            ),
          
            const Divider(),
          
            // 缓存设置
            _SectionHeader(title: '存储'),
            ListTile(
              title: const Text('清除缓存'),
              subtitle: const Text('目前仅包含离线封面缓存'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showClearCacheDialog(context),
            ),
          
            const Divider(),
            
            // 关于
            _SectionHeader(title: '关于'),
            ListTile(
              title: const Text('版本'),
              subtitle: const Text('1.0.0 (1)'),
            ),
            ListTile(
              title: const Text('开源许可'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showLicensePage(context: context);
              },
            ),
            ListTile(
              title: const Text('GitHub'),
              subtitle: const Text('查看源代码'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () {
                // TODO: 打开 GitHub 页面
              },
            ),
            
            const SizedBox(height: 32),
          ],
        );
      }),
    );
  }
  
  void _showConcurrentPicker(BuildContext context, int current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('最大并发下载数'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1, 2].map((count) {
            return RadioListTile<int>(
              title: Text('$count'),
              value: count,
              groupValue: current,
              onChanged: (value) {
                if (value == null) return;
                settingsState.setMaxConcurrentDownloads(value);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  
  void _showClearCacheDialog(BuildContext context) {
    final rootContext = context;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除离线封面缓存吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await settings_api.clearCoverCache();
              if (!mounted) return;
              if (!rootContext.mounted) return;
              ScaffoldMessenger.of(rootContext).showSnackBar(
                const SnackBar(content: Text('缓存已清除')),
              );
            },
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => '跟随系统',
      ThemeMode.light => '浅色',
      ThemeMode.dark => '深色',
    };
  }

  void _showThemeModePicker(BuildContext context, ThemeMode current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('主题模式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_themeModeLabel(mode)),
              value: mode,
              groupValue: current,
              onChanged: (value) {
                if (value == null) return;
                settingsState.setThemeMode(value);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _fullscreenOrientationLabel(FullscreenOrientationMode mode) {
    return switch (mode) {
      FullscreenOrientationMode.keepCurrent => '保持当前方向',
      FullscreenOrientationMode.portrait => '竖屏',
      FullscreenOrientationMode.landscape => '横屏',
      FullscreenOrientationMode.byVideoSize => '根据视频尺寸',
    };
  }

  void _showFullscreenOrientationPicker(
    BuildContext context,
    FullscreenOrientationMode current,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('全屏方向'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: FullscreenOrientationMode.values.map((mode) {
            return RadioListTile<FullscreenOrientationMode>(
              title: Text(_fullscreenOrientationLabel(mode)),
              value: mode,
              groupValue: current,
              onChanged: (value) {
                if (value == null) return;
                settingsState.setFullscreenOrientationMode(value);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUserHeader(
    BuildContext context,
    ThemeData theme,
    LoginStatus status,
    UserInfo? user,
  ) {
    final subtitle = switch (status) {
      LoginStatus.unknown => '正在检查登录状态…',
      LoginStatus.loggedOut => '未登录',
      LoginStatus.loggedIn => '已登录',
    };

    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        backgroundImage: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
            ? NetworkImage(user.avatarUrl!)
            : null,
        child: (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
            ? const Icon(Icons.person_outline)
            : null,
      ),
      title: Text(user?.username ?? '账号'),
      subtitle: Text(subtitle),
      trailing: status == LoginStatus.loggedIn
          ? FilledButton.tonal(
              onPressed: () async {
                await userState.logout();
                if (mounted) setState(() {});
              },
              child: const Text('退出'),
            )
          : FilledButton.tonal(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
                await userState.checkLoginStatus();
                if (mounted) setState(() {});
              },
              child: const Text('登录'),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  
  const _SectionHeader({required this.title});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
