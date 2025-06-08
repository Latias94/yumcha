import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/navigation/app_router.dart';
import 'shared/infrastructure/services/ai/ai_service_manager.dart';
import 'shared/infrastructure/services/notification_service.dart';
import 'shared/infrastructure/services/logger_service.dart';
import 'shared/infrastructure/services/database_service.dart';
import 'shared/infrastructure/services/preference_service.dart';
import 'app/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 确保绑定已初始化

  // 初始化数据库服务 (通过访问 getter 隐式初始化)
  DatabaseService.instance.database;

  // 初始化偏好设置服务
  await PreferenceService().init();

  // 初始化服务
  LoggerService().initialize();

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
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
