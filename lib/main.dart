import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'navigation/main_navigation.dart';

void main() {
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
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}
