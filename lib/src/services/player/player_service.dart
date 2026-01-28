// 播放器服务抽象接口
// 支持 media_kit 和 better_player_plus

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

/// 播放器类型
enum PlayerType {
  /// media_kit 播放器，PC 端唯一选择，移动端可选
  mediaKit,
  /// better_player_plus，移动端默认，支持画中画
  betterPlayer,
}

/// 播放器状态
class PlayerState {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isBuffering;
  final int? width;
  final int? height;
  final double volume;
  final String? error;

  const PlayerState({
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isBuffering = false,
    this.width,
    this.height,
    this.volume = 1.0,
    this.error,
  });

  PlayerState copyWith({
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    bool? isBuffering,
    int? width,
    int? height,
    double? volume,
    String? error,
  }) {
    return PlayerState(
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      width: width ?? this.width,
      height: height ?? this.height,
      volume: volume ?? this.volume,
      error: error,
    );
  }
}

/// 播放器服务抽象接口
abstract class PlayerService {
  /// 播放器状态流
  Stream<PlayerState> get stateStream;

  /// 当前播放状态
  PlayerState get currentState;

  /// 打开视频（网络地址）
  Future<void> openUrl(
    String url, {
    Map<String, String>? headers,
    bool autoPlay = true,
    Duration? startPosition,
  });

  /// 打开本地文件
  Future<void> openFile(
    String path, {
    bool autoPlay = true,
    Duration? startPosition,
  });

  /// 播放
  Future<void> play();

  /// 暂停
  Future<void> pause();

  /// 跳转到指定位置
  Future<void> seek(Duration position);

  /// 设置音量 (0.0 - 1.0)
  Future<void> setVolume(double volume);

  /// 停止播放
  Future<void> stop();

  /// 释放资源
  Future<void> dispose();

  /// 进入全屏
  Future<void> enterFullscreen();

  /// 退出全屏
  Future<void> exitFullscreen();

  /// 是否支持画中画
  bool get supportsPictureInPicture;

  /// 进入画中画模式
  Future<void> enterPictureInPicture();

  /// 退出画中画模式
  Future<void> exitPictureInPicture();

  /// 是否正在画中画模式
  bool get isInPictureInPicture;

  /// 构建播放器 Widget
  Widget buildVideoWidget({
    BoxFit fit = BoxFit.contain,
    Color backgroundColor = Colors.black,
  });

  /// 当前播放器类型
  PlayerType get playerType;

  /// 检测当前平台支持的播放器类型
  static List<PlayerType> supportedTypes() {
    if (Platform.isAndroid || Platform.isIOS) {
      return [PlayerType.betterPlayer, PlayerType.mediaKit];
    }
    // PC 端只支持 media_kit
    return [PlayerType.mediaKit];
  }

  /// 获取默认播放器类型
  static PlayerType defaultType() {
    if (Platform.isAndroid || Platform.isIOS) {
      return PlayerType.betterPlayer;
    }
    return PlayerType.mediaKit;
  }

  /// 检查指定类型是否支持
  static bool isSupported(PlayerType type) {
    return supportedTypes().contains(type);
  }
}
