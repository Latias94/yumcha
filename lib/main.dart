import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'navigation/main_navigation.dart';
import 'services/ai_service.dart';
import 'services/notification_service.dart';
import 'services/logger_service.dart';

void main() {
  // 初始化服务
  LoggerService().initialize();
  AiService().initialize();

  runApp(const YumchaApp());
}

class YumchaApp extends StatelessWidget {
  const YumchaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yumcha',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      scaffoldMessengerKey: NotificationService.scaffoldMessengerKey,
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}
