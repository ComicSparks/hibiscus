// 设置页

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:hibiscus/src/state/settings_state.dart';
import 'package:hibiscus/src/state/user_state.dart';
import 'package:hibiscus/src/state/host_state.dart';
import 'package:hibiscus/src/ui/pages/login_page.dart';
import 'package:hibiscus/src/ui/pages/log_viewer_page.dart';
import 'package:hibiscus/src/ui/pages/webdav_settings_page.dart';
import 'package:hibiscus/browser/browser_state.dart';
import 'package:hibiscus/src/rust/api/settings.dart' as settings_api;
import 'package:hibiscus/src/rust/api/init.dart' as init_api;
import 'package:hibiscus/src/services/image_cache_service.dart';
import 'package:hibiscus/src/services/log_export_service.dart';
import 'package:hibiscus/src/services/player/player_service.dart';
import 'package:hibiscus/src/services/recommendations_service.dart';
import 'package:hibiscus/src/services/update_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
    
    unawaited(preloadUpdateRepo());
    unawaited(refreshRecommendations());
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

  Future<void> _showHostPicker(BuildContext context, ActiveHostInfo current) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('选择访问域名'),
          children: activeHostState.choices.map((choice) {
            final isSelected = choice.host == current.host &&
                choice.useCustomDns == current.useCustomDns;
            return ListTile(
              title: Text(choice.label),
              subtitle: Text(choice.description),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () async {
                Navigator.of(dialogContext).pop();
                await _applyHostChoice(choice, context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _applyHostChoice(HostChoice choice, BuildContext context) async {
    try {
      await activeHostState.setActiveHost(choice);
      await userState.checkLoginStatus();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已切换到 ${choice.label}，登录状态独立')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('切换域名失败：$e')),
      );
    }
  }

  Future<void> _clearDomainCookies(
    BuildContext context,
    ActiveHostInfo current,
  ) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('清除登录'),
            content: Text('确认清除 ${current.label} 的 Cookies 和登录状态？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('确认'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    try {
      await init_api.clearCookies();
      await userState.checkLoginStatus();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已清除 ${current.label} 的登录信息')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('清除登录失败：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: Watch((context) {
        final settings = settingsState.settings.value;
        final activeHostInfo = activeHostState.activeHost.value;
        final loginStatus = userState.loginStatus.value;
        final user = userState.userInfo.value;
        final updateStatus = updateStatusSignal.value;
        final updateEnabled = updateRepoSpecSignal.value != null;
        final recommendations = recommendationsSignal.value;
        final recommendationsLoading = recommendationsLoadingSignal.value;

        return ListView(
          children: [
            if (recommendationsLoading || recommendations.isNotEmpty) ...[
              _SectionHeader(title: '推荐'),
              _buildRecommendationsCard(
                recommendations,
                loading: recommendationsLoading,
              ),
              const Divider(),
            ],
            _buildUserHeader(context, theme, loginStatus, user),
            const Divider(),
            // TODO: 暂时注释掉手动检查更新功能
            // _SectionHeader(title: '更新'),
            // ListTile(
            //   title: const Text('检查更新'),
            //   subtitle: Text(_updateStatusLabel(updateStatus, updateEnabled)),
            //   trailing: Badge(
            //     label: const Text('新', style: TextStyle(fontSize: 10)),
            //     isLabelVisible: updateEnabled && updateStatus.hasUpdate,
            //     child: const Icon(Icons.system_update_alt),
            //   ),
            //   onTap: () => manualCheckUpdate(context),
            // ),
            // const Divider(),

            // 外观设置
            _SectionHeader(title: '外观'),
            ListTile(
              title: const Text('主题模式'),
              subtitle: Text(_themeModeLabel(settings.themeMode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemeModePicker(context, settings.themeMode),
            ),
            ListTile(
              title: const Text('屏幕方向'),
              subtitle: Text(_appOrientationLabel(settings.appOrientation)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  _showAppOrientationPicker(context, settings.appOrientation),
            ),
            const Divider(),
            _SectionHeader(title: '导航'),
            ListTile(
              title: const Text('导航类型'),
              subtitle: Text(_navigationTypeLabel(settings.navigationType)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  _showNavigationTypePicker(context, settings.navigationType),
            ),

            const Divider(),

            // 播放设置
            _SectionHeader(title: '播放'),
            if (Platform.isAndroid || Platform.isIOS)
              ListTile(
                title: const Text('全屏方向'),
                subtitle: Text(
                  _fullscreenOrientationLabel(
                    settings.fullscreenOrientationMode,
                  ),
                ),
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
                onTap: () => _showPlayerTypePicker(
                  context,
                  settings.preferredPlayerType,
                ),
              ),

            const Divider(),

            // 下载设置
            _SectionHeader(title: '下载'),
            ListTile(
              title: const Text('最大并发下载数'),
              subtitle: Text('${settings.maxConcurrentDownloads}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showConcurrentPicker(
                context,
                settings.maxConcurrentDownloads,
              ),
            ),

            const Divider(),

            // 缓存设置
            _SectionHeader(title: '存储'),
            ListTile(
              title: const Text('清除缓存'),
              subtitle: Text(
                _loadingCacheSize
                    ? '正在计算缓存大小...'
                    : _cacheSizeInfo != null
                    ? '图片缓存: ${_cacheSizeInfo!.formattedImageSize} (${_cacheSizeInfo!.imageCacheCount} 张)\n'
                          'Web缓存: ${_cacheSizeInfo!.webCacheCount} 条'
                    : '点击清除所有缓存',
              ),
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
                  MaterialPageRoute(builder: (_) => const WebDavSettingsPage()),
                );
              },
            ),

            const Divider(),

            _SectionHeader(title: '网络'),
            Watch((context) {
              final ua = browserState.userAgent.value;
              return ListTile(
                title: const Text('User-Agent (只读)'),
                subtitle: Text(
                  ua ?? '尚未捕获，请先打开浏览器页面',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
            ListTile(
              title: const Text('访问域名'),
              subtitle: Text(activeHostInfo.label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showHostPicker(context, activeHostInfo),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                activeHostInfo.useCustomDns
                    ? '使用内置 Cloudflare DNS（WebView 仍走系统 DNS）。'
                    : '使用官方 DNS，适用于未污染的网络环境。',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            ListTile(
              title: const Text('清除当前域名登录'),
              subtitle: Text('${activeHostInfo.label} 的 Cookies 和登录状态会被清除'),
              trailing: const Icon(Icons.delete_outline),
              onTap: () => _clearDomainCookies(context, activeHostInfo),
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
              Text(
                '图片缓存: ${_cacheSizeInfo!.formattedImageSize} (${_cacheSizeInfo!.imageCacheCount} 张)',
              ),
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
              ScaffoldMessenger.of(
                rootContext,
              ).showSnackBar(const SnackBar(content: Text('图片缓存已清除')));
            },
            child: const Text('仅图片'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ImageCacheService.clearAllCache();
              await _loadCacheSize();
              if (!rootContext.mounted) return;
              ScaffoldMessenger.of(
                rootContext,
              ).showSnackBar(const SnackBar(content: Text('所有缓存已清除')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('打开失败: $e')));
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
      ScaffoldMessenger.of(
        rootContext,
      ).showSnackBar(SnackBar(content: Text('导出失败: $e')));
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

  String _appOrientationLabel(AppOrientation orientation) {
    return switch (orientation) {
      AppOrientation.automatic => '自动',
      AppOrientation.portrait => '竖屏',
      AppOrientation.landscape => '横屏',
    };
  }

  void _showAppOrientationPicker(BuildContext context, AppOrientation current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('屏幕方向'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppOrientation.values.map((orientation) {
            return RadioListTile<AppOrientation>(
              title: Text(_appOrientationLabel(orientation)),
              value: orientation,
              groupValue: current,
              onChanged: (value) {
                if (value == null) return;
                settingsState.setAppOrientation(value);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _navigationTypeLabel(NavigationType type) {
    return switch (type) {
      NavigationType.adaptive => '自适应导航',
      NavigationType.bottom => '底部导航',
      NavigationType.sidebar => '侧边导航',
    };
  }

  void _showNavigationTypePicker(BuildContext context, NavigationType current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导航类型'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: NavigationType.values.map((type) {
            return RadioListTile<NavigationType>(
              title: Text(_navigationTypeLabel(type)),
              value: type,
              groupValue: current,
              onChanged: (value) {
                if (value == null) return;
                settingsState.setNavigationType(value);
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

  String _updateStatusLabel(UpdateStatus status, bool enabled) {
    if (!enabled) return '未获取更新源';
    if (status.hasUpdate) {
      return '发现新版本：${status.latestVersion}';
    }
    if (status.currentVersion == '-' && status.latestVersion == '-') {
      return '尚未检查更新';
    }
    return '当前：${status.currentVersion}，最新：${status.latestVersion}';
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
            const Text('选择视频播放器内核：', style: TextStyle(fontSize: 14)),
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
        backgroundImage:
            (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
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
                await Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const LoginPage()));
                await userState.checkLoginStatus();
                if (mounted) setState(() {});
              },
              child: const Text('登录'),
            ),
    );
  }

  Widget _buildRecommendationsCard(
    List<RecommendationItem> items, {
    required bool loading,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          if (items.isEmpty)
            ListTile(
              title: Text(loading ? '正在加载…' : '暂无推荐'),
              trailing: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
          for (var i = 0; i < items.length; i++)
            ListTile(
              title: Text(items[i].title),
              subtitle: (items[i].subtitle != null && items[i].subtitle!.isNotEmpty)
                  ? Text(items[i].subtitle!)
                  : null,
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _openExternalUrl(items[i].url),
            ),
        ],
      ),
    );
  }

  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
