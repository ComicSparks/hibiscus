// 浏览器控制器
// 封装 InAppWebView 的控制逻辑

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hibiscus/browser/browser_state.dart';

/// 浏览器控制器
class BrowserController {
  InAppWebViewController? _webViewController;
  final TextEditingController urlController = TextEditingController();
  
  // 激活回调
  final VoidCallback? onActivated;
  
  BrowserController({this.onActivated});

  /// 设置 WebView 控制器
  void setWebViewController(InAppWebViewController controller) {
    _webViewController = controller;
  }

  /// 获取 WebView 控制器
  InAppWebViewController? get webViewController => _webViewController;

  /// 导航到指定 URL
  Future<void> navigateTo(String url) async {
    final controller = _webViewController;
    if (controller == null) return;

    String finalUrl = url.trim();
    
    // 检查是否是激活协议
    if (browserState.checkActivation(finalUrl)) {
      await browserState.activate();
      onActivated?.call();
      return;
    }

    // 自动添加协议
    if (!finalUrl.startsWith('http://') && 
        !finalUrl.startsWith('https://') &&
        !finalUrl.startsWith('file://')) {
      // 如果看起来像域名，添加 https
      if (finalUrl.contains('.') && !finalUrl.contains(' ')) {
        finalUrl = 'https://$finalUrl';
      } else {
        // 否则当作搜索
        finalUrl = 'https://www.bing.com/search?q=${Uri.encodeComponent(finalUrl)}';
      }
    }

    await controller.loadUrl(urlRequest: URLRequest(url: WebUri(finalUrl)));
    urlController.text = finalUrl;
  }

  /// 后退
  Future<void> goBack() async {
    final controller = _webViewController;
    if (controller == null) return;
    if (await controller.canGoBack()) {
      await controller.goBack();
    }
  }

  /// 前进
  Future<void> goForward() async {
    final controller = _webViewController;
    if (controller == null) return;
    if (await controller.canGoForward()) {
      await controller.goForward();
    }
  }

  /// 刷新
  Future<void> reload() async {
    await _webViewController?.reload();
  }

  /// 停止加载
  Future<void> stopLoading() async {
    await _webViewController?.stopLoading();
  }

  /// 回到首页
  Future<void> goHome() async {
    await navigateTo(browserState.homePage.value);
  }

  /// 更新导航状态
  Future<void> updateNavigationState() async {
    final controller = _webViewController;
    if (controller == null) return;

    final canBack = await controller.canGoBack();
    final canForward = await controller.canGoForward();
    browserState.updateLoadingState(
      loading: browserState.isLoading.value,
      back: canBack,
      forward: canForward,
    );
  }

  /// 获取当前 URL
  Future<String?> getCurrentUrl() async {
    final url = await _webViewController?.getUrl();
    return url?.toString();
  }

  /// 获取页面标题
  Future<String?> getTitle() async {
    return await _webViewController?.getTitle();
  }

  /// 执行 JavaScript
  Future<dynamic> evaluateJavascript(String source) async {
    return await _webViewController?.evaluateJavascript(source: source);
  }

  /// 截图
  Future<Uint8List?> takeScreenshot() async {
    return await _webViewController?.takeScreenshot();
  }

  /// 处理地址栏提交
  Future<void> onUrlSubmitted(String url) async {
    await navigateTo(url);
    // 隐藏键盘
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// 清理资源
  void dispose() {
    urlController.dispose();
  }
}

/// WebView 设置配置
class BrowserSettings {
  static const userAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  static InAppWebViewSettings get webViewSettings => InAppWebViewSettings(
    userAgent: userAgent,
    javaScriptEnabled: true,
    javaScriptCanOpenWindowsAutomatically: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    thirdPartyCookiesEnabled: true,
    supportZoom: true,
    builtInZoomControls: true,
    displayZoomControls: false,
    useWideViewPort: true,
    loadWithOverviewMode: true,
    domStorageEnabled: true,
    databaseEnabled: true,
    cacheEnabled: true,
    transparentBackground: false,
    verticalScrollBarEnabled: true,
    horizontalScrollBarEnabled: true,
    disableContextMenu: false,
    allowFileAccess: true,
    allowContentAccess: true,
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    useShouldOverrideUrlLoading: true,
    useOnLoadResource: false,
    useOnDownloadStart: true,
    allowsBackForwardNavigationGestures: true,
  );
}
