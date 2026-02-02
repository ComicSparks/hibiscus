// 登录页面

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hibiscus/browser/browser_state.dart';
import 'package:hibiscus/src/rust/api/init.dart' as init_api;
import 'package:hibiscus/src/state/host_state.dart';
import 'package:hibiscus/src/state/user_state.dart';

const String _kFallbackLoginUserAgent =
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _progress = ValueNotifier<double>(0);
  bool _saving = false;
  late final ActiveHostInfo _hostInfo;

  /// 使用 browserState 中保存的 UserAgent，如果没有则使用默认值
  String get _webviewUserAgent => browserState.userAgent.value ?? _kFallbackLoginUserAgent;

  @override
  void initState() {
    super.initState();
    _hostInfo = activeHostState.activeHost.value;
    _clearCookies();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  Future<void> _clearCookies() async {
    final cookieManager = CookieManager.instance();
    await cookieManager.deleteAllCookies();
  }

  Future<void> _finishLogin() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final cookieManager = CookieManager.instance();
      final cookies =
          await cookieManager.getCookies(url: WebUri(_hostInfo.loginUrl));
      final cookieString = cookies.map((c) => '${c.name}=${c.value}').join('; ');
      debugPrint('cookieString: $cookieString');
      // 显式传递域名，确保 cookies 保存到正确的域名
      await init_api.setCookies(cookieString: cookieString, domain: _hostInfo.host);
      await userState.checkLoginStatus();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        actions: [
          ValueListenableBuilder<double>(
            valueListenable: _progress,
            builder: (context, value, _) {
              if (value <= 0 || value >= 1) return const SizedBox();
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(value: value),
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: '完成',
            onPressed: _saving ? null : _finishLogin,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
          ),
        ],
      ),
      body: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(_hostInfo.loginUrl),
              ),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  useShouldOverrideUrlLoading: false,
                  userAgent: _webviewUserAgent,
                ),
                android: AndroidInAppWebViewOptions(
                  domStorageEnabled: true,
                ),
                ios: IOSInAppWebViewOptions(
                  allowsInlineMediaPlayback: true,
                ),
              ),
              onProgressChanged: (controller, progress) {
                _progress.value = progress / 100.0;
              },
            ),
    );
  }
}
