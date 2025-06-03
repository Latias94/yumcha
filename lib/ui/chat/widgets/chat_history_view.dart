import 'package:flutter/material.dart';
import '../chat_view_model_provider.dart';
import '../../../models/message.dart';
import 'chat_message_view.dart';
import 'chat_suggestions_view.dart';

/// 聊天历史显示组件
class ChatHistoryView extends StatefulWidget {
  const ChatHistoryView({
    super.key,
    this.onEditMessage,
    this.onRegenerateMessage,
    required this.onSelectSuggestion,
  });

  /// 编辑消息回调
  final void Function(Message message)? onEditMessage;

  /// 重新生成消息回调
  final void Function(Message message)? onRegenerateMessage;

  /// 选择建议回调
  final void Function(String suggestion) onSelectSuggestion;

  @override
  State<ChatHistoryView> createState() => _ChatHistoryViewState();
}

class _ChatHistoryViewState extends State<ChatHistoryView> {
  @override
  Widget build(BuildContext context) {
    final viewModel = ChatViewModelProvider.of(context);
    final messages = viewModel.messages;

    // 准备显示的消息列表（包括欢迎消息）
    final displayMessages = <Message>[];

    // 添加欢迎消息（如果有）
    if (viewModel.welcomeMessage != null && messages.isEmpty) {
      displayMessages.add(
        Message(
          content: viewModel.welcomeMessage!,
          timestamp: DateTime.now(),
          isFromUser: false,
          author: 'AI助手',
        ),
      );
    }

    // 添加实际消息
    displayMessages.addAll(messages);

    // 检查是否显示建议
    final showSuggestions =
        viewModel.suggestions.isNotEmpty && messages.isEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
      child: Column(
        children: [
          // 消息列表
          Expanded(
            child: displayMessages.isEmpty && !showSuggestions
                ? _buildEmptyState(context)
                : ListView.builder(
                    reverse: false, // 正常顺序显示，新消息在下面
                    itemCount:
                        displayMessages.length + (showSuggestions ? 1 : 0),
                    itemBuilder: (context, index) {
                      // 如果是建议区域
                      if (showSuggestions && index == displayMessages.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ChatSuggestionsView(
                            suggestions: viewModel.suggestions,
                            onSelectSuggestion: widget.onSelectSuggestion,
                          ),
                        );
                      }

                      final message = displayMessages[index];
                      final isWelcomeMessage =
                          viewModel.welcomeMessage != null &&
                          messages.isEmpty &&
                          index == 0;

                      // 判断是否可以编辑（只有最后一条用户消息可以编辑）
                      final canEdit =
                          !isWelcomeMessage &&
                          message.isFromUser &&
                          widget.onEditMessage != null &&
                          index == displayMessages.length - 1;

                      // 判断是否可以重新生成（只有最后一条AI消息可以重新生成）
                      final canRegenerate =
                          !isWelcomeMessage &&
                          !message.isFromUser &&
                          widget.onRegenerateMessage != null &&
                          index == displayMessages.length - 1;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ChatMessageView(
                          message: message,
                          isWelcomeMessage: isWelcomeMessage,
                          onEdit: canEdit
                              ? () => widget.onEditMessage?.call(message)
                              : null,
                          onRegenerate: canRegenerate
                              ? () => widget.onRegenerateMessage?.call(message)
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '开始新的对话',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '在下方输入消息开始与AI助手对话',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
