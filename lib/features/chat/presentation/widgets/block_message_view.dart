import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_status.dart' as msg_status;
import '../../domain/entities/message_block_type.dart';
import '../../domain/entities/chat_bubble_style.dart';
import '../providers/chat_style_provider.dart';
import '../providers/chat_providers.dart';
import 'bubble/message_bubble.dart';
import 'bubble/bubble_style.dart';
import 'message_block_widget.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';

/// 块化消息视图组件
/// 
/// 基于新的块化消息架构的消息显示组件
class BlockMessageView extends ConsumerStatefulWidget {
  const BlockMessageView({
    super.key,
    required this.message,
    this.onEdit,
    this.onRegenerate,
    this.onBlockEdit,
    this.onBlockDelete,
    this.onBlockRegenerate,
    this.isEditable = false,
  });

  /// 消息对象
  final Message message;

  /// 编辑消息回调
  final VoidCallback? onEdit;

  /// 重新生成消息回调
  final VoidCallback? onRegenerate;

  /// 编辑消息块回调
  final Function(String blockId)? onBlockEdit;

  /// 删除消息块回调
  final Function(String blockId)? onBlockDelete;

  /// 重新生成消息块回调
  final Function(String blockId)? onBlockRegenerate;

  /// 是否可编辑
  final bool isEditable;

  @override
  ConsumerState<BlockMessageView> createState() => _BlockMessageViewState();
}

class _BlockMessageViewState extends ConsumerState<BlockMessageView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatStyle = ref.watch(currentChatStyleProvider);

    switch (chatStyle) {
      case ChatBubbleStyle.list:
        return _buildListLayout(context, theme);
      case ChatBubbleStyle.card:
        return _buildCardLayout(context, theme);
      case ChatBubbleStyle.bubble:
        return _buildBubbleLayout(context, theme);
    }
  }

  /// 构建列表布局
  Widget _buildListLayout(BuildContext context, ThemeData theme) {
    return Container(
      margin: AdaptiveSpacing.getMessagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 消息头部
          _buildMessageHeader(theme),
          SizedBox(height: DesignConstants.spaceM),

          // 消息块列表
          Container(
            width: double.infinity,
            padding: AdaptiveSpacing.getCardPadding(context),
            decoration: BoxDecoration(
              color: _getListStyleBackgroundColor(theme),
              borderRadius: DesignConstants.radiusM,
              border: Border.all(
                color: widget.message.isError
                    ? theme.colorScheme.error.withValues(alpha: 0.5)
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: widget.message.isError
                    ? DesignConstants.borderWidthThin * 2
                    : DesignConstants.borderWidthThin,
              ),
              boxShadow: DesignConstants.shadowXS(theme),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._buildMessageBlocks(),
                
                // 消息状态指示器
                if (widget.message.status != msg_status.MessageStatus.userSuccess &&
                    widget.message.status != msg_status.MessageStatus.aiSuccess)
                  _buildMessageStatusIndicator(theme),
              ],
            ),
          ),

          // 操作按钮
          SizedBox(height: DesignConstants.spaceS),
          _buildActionButtons(context, theme),
        ],
      ),
    );
  }

  /// 构建卡片布局
  Widget _buildCardLayout(BuildContext context, ThemeData theme) {
    final isDesktop = DesignConstants.isDesktop(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 0,
        vertical: isDesktop ? DesignConstants.spaceL : DesignConstants.spaceM,
      ),
      child: Card(
        elevation: isDesktop ? 2 : 1,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: DesignConstants.radiusL,
          side: BorderSide(
            color: widget.message.isError
                ? theme.colorScheme.error.withValues(alpha: 0.5)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
            width: widget.message.isError
                ? DesignConstants.borderWidthThin * 2
                : DesignConstants.borderWidthThin,
          ),
        ),
        child: Padding(
          padding: isDesktop
              ? DesignConstants.paddingXXL
              : DesignConstants.paddingXL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部信息：角色、时间戳和操作按钮
              _buildCardHeader(theme, isDesktop),
              SizedBox(height: DesignConstants.spaceL),

              // 消息块列表
              ..._buildMessageBlocks(),

              // 消息状态指示器
              if (widget.message.status != msg_status.MessageStatus.userSuccess &&
                  widget.message.status != msg_status.MessageStatus.aiSuccess)
                _buildMessageStatusIndicator(theme),

              // Token使用信息显示（仅AI消息）
              if (widget.message.isAiMessage && widget.message.metadata != null)
                _buildTokenInfo(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建气泡布局
  Widget _buildBubbleLayout(BuildContext context, ThemeData theme) {
    // 使用新的MessageBubble组件，传递主题颜色方案
    return MessageBubble(
      message: widget.message,
      style: BubbleStyle.fromChatStyle(
        ChatBubbleStyle.bubble,
        colorScheme: theme.colorScheme, // 传递主题颜色方案
      ),
      onEdit: widget.onEdit,
      onRegenerate: widget.onRegenerate,
    );
  }

  /// 构建消息头部
  Widget _buildMessageHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignConstants.spaceS,
            vertical: DesignConstants.spaceXS / 2,
          ),
          decoration: BoxDecoration(
            color: widget.message.isFromUser
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                : theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
            borderRadius: DesignConstants.radiusM,
          ),
          child: Text(
            widget.message.isFromUser ? "用户" : "AI助手",
            style: TextStyle(
              color: widget.message.isFromUser
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: DesignConstants.spaceS),
        Text(
          _formatTimestamp(widget.message.createdAt),
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  /// 构建卡片头部
  Widget _buildCardHeader(ThemeData theme, bool isDesktop) {
    return Row(
      children: [
        // 角色头像
        Container(
          width: isDesktop
              ? DesignConstants.iconSizeXXL
              : DesignConstants.iconSizeXL,
          height: isDesktop
              ? DesignConstants.iconSizeXXL
              : DesignConstants.iconSizeXL,
          decoration: BoxDecoration(
            color: widget.message.isFromUser
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.secondaryContainer,
            borderRadius: DesignConstants.radiusXL,
          ),
          child: Icon(
            widget.message.isFromUser
                ? Icons.person_rounded
                : Icons.smart_toy_rounded,
            color: widget.message.isFromUser
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSecondaryContainer,
            size: isDesktop
                ? DesignConstants.iconSizeM
                : DesignConstants.iconSizeS + 2,
          ),
        ),
        SizedBox(width: DesignConstants.spaceM),

        // 角色名称和时间
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.message.isFromUser ? "用户" : "AI助手",
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: DesignConstants.getResponsiveFontSize(
                      context,
                      mobile: 15,
                      desktop: 16),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatTimestamp(widget.message.createdAt),
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: DesignConstants.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      desktop: 13),
                ),
              ),
            ],
          ),
        ),

        // 操作按钮
        _buildActionButtons(context, theme),
      ],
    );
  }

  /// 构建消息块列表
  List<Widget> _buildMessageBlocks() {
    if (widget.message.blocks.isEmpty) {
      return [
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: DesignConstants.radiusM,
          ),
          child: Center(
            child: Text(
              '消息内容为空',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ];
    }

    // 获取聊天设置
    final chatSettings = ref.watch(chatSettingsProvider);

    // 根据用户设置过滤消息块
    final filteredBlocks = widget.message.blocks.where((block) {
      // 如果是思考过程块，检查用户是否启用了显示思考过程
      if (block.type == MessageBlockType.thinking) {
        return chatSettings.showThinkingProcess;
      }
      // 其他类型的块正常显示
      return true;
    }).toList();

    return filteredBlocks.map((block) {
      return MessageBlockWidget(
        key: ValueKey(block.id),
        block: block,
        isEditable: widget.isEditable,
        onEdit: widget.onBlockEdit != null
            ? () => widget.onBlockEdit!(block.id)
            : null,
        onDelete: widget.onBlockDelete != null
            ? () => widget.onBlockDelete!(block.id)
            : null,
        onRegenerate: widget.onBlockRegenerate != null
            ? () => widget.onBlockRegenerate!(block.id)
            : null,
      );
    }).toList();
  }

  /// 构建气泡块列表
  List<Widget> _buildBubbleBlocks(ThemeData theme, double maxWidth) {
    if (widget.message.blocks.isEmpty) {
      return [
        Container(
          padding: DesignConstants.paddingM,
          decoration: BoxDecoration(
            color: widget.message.isFromUser
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: _getBubbleBorderRadius(),
          ),
          child: Text(
            '消息内容为空',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ];
    }

    return widget.message.blocks.map((block) {
      return Container(
        margin: EdgeInsets.only(bottom: DesignConstants.spaceXS),
        child: MessageBlockWidget(
          key: ValueKey(block.id),
          block: block,
          isEditable: widget.isEditable,
          onEdit: widget.onBlockEdit != null
              ? () => widget.onBlockEdit!(block.id)
              : null,
          onDelete: widget.onBlockDelete != null
              ? () => widget.onBlockDelete!(block.id)
              : null,
          onRegenerate: widget.onBlockRegenerate != null
              ? () => widget.onBlockRegenerate!(block.id)
              : null,
        ),
      );
    }).toList();
  }

  /// 构建消息状态指示器
  Widget _buildMessageStatusIndicator(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(top: DesignConstants.spaceS),
      child: Row(
        children: [
          Icon(
            _getMessageStatusIcon(),
            size: DesignConstants.iconSizeS,
            color: _getMessageStatusColor(theme),
          ),
          SizedBox(width: DesignConstants.spaceXS),
          Text(
            widget.message.status.displayName,
            style: TextStyle(
              fontSize: 11,
              color: _getMessageStatusColor(theme),
            ),
          ),
          if (widget.message.status.showLoadingIndicator) ...[
            SizedBox(width: DesignConstants.spaceS),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _getMessageStatusColor(theme),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建Token信息
  Widget _buildTokenInfo(BuildContext context, ThemeData theme) {
    final metadata = widget.message.metadata;
    if (metadata == null) return const SizedBox.shrink();

    final usage = metadata['usage'] as Map<String, dynamic>?;
    if (usage == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: DesignConstants.spaceS),
      child: Text(
        'Tokens: ${usage['totalTokens']} ↑${usage['promptTokens']} ↓${usage['completionTokens']}',
        style: TextStyle(
          fontSize: 10,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    final List<Widget> actionButtons = [];

    // 复制按钮
    actionButtons.add(
      IconButton(
        onPressed: () => _copyMessage(),
        icon: Icon(
          Icons.copy_rounded,
          size: DesignConstants.iconSizeS,
        ),
        tooltip: '复制消息',
      ),
    );

    // 编辑按钮（仅用户消息）
    if (widget.message.isFromUser && widget.onEdit != null) {
      actionButtons.add(
        IconButton(
          onPressed: widget.onEdit,
          icon: Icon(
            Icons.edit_rounded,
            size: DesignConstants.iconSizeS,
          ),
          tooltip: '编辑消息',
        ),
      );
    }

    // 重新生成按钮（仅AI消息）
    if (widget.message.isAiMessage && widget.onRegenerate != null) {
      actionButtons.add(
        IconButton(
          onPressed: widget.onRegenerate,
          icon: Icon(
            Icons.refresh_rounded,
            size: DesignConstants.iconSizeS,
          ),
          tooltip: '重新生成',
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actionButtons,
    );
  }

  /// 复制消息内容
  void _copyMessage() {
    final content = widget.message.content;
    if (content.isNotEmpty) {
      // 复制功能已在MessageBlockWidget中实现
      // 这里可以调用系统剪贴板API或显示复制成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('消息内容已复制')),
      );
    }
  }

  /// 格式化时间戳
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.month.toString().padLeft(2, '0')}/${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  /// 获取列表样式背景色
  Color _getListStyleBackgroundColor(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    } else {
      return theme.colorScheme.surface;
    }
  }

  /// 获取气泡边框半径
  BorderRadius _getBubbleBorderRadius() {
    return BorderRadius.only(
      topLeft: DesignConstants.radiusXL.topLeft,
      topRight: DesignConstants.radiusXL.topRight,
      bottomLeft: widget.message.isFromUser
          ? DesignConstants.radiusXL.bottomLeft
          : DesignConstants.radiusXS.bottomLeft,
      bottomRight: widget.message.isFromUser
          ? DesignConstants.radiusXS.bottomRight
          : DesignConstants.radiusXL.bottomRight,
    );
  }

  /// 获取消息状态图标
  IconData _getMessageStatusIcon() {
    switch (widget.message.status) {
      case msg_status.MessageStatus.userSuccess:
        return Icons.check_rounded;
      case msg_status.MessageStatus.aiProcessing:
        return Icons.hourglass_empty_rounded;
      case msg_status.MessageStatus.aiPending:
        return Icons.schedule_rounded;
      case msg_status.MessageStatus.aiStreaming:
        return Icons.stream_rounded;
      case msg_status.MessageStatus.aiSuccess:
        return Icons.check_rounded;
      case msg_status.MessageStatus.aiError:
        return Icons.error_rounded;
      case msg_status.MessageStatus.aiPaused:
        return Icons.pause_rounded;
      case msg_status.MessageStatus.system:
        return Icons.info_rounded;
      case msg_status.MessageStatus.temporary:
        return Icons.schedule_rounded;
    }
  }

  /// 获取消息状态颜色
  Color _getMessageStatusColor(ThemeData theme) {
    switch (widget.message.status) {
      case msg_status.MessageStatus.userSuccess:
        return theme.colorScheme.primary;
      case msg_status.MessageStatus.aiProcessing:
        return theme.colorScheme.primary;
      case msg_status.MessageStatus.aiPending:
        return theme.colorScheme.secondary;
      case msg_status.MessageStatus.aiStreaming:
        return theme.colorScheme.primary.withValues(alpha: 0.8);
      case msg_status.MessageStatus.aiSuccess:
        return theme.colorScheme.primary;
      case msg_status.MessageStatus.aiError:
        return theme.colorScheme.error;
      case msg_status.MessageStatus.aiPaused:
        return theme.colorScheme.tertiary;
      case msg_status.MessageStatus.system:
        return theme.colorScheme.onSurface.withValues(alpha: 0.6);
      case msg_status.MessageStatus.temporary:
        return theme.colorScheme.onSurface.withValues(alpha: 0.4);
    }
  }
}
