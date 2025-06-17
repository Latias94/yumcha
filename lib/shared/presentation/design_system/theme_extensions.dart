import 'package:flutter/material.dart';
import 'design_constants.dart';

/// 🎨 主题扩展方法
///
/// 提供便捷的主题相关装饰和样式方法，统一管理主题相关的UI样式
extension ThemeExtensions on ThemeData {
  /// 获取统一的卡片装饰
  BoxDecoration get cardDecoration => BoxDecoration(
        color: colorScheme.surface,
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: DesignConstants.borderWidthThin,
        ),
        boxShadow: DesignConstants.shadowS(this),
      );

  /// 获取统一的输入框装饰
  BoxDecoration get inputDecoration => BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: DesignConstants.radiusXXL,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: DesignConstants.borderWidthThin,
        ),
      );

  /// 获取焦点状态的输入框装饰
  BoxDecoration get inputFocusDecoration => BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: DesignConstants.radiusXXL,
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.4),
          width: DesignConstants.borderWidthMedium,
        ),
        boxShadow: DesignConstants.shadowFocus(this),
      );

  /// 获取按钮装饰
  BoxDecoration get buttonDecoration => BoxDecoration(
        borderRadius: DesignConstants.radiusXXL,
        boxShadow: DesignConstants.shadowButton(this),
      );

  /// 获取对话框装饰
  BoxDecoration get dialogDecoration => BoxDecoration(
        color: colorScheme.surface,
        borderRadius: DesignConstants.radiusL,
        boxShadow: DesignConstants.shadowL(this),
      );

  /// 获取底部面板装饰
  BoxDecoration get bottomSheetDecoration => BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: DesignConstants.radiusL.topLeft,
          topRight: DesignConstants.radiusL.topRight,
        ),
        boxShadow: DesignConstants.shadowM(this),
      );

  /// 获取搜索框装饰
  BoxDecoration get searchDecoration => BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: DesignConstants.radiusXXL,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: DesignConstants.borderWidthThin,
        ),
      );

  /// 获取选中状态的装饰
  BoxDecoration get selectedDecoration => BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.5),
          width: DesignConstants.borderWidthMedium,
        ),
      );

  /// 获取错误状态的装饰
  BoxDecoration get errorDecoration => BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.5),
          width: DesignConstants.borderWidthMedium,
        ),
      );

  /// 获取成功状态的装饰
  BoxDecoration get successDecoration => BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.5),
          width: DesignConstants.borderWidthThin,
        ),
      );

  /// 获取警告状态的装饰
  BoxDecoration get warningDecoration => BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: colorScheme.tertiary.withValues(alpha: 0.5),
          width: DesignConstants.borderWidthThin,
        ),
      );
}

/// 🎨 颜色扩展方法
///
/// 提供便捷的颜色相关方法
extension ColorExtensions on ColorScheme {
  /// 获取禁用状态的颜色
  Color get disabled =>
      onSurface.withValues(alpha: DesignConstants.opacityDisabled);

  /// 获取中等透明度的颜色
  Color get medium =>
      onSurface.withValues(alpha: DesignConstants.opacityMedium);

  /// 获取高透明度的颜色
  Color get high => onSurface.withValues(alpha: DesignConstants.opacityHigh);

  /// 获取成功颜色（使用primary作为成功色）
  Color get success => primary;

  /// 获取成功容器颜色
  Color get successContainer => primaryContainer;

  /// 获取成功文本颜色
  Color get onSuccess => onPrimary;

  /// 获取成功容器文本颜色
  Color get onSuccessContainer => onPrimaryContainer;

  /// 获取警告颜色（使用tertiary作为警告色）
  Color get warning => tertiary;

  /// 获取警告容器颜色
  Color get warningContainer => tertiaryContainer;

  /// 获取警告文本颜色
  Color get onWarning => onTertiary;

  /// 获取警告容器文本颜色
  Color get onWarningContainer => onTertiaryContainer;
}

/// 🎨 文本样式扩展方法
///
/// 提供便捷的文本样式方法
extension TextStyleExtensions on TextTheme {
  /// 获取标题样式（响应式）
  TextStyle? responsiveTitle(BuildContext context) {
    if (DesignConstants.isDesktop(context)) {
      return headlineMedium;
    } else if (DesignConstants.isTablet(context)) {
      return headlineSmall;
    } else {
      return titleLarge;
    }
  }

  /// 获取副标题样式（响应式）
  TextStyle? responsiveSubtitle(BuildContext context) {
    if (DesignConstants.isDesktop(context)) {
      return titleMedium;
    } else if (DesignConstants.isTablet(context)) {
      return titleSmall;
    } else {
      return bodyLarge;
    }
  }

  /// 获取正文样式（响应式）
  TextStyle? responsiveBody(BuildContext context) {
    if (DesignConstants.isDesktop(context)) {
      return bodyLarge;
    } else if (DesignConstants.isTablet(context)) {
      return bodyMedium;
    } else {
      return bodyMedium;
    }
  }

  /// 获取说明文字样式（响应式）
  TextStyle? responsiveCaption(BuildContext context) {
    if (DesignConstants.isDesktop(context)) {
      return bodyMedium;
    } else if (DesignConstants.isTablet(context)) {
      return bodySmall;
    } else {
      return bodySmall;
    }
  }
}

/// 🎨 边距扩展方法
///
/// 提供便捷的边距计算方法
extension PaddingExtensions on BuildContext {
  /// 获取响应式水平边距
  EdgeInsets get responsiveHorizontalPadding {
    if (DesignConstants.isDesktop(this)) {
      return EdgeInsets.symmetric(horizontal: DesignConstants.spaceXXL);
    } else if (DesignConstants.isTablet(this)) {
      return EdgeInsets.symmetric(horizontal: DesignConstants.spaceXL);
    } else {
      return EdgeInsets.symmetric(horizontal: DesignConstants.spaceL);
    }
  }

  /// 获取响应式垂直边距
  EdgeInsets get responsiveVerticalPadding {
    if (DesignConstants.isDesktop(this)) {
      return EdgeInsets.symmetric(vertical: DesignConstants.spaceXL);
    } else if (DesignConstants.isTablet(this)) {
      return EdgeInsets.symmetric(vertical: DesignConstants.spaceL);
    } else {
      return EdgeInsets.symmetric(vertical: DesignConstants.spaceM);
    }
  }

  /// 获取响应式全方向边距
  EdgeInsets get responsivePadding {
    if (DesignConstants.isDesktop(this)) {
      return DesignConstants.paddingXXL;
    } else if (DesignConstants.isTablet(this)) {
      return DesignConstants.paddingXL;
    } else {
      return DesignConstants.paddingL;
    }
  }
}
