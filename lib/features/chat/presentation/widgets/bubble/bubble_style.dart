import 'package:flutter/material.dart';

import '../../../domain/entities/chat_bubble_style.dart';
import 'bubble_theme.dart';
import 'bubble_layout.dart';
import 'bubble_animation.dart';

/// 气泡类型枚举
enum BubbleType {
  /// 传统气泡样式
  bubble,
  /// 卡片样式
  card,
  /// 列表样式
  list,
}

/// 气泡样式配置类
/// 
/// 统一管理气泡的所有样式配置，包括类型、主题、布局和动画
class BubbleStyle {
  const BubbleStyle({
    required this.type,
    required this.theme,
    required this.layout,
    required this.animation,
  });

  /// 气泡类型
  final BubbleType type;

  /// 主题配置
  final BubbleTheme theme;

  /// 布局配置
  final BubbleLayout layout;

  /// 动画配置
  final BubbleAnimation animation;

  /// 创建气泡样式
  factory BubbleStyle.bubble({
    BubbleTheme? theme,
    BubbleLayout? layout,
    BubbleAnimation? animation,
  }) {
    return BubbleStyle(
      type: BubbleType.bubble,
      theme: theme ?? BubbleTheme.defaultBubble(),
      layout: layout ?? BubbleLayout.bubble(),
      animation: animation ?? BubbleAnimation.standard(),
    );
  }

  /// 创建卡片样式
  factory BubbleStyle.card({
    BubbleTheme? theme,
    BubbleLayout? layout,
    BubbleAnimation? animation,
  }) {
    return BubbleStyle(
      type: BubbleType.card,
      theme: theme ?? BubbleTheme.defaultCard(),
      layout: layout ?? BubbleLayout.card(),
      animation: animation ?? BubbleAnimation.standard(),
    );
  }

  /// 创建列表样式
  factory BubbleStyle.list({
    BubbleTheme? theme,
    BubbleLayout? layout,
    BubbleAnimation? animation,
  }) {
    return BubbleStyle(
      type: BubbleType.list,
      theme: theme ?? BubbleTheme.defaultList(),
      layout: layout ?? BubbleLayout.list(),
      animation: animation ?? BubbleAnimation.minimal(),
    );
  }

  /// 从聊天样式创建气泡样式
  factory BubbleStyle.fromChatStyle(
    ChatBubbleStyle chatStyle, {
    BubbleTheme? theme,
    BubbleAnimation? animation,
  }) {
    switch (chatStyle) {
      case ChatBubbleStyle.bubble:
        return BubbleStyle.bubble(
          theme: theme,
          animation: animation,
        );
      case ChatBubbleStyle.card:
        return BubbleStyle.card(
          theme: theme,
          animation: animation,
        );
      case ChatBubbleStyle.list:
        return BubbleStyle.list(
          theme: theme,
          animation: animation,
        );
    }
  }

  /// 从颜色方案创建气泡样式
  factory BubbleStyle.fromColorScheme(
    BubbleType type,
    ColorScheme colorScheme, {
    BubbleLayout? layout,
    BubbleAnimation? animation,
  }) {
    final theme = BubbleTheme.fromColorScheme(colorScheme);
    
    switch (type) {
      case BubbleType.bubble:
        return BubbleStyle.bubble(
          theme: theme,
          layout: layout,
          animation: animation,
        );
      case BubbleType.card:
        return BubbleStyle.card(
          theme: theme,
          layout: layout,
          animation: animation,
        );
      case BubbleType.list:
        return BubbleStyle.list(
          theme: theme,
          layout: layout,
          animation: animation,
        );
    }
  }

  /// 复制并修改样式
  BubbleStyle copyWith({
    BubbleType? type,
    BubbleTheme? theme,
    BubbleLayout? layout,
    BubbleAnimation? animation,
  }) {
    return BubbleStyle(
      type: type ?? this.type,
      theme: theme ?? this.theme,
      layout: layout ?? this.layout,
      animation: animation ?? this.animation,
    );
  }

  /// 是否为气泡样式
  bool get isBubble => type == BubbleType.bubble;

  /// 是否为卡片样式
  bool get isCard => type == BubbleType.card;

  /// 是否为列表样式
  bool get isList => type == BubbleType.list;

  /// 获取样式名称
  String get name {
    switch (type) {
      case BubbleType.bubble:
        return '气泡';
      case BubbleType.card:
        return '卡片';
      case BubbleType.list:
        return '列表';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BubbleStyle &&
        other.type == type &&
        other.theme == theme &&
        other.layout == layout &&
        other.animation == animation;
  }

  @override
  int get hashCode {
    return Object.hash(type, theme, layout, animation);
  }

  @override
  String toString() {
    return 'BubbleStyle(type: $type, theme: $theme, layout: $layout, animation: $animation)';
  }
}

/// 气泡样式扩展方法
extension BubbleStyleExtensions on BubbleStyle {
  /// 获取适合桌面端的样式
  BubbleStyle get forDesktop {
    return copyWith(
      layout: layout.copyWith(
        borderRadius: layout.borderRadius * 1.25,
        padding: EdgeInsets.all(layout.padding.left * 1.2),
      ),
    );
  }

  /// 获取适合移动端的样式
  BubbleStyle get forMobile {
    return copyWith(
      layout: layout.copyWith(
        borderRadius: layout.borderRadius * 0.9,
        padding: EdgeInsets.all(layout.padding.left * 0.8),
      ),
    );
  }

  /// 获取紧凑样式
  BubbleStyle get compact {
    return copyWith(
      layout: layout.copyWith(
        padding: EdgeInsets.all(layout.padding.left * 0.7),
        margin: EdgeInsets.all(layout.margin.left * 0.5),
      ),
    );
  }

  /// 获取宽松样式
  BubbleStyle get spacious {
    return copyWith(
      layout: layout.copyWith(
        padding: EdgeInsets.all(layout.padding.left * 1.3),
        margin: EdgeInsets.all(layout.margin.left * 1.5),
      ),
    );
  }
}
