import 'package:flutter/material.dart';
import 'design_constants.dart';

/// 📱 聊天消息样式
class ChatMessageStyles {
  ChatMessageStyles._();

  /// 用户消息气泡样式
  static BoxDecoration userBubble(ThemeData theme) => BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: DesignConstants.radiusM,
        boxShadow: DesignConstants.shadowS(theme),
      );

  /// AI消息气泡样式
  static BoxDecoration aiBubble(ThemeData theme) => BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: DesignConstants.radiusM,
        boxShadow: DesignConstants.shadowS(theme),
      );

  /// 系统消息气泡样式
  static BoxDecoration systemBubble(ThemeData theme) => BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: DesignConstants.radiusS,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: DesignConstants.borderWidthThin,
        ),
      );

  /// 消息内边距
  static EdgeInsets get messagePadding => DesignConstants.paddingM;

  /// 消息间距
  static double get messageSpacing => DesignConstants.spaceS;

  /// 角色标签样式
  static BoxDecoration roleLabelDecoration(ThemeData theme, bool isUser) =>
      BoxDecoration(
        color: isUser
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: DesignConstants.radiusS,
      );

  /// 时间戳文本样式
  static TextStyle timestampStyle(ThemeData theme, BuildContext context) =>
      TextStyle(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        fontSize: DesignConstants.getResponsiveFontSize(
          context,
          mobile: 9,
          tablet: 10,
          desktop: 10,
        ),
      );
}

/// 🔘 按钮样式
class ButtonStyles {
  ButtonStyles._();

  /// 主要按钮样式
  static ButtonStyle primary(ThemeData theme) => ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: DesignConstants.radiusXXL,
        ),
        padding: DesignConstants.buttonPadding,
        elevation: 2,
      );

  /// 次要按钮样式
  static ButtonStyle secondary(ThemeData theme) => OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: DesignConstants.radiusXXL,
        ),
        padding: DesignConstants.buttonPadding,
        side: BorderSide(
          color: theme.colorScheme.outline,
          width: DesignConstants.borderWidthThin,
        ),
      );

  /// 文本按钮样式
  static ButtonStyle text(ThemeData theme) => TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: DesignConstants.radiusXXL,
        ),
        padding: DesignConstants.buttonPadding,
      );

  /// 图标按钮样式
  static ButtonStyle icon(ThemeData theme) => IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: DesignConstants.radiusM,
        ),
        padding: DesignConstants.paddingS,
      );

  /// 浮动操作按钮样式
  static ButtonStyle fab(ThemeData theme) => ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: DesignConstants.radiusL,
        ),
        elevation: 6,
        padding: DesignConstants.paddingM,
      );
}

/// 📝 输入框样式
class InputStyles {
  InputStyles._();

  /// 标准输入框装饰
  static InputDecoration standard(ThemeData theme) => InputDecoration(
        border: OutlineInputBorder(
          borderRadius: DesignConstants.radiusM,
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
            width: DesignConstants.borderWidthThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DesignConstants.radiusM,
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: DesignConstants.borderWidthMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: DesignConstants.radiusM,
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: DesignConstants.borderWidthMedium,
          ),
        ),
        contentPadding: DesignConstants.paddingL,
        filled: true,
        fillColor:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      );

  /// 搜索框装饰
  static InputDecoration search(ThemeData theme) => InputDecoration(
        border: OutlineInputBorder(
          borderRadius: DesignConstants.radiusXXL,
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        contentPadding: DesignConstants.paddingL,
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      );

  /// 聊天输入框装饰
  static InputDecoration chat(ThemeData theme) => InputDecoration(
        border: OutlineInputBorder(
          borderRadius: DesignConstants.radiusXXL,
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: DesignConstants.borderWidthThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DesignConstants.radiusXXL,
          borderSide: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.4),
            width: DesignConstants.borderWidthMedium,
          ),
        ),
        filled: true,
        fillColor:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignConstants.spaceL,
          vertical: DesignConstants.spaceM,
        ),
      );
}

/// 📋 卡片样式
class CardStyles {
  CardStyles._();

  /// 标准卡片样式
  static BoxDecoration standard(ThemeData theme) => BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: DesignConstants.borderWidthThin,
        ),
        boxShadow: DesignConstants.shadowS(theme),
      );

  /// 提升卡片样式
  static BoxDecoration elevated(ThemeData theme) => BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: DesignConstants.radiusM,
        boxShadow: DesignConstants.shadowM(theme),
      );

  /// 选中卡片样式
  static BoxDecoration selected(ThemeData theme) => BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
          width: DesignConstants.borderWidthMedium,
        ),
        boxShadow: DesignConstants.shadowS(theme),
      );

  /// 错误卡片样式
  static BoxDecoration error(ThemeData theme) => BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.5),
          width: DesignConstants.borderWidthMedium,
        ),
      );
}

/// 📊 列表样式
class ListStyles {
  ListStyles._();

  /// 列表项装饰
  static BoxDecoration item(ThemeData theme, {bool isSelected = false}) =>
      BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: DesignConstants.radiusS,
      );

  /// 列表项内边距
  static EdgeInsets get itemPadding => DesignConstants.listItemPadding;

  /// 列表项间距
  static double get itemSpacing => DesignConstants.listItemSpacing;

  /// 分割线样式
  static Divider divider(ThemeData theme) => Divider(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
        thickness: DesignConstants.borderWidthThin,
        height: 1,
      );
}

/// 🎯 导航样式
class NavigationStyles {
  NavigationStyles._();

  /// 导航栏装饰
  static BoxDecoration bar(ThemeData theme) => BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
            width: DesignConstants.borderWidthThin,
          ),
        ),
      );

  /// 抽屉装饰
  static BoxDecoration drawer(ThemeData theme) => BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: DesignConstants.shadowL(theme),
      );

  /// 标签页装饰
  static BoxDecoration tab(ThemeData theme, {bool isSelected = false}) =>
      BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        borderRadius: DesignConstants.radiusS,
      );
}

/// 🔔 通知样式
class NotificationStyles {
  NotificationStyles._();

  /// 成功通知样式
  static BoxDecoration success(ThemeData theme) => BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: DesignConstants.borderWidthThin,
        ),
      );

  /// 错误通知样式
  static BoxDecoration error(ThemeData theme) => BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: DesignConstants.borderWidthThin,
        ),
      );

  /// 警告通知样式
  static BoxDecoration warning(ThemeData theme) => BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
          width: DesignConstants.borderWidthThin,
        ),
      );

  /// 信息通知样式
  static BoxDecoration info(ThemeData theme) => BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: DesignConstants.borderWidthThin,
        ),
      );
}
