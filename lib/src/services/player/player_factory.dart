// 播放器工厂
// 根据设置和平台创建合适的播放器实例

import 'dart:io';

import 'package:hibiscus/src/services/player/player_service.dart';
import 'package:hibiscus/src/services/player/media_kit_player.dart';
import 'package:hibiscus/src/services/player/better_player_adapter.dart';
import 'package:hibiscus/src/state/settings_state.dart';

class PlayerFactory {
  /// 创建播放器实例
  static PlayerService create({PlayerType? type}) {
    final effectiveType = type ?? _getPreferredType();

    // PC 端强制使用 media_kit
    if (!Platform.isAndroid && !Platform.isIOS) {
      return MediaKitPlayer();
    }

    switch (effectiveType) {
      case PlayerType.betterPlayer:
        return BetterPlayerAdapter();
      case PlayerType.mediaKit:
        return MediaKitPlayer();
    }
  }

  /// 获取用户设置的首选播放器类型
  static PlayerType _getPreferredType() {
    final settings = settingsState.settings.value;
    return settings.preferredPlayerType;
  }

  /// 检查当前平台是否支持指定类型
  static bool isSupported(PlayerType type) {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return type == PlayerType.mediaKit;
    }
    return true;
  }

  /// 获取当前平台支持的播放器类型列表
  static List<PlayerType> supportedTypes() {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return [PlayerType.mediaKit];
    }
    return PlayerType.values.toList();
  }

  /// 获取默认播放器类型
  static PlayerType defaultType() {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return PlayerType.mediaKit;
    }
    return PlayerType.mediaKit;
  }
}
