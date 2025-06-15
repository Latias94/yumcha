import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/chat_message_content.dart';
import '../../domain/entities/chat_state.dart';
import '../../domain/services/message_processor.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';
import '../../../../shared/presentation/providers/providers.dart';
import '../providers/unified_chat_notifier.dart';
import 'widgets/chat_history_view.dart';
import 'widgets/chat_input.dart';

/// 重构后的聊天视图组件 - 使用统一聊天状态管理
///
/// 遵循 Riverpod 最佳实践：
/// - 🎯 单一数据源：所有状态通过 UnifiedChatNotifier 管理
/// - 🔗 依赖注入：通过 Provider 获取依赖
/// - 📝 清晰的职责分离：UI 只负责展示，状态管理交给 Notifier
/// - ⚠️ 统一的错误处理：错误状态统一管理
/// - 🔄 事件驱动：使用事件系统处理状态变化
class ChatView extends ConsumerStatefulWidget {
  const ChatView({
    super.key,
    required this.conversationId,
    required this.assistantId,
    required this.selectedProviderId,
    required this.selectedModelName,
    this.messages = const [],
    this.welcomeMessage,
    this.suggestions = const [],
    this.onMessagesChanged,
    this.onProviderModelChanged,
    this.initialMessageId,
  });

  /// 对话ID - 用于状态管理
  final String conversationId;

  /// 助手ID
  final String assistantId;

  /// 选择的提供商ID
  final String selectedProviderId;

  /// 选择的模型名称
  final String selectedModelName;

  /// 初始消息列表
  final List<Message> messages;

  /// 欢迎消息
  final String? welcomeMessage;

  /// 建议列表
  final List<String> suggestions;

  /// 消息变化回调
  final void Function(List<Message> messages)? onMessagesChanged;

  /// 提供商模型变化回调
  final void Function(String providerId, String modelName)?
      onProviderModelChanged;

  /// 初始要定位的消息ID
  final String? initialMessageId;

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // 编辑相关状态
  Message? _editingMessage;
  Message? _originalAssistantMessage;

  // 跟踪是否已经初始化过消息
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();

    // 使用统一聊天状态管理初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUnifiedChatState();
    });
  }

  @override
  void didUpdateWidget(ChatView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果对话ID发生变化，重置初始化状态
    if (widget.conversationId != oldWidget.conversationId) {
      _hasInitialized = false;
      // 延迟到下一帧执行，避免在Widget构建期间修改Provider状态
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeUnifiedChatState();
      });
    }

    // 如果消息列表发生变化，同步到统一状态
    if (widget.messages != oldWidget.messages &&
        widget.conversationId == oldWidget.conversationId) {
      Future(() {
        _syncMessagesToUnifiedState();
      });
    }
  }

  /// 初始化统一聊天状态
  void _initializeUnifiedChatState() {
    if (!_hasInitialized && mounted) {
      _hasInitialized = true;

      final unifiedChatNotifier = ref.read(unifiedChatProvider.notifier);

      // 加载对话
      if (widget.conversationId.isNotEmpty) {
        unifiedChatNotifier.loadConversation(widget.conversationId);
      }
    }
  }

  /// 同步消息到统一状态
  void _syncMessagesToUnifiedState() {
    // 统一状态管理会自动处理消息同步
    // 这里可以添加额外的同步逻辑如果需要
  }

  @override
  void dispose() {
    // Riverpod 会自动清理 Provider 状态
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin

    // 监听统一聊天状态
    final unifiedChatState = ref.watch(unifiedChatProvider);
    final assistants = ref.watch(aiAssistantsProvider);
    final providers = ref.watch(aiProvidersProvider);

    // 检查数据是否可用
    if (assistants.isEmpty || providers.isEmpty) {
      return const SizedBox.expand(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // 使用 SizedBox.expand 确保在 Scaffold.body 中正确布局
    return SizedBox.expand(
      child: _buildChatContent(unifiedChatState),
    );
  }

  /// 构建聊天内容
  Widget _buildChatContent(UnifiedChatState chatState) {
    return Column(
      children: [
        // 聊天历史
        Expanded(
          child: ChatHistoryView(
            conversationId: widget.conversationId,
            onEditMessage:
                !chatState.messageState.hasStreamingMessages ? _onEditMessage : null,
            onRegenerateMessage:
                !chatState.messageState.hasStreamingMessages ? _onRegenerateMessage : null,
            onSelectSuggestion: _onSelectSuggestion,
            initialMessageId: widget.initialMessageId,
            isLoading: chatState.isLoading,
            isStreaming: chatState.messageState.hasStreamingMessages,
            welcomeMessage: widget.welcomeMessage,
            suggestions: widget.suggestions,
          ),
        ),

        // 聊天输入
        ChatInput(
          initialMessage: _editingMessage,
          autofocus: widget.suggestions.isEmpty,
          onSendMessage: _onSendMessageRequest,
          onCancelMessage: chatState.messageState.hasStreamingMessages
              ? () {
                  if (mounted) {
                    ref.read(unifiedChatProvider.notifier).cancelStreaming();
                  }
                }
              : null,
          onCancelEdit: _editingMessage != null ? _onCancelEdit : null,
          isLoading: chatState.isLoading,
          onAssistantChanged: (assistant) {
            // 使用统一状态管理选择助手
            if (mounted) {
              ref.read(unifiedChatProvider.notifier).selectAssistant(assistant);
            }
          },
          initialAssistantId: widget.assistantId,
          onStartTyping: () {
            // 当用户开始输入时，清除错误状态
            if (mounted) {
              ref.read(unifiedChatProvider.notifier).clearError();
            }
          },
        ),
      ],
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(errorMessage),
        ],
      ),
    );
  }

  void _onSelectSuggestion(String suggestion) {
    _onSendMessage(suggestion);
  }

  /// 处理新的消息请求（支持多模态）
  Future<void> _onSendMessageRequest(ChatMessageRequest request) async {
    // 创建消息处理器管理器
    final processorManager = MessageProcessorManager();

    try {
      // 处理消息请求
      final result = await processorManager.processRequest(request);

      // 检查Widget是否仍然mounted，避免在异步操作后使用已销毁的Widget
      if (!mounted) return;

      if (result.success) {
        // 根据内容类型显示不同的提示
        String contentInfo = '';
        if (request.content is ImageContent) {
          final imageContent = request.content as ImageContent;
          contentInfo = ' [包含图片: ${imageContent.fileName ?? "image"}]';
        } else if (request.content is FileContent) {
          final fileContent = request.content as FileContent;
          contentInfo = ' [包含文件: ${fileContent.fileName}]';
        } else if (request.content is MixedContent) {
          final mixedContent = request.content as MixedContent;
          contentInfo = ' [包含 ${mixedContent.attachmentCount} 个附件]';
        }

        // 使用处理后的文本内容发送消息
        await _onSendMessage(result.processedText + contentInfo);

        // 显示处理结果信息
        if (mounted && result.attachments != null && result.attachments!.isNotEmpty) {
          NotificationService()
              .showInfo('已处理 ${result.attachments!.length} 个附件');
        }
      } else {
        if (mounted) {
          NotificationService().showError(result.error ?? '消息处理失败');
        }
      }
    } catch (e) {
      if (mounted) {
        NotificationService().showError('消息处理异常: $e');
      }
    }
  }

  Future<void> _onSendMessage(String content) async {
    if (content.trim().isEmpty) {
      NotificationService().showWarning('请输入消息内容');
      return;
    }

    // 获取助手信息以确定是否使用流式输出 - 使用新的统一AI管理Provider
    final assistants = ref.read(aiAssistantsProvider);
    bool isStreaming = true; // 默认使用流式输出

    final assistant = assistants.where((a) => a.id == widget.assistantId).firstOrNull;
    if (assistant != null) {
      isStreaming = assistant.streamOutput;
    }

    // 如果是编辑模式，处理编辑逻辑
    if (_editingMessage != null) {
      _handleEditMessage(content);
      return;
    }

    try {
      // 使用统一聊天状态管理发送消息
      await ref
          .read(unifiedChatProvider.notifier)
          .sendMessage(content, useStreaming: isStreaming);

      // 检查Widget是否仍然mounted，避免在Widget销毁后使用ref
      if (mounted) {
        // 通知消息变化（用于回调）
        _notifyMessagesChanged();
      }
    } catch (e) {
      // 检查Widget是否仍然mounted，避免在Widget销毁后显示错误
      if (mounted) {
        NotificationService().showError('发送消息失败: $e');
      }
    }
  }

  void _handleEditMessage(String content) {
    // 使用统一聊天状态管理删除消息
    final unifiedChatNotifier = ref.read(unifiedChatProvider.notifier);

    if (_editingMessage != null) {
      // TODO: 实现删除消息功能
      // unifiedChatNotifier.deleteMessage(_editingMessage!.id);
    }

    if (_originalAssistantMessage != null) {
      // TODO: 实现删除消息功能
      // unifiedChatNotifier.deleteMessage(_originalAssistantMessage!.id);
    }

    setState(() {
      _editingMessage = null;
      _originalAssistantMessage = null;
    });

    // 重新发送更新后的消息
    _onSendMessage(content);
  }

  void _onEditMessage(Message message) {
    if (!message.isFromUser) return;

    // 获取当前消息状态
    final chatState = ref.read(unifiedChatProvider);

    // 找到对应的AI回复消息
    final messageIndex = chatState.messageState.messages.indexOf(message);
    Message? associatedResponse;

    if (messageIndex != -1 && messageIndex < chatState.messageState.messages.length - 1) {
      final nextMessage = chatState.messageState.messages[messageIndex + 1];
      if (!nextMessage.isFromUser) {
        associatedResponse = nextMessage;
      }
    }

    setState(() {
      _editingMessage = message;
      _originalAssistantMessage = associatedResponse;
    });
  }

  void _onCancelEdit() {
    setState(() {
      _editingMessage = null;
      _originalAssistantMessage = null;
    });
  }

  void _onRegenerateMessage(Message aiMessage) async {
    if (aiMessage.isFromUser) return;

    // 获取当前消息状态
    final chatState = ref.read(unifiedChatProvider);
    final unifiedChatNotifier = ref.read(unifiedChatProvider.notifier);

    // 找到AI消息的索引
    final messageIndex = chatState.messageState.messages.indexOf(aiMessage);
    if (messageIndex < 0) return;

    // 获取助手信息以确定是否使用流式输出
    final assistants = ref.read(aiAssistantsProvider);
    bool isStreaming = true; // 默认使用流式输出

    final assistant = assistants.where((a) => a.id == widget.assistantId).firstOrNull;
    if (assistant != null) {
      isStreaming = assistant.streamOutput;
    }

    try {
      // 1. 清除AI消息内容（设为空内容，保持消息结构）
      // TODO: 实现更新消息内容的功能
      // unifiedChatNotifier.updateMessageContent(aiMessage.id!, '');

      // 2. 获取当前聊天上下文（除去要重新生成的AI消息）
      final contextMessages = chatState.messageState.messages
          .take(messageIndex) // 取AI消息之前的所有消息
          .toList();

      // 3. 如果没有上下文消息，不能重新生成
      if (contextMessages.isEmpty) {
        if (mounted) {
          NotificationService().showWarning('没有足够的上下文进行重新生成');
        }
        return;
      }

      // 4. 使用AI消息ID直接重新生成响应
      await unifiedChatNotifier.regenerateResponse(
        aiMessageId: aiMessage.id!,
        useStreaming: isStreaming,
      );

      // 检查Widget是否仍然mounted，避免在Widget销毁后使用ref
      if (mounted) {
        // 通知消息变化
        _notifyMessagesChanged();
      }
    } catch (e) {
      // 检查Widget是否仍然mounted，避免在Widget销毁后显示错误
      if (mounted) {
        NotificationService().showError('重新生成失败: $e');
      }
    }
  }

  void _notifyMessagesChanged() {
    // 检查Widget是否仍然mounted，避免在Widget销毁后使用ref
    if (!mounted) return;

    // 获取当前消息状态
    final chatState = ref.read(unifiedChatProvider);
    widget.onMessagesChanged?.call(chatState.messageState.messages);

    // 检查是否有新的 AI 消息，如果有则触发标题生成
    _checkForNewAiMessage();
  }

  /// 检查是否有新的 AI 消息并触发标题生成
  void _checkForNewAiMessage() {
    // 检查Widget是否仍然mounted，避免在Widget销毁后使用ref
    if (!mounted) return;

    final chatState = ref.read(unifiedChatProvider);
    if (chatState.messageState.messages.isEmpty) return;

    // 获取最后一条消息
    final lastMessage = chatState.messageState.messages.last;

    // 如果最后一条消息是 AI 消息，触发标题生成检查
    if (!lastMessage.isFromUser && lastMessage.content.isNotEmpty) {
      // 使用统一状态管理的事件系统
      // 标题生成会通过事件系统自动处理
    }
  }
}
