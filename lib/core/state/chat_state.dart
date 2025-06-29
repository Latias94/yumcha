import 'package:freezed_annotation/freezed_annotation.dart';
import '../../features/chat/domain/entities/message.dart';
import '../../features/chat/domain/entities/conversation_ui_state.dart';

part 'chat_state.freezed.dart';

/// Chat status enumeration - represents the overall chat state
enum ChatStatus {
  /// Chat is idle, ready to send messages
  idle,

  /// Currently sending a message
  sending,

  /// Receiving AI response (non-streaming)
  receiving,

  /// Receiving streaming AI response
  streaming,

  /// Error occurred during chat operation
  error,

  /// Chat is paused (e.g., user paused streaming)
  paused,
}

/// Chat configuration for the current session
@freezed
class ChatConfig with _$ChatConfig {
  const factory ChatConfig({
    /// Maximum number of messages to keep in memory
    @Default(100) int maxMessages,

    /// Whether to use streaming responses
    @Default(true) bool useStreaming,

    /// Whether to auto-scroll to new messages
    @Default(true) bool autoScroll,

    /// Message display settings
    @Default(MessageDisplayConfig()) MessageDisplayConfig displayConfig,

    /// Performance settings
    @Default(PerformanceConfig()) PerformanceConfig performanceConfig,
  }) = _ChatConfig;
}

/// Message display configuration
@freezed
class MessageDisplayConfig with _$MessageDisplayConfig {
  const factory MessageDisplayConfig({
    /// Number of messages to display initially
    @Default(20) int initialDisplayCount,

    /// Number of messages to load when scrolling up
    @Default(10) int loadMoreCount,

    /// Whether to show message timestamps
    @Default(true) bool showTimestamps,

    /// Whether to show message status indicators
    @Default(true) bool showStatusIndicators,
  }) = _MessageDisplayConfig;
}

/// Performance configuration for chat
@freezed
class PerformanceConfig with _$PerformanceConfig {
  const factory PerformanceConfig({
    /// Maximum concurrent streaming messages
    @Default(3) int maxConcurrentStreams,

    /// Streaming update throttle delay in milliseconds
    @Default(50) int streamingThrottleMs,

    /// Whether to enable message virtualization for large lists
    @Default(true) bool enableVirtualization,

    /// Threshold for enabling virtualization
    @Default(50) int virtualizationThreshold,
  }) = _PerformanceConfig;
}

/// Core chat state - manages conversations, messages, and chat status
///
/// This is inspired by Cherry Studio's message management but adapted for Riverpod.
/// Key differences from current UnifiedChatState:
/// 1. Simplified structure with clear separation of concerns
/// 2. EntityAdapter-like message management with messageMap for O(1) lookups
/// 3. Better streaming state management
/// 4. Performance optimizations built-in
@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    // === Conversation Management ===
    /// Current active conversation
    @Default(null) ConversationUiState? currentConversation,

    // === Message Management (EntityAdapter pattern) ===
    /// Ordered list of messages for display
    @Default([]) List<Message> messages,

    /// Message lookup map for O(1) access (messageId -> Message)
    /// Similar to Cherry Studio's EntityAdapter pattern
    @Default({}) Map<String, Message> messageMap,

    /// Messages grouped by conversation (conversationId -> messageIds)
    /// Similar to Cherry Studio's messageIdsByTopic
    @Default({}) Map<String, List<String>> messagesByConversation,

    // === Chat Status Management ===
    /// Overall chat status
    @Default(ChatStatus.idle) ChatStatus status,

    /// General error message
    @Default(null) String? error,

    /// Loading state for non-streaming operations
    @Default(false) bool isLoading,

    // === Configuration ===
    /// Chat configuration settings
    @Default(ChatConfig()) ChatConfig config,

    // === Performance Metrics ===
    /// Total number of messages (for quick access)
    @Default(0) int messageCount,

    /// Last update timestamp for cache invalidation
    @Default(null) DateTime? lastUpdateTime,

    /// Display count for pagination
    @Default(20) int displayCount,

    // === Loading States by Conversation ===
    /// Loading state per conversation (conversationId -> isLoading)
    /// Similar to Cherry Studio's loadingByTopic
    @Default({}) Map<String, bool> loadingByConversation,
  }) = _ChatState;

  const ChatState._();

  // === Computed Properties ===

  /// Get messages for the current conversation
  List<Message> get currentMessages {
    if (currentConversation == null) return [];

    final messageIds = messagesByConversation[currentConversation!.id] ?? [];
    return messageIds.map((id) => messageMap[id]).whereType<Message>().toList();
  }

  /// Get recent messages for display (limited by displayCount)
  List<Message> get displayMessages {
    final current = currentMessages;
    if (current.length <= displayCount) return current;
    return current.sublist(current.length - displayCount);
  }

  /// Check if current conversation is loading
  bool get isCurrentConversationLoading {
    if (currentConversation == null) return false;
    return loadingByConversation[currentConversation!.id] ?? false;
  }

  /// Check if chat is ready to send messages
  bool get isReady {
    return currentConversation != null &&
        status != ChatStatus.error &&
        !isLoading;
  }

  /// Check if there are any errors
  bool get hasError => error != null;

  /// Get message by ID with O(1) lookup
  Message? getMessageById(String messageId) => messageMap[messageId];

  /// Check if a message exists
  bool hasMessage(String messageId) => messageMap.containsKey(messageId);

  /// Get messages for a specific conversation
  List<Message> getMessagesForConversation(String conversationId) {
    final messageIds = messagesByConversation[conversationId] ?? [];
    return messageIds.map((id) => messageMap[id]).whereType<Message>().toList();
  }

  /// Get the last message in current conversation
  Message? get lastMessage {
    final current = currentMessages;
    return current.isNotEmpty ? current.last : null;
  }

  /// Check if we can load more messages
  bool get canLoadMore {
    final current = currentMessages;
    return current.length > displayCount;
  }
}

/// Helper methods for ChatState manipulation
extension ChatStateHelpers on ChatState {
  /// Add a message using EntityAdapter pattern
  ChatState addMessage(Message message) {
    final newMessageMap = Map<String, Message>.from(messageMap);
    newMessageMap[message.id] = message;

    final conversationId = message.conversationId;
    final newMessagesByConversation =
        Map<String, List<String>>.from(messagesByConversation);
    final messageIds =
        List<String>.from(newMessagesByConversation[conversationId] ?? []);

    if (!messageIds.contains(message.id)) {
      messageIds.add(message.id);
      newMessagesByConversation[conversationId] = messageIds;
    }

    return copyWith(
      messageMap: newMessageMap,
      messagesByConversation: newMessagesByConversation,
      messageCount: newMessageMap.length,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Update a message using EntityAdapter pattern
  ChatState updateMessage(String messageId, Message Function(Message) updater) {
    final existingMessage = messageMap[messageId];
    if (existingMessage == null) return this;

    final updatedMessage = updater(existingMessage);
    final newMessageMap = Map<String, Message>.from(messageMap);
    newMessageMap[messageId] = updatedMessage;

    return copyWith(
      messageMap: newMessageMap,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Remove a message using EntityAdapter pattern
  ChatState removeMessage(String messageId) {
    final message = messageMap[messageId];
    if (message == null) return this;

    final newMessageMap = Map<String, Message>.from(messageMap);
    newMessageMap.remove(messageId);

    final conversationId = message.conversationId;
    final newMessagesByConversation =
        Map<String, List<String>>.from(messagesByConversation);
    final messageIds =
        List<String>.from(newMessagesByConversation[conversationId] ?? []);
    messageIds.remove(messageId);
    newMessagesByConversation[conversationId] = messageIds;

    return copyWith(
      messageMap: newMessageMap,
      messagesByConversation: newMessagesByConversation,
      messageCount: newMessageMap.length,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Set loading state for a conversation
  ChatState setConversationLoading(String conversationId, bool loading) {
    final newLoadingByConversation =
        Map<String, bool>.from(loadingByConversation);
    newLoadingByConversation[conversationId] = loading;

    return copyWith(
      loadingByConversation: newLoadingByConversation,
    );
  }
}
