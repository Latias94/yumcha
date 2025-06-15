import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/legacy_message.dart';
import '../../domain/entities/message_block.dart';
import '../../domain/entities/message_block_type.dart';
import '../../domain/entities/message_status.dart' as new_status;
import '../../domain/entities/message_metadata.dart';
import '../providers/chat_providers.dart';
import 'block_message_view.dart';
import '../screens/widgets/chat_message_view.dart';

/// 消息视图适配器
/// 
/// 在重构期间提供新旧消息组件之间的兼容性
/// 根据配置决定使用块化消息组件还是传统消息组件
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

  /// 消息对象（可能是新的Message或旧的LegacyMessage）
  final dynamic message;

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
    // 检查是否启用块化视图
    if (useBlockView && message is Message) {
      return _buildBlockView(context, ref);
    } else {
      return _buildLegacyView(context, ref);
    }
  }

  /// 构建新的块化视图
  Widget _buildBlockView(BuildContext context, WidgetRef ref) {
    final blockMessage = message as Message;
    
    return BlockMessageView(
      message: blockMessage,
      onEdit: onEdit,
      onRegenerate: onRegenerate,
      onBlockEdit: (blockId) {
        // TODO: 实现块编辑功能
      },
      onBlockDelete: (blockId) {
        // TODO: 实现块删除功能
      },
      onBlockRegenerate: (blockId) {
        // TODO: 实现块重新生成功能
      },
      isEditable: false, // 暂时禁用编辑功能
    );
  }

  /// 构建传统视图
  Widget _buildLegacyView(BuildContext context, WidgetRef ref) {
    LegacyMessage legacyMessage;
    
    if (message is Message) {
      // 将新的Message转换为LegacyMessage
      legacyMessage = _convertToLegacyMessage(message as Message);
    } else if (message is LegacyMessage) {
      legacyMessage = message as LegacyMessage;
    } else {
      // 处理其他类型的消息（向后兼容）
      legacyMessage = _createFallbackLegacyMessage();
    }

    // 注意：ChatMessageView期望的是旧版Message类型，但我们传递的是LegacyMessage
    // 这里需要创建一个兼容的Message对象
    // 暂时使用dynamic类型来避免类型检查问题
    return ChatMessageView(
      message: legacyMessage as dynamic,
      onEdit: onEdit,
      onRegenerate: onRegenerate,
      isWelcomeMessage: isWelcomeMessage,
    );
  }

  /// 将新的Message转换为LegacyMessage
  LegacyMessage _convertToLegacyMessage(Message newMessage) {
    // 提取主要文本内容
    String content = '';
    String? thinkingContent;
    
    for (final block in newMessage.blocks) {
      switch (block.type) {
        case MessageBlockType.mainText:
          content = block.content ?? '';
          break;
        case MessageBlockType.thinking:
          thinkingContent = block.content;
          break;
        case MessageBlockType.error:
          content += '\n\n❌ 错误: ${block.content ?? ''}';
          break;
        case MessageBlockType.code:
          final language = block.language ?? '';
          content += '\n\n```$language\n${block.content ?? ''}\n```';
          break;
        case MessageBlockType.tool:
          final toolName = block.toolName ?? '工具';
          content += '\n\n🔧 $toolName: ${block.content ?? ''}';
          break;
        case MessageBlockType.image:
          content += '\n\n🖼️ [图片: ${block.content ?? ''}]';
          break;
        case MessageBlockType.file:
          content += '\n\n📎 [文件: ${block.content ?? ''}]';
          break;
        case MessageBlockType.citation:
          content += '\n\n📚 引用: ${block.content ?? ''}';
          break;
        case MessageBlockType.translation:
          content += '\n\n🌐 翻译: ${block.content ?? ''}';
          break;
        case MessageBlockType.unknown:
          content += '\n\n❓ 未知内容: ${block.content ?? ''}';
          break;
      }
    }

    // 如果有思考过程，添加到内容前面
    if (thinkingContent != null && thinkingContent.isNotEmpty) {
      content = '<think>$thinkingContent</think>\n\n$content';
    }

    // 转换状态
    LegacyMessageStatus legacyStatus;
    switch (newMessage.status) {
      case new_status.MessageStatus.userSuccess:
        legacyStatus = LegacyMessageStatus.normal;
        break;
      case new_status.MessageStatus.aiProcessing:
        legacyStatus = LegacyMessageStatus.streaming;
        break;
      case new_status.MessageStatus.aiPending:
        legacyStatus = LegacyMessageStatus.sending;
        break;
      case new_status.MessageStatus.aiSuccess:
        legacyStatus = LegacyMessageStatus.normal;
        break;
      case new_status.MessageStatus.aiError:
        legacyStatus = LegacyMessageStatus.error;
        break;
      case new_status.MessageStatus.aiPaused:
        legacyStatus = LegacyMessageStatus.failed;
        break;
      case new_status.MessageStatus.system:
        legacyStatus = LegacyMessageStatus.system;
        break;
      case new_status.MessageStatus.temporary:
        legacyStatus = LegacyMessageStatus.temporary;
        break;
    }

    return LegacyMessage(
      id: newMessage.id,
      author: newMessage.isFromUser ? 'User' : 'Assistant',
      content: content,
      timestamp: newMessage.createdAt,
      isFromUser: newMessage.isFromUser,
      status: legacyStatus,
      metadata: _convertMetadata(newMessage.metadata),
    );
  }

  /// 转换元数据
  MessageMetadata? _convertMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null) return null;

    final usage = metadata['usage'] as Map<String, dynamic>?;
    final duration = metadata['duration'] as int?;

    return MessageMetadata(
      totalDurationMs: duration,
      tokenUsage: usage != null ? TokenUsage(
        totalTokens: usage['totalTokens'] as int? ?? 0,
        promptTokens: usage['promptTokens'] as int? ?? 0,
        completionTokens: usage['completionTokens'] as int? ?? 0,
      ) : null,
      hasThinking: metadata['hasThinking'] as bool? ?? false,
      hasToolCalls: metadata['hasToolCalls'] as bool? ?? false,
    );
  }

  /// 创建回退的LegacyMessage
  LegacyMessage _createFallbackLegacyMessage() {
    return LegacyMessage(
      author: 'System',
      content: '消息格式不兼容',
      timestamp: DateTime.now(),
      isFromUser: false,
      status: LegacyMessageStatus.error,
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

  final dynamic message;
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
