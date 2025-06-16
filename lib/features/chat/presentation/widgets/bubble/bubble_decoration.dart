import 'package:flutter/material.dart';

import 'bubble_context.dart';

/// 气泡装饰工具类
/// 
/// 提供气泡的装饰效果，包括背景、边框、阴影等
class BubbleDecoration {
  BubbleDecoration._();

  /// 创建气泡装饰
  static BoxDecoration create(BubbleContext context) {
    return BoxDecoration(
      color: _getBubbleColor(context),
      borderRadius: _getBorderRadius(context),
      border: _getBorder(context),
      boxShadow: _getShadows(context),
      gradient: _getGradient(context),
    );
  }

  /// 获取气泡颜色
  static Color _getBubbleColor(BubbleContext context) {
    final baseColor = context.style.theme.getBubbleColor(context.isFromUser);
    return context.getStateAdjustedColor(baseColor);
  }

  /// 获取边框圆角
  static BorderRadius _getBorderRadius(BubbleContext context) {
    if (context.style.isList) {
      return BorderRadius.zero;
    }

    // 使用智能圆角计算
    return context.style.layout.getSmartBorderRadius(
      isFromUser: context.isFromUser,
      isFirstInGroup: context.isFirstInGroup,
      isLastInGroup: context.isLastInGroup,
    );
  }

  /// 获取边框
  static Border? _getBorder(BubbleContext context) {
    if (!context.shouldShowBorder) {
      return null;
    }

    return Border.all(
      color: context.borderColor,
      width: context.style.theme.borderWidth,
    );
  }

  /// 获取阴影
  static List<BoxShadow>? _getShadows(BubbleContext context) {
    if (!context.shouldShowShadow) {
      return null;
    }

    return context.getStateAdjustedShadows();
  }

  /// 获取渐变（可选）
  static Gradient? _getGradient(BubbleContext context) {
    // 目前不使用渐变，但为未来扩展保留接口
    return null;
  }

  /// 创建悬停状态装饰
  static BoxDecoration createHovered(BubbleContext context) {
    return create(context.copyWith(isHovered: true));
  }

  /// 创建选中状态装饰
  static BoxDecoration createSelected(BubbleContext context) {
    return create(context.copyWith(isSelected: true));
  }

  /// 创建错误状态装饰
  static BoxDecoration createError(BubbleContext context) {
    final errorColor = context.theme.colorScheme.error;
    
    return BoxDecoration(
      color: errorColor.withValues(alpha: 0.1),
      borderRadius: _getBorderRadius(context),
      border: Border.all(
        color: errorColor.withValues(alpha: 0.3),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: errorColor.withValues(alpha: 0.2),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// 创建流式状态装饰
  static BoxDecoration createStreaming(BubbleContext context) {
    final primaryColor = context.theme.colorScheme.primary;
    
    return create(context).copyWith(
      border: Border.all(
        color: primaryColor.withValues(alpha: 0.3),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

/// 气泡圆角计算工具
class BubbleCorners {
  BubbleCorners._();

  /// 计算智能圆角
  static BorderRadius calculate({
    required bool isFromUser,
    required bool isFirstInGroup,
    required bool isLastInGroup,
    required double borderRadius,
  }) {
    if (borderRadius == 0) {
      return BorderRadius.zero;
    }

    final standardRadius = Radius.circular(borderRadius);
    final smallRadius = Radius.circular(borderRadius * 0.25);

    if (isFromUser) {
      // 用户消息：右侧圆角较小
      return BorderRadius.only(
        topLeft: standardRadius,
        topRight: isFirstInGroup ? standardRadius : smallRadius,
        bottomLeft: standardRadius,
        bottomRight: isLastInGroup ? smallRadius : standardRadius,
      );
    } else {
      // AI消息：左侧圆角较小
      return BorderRadius.only(
        topLeft: isFirstInGroup ? standardRadius : smallRadius,
        topRight: standardRadius,
        bottomLeft: isLastInGroup ? smallRadius : standardRadius,
        bottomRight: standardRadius,
      );
    }
  }

  /// 计算对称圆角
  static BorderRadius symmetric(double borderRadius) {
    return BorderRadius.circular(borderRadius);
  }

  /// 计算顶部圆角
  static BorderRadius topOnly(double borderRadius) {
    return BorderRadius.only(
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
    );
  }

  /// 计算底部圆角
  static BorderRadius bottomOnly(double borderRadius) {
    return BorderRadius.only(
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );
  }

  /// 计算左侧圆角
  static BorderRadius leftOnly(double borderRadius) {
    return BorderRadius.only(
      topLeft: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
    );
  }

  /// 计算右侧圆角
  static BorderRadius rightOnly(double borderRadius) {
    return BorderRadius.only(
      topRight: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );
  }
}

/// 气泡阴影计算工具
class BubbleShadow {
  BubbleShadow._();

  /// 为样式创建阴影
  static List<BoxShadow> forStyle(
    BubbleContext context, {
    bool isHovered = false,
    bool isSelected = false,
  }) {
    final baseShadows = context.style.theme.shadows;

    if (baseShadows.isEmpty) {
      return [];
    }

    double multiplier = 1.0;

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

  /// 创建轻微阴影
  static List<BoxShadow> light(Color shadowColor) {
    return [
      BoxShadow(
        color: shadowColor.withValues(alpha: 0.1),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ];
  }

  /// 创建中等阴影
  static List<BoxShadow> medium(Color shadowColor) {
    return [
      BoxShadow(
        color: shadowColor.withValues(alpha: 0.15),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// 创建重阴影
  static List<BoxShadow> heavy(Color shadowColor) {
    return [
      BoxShadow(
        color: shadowColor.withValues(alpha: 0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// 创建发光效果
  static List<BoxShadow> glow(Color glowColor) {
    return [
      BoxShadow(
        color: glowColor.withValues(alpha: 0.3),
        blurRadius: 12,
        spreadRadius: 2,
        offset: Offset.zero,
      ),
    ];
  }

  /// 创建内阴影效果（通过多层阴影模拟）
  static List<BoxShadow> inset(Color shadowColor) {
    return [
      BoxShadow(
        color: shadowColor.withValues(alpha: 0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
        spreadRadius: -2,
      ),
    ];
  }
}

/// 气泡装饰扩展方法
extension BubbleDecorationExtensions on BoxDecoration {
  /// 添加悬停效果
  BoxDecoration withHover(Color hoverColor) {
    return copyWith(
      color: Color.alphaBlend(
        hoverColor.withValues(alpha: 0.05),
        color ?? Colors.transparent,
      ),
      boxShadow: boxShadow?.map((shadow) => shadow.copyWith(
        blurRadius: shadow.blurRadius * 1.2,
      )).toList(),
    );
  }

  /// 添加选中效果
  BoxDecoration withSelection(Color selectionColor) {
    return copyWith(
      color: Color.alphaBlend(
        selectionColor.withValues(alpha: 0.1),
        color ?? Colors.transparent,
      ),
      border: Border.all(
        color: selectionColor.withValues(alpha: 0.3),
        width: 1.0,
      ),
    );
  }

  /// 添加错误效果
  BoxDecoration withError(Color errorColor) {
    return copyWith(
      color: Color.alphaBlend(
        errorColor.withValues(alpha: 0.1),
        color ?? Colors.transparent,
      ),
      border: Border.all(
        color: errorColor.withValues(alpha: 0.3),
        width: 1.0,
      ),
    );
  }
}
