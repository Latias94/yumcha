import 'package:flutter/material.dart';

import '../../../domain/entities/message.dart';
import '../../../domain/entities/message_status.dart';
import 'bubble_style.dart';
import '../../../../../shared/presentation/design_system/design_constants.dart';

/// 气泡上下文类
/// 
/// 提供气泡渲染所需的所有上下文信息，包括约束、主题、样式和消息数据
class BubbleContext {
  const BubbleContext({
    required this.constraints,
    required this.theme,
    required this.style,
    required this.message,
    this.isFirstInGroup = false,
    this.isLastInGroup = false,
    this.isSelected = false,
    this.isHovered = false,
  });

  /// 布局约束
  final BoxConstraints constraints;

  /// 应用主题
  final ThemeData theme;

  /// 气泡样式
  final BubbleStyle style;

  /// 消息对象
  final Message message;

  /// 是否为组中第一条消息
  final bool isFirstInGroup;

  /// 是否为组中最后一条消息
  final bool isLastInGroup;

  /// 是否被选中
  final bool isSelected;

  /// 是否被悬停
  final bool isHovered;

  /// 复制并修改上下文
  BubbleContext copyWith({
    BoxConstraints? constraints,
    ThemeData? theme,
    BubbleStyle? style,
    Message? message,
    bool? isFirstInGroup,
    bool? isLastInGroup,
    bool? isSelected,
    bool? isHovered,
  }) {
    return BubbleContext(
      constraints: constraints ?? this.constraints,
      theme: theme ?? this.theme,
      style: style ?? this.style,
      message: message ?? this.message,
      isFirstInGroup: isFirstInGroup ?? this.isFirstInGroup,
      isLastInGroup: isLastInGroup ?? this.isLastInGroup,
      isSelected: isSelected ?? this.isSelected,
      isHovered: isHovered ?? this.isHovered,
    );
  }

  /// 获取屏幕宽度
  double get screenWidth => constraints.maxWidth;

  /// 获取屏幕高度
  double get screenHeight => constraints.maxHeight;

  /// 是否为桌面端
  bool get isDesktop => screenWidth >= DesignConstants.breakpointDesktop;

  /// 是否为平板
  bool get isTablet => screenWidth >= DesignConstants.breakpointTablet &&
                      screenWidth < DesignConstants.breakpointDesktop;

  /// 是否为移动端
  bool get isMobile => screenWidth < DesignConstants.breakpointTablet;

  /// 是否为用户消息
  bool get isFromUser => message.isFromUser;

  /// 是否为AI消息
  bool get isFromAI => !message.isFromUser;

  /// 是否为错误消息（使用MessageStatus的扩展方法）
  bool get isError => message.status.isError;

  /// 是否为流式消息（使用MessageStatus的扩展方法）
  bool get isStreaming => message.status.isInProgress;

  /// 是否为等待流式开始状态
  bool get isPendingStream => message.status == MessageStatus.aiPending;

  /// 是否为流式传输中状态
  bool get isActiveStreaming => message.status == MessageStatus.aiStreaming;

  /// 是否为AI处理中状态
  bool get isProcessing => message.status == MessageStatus.aiProcessing;

  /// 是否为完成的消息（使用MessageStatus的扩展方法）
  bool get isCompleted => message.status.isCompleted;

  /// 获取消息块数量
  int get blockCount => message.blocks.length;

  /// 是否有多个消息块
  bool get hasMultipleBlocks => blockCount > 1;

  /// 是否为空消息
  bool get isEmpty => blockCount == 0 || 
                     (blockCount == 1 && !message.blocks.first.hasContent);

  /// 获取气泡颜色
  Color get bubbleColor => style.theme.getBubbleColor(isFromUser);

  /// 获取文本颜色
  Color get textColor => style.theme.getTextColor(isFromUser);

  /// 获取边框颜色
  Color get borderColor => style.theme.borderColor;

  /// 获取阴影列表
  List<BoxShadow> get shadows => style.theme.shadows;

  /// 获取内边距
  EdgeInsets get padding => style.layout.padding;

  /// 获取外边距
  EdgeInsets get margin => style.layout.margin;

  /// 获取圆角半径
  double get borderRadius => style.layout.borderRadius;

  /// 获取最大宽度比例
  double get maxWidthRatio => style.layout.maxWidthRatio;

  /// 获取最小宽度
  double get minWidth => style.layout.minWidth;

  /// 获取智能圆角
  BorderRadius get smartBorderRadius => style.layout.getSmartBorderRadius(
        isFromUser: isFromUser,
        isFirstInGroup: isFirstInGroup,
        isLastInGroup: isLastInGroup,
      );

  /// 获取对齐方式
  Alignment get alignment => style.layout.getAlignment(isFromUser);

  /// 获取交叉轴对齐方式
  CrossAxisAlignment get crossAxisAlignment => 
      style.layout.getCrossAxisAlignment(isFromUser);

  /// 获取主轴对齐方式
  MainAxisAlignment get mainAxisAlignment => 
      style.layout.getMainAxisAlignment(isFromUser);

  /// 获取计算后的最大宽度
  double get calculatedMaxWidth => screenWidth * maxWidthRatio;

  /// 获取有效约束
  BoxConstraints get effectiveConstraints => BoxConstraints(
        minWidth: minWidth,
        maxWidth: calculatedMaxWidth,
        minHeight: 0,
        maxHeight: double.infinity,
      );

  /// 是否应该显示阴影
  bool get shouldShowShadow => shadows.isNotEmpty && !style.isList;

  /// 是否应该显示边框
  bool get shouldShowBorder => style.theme.borderWidth > 0;

  /// 获取状态相关的颜色调整
  Color getStateAdjustedColor(Color baseColor) {
    if (isSelected) {
      return Color.alphaBlend(
        theme.colorScheme.primary.withValues(alpha: 0.1),
        baseColor,
      );
    }
    if (isHovered) {
      return Color.alphaBlend(
        theme.colorScheme.onSurface.withValues(alpha: 0.05),
        baseColor,
      );
    }
    return baseColor;
  }

  /// 获取状态相关的阴影调整
  List<BoxShadow> getStateAdjustedShadows() {
    if (isSelected || isHovered) {
      return shadows.map((shadow) => shadow.copyWith(
        blurRadius: shadow.blurRadius * 1.5,
        spreadRadius: shadow.spreadRadius + 1,
      )).toList();
    }
    return shadows;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BubbleContext &&
        other.constraints == constraints &&
        other.theme == theme &&
        other.style == style &&
        other.message == message &&
        other.isFirstInGroup == isFirstInGroup &&
        other.isLastInGroup == isLastInGroup &&
        other.isSelected == isSelected &&
        other.isHovered == isHovered;
  }

  @override
  int get hashCode {
    return Object.hash(
      constraints,
      theme,
      style,
      message,
      isFirstInGroup,
      isLastInGroup,
      isSelected,
      isHovered,
    );
  }

  @override
  String toString() {
    return 'BubbleContext(screenWidth: $screenWidth, isFromUser: $isFromUser, blockCount: $blockCount, ...)';
  }
}
