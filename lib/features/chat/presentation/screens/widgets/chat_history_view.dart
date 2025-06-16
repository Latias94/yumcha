import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/message_status.dart' as msg_status;
import '../../providers/unified_chat_notifier.dart';
import '../../widgets/message_view_adapter.dart';
import '../../providers/chat_providers.dart';
import 'chat_suggestions_view.dart';
import '../../../../../shared/presentation/design_system/design_constants.dart';

/// 聊天历史显示组件 - 使用统一聊天状态管理
class ChatHistoryView extends ConsumerStatefulWidget {
  const ChatHistoryView({
    super.key,
    required this.conversationId,
    this.onEditMessage,
    this.onRegenerateMessage,
    required this.onSelectSuggestion,
    this.initialMessageId,
    this.isLoading = false,
    this.isStreaming = false,
    this.welcomeMessage,
    this.suggestions = const [],
  });

  /// 对话ID
  final String conversationId;

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

  /// 欢迎消息
  final String? welcomeMessage;

  /// 建议列表
  final List<String> suggestions;

  @override
  ConsumerState<ChatHistoryView> createState() => _ChatHistoryViewState();
}

class _ChatHistoryViewState extends ConsumerState<ChatHistoryView> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToMessage = false;
  int _previousMessageCount = 0;

  // 滚动状态管理
  bool _isNearBottom = true;
  static const double _bottomThreshold = 100.0; // 距离底部100px内认为是在底部

  // 流式消息滚动管理
  Set<String> _trackedStreamingMessageIds = {};
  String? _lastBottomStreamingMessageId;
  bool _shouldFollowStreaming = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 滚动监听器 - 检测用户滚动行为
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final isAtBottom =
        position.pixels >= position.maxScrollExtent - _bottomThreshold;

    // 更新底部状态
    if (_isNearBottom != isAtBottom) {
      setState(() {
        _isNearBottom = isAtBottom;
      });
    }

    // 检测用户主动滚动（非程序触发的滚动）
    if (position.userScrollDirection != ScrollDirection.idle) {
      // 如果用户滚动离开底部，停止跟随流式消息
      if (!isAtBottom) {
        _shouldFollowStreaming = false;
      } else {
        // 用户滚动回底部，恢复跟随流式消息
        _shouldFollowStreaming = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 监听统一聊天状态
    final messages = ref.watch(chatMessagesProvider);

    // 准备显示的消息列表（包括欢迎消息）
    final displayMessages = <Message>[];

    // 添加欢迎消息（如果有）
    if (widget.welcomeMessage != null && messages.isEmpty) {
      displayMessages.add(
        Message.assistant(
          id: 'welcome_message',
          conversationId: widget.conversationId,
          assistantId: 'system',
          createdAt: DateTime.now(),
        ),
      );
    }

    // 添加实际消息
    displayMessages.addAll(messages);

    // 检查是否显示建议
    final showSuggestions = widget.suggestions.isNotEmpty && messages.isEmpty;

    // 处理消息定位和智能滚动
    if (widget.initialMessageId != null &&
        !_hasScrolledToMessage &&
        displayMessages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToMessage(widget.initialMessageId!, displayMessages);
      });
    } else {
      _handleSmartScrolling(displayMessages, messages);
    }

    // 更新消息计数
    _previousMessageCount = displayMessages.length;

    return Column(
      children: [
        // 顶部间距
        SizedBox(height: DesignConstants.spaceL),

        // 消息列表 - 滚动条贴边，内容通过padding保持间距
        Expanded(
          child: Stack(
            children: [
              displayMessages.isEmpty && !showSuggestions
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: false, // 正常顺序显示，新消息在下面
                      padding: EdgeInsets.zero, // 移除ListView默认padding
                      itemCount:
                          displayMessages.length + (showSuggestions ? 1 : 0),
                      itemBuilder: (context, index) {
                        // 如果是建议区域
                        if (showSuggestions &&
                            index == displayMessages.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: DesignConstants.spaceS,
                              vertical: DesignConstants.spaceS,
                            ),
                            child: ChatSuggestionsView(
                              suggestions: widget.suggestions,
                              onSelectSuggestion: widget.onSelectSuggestion,
                            ),
                          );
                        }

                        final message = displayMessages[index];
                        final isWelcomeMessage =
                            widget.welcomeMessage != null &&
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
                          padding: EdgeInsets.only(
                            left: DesignConstants.spaceS,
                            right: DesignConstants.spaceS,
                            bottom: DesignConstants.spaceS,
                          ),
                          child: _OptimizedMessageItem(
                            key: ValueKey(message.id),
                            message: message,
                            isWelcomeMessage: isWelcomeMessage,
                            canEdit: canEdit,
                            canRegenerate: canRegenerate,
                            onEdit: widget.onEditMessage,
                            onRegenerate: widget.onRegenerateMessage,
                          ),
                        );
                      },
                    ),

              // 回到底部浮动按钮
              if (!_isNearBottom && displayMessages.isNotEmpty)
                _buildScrollToBottomButton(context),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建回到底部浮动按钮
  Widget _buildScrollToBottomButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = DesignConstants.isDesktop(context);

    return Positioned(
      right: DesignConstants.spaceL,
      bottom: DesignConstants.spaceL,
      child: AnimatedOpacity(
        opacity: !_isNearBottom ? 1.0 : 0.0,
        duration: DesignConstants.animationFast,
        child: Material(
          elevation: 4,
          borderRadius: DesignConstants.radiusXL,
          shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.3),
          child: Container(
            width: isDesktop ? 48 : 44,
            height: isDesktop ? 48 : 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: DesignConstants.radiusXL,
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.colorScheme.onPrimaryContainer,
                size: isDesktop ? 24 : 22,
              ),
              onPressed: () {
                _shouldFollowStreaming = true;
                _scrollToBottomSmoothly();
              },
              tooltip: '回到底部',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: DesignConstants.radiusXL,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: DesignConstants.spaceXXL,
          vertical: DesignConstants.spaceXXL,
        ),
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

            SizedBox(height: DesignConstants.spaceXXL),

            // 主标题
            Text(
              '开始新的对话',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: DesignConstants.spaceM),

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
          ],
        ),
      ),
    );
  }

  /// 智能滚动处理 - 支持多流式消息
  void _handleSmartScrolling(
      List<Message> displayMessages, List<Message> messages) {
    // 检查是否有新消息
    final hasNewMessage = displayMessages.length > _previousMessageCount;

    // 获取所有处理中的消息
    final streamingMessages =
        messages.where((m) => m.status == msg_status.MessageStatus.aiProcessing).toList();
    final currentStreamingIds = streamingMessages.map((m) => m.id).toSet();

    // 检查是否有新的流式消息或流式消息更新
    final hasNewStreamingMessage =
        !_trackedStreamingMessageIds.containsAll(currentStreamingIds);

    // 找到最底部（最新）的流式消息
    final bottomStreamingMessage =
        streamingMessages.isNotEmpty ? streamingMessages.last : null;
    final hasBottomStreamingUpdate = bottomStreamingMessage != null &&
        _lastBottomStreamingMessageId != bottomStreamingMessage.id;

    if (hasNewMessage) {
      // 新消息：只有用户在底部附近时才自动滚动
      if (_isNearBottom) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottomSmoothly();
        });
      }
    } else if ((hasNewStreamingMessage || hasBottomStreamingUpdate) &&
        _shouldFollowStreaming) {
      // 流式消息更新：只有在跟随模式下才滚动
      // 优先跟踪最底部的流式消息，确保用户看到最新的内容
      if (_isNearBottom) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottomSmoothly(duration: const Duration(milliseconds: 150));
        });
      }
    }

    // 更新跟踪状态
    _trackedStreamingMessageIds = currentStreamingIds;
    _lastBottomStreamingMessageId = bottomStreamingMessage?.id;
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

  /// 平滑滚动到底部
  void _scrollToBottomSmoothly({
    Duration duration = const Duration(milliseconds: 300),
  }) {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: duration,
      curve: Curves.easeOut,
    );
  }
}

/// 优化的消息项组件
///
/// 减少不必要的Provider监听，提升渲染性能
class _OptimizedMessageItem extends ConsumerWidget {
  const _OptimizedMessageItem({
    super.key,
    required this.message,
    required this.isWelcomeMessage,
    required this.canEdit,
    required this.canRegenerate,
    this.onEdit,
    this.onRegenerate,
  });

  final Message message;
  final bool isWelcomeMessage;
  final bool canEdit;
  final bool canRegenerate;
  final Function(Message)? onEdit;
  final Function(Message)? onRegenerate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 只监听聊天设置，避免监听整个聊天状态
    final chatSettings = ref.watch(chatSettingsProvider);

    return RepaintBoundary(
      child: MessageViewAdapter(
        message: message,
        useBlockView: chatSettings.enableBlockView,
        isWelcomeMessage: isWelcomeMessage,
        onEdit: canEdit ? () => onEdit?.call(message) : null,
        onRegenerate: canRegenerate ? () => onRegenerate?.call(message) : null,
      ),
    );
  }
}
