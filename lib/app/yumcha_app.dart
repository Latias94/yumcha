/// 🏠 YumCha 应用主组件
///
/// 应用的根组件，负责：
/// - 🎨 主题管理
library;

/// - 🚀 初始化状态管理
/// - 🔄 路由配置
/// - 📱 全局UI配置

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'navigation/app_router.dart';
import 'navigation/main_navigation.dart';
import '../shared/infrastructure/services/notification_service.dart';
import '../shared/presentation/providers/app_initialization_provider.dart';
import 'theme/theme_provider.dart';
import 'config/splash_config.dart';
import 'widgets/app_splash_screen.dart';
import '../shared/presentation/widgets/enhanced_splash_screen.dart';

/// YumCha 应用主组件
///
/// 负责管理应用的整体状态和UI结构。
/// 根据初始化状态显示不同的界面：
/// - 初始化中：显示启动页面
/// - 初始化失败：显示错误页面
/// - 初始化完成：显示主界面
class YumchaApp extends ConsumerWidget {
  const YumchaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听应用初始化状态
    final initState = ref.watch(appInitializationProvider);

    final themeSettings = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return MaterialApp(
      title: 'Yumcha',
      theme:
          themeNotifier.getLightTheme().useSystemChineseFont(Brightness.light),
      darkTheme:
          themeNotifier.getDarkTheme().useSystemChineseFont(Brightness.dark),
      themeMode: themeSettings.themeMode,
      scaffoldMessengerKey: NotificationService.scaffoldMessengerKey,
      home: _buildAppContent(context, ref, initState),
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }

  /// 根据初始化状态构建应用内容
  Widget _buildAppContent(
    BuildContext context,
    WidgetRef ref,
    AppInitializationState initState,
  ) {
    if (initState.canEnterMainApp) {
      // 初始化完成且满足最小显示时间，显示主界面
      return const MainNavigation();
    } else if (initState.hasError) {
      // 初始化失败，显示错误页面
      return _buildErrorScreen(initState.error!, ref);
    } else {
      // 正在初始化或等待最小显示时间，显示启动页（根据配置选择）
      return SplashScreenFactory.createSplashScreen(
        initState: initState,
        standardBuilder: (state) => AppSplashScreen(initState: state),
        enhancedBuilder: (state) => EnhancedSplashScreen(initState: state),
      );
    }
  }

  /// 构建错误页面
  Widget _buildErrorScreen(String error, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('应用初始化失败', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('错误: $error', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(appInitializationProvider.notifier).retry(),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}
