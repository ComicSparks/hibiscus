// 设置状态管理

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'dart:convert';
import 'package:hibiscus/src/rust/api/settings.dart' as rust_settings;
import 'package:hibiscus/src/services/player/player_service.dart';

/// 应用设置
class AppSettings {
  final ThemeMode themeMode;
  final int maxConcurrentDownloads;
  final double defaultVolume;
  final bool hardwareAcceleration;
  final String defaultPlayQuality;
  final String defaultDownloadQuality;
  final FullscreenOrientationMode fullscreenOrientationMode;
  final String? proxyUrl;
  final bool enableProxy;
  final PlayerType preferredPlayerType;
  
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.maxConcurrentDownloads = 1,
    this.defaultVolume = 1.0,
    this.hardwareAcceleration = true,
    this.defaultPlayQuality = '1080P',
    this.defaultDownloadQuality = '1080P',
    this.fullscreenOrientationMode = FullscreenOrientationMode.landscape,
    this.proxyUrl,
    this.enableProxy = false,
    this.preferredPlayerType = PlayerType.mediaKit,
  });

  /// 获取实际使用的播放器类型（PC 端强制 mediaKit）
  PlayerType get effectivePlayerType {
    if (Platform.isAndroid || Platform.isIOS) {
      return preferredPlayerType;
    }
    return PlayerType.mediaKit;
  }
  
  AppSettings copyWith({
    ThemeMode? themeMode,
    int? maxConcurrentDownloads,
    double? defaultVolume,
    bool? hardwareAcceleration,
    String? defaultPlayQuality,
    String? defaultDownloadQuality,
    FullscreenOrientationMode? fullscreenOrientationMode,
    String? proxyUrl,
    bool? enableProxy,
    PlayerType? preferredPlayerType,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      maxConcurrentDownloads: maxConcurrentDownloads ?? this.maxConcurrentDownloads,
      defaultVolume: defaultVolume ?? this.defaultVolume,
      hardwareAcceleration: hardwareAcceleration ?? this.hardwareAcceleration,
      defaultPlayQuality: defaultPlayQuality ?? this.defaultPlayQuality,
      defaultDownloadQuality: defaultDownloadQuality ?? this.defaultDownloadQuality,
      fullscreenOrientationMode:
          fullscreenOrientationMode ?? this.fullscreenOrientationMode,
      proxyUrl: proxyUrl ?? this.proxyUrl,
      enableProxy: enableProxy ?? this.enableProxy,
      preferredPlayerType: preferredPlayerType ?? this.preferredPlayerType,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.index,
    'maxConcurrentDownloads': maxConcurrentDownloads,
    'defaultVolume': defaultVolume,
    'hardwareAcceleration': hardwareAcceleration,
    'defaultPlayQuality': defaultPlayQuality,
    'defaultDownloadQuality': defaultDownloadQuality,
    'fullscreenOrientationMode': fullscreenOrientationMode.index,
    'proxyUrl': proxyUrl,
    'enableProxy': enableProxy,
    'preferredPlayerType': preferredPlayerType.index,
  };
  
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    int clampConcurrent(dynamic v) {
      final parsed = (v is num) ? v.toInt() : int.tryParse('$v');
      return (parsed ?? 1).clamp(1, 2);
    }
    FullscreenOrientationMode parseFullscreenMode(dynamic v) {
      final parsed = (v is num) ? v.toInt() : int.tryParse('$v');
      final idx = (parsed ?? FullscreenOrientationMode.landscape.index)
          .clamp(0, FullscreenOrientationMode.values.length - 1);
      return FullscreenOrientationMode.values[idx];
    }
    int parsePlayerType(dynamic v) {
      final parsed = (v is num) ? v.toInt() : int.tryParse('$v');
      final idx = (parsed ?? PlayerType.mediaKit.index)
          .clamp(0, PlayerType.values.length - 1);
      return idx;
    }
    return AppSettings(
      themeMode: ThemeMode.values[json['themeMode'] ?? 0],
      maxConcurrentDownloads: clampConcurrent(json['maxConcurrentDownloads']),
      defaultVolume: (json['defaultVolume'] ?? 1.0).toDouble(),
      hardwareAcceleration: json['hardwareAcceleration'] ?? true,
      defaultPlayQuality: json['defaultPlayQuality'] ?? '1080P',
      defaultDownloadQuality: json['defaultDownloadQuality'] ?? '1080P',
      fullscreenOrientationMode:
          parseFullscreenMode(json['fullscreenOrientationMode']),
      proxyUrl: json['proxyUrl'],
      enableProxy: json['enableProxy'] ?? false,
      preferredPlayerType: PlayerType.values[parsePlayerType(json['preferredPlayerType'])],
    );
  }
}

enum FullscreenOrientationMode {
  keepCurrent,
  portrait,
  landscape,
  byVideoSize,
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
      final jsonStr = await rust_settings.getFlutterSettings();
      if (jsonStr != null && jsonStr.isNotEmpty) {
        settings.value = AppSettings.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
      }
      
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
  /// 设置最大并发下载数
  Future<void> setMaxConcurrentDownloads(int max) async {
    final clamped = max.clamp(1, 2);
    settings.value = settings.value.copyWith(maxConcurrentDownloads: clamped);
    await _save();
    try {
      await rust_settings.setDownloadConcurrent(count: clamped);
    } catch (_) {
      // ignore
    }
  }
  
  Future<void> setDefaultPlayQuality(String quality) async {
    settings.value = settings.value.copyWith(defaultPlayQuality: quality);
    await _save();
  }

  /// 设置默认下载清晰度
  Future<void> setDefaultDownloadQuality(String quality) async {
    settings.value = settings.value.copyWith(defaultDownloadQuality: quality);
    await _save();
  }

  Future<void> setFullscreenOrientationMode(FullscreenOrientationMode mode) async {
    settings.value = settings.value.copyWith(fullscreenOrientationMode: mode);
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

  /// 设置首选播放器类型
  Future<void> setPreferredPlayerType(PlayerType type) async {
    settings.value = settings.value.copyWith(preferredPlayerType: type);
    await _save();
  }

  /// 重置设置
  Future<void> reset() async {
    settings.value = const AppSettings();
    await _save();
  }
  
  /// 保存设置到本地存储
  Future<void> _save() async {
    final jsonStr = jsonEncode(settings.value.toJson());
    await rust_settings.saveFlutterSettings(json: jsonStr);
  }
}

/// 全局设置状态实例
final settingsState = SettingsState();
