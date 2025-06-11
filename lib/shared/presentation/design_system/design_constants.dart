/// 🎨 设计系统常量
/// 
/// 统一管理应用的设计规范，包括圆角、间距、阴影等视觉元素。
/// 确保整个应用的视觉一致性和设计规范的统一性。

import 'package:flutter/material.dart';

/// 设计系统常量类
class DesignConstants {
  // 私有构造函数，防止实例化
  DesignConstants._();

  /// 🔄 圆角半径规范
  static const BorderRadius radiusXS = BorderRadius.all(Radius.circular(4));
  static const BorderRadius radiusS = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusM = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusL = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(20));
  static const BorderRadius radiusXXL = BorderRadius.all(Radius.circular(24));

  /// 🔄 圆角半径数值
  static const double radiusXSValue = 4;
  static const double radiusSValue = 8;
  static const double radiusMValue = 12;
  static const double radiusLValue = 16;
  static const double radiusXLValue = 20;
  static const double radiusXXLValue = 24;

  /// 📏 间距规范
  static const double spaceXS = 4;
  static const double spaceS = 8;
  static const double spaceM = 12;
  static const double spaceL = 16;
  static const double spaceXL = 20;
  static const double spaceXXL = 24;
  static const double spaceXXXL = 32;

  /// 🎯 边距规范
  static const EdgeInsets paddingXS = EdgeInsets.all(spaceXS);
  static const EdgeInsets paddingS = EdgeInsets.all(spaceS);
  static const EdgeInsets paddingM = EdgeInsets.all(spaceM);
  static const EdgeInsets paddingL = EdgeInsets.all(spaceL);
  static const EdgeInsets paddingXL = EdgeInsets.all(spaceXL);
  static const EdgeInsets paddingXXL = EdgeInsets.all(spaceXXL);

  /// 📱 响应式边距
  static EdgeInsets responsivePadding(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    return EdgeInsets.all(isDesktop ? spaceXXL : spaceL);
  }

  /// 📱 响应式水平边距
  static EdgeInsets responsiveHorizontalPadding(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    return EdgeInsets.symmetric(horizontal: isDesktop ? spaceXXL : spaceL);
  }

  /// 🌊 阴影层次规范
  static List<BoxShadow> shadowNone = [];
  
  static List<BoxShadow> shadowXS(ThemeData theme) => [
    BoxShadow(
      color: theme.colorScheme.shadow.withValues(alpha: 0.02),
      blurRadius: 1,
      offset: const Offset(0, 0.5),
    ),
  ];

  static List<BoxShadow> shadowS(ThemeData theme) => [
    BoxShadow(
      color: theme.colorScheme.shadow.withValues(alpha: 0.04),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> shadowM(ThemeData theme) => [
    BoxShadow(
      color: theme.colorScheme.shadow.withValues(alpha: 0.06),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowL(ThemeData theme) => [
    BoxShadow(
      color: theme.colorScheme.shadow.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowXL(ThemeData theme) => [
    BoxShadow(
      color: theme.colorScheme.shadow.withValues(alpha: 0.1),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  /// 🎨 特殊阴影效果
  static List<BoxShadow> shadowFocus(ThemeData theme) => [
    BoxShadow(
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      blurRadius: 6,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> shadowButton(ThemeData theme) => [
    BoxShadow(
      color: theme.colorScheme.primary.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowGlow(ThemeData theme, Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.2),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// 📐 尺寸规范
  static const double iconSizeS = 16;
  static const double iconSizeM = 20;
  static const double iconSizeL = 24;
  static const double iconSizeXL = 32;
  static const double iconSizeXXL = 40;

  /// 🔘 按钮尺寸
  static const double buttonHeightS = 32;
  static const double buttonHeightM = 40;
  static const double buttonHeightL = 48;
  static const double buttonHeightXL = 56;

  /// 📝 输入框规范
  static const double inputFieldHeight = 48;
  static const double inputFieldBorderWidth = 1;
  static const double inputFieldFocusBorderWidth = 2;

  /// 🎭 透明度规范
  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.6;
  static const double opacityHigh = 0.8;
  static const double opacityFull = 1.0;

  /// 🎬 动画时长规范
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 400);
  static const Duration animationVerySlow = Duration(milliseconds: 600);

  /// 📱 断点规范
  static const double breakpointMobile = 480;
  static const double breakpointTablet = 768;
  static const double breakpointDesktop = 1024;
  static const double breakpointLargeDesktop = 1440;

  /// 🎯 辅助方法
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < breakpointTablet;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointTablet && width < breakpointDesktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= breakpointTablet;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= breakpointLargeDesktop;

  /// 🎨 边框规范
  static BorderSide borderThin(ThemeData theme) => BorderSide(
    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
    width: 1,
  );

  static BorderSide borderMedium(ThemeData theme) => BorderSide(
    color: theme.colorScheme.outline.withValues(alpha: 0.4),
    width: 1.5,
  );

  static BorderSide borderThick(ThemeData theme) => BorderSide(
    color: theme.colorScheme.outline,
    width: 2,
  );

  static BorderSide borderFocus(ThemeData theme) => BorderSide(
    color: theme.colorScheme.primary.withValues(alpha: 0.4),
    width: 1,
  );
}

/// 🎨 设计系统扩展方法
extension DesignSystemExtensions on ThemeData {
  /// 获取统一的卡片装饰
  BoxDecoration get cardDecoration => BoxDecoration(
    color: colorScheme.surface,
    borderRadius: DesignConstants.radiusM,
    border: Border.all(
      color: colorScheme.outlineVariant.withValues(alpha: 0.2),
      width: 1,
    ),
    boxShadow: DesignConstants.shadowS(this),
  );

  /// 获取统一的输入框装饰
  BoxDecoration get inputDecoration => BoxDecoration(
    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
    borderRadius: DesignConstants.radiusXXL,
    border: Border.all(
      color: colorScheme.outline.withValues(alpha: 0.2),
      width: 1,
    ),
  );

  /// 获取聚焦状态的输入框装饰
  BoxDecoration get inputFocusDecoration => BoxDecoration(
    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
    borderRadius: DesignConstants.radiusXXL,
    border: Border.all(
      color: colorScheme.primary.withValues(alpha: 0.4),
      width: 1,
    ),
    boxShadow: DesignConstants.shadowFocus(this),
  );
}
