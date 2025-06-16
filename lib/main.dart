import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/yumcha_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 启动应用，所有服务通过 Riverpod Provider 初始化
  runApp(const ProviderScope(child: YumchaApp()));
}
