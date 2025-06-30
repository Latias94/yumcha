import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_block.dart';
import '../../domain/entities/chat_bubble_style.dart';
import '../providers/chat_providers.dart';
import '../providers/chat_style_provider.dart';
import 'block_message_view.dart';
import '../screens/widgets/chat_message_view.dart';
import 'bubble/message_bubble.dart';
import 'bubble/bubble_style.dart';

/// 消息视图适配器
///
/// 统一的消息显示组件，根据配置选择合适的视图样式
/// 支持块化消息架构和多种显示样式
class MessageViewAdapter extends ConsumerWidget {
  const MessageViewAdapter({
    super.key,
    required this.message,
    this.onEdit,
    this.onRegenerate,
    this.onDelete,
    this.isWelcomeMessage = false,
    this.useBlockView = false, // 控制是否使用新的块化视图
  });

  /// 消息对象（新的Message类）
  final Message message;

  /// 编辑消息回调
  final VoidCallback? onEdit;

  /// 重新生成消息回调
  final VoidCallback? onRegenerate;

  /// 删除消息回调
  final VoidCallback? onDelete;

  /// 是否为欢迎消息
  final bool isWelcomeMessage;

  /// 是否使用块化视图
  final bool useBlockView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatStyle = ref.watch(currentChatStyleProvider);

    // 根据聊天样式选择合适的视图
    switch (chatStyle) {
      case ChatBubbleStyle.bubble:
        return _buildBubbleView(context, ref);
      case ChatBubbleStyle.card:
      case ChatBubbleStyle.list:
        // 检查是否启用块化视图
        if (useBlockView) {
          return _buildBlockView(context, ref);
        } else {
          return _buildStandardView(context, ref);
        }
    }
  }

  /// 构建气泡视图（使用MessageBubble组件）
  Widget _buildBubbleView(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return MessageBubble(
      message: message,
      style: BubbleStyle.fromChatStyle(
        ChatBubbleStyle.bubble,
        colorScheme: theme.colorScheme, // 传递主题颜色方案
      ),
      onEdit: onEdit,
      onRegenerate: onRegenerate,
    );
  }

  /// 构建块化视图
  Widget _buildBlockView(BuildContext context, WidgetRef ref) {
    return BlockMessageView(
      message: message,
      onEdit: onEdit,
      onRegenerate: onRegenerate,
      onBlockEdit: (blockId) {
        // 块编辑功能 - 通过消息级别的编辑实现
        onEdit?.call();
      },
      onBlockDelete: (blockId) {
        // 块删除功能 - 通过消息级别的操作实现
        // 暂时不支持单独删除块
      },
      onBlockRegenerate: (blockId) {
        // 块重新生成功能 - 通过消息级别的重新生成实现
        onRegenerate?.call();
      },
      isEditable: false, // 暂时禁用编辑功能
    );
  }

  /// 构建标准视图（使用ChatMessageView组件）
  Widget _buildStandardView(BuildContext context, WidgetRef ref) {
    return ChatMessageView(
      message: message,
      onEdit: onEdit,
      onRegenerate: onRegenerate,
      isWelcomeMessage: isWelcomeMessage,
    );
  }
}

/// 消息视图配置Provider
final messageViewConfigProvider = StateProvider<MessageViewConfig>((ref) {
  return const MessageViewConfig();
});

/// 消息视图配置
class MessageViewConfig {
  /// 是否启用块化视图
  final bool enableBlockView;

  /// 是否启用块编辑功能
  final bool enableBlockEditing;

  /// 是否显示块类型标识
  final bool showBlockTypeLabels;

  const MessageViewConfig({
    this.enableBlockView = false, // 默认禁用，逐步迁移
    this.enableBlockEditing = false,
    this.showBlockTypeLabels = false,
  });

  MessageViewConfig copyWith({
    bool? enableBlockView,
    bool? enableBlockEditing,
    bool? showBlockTypeLabels,
  }) {
    return MessageViewConfig(
      enableBlockView: enableBlockView ?? this.enableBlockView,
      enableBlockEditing: enableBlockEditing ?? this.enableBlockEditing,
      showBlockTypeLabels: showBlockTypeLabels ?? this.showBlockTypeLabels,
    );
  }
}

/// 便捷的消息视图组件
///
/// 自动根据配置选择合适的视图
class AdaptiveMessageView extends ConsumerWidget {
  const AdaptiveMessageView({
    super.key,
    required this.message,
    this.onEdit,
    this.onRegenerate,
    this.onDelete,
    this.isWelcomeMessage = false,
  });

  final Message message;
  final VoidCallback? onEdit;
  final VoidCallback? onRegenerate;
  final VoidCallback? onDelete;
  final bool isWelcomeMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatSettings = ref.watch(chatSettingsProvider);

    return MessageViewAdapter(
      message: message,
      onEdit: onEdit,
      onRegenerate: onRegenerate,
      onDelete: onDelete,
      isWelcomeMessage: isWelcomeMessage,
      useBlockView: chatSettings.enableBlockView,
    );
  }
}

/// 用于测试的消息创建工具
class MessageTestUtils {
  /// 创建测试用的块化消息
  static Message createTestBlockMessage({
    required String id,
    required String conversationId,
    required bool isFromUser,
    String? textContent,
    String? thinkingContent,
    String? codeContent,
    String? errorContent,
  }) {
    final blocks = <MessageBlock>[];

    // 添加思考过程块
    if (thinkingContent != null && thinkingContent.isNotEmpty) {
      blocks.add(MessageBlock.thinking(
        id: '${id}_thinking',
        messageId: id,
        content: thinkingContent,
      ));
    }

    // 添加主文本块
    if (textContent != null && textContent.isNotEmpty) {
      blocks.add(MessageBlock.text(
        id: '${id}_text',
        messageId: id,
        content: textContent,
      ));
    }

    // 添加代码块
    if (codeContent != null && codeContent.isNotEmpty) {
      blocks.add(MessageBlock.code(
        id: '${id}_code',
        messageId: id,
        content: codeContent,
        language: 'dart',
      ));
    }

    // 添加错误块
    if (errorContent != null && errorContent.isNotEmpty) {
      blocks.add(MessageBlock.error(
        id: '${id}_error',
        messageId: id,
        content: errorContent,
      ));
    }

    final now = DateTime.now();
    return Message(
      id: id,
      conversationId: conversationId,
      role: isFromUser ? 'user' : 'assistant',
      assistantId: 'test-assistant',
      createdAt: now,
      updatedAt: now,
      blocks: blocks,
    );
  }
}
