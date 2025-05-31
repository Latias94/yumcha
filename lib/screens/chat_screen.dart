import 'package:flutter/material.dart';
import '../components/message_bubble.dart';
import '../components/chat_input.dart';
import '../models/conversation_ui_state.dart';
import '../models/message.dart';
import '../services/ai_service.dart';
import '../services/notification_service.dart';

// 简单的会话包装类
class Conversation {
  final ConversationUiState uiState;
  final List<Message> messages;

  Conversation({required this.uiState, List<Message>? messages})
    : messages = messages ?? [];
}

class ChatScreen extends StatefulWidget {
  final ConversationUiState conversationState;
  final bool showAppBar;

  const ChatScreen({
    super.key,
    required this.conversationState,
    this.showAppBar = true,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final AiService _aiService = AiService();

  bool _isLoading = false;
  bool _isStreaming = false;
  String? _currentRequestId;
  late Conversation _conversation;

  @override
  void initState() {
    super.initState();
    _conversation = Conversation(
      uiState: widget.conversationState,
      messages: List.from(widget.conversationState.messages),
    );
    // 初始化AI服务
    _aiService.initialize();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // 如果页面销毁时还在生成，停止生成
    if (_currentRequestId != null) {
      _aiService.stopGeneration(_currentRequestId!);
    }
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _isStreaming = false;
      _currentRequestId = 'req_${DateTime.now().millisecondsSinceEpoch}';
    });

    // 添加用户消息
    final userMessage = Message(
      content: content,
      timestamp: DateTime.now(),
      isFromUser: true,
      author: "你",
    );

    setState(() {
      _conversation.messages.add(userMessage);
    });

    _scrollToBottom();

    try {
      // 获取当前助手
      final assistants = _aiService.assistants;
      final currentAssistant = assistants.isNotEmpty
          ? assistants.firstWhere(
              (a) => a.id == _conversation.uiState.assistantId,
              orElse: () => assistants.first,
            )
          : null;

      if (currentAssistant == null) {
        throw Exception('没有可用的AI助手，请先在设置中配置');
      }

      // 创建AI消息（用于流式更新）
      var aiMessageContent = '';
      final aiMessage = Message(
        content: aiMessageContent,
        timestamp: DateTime.now(),
        isFromUser: false,
        author: currentAssistant.name,
      );

      setState(() {
        _conversation.messages.add(aiMessage);
        _isStreaming = true;
      });

      _scrollToBottom();

      // 发送流式请求
      final stream = _aiService.sendMessageStream(
        assistantId: currentAssistant.id,
        chatHistory: _conversation.messages
            .where((m) => m != aiMessage) // 排除当前AI消息
            .toList(),
        userMessage: content,
      );

      await for (final chunk in stream) {
        // 检查是否被停止
        if (_currentRequestId == null) {
          break;
        }

        setState(() {
          aiMessageContent += chunk;
          // 更新AI消息内容
          final index = _conversation.messages.indexOf(aiMessage);
          if (index != -1) {
            _conversation.messages[index] = aiMessage.copyWith(
              content: aiMessageContent,
            );
          }
        });
        _scrollToBottom();
      }
    } catch (e) {
      // 错误处理
      String errorMessage = '发送消息失败';
      if (e.toString().contains('cancelled')) {
        errorMessage = '消息发送已取消';
      } else if (e.toString().contains('timeout')) {
        errorMessage = '请求超时，请检查网络连接';
      }

      NotificationService().showError(errorMessage);

      // 添加错误消息到聊天
      final errorMsg = Message(
        content: '[错误] $errorMessage',
        timestamp: DateTime.now(),
        isFromUser: false,
        author: "系统",
      );

      setState(() {
        _conversation.messages.add(errorMsg);
      });

      _scrollToBottom();
    } finally {
      setState(() {
        _isLoading = false;
        _isStreaming = false;
        _currentRequestId = null;
      });
    }
  }

  void _stopGeneration() {
    if (_currentRequestId != null) {
      _aiService.stopGeneration(_currentRequestId!);
      setState(() {
        _isLoading = false;
        _isStreaming = false;
        _currentRequestId = null;
      });
      NotificationService().showInfo('已停止生成');
    }
  }

  void _showAssistantSelector() {
    final assistants = _aiService.assistants;
    if (assistants.isEmpty) {
      NotificationService().showWarning('没有可用的AI助手，请先在设置中配置');
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('选择AI助手', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ...assistants.map((assistant) {
                final isSelected =
                    assistant.id == _conversation.uiState.assistantId;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(assistant.avatar),
                    onBackgroundImageError: (_, __) {},
                    child: assistant.avatar.isEmpty
                        ? const Icon(Icons.smart_toy)
                        : null,
                  ),
                  title: Text(assistant.name),
                  subtitle: Text(assistant.description),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      _conversation.uiState.copyWith(assistantId: assistant.id);
                    });
                    Navigator.pop(context);
                    NotificationService().showSuccess('已切换到${assistant.name}');
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.smart_toy),
                title: const Text('选择助手'),
                onTap: () {
                  Navigator.pop(context);
                  _showAssistantSelector();
                },
              ),
              ListTile(
                leading: const Icon(Icons.clear_all),
                title: const Text('清空对话'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _conversation.messages.clear();
                  });
                  NotificationService().showSuccess('对话已清空');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前助手信息
    final assistants = _aiService.assistants;
    final currentAssistant = assistants.isNotEmpty
        ? assistants.firstWhere(
            (a) => a.id == _conversation.uiState.assistantId,
            orElse: () => assistants.first,
          )
        : null;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(currentAssistant?.name ?? '聊天'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: _showMenu,
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: _conversation.messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _conversation.messages.length,
                    itemBuilder: (context, index) {
                      final message = _conversation.messages[index];
                      final isLastMessage =
                          index == _conversation.messages.length - 1;
                      final showStreaming =
                          isLastMessage && !message.isFromUser && _isStreaming;

                      return MessageBubble(
                        message: message,
                        isStreaming: showStreaming,
                        showAvatar: false, // 默认不显示头像
                        showAuthor: false, // 默认不显示作者名
                      );
                    },
                  ),
          ),
          ChatInput(
            onSendMessage: _sendMessage,
            isLoading: _isLoading,
            onStopGeneration: _stopGeneration,
            canStop: _isStreaming && _currentRequestId != null,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            '开始对话',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '在下方输入框中输入消息开始与AI聊天',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
