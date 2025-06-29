import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_state_provider.dart' as core;
import '../../features/chat/domain/entities/message.dart';
import '../../features/chat/domain/entities/conversation_ui_state.dart';
import '../../features/chat/presentation/providers/unified_chat_notifier.dart'
    as legacy;

/// Migration adapter to help transition from old UnifiedChatNotifier to new ChatStateProvider
///
/// This adapter provides compatibility methods and helps migrate components gradually
/// without breaking existing functionality.
class ChatMigrationAdapter {
  final WidgetRef _ref;

  ChatMigrationAdapter(this._ref);

  // === Core State Access ===

  /// Get current conversation from new state system
  ConversationUiState? get currentConversation {
    return _ref.read(core.chatStateProvider).currentConversation;
  }

  /// Get current messages from new state system
  List<Message> get currentMessages {
    return _ref.read(core.chatStateProvider).currentMessages;
  }

  /// Get display messages (paginated) from new state system
  List<Message> get displayMessages {
    return _ref.read(core.chatStateProvider).displayMessages;
  }

  /// Check if chat is loading
  bool get isLoading {
    return _ref.read(core.chatStateProvider).isLoading;
  }

  /// Get current error
  String? get error {
    return _ref.read(core.chatStateProvider).error;
  }

  /// Check if chat is ready
  bool get isReady {
    return _ref.read(core.chatStateProvider).isReady;
  }

  // === Actions ===

  /// Create new conversation using new state system
  Future<void> createConversation({
    required String title,
    required String assistantId,
    Map<String, dynamic>? metadata,
  }) async {
    final notifier = _ref.read(core.chatStateProvider.notifier);
    await notifier.createConversation(
      title: title,
      assistantId: assistantId,
      metadata: metadata,
    );
  }

  /// Set current conversation
  void setCurrentConversation(ConversationUiState? conversation) {
    final notifier = _ref.read(core.chatStateProvider.notifier);
    notifier.setCurrentConversation(conversation);
  }

  /// Add message to current conversation
  void addMessage(Message message) {
    final notifier = _ref.read(core.chatStateProvider.notifier);
    notifier.addMessage(message);
  }

  /// Update message
  void updateMessage(Message message) {
    final notifier = _ref.read(core.chatStateProvider.notifier);
    // Fix: updateMessage requires messageId and updater function
    notifier.updateMessage(message.id, (_) => message);
  }

  /// Remove message
  void removeMessage(String messageId) {
    final notifier = _ref.read(core.chatStateProvider.notifier);
    notifier.removeMessage(messageId);
  }

  /// Clear all messages
  void clearMessages() {
    final notifier = _ref.read(core.chatStateProvider.notifier);
    notifier.clearCurrentConversationMessages();
  }

  /// Set loading state
  void setLoading(bool loading) {
    final notifier = _ref.read(core.chatStateProvider.notifier);
    notifier.setLoading(loading);
  }

  /// Set error
  void setError(String? error) {
    final notifier = _ref.read(core.chatStateProvider.notifier);
    if (error != null) {
      notifier.setError(error);
    } else {
      notifier.clearError();
    }
  }

  /// Load more messages (pagination)
  void loadMoreMessages() {
    final notifier = _ref.read(core.chatStateProvider.notifier);
    notifier.loadMoreMessages();
  }

  /// Reset display count
  void resetDisplayCount() {
    final notifier = _ref.read(core.chatStateProvider.notifier);
    notifier.resetDisplayCount();
  }

  // === Migration Helpers ===

  /// Check if old system is still being used
  bool get isUsingOldSystem {
    try {
      final oldState = _ref.read(legacy.unifiedChatProvider);
      return oldState.conversationState.currentConversation != null;
    } catch (e) {
      return false;
    }
  }

  /// Migrate data from old system to new system
  Future<void> migrateFromOldSystem() async {
    if (!isUsingOldSystem) return;

    try {
      final oldState = _ref.read(legacy.unifiedChatProvider);
      final newNotifier = _ref.read(core.chatStateProvider.notifier);

      // Migrate current conversation
      if (oldState.conversationState.currentConversation != null) {
        newNotifier.setCurrentConversation(
          oldState.conversationState.currentConversation,
        );
      }

      // Migrate messages
      if (oldState.messageState.messages.isNotEmpty) {
        for (final message in oldState.messageState.messages) {
          newNotifier.addMessage(message);
        }
      }

      // Migrate loading state
      if (oldState.isLoading) {
        newNotifier.setLoading(true);
      }

      // Migrate error state
      if (oldState.primaryError != null) {
        newNotifier.setError(oldState.primaryError);
      }
    } catch (e) {
      // Migration failed, log error but don't crash
      // TODO: Use proper logging framework
    }
  }
}

/// Provider for ChatMigrationAdapter
final chatMigrationAdapterProvider = Provider<ChatMigrationAdapter>((ref) {
  // Note: This is a workaround for the type mismatch
  // In a real implementation, you might want to restructure this
  return ChatMigrationAdapter(ref as WidgetRef);
});

/// Compatibility providers that delegate to new system
/// These help existing components work without immediate changes

/// Legacy current conversation provider (delegates to new system)
final legacyCurrentConversationProvider = Provider<ConversationUiState?>((ref) {
  return ref.watch(core.currentConversationProvider);
});

/// Legacy chat messages provider (delegates to new system)
final legacyChatMessagesProvider = Provider<List<Message>>((ref) {
  return ref.watch(core.currentMessagesProvider);
});

/// Legacy chat loading state provider (delegates to new system)
final legacyChatLoadingStateProvider = Provider<bool>((ref) {
  return ref.watch(core.chatStateProvider.select((state) => state.isLoading));
});

/// Legacy chat error provider (delegates to new system)
final legacyChatErrorProvider = Provider<String?>((ref) {
  return ref.watch(core.chatStateProvider.select((state) => state.error));
});

/// Legacy chat ready state provider (delegates to new system)
final legacyChatReadyStateProvider = Provider<bool>((ref) {
  return ref.watch(core.chatStateProvider.select((state) => state.isReady));
});
