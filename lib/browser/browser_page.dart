// 浏览器页面
// 完整的内置浏览器实现，包含地址栏、导航控制、书签、历史等功能

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hibiscus/browser/browser_state.dart';
import 'package:hibiscus/browser/browser_controller.dart';
import 'package:signals/signals_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// 浏览器页面
class BrowserPage extends StatefulWidget {
  /// 初始 URL（可选）
  final String? initialUrl;

  /// 激活成功回调
  final VoidCallback? onActivated;

  const BrowserPage({
    super.key,
    this.initialUrl,
    this.onActivated,
  });

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage>
    with SingleTickerProviderStateMixin {
  late final BrowserController _controller;
  final _urlFocusNode = FocusNode();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // 是否正在编辑地址栏
  bool _isEditingUrl = false;

  @override
  void initState() {
    super.initState();
    _controller = BrowserController(onActivated: _handleActivation);

    // 设置初始 URL
    final initialUrl = widget.initialUrl ?? browserState.currentUrl.value;
    if (initialUrl.isNotEmpty) {
      _controller.urlController.text = initialUrl;
    } else {
      _controller.urlController.text = browserState.homePage.value;
    }
  }

  @override
  void dispose() {
    _urlFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleActivation() {
    widget.onActivated?.call();
  }

  void _onWebViewCreated(InAppWebViewController controller) async {
    _controller.setWebViewController(controller);
    
    // 捕获并保存 UserAgent 到数据库
    try {
      final settings = await controller.getSettings();
      final ua = settings?.userAgent;
      if (ua != null && ua.isNotEmpty) {
        await browserState.saveUserAgent(ua);
      }
      debugPrint('UserAgent: $ua');
    } catch (e) {
      debugPrint('Failed to capture UserAgent: $e');
    }
  }

  void _onLoadStart(InAppWebViewController controller, WebUri? url) {
    browserState.updateLoadingState(loading: true, progress: 0.0);
    if (url != null) {
      final urlStr = url.toString();
      if (!_isEditingUrl) {
        _controller.urlController.text = urlStr;
      }
    }
  }

  void _onLoadStop(InAppWebViewController controller, WebUri? url) async {
    browserState.updateLoadingState(loading: false, progress: 1.0);
    await _controller.updateNavigationState();

    if (url != null) {
      final urlStr = url.toString();
      browserState.updateCurrentUrl(urlStr);
      if (!_isEditingUrl) {
        _controller.urlController.text = urlStr;
      }

      // 获取并更新标题
      final title = await controller.getTitle() ?? urlStr;
      browserState.updateTitle(title);

      // 添加到历史记录
      browserState.addHistory(title, urlStr);
    }
  }

  void _onProgressChanged(InAppWebViewController controller, int progress) {
    browserState.updateLoadingState(
      loading: progress < 100,
      progress: progress / 100.0,
    );
  }

  void _onTitleChanged(InAppWebViewController controller, String? title) {
    if (title != null && title.isNotEmpty) {
      browserState.updateTitle(title);
    }
  }

  Future<NavigationActionPolicy?> _shouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction action,
  ) async {
    final url = action.request.url?.toString() ?? '';

    // 检查是否是激活协议
    if (browserState.checkActivation(url)) {
      await browserState.activate();
      _handleActivation();
      return NavigationActionPolicy.CANCEL;
    }

    // 处理特殊协议
    if (url.startsWith('tel:') ||
        url.startsWith('mailto:') ||
        url.startsWith('sms:')) {
      try {
        await launchUrl(Uri.parse(url));
      } catch (_) {}
      return NavigationActionPolicy.CANCEL;
    }

    return NavigationActionPolicy.ALLOW;
  }

  void _onUrlFieldTap() {
    setState(() => _isEditingUrl = true);
    _controller.urlController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.urlController.text.length,
    );
  }

  void _onUrlFieldEditingComplete() {
    setState(() => _isEditingUrl = false);
    _controller.onUrlSubmitted(_controller.urlController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(colorScheme),
      body: Column(
        children: [
          // 加载进度条
          Watch((context) {
            final progress = browserState.loadProgress.value;
            final isLoading = browserState.isLoading.value;
            if (!isLoading || progress >= 1.0) {
              return const SizedBox.shrink();
            }
            return LinearProgressIndicator(
              value: progress,
              minHeight: 2,
              backgroundColor: Colors.transparent,
            );
          }),
          // WebView
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(
                  widget.initialUrl ??
                      (browserState.currentUrl.value.isNotEmpty
                          ? browserState.currentUrl.value
                          : browserState.homePage.value),
                ),
              ),
              initialSettings: BrowserSettings.webViewSettings,
              onWebViewCreated: _onWebViewCreated,
              onLoadStart: _onLoadStart,
              onLoadStop: _onLoadStop,
              onProgressChanged: _onProgressChanged,
              onTitleChanged: _onTitleChanged,
              shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
              onDownloadStartRequest: (controller, request) async {
                // 处理下载请求
                _showDownloadDialog(request);
              },
              onConsoleMessage: (controller, consoleMessage) {
                debugPrint('Browser Console: ${consoleMessage.message}');
              },
              onReceivedError: (controller, request, error) {
                debugPrint('Browser Error: ${error.description}');
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(colorScheme),
      endDrawer: _buildDrawer(context),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 8,
      title: _buildUrlBar(colorScheme),
      actions: [
        // 菜单按钮
        IconButton(
          icon: const Icon(Icons.more_vert),
          tooltip: '菜单',
          onPressed: () {
            _scaffoldKey.currentState?.openEndDrawer();
          },
        ),
      ],
    );
  }

  Widget _buildUrlBar(ColorScheme colorScheme) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // 安全图标
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Watch((context) {
              final url = browserState.currentUrl.value;
              final isSecure = url.startsWith('https://');
              return Icon(
                isSecure ? Icons.lock_outline : Icons.lock_open,
                size: 16,
                color: isSecure
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              );
            }),
          ),
          // 地址输入框
          Expanded(
            child: TextField(
              controller: _controller.urlController,
              focusNode: _urlFocusNode,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                isDense: true,
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.go,
              onTap: _onUrlFieldTap,
              onSubmitted: (_) => _onUrlFieldEditingComplete(),
              onEditingComplete: _onUrlFieldEditingComplete,
            ),
          ),
          // 刷新/停止按钮
          Watch((context) {
            final isLoading = browserState.isLoading.value;
            return IconButton(
              icon: Icon(
                isLoading ? Icons.close : Icons.refresh,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              onPressed: isLoading ? _controller.stopLoading : _controller.reload,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ColorScheme colorScheme) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 后退
          Watch((context) {
            final canGoBack = browserState.canGoBack.value;
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: '后退',
              onPressed: canGoBack ? _controller.goBack : null,
            );
          }),
          // 前进
          Watch((context) {
            final canGoForward = browserState.canGoForward.value;
            return IconButton(
              icon: const Icon(Icons.arrow_forward),
              tooltip: '前进',
              onPressed: canGoForward ? _controller.goForward : null,
            );
          }),
          // 首页
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: '首页',
            onPressed: _controller.goHome,
          ),
          // 书签
          Watch((context) {
            final url = browserState.currentUrl.value;
            final isBookmarked = browserState.isBookmarked(url);
            return IconButton(
              icon: Icon(
                isBookmarked ? Icons.star : Icons.star_outline,
                color: isBookmarked ? Colors.amber : null,
              ),
              tooltip: isBookmarked ? '移除书签' : '添加书签',
              onPressed: () async {
                if (isBookmarked) {
                  await browserState.removeBookmark(url);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('已移除书签'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                } else {
                  await browserState.addBookmark(
                    browserState.pageTitle.value,
                    url,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('已添加书签'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                }
              },
            );
          }),
          // 分享
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: '分享',
            onPressed: () {
              final url = browserState.currentUrl.value;
              if (url.isNotEmpty) {
                Share.share(url);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.public, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    '浏览器',
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 激活提示
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, 
                        color: colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '激活应用',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '在地址栏输入 hibi://start 并回车即可进入主应用。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.content_copy, size: 16),
                    label: const Text('复制激活地址'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onPrimaryContainer,
                      side: BorderSide(color: colorScheme.onPrimaryContainer),
                    ),
                    onPressed: () {
                      Clipboard.setData(
                        const ClipboardData(text: 'hibi://start'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('已复制到剪贴板'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // 菜单列表
            ListTile(
              leading: const Icon(Icons.star_outline),
              title: const Text('书签'),
              onTap: () {
                Navigator.pop(context);
                _showBookmarksDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('历史记录'),
              onTap: () {
                Navigator.pop(context);
                _showHistoryDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('设置首页'),
              subtitle: Watch((context) {
                return Text(
                  browserState.homePage.value,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              }),
              onTap: () {
                Navigator.pop(context);
                _showSetHomePageDialog();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.open_in_browser),
              title: const Text('在外部浏览器打开'),
              onTap: () async {
                Navigator.pop(context);
                final url = browserState.currentUrl.value;
                if (url.isNotEmpty) {
                  try {
                    await launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  } catch (_) {}
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('复制链接'),
              onTap: () {
                Navigator.pop(context);
                final url = browserState.currentUrl.value;
                if (url.isNotEmpty) {
                  Clipboard.setData(ClipboardData(text: url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('已复制到剪贴板'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
            ),
            const Spacer(),
            // 版本信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Hibiscus Browser',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookmarksDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // 标题栏
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.star),
                      const SizedBox(width: 12),
                      const Text(
                        '书签',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // 书签列表
                Expanded(
                  child: Watch((context) {
                    final bookmarks = browserState.bookmarks.value;
                    if (bookmarks.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_outline, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('暂无书签'),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: bookmarks.length,
                      itemBuilder: (context, index) {
                        final bookmark = bookmarks[index];
                        return ListTile(
                          leading: const Icon(Icons.bookmark),
                          title: Text(
                            bookmark.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            bookmark.url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await browserState.removeBookmark(bookmark.url);
                            },
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _controller.navigateTo(bookmark.url);
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showHistoryDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // 标题栏
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.history),
                      const SizedBox(width: 12),
                      const Text(
                        '历史记录',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('清空历史记录'),
                              content: const Text('确定要清空所有浏览历史吗？'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('取消'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('清空'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await browserState.clearHistory();
                          }
                        },
                        child: const Text('清空'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // 历史列表
                Expanded(
                  child: Watch((context) {
                    final history = browserState.browseHistory.value;
                    if (history.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.history, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('暂无浏览记录'),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return ListTile(
                          leading: const Icon(Icons.language),
                          title: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            item.url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _controller.navigateTo(item.url);
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSetHomePageDialog() {
    final controller = TextEditingController(
      text: browserState.homePage.value,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置首页'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: '首页地址',
                    hintText: 'https://www.bing.com',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.my_location, size: 16),
              label: const Text('使用当前页面'),
              onPressed: () {
                controller.text = browserState.currentUrl.value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                await browserState.setHomePage(url);
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showDownloadDialog(DownloadStartRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('下载文件'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('文件名: ${request.suggestedFilename ?? '未知'}'),
            const SizedBox(height: 8),
            Text(
              '链接: ${request.url}',
              style: const TextStyle(fontSize: 12),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              // 使用外部浏览器下载
              try {
                await launchUrl(
                  request.url,
                  mode: LaunchMode.externalApplication,
                );
              } catch (_) {}
            },
            child: const Text('在浏览器中下载'),
          ),
        ],
      ),
    );
  }
}
