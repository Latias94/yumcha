import 'package:flutter/material.dart';
import '../chat_view_model_provider.dart';
import '../../../domain/entities/message.dart';
import 'chat_message_view.dart';
import 'chat_suggestions_view.dart';
import 'ai_thinking_indicator.dart';

/// 聊天历史显示组件
class ChatHistoryView extends StatefulWidget {
  const ChatHistoryView({
    super.key,
    this.onEditMessage,
    this.onRegenerateMessage,
    required this.onSelectSuggestion,
    this.initialMessageId,
    this.isLoading = false,
    this.isStreaming = false,
  });

  /// 编辑消息回调
  final void Function(Message message)? onEditMessage;

  /// 重新生成消息回调
  final void Function(Message message)? onRegenerateMessage;

  /// 选择建议回调
  final void Function(String suggestion) onSelectSuggestion;

  /// 初始要定位的消息ID
  final String? initialMessageId;

  /// 是否正在加载
  final bool isLoading;

  /// 是否为流式响应
  final bool isStreaming;

  @override
  State<ChatHistoryView> createState() => _ChatHistoryViewState();
}

class _ChatHistoryViewState extends State<ChatHistoryView> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToMessage = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

    // 处理消息定位
    if (widget.initialMessageId != null &&
        !_hasScrolledToMessage &&
        displayMessages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToMessage(widget.initialMessageId!, displayMessages);
      });
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
      child: Column(
        children: [
          // 消息列表
          Expanded(
            child: displayMessages.isEmpty && !showSuggestions
                ? _buildEmptyState(context)
                : ListView.builder(
                    controller: _scrollController,
                    reverse: false, // 正常顺序显示，新消息在下面
                    itemCount: displayMessages.length +
                        (showSuggestions ? 1 : 0) +
                        (widget.isLoading ? 1 : 0), // 为AI思考指示器添加额外项
                    itemBuilder: (context, index) {
                      // 如果是AI思考指示器
                      if (widget.isLoading &&
                          index ==
                              displayMessages.length +
                                  (showSuggestions ? 1 : 0)) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: AiThinkingIndicator(
                            isStreaming: widget.isStreaming,
                            message:
                                widget.isStreaming ? '正在接收回复...' : 'AI正在思考中...',
                          ),
                        );
                      }

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
                      final canEdit = !isWelcomeMessage &&
                          message.isFromUser &&
                          widget.onEditMessage != null &&
                          index == displayMessages.length - 1;

                      // 判断是否可以重新生成（只有最后一条AI消息可以重新生成）
                      final canRegenerate = !isWelcomeMessage &&
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
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 主图标 - 使用渐变效果
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                    theme.colorScheme.secondary.withValues(alpha: 0.6),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 40,
                color: theme.colorScheme.onPrimary,
              ),
            ),

            const SizedBox(height: 24),

            // 主标题
            Text(
              '开始新的对话',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            // 副标题
            Text(
              '在下方输入消息开始与AI助手对话\n体验智能、流畅的AI交互',
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // 功能提示卡片
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '小贴士',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• 支持多种AI模型切换\n• 实时流式响应体验\n• 智能思考过程展示',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToMessage(String messageId, List<Message> displayMessages) {
    // 查找目标消息的索引
    final targetIndex = displayMessages.indexWhere(
      (message) => message.id == messageId,
    );

    if (targetIndex != -1) {
      // 计算滚动位置（每个消息项大概的高度）
      const double estimatedItemHeight = 100.0; // 估算的消息项高度
      final double targetOffset = targetIndex * estimatedItemHeight;

      // 滚动到目标位置
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      setState(() {
        _hasScrolledToMessage = true;
      });
    }
  }
}
