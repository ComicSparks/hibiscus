// 浏览器状态管理
// 使用 Rust 端 sqlite(settings 表) 持久化存储应用是否已激活等状态
import 'package:signals/signals_flutter.dart';
import 'package:hibiscus/src/services/rust_kv_store.dart';
import 'package:hibiscus/src/rust/api/user.dart' as user_api;

/// 浏览器/激活状态管理
class BrowserState {
  // 单例
  static final BrowserState _instance = BrowserState._();
  factory BrowserState() => _instance;
  BrowserState._();

  static const _keyAppActivated = 'hibiscus_app_activated';
  static const _keyLastVisitedUrl = 'hibiscus_last_visited_url';
  static const _keyBookmarks = 'hibiscus_bookmarks';
  static const _keyBrowseHistory = 'hibiscus_browse_history';
  static const _keyHomePage = 'hibiscus_browser_home_page';
  static const _keyUserAgent = 'hibiscus_browser_user_agent';

  /// 激活协议
  static const activationScheme = 'hibi://start';

  /// 默认首页
  static const defaultHomePage = 'https://www.bing.com';

  // 应用是否已激活（首次进入浏览器后输入 hibi://start 激活）
  final isActivated = signal(false);

  // 是否正在加载中
  final isLoading = signal(false);

  // 当前 URL
  final currentUrl = signal('');

  // 页面标题
  final pageTitle = signal('');

  // 加载进度 (0.0 - 1.0)
  final loadProgress = signal(0.0);

  // 是否可以后退
  final canGoBack = signal(false);

  // 是否可以前进
  final canGoForward = signal(false);

  // 首页
  final homePage = signal(defaultHomePage);

  // 书签列表
  final bookmarks = signal<List<BrowserBookmark>>([]);

  // 浏览历史
  final browseHistory = signal<List<BrowserHistoryItem>>([]);

  // 用户代理
  final userAgent = signal<String?>(null);

  /// 初始化状态
  Future<void> init() async {
    await _loadState();
  }

  Future<void> _loadState() async {
    // 加载激活状态
    isActivated.value = await RustKvStore.getBool(_keyAppActivated) ?? false;

    // 加载首页
    homePage.value = await RustKvStore.getString(_keyHomePage) ?? defaultHomePage;

    // 加载书签
    final bookmarksRaw = await RustKvStore.getStringList(_keyBookmarks);
    if (bookmarksRaw != null) {
      bookmarks.value = bookmarksRaw
          .map((e) => BrowserBookmark.fromString(e))
          .whereType<BrowserBookmark>()
          .toList();
    }

    // 加载历史
    final historyRaw = await RustKvStore.getStringList(_keyBrowseHistory);
    if (historyRaw != null) {
      browseHistory.value = historyRaw
          .map((e) => BrowserHistoryItem.fromString(e))
          .whereType<BrowserHistoryItem>()
          .toList();
    }

    // 加载上次访问的 URL
    currentUrl.value =
        await RustKvStore.getString(_keyLastVisitedUrl) ?? homePage.value;

    // 加载 UserAgent
    userAgent.value = await RustKvStore.getString(_keyUserAgent);
  }

  /// 检查输入的 URL 是否是激活协议
  bool checkActivation(String url) {
    final normalized = url.trim().toLowerCase();
    return normalized == activationScheme ||
        normalized == 'hibi://start/' ||
        normalized.startsWith('hibi://start');
  }

  /// 激活应用
  Future<void> activate() async {
    isActivated.value = true;
    await RustKvStore.setBool(_keyAppActivated, true);
  }

  /// 重置激活状态（仅用于测试/调试）
  Future<void> resetActivation() async {
    isActivated.value = false;
    await RustKvStore.setBool(_keyAppActivated, false);
  }

  /// 更新当前 URL
  Future<void> updateCurrentUrl(String url) async {
    currentUrl.value = url;
    await RustKvStore.setString(_keyLastVisitedUrl, url);
  }

  /// 更新页面标题
  void updateTitle(String title) {
    pageTitle.value = title;
  }

  /// 更新加载状态
  void updateLoadingState({
    required bool loading,
    double? progress,
    bool? back,
    bool? forward,
  }) {
    isLoading.value = loading;
    if (progress != null) loadProgress.value = progress;
    if (back != null) canGoBack.value = back;
    if (forward != null) canGoForward.value = forward;
  }

  /// 设置首页
  Future<void> setHomePage(String url) async {
    homePage.value = url;
    await RustKvStore.setString(_keyHomePage, url);
  }

  /// 添加书签
  Future<void> addBookmark(String title, String url) async {
    final bookmark = BrowserBookmark(
      title: title,
      url: url,
      createdAt: DateTime.now(),
    );
    bookmarks.value = [...bookmarks.value, bookmark];
    await _saveBookmarks();
  }

  /// 移除书签
  Future<void> removeBookmark(String url) async {
    bookmarks.value = bookmarks.value.where((b) => b.url != url).toList();
    await _saveBookmarks();
  }

  /// 检查是否已收藏
  bool isBookmarked(String url) {
    return bookmarks.value.any((b) => b.url == url);
  }

  Future<void> _saveBookmarks() async {
    final list = bookmarks.value.map((b) => b.toString()).toList();
    await RustKvStore.setStringList(_keyBookmarks, list);
  }

  /// 添加浏览历史
  Future<void> addHistory(String title, String url) async {
    // 移除重复项
    final filtered = browseHistory.value.where((h) => h.url != url).toList();
    
    final item = BrowserHistoryItem(
      title: title,
      url: url,
      visitedAt: DateTime.now(),
    );
    
    // 保持最多 100 条历史
    final newHistory = [item, ...filtered];
    if (newHistory.length > 100) {
      browseHistory.value = newHistory.sublist(0, 100);
    } else {
      browseHistory.value = newHistory;
    }
    
    await _saveHistory();
  }

  /// 清空浏览历史
  Future<void> clearHistory() async {
    browseHistory.value = [];
    await RustKvStore.remove(_keyBrowseHistory);
  }

  Future<void> _saveHistory() async {
    final list = browseHistory.value.map((h) => h.toString()).toList();
    await RustKvStore.setStringList(_keyBrowseHistory, list);
  }

  /// 保存 UserAgent 并通知 Rust 端重新加载
  Future<void> saveUserAgent(String ua) async {
    userAgent.value = ua;
    await RustKvStore.setString(_keyUserAgent, ua);
    // 通知 Rust 端重新加载 UserAgent
    try {
      await user_api.reloadUserAgent();
    } catch (_) {
      // 忽略错误
    }
  }
}

/// 书签数据类
class BrowserBookmark {
  final String title;
  final String url;
  final DateTime createdAt;

  const BrowserBookmark({
    required this.title,
    required this.url,
    required this.createdAt,
  });

  @override
  String toString() {
    return '$title\x1F$url\x1F${createdAt.millisecondsSinceEpoch}';
  }

  static BrowserBookmark? fromString(String str) {
    final parts = str.split('\x1F');
    if (parts.length != 3) return null;
    final timestamp = int.tryParse(parts[2]);
    if (timestamp == null) return null;
    return BrowserBookmark(
      title: parts[0],
      url: parts[1],
      createdAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
  }
}

/// 浏览历史数据类
class BrowserHistoryItem {
  final String title;
  final String url;
  final DateTime visitedAt;

  const BrowserHistoryItem({
    required this.title,
    required this.url,
    required this.visitedAt,
  });

  @override
  String toString() {
    return '$title\x1F$url\x1F${visitedAt.millisecondsSinceEpoch}';
  }

  static BrowserHistoryItem? fromString(String str) {
    final parts = str.split('\x1F');
    if (parts.length != 3) return null;
    final timestamp = int.tryParse(parts[2]);
    if (timestamp == null) return null;
    return BrowserHistoryItem(
      title: parts[0],
      url: parts[1],
      visitedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
  }
}

/// 全局浏览器状态实例
final browserState = BrowserState();
