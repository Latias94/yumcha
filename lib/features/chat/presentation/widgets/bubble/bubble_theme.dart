import 'package:flutter/material.dart';

/// 气泡主题配置类
/// 
/// 统一管理气泡的颜色、阴影、边框等视觉样式
class BubbleTheme {
  const BubbleTheme({
    required this.userBubbleColor,
    required this.aiBubbleColor,
    required this.userTextColor,
    required this.aiTextColor,
    required this.borderColor,
    required this.shadows,
    this.borderWidth = 0.0,
    this.elevation = 1.0,
  });

  /// 用户消息气泡颜色
  final Color userBubbleColor;

  /// AI消息气泡颜色
  final Color aiBubbleColor;

  /// 用户消息文本颜色
  final Color userTextColor;

  /// AI消息文本颜色
  final Color aiTextColor;

  /// 边框颜色
  final Color borderColor;

  /// 边框宽度
  final double borderWidth;

  /// 阴影列表
  final List<BoxShadow> shadows;

  /// 阴影高度
  final double elevation;

  /// 创建默认气泡主题（已废弃，请使用fromColorScheme）
  @Deprecated('使用 BubbleTheme.fromColorScheme 以确保主题适配')
  factory BubbleTheme.defaultBubble() {
    return const BubbleTheme(
      userBubbleColor: Color(0xFF007AFF),
      aiBubbleColor: Color(0xFFF2F2F7),
      userTextColor: Colors.white,
      aiTextColor: Color(0xFF1C1C1E),
      borderColor: Color(0xFFE5E5EA),
      shadows: [
        BoxShadow(
          color: Color(0x0F000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
      elevation: 1.0,
    );
  }

  /// 创建默认卡片主题（已废弃，请使用fromColorScheme）
  @Deprecated('使用 BubbleTheme.fromColorScheme 以确保主题适配')
  factory BubbleTheme.defaultCard() {
    return const BubbleTheme(
      userBubbleColor: Color(0xFFF8F9FA),
      aiBubbleColor: Color(0xFFF8F9FA),
      userTextColor: Color(0xFF1C1C1E),
      aiTextColor: Color(0xFF1C1C1E),
      borderColor: Color(0xFFE5E5EA),
      borderWidth: 1.0,
      shadows: [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
      elevation: 2.0,
    );
  }

  /// 创建默认列表主题（已废弃，请使用fromColorScheme）
  @Deprecated('使用 BubbleTheme.fromColorScheme 以确保主题适配')
  factory BubbleTheme.defaultList() {
    return const BubbleTheme(
      userBubbleColor: Colors.transparent,
      aiBubbleColor: Colors.transparent,
      userTextColor: Color(0xFF1C1C1E),
      aiTextColor: Color(0xFF1C1C1E),
      borderColor: Colors.transparent,
      shadows: [],
      elevation: 0.0,
    );
  }

  /// 从颜色方案创建主题
  factory BubbleTheme.fromColorScheme(ColorScheme colorScheme) {
    return BubbleTheme(
      userBubbleColor: colorScheme.primary,
      aiBubbleColor: colorScheme.surfaceContainerHighest,
      userTextColor: colorScheme.onPrimary,
      aiTextColor: colorScheme.onSurface,
      borderColor: colorScheme.outline.withValues(alpha: 0.2),
      borderWidth: 0.5,
      shadows: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
      elevation: 1.0,
    );
  }

  /// 从颜色方案创建气泡主题
  factory BubbleTheme.bubbleFromColorScheme(ColorScheme colorScheme) {
    return BubbleTheme(
      userBubbleColor: colorScheme.primary,
      aiBubbleColor: colorScheme.surfaceContainerHighest,
      userTextColor: colorScheme.onPrimary,
      aiTextColor: colorScheme.onSurface,
      borderColor: colorScheme.outline.withValues(alpha: 0.2),
      borderWidth: 0.0, // 气泡模式通常无边框
      shadows: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
      elevation: 1.0,
    );
  }

  /// 从颜色方案创建卡片主题
  factory BubbleTheme.cardFromColorScheme(ColorScheme colorScheme) {
    return BubbleTheme(
      userBubbleColor: colorScheme.surfaceContainerHigh,
      aiBubbleColor: colorScheme.surfaceContainerHigh,
      userTextColor: colorScheme.onSurface,
      aiTextColor: colorScheme.onSurface,
      borderColor: colorScheme.outline.withValues(alpha: 0.2),
      borderWidth: 1.0, // 卡片模式有边框
      shadows: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      elevation: 2.0,
    );
  }

  /// 从颜色方案创建列表主题
  factory BubbleTheme.listFromColorScheme(ColorScheme colorScheme) {
    return BubbleTheme(
      userBubbleColor: Colors.transparent,
      aiBubbleColor: Colors.transparent,
      userTextColor: colorScheme.onSurface,
      aiTextColor: colorScheme.onSurface,
      borderColor: Colors.transparent,
      borderWidth: 0.0, // 列表模式无边框
      shadows: [], // 列表模式无阴影
      elevation: 0.0,
    );
  }

  /// 创建深色主题
  factory BubbleTheme.dark() {
    return const BubbleTheme(
      userBubbleColor: Color(0xFF0A84FF),
      aiBubbleColor: Color(0xFF2C2C2E),
      userTextColor: Colors.white,
      aiTextColor: Color(0xFFFFFFFF),
      borderColor: Color(0xFF38383A),
      borderWidth: 0.5,
      shadows: [
        BoxShadow(
          color: Color(0x20000000),
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
      elevation: 2.0,
    );
  }

  /// 创建浅色主题
  factory BubbleTheme.light() {
    return const BubbleTheme(
      userBubbleColor: Color(0xFF007AFF),
      aiBubbleColor: Color(0xFFF2F2F7),
      userTextColor: Colors.white,
      aiTextColor: Color(0xFF1C1C1E),
      borderColor: Color(0xFFE5E5EA),
      borderWidth: 0.5,
      shadows: [
        BoxShadow(
          color: Color(0x0F000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
      elevation: 1.0,
    );
  }

  /// 获取消息气泡颜色
  Color getBubbleColor(bool isFromUser) {
    return isFromUser ? userBubbleColor : aiBubbleColor;
  }

  /// 获取消息文本颜色
  Color getTextColor(bool isFromUser) {
    return isFromUser ? userTextColor : aiTextColor;
  }

  /// 复制并修改主题
  BubbleTheme copyWith({
    Color? userBubbleColor,
    Color? aiBubbleColor,
    Color? userTextColor,
    Color? aiTextColor,
    Color? borderColor,
    double? borderWidth,
    List<BoxShadow>? shadows,
    double? elevation,
  }) {
    return BubbleTheme(
      userBubbleColor: userBubbleColor ?? this.userBubbleColor,
      aiBubbleColor: aiBubbleColor ?? this.aiBubbleColor,
      userTextColor: userTextColor ?? this.userTextColor,
      aiTextColor: aiTextColor ?? this.aiTextColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      shadows: shadows ?? this.shadows,
      elevation: elevation ?? this.elevation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BubbleTheme &&
        other.userBubbleColor == userBubbleColor &&
        other.aiBubbleColor == aiBubbleColor &&
        other.userTextColor == userTextColor &&
        other.aiTextColor == aiTextColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.elevation == elevation;
  }

  @override
  int get hashCode {
    return Object.hash(
      userBubbleColor,
      aiBubbleColor,
      userTextColor,
      aiTextColor,
      borderColor,
      borderWidth,
      elevation,
    );
  }

  @override
  String toString() {
    return 'BubbleTheme(userBubbleColor: $userBubbleColor, aiBubbleColor: $aiBubbleColor, ...)';
  }
}
