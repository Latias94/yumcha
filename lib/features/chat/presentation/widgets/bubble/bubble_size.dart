import 'package:flutter/material.dart';

import 'bubble_style.dart';
import '../../../../../shared/presentation/design_system/design_constants.dart';

/// 气泡尺寸计算工具类
/// 
/// 提供智能的气泡尺寸计算，支持响应式设计
class BubbleSize {
  BubbleSize._();

  /// 计算气泡最大宽度
  static double calculateMaxWidth(BuildContext context, BubbleStyle style) {
    final screenWidth = MediaQuery.of(context).size.width;

    switch (style.type) {
      case BubbleType.bubble:
        if (DesignConstants.isDesktop(context)) {
          return screenWidth * 0.6;
        } else if (DesignConstants.isTablet(context)) {
          return screenWidth * 0.75;
        } else {
          return screenWidth * 0.85;
        }

      case BubbleType.card:
        if (DesignConstants.isDesktop(context)) {
          return screenWidth * 0.8;
        } else if (DesignConstants.isTablet(context)) {
          return screenWidth * 0.9;
        } else {
          return screenWidth * 0.95;
        }

      case BubbleType.list:
        return double.infinity;
    }
  }

  /// 计算气泡最小宽度
  static double calculateMinWidth(BuildContext context, BubbleStyle style) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    switch (style.type) {
      case BubbleType.bubble:
        return isDesktop ? 120.0 : 80.0;
      case BubbleType.card:
        return isDesktop ? 160.0 : 120.0;
      case BubbleType.list:
        return 0.0;
    }
  }

  /// 计算响应式内边距
  static EdgeInsets calculatePadding(BuildContext context, BubbleStyle style) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;
    final isTablet = screenWidth > 480 && screenWidth <= 768;

    final basePadding = style.layout.padding;
    
    if (isDesktop) {
      return EdgeInsets.all(basePadding.left * 1.2);
    } else if (isTablet) {
      return basePadding;
    } else {
      return EdgeInsets.all(basePadding.left * 0.8);
    }
  }

  /// 计算响应式外边距
  static EdgeInsets calculateMargin(BuildContext context, BubbleStyle style) {
    final baseMargin = style.layout.margin;

    if (DesignConstants.isDesktop(context)) {
      return EdgeInsets.symmetric(
        horizontal: baseMargin.horizontal * 1.5,
        vertical: baseMargin.vertical * 1.2,
      );
    } else if (DesignConstants.isTablet(context)) {
      return baseMargin;
    } else {
      return EdgeInsets.symmetric(
        horizontal: baseMargin.horizontal * 0.7,
        vertical: baseMargin.vertical * 0.8,
      );
    }
  }

  /// 计算响应式圆角
  static double calculateBorderRadius(BuildContext context, BubbleStyle style) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;
    final isTablet = screenWidth > 480 && screenWidth <= 768;

    final baseBorderRadius = style.layout.borderRadius;
    
    if (isDesktop) {
      return baseBorderRadius * 1.25;
    } else if (isTablet) {
      return baseBorderRadius;
    } else {
      return baseBorderRadius * 0.9;
    }
  }

  /// 计算内容区域约束
  static BoxConstraints calculateContentConstraints(
    BuildContext context,
    BubbleStyle style,
  ) {
    final maxWidth = calculateMaxWidth(context, style);
    final minWidth = calculateMinWidth(context, style);
    final padding = calculatePadding(context, style);

    return BoxConstraints(
      minWidth: (minWidth - padding.horizontal).clamp(0, double.infinity),
      maxWidth: (maxWidth - padding.horizontal).clamp(0, double.infinity),
      minHeight: 0,
      maxHeight: double.infinity,
    );
  }

  /// 计算气泡容器约束
  static BoxConstraints calculateBubbleConstraints(
    BuildContext context,
    BubbleStyle style,
  ) {
    final maxWidth = calculateMaxWidth(context, style);
    final minWidth = calculateMinWidth(context, style);

    return BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: 0,
      maxHeight: double.infinity,
    );
  }

  // 删除重复的方法，使用 DesignConstants 中的统一方法

  /// 计算气泡阴影
  static List<BoxShadow> calculateShadows(
    BuildContext context,
    BubbleStyle style, {
    bool isHovered = false,
    bool isSelected = false,
  }) {
    final baseShadows = style.theme.shadows;
    
    if (baseShadows.isEmpty) {
      return [];
    }

    double multiplier = 1.0;

    // 根据设备类型调整阴影
    if (DesignConstants.isDesktop(context)) {
      multiplier = 1.2;
    } else if (DesignConstants.isTablet(context)) {
      multiplier = 1.0;
    } else {
      multiplier = 0.8;
    }

    // 根据状态调整阴影
    if (isSelected) {
      multiplier *= 1.5;
    } else if (isHovered) {
      multiplier *= 1.3;
    }

    return baseShadows.map((shadow) {
      return BoxShadow(
        color: shadow.color,
        blurRadius: shadow.blurRadius * multiplier,
        spreadRadius: shadow.spreadRadius * multiplier,
        offset: shadow.offset * multiplier,
      );
    }).toList();
  }
}

// 删除重复的DeviceType枚举，使用DesignConstants中的统一定义

/// 气泡尺寸扩展方法
extension BubbleSizeExtensions on BuildContext {
  /// 获取气泡最大宽度
  double getBubbleMaxWidth(BubbleStyle style) {
    return BubbleSize.calculateMaxWidth(this, style);
  }

  /// 获取气泡最小宽度
  double getBubbleMinWidth(BubbleStyle style) {
    return BubbleSize.calculateMinWidth(this, style);
  }

  /// 获取响应式内边距
  EdgeInsets getResponsivePadding(BubbleStyle style) {
    return BubbleSize.calculatePadding(this, style);
  }

  /// 获取响应式外边距
  EdgeInsets getResponsiveMargin(BubbleStyle style) {
    return BubbleSize.calculateMargin(this, style);
  }

  /// 获取响应式圆角
  double getResponsiveBorderRadius(BubbleStyle style) {
    return BubbleSize.calculateBorderRadius(this, style);
  }

  /// 获取设备类型
  DeviceType get deviceType => DesignConstants.getDeviceType(this);

  /// 是否为桌面端
  bool get isDesktop => DesignConstants.isDesktop(this);

  /// 是否为平板
  bool get isTablet => DesignConstants.isTablet(this);

  /// 是否为移动端
  bool get isMobile => DesignConstants.isMobile(this);
}
