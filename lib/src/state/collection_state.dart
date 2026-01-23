// 收藏/稍后观看/订阅状态管理

import 'package:signals/signals_flutter.dart';
import '../ui/widgets/video_grid.dart';

/// 收藏夹
class FavoriteFolder {
  final String id;
  final String name;
  final int count;
  final DateTime createdAt;
  
  const FavoriteFolder({
    required this.id,
    required this.name,
    this.count = 0,
    required this.createdAt,
  });
}

/// 订阅频道
class Subscription {
  final String id;
  final String name;
  final String? avatarUrl;
  final int videoCount;
  final DateTime subscribedAt;
  
  const Subscription({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.videoCount = 0,
    required this.subscribedAt,
  });
}

/// 收藏状态
class FavoritesState {
  static final FavoritesState _instance = FavoritesState._();
  factory FavoritesState() => _instance;
  FavoritesState._();
  
  // 收藏夹列表
  final folders = signal<List<FavoriteFolder>>([]);
  
  // 当前选中收藏夹的视频
  final videos = signal<List<VideoItem>>([]);
  
  // 当前选中的收藏夹ID
  final currentFolderId = signal<String?>(null);
  
  // 是否正在加载
  final isLoading = signal(false);
  
  /// 加载收藏夹列表
  Future<void> loadFolders() async {
    isLoading.value = true;
    
    try {
      // TODO: 从 API 加载
      await Future.delayed(const Duration(milliseconds: 300));
      
      folders.value = [
        FavoriteFolder(
          id: 'default',
          name: '默認收藏夾',
          count: 15,
          createdAt: DateTime.now(),
        ),
        FavoriteFolder(
          id: 'folder_1',
          name: '稍後觀看',
          count: 8,
          createdAt: DateTime.now(),
        ),
      ];
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 加载收藏夹中的视频
  Future<void> loadVideos(String folderId) async {
    currentFolderId.value = folderId;
    isLoading.value = true;
    
    try {
      // TODO: 从 API 加载
      await Future.delayed(const Duration(milliseconds: 300));
      
      videos.value = List.generate(
        10,
        (i) => VideoItem(
          id: 'fav_video_$i',
          title: '收藏視頻 $i',
          coverUrl: '',
          duration: '${15 + i}:00',
          views: '${1000 + i * 100}',
          tags: ['標籤$i'],
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 添加到收藏夹
  Future<bool> addToFolder(String folderId, VideoItem video) async {
    // TODO: 调用 API
    return true;
  }
  
  /// 从收藏夹移除
  Future<bool> removeFromFolder(String folderId, String videoId) async {
    videos.value = videos.value.where((v) => v.id != videoId).toList();
    // TODO: 调用 API
    return true;
  }
  
  /// 创建收藏夹
  Future<FavoriteFolder?> createFolder(String name) async {
    // TODO: 调用 API
    final folder = FavoriteFolder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
    );
    folders.value = [...folders.value, folder];
    return folder;
  }
  
  /// 删除收藏夹
  Future<bool> deleteFolder(String folderId) async {
    folders.value = folders.value.where((f) => f.id != folderId).toList();
    // TODO: 调用 API
    return true;
  }
  
  /// 检查视频是否已收藏
  bool isVideoFavorited(String videoId) {
    return videos.value.any((v) => v.id == videoId);
  }
}

/// 稍后观看状态
class WatchLaterState {
  static final WatchLaterState _instance = WatchLaterState._();
  factory WatchLaterState() => _instance;
  WatchLaterState._();
  
  // 视频列表
  final videos = signal<List<VideoItem>>([]);
  
  // 是否正在加载
  final isLoading = signal(false);
  
  /// 加载列表
  Future<void> load() async {
    isLoading.value = true;
    
    try {
      // TODO: 从本地存储加载
      await Future.delayed(const Duration(milliseconds: 300));
      
      videos.value = List.generate(
        5,
        (i) => VideoItem(
          id: 'watch_later_$i',
          title: '稍後觀看視頻 $i',
          coverUrl: '',
          duration: '${20 + i}:00',
          views: '${2000 + i * 200}',
          tags: [],
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 添加到稍后观看
  Future<void> add(VideoItem video) async {
    if (videos.value.any((v) => v.id == video.id)) return;
    
    videos.value = [video, ...videos.value];
    // TODO: 保存到本地存储
  }
  
  /// 移除
  Future<void> remove(String videoId) async {
    videos.value = videos.value.where((v) => v.id != videoId).toList();
    // TODO: 从本地存储删除
  }
  
  /// 清空
  Future<void> clear() async {
    videos.value = [];
    // TODO: 清空本地存储
  }
  
  /// 检查是否已添加
  bool contains(String videoId) {
    return videos.value.any((v) => v.id == videoId);
  }
}

/// 订阅状态
class SubscriptionsState {
  static final SubscriptionsState _instance = SubscriptionsState._();
  factory SubscriptionsState() => _instance;
  SubscriptionsState._();
  
  // 订阅列表
  final subscriptions = signal<List<Subscription>>([]);
  
  // 当前选中订阅的视频
  final videos = signal<List<VideoItem>>([]);
  
  // 是否正在加载
  final isLoading = signal(false);
  
  /// 加载订阅列表
  Future<void> load() async {
    isLoading.value = true;
    
    try {
      // TODO: 从 API 加载
      await Future.delayed(const Duration(milliseconds: 300));
      
      subscriptions.value = List.generate(
        8,
        (i) => Subscription(
          id: 'sub_$i',
          name: '創作者 $i',
          videoCount: 50 + i * 10,
          subscribedAt: DateTime.now().subtract(Duration(days: i * 7)),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 加载订阅频道的视频
  Future<void> loadVideos(String subscriptionId) async {
    isLoading.value = true;
    
    try {
      // TODO: 从 API 加载
      await Future.delayed(const Duration(milliseconds: 300));
      
      videos.value = List.generate(
        20,
        (i) => VideoItem(
          id: 'sub_video_$i',
          title: '訂閱視頻 $i',
          coverUrl: '',
          duration: '${10 + i}:00',
          views: '${5000 + i * 500}',
          tags: [],
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 订阅
  Future<bool> subscribe(String id, String name) async {
    if (subscriptions.value.any((s) => s.id == id)) return false;
    
    subscriptions.value = [
      ...subscriptions.value,
      Subscription(
        id: id,
        name: name,
        subscribedAt: DateTime.now(),
      ),
    ];
    // TODO: 调用 API
    return true;
  }
  
  /// 取消订阅
  Future<bool> unsubscribe(String id) async {
    subscriptions.value = subscriptions.value.where((s) => s.id != id).toList();
    // TODO: 调用 API
    return true;
  }
  
  /// 检查是否已订阅
  bool isSubscribed(String id) {
    return subscriptions.value.any((s) => s.id == id);
  }
}

/// 全局实例
final favoritesState = FavoritesState();
final watchLaterState = WatchLaterState();
final subscriptionsState = SubscriptionsState();
