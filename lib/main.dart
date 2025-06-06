import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'navigation/app_router.dart';
import 'services/ai/ai_service_manager.dart';
import 'services/notification_service.dart';
import 'services/logger_service.dart';
import 'services/database_service.dart';
import 'services/theme_service.dart';
import 'services/preference_service.dart';
import 'screens/config_screen.dart';
import 'package:yumcha/src/rust/frb_generated.dart';

void main() async {
  await RustLib.init();
  WidgetsFlutterBinding.ensureInitialized(); // 确保绑定已初始化

  // 初始化数据库服务 (通过访问 getter 隐式初始化)
  DatabaseService.instance.database;

  // 初始化偏好设置服务
  await PreferenceService().init();

  // 初始化服务
  LoggerService().initialize();

  // 初始化主题服务
  await ThemeService().initialize();

  // 初始化 MCP 服务
  await _initializeMcp();

  runApp(ProviderScope(child: const YumchaApp()));
}

/// 初始化 MCP 服务
Future<void> _initializeMcp() async {
  try {
    // 这里暂时使用默认设置，实际应用中会从设置中读取
    // 由于在 main 函数中无法直接使用 Riverpod，我们先跳过 MCP 初始化
    // MCP 将在应用启动后通过设置页面进行配置和初始化
    LoggerService().info('MCP 服务将在应用启动后进行配置');
  } catch (e) {
    LoggerService().error('MCP 初始化失败', {'error': e.toString()});
  }
}

class YumchaApp extends ConsumerWidget {
  const YumchaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(initializeAiServicesProvider);

    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, child) {
        final themeService = ThemeService();
        return MaterialApp(
          title: 'Yumcha',
          theme: AppTheme.getLightTheme(themeService.getLightColorScheme()),
          darkTheme: AppTheme.getDarkTheme(themeService.getDarkColorScheme()),
          themeMode: themeService.themeMode,
          scaffoldMessengerKey: NotificationService.scaffoldMessengerKey,
          initialRoute: AppRouter.home,
          onGenerateRoute: AppRouter.generateRoute,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
