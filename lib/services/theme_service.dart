import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import '../theme/colors.dart';

enum ColorMode { system, light, dark }

enum AppThemeType {
  standard, // 标准主题
  mediumContrast, // 中对比主题
  highContrast, // 高对比主题
  vibrant, // 活力主题
}

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const String _colorModeKey = 'color_mode';
  static const String _dynamicColorKey = 'dynamic_color';
  static const String _appThemeTypeKey = 'app_theme_type';

  ColorMode _colorMode = ColorMode.system;
  bool _dynamicColor = true;
  AppThemeType _appThemeType = AppThemeType.standard;
  bool _isDynamicColorAvailable = false;
  ColorScheme? _lightDynamicColorScheme;
  ColorScheme? _darkDynamicColorScheme;

  ColorMode get colorMode => _colorMode;
  bool get dynamicColor => _dynamicColor;
  AppThemeType get appThemeType => _appThemeType;
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

  String get appThemeTypeDisplayName {
    switch (_appThemeType) {
      case AppThemeType.standard:
        return '标准';
      case AppThemeType.mediumContrast:
        return '中对比';
      case AppThemeType.highContrast:
        return '高对比';
      case AppThemeType.vibrant:
        return '活力';
    }
  }

  String getAppThemeTypeDescription(AppThemeType type) {
    switch (type) {
      case AppThemeType.standard:
        return '平衡的颜色和对比度';
      case AppThemeType.mediumContrast:
        return '增强的对比度，更易阅读';
      case AppThemeType.highContrast:
        return '最高对比度，最佳可访问性';
      case AppThemeType.vibrant:
        return '鲜艳的颜色，充满活力';
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

    // 加载动态颜色设置 - 如果是第一次启动且动态颜色不可用，默认关闭
    _dynamicColor = prefs.getBool(_dynamicColorKey) ?? true;

    // 加载主题类型设置
    final appThemeTypeIndex = prefs.getInt(_appThemeTypeKey) ?? 0;
    _appThemeType = AppThemeType.values[appThemeTypeIndex];

    notifyListeners();
  }

  Future<void> _loadDynamicColors() async {
    try {
      final corePalette = await DynamicColorPlugin.getCorePalette();
      _isDynamicColorAvailable = corePalette != null;

      // 如果动态颜色不可用，自动关闭动态颜色设置
      if (!_isDynamicColorAvailable && _dynamicColor) {
        _dynamicColor = false;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_dynamicColorKey, false);
      }

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
      // 如果获取动态颜色失败，标记为不可用并关闭动态颜色
      _isDynamicColorAvailable = false;
      if (_dynamicColor) {
        _dynamicColor = false;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_dynamicColorKey, false);
      }
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

  Future<void> setAppThemeType(AppThemeType type) async {
    if (_appThemeType != type) {
      _appThemeType = type;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_appThemeTypeKey, type.index);
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

    switch (_appThemeType) {
      case AppThemeType.standard:
        return AppColors.lightColorScheme;
      case AppThemeType.mediumContrast:
        return AppColors.mediumContrastLightColorScheme;
      case AppThemeType.highContrast:
        return AppColors.highContrastLightColorScheme;
      case AppThemeType.vibrant:
        return AppColors.vibrantLightColorScheme;
    }
  }

  ColorScheme getDarkColorScheme() {
    if (_dynamicColor && _darkDynamicColorScheme != null) {
      return _darkDynamicColorScheme!;
    }

    switch (_appThemeType) {
      case AppThemeType.standard:
        return AppColors.darkColorScheme;
      case AppThemeType.mediumContrast:
        return AppColors.mediumContrastDarkColorScheme;
      case AppThemeType.highContrast:
        return AppColors.highContrastDarkColorScheme;
      case AppThemeType.vibrant:
        return AppColors.vibrantDarkColorScheme;
    }
  }
}
