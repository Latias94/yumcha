import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/chat_message_content.dart';
import '../../domain/services/message_processor.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';
import '../../../../shared/presentation/providers/providers.dart';
import '../providers/chat_message_notifier.dart';
import 'widgets/chat_history_view.dart';
import 'widgets/chat_input.dart';

/// 重构后的聊天视图组件 - 使用纯 Riverpod 状态管理
///
/// 遵循 Riverpod 最佳实践：
/// - 🎯 单一数据源：所有状态通过 ChatMessageNotifier 管理
/// - 🔗 依赖注入：通过 Provider 获取依赖
/// - 📝 清晰的职责分离：UI 只负责展示，状态管理交给 Notifier
/// - ⚠️ 统一的错误处理：错误状态统一管理
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

  @override
  void initState() {
    super.initState();

    // 初始化消息列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.messages.isNotEmpty) {
        ref
            .read(chatMessageNotifierProvider(widget.conversationId).notifier)
            .initializeMessages(widget.messages);
      }
    });
  }

  @override
  void didUpdateWidget(ChatView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果消息列表发生变化，更新状态
    if (widget.messages != oldWidget.messages) {
      ref
          .read(chatMessageNotifierProvider(widget.conversationId).notifier)
          .initializeMessages(widget.messages);
    }
  }

  @override
  void dispose() {
    // Riverpod 会自动清理 Provider 状态
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin

    // 监听聊天消息状态
    final chatState =
        ref.watch(chatMessageNotifierProvider(widget.conversationId));
    final assistantsAsync = ref.watch(aiAssistantNotifierProvider);
    final providersAsync = ref.watch(aiProviderNotifierProvider);

    return assistantsAsync.when(
      data: (assistants) {
        return providersAsync.when(
          data: (providers) {
            return Column(
              children: [
                // 错误提示横幅
                if (chatState.error != null)
                  _buildErrorBanner(chatState.error!),

                // 聊天历史
                Expanded(
                  child: ChatHistoryView(
                    conversationId: widget.conversationId,
                    onEditMessage:
                        !chatState.hasStreamingMessage ? _onEditMessage : null,
                    onRegenerateMessage: !chatState.hasStreamingMessage
                        ? _onRegenerateMessage
                        : null,
                    onSelectSuggestion: _onSelectSuggestion,
                    initialMessageId: widget.initialMessageId,
                    isLoading: chatState.isLoading,
                    isStreaming: chatState.hasStreamingMessage,
                    welcomeMessage: widget.welcomeMessage,
                    suggestions: widget.suggestions,
                  ),
                ),

                // 聊天输入
                ChatInput(
                  initialMessage: _editingMessage,
                  autofocus: widget.suggestions.isEmpty,
                  onSendMessage: _onSendMessageRequest,
                  onCancelMessage: chatState.hasStreamingMessage
                      ? () => ref
                          .read(
                              chatMessageNotifierProvider(widget.conversationId)
                                  .notifier)
                          .cancelStreaming()
                      : null,
                  onCancelEdit: _editingMessage != null ? _onCancelEdit : null,
                  isLoading: chatState.isLoading,
                  onAssistantChanged: (assistant) {
                    // 临时修复：助手不再关联提供商和模型
                    // TODO: 实现新的助手选择逻辑
                  },
                  initialAssistantId: widget.assistantId,
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text('加载提供商失败: $error'),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text('加载助手失败: $error'),
          ],
        ),
      ),
    );
  }

  /// 构建错误横幅
  Widget _buildErrorBanner(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.red.shade100,
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ref
                  .read(chatMessageNotifierProvider(widget.conversationId)
                      .notifier)
                  .clearError();
            },
          ),
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
        if (result.attachments != null && result.attachments!.isNotEmpty) {
          NotificationService()
              .showInfo('已处理 ${result.attachments!.length} 个附件');
        }
      } else {
        NotificationService().showError(result.error ?? '消息处理失败');
      }
    } catch (e) {
      NotificationService().showError('消息处理异常: $e');
    }
  }

  Future<void> _onSendMessage(String content) async {
    if (content.trim().isEmpty) {
      NotificationService().showWarning('请输入消息内容');
      return;
    }

    // 获取助手信息以确定是否使用流式输出
    final assistantsAsync = ref.read(aiAssistantNotifierProvider);
    bool isStreaming = true; // 默认使用流式输出

    assistantsAsync.whenData((assistants) {
      final assistant =
          assistants.where((a) => a.id == widget.assistantId).firstOrNull;
      if (assistant != null) {
        isStreaming = assistant.streamOutput;
      }
    });

    // 如果是编辑模式，处理编辑逻辑
    if (_editingMessage != null) {
      _handleEditMessage(content);
      return;
    }

    try {
      // 使用新的 ChatMessageNotifier 发送消息
      await ref
          .read(chatMessageNotifierProvider(widget.conversationId).notifier)
          .sendMessage(
            content: content,
            assistantId: widget.assistantId,
            providerId: widget.selectedProviderId,
            modelName: widget.selectedModelName,
            isStreaming: isStreaming,
          );

      // 通知消息变化（用于回调）
      _notifyMessagesChanged();
    } catch (e) {
      NotificationService().showError('发送消息失败: $e');
    }
  }

  void _handleEditMessage(String content) {
    // 删除正在编辑的消息和相关的AI回复
    if (_editingMessage != null) {
      ref
          .read(chatMessageNotifierProvider(widget.conversationId).notifier)
          .deleteMessage(_editingMessage!);
    }

    if (_originalAssistantMessage != null) {
      ref
          .read(chatMessageNotifierProvider(widget.conversationId).notifier)
          .deleteMessage(_originalAssistantMessage!);
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
    final chatState =
        ref.read(chatMessageNotifierProvider(widget.conversationId));

    // 找到对应的AI回复消息
    final messageIndex = chatState.messages.indexOf(message);
    Message? associatedResponse;

    if (messageIndex != -1 && messageIndex < chatState.messages.length - 1) {
      final nextMessage = chatState.messages[messageIndex + 1];
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
    final chatState =
        ref.read(chatMessageNotifierProvider(widget.conversationId));

    // 找到对应的用户消息
    final messageIndex = chatState.messages.indexOf(aiMessage);
    if (messageIndex <= 0) return; // AI消息应该不是第一条消息

    final userMessage = chatState.messages[messageIndex - 1];
    if (!userMessage.isFromUser) return;

    // 删除当前的AI消息
    ref
        .read(chatMessageNotifierProvider(widget.conversationId).notifier)
        .deleteMessage(aiMessage);

    // 获取助手信息以确定是否使用流式输出
    final assistantsAsync = ref.read(aiAssistantNotifierProvider);
    bool isStreaming = true; // 默认使用流式输出

    assistantsAsync.whenData((assistants) {
      final assistant =
          assistants.where((a) => a.id == widget.assistantId).firstOrNull;
      if (assistant != null) {
        isStreaming = assistant.streamOutput;
      }
    });

    try {
      // 重新发送消息
      await ref
          .read(chatMessageNotifierProvider(widget.conversationId).notifier)
          .sendMessage(
            content: userMessage.content,
            assistantId: widget.assistantId,
            providerId: widget.selectedProviderId,
            modelName: widget.selectedModelName,
            isStreaming: isStreaming,
          );

      // 通知消息变化
      _notifyMessagesChanged();
    } catch (e) {
      NotificationService().showError('重新生成失败: $e');
    }
  }

  void _notifyMessagesChanged() {
    // 获取当前消息状态
    final chatState =
        ref.read(chatMessageNotifierProvider(widget.conversationId));
    widget.onMessagesChanged?.call(chatState.messages);

    // 检查是否有新的 AI 消息，如果有则触发标题生成
    _checkForNewAiMessage();
  }

  /// 检查是否有新的 AI 消息并触发标题生成
  void _checkForNewAiMessage() {
    final chatState =
        ref.read(chatMessageNotifierProvider(widget.conversationId));
    if (chatState.messages.isEmpty) return;

    // 获取最后一条消息
    final lastMessage = chatState.messages.last;

    // 如果最后一条消息是 AI 消息，触发标题生成检查
    if (!lastMessage.isFromUser && lastMessage.content.isNotEmpty) {
      // 使用 Riverpod 获取 conversation notifier 并调用标题生成
      final conversationNotifier = ref.read(
        currentConversationProvider.notifier,
      );
      conversationNotifier.onAiMessageAdded(lastMessage);
    }
  }
}
