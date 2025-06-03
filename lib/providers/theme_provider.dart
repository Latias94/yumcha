import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

// 主题模式枚举
enum AppColorMode { system, light, dark }

// 主题方案枚举
enum AppThemeScheme {
  pink, // 粉色主题（温柔）
  green, // 绿色主题（自然）
  blue, // 蓝色主题（清新）
  monochrome, // 黑白主题（简约）
}

// 主题设置状态类
class ThemeSettings {
  final AppColorMode colorMode;
  final bool dynamicColorEnabled;
  final bool isDynamicColorAvailable;
  final AppThemeScheme themeScheme;

  const ThemeSettings({
    required this.colorMode,
    required this.dynamicColorEnabled,
    required this.isDynamicColorAvailable,
    required this.themeScheme,
  });

  ThemeSettings copyWith({
    AppColorMode? colorMode,
    bool? dynamicColorEnabled,
    bool? isDynamicColorAvailable,
    AppThemeScheme? themeScheme,
  }) {
    return ThemeSettings(
      colorMode: colorMode ?? this.colorMode,
      dynamicColorEnabled: dynamicColorEnabled ?? this.dynamicColorEnabled,
      isDynamicColorAvailable:
          isDynamicColorAvailable ?? this.isDynamicColorAvailable,
      themeScheme: themeScheme ?? this.themeScheme,
    );
  }

  // 获取 ThemeMode
  ThemeMode get themeMode {
    switch (colorMode) {
      case AppColorMode.light:
        return ThemeMode.light;
      case AppColorMode.dark:
        return ThemeMode.dark;
      case AppColorMode.system:
        return ThemeMode.system;
    }
  }

  // 获取颜色模式显示名称
  String get colorModeDisplayName {
    switch (colorMode) {
      case AppColorMode.system:
        return '跟随系统';
      case AppColorMode.light:
        return '浅色模式';
      case AppColorMode.dark:
        return '深色模式';
    }
  }

  // 获取主题方案显示名称
  String get themeSchemeDisplayName {
    switch (themeScheme) {
      case AppThemeScheme.pink:
        return '粉色';
      case AppThemeScheme.green:
        return '绿色';
      case AppThemeScheme.blue:
        return '蓝色';
      case AppThemeScheme.monochrome:
        return '黑白';
    }
  }

  // 获取主题方案描述
  String get themeSchemeDescription {
    switch (themeScheme) {
      case AppThemeScheme.pink:
        return '温柔粉色，浪漫优雅';
      case AppThemeScheme.green:
        return '自然绿色，清新舒适';
      case AppThemeScheme.blue:
        return '清新蓝色，沉稳专业';
      case AppThemeScheme.monochrome:
        return '黑白简约，经典永恒';
    }
  }

  // 是否应该显示主题选择器
  bool get shouldShowThemeSelector {
    return !isDynamicColorAvailable || !dynamicColorEnabled;
  }
}

// 主题状态管理器
class ThemeNotifier extends StateNotifier<ThemeSettings> {
  static const String _colorModeKey = 'app_color_mode';
  static const String _dynamicColorKey = 'app_dynamic_color';
  static const String _themeSchemeKey = 'app_theme_scheme';

  ColorScheme? _lightDynamicColorScheme;
  ColorScheme? _darkDynamicColorScheme;

  ThemeNotifier()
    : super(
        const ThemeSettings(
          colorMode: AppColorMode.system,
          dynamicColorEnabled: true,
          isDynamicColorAvailable: false,
          themeScheme: AppThemeScheme.pink,
        ),
      ) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadSettings();
    await _loadDynamicColors();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final colorModeIndex = prefs.getInt(_colorModeKey) ?? 0;
    final colorMode = AppColorMode.values[colorModeIndex];

    final dynamicColorEnabled = prefs.getBool(_dynamicColorKey) ?? true;

    final themeSchemeIndex = prefs.getInt(_themeSchemeKey) ?? 0;
    final themeScheme = AppThemeScheme.values[themeSchemeIndex];

    state = state.copyWith(
      colorMode: colorMode,
      dynamicColorEnabled: dynamicColorEnabled,
      themeScheme: themeScheme,
    );
  }

  Future<void> _loadDynamicColors() async {
    try {
      final corePalette = await DynamicColorPlugin.getCorePalette();
      final isAvailable = corePalette != null;

      // 如果动态颜色不可用，自动关闭动态颜色设置
      bool dynamicEnabled = state.dynamicColorEnabled;
      if (!isAvailable && dynamicEnabled) {
        dynamicEnabled = false;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_dynamicColorKey, false);
      }

      if (dynamicEnabled && corePalette != null) {
        _lightDynamicColorScheme = corePalette.toColorScheme();
        _darkDynamicColorScheme = corePalette.toColorScheme(
          brightness: Brightness.dark,
        );
      } else {
        _lightDynamicColorScheme = null;
        _darkDynamicColorScheme = null;
      }

      state = state.copyWith(
        isDynamicColorAvailable: isAvailable,
        dynamicColorEnabled: dynamicEnabled,
      );
    } catch (e) {
      // 如果获取动态颜色失败，标记为不可用并关闭动态颜色
      bool dynamicEnabled = false;
      if (state.dynamicColorEnabled) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_dynamicColorKey, false);
      }

      _lightDynamicColorScheme = null;
      _darkDynamicColorScheme = null;

      state = state.copyWith(
        isDynamicColorAvailable: false,
        dynamicColorEnabled: dynamicEnabled,
      );
    }
  }

  // 设置颜色模式
  Future<void> setColorMode(AppColorMode mode) async {
    if (state.colorMode != mode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_colorModeKey, mode.index);
      state = state.copyWith(colorMode: mode);
    }
  }

  // 设置动态颜色
  Future<bool> setDynamicColor(bool enabled) async {
    if (enabled && !state.isDynamicColorAvailable) {
      return false;
    }

    if (state.dynamicColorEnabled != enabled) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_dynamicColorKey, enabled);

      if (enabled) {
        await _loadDynamicColors();
      } else {
        _lightDynamicColorScheme = null;
        _darkDynamicColorScheme = null;
        state = state.copyWith(dynamicColorEnabled: enabled);
      }
    }
    return true;
  }

  // 设置主题方案
  Future<void> setThemeScheme(AppThemeScheme scheme) async {
    if (state.themeScheme != scheme) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeSchemeKey, scheme.index);
      state = state.copyWith(themeScheme: scheme);
    }
  }

  // 获取浅色主题
  ThemeData getLightTheme() {
    if (state.dynamicColorEnabled && _lightDynamicColorScheme != null) {
      return FlexThemeData.light(
        colorScheme: _lightDynamicColorScheme,
        useMaterial3: true,
      );
    }

    return _getFlexTheme(Brightness.light);
  }

  // 获取深色主题
  ThemeData getDarkTheme() {
    if (state.dynamicColorEnabled && _darkDynamicColorScheme != null) {
      return FlexThemeData.dark(
        colorScheme: _darkDynamicColorScheme,
        useMaterial3: true,
      );
    }

    return _getFlexTheme(Brightness.dark);
  }

  // 获取 FlexColorScheme 主题
  ThemeData _getFlexTheme(Brightness brightness) {
    final scheme = _getFlexScheme();

    if (brightness == Brightness.light) {
      return FlexThemeData.light(
        scheme: scheme,
        useMaterial3: true,
        appBarStyle: FlexAppBarStyle.surface,
        lightIsWhite: false, // 允许使用主题背景色
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold, // 使用分层表面
        blendLevel: 8, // 适度混合，让背景有颜色
        subThemesData: const FlexSubThemesData(
          // 增加混合程度，让主题颜色更明显
          blendOnLevel: 15,
          blendOnColors: false,
          useMaterial3Typography: true,
          useM2StyleDividerInM3: true,
          // 卡片样式
          cardElevation: 1,
          cardRadius: 12,
          // 按钮样式
          elevatedButtonRadius: 24,
          filledButtonRadius: 24,
          outlinedButtonRadius: 24,
          textButtonRadius: 24,
          // 输入框样式
          inputDecoratorRadius: 12,
          inputDecoratorBorderType: FlexInputBorderType.outline,
          // 导航样式
          navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
          navigationBarUnselectedLabelSchemeColor: SchemeColor.onSurfaceVariant,
          navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
          navigationBarIndicatorOpacity: 0.24,
          // 其他组件
          chipRadius: 8,
          dialogRadius: 16,
          timePickerDialogRadius: 16,
          snackBarRadius: 8,
          // 确保 Scaffold 背景使用主题颜色
          scaffoldBackgroundSchemeColor: SchemeColor.surface,
          // AppBar 样式
          appBarBackgroundSchemeColor: SchemeColor.surface,
          // 抽屉样式
          drawerBackgroundSchemeColor: SchemeColor.surface,
        ),
      );
    } else {
      return FlexThemeData.dark(
        scheme: scheme,
        useMaterial3: true,
        appBarStyle: FlexAppBarStyle.surface,
        darkIsTrueBlack: false, // 不使用纯黑背景
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold, // 使用分层表面
        blendLevel: 12, // 深色模式下更多混合
        subThemesData: const FlexSubThemesData(
          // 深色模式下适度混合
          blendOnLevel: 20,
          blendOnColors: false,
          useMaterial3Typography: true,
          useM2StyleDividerInM3: true,
          // 卡片样式
          cardElevation: 1,
          cardRadius: 12,
          // 按钮样式
          elevatedButtonRadius: 24,
          filledButtonRadius: 24,
          outlinedButtonRadius: 24,
          textButtonRadius: 24,
          // 输入框样式
          inputDecoratorRadius: 12,
          inputDecoratorBorderType: FlexInputBorderType.outline,
          // 导航样式
          navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
          navigationBarUnselectedLabelSchemeColor: SchemeColor.onSurfaceVariant,
          navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
          navigationBarIndicatorOpacity: 0.24,
          // 其他组件
          chipRadius: 8,
          dialogRadius: 16,
          timePickerDialogRadius: 16,
          snackBarRadius: 8,
          // 确保 Scaffold 背景使用主题颜色
          scaffoldBackgroundSchemeColor: SchemeColor.surface,
          // AppBar 样式
          appBarBackgroundSchemeColor: SchemeColor.surface,
          // 抽屉样式
          drawerBackgroundSchemeColor: SchemeColor.surface,
        ),
      );
    }
  }

  // 获取 FlexScheme
  FlexScheme _getFlexScheme() {
    switch (state.themeScheme) {
      case AppThemeScheme.pink:
        return FlexScheme.sakura; // 樱花粉色
      case AppThemeScheme.green:
        return FlexScheme.greenM3; // Material 3 绿色
      case AppThemeScheme.blue:
        return FlexScheme.blue; // 清新蓝色
      case AppThemeScheme.monochrome:
        return FlexScheme.greyLaw; // 灰色法则（黑白主题）
    }
  }

  // 获取主题预览颜色
  ColorScheme getPreviewColorScheme(
    AppThemeScheme scheme,
    Brightness brightness,
  ) {
    final flexScheme = _getFlexSchemeForPreview(scheme);
    if (brightness == Brightness.light) {
      return FlexColorScheme.light(scheme: flexScheme).toScheme;
    } else {
      return FlexColorScheme.dark(scheme: flexScheme).toScheme;
    }
  }

  FlexScheme _getFlexSchemeForPreview(AppThemeScheme scheme) {
    switch (scheme) {
      case AppThemeScheme.pink:
        return FlexScheme.sakura; // 樱花粉色
      case AppThemeScheme.green:
        return FlexScheme.greenM3; // Material 3 绿色
      case AppThemeScheme.blue:
        return FlexScheme.blue; // 清新蓝色
      case AppThemeScheme.monochrome:
        return FlexScheme.greyLaw; // 灰色法则（黑白主题）
    }
  }
}

// Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeSettings>((
  ref,
) {
  return ThemeNotifier();
});
