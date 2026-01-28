// WebDAV 同步设置页

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hibiscus/src/rust/api/sync.dart' as sync_api;

class WebDavSettingsPage extends StatefulWidget {
  const WebDavSettingsPage({super.key});

  @override
  State<WebDavSettingsPage> createState() => _WebDavSettingsPageState();
}

class _WebDavSettingsPageState extends State<WebDavSettingsPage> {
  final _urlFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _encryptionKeyFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _encryptionKeyController = TextEditingController();

  bool _autoSyncOnStart = false;
  int _autoSyncInterval = 0;
  bool _isLoading = true;
  bool _isTesting = false;
  bool _isSyncing = false;
  bool _isAutoSaving = false;
  bool _obscurePassword = true;
  bool _obscureEncryptionKey = true;
  int? _lastSyncTime;

  @override
  void initState() {
    super.initState();
    _attachFocusListeners();
    _loadSettings();
  }

  Future<void> _autoSaveSettings() async {
    await _saveSettings(showSuccessSnack: false, isAuto: true);
  }

  Future<void> _blurAndSave() async {
    FocusScope.of(context).unfocus();
    await _saveSettings(showSuccessSnack: false, isAuto: true);
  }

  @override
  void dispose() {
    unawaited(_saveSettings(showSuccessSnack: false, isAuto: true));
    _urlFocusNode.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _encryptionKeyFocusNode.dispose();
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _encryptionKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await sync_api.getWebdavSettings();
      final lastSync = await sync_api.getLastSyncTime();

      if (!mounted) return;
      setState(() {
        _urlController.text = settings.url;
        _usernameController.text = settings.username;
        _passwordController.text = settings.password;
        _encryptionKeyController.text = settings.encryptionKey;
        _autoSyncOnStart = settings.autoSyncOnStart;
        _autoSyncInterval = settings.autoSyncInterval;
        _lastSyncTime = lastSync;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载设置失败: $e')),
      );
    }
  }

  void _attachFocusListeners() {
    for (final node in [
      _urlFocusNode,
      _usernameFocusNode,
      _passwordFocusNode,
      _encryptionKeyFocusNode,
    ]) {
      node.addListener(() {
        if (!node.hasFocus) {
          _autoSaveSettings();
        }
      });
    }
  }

  Future<void> _saveSettings({
    bool showSuccessSnack = true,
    bool isAuto = false,
  }) async {
    if (!_formKey.currentState!.validate()) return;

    if (isAuto) {
      if (_isAutoSaving) return;
      _isAutoSaving = true;
    }

    try {
      await sync_api.saveWebdavSettings(
        settings: sync_api.ApiWebDavSettings(
          url: _urlController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          encryptionKey: _encryptionKeyController.text,
          autoSyncOnStart: _autoSyncOnStart,
          autoSyncInterval: _autoSyncInterval,
        ),
      );
      if (!mounted) return;
      if (showSuccessSnack) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('设置已保存')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    } finally {
      if (isAuto) {
        _isAutoSaving = false;
      }
    }
  }

  Future<void> _testConnection() async {
    final url = _urlController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入 WebDAV 地址')),
      );
      return;
    }

    await _blurAndSave();

    setState(() => _isTesting = true);
    try {
      await sync_api.testWebdavConnection(
        url: url,
        username: username,
        password: password,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('连接成功！'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('连接失败: ${_friendlyErrorMessage(e)}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  Future<void> _syncNow() async {
    if (_urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先配置 WebDAV')),
      );
      return;
    }

    await _blurAndSave();

    setState(() => _isSyncing = true);
    try {
      final result = await sync_api.syncHistory(forceUpload: false);

      if (!mounted) return;

      if (result is sync_api.ApiSyncStatus_Success) {
        await sync_api.updateLastSyncTime();
        final lastSync = await sync_api.getLastSyncTime();
        setState(() => _lastSyncTime = lastSync);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('同步成功！合并了 ${result.mergedCount} 条记录'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (result is sync_api.ApiSyncStatus_DecryptionFailed) {
        _showDecryptionFailedDialog();
      } else if (result is sync_api.ApiSyncStatus_NetworkError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('网络错误: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (result is sync_api.ApiSyncStatus_NotConfigured) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先配置 WebDAV')),
        );
      }
    } catch (e) {
      debugPrint('WebDAV sync error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('同步失败: ${_friendlyErrorMessage(e)}')),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  void _showDecryptionFailedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('无法解密云端数据'),
        content: const Text(
          '云端数据无法使用当前密钥解密。\n\n'
          '可能的原因：\n'
          '• 加密密钥不正确\n'
          '• 云端数据已损坏\n\n'
          '您可以：',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍后同步'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showChangeKeyDialog();
            },
            child: const Text('修改密钥'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _forceUpload();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('强制覆盖云端'),
          ),
        ],
      ),
    );
  }

  String _friendlyErrorMessage(Object error) {
    final message = error is Exception ? error.toString() : '$error';
    return message.split('\n').first;
  }

  void _showChangeKeyDialog() {
    final keyController = TextEditingController(text: _encryptionKeyController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改加密密钥'),
        content: TextField(
          controller: keyController,
          decoration: const InputDecoration(
            labelText: '加密密钥',
            hintText: '为空时使用默认密钥',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _encryptionKeyController.text = keyController.text;
              });
              _syncNow();
            },
            child: const Text('保存并重试'),
          ),
        ],
      ),
    );
  }

  Future<void> _forceUpload() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认强制覆盖'),
        content: const Text(
          '这将使用本地数据完全覆盖云端数据。\n\n'
          '云端的所有现有记录将被替换，此操作不可撤销。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('确认覆盖'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSyncing = true);
    try {
      final result = await sync_api.forceUploadHistory();
      if (!mounted) return;

      if (result is sync_api.ApiSyncStatus_Success) {
        await sync_api.updateLastSyncTime();
        final lastSync = await sync_api.getLastSyncTime();
        setState(() => _lastSyncTime = lastSync);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已强制上传到云端'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (result is sync_api.ApiSyncStatus_NetworkError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('上传失败: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('上传失败: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  String _formatLastSyncTime(int? timestamp) {
    if (timestamp == null || timestamp == 0) return '从未同步';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
    if (diff.inDays < 1) return '${diff.inHours} 小时前';
    if (diff.inDays < 7) return '${diff.inDays} 天前';

    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('WebDAV 同步')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('WebDAV 同步'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 同步状态卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.sync,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '同步状态',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('上次同步: ${_formatLastSyncTime(_lastSyncTime)}'),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isSyncing ? null : _syncNow,
                        icon: _isSyncing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.sync),
                        label: Text(_isSyncing ? '同步中...' : '立即同步'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // WebDAV 服务器设置
            Text(
              '服务器设置',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _urlController,
              focusNode: _urlFocusNode,
              decoration: const InputDecoration(
                labelText: 'WebDAV 地址',
                hintText: 'https://example.com/dav/',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return null; // 允许为空（未配置）
                }
                final uri = Uri.tryParse(value.trim());
                if (uri == null || !uri.hasScheme) {
                  return '请输入有效的 URL';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _usernameController,
              focusNode: _usernameFocusNode,
              decoration: const InputDecoration(
                labelText: '用户名',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: '密码',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _isTesting ? null : _testConnection,
              icon: _isTesting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi_tethering),
              label: Text(_isTesting ? '测试中...' : '测试连接'),
            ),

            const SizedBox(height: 24),

            // 加密设置
            Text(
              '安全设置',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _encryptionKeyController,
              focusNode: _encryptionKeyFocusNode,
              obscureText: _obscureEncryptionKey,
              decoration: InputDecoration(
                labelText: '加密密钥',
                hintText: '为空时使用默认密钥',
                prefixIcon: const Icon(Icons.key),
                border: const OutlineInputBorder(),
                helperText: '浏览记录将使用此密钥加密后上传',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureEncryptionKey
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(
                        () => _obscureEncryptionKey = !_obscureEncryptionKey);
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 自动同步设置
            Text(
              '自动同步',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            SwitchListTile(
              title: const Text('启动时自动同步'),
              subtitle: const Text('打开应用时自动同步浏览记录'),
              value: _autoSyncOnStart,
              onChanged: (value) {
                setState(() => _autoSyncOnStart = value);
                _autoSaveSettings();
              },
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('浏览时自动同步'),
                      Text(
                        '设置为 0 则不自动同步；在进入/退出视频详情页时检测',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        _autoSyncInterval == 0
                            ? '不自动同步'
                            : '$_autoSyncInterval 分钟',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Slider(
              value: _autoSyncInterval.toDouble(),
              min: 0,
              max: 60,
              divisions: 60,
              label: _autoSyncInterval == 0
                  ? '关闭'
                  : '$_autoSyncInterval 分钟',
              onChanged: (value) {
                setState(() => _autoSyncInterval = value.toInt());
              },
              onChangeEnd: (_) => _autoSaveSettings(),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
