import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:media_kit/media_kit.dart';
import 'package:hibiscus/src/rust/frb_generated.dart';
import 'package:hibiscus/src/rust/api/init.dart' as init_api;
import 'package:hibiscus/src/router/router.dart';
import 'package:hibiscus/src/ui/theme/app_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hibiscus/src/state/user_state.dart';
import 'package:hibiscus/src/state/settings_state.dart';
import 'package:hibiscus/src/state/host_state.dart';
import 'package:signals/signals_flutter.dart';
import 'package:hibiscus/src/services/app_logger.dart';
import 'package:hibiscus/src/services/update_service.dart';
import 'package:hibiscus/src/services/webdav_sync_service.dart';
import 'package:hibiscus/browser/browser_state.dart';
import 'package:hibiscus/browser/browser_entry.dart';

Future<void> main() async {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const AppEntry());
  }, (error, stack) => AppLogger.error('zone', error.toString(), stack: stack));
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await RustLib.init();
    final appSupportDir = await getApplicationSupportDirectory();
    debugPrint('App Support Directory: ${appSupportDir.path}');
    await init_api.initApp(dataPath: appSupportDir.path);
    AppLogger.installGlobalHandlers();
    await activeHostState.init();
    await userState.checkLoginStatus();
    await settingsState.init();
    await browserState.init();
    MediaKit.ensureInitialized();
    if (!mounted) return;
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const InitializationPage();
    }
    // 根据激活状态决定入口
    // 未激活时显示浏览器，激活后显示主应用
    return BrowserEntry(
      appBuilder: () => const HibiscusApp(),
    );
  }
}

class InitializationPage extends StatelessWidget {
  const InitializationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hibiscus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: Scaffold(
        appBar: AppBar(title: const Text('Hibiscus')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              SvgPicture.asset(
                'assets/images/android_adaptive_foreground.svg',
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 12),
              const Text('正在初始化...'),
            ],
          ),
        ),
      ),
    );
  }
}

class HibiscusApp extends StatefulWidget {
  const HibiscusApp({super.key});

  @override
  State<HibiscusApp> createState() => _HibiscusAppState();
}

class _HibiscusAppState extends State<HibiscusApp> {
  AppOrientation? _lastOrientation;

  List<DeviceOrientation> _deviceOrientations(AppOrientation orientation) {
    return switch (orientation) {
      AppOrientation.portrait => [DeviceOrientation.portraitUp],
      AppOrientation.landscape => [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      AppOrientation.automatic => const [],
    };
  }

  void _applyOrientation(AppOrientation orientation) {
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    if (_lastOrientation == orientation) return;
    _lastOrientation = orientation;
    final orientations = _deviceOrientations(orientation);
    SystemChrome.setPreferredOrientations(orientations);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final navigatorContext = appNavigatorKey.currentContext;
      if (navigatorContext == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final ctx = appNavigatorKey.currentContext;
          if (ctx != null) maybeAutoCheckUpdate(ctx);
        });
        return;
      }
      maybeAutoCheckUpdate(navigatorContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final mode = settingsState.settings.value.themeMode;
      final orientation = settingsState.settings.value.appOrientation;
      _applyOrientation(orientation);
      return MaterialApp(
        title: 'Hibiscus',
        debugShowCheckedModeBanner: false,
        navigatorKey: appNavigatorKey,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        initialRoute: AppRoutes.home,
        onGenerateRoute: onGenerateRoute,
        builder: (context, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            WebDavSyncService.autoSyncOnAppStart(context: context);
          });
          return child ?? const SizedBox.shrink();
        },
      );
    });
  }
}
