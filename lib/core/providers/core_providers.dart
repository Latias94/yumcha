/// Core providers for YumCha state management
///
/// This file exports all core providers that replace the unified chat provider.
/// The new architecture separates concerns into focused state managers:
///
/// - ChatStateProvider: Manages conversations, messages, and chat status
/// - StreamingStateProvider: Manages streaming operations and real-time updates
/// - MessageBlockStateProvider: Manages message blocks using EntityAdapter pattern
/// - RuntimeStateProvider: Manages UI interactions and user operations
/// - UIStateProvider: Manages visual presentation and layout
///
/// This design is inspired by Cherry Studio's Redux architecture but adapted
/// for Riverpod with better separation of concerns and performance optimization.

// === Core State Providers ===
export 'chat_state_provider.dart';
export 'streaming_state_provider.dart';
export 'message_block_state_provider.dart';
export 'runtime_state_provider.dart';
export 'ui_state_provider.dart';
export 'message_operation_state_provider.dart';
export 'search_state_provider.dart';
export 'settings_state_provider.dart';
export 'assistant_state_provider.dart';

// === Core Services ===
export '../services/streaming_service.dart';
export '../services/streaming_content_manager.dart';
export '../services/tool_call_handler.dart';
export '../services/request_deduplicator.dart';
export '../services/event_deduplicator.dart';
export '../services/deduplication_manager.dart';
export '../services/message_operation_service.dart';
export '../services/search_service.dart';
export '../services/settings_service.dart';
export '../services/assistant_service.dart';

// === Core State Models ===
export '../state/chat_state.dart';
export '../state/streaming_state.dart';
export '../state/message_block_state.dart';
export '../state/runtime_state.dart' hide SearchResult, SearchResultType;
export '../state/ui_state.dart';
export '../state/message_operation_state.dart';
export '../state/search_state.dart';
export '../state/settings_state.dart';
export '../state/assistant_state.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_state_provider.dart';
import 'streaming_state_provider.dart';
import 'message_block_state_provider.dart';
import 'runtime_state_provider.dart';
import 'ui_state_provider.dart';
import 'message_operation_state_provider.dart';
import 'search_state_provider.dart';
import 'settings_state_provider.dart';
import 'assistant_state_provider.dart';
import '../services/streaming_service.dart';
import '../services/tool_call_handler.dart';
import '../services/deduplication_manager.dart';
import '../state/chat_state.dart';
import '../state/streaming_state.dart';
import '../state/message_block_state.dart';
import '../state/runtime_state.dart' hide SearchResult, SearchResultType;
import '../state/ui_state.dart';
import '../state/message_operation_state.dart';
import '../state/search_state.dart';
import '../state/settings_state.dart';
import '../state/assistant_state.dart';
import '../../features/chat/domain/entities/message.dart';
import '../../features/chat/domain/entities/conversation_ui_state.dart';

// === Unified Core State Provider ===

/// Core application state that combines all major state components
///
/// This provider gives access to all core state in a single place while
/// maintaining the separation of concerns. Use this when you need to
/// access multiple state components or for dependency injection.
final coreStateProvider = Provider((ref) {
  return CoreState(
    chatState: ref.watch(chatStateProvider),
    streamingState: ref.watch(streamingStateProvider),
    messageBlockState: ref.watch(messageBlockStateProvider),
    runtimeState: ref.watch(runtimeStateProvider),
    uiState: ref.watch(uiStateProvider),
    messageOperationState: ref.watch(messageOperationStateProvider),
    searchState: ref.watch(searchStateProvider),
    settingsState: ref.watch(settingsStateProvider),
    assistantState: ref.watch(assistantStateProvider),
  );
});

/// Core application state container
class CoreState {
  final ChatState chatState;
  final StreamingState streamingState;
  final MessageBlockState messageBlockState;
  final RuntimeState runtimeState;
  final UIState uiState;
  final MessageOperationState messageOperationState;
  final SearchState searchState;
  final SettingsState settingsState;
  final AssistantState assistantState;

  const CoreState({
    required this.chatState,
    required this.streamingState,
    required this.messageBlockState,
    required this.runtimeState,
    required this.uiState,
    required this.messageOperationState,
    required this.searchState,
    required this.settingsState,
    required this.assistantState,
  });

  /// Check if the application is in a ready state
  bool get isReady {
    return chatState.isReady &&
        !streamingState.hasError &&
        !runtimeState.hasActiveOperations &&
        !messageOperationState.hasActiveOperations &&
        settingsState.isReady &&
        assistantState.isReady;
  }

  /// Check if there are any errors across all states
  bool get hasErrors {
    return chatState.hasError ||
        streamingState.hasError ||
        messageBlockState.error != null ||
        uiState.showErrorOverlay;
  }

  /// Get all error messages
  List<String> get errorMessages {
    final errors = <String>[];

    if (chatState.error != null) {
      errors.add('Chat: ${chatState.error}');
    }

    if (streamingState.error != null) {
      errors.add('Streaming: ${streamingState.error}');
    }

    if (messageBlockState.error != null) {
      errors.add('Message Blocks: ${messageBlockState.error}');
    }

    if (uiState.errorOverlayMessage != null) {
      errors.add('UI: ${uiState.errorOverlayMessage}');
    }

    return errors;
  }

  /// Check if any loading operations are in progress
  bool get isLoading {
    return chatState.isLoading ||
        streamingState.isStreaming ||
        messageBlockState.loadingState == MessageBlockLoadingState.loading ||
        uiState.isGlobalLoading;
  }

  /// Get summary statistics
  Map<String, dynamic> get statistics {
    return {
      'messages': {
        'total': chatState.messageCount,
        'current': chatState.currentMessages.length,
        'display': chatState.displayMessages.length,
      },
      'streaming': {
        'active': streamingState.activeStreamCount,
        'total': streamingState.totalStreams,
        'maxConcurrent': streamingState.maxConcurrentStreams,
      },
      'blocks': {
        'total': messageBlockState.totalBlocks,
        'processing': messageBlockState.processingBlocks.length,
        'errors': messageBlockState.errorBlocks.length,
      },
      'runtime': {
        'selectedMessages': runtimeState.selectedMessageIds.length,
        'activeOperations': runtimeState.hasActiveOperations,
        'notifications': runtimeState.activeNotifications.length,
      },
      'ui': {
        'screenSize': uiState.screenSize.name,
        'frameRate': uiState.frameRate,
        'memoryUsage': uiState.memoryUsage,
      },
    };
  }
}

// === Service Providers ===

/// Streaming service provider (singleton)
final streamingServiceProvider = Provider<StreamingService>((ref) {
  return StreamingService();
});

/// Tool call handler provider (singleton)
final toolCallHandlerProvider = Provider<ToolCallHandler>((ref) {
  return ToolCallHandler();
});

/// Deduplication manager provider (singleton)
final deduplicationManagerProvider = Provider<DeduplicationManager>((ref) {
  return DeduplicationManager.instance;
});

// === Convenience Providers for Common Operations ===

/// Current conversation with messages provider
final currentConversationWithMessagesProvider = Provider((ref) {
  final conversation = ref.watch(currentConversationProvider);
  final messages = ref.watch(currentMessagesProvider);

  return {
    'conversation': conversation,
    'messages': messages,
  };
});

/// Chat ready state provider
final chatReadyStateProvider = Provider<bool>((ref) {
  final chatReady = ref.watch(chatReadyProvider);
  final hasErrors = ref.watch(coreStateProvider).hasErrors;

  return chatReady && !hasErrors;
});

/// Global loading state provider
final globalLoadingStateProvider = Provider<bool>((ref) {
  return ref.watch(coreStateProvider).isLoading;
});

/// Global error state provider
final globalErrorStateProvider = Provider<List<String>>((ref) {
  return ref.watch(coreStateProvider).errorMessages;
});

/// Application statistics provider
final applicationStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(coreStateProvider).statistics;
});

// === Migration Helpers ===

/// Legacy unified chat state provider for gradual migration
///
/// This provider maintains compatibility with existing code while
/// the migration to the new architecture is in progress.
@Deprecated(
    'Use specific state providers instead (chatStateProvider, streamingStateProvider, etc.)')
final legacyUnifiedChatProvider = Provider((ref) {
  return LegacyUnifiedChatState(
    chatState: ref.watch(chatStateProvider),
    streamingState: ref.watch(streamingStateProvider),
    messageBlockState: ref.watch(messageBlockStateProvider),
    runtimeState: ref.watch(runtimeStateProvider),
  );
});

/// Legacy unified chat state for backward compatibility
@Deprecated('Use CoreState instead')
class LegacyUnifiedChatState {
  final ChatState chatState;
  final StreamingState streamingState;
  final MessageBlockState messageBlockState;
  final RuntimeState runtimeState;

  const LegacyUnifiedChatState({
    required this.chatState,
    required this.streamingState,
    required this.messageBlockState,
    required this.runtimeState,
  });

  // Legacy getters for backward compatibility
  List<Message> get messages => chatState.currentMessages;
  ConversationUiState? get currentConversation => chatState.currentConversation;
  ChatStatus get status => chatState.status;
  bool get isLoading => chatState.isLoading;
  String? get error => chatState.error;
  bool get isStreaming => streamingState.isStreaming;
  Set<String> get selectedMessageIds => runtimeState.selectedMessageIds;
  bool get isMultiSelectMode => runtimeState.isMultiSelectMode;
}

// === Provider Overrides for Testing ===

/// Provider overrides for testing
///
/// Use these overrides in tests to provide mock implementations
/// of the core services and state providers.
class CoreProviderOverrides {
  static List<Override> get testOverrides => [
        // Add test overrides here when needed
        // Example:
        // streamingServiceProvider.overrideWithValue(MockStreamingService()),
        // toolCallHandlerProvider.overrideWithValue(MockToolCallHandler()),
      ];

  static List<Override> mockOverrides({
    StreamingService? streamingService,
    ToolCallHandler? toolCallHandler,
    DeduplicationManager? deduplicationManager,
  }) {
    final overrides = <Override>[];

    if (streamingService != null) {
      overrides
          .add(streamingServiceProvider.overrideWithValue(streamingService));
    }

    if (toolCallHandler != null) {
      overrides.add(toolCallHandlerProvider.overrideWithValue(toolCallHandler));
    }

    if (deduplicationManager != null) {
      overrides.add(
          deduplicationManagerProvider.overrideWithValue(deduplicationManager));
    }

    return overrides;
  }
}
