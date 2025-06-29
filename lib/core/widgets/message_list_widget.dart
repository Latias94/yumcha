import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_state_provider.dart';
import '../../features/chat/domain/entities/message.dart';
import '../../features/chat/presentation/widgets/message_view_adapter.dart';

/// Modern message list widget using new state management system
///
/// This widget replaces the old VirtualizedMessageList and uses the new
/// ChatStateProvider for better performance and maintainability.
///
/// Features:
/// - 🚀 **Optimized rendering**: Only renders visible messages
/// - 📱 **Responsive design**: Adapts to different screen sizes
/// - 🔄 **Pagination**: Loads more messages on demand
/// - 📍 **Scroll position**: Maintains scroll position intelligently
/// - ⚡ **Performance**: Efficient rebuilds with fine-grained providers
class MessageListWidget extends ConsumerStatefulWidget {
  /// Conversation ID for this message list
  final String? conversationId;

  /// Whether to show loading indicator
  final bool showLoadingIndicator;

  /// Whether to enable pull-to-refresh
  final bool enablePullToRefresh;

  /// Callback when user scrolls to top (for loading more messages)
  final VoidCallback? onLoadMore;

  /// Callback when message is tapped
  final void Function(Message message)? onMessageTap;

  /// Callback when message is long pressed
  final void Function(Message message)? onMessageLongPress;

  const MessageListWidget({
    super.key,
    this.conversationId,
    this.showLoadingIndicator = true,
    this.enablePullToRefresh = true,
    this.onLoadMore,
    this.onMessageTap,
    this.onMessageLongPress,
  });

  @override
  ConsumerState<MessageListWidget> createState() => _MessageListWidgetState();
}

class _MessageListWidgetState extends ConsumerState<MessageListWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

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

  void _onScroll() {
    // Load more messages when scrolled to top
    if (_scrollController.position.pixels <= 100 &&
        !_isLoadingMore &&
        widget.onLoadMore != null) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // Load more messages through the state provider
      ref.read(chatStateProvider.notifier).loadMoreMessages();
      widget.onLoadMore?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    if (widget.enablePullToRefresh) {
      await _loadMoreMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch display messages (paginated)
    final displayMessages = ref.watch(displayMessagesProvider);
    final isLoading =
        ref.watch(chatStateProvider.select((state) => state.isLoading));
    final error = ref.watch(chatStateProvider.select((state) => state.error));

    // Handle error state
    if (error != null) {
      return _buildErrorWidget(error);
    }

    // Handle empty state
    if (displayMessages.isEmpty && !isLoading) {
      return _buildEmptyWidget();
    }

    return RefreshIndicator(
      onRefresh: widget.enablePullToRefresh ? _onRefresh : () async {},
      child: CustomScrollView(
        controller: _scrollController,
        reverse: true, // Start from bottom like chat apps
        slivers: [
          // Messages list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= displayMessages.length) {
                  return null;
                }

                final message =
                    displayMessages[displayMessages.length - 1 - index];
                return _buildMessageItem(message);
              },
              childCount: displayMessages.length,
            ),
          ),

          // Loading indicator at top
          if (_isLoadingMore || (isLoading && widget.showLoadingIndicator))
            SliverToBoxAdapter(
              child: _buildLoadingIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Message message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: GestureDetector(
        onTap: () => widget.onMessageTap?.call(message),
        onLongPress: () => widget.onMessageLongPress?.call(message),
        child: MessageViewAdapter(
          message: message,
          // Pass additional configuration as needed
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading messages',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(chatStateProvider.notifier).clearError();
              _loadMoreMessages();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation to see messages here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Convenience provider for message list configuration
final messageListConfigProvider = Provider<MessageListConfig>((ref) {
  final chatState = ref.watch(chatStateProvider);
  return MessageListConfig(
    enableVirtualization: chatState.messageCount > 100,
    batchSize: chatState.config.displayConfig.loadMoreCount,
    initialDisplayCount: chatState.config.displayConfig.initialDisplayCount,
  );
});

/// Configuration for message list behavior
class MessageListConfig {
  final bool enableVirtualization;
  final int batchSize;
  final int initialDisplayCount;

  const MessageListConfig({
    required this.enableVirtualization,
    required this.batchSize,
    required this.initialDisplayCount,
  });
}
