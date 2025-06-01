import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import '../theme/colors.dart';

enum ColorMode { system, light, dark }

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const String _colorModeKey = 'color_mode';
  static const String _dynamicColorKey = 'dynamic_color';

  ColorMode _colorMode = ColorMode.system;
  bool _dynamicColor = true;
  ColorScheme? _lightDynamicColorScheme;
  ColorScheme? _darkDynamicColorScheme;

  ColorMode get colorMode => _colorMode;
  bool get dynamicColor => _dynamicColor;
  ColorScheme? get lightDynamicColorScheme => _lightDynamicColorScheme;
  ColorScheme? get darkDynamicColorScheme => _darkDynamicColorScheme;

  ThemeMode get themeMode {
    switch (_colorMode) {
      case ColorMode.light:
        return ThemeMode.light;
      case ColorMode.dark:
        return ThemeMode.dark;
      case ColorMode.system:
        return ThemeMode.system;
    }
  }

  String get colorModeDisplayName {
    switch (_colorMode) {
      case ColorMode.system:
        return '跟随系统';
      case ColorMode.light:
        return '浅色模式';
      case ColorMode.dark:
        return '深色模式';
    }
  }

  Future<void> initialize() async {
    await _loadSettings();
    await _loadDynamicColors();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // 加载颜色模式
    final colorModeIndex = prefs.getInt(_colorModeKey) ?? 0;
    _colorMode = ColorMode.values[colorModeIndex];

    // 加载动态颜色设置
    _dynamicColor = prefs.getBool(_dynamicColorKey) ?? true;

    notifyListeners();
  }

  Future<void> _loadDynamicColors() async {
    if (_dynamicColor) {
      final corePalette = await DynamicColorPlugin.getCorePalette();
      if (corePalette != null) {
        _lightDynamicColorScheme = corePalette.toColorScheme();
        _darkDynamicColorScheme = corePalette.toColorScheme(
          brightness: Brightness.dark,
        );
      }
    }
    notifyListeners();
  }

  Future<void> setColorMode(ColorMode mode) async {
    if (_colorMode != mode) {
      _colorMode = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_colorModeKey, mode.index);
      notifyListeners();
    }
  }

  Future<void> setDynamicColor(bool enabled) async {
    if (_dynamicColor != enabled) {
      _dynamicColor = enabled;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_dynamicColorKey, enabled);

      if (enabled) {
        await _loadDynamicColors();
      } else {
        _lightDynamicColorScheme = null;
        _darkDynamicColorScheme = null;
        notifyListeners();
      }
    }
  }

  ColorScheme getLightColorScheme() {
    if (_dynamicColor && _lightDynamicColorScheme != null) {
      return _lightDynamicColorScheme!;
    }
    return AppColors.lightColorScheme;
  }

  ColorScheme getDarkColorScheme() {
    if (_dynamicColor && _darkDynamicColorScheme != null) {
      return _darkDynamicColorScheme!;
    }
    return AppColors.darkColorScheme;
  }
}
