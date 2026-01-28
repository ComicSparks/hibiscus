// BetterPlayerPlus 播放器实现
// 仅支持 iOS 和 Android，支持画中画功能

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:hibiscus/src/services/player/player_service.dart';
import 'package:hibiscus/src/state/settings_state.dart';

class BetterPlayerAdapter with WidgetsBindingObserver implements PlayerService {
  BetterPlayerController? _controller;
  final _stateController = StreamController<PlayerState>.broadcast();
  PlayerState _currentState = const PlayerState();
  bool _isInPip = false;
  Timer? _positionTimer;
  Orientation _lastOrientation = Orientation.portrait;
  GlobalKey? _playerKey;

  BetterPlayerAdapter() {
    WidgetsBinding.instance.addObserver(this);
  }

  void _setupListeners() {
    _controller?.addEventsListener(_onPlayerEvent);
    // 定期更新播放位置
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _updatePositionFromController();
    });
  }

  void _updatePositionFromController() {
    final videoPlayerValue = _controller?.videoPlayerController?.value;
    if (videoPlayerValue != null) {
      final position = videoPlayerValue.position;
      final duration = videoPlayerValue.duration;
      if (_currentState.position != position ||
          _currentState.duration != duration) {
        _updateState(_currentState.copyWith(
          position: position,
          duration: duration,
        ));
      }
    }
  }

  void _onPlayerEvent(BetterPlayerEvent event) {
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.initialized:
        final videoPlayerValue = _controller?.videoPlayerController?.value;
        if (videoPlayerValue != null) {
          _updateState(_currentState.copyWith(
            duration: videoPlayerValue.duration,
            width: videoPlayerValue.size?.width.toInt(),
            height: videoPlayerValue.size?.height.toInt(),
            isBuffering: false,
          ));
        }
        break;

      case BetterPlayerEventType.play:
        _updateState(_currentState.copyWith(isPlaying: true));
        break;

      case BetterPlayerEventType.pause:
        _updateState(_currentState.copyWith(isPlaying: false));
        break;

      case BetterPlayerEventType.bufferingStart:
        _updateState(_currentState.copyWith(isBuffering: true));
        break;

      case BetterPlayerEventType.bufferingEnd:
        _updateState(_currentState.copyWith(isBuffering: false));
        break;

      case BetterPlayerEventType.progress:
        final progress = event.parameters?['progress'] as Duration?;
        final duration = event.parameters?['duration'] as Duration?;
        if (progress != null) {
          _updateState(_currentState.copyWith(
            position: progress,
            duration: duration ?? _currentState.duration,
          ));
        }
        break;

      case BetterPlayerEventType.exception:
        final error = event.parameters?['exception']?.toString();
        if (error != null) {
          _updateState(_currentState.copyWith(error: error));
        }
        break;

      case BetterPlayerEventType.openFullscreen:
        unawaited(enterFullscreen());
        break;

      case BetterPlayerEventType.hideFullscreen:
        unawaited(exitFullscreen());
        break;

      case BetterPlayerEventType.pipStart:
        _isInPip = true;
        break;

      case BetterPlayerEventType.pipStop:
        _isInPip = false;
        break;

      default:
        break;
    }
  }

  void _updateState(PlayerState state) {
    _currentState = state;
    _stateController.add(state);
  }

  @override
  PlayerType get playerType => PlayerType.betterPlayer;

  @override
  Stream<PlayerState> get stateStream => _stateController.stream;

  @override
  PlayerState get currentState => _currentState;

  BetterPlayerConfiguration _buildConfiguration({
    Duration? startPosition,
    bool autoPlay = true,
  }) {
    final pipEnabled = Platform.isAndroid || Platform.isIOS;
    return BetterPlayerConfiguration(
      autoPlay: autoPlay,
      startAt: startPosition,
      fit: BoxFit.contain,
      autoDispose: false,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enablePlayPause: true,
        enableFullscreen: true,
        enableProgressBar: true,
        enableProgressText: true,
        enableSkips: false,
        enableSubtitles: false,
        enableQualities: false,
        enableAudioTracks: false,
        enableMute: true,
        enablePip: pipEnabled,
        controlBarColor: Colors.black54,
        progressBarPlayedColor: Colors.pinkAccent,
        progressBarBufferedColor: Colors.white54,
        progressBarBackgroundColor: Colors.white24,
      ),
      allowedScreenSleep: false,
    );
  }

  @override
  Future<void> openUrl(
    String url, {
    Map<String, String>? headers,
    bool autoPlay = true,
    Duration? startPosition,
  }) async {
    _updateState(const PlayerState(isBuffering: true));

    // 如果已有控制器，先彻底释放
    await _disposeController();
    
    // 等待一帧确保释放完成
    await Future.delayed(const Duration(milliseconds: 50));

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      headers: headers,
      notificationConfiguration: const BetterPlayerNotificationConfiguration(
        showNotification: false,
      ),
    );

    _playerKey = GlobalKey();
    _controller = BetterPlayerController(
      _buildConfiguration(
        startPosition: startPosition,
        autoPlay: autoPlay,
      ),
      betterPlayerDataSource: dataSource,
    );
    _controller?.setBetterPlayerGlobalKey(_playerKey!);

    _setupListeners();
  }

  @override
  Future<void> openFile(
    String path, {
    bool autoPlay = true,
    Duration? startPosition,
  }) async {
    _updateState(const PlayerState(isBuffering: true));

    // 如果已有控制器，先彻底释放
    await _disposeController();
    
    // 等待一帧确保释放完成
    await Future.delayed(const Duration(milliseconds: 50));

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.file,
      path,
      notificationConfiguration: const BetterPlayerNotificationConfiguration(
        showNotification: false,
      ),
    );

    _playerKey = GlobalKey();
    _controller = BetterPlayerController(
      _buildConfiguration(
        startPosition: startPosition,
        autoPlay: autoPlay,
      ),
      betterPlayerDataSource: dataSource,
    );
    _controller?.setBetterPlayerGlobalKey(_playerKey!);

    _setupListeners();
  }

  @override
  Future<void> play() async {
    _controller?.play();
  }

  @override
  Future<void> pause() async {
    _controller?.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    _controller?.seekTo(position);
  }

  @override
  Future<void> setVolume(double volume) async {
    _controller?.setVolume(volume.clamp(0.0, 1.0));
  }

  @override
  Future<void> stop() async {
    _controller?.pause();
  }

  Future<void> _disposeController() async {
    _positionTimer?.cancel();
    _positionTimer = null;
    
    final controller = _controller;
    _controller = null;
    _playerKey = null;
    
    if (controller != null) {
      try {
        controller.removeEventsListener(_onPlayerEvent);
        // 先暂停播放
        controller.pause();
        // 重要：等待一帧确保暂停生效
        await Future.delayed(const Duration(milliseconds: 100));
        // 销毁控制器
        controller.dispose(forceDispose: true);
      } catch (e) {
        // 忽略 dispose 错误
        debugPrint('BetterPlayer dispose error: $e');
      }
    }
    
    // 强制垃圾回收提示
    _currentState = const PlayerState();
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _disposeController();
    
    // 关闭状态流
    if (!_stateController.isClosed) {
      await _stateController.close();
    }
  }

  @override
  bool get supportsPictureInPicture => Platform.isAndroid || Platform.isIOS;

  @override
  Future<void> enterPictureInPicture() async {
    if (!supportsPictureInPicture) return;
    final controller = _controller;
    final key = controller?.betterPlayerGlobalKey ?? _playerKey;
    if (controller == null || key == null) return;
    controller.enablePictureInPicture(key);
  }

  @override
  Future<void> exitPictureInPicture() async {
    if (_isInPip) {
      _controller?.disablePictureInPicture();
    }
  }

  @override
  bool get isInPictureInPicture => _isInPip;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!supportsPictureInPicture) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // handleLifecycle=false 时，避免未进入 PiP 仍在后台播放
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_isInPip) {
          _controller?.pause();
        }
      });
    }
  }

  @override
  Future<void> enterFullscreen() async {
    if (!(Platform.isAndroid || Platform.isIOS)) return;

    final mode = settingsState.settings.value.fullscreenOrientationMode;
    final isPortrait = _lastOrientation == Orientation.portrait;
    final w = _currentState.width ?? 0;
    final h = _currentState.height ?? 0;
    final isLandscapeVideo = w > 0 && h > 0 && w >= h;

    final orientations = switch (mode) {
      FullscreenOrientationMode.keepCurrent => isPortrait
          ? <DeviceOrientation>[DeviceOrientation.portraitUp]
          : <DeviceOrientation>[
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ],
      FullscreenOrientationMode.portrait => <DeviceOrientation>[
          DeviceOrientation.portraitUp,
        ],
      FullscreenOrientationMode.landscape => <DeviceOrientation>[
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      FullscreenOrientationMode.byVideoSize => isLandscapeVideo
          ? <DeviceOrientation>[
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          : <DeviceOrientation>[DeviceOrientation.portraitUp],
    };

    await Future.wait([
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: const [],
      ),
      SystemChrome.setPreferredOrientations(orientations),
    ]);
  }

  @override
  Future<void> exitFullscreen() async {
    if (!(Platform.isAndroid || Platform.isIOS)) return;

    await Future.wait([
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      ),
      SystemChrome.setPreferredOrientations(const []),
    ]);
  }

  /// 更新设备方向状态
  void updateOrientation(Orientation orientation) {
    _lastOrientation = orientation;
  }

  /// 获取内部控制器（用于高级功能）
  BetterPlayerController? get internalController => _controller;

  @override
  Widget buildVideoWidget({
    BoxFit fit = BoxFit.contain,
    Color backgroundColor = Colors.black,
  }) {
    if (_controller == null) {
      return Container(
        color: backgroundColor,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      color: backgroundColor,
      child: BetterPlayer(controller: _controller!, key: _playerKey),
    );
  }
}
