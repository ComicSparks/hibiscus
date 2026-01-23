import 'package:flutter/material.dart';
import 'package:hibiscus/src/rust/frb_generated.dart';
import 'package:hibiscus/src/router/router.dart';
import 'package:hibiscus/src/ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Rust 库
  await RustLib.init();
  
  // TODO: 初始化 MediaKit
  // MediaKit.ensureInitialized();
  
  runApp(const HibiscusApp());
}

class HibiscusApp extends StatelessWidget {
  const HibiscusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = createRouter();
    
    return MaterialApp.router(
      title: 'Hibiscus',
      debugShowCheckedModeBanner: false,
      
      // 主题配置
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      
      // 路由配置
      routerConfig: router,
    );
  }
}
