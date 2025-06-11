import 'package:flutter/material.dart';

/// 🎨 启动页面配置
///
/// 简单的启动页面切换配置，只需修改一行代码即可切换。

/// 启动页面类型
enum SplashScreenType {
  /// 标准版 - 简洁美观，性能优秀
  standard,

  /// 增强版 - 丰富动画，粒子效果
  enhanced,
}

/// 启动页面配置
class SplashConfig {
  /// 🔧 修改这里来切换启动页面类型
  ///
  /// - `SplashScreenType.standard` - 标准版（推荐）
  /// - `SplashScreenType.enhanced` - 增强版
  static const SplashScreenType currentType = SplashScreenType.standard;

  /// ⏱️ 启动页面最小显示时间
  ///
  /// 确保用户能够看到启动页面，即使初始化很快完成。
  /// 建议值：
  /// - `Duration.zero` - 不设置最小时间
  /// - `Duration(seconds: 1)` - 最少显示1秒
  /// - `Duration(milliseconds: 1500)` - 最少显示1.5秒（推荐）
  /// - `Duration(seconds: 2)` - 最少显示2秒
  static const Duration minDisplayDuration = Duration(milliseconds: 1500);

  /// 🎯 是否启用最小显示时间
  ///
  /// - `true` - 启用最小显示时间控制（推荐）
  /// - `false` - 禁用，初始化完成后立即跳转
  static const bool enableMinDisplayTime = true;
}

/// 启动页面工厂类
///
/// 根据配置创建相应的启动页面组件
///
/// 注意：这个类需要在使用时导入相应的启动页面组件
class SplashScreenFactory {
  /// 根据配置创建启动页面
  ///
  /// 自动根据 `SplashConfig.currentSplashType` 创建对应的启动页面组件
  ///
  /// 使用方式：
  /// ```dart
  /// // 在需要使用的地方
  /// import '../widgets/app_splash_screen.dart';
  /// import '../../shared/presentation/widgets/enhanced_splash_screen.dart';
  ///
  /// Widget splash = SplashScreenFactory.createSplashScreen(
  ///   initState: initState,
  ///   standardBuilder: (state) => AppSplashScreen(initState: state),
  ///   enhancedBuilder: (state) => EnhancedSplashScreen(initState: state),
  /// );
  /// ```
  static Widget createSplashScreen({
    required dynamic initState,
    required Widget Function(dynamic) standardBuilder,
    required Widget Function(dynamic) enhancedBuilder,
  }) {
    switch (SplashConfig.currentType) {
      case SplashScreenType.standard:
        return standardBuilder(initState);
      case SplashScreenType.enhanced:
        return enhancedBuilder(initState);
    }
  }
}
