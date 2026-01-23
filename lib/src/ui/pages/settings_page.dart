// 设置页

import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // 设置状态
  bool _darkMode = false;
  bool _autoPlay = true;
  bool _wifiOnlyDownload = true;
  String _defaultQuality = '1080p';
  int _maxConcurrentDownloads = 3;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // 外观设置
          _SectionHeader(title: '外观'),
          SwitchListTile(
            title: const Text('深色模式'),
            subtitle: const Text('跟随系统或手动切换'),
            value: _darkMode,
            onChanged: (value) {
              setState(() => _darkMode = value);
              // TODO: 应用主题
            },
          ),
          
          const Divider(),
          
          // 播放设置
          _SectionHeader(title: '播放'),
          SwitchListTile(
            title: const Text('自动播放'),
            subtitle: const Text('打开视频后自动开始播放'),
            value: _autoPlay,
            onChanged: (value) {
              setState(() => _autoPlay = value);
            },
          ),
          ListTile(
            title: const Text('默认画质'),
            subtitle: Text(_defaultQuality),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showQualityPicker(context),
          ),
          
          const Divider(),
          
          // 下载设置
          _SectionHeader(title: '下载'),
          SwitchListTile(
            title: const Text('仅 Wi-Fi 下载'),
            subtitle: const Text('移动网络下暂停下载'),
            value: _wifiOnlyDownload,
            onChanged: (value) {
              setState(() => _wifiOnlyDownload = value);
            },
          ),
          ListTile(
            title: const Text('最大并发下载数'),
            subtitle: Text('$_maxConcurrentDownloads'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showConcurrentPicker(context),
          ),
          ListTile(
            title: const Text('下载路径'),
            subtitle: const Text('/storage/emulated/0/Download/Hibiscus'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 选择下载路径
            },
          ),
          
          const Divider(),
          
          // 缓存设置
          _SectionHeader(title: '存储'),
          ListTile(
            title: const Text('清除缓存'),
            subtitle: const Text('图片缓存、临时文件等'),
            trailing: Text(
              '128 MB',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            onTap: () => _showClearCacheDialog(context),
          ),
          ListTile(
            title: const Text('清除播放历史'),
            subtitle: const Text('删除所有播放记录'),
            onTap: () => _showClearHistoryDialog(context),
          ),
          
          const Divider(),
          
          // 账号设置
          _SectionHeader(title: '账号'),
          ListTile(
            title: const Text('登录状态'),
            subtitle: const Text('未登录'),
            trailing: FilledButton.tonal(
              onPressed: () {
                // TODO: 跳转到登录
              },
              child: const Text('登录'),
            ),
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
      ),
    );
  }
  
  void _showQualityPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('默认画质'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['1080p', '720p', '480p', '360p'].map((quality) {
            return RadioListTile<String>(
              title: Text(quality),
              value: quality,
              groupValue: _defaultQuality,
              onChanged: (value) {
                setState(() => _defaultQuality = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  
  void _showConcurrentPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('最大并发下载数'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1, 2, 3, 4, 5].map((count) {
            return RadioListTile<int>(
              title: Text('$count'),
              value: count,
              groupValue: _maxConcurrentDownloads,
              onChanged: (value) {
                setState(() => _maxConcurrentDownloads = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  
  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存数据吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 清除缓存
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清除')),
              );
            },
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }
  
  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除播放历史'),
        content: const Text('确定要清除所有播放历史吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 清除历史
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('播放历史已清除')),
              );
            },
            child: const Text('清除'),
          ),
        ],
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
