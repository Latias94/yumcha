import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/streaming_state.dart';
import '../services/streaming_service.dart';
import '../services/deduplication_manager.dart';

/// Streaming state notifier for managing streaming operations
///
/// This notifier manages all streaming-related state including active streams,
/// streaming metrics, and stream lifecycle management.
class StreamingStateNotifier extends StateNotifier<StreamingState> {
  final Ref _ref;
  final DeduplicationManager _deduplicationManager;

  StreamingStateNotifier(this._ref)
      : _deduplicationManager = DeduplicationManager.instance,
        super(const StreamingState());

  // === Stream Lifecycle Management ===

  /// Initialize a new streaming message
  void initializeStream({
    required String messageId,
    required String conversationId,
    required String assistantId,
    String? modelId,
    Map<String, dynamic>? metadata,
  }) {
    // Check if we can start a new stream
    if (!state.canStartNewStream) {
      throw Exception(
          'Cannot start new stream: maximum concurrent streams reached');
    }

    // Check for duplicate stream initialization
    if (state.isMessageStreaming(messageId)) {
      return; // Stream already active
    }

    state = state.initializeStream(
      messageId: messageId,
      conversationId: conversationId,
      assistantId: assistantId,
      modelId: modelId,
      metadata: metadata,
    );
  }

  /// Update streaming content
  void updateStreamContent({
    required String messageId,
    String? contentDelta,
    String? fullContent,
    String? thinking,
  }) {
    if (!state.isMessageStreaming(messageId)) {
      return; // Stream not active
    }

    // Check for duplicate updates
    final updateKey =
        '${messageId}_${contentDelta ?? fullContent ?? ''}_${DateTime.now().millisecondsSinceEpoch}';
    if (!_deduplicationManager.shouldAllowStreamingUpdate(
      messageId: messageId,
      content: contentDelta ?? fullContent ?? '',
      throwOnDuplicate: false,
    )) {
      return; // Skip duplicate update
    }

    state = state.updateStreamContent(
      messageId: messageId,
      contentDelta: contentDelta,
      fullContent: fullContent,
      thinking: thinking,
    );
  }

  /// Complete a streaming message
  void completeStream(String messageId) {
    if (!state.isMessageStreaming(messageId)) {
      return; // Stream not active
    }

    state = state.completeStream(messageId);
  }

  /// Handle streaming error
  void errorStream(String messageId, String errorMessage) {
    if (!state.isMessageStreaming(messageId)) {
      return; // Stream not active
    }

    state = state.errorStream(messageId, errorMessage);
  }

  /// Cancel a streaming message
  void cancelStream(String messageId) {
    if (!state.isMessageStreaming(messageId)) {
      return; // Stream not active
    }

    state = state.cancelStream(messageId);
  }

  /// Cancel all active streams
  void cancelAllStreams() {
    if (state.activeStreams.isEmpty) return;

    state = state.clearAllStreams();
  }

  // === Stream Status Management ===

  /// Set global streaming status
  void setStreamingStatus(StreamingStatus status) {
    if (state.status == status) return;

    state = state.copyWith(
      status: status,
      lastStreamTime: DateTime.now(),
    );
  }

  /// Set global streaming error
  void setStreamingError(String? error) {
    state = state.copyWith(
      error: error,
      lastStreamTime: DateTime.now(),
    );
  }

  /// Clear global streaming error
  void clearStreamingError() {
    if (state.error == null) return;

    state = state.copyWith(
      error: null,
      lastStreamTime: DateTime.now(),
    );
  }

  // === Configuration Management ===

  /// Update maximum allowed concurrent streams
  void setMaxAllowedConcurrentStreams(int maxStreams) {
    if (state.maxAllowedConcurrentStreams == maxStreams) return;

    state = state.copyWith(
      maxAllowedConcurrentStreams: maxStreams,
      lastStreamTime: DateTime.now(),
    );
  }

  /// Update stream timeout
  void setStreamTimeout(int timeoutSeconds) {
    if (state.streamTimeoutSeconds == timeoutSeconds) return;

    state = state.copyWith(
      streamTimeoutSeconds: timeoutSeconds,
      lastStreamTime: DateTime.now(),
    );
  }

  // === Utility Methods ===

  /// Get stream by message ID
  StreamingMessage? getStream(String messageId) {
    return state.getStream(messageId);
  }

  /// Get streams for conversation
  List<StreamingMessage> getStreamsForConversation(String conversationId) {
    return state.getStreamsForConversation(conversationId);
  }

  /// Check if message is streaming
  bool isMessageStreaming(String messageId) {
    return state.isMessageStreaming(messageId);
  }

  /// Check if streaming is active
  bool get isStreaming => state.isStreaming;

  /// Check if can start new stream
  bool get canStartNewStream => state.canStartNewStream;

  /// Check if has errors
  bool get hasError => state.hasError;

  /// Get active stream count
  int get activeStreamCount => state.activeStreamCount;

  /// Get total streams processed
  int get totalStreams => state.totalStreams;

  /// Get streaming metrics
  StreamingMetrics get metrics => state.metrics;

  // === Timeout Management ===

  /// Handle timed out streams
  void handleTimedOutStreams() {
    final timedOutStreams = state.timedOutStreams;

    for (final stream in timedOutStreams) {
      errorStream(stream.messageId, 'Stream timed out');
    }
  }

  /// Get oldest active stream
  StreamingMessage? get oldestActiveStream => state.oldestActiveStream;

  // === Cleanup and Reset ===

  /// Reset streaming state
  void reset() {
    state = const StreamingState();
    _deduplicationManager.clearStreamingDeduplication();
  }

  /// Clear all streaming data
  void clearAll() {
    state = const StreamingState();
    _deduplicationManager.clearAll();
  }

  @override
  void dispose() {
    // Cancel all active streams before disposing
    cancelAllStreams();
    super.dispose();
  }
}

/// Streaming state provider
final streamingStateProvider =
    StateNotifierProvider<StreamingStateNotifier, StreamingState>((ref) {
  return StreamingStateNotifier(ref);
});

/// Streaming service provider
final streamingServiceProvider = Provider<StreamingService>((ref) {
  return StreamingService();
});

// === Convenience Providers ===

/// Active streams provider
final activeStreamsProvider = Provider<Map<String, StreamingMessage>>((ref) {
  return ref.watch(streamingStateProvider).activeStreams;
});

/// Active streams list provider
final activeStreamsListProvider = Provider<List<StreamingMessage>>((ref) {
  return ref.watch(streamingStateProvider).activeStreamsList;
});

/// Streaming status provider
final streamingStatusProvider = Provider<StreamingStatus>((ref) {
  return ref.watch(streamingStateProvider).status;
});

/// Is streaming provider
final isStreamingProvider = Provider<bool>((ref) {
  return ref.watch(streamingStateProvider).isStreaming;
});

/// Can start new stream provider
final canStartNewStreamProvider = Provider<bool>((ref) {
  return ref.watch(streamingStateProvider).canStartNewStream;
});

/// Streaming error provider
final streamingErrorProvider = Provider<String?>((ref) {
  return ref.watch(streamingStateProvider).error;
});

/// Streaming has error provider
final streamingHasErrorProvider = Provider<bool>((ref) {
  return ref.watch(streamingStateProvider).hasError;
});

/// Active stream count provider
final activeStreamCountProvider = Provider<int>((ref) {
  return ref.watch(streamingStateProvider).activeStreamCount;
});

/// Total streams provider
final totalStreamsProvider = Provider<int>((ref) {
  return ref.watch(streamingStateProvider).totalStreams;
});

/// Max concurrent streams provider
final maxConcurrentStreamsProvider = Provider<int>((ref) {
  return ref.watch(streamingStateProvider).maxConcurrentStreams;
});

/// Streaming metrics provider
final streamingMetricsProvider = Provider<StreamingMetrics>((ref) {
  return ref.watch(streamingStateProvider).metrics;
});

/// Recent completed streams provider
final recentCompletedStreamsProvider = Provider<List<StreamingMessage>>((ref) {
  return ref.watch(streamingStateProvider).recentCompletedStreams;
});

/// Last stream time provider
final lastStreamTimeProvider = Provider<DateTime?>((ref) {
  return ref.watch(streamingStateProvider).lastStreamTime;
});

// === Selector Providers ===

/// Get stream by message ID provider
final streamByMessageIdProvider =
    Provider.family<StreamingMessage?, String>((ref, messageId) {
  return ref.watch(streamingStateProvider).getStream(messageId);
});

/// Is message streaming provider
final isMessageStreamingProvider =
    Provider.family<bool, String>((ref, messageId) {
  return ref.watch(streamingStateProvider).isMessageStreaming(messageId);
});

/// Get streams for conversation provider
final streamsForConversationProvider =
    Provider.family<List<StreamingMessage>, String>((ref, conversationId) {
  return ref
      .watch(streamingStateProvider)
      .getStreamsForConversation(conversationId);
});

/// Stream content provider
final streamContentProvider = Provider.family<String, String>((ref, messageId) {
  final stream = ref.watch(streamByMessageIdProvider(messageId));
  return stream?.content ?? '';
});

/// Stream thinking provider
final streamThinkingProvider =
    Provider.family<String, String>((ref, messageId) {
  final stream = ref.watch(streamByMessageIdProvider(messageId));
  return stream?.thinking ?? '';
});

/// Stream is complete provider
final streamIsCompleteProvider =
    Provider.family<bool, String>((ref, messageId) {
  final stream = ref.watch(streamByMessageIdProvider(messageId));
  return stream?.isComplete ?? false;
});

/// Stream has error provider
final streamHasErrorProvider = Provider.family<bool, String>((ref, messageId) {
  final stream = ref.watch(streamByMessageIdProvider(messageId));
  return stream?.hasError ?? false;
});

/// Stream error message provider
final streamErrorMessageProvider =
    Provider.family<String?, String>((ref, messageId) {
  final stream = ref.watch(streamByMessageIdProvider(messageId));
  return stream?.errorMessage;
});

/// Stream duration provider
final streamDurationProvider =
    Provider.family<Duration?, String>((ref, messageId) {
  final stream = ref.watch(streamByMessageIdProvider(messageId));
  return stream?.duration;
});

/// Stream is active provider
final streamIsActiveProvider = Provider.family<bool, String>((ref, messageId) {
  final stream = ref.watch(streamByMessageIdProvider(messageId));
  return stream?.isActive ?? false;
});
