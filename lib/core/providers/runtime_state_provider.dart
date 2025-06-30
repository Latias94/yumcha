import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/runtime_state.dart';

/// Runtime state notifier for managing UI interaction state
///
/// This notifier manages user interactions, selections, editing modes,
/// search functionality, and other runtime UI state.
class RuntimeStateNotifier extends StateNotifier<RuntimeState> {
  final Ref _ref;

  RuntimeStateNotifier(this._ref) : super(const RuntimeState());

  // === Multi-Selection Management ===

  /// Toggle multi-select mode
  void toggleMultiSelectMode() {
    state = state.copyWith(
      isMultiSelectMode: !state.isMultiSelectMode,
      selectedMessageIds:
          state.isMultiSelectMode ? {} : state.selectedMessageIds,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Toggle message selection
  void toggleMessageSelection(String messageId) {
    state = state.toggleMessageSelection(messageId);
  }

  /// Select all messages
  void selectAllMessages(List<String> messageIds) {
    state = state.copyWith(
      selectedMessageIds: Set.from(messageIds),
      isMultiSelectMode: true,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Clear all selections
  void clearSelections() {
    state = state.clearSelections();
  }

  /// Set selection for deletion
  void setSelectionForDeletion(bool forDeletion) {
    state = state.copyWith(
      isSelectionForDeletion: forDeletion,
      lastInteractionTime: DateTime.now(),
    );
  }

  // === Topic/Conversation Management ===

  /// Set active topic
  void setActiveTopic(String? topicId) {
    if (state.activeTopicId == topicId) return;

    state = state.copyWith(
      activeTopicId: topicId,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Start renaming topic
  void startRenamingTopic(String topicId) {
    final newRenamingTopicIds = Set<String>.from(state.renamingTopicIds);
    newRenamingTopicIds.add(topicId);

    state = state.copyWith(
      renamingTopicIds: newRenamingTopicIds,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Finish renaming topic
  void finishRenamingTopic(String topicId) {
    final newRenamingTopicIds = Set<String>.from(state.renamingTopicIds);
    newRenamingTopicIds.remove(topicId);

    final newNewlyRenamedTopicIds =
        Set<String>.from(state.newlyRenamedTopicIds);
    newNewlyRenamedTopicIds.add(topicId);

    state = state.copyWith(
      renamingTopicIds: newRenamingTopicIds,
      newlyRenamedTopicIds: newNewlyRenamedTopicIds,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Clear newly renamed topics
  void clearNewlyRenamedTopics() {
    if (state.newlyRenamedTopicIds.isEmpty) return;

    state = state.copyWith(
      newlyRenamedTopicIds: {},
      lastInteractionTime: DateTime.now(),
    );
  }

  // === Message Editing ===

  /// Start editing message
  void startEditingMessage(String messageId, String originalContent) {
    state = state.startEditing(messageId, originalContent);
  }

  /// Update editing content
  void updateEditingContent(String content) {
    if (!state.isEditing) return;

    state = state.copyWith(
      editingContent: content,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Cancel editing
  void cancelEditing() {
    state = state.cancelEditing();
  }

  /// Finish editing
  void finishEditing() {
    state = state.copyWith(
      editingMessageId: null,
      originalEditingContent: null,
      editingContent: null,
      isEditing: false,
      lastInteractionTime: DateTime.now(),
    );
  }

  // === Search Management ===

  /// Start search
  void startSearch() {
    state = state.copyWith(
      isSearching: true,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Stop search
  void stopSearch() {
    state = state.copyWith(
      isSearching: false,
      searchQuery: '',
      searchResults: [],
      currentSearchIndex: 0,
      searchError: null,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Update search query
  void updateSearchQuery(String query) {
    state = state.updateSearchQuery(query);
  }

  /// Set search results
  void setSearchResults(List<RuntimeSearchResult> results) {
    state = state.copyWith(
      searchResults: results,
      currentSearchIndex: 0,
      isSearchLoading: false,
      searchError: null,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Set search loading
  void setSearchLoading(bool loading) {
    state = state.copyWith(
      isSearchLoading: loading,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Set search error
  void setSearchError(String? error) {
    state = state.copyWith(
      searchError: error,
      isSearchLoading: false,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Navigate to next search result
  void nextSearchResult() {
    if (!state.hasSearchResults) return;

    final nextIndex =
        (state.currentSearchIndex + 1) % state.searchResults.length;
    state = state.copyWith(
      currentSearchIndex: nextIndex,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Navigate to previous search result
  void previousSearchResult() {
    if (!state.hasSearchResults) return;

    final prevIndex = state.currentSearchIndex > 0
        ? state.currentSearchIndex - 1
        : state.searchResults.length - 1;
    state = state.copyWith(
      currentSearchIndex: prevIndex,
      lastInteractionTime: DateTime.now(),
    );
  }

  // === Message Operations ===

  /// Start message operation
  void startMessageOperation(String messageId, String operationType) {
    Set<String> operationSet;

    switch (operationType) {
      case 'processing':
        operationSet = Set.from(state.processingMessageIds);
        break;
      case 'regenerating':
        operationSet = Set.from(state.regeneratingMessageIds);
        break;
      case 'translating':
        operationSet = Set.from(state.translatingMessageIds);
        break;
      case 'deleting':
        operationSet = Set.from(state.deletingMessageIds);
        break;
      default:
        return;
    }

    operationSet.add(messageId);

    state = state.copyWith(
      processingMessageIds: operationType == 'processing'
          ? operationSet
          : state.processingMessageIds,
      regeneratingMessageIds: operationType == 'regenerating'
          ? operationSet
          : state.regeneratingMessageIds,
      translatingMessageIds: operationType == 'translating'
          ? operationSet
          : state.translatingMessageIds,
      deletingMessageIds:
          operationType == 'deleting' ? operationSet : state.deletingMessageIds,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Finish message operation
  void finishMessageOperation(String messageId, String operationType) {
    Set<String> operationSet;

    switch (operationType) {
      case 'processing':
        operationSet = Set.from(state.processingMessageIds);
        break;
      case 'regenerating':
        operationSet = Set.from(state.regeneratingMessageIds);
        break;
      case 'translating':
        operationSet = Set.from(state.translatingMessageIds);
        break;
      case 'deleting':
        operationSet = Set.from(state.deletingMessageIds);
        break;
      default:
        return;
    }

    operationSet.remove(messageId);

    state = state.copyWith(
      processingMessageIds: operationType == 'processing'
          ? operationSet
          : state.processingMessageIds,
      regeneratingMessageIds: operationType == 'regenerating'
          ? operationSet
          : state.regeneratingMessageIds,
      translatingMessageIds: operationType == 'translating'
          ? operationSet
          : state.translatingMessageIds,
      deletingMessageIds:
          operationType == 'deleting' ? operationSet : state.deletingMessageIds,
      lastInteractionTime: DateTime.now(),
    );
  }

  // === UI State Management ===

  /// Set modal state
  void setModalState(bool isOpen, {String? modalType}) {
    state = state.copyWith(
      isModalOpen: isOpen,
      currentModalType: isOpen ? modalType : null,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Toggle sidebar
  void toggleSidebar() {
    state = state.copyWith(
      isSidebarCollapsed: !state.isSidebarCollapsed,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Set sidebar collapsed
  void setSidebarCollapsed(bool collapsed) {
    if (state.isSidebarCollapsed == collapsed) return;

    state = state.copyWith(
      isSidebarCollapsed: collapsed,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Toggle settings panel
  void toggleSettingsPanel() {
    state = state.copyWith(
      isSettingsPanelOpen: !state.isSettingsPanelOpen,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Set view mode
  void setViewMode(ViewMode viewMode) {
    if (state.currentViewMode == viewMode) return;

    state = state.copyWith(
      currentViewMode: viewMode,
      lastInteractionTime: DateTime.now(),
    );
  }

  // === Drag and Drop ===

  /// Start drag operation
  void startDrag(String itemType, Map<String, dynamic> itemData) {
    state = state.copyWith(
      isDragging: true,
      dragItemType: itemType,
      dragItemData: itemData,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// End drag operation
  void endDrag() {
    state = state.copyWith(
      isDragging: false,
      dragItemType: null,
      dragItemData: {},
      lastInteractionTime: DateTime.now(),
    );
  }

  // === Notifications ===

  /// Add notification
  void addNotification(RuntimeNotification notification) {
    state = state.addNotification(notification);
  }

  /// Remove notification
  void removeNotification(String notificationId) {
    state = state.removeNotification(notificationId);
  }

  /// Toggle notifications muted
  void toggleNotificationsMuted() {
    state = state.copyWith(
      notificationsMuted: !state.notificationsMuted,
      lastInteractionTime: DateTime.now(),
    );
  }

  // === Debug and Performance ===

  /// Toggle debug mode
  void toggleDebugMode() {
    state = state.copyWith(
      isDebugMode: !state.isDebugMode,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Toggle performance metrics
  void togglePerformanceMetrics() {
    state = state.copyWith(
      showPerformanceMetrics: !state.showPerformanceMetrics,
      lastInteractionTime: DateTime.now(),
    );
  }

  // === Keyboard Shortcuts ===

  /// Set keyboard shortcuts enabled
  void setKeyboardShortcutsEnabled(bool enabled) {
    if (state.keyboardShortcutsEnabled == enabled) return;

    state = state.copyWith(
      keyboardShortcutsEnabled: enabled,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Update pressed modifier keys
  void updatePressedModifierKeys(Set<String> keys) {
    state = state.copyWith(
      pressedModifierKeys: keys,
      lastInteractionTime: DateTime.now(),
    );
  }

  // === Cleanup and Reset ===

  /// Reset runtime state
  void reset() {
    state = const RuntimeState();
  }

  /// Clear all selections and operations
  void clearAllOperations() {
    state = state.copyWith(
      selectedMessageIds: {},
      isMultiSelectMode: false,
      processingMessageIds: {},
      regeneratingMessageIds: {},
      translatingMessageIds: {},
      deletingMessageIds: {},
      lastInteractionTime: DateTime.now(),
    );
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}

/// Runtime state provider
final runtimeStateProvider =
    StateNotifierProvider<RuntimeStateNotifier, RuntimeState>((ref) {
  return RuntimeStateNotifier(ref);
});

// === Convenience Providers ===

/// Multi-select mode provider
final multiSelectModeProvider = Provider<bool>((ref) {
  return ref.watch(runtimeStateProvider).isMultiSelectMode;
});

/// Selected message IDs provider
final selectedMessageIdsProvider = Provider<Set<String>>((ref) {
  return ref.watch(runtimeStateProvider).selectedMessageIds;
});

/// Has selected messages provider
final hasSelectedMessagesProvider = Provider<bool>((ref) {
  return ref.watch(runtimeStateProvider).hasSelectedMessages;
});

/// Active topic ID provider
final activeTopicIdProvider = Provider<String?>((ref) {
  return ref.watch(runtimeStateProvider).activeTopicId;
});

/// Is editing provider
final isEditingProvider = Provider<bool>((ref) {
  return ref.watch(runtimeStateProvider).isEditing;
});

/// Editing message ID provider
final editingMessageIdProvider = Provider<String?>((ref) {
  return ref.watch(runtimeStateProvider).editingMessageId;
});

/// Editing content provider
final editingContentProvider = Provider<String?>((ref) {
  return ref.watch(runtimeStateProvider).editingContent;
});

/// Is searching provider (legacy - use search_state_provider instead)
@Deprecated('Use isSearchingProvider from search_state_provider instead')
final runtimeIsSearchingProvider = Provider<bool>((ref) {
  return ref.watch(runtimeStateProvider).isSearching;
});

/// Search query provider (legacy - use search_state_provider instead)
@Deprecated('Use searchQueryProvider from search_state_provider instead')
final runtimeSearchQueryProvider = Provider<String>((ref) {
  return ref.watch(runtimeStateProvider).searchQuery;
});

/// Search results provider (legacy - use search_state_provider instead)
@Deprecated('Use searchResultsProvider from search_state_provider instead')
final runtimeSearchResultsProvider = Provider<List<RuntimeSearchResult>>((ref) {
  return ref.watch(runtimeStateProvider).searchResults;
});

/// Has search results provider (legacy - use search_state_provider instead)
@Deprecated('Use hasSearchResultsProvider from search_state_provider instead')
final runtimeHasSearchResultsProvider = Provider<bool>((ref) {
  return ref.watch(runtimeStateProvider).hasSearchResults;
});

/// Current search result provider (legacy - use search_state_provider instead)
@Deprecated(
    'Use currentSearchResultProvider from search_state_provider instead')
final runtimeCurrentSearchResultProvider =
    Provider<RuntimeSearchResult?>((ref) {
  return ref.watch(runtimeStateProvider).currentSearchResult;
});

/// Has active operations provider
final hasActiveOperationsProvider = Provider<bool>((ref) {
  return ref.watch(runtimeStateProvider).hasActiveOperations;
});

/// Is modal open provider
final isModalOpenProvider = Provider<bool>((ref) {
  return ref.watch(runtimeStateProvider).isModalOpen;
});

/// Current modal type provider
final currentModalTypeProvider = Provider<String?>((ref) {
  return ref.watch(runtimeStateProvider).currentModalType;
});

/// Is sidebar collapsed provider
final isSidebarCollapsedProvider = Provider<bool>((ref) {
  return ref.watch(runtimeStateProvider).isSidebarCollapsed;
});

/// Current view mode provider
final currentViewModeProvider = Provider<ViewMode>((ref) {
  return ref.watch(runtimeStateProvider).currentViewMode;
});

/// Is dragging provider
final isDraggingProvider = Provider<bool>((ref) {
  return ref.watch(runtimeStateProvider).isDragging;
});

/// Active notifications provider
final activeNotificationsProvider = Provider<List<RuntimeNotification>>((ref) {
  return ref.watch(runtimeStateProvider).activeNotifications;
});

/// Is debug mode provider
final isDebugModeProvider = Provider<bool>((ref) {
  return ref.watch(runtimeStateProvider).isDebugMode;
});

// === Selector Providers ===

/// Is message selected provider
final isMessageSelectedProvider =
    Provider.family<bool, String>((ref, messageId) {
  return ref.watch(runtimeStateProvider).isMessageSelected(messageId);
});

/// Is message being processed provider
final isMessageBeingProcessedProvider =
    Provider.family<bool, String>((ref, messageId) {
  return ref.watch(runtimeStateProvider).isMessageBeingProcessed(messageId);
});

/// Is topic being renamed provider
final isTopicBeingRenamedProvider =
    Provider.family<bool, String>((ref, topicId) {
  return ref.watch(runtimeStateProvider).isTopicBeingRenamed(topicId);
});

/// Was topic recently renamed provider
final wasTopicRecentlyRenamedProvider =
    Provider.family<bool, String>((ref, topicId) {
  return ref.watch(runtimeStateProvider).wasTopicRecentlyRenamed(topicId);
});
