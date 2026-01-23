// 视频详情页

import 'package:flutter/material.dart';

class VideoDetailPage extends StatefulWidget {
  final String videoId;
  
  const VideoDetailPage({super.key, required this.videoId});
  
  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
              // TODO: 显示下载弹窗
              _showDownloadDialog(context);
            },
            tooltip: '加入下载',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 播放器区域
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 64,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '点击播放',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // 视频信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    '视频标题 - ID: ${widget.videoId}',
                    style: theme.textTheme.titleLarge,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 统计信息
                  Text(
                    '12.3K 次播放 · 2024-01-15',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 作者信息
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: const Icon(Icons.person),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '作者名称',
                              style: theme.textTheme.titleSmall,
                            ),
                            Text(
                              '100 个订阅者',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: () {
                          // TODO: 订阅/取消订阅
                        },
                        child: const Text('订阅'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 操作按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(
                        icon: Icons.favorite_outline,
                        label: '收藏',
                        onPressed: () {},
                      ),
                      _ActionButton(
                        icon: Icons.watch_later_outlined,
                        label: '稀后观看',
                        onPressed: () {},
                      ),
                      _ActionButton(
                        icon: Icons.share_outlined,
                        label: '分享',
                        onPressed: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // 标签
                  Text('标签', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(label: const Text('标签1'), onPressed: () {}),
                      ActionChip(label: const Text('标签2'), onPressed: () {}),
                      ActionChip(label: const Text('标签3'), onPressed: () {}),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 评论区占位
                  Text('评论区', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '评论功能开发中...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showDownloadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择清晰度'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('1080p'),
              leading: const Icon(Icons.hd),
              onTap: () {
                Navigator.pop(context);
                // TODO: 添加下载任务
              },
            ),
            ListTile(
              title: const Text('720p'),
              leading: const Icon(Icons.sd),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('480p'),
              leading: const Icon(Icons.sd),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
