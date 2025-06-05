import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import '../theme/colors.dart';

/// 颜色模式枚举 - 定义应用的明暗主题模式
///
/// 支持三种颜色模式：
/// - `system`: 跟随系统设置自动切换
/// - `light`: 强制使用浅色模式
/// - `dark`: 强制使用深色模式
enum ColorMode {
  /// 跟随系统 - 根据系统设置自动切换明暗模式
  system,

  /// 浅色模式 - 强制使用浅色主题
  light,

  /// 深色模式 - 强制使用深色主题
  dark,
}

/// 应用主题类型枚举 - 定义不同的视觉风格和对比度
///
/// 提供四种主题风格，满足不同用户的视觉需求和可访问性要求：
///
/// ## 🎨 主题特性
/// - **standard**: 平衡的颜色和对比度，适合大多数用户
/// - **mediumContrast**: 增强的对比度，提升可读性
/// - **highContrast**: 最高对比度，最佳可访问性支持
/// - **vibrant**: 鲜艳的颜色，充满活力的视觉体验
enum AppThemeType {
  /// 标准主题 - 平衡的颜色和对比度
  ///
  /// 适合大多数用户的日常使用，提供舒适的视觉体验。
  standard,

  /// 中对比主题 - 增强的对比度，更易阅读
  ///
  /// 适合需要更好可读性的用户，在保持美观的同时提升对比度。
  mediumContrast,

  /// 高对比主题 - 最高对比度，最佳可访问性
  ///
  /// 专为视觉障碍用户设计，提供最高的颜色对比度。
  highContrast,

  /// 活力主题 - 鲜艳的颜色，充满活力
  ///
  /// 使用更鲜艳的颜色，为应用带来活力和现代感。
  vibrant,
}

/// 主题服务 - 应用外观和主题管理的核心服务
///
/// ThemeService负责管理整个应用的视觉主题，提供：
/// - 🎨 **主题管理**：多种主题风格和对比度选项
/// - 🌓 **明暗模式**：支持浅色、深色和跟随系统模式
/// - 🎯 **动态颜色**：支持Android 12+的Material You动态颜色
/// - ♿ **可访问性**：高对比度主题支持视觉障碍用户
/// - 💾 **持久化**：用户偏好自动保存和恢复
/// - 🔄 **实时更新**：主题变更时自动通知UI更新
///
/// ## 🏗️ 架构设计
///
/// ### 单例模式 + ChangeNotifier
/// 结合单例模式和观察者模式：
/// ```dart
/// final themeService = ThemeService(); // 单例实例
/// // 自动通知所有监听者主题变更
/// ```
///
/// ### 状态管理
/// 使用ChangeNotifier实现响应式主题更新：
/// - UI组件自动监听主题变化
/// - 主题切换时立即更新界面
/// - 支持多个组件同时监听
///
/// ## 🎨 主题系统
///
/// ### 四种主题风格
/// 1. **标准主题**: 平衡的颜色和对比度
/// 2. **中对比主题**: 增强可读性
/// 3. **高对比主题**: 最佳可访问性
/// 4. **活力主题**: 鲜艳活泼的颜色
///
/// ### 动态颜色支持
/// - **Android 12+**: 自动提取壁纸颜色
/// - **自动降级**: 不支持时使用预设主题
/// - **智能检测**: 自动检测系统支持情况
///
/// ### 明暗模式
/// - **跟随系统**: 自动跟随系统设置
/// - **强制模式**: 用户手动选择明暗
/// - **实时切换**: 无需重启应用
///
/// ## 🚀 使用示例
///
/// ### 初始化服务
/// ```dart
/// void main() async {
///   final themeService = ThemeService();
///   await themeService.initialize();
///   runApp(MyApp());
/// }
/// ```
///
/// ### 在Widget中使用
/// ```dart
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return ListenableBuilder(
///       listenable: ThemeService(),
///       builder: (context, child) {
///         final themeService = ThemeService();
///         return MaterialApp(
///           themeMode: themeService.themeMode,
///           theme: ThemeData(
///             colorScheme: themeService.getLightColorScheme(),
///           ),
///           darkTheme: ThemeData(
///             colorScheme: themeService.getDarkColorScheme(),
///           ),
///         );
///       },
///     );
///   }
/// }
/// ```
///
/// ### 切换主题
/// ```dart
/// final themeService = ThemeService();
///
/// // 切换颜色模式
/// await themeService.setColorMode(ColorMode.dark);
///
/// // 切换主题类型
/// await themeService.setAppThemeType(AppThemeType.vibrant);
///
/// // 启用动态颜色
/// await themeService.setDynamicColor(true);
/// ```
///
/// ## ⚙️ 配置特性
/// - **自动保存**: 用户设置自动保存到SharedPreferences
/// - **智能默认**: 首次启动时使用合理的默认设置
/// - **兼容性**: 自动处理不同Android版本的兼容性
/// - **性能优化**: 颜色方案缓存，避免重复计算
class ThemeService extends ChangeNotifier {
  // 单例模式实现
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
