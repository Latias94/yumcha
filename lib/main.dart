import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/yumcha_app.dart';
import 'shared/infrastructure/services/logger_service.dart';
import 'shared/infrastructure/services/preference_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 只初始化最基础的服务
    await _initializeBasicServices();

    // 启动应用，其他服务通过 Riverpod Provider 初始化
    runApp(const ProviderScope(child: YumchaApp()));
  } catch (e) {
    // 如果基础服务初始化失败，显示错误页面
    runApp(_buildErrorApp(e.toString()));
  }
}

/// 初始化最基础的服务
///
/// 只初始化在 Riverpod 之外必须初始化的服务：
/// - 日志服务（用于记录初始化过程）
/// - 偏好设置服务（某些Provider可能需要）
Future<void> _initializeBasicServices() async {
  // 1. 初始化日志服务
  LoggerService().initialize();
  LoggerService().info('🚀 开始应用启动');

  // 2. 初始化偏好设置服务
  LoggerService().info('⚙️ 初始化偏好设置服务');
  await PreferenceService().init();
  LoggerService().info('✅ 偏好设置服务初始化完成');

  LoggerService().info('🎉 基础服务初始化完成');
}

/// 构建启动错误应用
Widget _buildErrorApp(String error) {
  return MaterialApp(
    title: 'Yumcha - 启动错误',
    home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('应用启动失败', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                '错误: $error',
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => main(), // 重新启动
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    ),
  );
}
