import 'package:flutter/material.dart';

import '../../../../../shared/presentation/design_system/design_constants.dart';

/// 气泡布局配置类
/// 
/// 管理气泡的尺寸、间距、圆角等布局相关配置
class BubbleLayout {
  const BubbleLayout({
    required this.padding,
    required this.margin,
    required this.borderRadius,
    required this.maxWidthRatio,
    required this.minWidth,
    this.alignment,
  });

  /// 内边距
  final EdgeInsets padding;

  /// 外边距
  final EdgeInsets margin;

  /// 圆角半径
  final double borderRadius;

  /// 最大宽度比例（相对于屏幕宽度）
  final double maxWidthRatio;

  /// 最小宽度
  final double minWidth;

  /// 对齐方式（可选）
  final Alignment? alignment;

  /// 创建气泡布局
  factory BubbleLayout.bubble() {
    return BubbleLayout(
      padding: DesignConstants.paddingM,
      margin: EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceS,
        vertical: DesignConstants.spaceXS / 2, // 减少垂直间距，避免与列表项间距叠加
      ),
      borderRadius: DesignConstants.radiusL.topLeft.x,
      maxWidthRatio: 0.75,
      minWidth: 80.0,
    );
  }

  /// 创建卡片布局
  factory BubbleLayout.card() {
    return BubbleLayout(
      padding: DesignConstants.paddingL,
      margin: EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceM,
        vertical: DesignConstants.spaceXS, // 减少垂直间距，保持一致性
      ),
      borderRadius: DesignConstants.radiusM.topLeft.x,
      maxWidthRatio: 0.9,
      minWidth: 120.0,
    );
  }

  /// 创建列表布局
  factory BubbleLayout.list() {
    return BubbleLayout(
      padding: DesignConstants.paddingM,
      margin: EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceM,
        vertical: DesignConstants.spaceXS / 2, // 减少垂直间距，避免双重间距
      ),
      borderRadius: 0.0,
      maxWidthRatio: 1.0,
      minWidth: 0.0,
    );
  }

  /// 创建紧凑布局
  factory BubbleLayout.compact() {
    return BubbleLayout(
      padding: EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceM,
        vertical: DesignConstants.spaceS,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceS,
        vertical: DesignConstants.spaceXS / 2,
      ),
      borderRadius: DesignConstants.radiusM.topLeft.x,
      maxWidthRatio: 0.8,
      minWidth: 60.0,
    );
  }

  /// 创建宽松布局
  factory BubbleLayout.spacious() {
    return BubbleLayout(
      padding: EdgeInsets.all(DesignConstants.spaceL),
      margin: EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceL,
        vertical: DesignConstants.spaceM,
      ),
      borderRadius: DesignConstants.radiusXL.topLeft.x,
      maxWidthRatio: 0.7,
      minWidth: 100.0,
    );
  }

  /// 创建响应式布局
  factory BubbleLayout.responsive(BuildContext context) {
    if (DesignConstants.isDesktop(context)) {
      return BubbleLayout.spacious();
    } else if (DesignConstants.isTablet(context)) {
      return BubbleLayout.bubble();
    } else {
      return BubbleLayout.compact();
    }
  }

  /// 创建优化的响应式布局（减少间距浪费）
  factory BubbleLayout.optimizedResponsive(BuildContext context) {
    final isMobile = DesignConstants.isMobile(context);
    final isTablet = DesignConstants.isTablet(context);

    return BubbleLayout(
      padding: _getOptimizedPadding(context),
      margin: _getOptimizedMargin(context),
      borderRadius: DesignConstants.radiusL.topLeft.x,
      maxWidthRatio: isMobile ? 0.9 : (isTablet ? 0.8 : 0.75), // 更宽的移动端布局
      minWidth: isMobile ? 40.0 : (isTablet ? 60.0 : 80.0), // 更小的最小宽度
    );
  }

  /// 获取优化的内边距
  static EdgeInsets _getOptimizedPadding(BuildContext context) {
    if (DesignConstants.isMobile(context)) {
      return EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceM, // 12px
        vertical: DesignConstants.spaceS,   // 8px
      );
    } else if (DesignConstants.isTablet(context)) {
      return EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceL,  // 16px
        vertical: DesignConstants.spaceM,    // 12px
      );
    } else {
      return EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceXL, // 20px
        vertical: DesignConstants.spaceL,    // 16px
      );
    }
  }

  /// 获取优化的外边距
  static EdgeInsets _getOptimizedMargin(BuildContext context) {
    if (DesignConstants.isMobile(context)) {
      return EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceXS, // 4px - 减少水平间距
        vertical: DesignConstants.spaceXS,   // 4px - 减少垂直间距
      );
    } else if (DesignConstants.isTablet(context)) {
      return EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceS,  // 8px
        vertical: DesignConstants.spaceXS,   // 4px
      );
    } else {
      return EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceM,  // 12px
        vertical: DesignConstants.spaceS,    // 8px
      );
    }
  }

  /// 复制并修改布局
  BubbleLayout copyWith({
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? borderRadius,
    double? maxWidthRatio,
    double? minWidth,
    Alignment? alignment,
  }) {
    return BubbleLayout(
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      borderRadius: borderRadius ?? this.borderRadius,
      maxWidthRatio: maxWidthRatio ?? this.maxWidthRatio,
      minWidth: minWidth ?? this.minWidth,
      alignment: alignment ?? this.alignment,
    );
  }

  /// 获取智能圆角
  /// 根据消息位置和类型动态计算圆角
  BorderRadius getSmartBorderRadius({
    required bool isFromUser,
    required bool isFirstInGroup,
    required bool isLastInGroup,
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

  /// 获取对齐方式
  Alignment getAlignment(bool isFromUser) {
    if (alignment != null) return alignment!;
    return isFromUser ? Alignment.centerRight : Alignment.centerLeft;
  }

  /// 获取交叉轴对齐方式
  CrossAxisAlignment getCrossAxisAlignment(bool isFromUser) {
    return isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
  }

  /// 获取主轴对齐方式
  MainAxisAlignment getMainAxisAlignment(bool isFromUser) {
    return isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BubbleLayout &&
        other.padding == padding &&
        other.margin == margin &&
        other.borderRadius == borderRadius &&
        other.maxWidthRatio == maxWidthRatio &&
        other.minWidth == minWidth &&
        other.alignment == alignment;
  }

  @override
  int get hashCode {
    return Object.hash(
      padding,
      margin,
      borderRadius,
      maxWidthRatio,
      minWidth,
      alignment,
    );
  }

  @override
  String toString() {
    return 'BubbleLayout(padding: $padding, margin: $margin, borderRadius: $borderRadius, ...)';
  }
}

/// 气泡布局扩展方法
extension BubbleLayoutExtensions on BubbleLayout {
  /// 获取适合桌面端的布局
  BubbleLayout get forDesktop {
    return copyWith(
      padding: EdgeInsets.all(padding.left * 1.2),
      borderRadius: borderRadius * 1.25,
      maxWidthRatio: maxWidthRatio * 0.8,
    );
  }

  /// 获取适合移动端的布局
  BubbleLayout get forMobile {
    return copyWith(
      padding: EdgeInsets.all(padding.left * 0.8),
      borderRadius: borderRadius * 0.9,
      maxWidthRatio: maxWidthRatio * 1.1,
    );
  }

  /// 获取适合平板的布局
  BubbleLayout get forTablet {
    return copyWith(
      padding: EdgeInsets.all(padding.left * 1.0),
      borderRadius: borderRadius * 1.0,
      maxWidthRatio: maxWidthRatio * 0.9,
    );
  }
}
