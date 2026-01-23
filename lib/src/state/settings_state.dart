// 设置状态管理

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

/// 应用设置
class AppSettings {
  final ThemeMode themeMode;
  final String downloadPath;
  final int maxConcurrentDownloads;
  final bool autoPlay;
  final double defaultVolume;
  final bool hardwareAcceleration;
  final String? proxyUrl;
  final bool enableProxy;
  
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.downloadPath = '',
    this.maxConcurrentDownloads = 3,
    this.autoPlay = true,
    this.defaultVolume = 1.0,
    this.hardwareAcceleration = true,
    this.proxyUrl,
    this.enableProxy = false,
  });
  
  AppSettings copyWith({
    ThemeMode? themeMode,
    String? downloadPath,
    int? maxConcurrentDownloads,
    bool? autoPlay,
    double? defaultVolume,
    bool? hardwareAcceleration,
    String? proxyUrl,
    bool? enableProxy,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      downloadPath: downloadPath ?? this.downloadPath,
      maxConcurrentDownloads: maxConcurrentDownloads ?? this.maxConcurrentDownloads,
      autoPlay: autoPlay ?? this.autoPlay,
      defaultVolume: defaultVolume ?? this.defaultVolume,
      hardwareAcceleration: hardwareAcceleration ?? this.hardwareAcceleration,
      proxyUrl: proxyUrl ?? this.proxyUrl,
      enableProxy: enableProxy ?? this.enableProxy,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.index,
    'downloadPath': downloadPath,
    'maxConcurrentDownloads': maxConcurrentDownloads,
    'autoPlay': autoPlay,
    'defaultVolume': defaultVolume,
    'hardwareAcceleration': hardwareAcceleration,
    'proxyUrl': proxyUrl,
    'enableProxy': enableProxy,
  };
  
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values[json['themeMode'] ?? 0],
      downloadPath: json['downloadPath'] ?? '',
      maxConcurrentDownloads: json['maxConcurrentDownloads'] ?? 3,
      autoPlay: json['autoPlay'] ?? true,
      defaultVolume: (json['defaultVolume'] ?? 1.0).toDouble(),
      hardwareAcceleration: json['hardwareAcceleration'] ?? true,
      proxyUrl: json['proxyUrl'],
      enableProxy: json['enableProxy'] ?? false,
    );
  }
}

/// 设置状态
class SettingsState {
  // 单例
  static final SettingsState _instance = SettingsState._();
  factory SettingsState() => _instance;
  SettingsState._();
  
  // 当前设置
  final settings = signal(const AppSettings());
  
  // 是否已初始化
  final _initialized = signal(false);
  
  /// 主题模式
  ThemeMode get themeMode => settings.value.themeMode;
  
  /// 初始化设置
  Future<void> init() async {
    if (_initialized.value) return;
    
    try {
      // TODO: 从本地存储加载设置
      // final json = await storage.read('settings');
      // if (json != null) {
      //   settings.value = AppSettings.fromJson(jsonDecode(json));
      // }
      
      // 设置默认下载路径
      // final appDir = await getApplicationDocumentsDirectory();
      // if (settings.value.downloadPath.isEmpty) {
      //   settings.value = settings.value.copyWith(
      //     downloadPath: '${appDir.path}/downloads',
      //   );
      // }
      
      _initialized.value = true;
    } catch (e) {
      // 使用默认设置
      _initialized.value = true;
    }
  }
  
  /// 更新设置
  Future<void> update(AppSettings newSettings) async {
    settings.value = newSettings;
    await _save();
  }
  
  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    settings.value = settings.value.copyWith(themeMode: mode);
    await _save();
  }
  
  /// 设置下载路径
  Future<void> setDownloadPath(String path) async {
    settings.value = settings.value.copyWith(downloadPath: path);
    await _save();
  }
  
  /// 设置最大并发下载数
  Future<void> setMaxConcurrentDownloads(int max) async {
    settings.value = settings.value.copyWith(maxConcurrentDownloads: max);
    await _save();
  }
  
  /// 设置自动播放
  Future<void> setAutoPlay(bool autoPlay) async {
    settings.value = settings.value.copyWith(autoPlay: autoPlay);
    await _save();
  }
  
  /// 设置默认音量
  Future<void> setDefaultVolume(double volume) async {
    settings.value = settings.value.copyWith(defaultVolume: volume);
    await _save();
  }
  
  /// 设置硬件加速
  Future<void> setHardwareAcceleration(bool enabled) async {
    settings.value = settings.value.copyWith(hardwareAcceleration: enabled);
    await _save();
  }
  
  /// 设置代理
  Future<void> setProxy(String? url, bool enabled) async {
    settings.value = settings.value.copyWith(
      proxyUrl: url,
      enableProxy: enabled,
    );
    await _save();
    
    // TODO: 通知 Rust 更新代理设置
  }
  
  /// 重置设置
  Future<void> reset() async {
    settings.value = const AppSettings();
    await _save();
  }
  
  /// 保存设置到本地存储
  Future<void> _save() async {
    // TODO: 保存到本地存储
    // await storage.write('settings', jsonEncode(settings.value.toJson()));
  }
}

/// 全局设置状态实例
final settingsState = SettingsState();
