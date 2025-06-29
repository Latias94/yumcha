import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_state_provider.dart';
import '../adapters/chat_migration_adapter.dart';
import '../../features/chat/domain/entities/conversation_ui_state.dart';
import '../../features/chat/domain/entities/message.dart';
import 'message_list_widget.dart';
import 'chat_input_widget.dart';

/// Modern chat view using new state management system
///
/// This is the main chat interface component that replaces the old ChatView.
/// It uses the new ChatStateProvider for better performance and maintainability.
///
/// Features:
/// - 🎯 **Unified state management**: Single source of truth for chat state
/// - 🔄 **Real-time updates**: Reactive UI that updates automatically
/// - 📱 **Responsive design**: Adapts to different screen sizes
/// - ⚡ **Performance optimized**: Efficient rebuilds and memory usage
/// - 🛡️ **Error handling**: Graceful error states and recovery
/// - 🔧 **Migration support**: Smooth transition from old system
class ModernChatView extends ConsumerStatefulWidget {
  /// Conversation ID to display
  final String? conversationId;

  /// Assistant ID for this chat
  final String? assistantId;

  /// Whether to show the app bar
  final bool showAppBar;

  /// Custom app bar title
  final String? appBarTitle;

  /// Whether to enable message input
  final bool enableInput;

  /// Callback when a message is sent
  final void Function(String message)? onMessageSent;

  /// Callback when conversation changes
  final void Function(ConversationUiState? conversation)? onConversationChanged;

  const ModernChatView({
    super.key,
    this.conversationId,
    this.assistantId,
    this.showAppBar = true,
    this.appBarTitle,
    this.enableInput = true,
    this.onMessageSent,
    this.onConversationChanged,
  });

  @override
  ConsumerState<ModernChatView> createState() => _ModernChatViewState();
}

class _ModernChatViewState extends ConsumerState<ModernChatView> {
  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void didUpdateWidget(ModernChatView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.conversationId != oldWidget.conversationId) {
      _initializeChat();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeChat() {
    if (widget.conversationId != null) {
      // Load conversation if specified
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadConversation(widget.conversationId!);
      });
    } else if (widget.assistantId != null) {
      // Create new conversation if assistant specified
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _createNewConversation();
      });
    }
  }

  Future<void> _loadConversation(String conversationId) async {
    final adapter = ref.read(chatMigrationAdapterProvider);

    // For now, we'll create a placeholder conversation
    // In a real implementation, this would load from database
    final conversation = ConversationUiState(
      id: conversationId,
      channelName: 'Chat ${conversationId.substring(0, 8)}',
      channelMembers: 1,
      assistantId: widget.assistantId,
      selectedProviderId: 'default',
    );

    adapter.setCurrentConversation(conversation);
    widget.onConversationChanged?.call(conversation);
  }

  Future<void> _createNewConversation() async {
    if (widget.assistantId == null) return;

    final adapter = ref.read(chatMigrationAdapterProvider);
    await adapter.createConversation(
      title: 'New Chat',
      assistantId: widget.assistantId!,
    );

    final conversation = adapter.currentConversation;
    widget.onConversationChanged?.call(conversation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? _buildAppBar() : null,
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: _buildMessageArea(),
          ),

          // Message input
          if (widget.enableInput)
            ChatInputWidget(
              placeholder: 'Type a message...',
              onMessageSent: (message) {
                widget.onMessageSent?.call(message);
              },
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final currentConversation = ref.watch(currentConversationProvider);
    final isLoading =
        ref.watch(chatStateProvider.select((state) => state.isLoading));

    return AppBar(
      title: Text(
          widget.appBarTitle ?? currentConversation?.channelName ?? 'Chat'),
      actions: [
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: _showChatOptions,
        ),
      ],
    );
  }

  Widget _buildMessageArea() {
    final error = ref.watch(chatStateProvider.select((state) => state.error));

    if (error != null) {
      return _buildErrorWidget(error);
    }

    return MessageListWidget(
      conversationId: widget.conversationId,
      onMessageTap: _onMessageTap,
      onMessageLongPress: _onMessageLongPress,
      onLoadMore: _onLoadMoreMessages,
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
            'Something went wrong',
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
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _onMessageTap(Message message) {
    // Handle message tap
    // TODO: Implement message tap handling
  }

  void _onMessageLongPress(Message message) {
    // Show message options
    _showMessageOptions(message);
  }

  void _onLoadMoreMessages() {
    // Load more messages is handled by MessageListWidget
    // TODO: Add logging framework for debug messages
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildChatOptionsSheet(),
    );
  }

  Widget _buildChatOptionsSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.clear_all),
            title: const Text('Clear Messages'),
            onTap: () {
              Navigator.pop(context);
              _clearMessages();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Chat Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(Message message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildMessageOptionsSheet(message),
    );
  }

  Widget _buildMessageOptionsSheet(Message message) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy'),
            onTap: () {
              Navigator.pop(context);
              // Copy message content
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
            onTap: () {
              Navigator.pop(context);
              _deleteMessage(message);
            },
          ),
        ],
      ),
    );
  }

  void _clearMessages() {
    ref.read(chatStateProvider.notifier).clearCurrentConversationMessages();
  }

  void _deleteMessage(Message message) {
    ref.read(chatStateProvider.notifier).removeMessage(message.id);
  }
}
