import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import '../../../models/message.dart';

/// 聊天消息显示组件
class ChatMessageView extends StatelessWidget {
  const ChatMessageView({
    super.key,
    required this.message,
    this.onEdit,
    this.isWelcomeMessage = false,
  });

  /// 消息对象
  final Message message;

  /// 编辑消息回调
  final VoidCallback? onEdit;

  /// 是否为欢迎消息
  final bool isWelcomeMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Column(
        crossAxisAlignment: message.isFromUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // 使用chat_bubbles库的BubbleNormal组件
          BubbleNormal(
            text: message.content,
            isSender: message.isFromUser,
            color: message.isFromUser
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            tail: true,
            textStyle: TextStyle(
              color: message.isFromUser
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              fontSize: 16,
            ),
          ),

          // 操作按钮显示在气泡下方
          const SizedBox(height: 4),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // 准备按钮列表
    final List<Widget> actionButtons = [];

    // 复制按钮 - 始终显示
    actionButtons.add(
      _buildActionButton(
        context,
        icon: Icons.copy,
        onPressed: () => _copyToClipboard(context),
        tooltip: '复制',
      ),
    );

    // 编辑按钮 - 仅用户消息显示
    if (onEdit != null && message.isFromUser) {
      actionButtons.add(
        _buildActionButton(
          context,
          icon: Icons.edit,
          onPressed: onEdit,
          tooltip: '编辑',
        ),
      );
    }

    // AI消息的额外按钮
    if (!message.isFromUser) {
      actionButtons.add(
        _buildActionButton(
          context,
          icon: Icons.refresh,
          onPressed: () => _regenerateMessage(context),
          tooltip: '重新生成',
        ),
      );
    }

    if (actionButtons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: message.isFromUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: actionButtons.map((button) {
        final isLast = button == actionButtons.last;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [button, if (!isLast) const SizedBox(width: 4)],
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        icon: Icon(
          icon,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          // 移除背景色，让按钮更简洁
          backgroundColor: Colors.transparent,
          hoverColor: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
          splashFactory: InkRipple.splashFactory,
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('消息已复制到剪贴板'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _regenerateMessage(BuildContext context) {
    // TODO: 实现重新生成消息功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('重新生成功能待实现'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
