// 用户状态管理

import 'package:signals/signals_flutter.dart';
import 'package:hibiscus/src/rust/api/user.dart' as user_api;
import 'package:hibiscus/src/rust/api/init.dart' as init_api;

/// 用户登录状态
enum LoginStatus {
  unknown,    // 初始状态
  loggedIn,   // 已登录
  loggedOut,  // 未登录
}

/// 用户信息
class UserInfo {
  final String id;
  final String username;
  final String? avatarUrl;
  final bool isVip;
  
  const UserInfo({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.isVip = false,
  });
}

/// 用户状态
class UserState {
  // 单例
  static final UserState _instance = UserState._();
  factory UserState() => _instance;
  UserState._();
  
  // 登录状态
  final loginStatus = signal(LoginStatus.unknown);
  
  // 用户信息
  final userInfo = signal<UserInfo?>(null);
  
  // Cookies（用于 Cloudflare 验证后保存）
  final cookies = signal<Map<String, String>>({});
  
  // 是否正在加载
  final isLoading = signal(false);
  
  /// 用户是否已登录
  bool get isLoggedIn => loginStatus.value == LoginStatus.loggedIn;
  
  /// 检查登录状态
  Future<void> checkLoginStatus() async {
    isLoading.value = true;
    
    try {
      final current = await user_api.getCurrentUser();
      if (current != null && current.isLoggedIn) {
        loginStatus.value = LoginStatus.loggedIn;
        userInfo.value = UserInfo(
          id: current.id,
          username: current.name,
          avatarUrl: current.avatarUrl,
        );
      } else {
        loginStatus.value = LoginStatus.loggedOut;
        userInfo.value = null;
      }
    } catch (e) {
      loginStatus.value = LoginStatus.loggedOut;
      userInfo.value = null;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 设置 Cookies（从 WebView 获取）
  Future<void> setCookies(Map<String, String> newCookies) async {
    cookies.value = newCookies;
    if (newCookies.isEmpty) return;
    final cookieString = newCookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
    await init_api.setCookies(cookieString: cookieString);
    await checkLoginStatus();
  }
  
  /// 登出
  Future<void> logout() async {
    cookies.value = {};
    userInfo.value = null;
    loginStatus.value = LoginStatus.loggedOut;
    await init_api.clearCookies();
  }
  
  /// 手动导入 Cookies（Linux 无 WebView 时使用）
  Future<bool> importCookies(String cookieString) async {
    try {
      final parsed = <String, String>{};
      
      for (final part in cookieString.split(';')) {
        final trimmed = part.trim();
        final idx = trimmed.indexOf('=');
        if (idx > 0) {
          final key = trimmed.substring(0, idx).trim();
          final value = trimmed.substring(idx + 1).trim();
          parsed[key] = value;
        }
      }
      
      if (parsed.isEmpty) return false;

      await init_api.setCookies(cookieString: cookieString);
      await checkLoginStatus();
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// 全局用户状态实例
final userState = UserState();
