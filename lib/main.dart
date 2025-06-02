import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'navigation/main_navigation.dart';
import 'services/ai_service.dart';
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
  // 初始化AI服务 (它依赖于数据库服务)
  await AiService().initialize();
  // 初始化主题服务
  await ThemeService().initialize();

  runApp(ProviderScope(child: const YumchaApp()));
}

class YumchaApp extends StatelessWidget {
  const YumchaApp({super.key});

  @override
  Widget build(BuildContext context) {
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
          home: const MainNavigation(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('YumCha AI助手'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.smart_toy, size: 100, color: Colors.deepPurple),
            const SizedBox(height: 20),
            const Text(
              '欢迎使用 YumCha AI助手',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '智能对话，无限可能',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConfigScreen()),
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text('配置管理'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
