import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/message.dart';
import 'bubble_style.dart';
import 'bubble_context.dart';
import 'bubble_content.dart';
import 'bubble_decoration.dart';
import 'bubble_size.dart';
import '../../../../../shared/presentation/design_system/design_constants.dart';

/// 统一的消息气泡组件
/// 
/// 这是重构后的核心气泡组件，用于替代原有的多套气泡实现。
/// 支持所有类型的消息块，具备响应式布局和可配置的视觉样式。
class MessageBubble extends ConsumerWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.style,
    this.maxWidth,
    this.onTap,
    this.onLongPress,
    this.onEdit,
    this.onRegenerate,
    this.onDelete,
  });

  /// 消息对象
  final Message message;

  /// 气泡样式配置
  final BubbleStyle style;

  /// 最大宽度（可选，会自动计算）
  final double? maxWidth;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 编辑回调
  final VoidCallback? onEdit;

  /// 重新生成回调
  final VoidCallback? onRegenerate;

  /// 删除回调
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bubbleContext = BubbleContext(
          constraints: constraints,
          theme: Theme.of(context),
          style: style,
          message: message,
        );

        return _buildBubbleContainer(context, bubbleContext);
      },
    );
  }

  /// 构建气泡容器
  Widget _buildBubbleContainer(BuildContext context, BubbleContext bubbleContext) {
    final calculatedMaxWidth = maxWidth ?? BubbleSize.calculateMaxWidth(context, style);

    // 构建气泡主体
    Widget bubbleWidget = Container(
      constraints: BoxConstraints(
        maxWidth: calculatedMaxWidth,
      ),
      decoration: BubbleDecoration.create(bubbleContext),
      child: BubbleContent(
        message: message,
        context: bubbleContext,
        onEdit: onEdit,
        onRegenerate: onRegenerate,
        onDelete: onDelete,
      ),
    );

    // 添加手势识别
    if (onTap != null || onLongPress != null) {
      bubbleWidget = GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: bubbleWidget,
      );
    }

    // 添加语义标签
    bubbleWidget = Semantics(
      label: _buildSemanticLabel(),
      child: bubbleWidget,
    );

    // 为气泡样式添加角色标识和适当的布局
    if (style.isBubble) {
      return _buildBubbleWithRoleLabel(context, bubbleContext, bubbleWidget);
    }

    return bubbleWidget;
  }

  /// 构建带角色标识的气泡布局
  Widget _buildBubbleWithRoleLabel(BuildContext context, BubbleContext bubbleContext, Widget bubbleWidget) {
    return Column(
      crossAxisAlignment: bubbleContext.crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 角色标识
        _buildRoleLabel(context, bubbleContext),

        // 气泡主体
        bubbleWidget,
      ],
    );
  }

  /// 构建角色标识
  Widget _buildRoleLabel(BuildContext context, BubbleContext bubbleContext) {
    final roleText = message.isFromUser ? "用户" : "AI助手";
    final roleColor = message.isFromUser
        ? bubbleContext.theme.colorScheme.primary
        : bubbleContext.theme.colorScheme.secondary;
    final backgroundColor = message.isFromUser
        ? bubbleContext.theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
        : bubbleContext.theme.colorScheme.secondaryContainer.withValues(alpha: 0.3);

    return Container(
      margin: EdgeInsets.only(bottom: DesignConstants.spaceS),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: DesignConstants.spaceS,
              vertical: DesignConstants.spaceXS,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: DesignConstants.radiusS,
            ),
            child: Text(
              roleText,
              style: TextStyle(
                color: roleColor,
                fontSize: DesignConstants.getResponsiveFontSize(
                  context,
                  mobile: 11,
                  tablet: 12,
                  desktop: 12,
                ),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: DesignConstants.spaceS),
          Text(
            _formatTimestamp(message.createdAt),
            style: TextStyle(
              color: bubbleContext.theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: DesignConstants.getResponsiveFontSize(
                context,
                mobile: 9,
                tablet: 10,
                desktop: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 格式化时间戳
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }

  /// 构建语义标签
  String _buildSemanticLabel() {
    final sender = message.isFromUser ? '用户' : 'AI助手';
    final blockCount = message.blocks.length;
    return '$sender的消息，包含$blockCount个内容块';
  }
}

/// 便捷的气泡样式创建方法
extension MessageBubbleExtensions on MessageBubble {
  /// 创建气泡样式的消息气泡
  static MessageBubble bubble({
    required Message message,
    double? maxWidth,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    VoidCallback? onEdit,
    VoidCallback? onRegenerate,
    VoidCallback? onDelete,
  }) {
    return MessageBubble(
      message: message,
      style: BubbleStyle.bubble(),
      maxWidth: maxWidth,
      onTap: onTap,
      onLongPress: onLongPress,
      onEdit: onEdit,
      onRegenerate: onRegenerate,
      onDelete: onDelete,
    );
  }

  /// 创建卡片样式的消息气泡
  static MessageBubble card({
    required Message message,
    double? maxWidth,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    VoidCallback? onEdit,
    VoidCallback? onRegenerate,
    VoidCallback? onDelete,
  }) {
    return MessageBubble(
      message: message,
      style: BubbleStyle.card(),
      maxWidth: maxWidth,
      onTap: onTap,
      onLongPress: onLongPress,
      onEdit: onEdit,
      onRegenerate: onRegenerate,
      onDelete: onDelete,
    );
  }

  /// 创建列表样式的消息气泡
  static MessageBubble list({
    required Message message,
    double? maxWidth,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    VoidCallback? onEdit,
    VoidCallback? onRegenerate,
    VoidCallback? onDelete,
  }) {
    return MessageBubble(
      message: message,
      style: BubbleStyle.list(),
      maxWidth: maxWidth,
      onTap: onTap,
      onLongPress: onLongPress,
      onEdit: onEdit,
      onRegenerate: onRegenerate,
      onDelete: onDelete,
    );
  }
}
