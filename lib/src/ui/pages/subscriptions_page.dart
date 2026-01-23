// 订阅页

import 'package:flutter/material.dart';

class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Mock 订阅数据
    final subscriptions = <_SubscriptionItem>[
      _SubscriptionItem(
        id: 'author_1',
        name: '作者名称 1',
        avatarUrl: '',
        videoCount: 120,
        isNotificationOn: true,
      ),
      _SubscriptionItem(
        id: 'author_2',
        name: '作者名称 2',
        avatarUrl: '',
        videoCount: 85,
        isNotificationOn: false,
      ),
      _SubscriptionItem(
        id: 'author_3',
        name: '作者名称 3',
        avatarUrl: '',
        videoCount: 230,
        isNotificationOn: true,
      ),
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的订阅'),
      ),
      body: subscriptions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.subscriptions_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无订阅',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '浏览视频时点击订阅按钮添加',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final item = subscriptions[index];
                return _SubscriptionListTile(item: item);
              },
            ),
    );
  }
}

class _SubscriptionItem {
  final String id;
  final String name;
  final String avatarUrl;
  final int videoCount;
  final bool isNotificationOn;
  
  _SubscriptionItem({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.videoCount,
    required this.isNotificationOn,
  });
}

class _SubscriptionListTile extends StatefulWidget {
  final _SubscriptionItem item;
  
  const _SubscriptionListTile({required this.item});
  
  @override
  State<_SubscriptionListTile> createState() => _SubscriptionListTileState();
}

class _SubscriptionListTileState extends State<_SubscriptionListTile> {
  late bool _isNotificationOn;
  
  @override
  void initState() {
    super.initState();
    _isNotificationOn = widget.item.isNotificationOn;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          widget.item.name[0],
          style: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(widget.item.name),
      subtitle: Text('${widget.item.videoCount} 个视频'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              _isNotificationOn
                  ? Icons.notifications_active
                  : Icons.notifications_off_outlined,
              color: _isNotificationOn
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              setState(() {
                _isNotificationOn = !_isNotificationOn;
              });
              // TODO: 更新通知状态
            },
            tooltip: _isNotificationOn ? '关闭通知' : '开启通知',
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'unsubscribe',
                child: ListTile(
                  leading: Icon(Icons.person_remove),
                  title: Text('取消订阅'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'view_videos',
                child: ListTile(
                  leading: Icon(Icons.video_library),
                  title: Text('查看视频'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'unsubscribe') {
                _showUnsubscribeDialog(context);
              } else if (value == 'view_videos') {
                // TODO: 跳转到作者视频列表
              }
            },
          ),
        ],
      ),
      onTap: () {
        // TODO: 跳转到作者页面
      },
    );
  }
  
  void _showUnsubscribeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('取消订阅'),
        content: Text('确定要取消订阅 ${widget.item.name} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 取消订阅
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
