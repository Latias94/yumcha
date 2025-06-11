import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ai_management/domain/entities/ai_assistant.dart';
import '../../domain/entities/message.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';
import '../../../../shared/presentation/providers/providers.dart';
import '../providers/chat_configuration_notifier.dart';
import 'chat_view_model.dart';
import 'chat_view_model_provider.dart';
import 'stream_response.dart';
import 'widgets/chat_history_view.dart';
import 'widgets/chat_input.dart';

/// 主要的聊天视图组件
class ChatView extends ConsumerStatefulWidget {
  const ChatView({
    super.key,
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

  /// 助手ID
  final String assistantId;

  /// 选择的提供商ID
  final String selectedProviderId;

  /// 选择的模型名称
  final String selectedModelName;

  /// 消息列表
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

  late List<Message> _messages;

  // 流式响应相关
  StreamResponse? _pendingStreamResponse;
  Message? _streamingMessage;

  // 编辑相关
  Message? _editingMessage;
  Message? _originalAssistantMessage;

  // 状态
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.messages);
  }

  @override
  void didUpdateWidget(ChatView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages != oldWidget.messages) {
      _messages = List.from(widget.messages);
    }
  }

  @override
  void dispose() {
    _pendingStreamResponse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin

    final assistantsAsync = ref.watch(aiAssistantNotifierProvider);
    final providersAsync = ref.watch(aiProviderNotifierProvider);

    return assistantsAsync.when(
      data: (assistants) {
        return providersAsync.when(
          data: (providers) {
            final assistant =
                assistants.where((a) => a.id == widget.assistantId).firstOrNull;
            final provider = providers
                .where((p) => p.id == widget.selectedProviderId)
                .firstOrNull;

            final viewModel = ChatViewModel(
              assistantId: widget.assistantId,
              selectedProviderId: widget.selectedProviderId,
              selectedModelName: widget.selectedModelName,
              messages: _messages,
              currentAssistant: assistant,
              currentProvider: provider,
              welcomeMessage: widget.welcomeMessage,
              suggestions: widget.suggestions,
            );

            return ChatViewModelProvider(
              viewModel: viewModel,
              child: Column(
                children: [
                  // 聊天历史
                  Expanded(
                    child: ChatHistoryView(
                      onEditMessage: _pendingStreamResponse == null
                          ? _onEditMessage
                          : null,
                      onRegenerateMessage: _pendingStreamResponse == null
                          ? _onRegenerateMessage
                          : null,
                      onSelectSuggestion: _onSelectSuggestion,
                      initialMessageId: widget.initialMessageId,
                      isLoading: _isLoading,
                      isStreaming: _pendingStreamResponse != null,
                    ),
                  ),

                  // 聊天输入
                  ChatInput(
                    initialMessage: _editingMessage,
                    autofocus: widget.suggestions.isEmpty,
                    onSendMessage: _onSendMessage,
                    onCancelMessage: _pendingStreamResponse?.cancel,
                    onCancelEdit:
                        _editingMessage != null ? _onCancelEdit : null,
                    isLoading: _isLoading,
                    onAssistantChanged: (assistant) {
                      // 临时修复：助手不再关联提供商和模型
                      // TODO: 实现新的助手选择逻辑
                    },
                    initialAssistantId: widget.assistantId,
                  ),
                ],
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

  void _onSelectSuggestion(String suggestion) {
    _onSendMessage(suggestion);
  }

  Future<void> _onSendMessage(String content) async {
    if (content.trim().isEmpty) {
      NotificationService().showWarning('请输入消息内容');
      return;
    }

    // 使用 Riverpod 获取助手信息
    final assistantsAsync = ref.read(aiAssistantNotifierProvider);
    AiAssistant? assistant;

    assistantsAsync.whenData((assistants) {
      assistant =
          assistants.where((a) => a.id == widget.assistantId).firstOrNull;
    });

    if (assistant == null) {
      NotificationService().showError('找不到助手配置');
      return;
    }

    // 如果是编辑模式，处理编辑逻辑
    if (_editingMessage != null) {
      _handleEditMessage(content, assistant!);
      return;
    }

    // 添加用户消息
    final userMessage = Message(
      content: content,
      timestamp: DateTime.now(),
      isFromUser: true,
      author: "你",
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    // 立即保存用户消息到数据库
    _notifyMessagesChanged();

    try {
      if (assistant!.streamOutput) {
        await _handleStreamMessage(userMessage, assistant!);
        // 流式消息的 _isLoading 状态由 _handleStreamMessage 内部管理
      } else {
        await _handleNormalMessage(userMessage, assistant!);
        // 非流式消息完成后重置加载状态
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _handleError(e);
      // 发生异常时重置加载状态
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleEditMessage(String content, AiAssistant assistant) {
    // 移除原来的用户消息和AI回复
    if (_originalAssistantMessage != null) {
      _messages.remove(_originalAssistantMessage!);
    }
    final editingIndex = _messages.indexOf(_editingMessage!);
    if (editingIndex != -1) {
      _messages.removeAt(editingIndex);
    }

    setState(() {
      _editingMessage = null;
      _originalAssistantMessage = null;
    });

    // 重新发送更新后的消息
    _onSendMessage(content);
  }

  Future<void> _handleStreamMessage(
    Message userMessage,
    AiAssistant assistant,
  ) async {
    // 创建占位AI消息
    final aiMessage = Message(
      content: '',
      timestamp: DateTime.now(),
      isFromUser: false,
      author: assistant.name,
    );

    setState(() {
      _messages.add(aiMessage);
      _streamingMessage = aiMessage;
      // 确保在流式响应期间保持加载状态
      _isLoading = true;
    });

    // 注意：这里不调用 _notifyMessagesChanged()，避免保存空的AI消息到数据库

    try {
      // 获取当前的聊天配置
      final chatConfig = ref.read(chatConfigurationProvider);
      final providerId =
          chatConfig.selectedProvider?.id ?? widget.selectedProviderId;
      final modelName =
          chatConfig.selectedModel?.name ?? widget.selectedModelName;

      // 使用新的智能流式聊天Provider
      final params = SmartChatParams(
        chatHistory: _messages.where((m) => m != aiMessage).toList(),
        userMessage: userMessage.content,
        assistantId: widget.assistantId,
        providerId: providerId,
        modelName: modelName,
      );

      // 使用传统的流式监听方式
      final chatService = ref.read(aiChatServiceProvider);
      final provider = ref.read(aiProviderProvider(providerId));
      final assistant = ref.read(aiAssistantProvider(widget.assistantId));

      if (provider == null || assistant == null) {
        throw Exception('Provider or assistant not found');
      }

      final stream = chatService.sendMessageStream(
        provider: provider,
        assistant: assistant,
        modelName: modelName,
        chatHistory: params.chatHistory,
        userMessage: params.userMessage,
      );

      _pendingStreamResponse = StreamResponse(
        stream: stream,
        onUpdate: () {
          setState(() {
            // 更新流式消息内容
            if (_streamingMessage != null) {
              final updatedMessage = Message(
                content: _pendingStreamResponse!.fullContent,
                timestamp: _streamingMessage!.timestamp,
                isFromUser: false,
                author: _streamingMessage!.author,
                duration: _pendingStreamResponse!.duration,
              );

              final index = _messages.indexOf(_streamingMessage!);
              if (index != -1) {
                _messages[index] = updatedMessage;
                _streamingMessage = updatedMessage;
              }
            }
          });
        },
        onDone: (error) {
          // 如果有错误，先处理错误消息
          if (error != null) {
            NotificationService().showError('请求失败: $error');

            // 如果有流式消息，添加错误标记
            if (_streamingMessage != null) {
              final errorMessage = Message(
                content: '[错误] $error',
                timestamp: _streamingMessage!.timestamp,
                isFromUser: false,
                author: _streamingMessage!.author,
              );

              final index = _messages.indexOf(_streamingMessage!);
              if (index != -1) {
                setState(() {
                  _messages[index] = errorMessage;
                });
              }
            }
          }

          // 清空状态变量
          setState(() {
            _pendingStreamResponse = null;
            _streamingMessage = null;
            _isLoading = false;
          });

          // 只在流式响应完成时通知消息变化（无论成功还是失败）
          _notifyMessagesChanged();
        },
      );
    } catch (e) {
      setState(() {
        _pendingStreamResponse = null;
        _streamingMessage = null;
        _isLoading = false; // 确保在异常时也重置加载状态
      });
      rethrow;
    }
  }

  Future<void> _handleNormalMessage(
    Message userMessage,
    AiAssistant assistant,
  ) async {
    // 获取当前的聊天配置
    final chatConfig = ref.read(chatConfigurationProvider);
    final providerId =
        chatConfig.selectedProvider?.id ?? widget.selectedProviderId;
    final modelName =
        chatConfig.selectedModel?.name ?? widget.selectedModelName;

    // 使用新的智能聊天Provider
    final params = SmartChatParams(
      chatHistory: _messages,
      userMessage: userMessage.content,
      assistantId: widget.assistantId,
      providerId: providerId,
      modelName: modelName,
    );

    try {
      final response = await ref.read(smartChatProvider(params).future);

      if (response.isSuccess) {
        final aiMessage = Message(
          content: response.content,
          timestamp: DateTime.now(),
          isFromUser: false,
          author: assistant.name,
          duration: response.duration,
        );

        setState(() {
          _messages.add(aiMessage);
        });

        _notifyMessagesChanged();
      } else {
        NotificationService().showError(response.error ?? '请求失败');
      }
    } catch (e) {
      NotificationService().showError('请求失败: $e');
    }
  }

  void _onEditMessage(Message message) {
    if (!message.isFromUser) return;

    // 找到对应的AI回复消息
    final messageIndex = _messages.indexOf(message);
    Message? associatedResponse;

    if (messageIndex != -1 && messageIndex < _messages.length - 1) {
      final nextMessage = _messages[messageIndex + 1];
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
    // 恢复原来的消息
    if (_editingMessage != null && _originalAssistantMessage != null) {
      if (!_messages.contains(_editingMessage!)) {
        _messages.add(_editingMessage!);
      }
      if (!_messages.contains(_originalAssistantMessage!)) {
        _messages.add(_originalAssistantMessage!);
      }
      _notifyMessagesChanged();
    }

    setState(() {
      _editingMessage = null;
      _originalAssistantMessage = null;
    });
  }

  void _onRegenerateMessage(Message aiMessage) async {
    if (aiMessage.isFromUser) return;

    // 找到对应的用户消息
    final messageIndex = _messages.indexOf(aiMessage);
    if (messageIndex <= 0) return; // AI消息应该不是第一条消息

    final userMessage = _messages[messageIndex - 1];
    if (!userMessage.isFromUser) return;

    // 移除当前的AI消息
    setState(() {
      _messages.removeAt(messageIndex);
      _isLoading = true;
    });

    // 使用 Riverpod 获取助手信息
    final assistantsAsync = ref.read(aiAssistantNotifierProvider);
    AiAssistant? assistant;

    assistantsAsync.whenData((assistants) {
      assistant =
          assistants.where((a) => a.id == widget.assistantId).firstOrNull;
    });

    if (assistant == null) {
      NotificationService().showError('找不到助手配置');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // 重新发送消息
    if (assistant!.streamOutput) {
      await _handleStreamMessage(userMessage, assistant!);
      // 流式消息的 _isLoading 状态由 _handleStreamMessage 内部管理
    } else {
      await _handleNormalMessage(userMessage, assistant!);
      // 非流式消息完成后重置加载状态
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleError(Object error) {
    NotificationService().showError('请求失败: $error');

    // 如果有流式消息，添加错误标记
    if (_streamingMessage != null) {
      final errorMessage = Message(
        content: '[错误] $error',
        timestamp: _streamingMessage!.timestamp,
        isFromUser: false,
        author: _streamingMessage!.author,
      );

      final index = _messages.indexOf(_streamingMessage!);
      if (index != -1) {
        _messages[index] = errorMessage;
        _notifyMessagesChanged();
      }
    }
  }

  void _notifyMessagesChanged() {
    widget.onMessagesChanged?.call(_messages);

    // 检查是否有新的 AI 消息，如果有则触发标题生成
    _checkForNewAiMessage();
  }

  /// 检查是否有新的 AI 消息并触发标题生成
  void _checkForNewAiMessage() {
    if (_messages.isEmpty) return;

    // 获取最后一条消息
    final lastMessage = _messages.last;

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
