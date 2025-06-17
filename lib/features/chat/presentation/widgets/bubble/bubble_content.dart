import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/message.dart';
import '../../../domain/entities/message_status.dart';
import '../../../domain/entities/message_block_type.dart';
import '../../providers/chat_providers.dart';
import '../animated_typing_indicator.dart';
import 'bubble_context.dart';
import 'bubble_block_renderer.dart';
import 'block_layout_manager.dart';

/// 气泡内容组件
///
/// 负责渲染气泡内的所有消息块内容
class BubbleContent extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: this.context.padding,
      child: Column(
        crossAxisAlignment: this.context.crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 消息块内容
          ..._buildMessageBlocks(ref),

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
  List<Widget> _buildMessageBlocks(WidgetRef ref) {
    if (message.blocks.isEmpty) {
      return [_buildEmptyContent()];
    }

    // 获取聊天设置
    final chatSettings = ref.watch(chatSettingsProvider);

    // 根据用户设置过滤消息块
    final filteredBlocks = message.blocks.where((block) {
      // 如果是思考过程块，检查用户是否启用了显示思考过程
      if (block.type == MessageBlockType.thinking) {
        return chatSettings.showThinkingProcess;
      }
      // 其他类型的块正常显示
      return true;
    }).toList();

    if (filteredBlocks.isEmpty) {
      return [_buildEmptyContent()];
    }

    // 使用新的布局管理器构建优化的块列表
    final layoutManager = BlockLayoutManager.instance;
    final renderer = BubbleBlockRenderer.instance;

    return layoutManager.buildOptimizedBlockList(
      filteredBlocks,
      context,
      (block, bubbleContext, {required bool isFirst, required bool isLast}) {
        return renderer.renderBlock(
          block,
          bubbleContext,
          isFirst: isFirst,
          isLast: isLast,
        );
      },
    );
  }

  /// 构建空内容占位符
  Widget _buildEmptyContent() {
    // 根据消息状态显示不同的占位符
    if (context.isPendingStream) {
      return _buildPendingStreamPlaceholder();
    } else if (context.isActiveStreaming) {
      return _buildActiveStreamingPlaceholder();
    } else if (context.isProcessing) {
      return _buildProcessingPlaceholder();
    } else {
      return _buildDefaultEmptyPlaceholder();
    }
  }

  /// 构建等待流式开始的占位符
  Widget _buildPendingStreamPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '正在准备回复...',
            style: TextStyle(
              color: context.theme.colorScheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建流式传输中的占位符
  Widget _buildActiveStreamingPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedTypingIndicator(
            dotColor: context.theme.colorScheme.primary,
            dotSize: 5.0,
            dotSpacing: 4.0,
          ),
          const SizedBox(width: 12),
          Text(
            '正在输入...',
            style: TextStyle(
              color: context.theme.colorScheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建处理中的占位符
  Widget _buildProcessingPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.theme.colorScheme.secondary.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '正在思考...',
            style: TextStyle(
              color: context.theme.colorScheme.secondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建默认空内容占位符
  Widget _buildDefaultEmptyPlaceholder() {
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
    if (context.message.status.showLoadingIndicator) {
      return _buildStreamingIndicator();
    } else if (context.message.status.isError) {
      return _buildErrorIndicator();
    }
    return const SizedBox.shrink();
  }

  /// 构建流式状态指示器
  Widget _buildStreamingIndicator() {
    if (context.isPendingStream) {
      return _buildPendingIndicator();
    } else if (context.isActiveStreaming) {
      return _buildActiveStreamingIndicator();
    } else if (context.isProcessing) {
      return _buildProcessingIndicator();
    } else {
      return _buildDefaultStreamingIndicator();
    }
  }

  /// 构建等待状态指示器
  Widget _buildPendingIndicator() {
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
                context.theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '等待回复...',
            style: TextStyle(
              fontSize: 12,
              color: context.theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建活跃流式指示器
  Widget _buildActiveStreamingIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedTypingIndicator(
            dotColor: context.theme.colorScheme.primary,
            dotSize: 3.0,
            dotSpacing: 3.0,
          ),
          const SizedBox(width: 8),
          Text(
            '正在输入...',
            style: TextStyle(
              fontSize: 12,
              color: context.theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          _buildBlinkingCursor(),
        ],
      ),
    );
  }

  /// 构建处理中指示器
  Widget _buildProcessingIndicator() {
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
                context.theme.colorScheme.secondary.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '正在思考...',
            style: TextStyle(
              fontSize: 12,
              color: context.theme.colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建默认流式指示器
  Widget _buildDefaultStreamingIndicator() {
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

  /// 构建闪烁光标
  Widget _buildBlinkingCursor() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return AnimatedOpacity(
          opacity: (value * 2) % 2 > 1 ? 1.0 : 0.3,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 2,
            height: 14,
            decoration: BoxDecoration(
              color: this.context.theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      },
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



  /// 是否应该显示状态指示器
  bool _shouldShowStatusIndicator() {
    return context.message.status.showLoadingIndicator || context.message.status.isError;
  }

  /// 是否应该显示操作按钮
  bool _shouldShowActions() {
    // 只在非进行中状态下显示操作按钮
    return !context.message.status.isInProgress &&
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
