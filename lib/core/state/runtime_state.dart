import 'package:freezed_annotation/freezed_annotation.dart';

part 'runtime_state.freezed.dart';

/// Search result for message/conversation search
@freezed
class RuntimeSearchResult with _$RuntimeSearchResult {
  const factory RuntimeSearchResult({
    /// Result ID
    required String id,

    /// Result type (message, conversation, etc.)
    required SearchResultType type,

    /// Matched content
    required String content,

    /// Context around the match
    @Default('') String context,

    /// Match score (0.0 to 1.0)
    @Default(0.0) double score,

    /// Highlighted content with match markers
    @Default('') String highlightedContent,

    /// Additional metadata
    @Default({}) Map<String, dynamic> metadata,
  }) = _SearchResult;
}

/// Search result types
enum SearchResultType {
  /// Message content match
  message,

  /// Conversation title match
  conversation,

  /// Assistant name match
  assistant,

  /// File content match
  file,
}

/// Runtime interaction state management
///
/// Manages UI interaction state, user selections, editing modes, and search.
/// This is inspired by Cherry Studio's runtime state but adapted for Riverpod.
@freezed
class RuntimeState with _$RuntimeState {
  const factory RuntimeState({
    // === Multi-Selection Mode (Cherry Studio: isMultiSelectMode) ===
    /// Whether multi-select mode is active
    @Default(false) bool isMultiSelectMode,

    /// Set of selected message IDs
    @Default({}) Set<String> selectedMessageIds,

    /// Whether selection mode is for deletion
    @Default(false) bool isSelectionForDeletion,

    // === Topic/Conversation Management (Cherry Studio: activeTopic) ===
    /// Currently active topic/conversation ID
    @Default(null) String? activeTopicId,

    /// Topic IDs currently being renamed
    @Default({}) Set<String> renamingTopicIds,

    /// Topic IDs that were recently renamed (for UI feedback)
    @Default({}) Set<String> newlyRenamedTopicIds,

    // === Message Editing State ===
    /// Message ID currently being edited
    @Default(null) String? editingMessageId,

    /// Original content before editing (for cancel functionality)
    @Default(null) String? originalEditingContent,

    /// Current editing content
    @Default(null) String? editingContent,

    /// Whether editing is in progress
    @Default(false) bool isEditing,

    // === Search State ===
    /// Whether search mode is active
    @Default(false) bool isSearching,

    /// Current search query
    @Default('') String searchQuery,

    /// Search results
    @Default([]) List<RuntimeSearchResult> searchResults,

    /// Current search result index (for navigation)
    @Default(0) int currentSearchIndex,

    /// Whether search is loading
    @Default(false) bool isSearchLoading,

    /// Search error message
    @Default(null) String? searchError,

    // === Message Operations State ===
    /// Messages currently being processed for operations
    @Default({}) Set<String> processingMessageIds,

    /// Messages being regenerated
    @Default({}) Set<String> regeneratingMessageIds,

    /// Messages being translated
    @Default({}) Set<String> translatingMessageIds,

    /// Messages being deleted
    @Default({}) Set<String> deletingMessageIds,

    // === UI Interaction State ===
    /// Whether any modal/dialog is open
    @Default(false) bool isModalOpen,

    /// Current modal type
    @Default(null) String? currentModalType,

    /// Whether sidebar is collapsed
    @Default(false) bool isSidebarCollapsed,

    /// Whether settings panel is open
    @Default(false) bool isSettingsPanelOpen,

    /// Current view mode (chat, settings, etc.)
    @Default(ViewMode.chat) ViewMode currentViewMode,

    // === Drag and Drop State ===
    /// Whether drag operation is in progress
    @Default(false) bool isDragging,

    /// Type of item being dragged
    @Default(null) String? dragItemType,

    /// Data of item being dragged
    @Default({}) Map<String, dynamic> dragItemData,

    // === Keyboard Shortcuts State ===
    /// Whether keyboard shortcuts are enabled
    @Default(true) bool keyboardShortcutsEnabled,

    /// Currently pressed modifier keys
    @Default({}) Set<String> pressedModifierKeys,

    // === Performance and Debug State ===
    /// Whether debug mode is enabled
    @Default(false) bool isDebugMode,

    /// Performance metrics visibility
    @Default(false) bool showPerformanceMetrics,

    /// Last interaction timestamp
    @Default(null) DateTime? lastInteractionTime,

    // === Notification State ===
    /// Active notifications
    @Default([]) List<RuntimeNotification> activeNotifications,

    /// Whether notifications are muted
    @Default(false) bool notificationsMuted,
  }) = _RuntimeState;

  const RuntimeState._();

  // === Computed Properties ===

  /// Whether any messages are selected
  bool get hasSelectedMessages => selectedMessageIds.isNotEmpty;

  /// Number of selected messages
  int get selectedMessageCount => selectedMessageIds.length;

  /// Whether search has results
  bool get hasSearchResults => searchResults.isNotEmpty;

  /// Whether there's a current search result
  bool get hasCurrentSearchResult =>
      hasSearchResults && currentSearchIndex < searchResults.length;

  /// Get current search result
  RuntimeSearchResult? get currentSearchResult =>
      hasCurrentSearchResult ? searchResults[currentSearchIndex] : null;

  /// Whether any message operations are in progress
  bool get hasActiveOperations =>
      processingMessageIds.isNotEmpty ||
      regeneratingMessageIds.isNotEmpty ||
      translatingMessageIds.isNotEmpty ||
      deletingMessageIds.isNotEmpty;

  /// Whether a specific message is being processed
  bool isMessageBeingProcessed(String messageId) =>
      processingMessageIds.contains(messageId) ||
      regeneratingMessageIds.contains(messageId) ||
      translatingMessageIds.contains(messageId) ||
      deletingMessageIds.contains(messageId);

  /// Whether a specific message is selected
  bool isMessageSelected(String messageId) =>
      selectedMessageIds.contains(messageId);

  /// Whether a specific topic is being renamed
  bool isTopicBeingRenamed(String topicId) =>
      renamingTopicIds.contains(topicId);

  /// Whether a specific topic was recently renamed
  bool wasTopicRecentlyRenamed(String topicId) =>
      newlyRenamedTopicIds.contains(topicId);

  /// Get all active operation types for a message
  List<String> getActiveOperationsForMessage(String messageId) {
    final operations = <String>[];
    if (processingMessageIds.contains(messageId)) operations.add('processing');
    if (regeneratingMessageIds.contains(messageId))
      operations.add('regenerating');
    if (translatingMessageIds.contains(messageId))
      operations.add('translating');
    if (deletingMessageIds.contains(messageId)) operations.add('deleting');
    return operations;
  }
}

/// View modes for the application
enum ViewMode {
  /// Main chat view
  chat,

  /// Settings view
  settings,

  /// Search view
  search,

  /// Assistant management view
  assistants,

  /// Provider management view
  providers,

  /// About/help view
  about,
}

/// Runtime notification for user feedback
@freezed
class RuntimeNotification with _$RuntimeNotification {
  const factory RuntimeNotification({
    /// Notification ID
    required String id,

    /// Notification type
    required NotificationType type,

    /// Notification title
    required String title,

    /// Notification message
    @Default('') String message,

    /// Whether notification is persistent (doesn't auto-dismiss)
    @Default(false) bool isPersistent,

    /// Auto-dismiss duration in seconds
    @Default(5) int autoDismissSeconds,

    /// Creation timestamp
    required DateTime createdAt,

    /// Whether notification was read
    @Default(false) bool isRead,

    /// Action buttons
    @Default([]) List<NotificationAction> actions,

    /// Additional metadata
    @Default({}) Map<String, dynamic> metadata,
  }) = _RuntimeNotification;
}

/// Notification types
enum NotificationType {
  /// Information notification
  info,

  /// Success notification
  success,

  /// Warning notification
  warning,

  /// Error notification
  error,

  /// System notification
  system,
}

/// Notification action button
@freezed
class NotificationAction with _$NotificationAction {
  const factory NotificationAction({
    /// Action ID
    required String id,

    /// Action label
    required String label,

    /// Action type
    @Default(NotificationActionType.button) NotificationActionType type,

    /// Whether action is primary
    @Default(false) bool isPrimary,

    /// Whether action dismisses notification
    @Default(true) bool dismissesNotification,

    /// Action metadata
    @Default({}) Map<String, dynamic> metadata,
  }) = _NotificationAction;
}

/// Notification action types
enum NotificationActionType {
  /// Button action
  button,

  /// Link action
  link,

  /// Dismiss action
  dismiss,
}

/// Helper methods for RuntimeState manipulation
extension RuntimeStateHelpers on RuntimeState {
  /// Toggle message selection
  RuntimeState toggleMessageSelection(String messageId) {
    final newSelectedIds = Set<String>.from(selectedMessageIds);
    if (newSelectedIds.contains(messageId)) {
      newSelectedIds.remove(messageId);
    } else {
      newSelectedIds.add(messageId);
    }

    return copyWith(
      selectedMessageIds: newSelectedIds,
      isMultiSelectMode: newSelectedIds.isNotEmpty,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Clear all selections
  RuntimeState clearSelections() {
    return copyWith(
      selectedMessageIds: {},
      isMultiSelectMode: false,
      isSelectionForDeletion: false,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Start editing a message
  RuntimeState startEditing(String messageId, String originalContent) {
    return copyWith(
      editingMessageId: messageId,
      originalEditingContent: originalContent,
      editingContent: originalContent,
      isEditing: true,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Cancel editing
  RuntimeState cancelEditing() {
    return copyWith(
      editingMessageId: null,
      originalEditingContent: null,
      editingContent: null,
      isEditing: false,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Update search query
  RuntimeState updateSearchQuery(String query) {
    return copyWith(
      searchQuery: query,
      currentSearchIndex: 0,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Add notification
  RuntimeState addNotification(RuntimeNotification notification) {
    final newNotifications =
        List<RuntimeNotification>.from(activeNotifications);
    newNotifications.add(notification);

    return copyWith(
      activeNotifications: newNotifications,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Remove notification
  RuntimeState removeNotification(String notificationId) {
    final newNotifications =
        activeNotifications.where((n) => n.id != notificationId).toList();

    return copyWith(
      activeNotifications: newNotifications,
      lastInteractionTime: DateTime.now(),
    );
  }
}
