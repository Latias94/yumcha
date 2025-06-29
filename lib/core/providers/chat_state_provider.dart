import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/chat_state.dart';
import '../services/deduplication_manager.dart';
import '../../features/chat/domain/entities/message.dart';
import '../../features/chat/domain/entities/conversation_ui_state.dart';

/// Chat state notifier for managing chat state
///
/// This notifier manages the core chat state including conversations,
/// messages, and chat status. It replaces the unified chat provider
/// with a more focused and maintainable approach.
class ChatStateNotifier extends StateNotifier<ChatState> {
  final Ref _ref;
  final DeduplicationManager _deduplicationManager;

  ChatStateNotifier(this._ref)
      : _deduplicationManager = DeduplicationManager.instance,
        super(const ChatState());

  // === Conversation Management ===

  /// Set the current conversation
  void setCurrentConversation(ConversationUiState? conversation) {
    if (state.currentConversation?.id == conversation?.id) {
      return; // No change needed
    }

    state = state.copyWith(
      currentConversation: conversation,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Create a new conversation
  Future<void> createConversation({
    required String title,
    String? assistantId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final conversation = ConversationUiState(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        channelName: title,
        channelMembers: 1,
        assistantId: assistantId,
        selectedProviderId: 'default', // TODO: Get from current provider
        selectedModelId: null,
      );

      // Set as current conversation
      state = state.copyWith(
        currentConversation: conversation,
        isLoading: false,
        lastUpdateTime: DateTime.now(),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
        lastUpdateTime: DateTime.now(),
      );
    }
  }

  // === Message Management ===

  /// Add a message to the current conversation
  void addMessage(Message message) {
    if (state.currentConversation == null) {
      state = state.copyWith(
        error: 'No active conversation to add message to',
        lastUpdateTime: DateTime.now(),
      );
      return;
    }

    // Check for duplicate messages
    if (state.hasMessage(message.id)) {
      return; // Message already exists
    }

    // Add message using EntityAdapter pattern
    state = state.addMessage(message);
  }

  /// Update an existing message
  void updateMessage(String messageId, Message Function(Message) updater) {
    if (!state.hasMessage(messageId)) {
      return; // Message doesn't exist
    }

    state = state.updateMessage(messageId, updater);
  }

  /// Remove a message
  void removeMessage(String messageId) {
    if (!state.hasMessage(messageId)) {
      return; // Message doesn't exist
    }

    state = state.removeMessage(messageId);
  }

  /// Add multiple messages (batch operation)
  void addMessages(List<Message> messages) {
    if (state.currentConversation == null) {
      state = state.copyWith(
        error: 'No active conversation to add messages to',
        lastUpdateTime: DateTime.now(),
      );
      return;
    }

    ChatState newState = state;
    for (final message in messages) {
      if (!newState.hasMessage(message.id)) {
        newState = newState.addMessage(message);
      }
    }
    state = newState;
  }

  /// Clear all messages in current conversation
  void clearCurrentConversationMessages() {
    if (state.currentConversation == null) return;

    final conversationId = state.currentConversation!.id;
    final messageIds = state.messagesByConversation[conversationId] ?? [];

    ChatState newState = state;
    for (final messageId in messageIds) {
      newState = newState.removeMessage(messageId);
    }
    state = newState;
  }

  // === Chat Status Management ===

  /// Set chat status
  void setChatStatus(ChatStatus status) {
    if (state.status == status) return;

    state = state.copyWith(
      status: status,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Set loading state
  void setLoading(bool isLoading) {
    if (state.isLoading == isLoading) return;

    state = state.copyWith(
      isLoading: isLoading,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Set error
  void setError(String? error) {
    state = state.copyWith(
      error: error,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Clear error
  void clearError() {
    if (state.error == null) return;

    state = state.copyWith(
      error: null,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Set conversation loading state
  void setConversationLoading(String conversationId, bool loading) {
    state = state.setConversationLoading(conversationId, loading);
  }

  // === Pagination Management ===

  /// Load more messages (pagination)
  void loadMoreMessages() {
    if (!state.canLoadMore) return;

    final newDisplayCount =
        state.displayCount + state.config.displayConfig.loadMoreCount;
    final maxDisplayCount = state.currentMessages.length;

    state = state.copyWith(
      displayCount: newDisplayCount.clamp(0, maxDisplayCount),
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Reset display count to initial value
  void resetDisplayCount() {
    state = state.copyWith(
      displayCount: state.config.displayConfig.initialDisplayCount,
      lastUpdateTime: DateTime.now(),
    );
  }

  // === Configuration Management ===

  /// Update chat configuration
  void updateConfig(ChatConfig config) {
    state = state.copyWith(
      config: config,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Update display configuration
  void updateDisplayConfig(MessageDisplayConfig displayConfig) {
    final newConfig = state.config.copyWith(displayConfig: displayConfig);
    updateConfig(newConfig);
  }

  /// Update performance configuration
  void updatePerformanceConfig(PerformanceConfig performanceConfig) {
    final newConfig =
        state.config.copyWith(performanceConfig: performanceConfig);
    updateConfig(newConfig);
  }

  // === Utility Methods ===

  /// Get message by ID
  Message? getMessage(String messageId) {
    return state.getMessageById(messageId);
  }

  /// Get messages for current conversation
  List<Message> getCurrentMessages() {
    return state.currentMessages;
  }

  /// Get display messages (paginated)
  List<Message> getDisplayMessages() {
    return state.displayMessages;
  }

  /// Check if chat is ready
  bool get isReady => state.isReady;

  /// Check if there are errors
  bool get hasError => state.hasError;

  /// Get last message
  Message? get lastMessage => state.lastMessage;

  /// Check if can load more
  bool get canLoadMore => state.canLoadMore;

  // === Cleanup and Reset ===

  /// Reset chat state to initial state
  void reset() {
    state = const ChatState();
    _deduplicationManager.clearChatDeduplication();
  }

  /// Clear all data
  void clearAll() {
    state = const ChatState();
    _deduplicationManager.clearAll();
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}

/// Chat state provider
final chatStateProvider =
    StateNotifierProvider<ChatStateNotifier, ChatState>((ref) {
  return ChatStateNotifier(ref);
});

// === Convenience Providers ===

/// Current conversation provider
final currentConversationProvider = Provider<ConversationUiState?>((ref) {
  return ref.watch(chatStateProvider).currentConversation;
});

/// Current messages provider
final currentMessagesProvider = Provider<List<Message>>((ref) {
  return ref.watch(chatStateProvider).currentMessages;
});

/// Display messages provider (paginated)
final displayMessagesProvider = Provider<List<Message>>((ref) {
  return ref.watch(chatStateProvider).displayMessages;
});

/// Chat status provider
final chatStatusProvider = Provider<ChatStatus>((ref) {
  return ref.watch(chatStateProvider).status;
});

/// Chat loading provider
final chatLoadingProvider = Provider<bool>((ref) {
  return ref.watch(chatStateProvider).isLoading;
});

/// Chat error provider
final chatErrorProvider = Provider<String?>((ref) {
  return ref.watch(chatStateProvider).error;
});

/// Chat ready provider
final chatReadyProvider = Provider<bool>((ref) {
  return ref.watch(chatStateProvider).isReady;
});

/// Last message provider
final lastMessageProvider = Provider<Message?>((ref) {
  return ref.watch(chatStateProvider).lastMessage;
});

/// Can load more provider
final canLoadMoreProvider = Provider<bool>((ref) {
  return ref.watch(chatStateProvider).canLoadMore;
});

/// Message count provider
final messageCountProvider = Provider<int>((ref) {
  return ref.watch(chatStateProvider).messageCount;
});

/// Chat configuration provider
final chatConfigProvider = Provider<ChatConfig>((ref) {
  return ref.watch(chatStateProvider).config;
});

// === Selector Providers ===

/// Get message by ID provider
final messageByIdProvider = Provider.family<Message?, String>((ref, messageId) {
  return ref.watch(chatStateProvider).getMessageById(messageId);
});

/// Get messages for conversation provider
final messagesForConversationProvider =
    Provider.family<List<Message>, String>((ref, conversationId) {
  return ref
      .watch(chatStateProvider)
      .getMessagesForConversation(conversationId);
});

/// Conversation loading provider
final conversationLoadingProvider =
    Provider.family<bool, String>((ref, conversationId) {
  return ref.watch(chatStateProvider).loadingByConversation[conversationId] ??
      false;
});
