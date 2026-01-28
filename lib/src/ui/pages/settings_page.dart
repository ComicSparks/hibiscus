// 设置页

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:hibiscus/src/state/settings_state.dart';
import 'package:hibiscus/src/state/user_state.dart';
import 'package:hibiscus/src/ui/pages/login_page.dart';
import 'package:hibiscus/src/ui/pages/log_viewer_page.dart';
import 'package:hibiscus/src/ui/pages/webdav_settings_page.dart';
import 'package:hibiscus/src/rust/api/settings.dart' as settings_api;
import 'package:hibiscus/src/services/image_cache_service.dart';
import 'package:hibiscus/src/services/log_export_service.dart';
import 'package:hibiscus/src/services/player/player_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  CacheSizeInfo? _cacheSizeInfo;
  bool _loadingCacheSize = true;

  @override
  void initState() {
    super.initState();
    if (userState.loginStatus.value == LoginStatus.unknown) {
      userState.checkLoginStatus();
    }
    _loadCacheSize();
  }

  Future<void> _loadCacheSize() async {
    try {
      final info = await ImageCacheService.getCacheSize();
      if (mounted) {
        setState(() {
          _cacheSizeInfo = info;
          _loadingCacheSize = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingCacheSize = false;
        });
      }
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
            if (Platform.isAndroid || Platform.isIOS)
              ListTile(
                title: const Text('播放器内核'),
                subtitle: Text(_playerTypeLabel(settings.preferredPlayerType)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showPlayerTypePicker(context, settings.preferredPlayerType),
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
              subtitle: Text(_loadingCacheSize
                  ? '正在计算缓存大小...'
                  : _cacheSizeInfo != null
                      ? '图片缓存: ${_cacheSizeInfo!.formattedImageSize} (${_cacheSizeInfo!.imageCacheCount} 张)\n'
                        'Web缓存: ${_cacheSizeInfo!.webCacheCount} 条'
                      : '点击清除所有缓存'),
              isThreeLine: !_loadingCacheSize && _cacheSizeInfo != null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showClearCacheDialog(context),
            ),
            if (Platform.isMacOS || Platform.isWindows)
              ListTile(
                title: const Text('打开数据目录'),
                subtitle: const Text('打开应用数据存储位置'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _openDataDir(context),
              ),

            const Divider(),

            // 同步设置
            _SectionHeader(title: '同步'),
            ListTile(
              leading: const Icon(Icons.cloud_sync_outlined),
              title: const Text('WebDAV 同步'),
              subtitle: const Text('同步浏览记录到云端'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WebDavSettingsPage(),
                  ),
                );
              },
            ),

            const Divider(),

            _SectionHeader(title: '诊断'),
            ListTile(
              title: const Text('日志预览'),
              subtitle: const Text('在应用内查看最近日志'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LogViewerPage()),
                );
              },
            ),
            ListTile(
              title: const Text('导出日志'),
              subtitle: const Text('打包日志用于反馈问题'),
              trailing: const Icon(Icons.share_outlined),
              onTap: () => _shareLogs(context),
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
            // ListTile(
            //   title: const Text('GitHub'),
            //   subtitle: const Text('查看源代码'),
            //   trailing: const Icon(Icons.open_in_new),
            //   onTap: () {
            //     // TODO: 打开 GitHub 页面
            //   },
            // ),
            
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择要清除的缓存类型：'),
            const SizedBox(height: 16),
            if (_cacheSizeInfo != null) ...[
              Text('图片缓存: ${_cacheSizeInfo!.formattedImageSize} (${_cacheSizeInfo!.imageCacheCount} 张)'),
              Text('Web缓存: ${_cacheSizeInfo!.webCacheCount} 条'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ImageCacheService.clearImageCache();
              await _loadCacheSize();
              if (!rootContext.mounted) return;
              ScaffoldMessenger.of(rootContext).showSnackBar(
                const SnackBar(content: Text('图片缓存已清除')),
              );
            },
            child: const Text('仅图片'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ImageCacheService.clearAllCache();
              await _loadCacheSize();
              if (!rootContext.mounted) return;
              ScaffoldMessenger.of(rootContext).showSnackBar(
                const SnackBar(content: Text('所有缓存已清除')),
              );
            },
            child: const Text('全部清除'),
          ),
        ],
      ),
    );
  }

  Future<void> _openDataDir(BuildContext context) async {
    try {
      final dirPath = await settings_api.getDataDirPath();
      if (Platform.isMacOS) {
        await Process.run('open', [dirPath]);
      } else if (Platform.isWindows) {
        await Process.run('explorer', [dirPath]);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('打开失败: $e')),
      );
    }
  }

  Future<void> _shareLogs(BuildContext context) async {
    final rootContext = context;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('正在打包日志…'),
        content: SizedBox(
          height: 56,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    try {
      await LogExportService.shareLogs(rootContext);
    } catch (e) {
      debugPrint('Log export failed: $e');
      if (!rootContext.mounted) return;
      ScaffoldMessenger.of(rootContext).showSnackBar(
        SnackBar(content: Text('导出失败: $e')),
      );
    } finally {
      if (rootContext.mounted) Navigator.of(rootContext).pop();
    }
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

  String _playerTypeLabel(PlayerType type) {
    return switch (type) {
      PlayerType.mediaKit => 'MediaKit（通用）',
      PlayerType.betterPlayer => 'BetterPlayer（支持画中画）',
    };
  }

  void _showPlayerTypePicker(BuildContext context, PlayerType current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('播放器内核'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择视频播放器内核：',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...PlayerType.values.map((type) {
              return RadioListTile<PlayerType>(
                title: Text(_playerTypeLabel(type)),
                subtitle: type == PlayerType.betterPlayer
                    ? const Text('仅支持移动端')
                    : const Text('跨平台通用'),
                value: type,
                groupValue: current,
                onChanged: (value) {
                  if (value == null) return;
                  settingsState.setPreferredPlayerType(value);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 8),
            Text(
              '注：切换播放器后需要重新打开视频页面才会生效',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
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
