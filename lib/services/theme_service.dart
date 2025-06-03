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
  bool _isDynamicColorAvailable = false;
  ColorScheme? _lightDynamicColorScheme;
  ColorScheme? _darkDynamicColorScheme;

  ColorMode get colorMode => _colorMode;
  bool get dynamicColor => _dynamicColor;
  bool get isDynamicColorAvailable => _isDynamicColorAvailable;
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
    try {
      final corePalette = await DynamicColorPlugin.getCorePalette();
      _isDynamicColorAvailable = corePalette != null;

      if (_dynamicColor && corePalette != null) {
        _lightDynamicColorScheme = corePalette.toColorScheme();
        _darkDynamicColorScheme = corePalette.toColorScheme(
          brightness: Brightness.dark,
        );
      } else {
        _lightDynamicColorScheme = null;
        _darkDynamicColorScheme = null;
      }
    } catch (e) {
      // 如果获取动态颜色失败，标记为不可用
      _isDynamicColorAvailable = false;
      _lightDynamicColorScheme = null;
      _darkDynamicColorScheme = null;
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

  Future<bool> setDynamicColor(bool enabled) async {
    // 如果要启用动态颜色但不可用，返回 false
    if (enabled && !_isDynamicColorAvailable) {
      return false;
    }

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
    return true;
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
