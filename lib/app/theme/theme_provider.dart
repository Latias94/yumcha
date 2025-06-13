import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'theme_color_schemes.dart';
import '../../shared/presentation/design_system/design_constants.dart';
import '../../features/settings/presentation/providers/settings_notifier.dart';
import '../../features/settings/domain/entities/app_setting.dart';
import '../../shared/infrastructure/services/logger_service.dart';

// 主题模式枚举
enum AppColorMode { system, light, dark }

// 主题方案枚举
enum AppThemeScheme {
  ocean, // 海洋蓝 - 深邃宁静
  monochrome, // 极简灰 - 经典永恒
  forest, // 森林绿 - 专注护眼
  warmOrange, // 暖橙 - 温暖友好
  custom, // 自定义 - 个性化配色
}

// 对比度类型枚举
enum AppContrastLevel {
  standard, // 标准对比度
  medium, // 中等对比度
  high, // 高对比度
}

// 主题设置状态类
class ThemeSettings {
  final AppColorMode colorMode;
  final bool dynamicColorEnabled;
  final bool isDynamicColorAvailable;
  final AppThemeScheme themeScheme;
  final AppContrastLevel contrastLevel;

  const ThemeSettings({
    required this.colorMode,
    required this.dynamicColorEnabled,
    required this.isDynamicColorAvailable,
    required this.themeScheme,
    required this.contrastLevel,
  });

  ThemeSettings copyWith({
    AppColorMode? colorMode,
    bool? dynamicColorEnabled,
    bool? isDynamicColorAvailable,
    AppThemeScheme? themeScheme,
    AppContrastLevel? contrastLevel,
  }) {
    return ThemeSettings(
      colorMode: colorMode ?? this.colorMode,
      dynamicColorEnabled: dynamicColorEnabled ?? this.dynamicColorEnabled,
      isDynamicColorAvailable:
          isDynamicColorAvailable ?? this.isDynamicColorAvailable,
      themeScheme: themeScheme ?? this.themeScheme,
      contrastLevel: contrastLevel ?? this.contrastLevel,
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
      case AppThemeScheme.ocean:
        return '海洋蓝';
      case AppThemeScheme.monochrome:
        return '极简灰';
      case AppThemeScheme.forest:
        return '森林绿';
      case AppThemeScheme.warmOrange:
        return '暖橙';
      case AppThemeScheme.custom:
        return '自定义';
    }
  }

  // 获取对比度显示名称
  String get contrastLevelDisplayName {
    switch (contrastLevel) {
      case AppContrastLevel.standard:
        return '标准';
      case AppContrastLevel.medium:
        return '中对比';
      case AppContrastLevel.high:
        return '高对比';
    }
  }

  // 获取对比度描述
  String get contrastLevelDescription {
    switch (contrastLevel) {
      case AppContrastLevel.standard:
        return '平衡的颜色和对比度';
      case AppContrastLevel.medium:
        return '增强的对比度，更易阅读';
      case AppContrastLevel.high:
        return '最高对比度，最佳可访问性';
    }
  }

  // 是否应该显示主题选择器
  bool get shouldShowThemeSelector {
    return !isDynamicColorAvailable || !dynamicColorEnabled;
  }
}

// 主题状态管理器
class ThemeNotifier extends StateNotifier<ThemeSettings> {
  ColorScheme? _lightDynamicColorScheme;
  ColorScheme? _darkDynamicColorScheme;
  final LoggerService _logger = LoggerService();

  ThemeNotifier(this._ref)
      : super(
          const ThemeSettings(
            colorMode: AppColorMode.system,
            dynamicColorEnabled: true,
            isDynamicColorAvailable: false,
            themeScheme: AppThemeScheme.ocean,
            contrastLevel: AppContrastLevel.standard,
          ),
        ) {
    _initialize();
  }

  final Ref _ref;

  /// 获取设置管理器
  SettingsNotifier get _settingsNotifier =>
      _ref.read(settingsNotifierProvider.notifier);

  Future<void> _initialize() async {
    try {
      // 等待设置系统初始化完成
      await _waitForSettingsInitialization();
      await _loadSettings();
      await _loadDynamicColors();
    } catch (e) {
      _logger.error('主题初始化失败', {'error': e.toString()});
    }
  }

  /// 等待设置系统初始化完成
  Future<void> _waitForSettingsInitialization() async {
    // 等待设置系统加载完成
    final settingsState = _ref.read(settingsNotifierProvider);
    if (settingsState.isLoading) {
      // 如果还在加载中，等待一段时间后重试
      await Future.delayed(const Duration(milliseconds: 100));
      return _waitForSettingsInitialization();
    }
  }

  Future<void> _loadSettings() async {
    try {
      // 从数据库设置中读取主题配置
      final colorModeIndex =
          _settingsNotifier.getValueOrDefault<int>(SettingKeys.colorMode, 0);
      final colorMode = AppColorMode.values[colorModeIndex];

      final dynamicColorEnabled = _settingsNotifier.getValueOrDefault<bool>(
          SettingKeys.dynamicColorEnabled, true);

      final themeSchemeIndex =
          _settingsNotifier.getValueOrDefault<int>(SettingKeys.themeScheme, 0);
      final themeScheme = AppThemeScheme.values[themeSchemeIndex];

      final contrastLevelIndex = _settingsNotifier.getValueOrDefault<int>(
          SettingKeys.contrastLevel, 0);
      final contrastLevel = AppContrastLevel.values[contrastLevelIndex];

      state = state.copyWith(
        colorMode: colorMode,
        dynamicColorEnabled: dynamicColorEnabled,
        themeScheme: themeScheme,
        contrastLevel: contrastLevel,
      );

      _logger.debug('主题设置加载完成', {
        'colorMode': colorMode.name,
        'dynamicColorEnabled': dynamicColorEnabled,
        'themeScheme': themeScheme.name,
        'contrastLevel': contrastLevel.name,
      });
    } catch (e) {
      _logger.error('主题设置加载失败', {'error': e.toString()});
      // 使用默认设置
    }
  }

  Future<void> _loadDynamicColors() async {
    try {
      final corePalette = await DynamicColorPlugin.getCorePalette();
      final isAvailable = corePalette != null;

      // 如果动态颜色不可用，自动关闭动态颜色设置
      bool dynamicEnabled = state.dynamicColorEnabled;
      if (!isAvailable && dynamicEnabled) {
        dynamicEnabled = false;
        await _settingsNotifier.setDynamicColorEnabled(false);
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

      _logger.debug('动态颜色加载完成', {
        'isAvailable': isAvailable,
        'dynamicEnabled': dynamicEnabled,
      });
    } catch (e) {
      // 如果获取动态颜色失败，标记为不可用并关闭动态颜色
      bool dynamicEnabled = false;
      if (state.dynamicColorEnabled) {
        await _settingsNotifier.setDynamicColorEnabled(false);
      }

      _lightDynamicColorScheme = null;
      _darkDynamicColorScheme = null;

      state = state.copyWith(
        isDynamicColorAvailable: false,
        dynamicColorEnabled: dynamicEnabled,
      );

      _logger.error('动态颜色加载失败', {'error': e.toString()});
    }
  }

  // 设置颜色模式
  Future<void> setColorMode(AppColorMode mode) async {
    if (state.colorMode != mode) {
      await _settingsNotifier.setColorMode(mode.index);
      state = state.copyWith(colorMode: mode);
      _logger.debug('颜色模式已更新', {'mode': mode.name});
    }
  }

  // 设置动态颜色
  Future<bool> setDynamicColor(bool enabled) async {
    if (enabled && !state.isDynamicColorAvailable) {
      return false;
    }

    if (state.dynamicColorEnabled != enabled) {
      await _settingsNotifier.setDynamicColorEnabled(enabled);

      if (enabled) {
        await _loadDynamicColors();
      } else {
        _lightDynamicColorScheme = null;
        _darkDynamicColorScheme = null;
        state = state.copyWith(dynamicColorEnabled: enabled);
      }
      _logger.debug('动态颜色设置已更新', {'enabled': enabled});
    }
    return true;
  }

  // 设置主题方案
  Future<void> setThemeScheme(AppThemeScheme scheme) async {
    if (state.themeScheme != scheme) {
      await _settingsNotifier.setThemeScheme(scheme.index);
      state = state.copyWith(themeScheme: scheme);
      _logger.debug('主题方案已更新', {'scheme': scheme.name});
    }
  }

  // 设置对比度级别
  Future<void> setContrastLevel(AppContrastLevel level) async {
    if (state.contrastLevel != level) {
      await _settingsNotifier.setContrastLevel(level.index);
      state = state.copyWith(contrastLevel: level);
      _logger.debug('对比度级别已更新', {'level': level.name});
    }
  }

  // 设置是否使用自定义颜色
  Future<void> setUseCustomColors(bool enabled) async {
    await _settingsNotifier.setUseCustomColors(enabled);
    _logger.debug('自定义颜色设置已更新', {'enabled': enabled});
  }

  // 设置自定义主色调
  Future<void> setCustomPrimaryColor(Color color) async {
    final colorValue = color.toARGB32();
    await _settingsNotifier.setCustomPrimaryColor(colorValue);
    _logger.debug('自定义主色调已更新', {'color': colorValue.toRadixString(16)});
  }

  // 获取是否使用自定义颜色
  bool getUseCustomColors() {
    return _settingsNotifier.getValueOrDefault<bool>(
        SettingKeys.useCustomColors, false);
  }

  // 获取自定义主色调
  Color? getCustomPrimaryColor() {
    final colorValue =
        _settingsNotifier.getValue<int>(SettingKeys.customPrimaryColor);
    return colorValue != null ? Color(colorValue) : null;
  }

  // 获取浅色主题
  ThemeData getLightTheme() {
    if (state.dynamicColorEnabled && _lightDynamicColorScheme != null) {
      return FlexThemeData.light(
        colorScheme: _lightDynamicColorScheme,
        useMaterial3: true,
      );
    }

    // 检查是否是自定义主题
    if (state.themeScheme == AppThemeScheme.custom) {
      final customColorScheme = _getCustomColorScheme(Brightness.light);
      if (customColorScheme != null) {
        return _getCustomTheme(customColorScheme, Brightness.light);
      }
    }

    // 检查是否有预定义的自定义颜色方案
    final customColorScheme = ThemeColorSchemes.getColorSchemeForTheme(
      state.themeScheme.name,
      Brightness.light,
      state.contrastLevel.name,
    );

    if (customColorScheme != null) {
      return _getCustomTheme(customColorScheme, Brightness.light);
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

    // 检查是否是自定义主题
    if (state.themeScheme == AppThemeScheme.custom) {
      final customColorScheme = _getCustomColorScheme(Brightness.dark);
      if (customColorScheme != null) {
        return _getCustomTheme(customColorScheme, Brightness.dark);
      }
    }

    // 检查是否有预定义的自定义颜色方案
    final customColorScheme = ThemeColorSchemes.getColorSchemeForTheme(
      state.themeScheme.name,
      Brightness.dark,
      state.contrastLevel.name,
    );

    if (customColorScheme != null) {
      return _getCustomTheme(customColorScheme, Brightness.dark);
    }

    return _getFlexTheme(Brightness.dark);
  }

  // 获取 FlexColorScheme 主题
  ThemeData _getFlexTheme(Brightness brightness) {
    final scheme = _getFlexScheme();
    final contrastLevel = state.contrastLevel;

    if (brightness == Brightness.light) {
      return FlexThemeData.light(
        scheme: scheme,
        useMaterial3: true,
        appBarStyle: FlexAppBarStyle.surface,
        lightIsWhite: false, // 允许使用主题背景色
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold, // 使用分层表面
        blendLevel: _getBlendLevel(contrastLevel, brightness), // 根据对比度调整混合
        subThemesData: FlexSubThemesData(
          // 根据对比度调整混合程度
          blendOnLevel: _getBlendOnLevel(contrastLevel, brightness),
          blendOnColors: false,
          useMaterial3Typography: true,
          useM2StyleDividerInM3: true,
          // 卡片样式
          cardElevation: 1,
          cardRadius: DesignConstants.radiusM.topLeft.x,
          // 按钮样式
          elevatedButtonRadius: DesignConstants.radiusXXL.topLeft.x,
          filledButtonRadius: DesignConstants.radiusXXL.topLeft.x,
          outlinedButtonRadius: DesignConstants.radiusXXL.topLeft.x,
          textButtonRadius: DesignConstants.radiusXXL.topLeft.x,
          // 输入框样式
          inputDecoratorRadius: DesignConstants.radiusM.topLeft.x,
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
        darkIsTrueBlack: contrastLevel == AppContrastLevel.high, // 高对比度使用纯黑背景
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold, // 使用分层表面
        blendLevel: _getBlendLevel(contrastLevel, brightness), // 根据对比度调整混合
        subThemesData: FlexSubThemesData(
          // 根据对比度调整混合程度
          blendOnLevel: _getBlendOnLevel(contrastLevel, brightness),
          blendOnColors: false,
          useMaterial3Typography: true,
          useM2StyleDividerInM3: true,
          // 卡片样式
          cardElevation: 1,
          cardRadius: DesignConstants.radiusM.topLeft.x,
          // 按钮样式
          elevatedButtonRadius: DesignConstants.radiusXXL.topLeft.x,
          filledButtonRadius: DesignConstants.radiusXXL.topLeft.x,
          outlinedButtonRadius: DesignConstants.radiusXXL.topLeft.x,
          textButtonRadius: DesignConstants.radiusXXL.topLeft.x,
          // 输入框样式
          inputDecoratorRadius: DesignConstants.radiusM.topLeft.x,
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
      case AppThemeScheme.ocean:
        return FlexScheme.deepBlue; // 深蓝色（临时映射）
      case AppThemeScheme.monochrome:
        return FlexScheme.greyLaw; // 灰色法则（黑白主题）
      case AppThemeScheme.forest:
        return FlexScheme.greenM3; // Material 3 绿色
      case AppThemeScheme.warmOrange:
        return FlexScheme.orangeM3; // 橙色
      case AppThemeScheme.custom:
        return FlexScheme.material; // 自定义主题使用默认 Material 方案
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
      case AppThemeScheme.ocean:
        return FlexScheme.deepBlue; // 深蓝色（临时映射）
      case AppThemeScheme.monochrome:
        return FlexScheme.greyLaw; // 灰色法则（黑白主题）
      case AppThemeScheme.forest:
        return FlexScheme.greenM3; // Material 3 绿色
      case AppThemeScheme.warmOrange:
        return FlexScheme.orangeM3; // 橙色
      case AppThemeScheme.custom:
        return FlexScheme.material; // 自定义主题使用默认 Material 方案
    }
  }

  // 根据对比度级别获取混合级别
  int _getBlendLevel(AppContrastLevel contrastLevel, Brightness brightness) {
    switch (contrastLevel) {
      case AppContrastLevel.standard:
        return brightness == Brightness.light ? 8 : 12;
      case AppContrastLevel.medium:
        return brightness == Brightness.light ? 4 : 8;
      case AppContrastLevel.high:
        return 0; // 高对比度不使用混合
    }
  }

  // 根据对比度级别获取表面混合级别
  int _getBlendOnLevel(AppContrastLevel contrastLevel, Brightness brightness) {
    switch (contrastLevel) {
      case AppContrastLevel.standard:
        return brightness == Brightness.light ? 15 : 20;
      case AppContrastLevel.medium:
        return brightness == Brightness.light ? 8 : 12;
      case AppContrastLevel.high:
        return 0; // 高对比度不使用表面混合
    }
  }

  // 获取自定义主题
  ThemeData _getCustomTheme(ColorScheme colorScheme, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      // 应用自定义样式
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: DesignConstants.radiusM,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: DesignConstants.radiusXXL,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: DesignConstants.radiusXXL,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: DesignConstants.radiusXXL,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: DesignConstants.radiusXXL,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: DesignConstants.radiusM,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: DesignConstants.radiusS,
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: DesignConstants.radiusL,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: DesignConstants.radiusS,
        ),
      ),
    );
  }

  // 获取自定义颜色方案
  ColorScheme? _getCustomColorScheme(Brightness brightness) {
    try {
      // 检查是否启用了自定义颜色
      final useCustomColors = _settingsNotifier.getValueOrDefault<bool>(
          SettingKeys.useCustomColors, false);
      if (!useCustomColors) {
        return null;
      }

      // 获取自定义主色调
      final customPrimaryColorValue =
          _settingsNotifier.getValue<int>(SettingKeys.customPrimaryColor);
      if (customPrimaryColorValue == null) {
        return null;
      }

      final customPrimaryColor = Color(customPrimaryColorValue);

      // 使用 Material 3 的 ColorScheme.fromSeed 方法生成完整的颜色方案
      return ColorScheme.fromSeed(
        seedColor: customPrimaryColor,
        brightness: brightness,
      );
    } catch (e) {
      _logger.error('获取自定义颜色方案失败', {'error': e.toString()});
      return null;
    }
  }
}

// Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeSettings>((
  ref,
) {
  return ThemeNotifier(ref);
});
