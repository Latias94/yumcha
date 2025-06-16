import 'package:flutter/material.dart';

import '../../../domain/entities/message.dart';
import '../../../../../shared/presentation/design_system/design_constants.dart';
import 'bubble_context.dart';
import 'bubble_style.dart';
import 'bubble_block_renderer.dart';

/// 气泡内容组件
/// 
/// 负责渲染气泡内的所有消息块内容
class BubbleContent extends StatelessWidget {
  const BubbleContent({
    super.key,
    required this.message,
    required this.context,
    this.onEdit,
    this.onRegenerate,
    this.onDelete,
  });

  /// 消息对象
  final Message message;

  /// 气泡上下文
  final BubbleContext context;

  /// 编辑回调
  final VoidCallback? onEdit;

  /// 重新生成回调
  final VoidCallback? onRegenerate;

  /// 删除回调
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: this.context.padding,
      child: Column(
        crossAxisAlignment: this.context.crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 消息块内容
          ..._buildMessageBlocks(),

          // 消息状态指示器
          if (_shouldShowStatusIndicator())
            _buildStatusIndicator(),

          // 操作按钮（如果需要）
          if (_shouldShowActions())
            _buildActionButtons(),
        ],
      ),
    );
  }

  /// 构建消息块列表
  List<Widget> _buildMessageBlocks() {
    if (message.blocks.isEmpty) {
      return [_buildEmptyContent()];
    }

    final renderer = BubbleBlockRenderer.instance;
    final blocks = <Widget>[];

    for (int i = 0; i < message.blocks.length; i++) {
      final block = message.blocks[i];
      final isFirst = i == 0;
      final isLast = i == message.blocks.length - 1;

      final blockWidget = renderer.renderBlock(
        block,
        context.copyWith(
          // 可以根据需要传递额外的上下文信息
        ),
        isFirst: isFirst,
        isLast: isLast,
      );

      blocks.add(blockWidget);

      // 在块之间添加间距（除了最后一个）
      if (!isLast) {
        blocks.add(SizedBox(height: _getBlockSpacing()));
      }
    }

    return blocks;
  }

  /// 构建空内容占位符
  Widget _buildEmptyContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        '消息内容为空',
        style: TextStyle(
          color: context.textColor.withValues(alpha: 0.5),
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  /// 构建状态指示器
  Widget _buildStatusIndicator() {
    if (context.isStreaming) {
      return _buildStreamingIndicator();
    } else if (context.isError) {
      return _buildErrorIndicator();
    }
    return const SizedBox.shrink();
  }

  /// 构建流式状态指示器
  Widget _buildStreamingIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '正在生成...',
            style: TextStyle(
              fontSize: 12,
              color: context.theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建错误指示器
  Widget _buildErrorIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: context.theme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 14,
            color: context.theme.colorScheme.error,
          ),
          const SizedBox(width: 4),
          Text(
            '生成失败',
            style: TextStyle(
              fontSize: 12,
              color: context.theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons() {
    final actions = <Widget>[];

    if (onEdit != null) {
      actions.add(_buildActionButton(
        icon: Icons.edit_outlined,
        label: '编辑',
        onTap: onEdit!,
      ));
    }

    if (onRegenerate != null) {
      actions.add(_buildActionButton(
        icon: Icons.refresh_outlined,
        label: '重新生成',
        onTap: onRegenerate!,
      ));
    }

    if (onDelete != null) {
      actions.add(_buildActionButton(
        icon: Icons.delete_outline,
        label: '删除',
        onTap: onDelete!,
        isDestructive: true,
      ));
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: actions,
      ),
    );
  }

  /// 构建单个操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? context.theme.colorScheme.error
        : context.theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 获取块之间的间距
  double _getBlockSpacing() {
    // 使用设计系统常量，确保一致性
    switch (context.style.type) {
      case BubbleType.bubble:
        return DesignConstants.spaceS; // 8.0
      case BubbleType.card:
        return DesignConstants.spaceM; // 12.0
      case BubbleType.list:
        return DesignConstants.spaceXS; // 4.0 - 减少列表模式的块间距
    }
  }

  /// 是否应该显示状态指示器
  bool _shouldShowStatusIndicator() {
    return context.isStreaming || context.isError;
  }

  /// 是否应该显示操作按钮
  bool _shouldShowActions() {
    // 只在非流式状态下显示操作按钮
    return !context.isStreaming &&
           (onEdit != null || onRegenerate != null || onDelete != null);
  }


}

/// 气泡内容扩展方法
extension BubbleContentExtensions on BubbleContent {
  /// 创建简单的文本气泡内容
  static BubbleContent text({
    required String text,
    required BubbleContext context,
    VoidCallback? onEdit,
    VoidCallback? onRegenerate,
    VoidCallback? onDelete,
  }) {
    // 创建一个简单的文本消息
    final message = Message(
      id: 'temp',
      conversationId: 'temp',
      role: context.isFromUser ? 'user' : 'assistant',
      assistantId: 'temp',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return BubbleContent(
      message: message,
      context: context,
      onEdit: onEdit,
      onRegenerate: onRegenerate,
      onDelete: onDelete,
    );
  }
}
