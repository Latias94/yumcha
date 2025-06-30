import 'dart:math' as math;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'streaming_state.freezed.dart';

/// Streaming status enumeration
enum StreamingStatus {
  /// No active streams
  idle,

  /// Streams are active
  active,

  /// Stream encountered an error
  error,

  /// Stream was paused by user
  paused,

  /// Stream was cancelled
  cancelled,
}

/// Individual streaming message context
///
/// Tracks the state of a single streaming message, similar to Cherry Studio's
/// streaming block management but simplified for Riverpod.
@freezed
class StreamingMessage with _$StreamingMessage {
  const factory StreamingMessage({
    /// Unique message ID
    required String messageId,

    /// Conversation this message belongs to
    required String conversationId,

    /// Assistant ID generating this message
    required String assistantId,

    /// Model being used (optional)
    String? modelId,

    /// Current accumulated content
    @Default('') String content,

    /// Thinking process content (for models that support it)
    @Default('') String thinking,

    /// Whether the stream has completed
    @Default(false) bool isComplete,

    /// Whether the stream encountered an error
    @Default(false) bool hasError,

    /// Error message if any
    String? errorMessage,

    /// When the stream started
    @Default(null) DateTime? startTime,

    /// Last update timestamp
    @Default(null) DateTime? lastUpdateTime,

    /// Completion timestamp
    @Default(null) DateTime? completionTime,

    /// Additional metadata
    @Default({}) Map<String, dynamic> metadata,

    /// Content length for performance tracking
    @Default(0) int contentLength,

    /// Number of updates received
    @Default(0) int updateCount,
  }) = _StreamingMessage;

  const StreamingMessage._();

  // === Computed Properties ===

  /// Duration since stream started
  Duration? get duration {
    if (startTime == null) return null;
    final endTime = completionTime ?? DateTime.now();
    return endTime.difference(startTime!);
  }

  /// Whether the stream is currently active
  bool get isActive => !isComplete && !hasError;

  /// Whether the stream has content
  bool get hasContent => content.isNotEmpty;

  /// Whether the stream has thinking content
  bool get hasThinking => thinking.isNotEmpty;

  /// Stream status summary
  String get statusSummary {
    if (hasError) return 'Error: ${errorMessage ?? "Unknown error"}';
    if (isComplete) return 'Completed';
    if (isActive) return 'Streaming...';
    return 'Pending';
  }
}

/// Core streaming state management
///
/// Manages all active streaming messages and their lifecycle.
/// Inspired by Cherry Studio's streaming management but adapted for Riverpod.
@freezed
class StreamingState with _$StreamingState {
  const factory StreamingState({
    // === Active Streams Management ===
    /// Map of active streaming messages (messageId -> StreamingMessage)
    /// Similar to Cherry Studio's block management
    @Default({}) Map<String, StreamingMessage> activeStreams,

    // === Global Streaming Status ===
    /// Overall streaming status
    @Default(StreamingStatus.idle) StreamingStatus status,

    /// Global streaming error
    @Default(null) String? error,

    // === Performance Metrics ===
    /// Total number of streams processed in this session
    @Default(0) int totalStreams,

    /// Current number of active streams
    @Default(0) int activeStreamCount,

    /// Maximum concurrent streams reached
    @Default(0) int maxConcurrentStreams,

    /// Last stream activity timestamp
    @Default(null) DateTime? lastStreamTime,

    // === Configuration ===
    /// Maximum allowed concurrent streams
    @Default(3) int maxAllowedConcurrentStreams,

    /// Stream timeout duration in seconds
    @Default(30) int streamTimeoutSeconds,

    // === Stream History (for debugging) ===
    /// Recently completed streams (limited to last 10)
    @Default([]) List<StreamingMessage> recentCompletedStreams,

    /// Stream performance metrics
    @Default(StreamingMetrics()) StreamingMetrics metrics,
  }) = _StreamingState;

  const StreamingState._();

  // === Computed Properties ===

  /// Get all active streaming messages as a list
  List<StreamingMessage> get activeStreamsList => activeStreams.values.toList();

  /// Check if streaming is currently active
  bool get isStreaming => activeStreamCount > 0;

  /// Check if we can start a new stream
  bool get canStartNewStream => activeStreamCount < maxAllowedConcurrentStreams;

  /// Check if there are any errors
  bool get hasError =>
      error != null || activeStreams.values.any((s) => s.hasError);

  /// Get streams by conversation
  List<StreamingMessage> getStreamsForConversation(String conversationId) {
    return activeStreams.values
        .where((stream) => stream.conversationId == conversationId)
        .toList();
  }

  /// Get stream by message ID
  StreamingMessage? getStream(String messageId) => activeStreams[messageId];

  /// Check if a message is currently streaming
  bool isMessageStreaming(String messageId) =>
      activeStreams.containsKey(messageId);

  /// Get the oldest active stream (for timeout management)
  StreamingMessage? get oldestActiveStream {
    if (activeStreams.isEmpty) return null;

    return activeStreams.values.reduce((a, b) {
      final aTime = a.startTime ?? DateTime.now();
      final bTime = b.startTime ?? DateTime.now();
      return aTime.isBefore(bTime) ? a : b;
    });
  }

  /// Get streams that have timed out
  List<StreamingMessage> get timedOutStreams {
    final now = DateTime.now();
    final timeoutDuration = Duration(seconds: streamTimeoutSeconds);

    return activeStreams.values.where((stream) {
      if (stream.startTime == null) return false;
      return now.difference(stream.startTime!) > timeoutDuration;
    }).toList();
  }
}

/// Streaming performance metrics
@freezed
class StreamingMetrics with _$StreamingMetrics {
  const factory StreamingMetrics({
    /// Average stream duration in milliseconds
    @Default(0) double averageStreamDuration,

    /// Average content length per stream
    @Default(0) double averageContentLength,

    /// Average updates per stream
    @Default(0) double averageUpdatesPerStream,

    /// Total characters streamed
    @Default(0) int totalCharactersStreamed,

    /// Total updates processed
    @Default(0) int totalUpdatesProcessed,

    /// Success rate (completed / total)
    @Default(0.0) double successRate,

    /// Error rate (errors / total)
    @Default(0.0) double errorRate,
  }) = _StreamingMetrics;
}

/// Helper methods for StreamingState manipulation
extension StreamingStateHelpers on StreamingState {
  /// Initialize a new streaming message
  StreamingState initializeStream({
    required String messageId,
    required String conversationId,
    required String assistantId,
    String? modelId,
    Map<String, dynamic>? metadata,
  }) {
    final newStream = StreamingMessage(
      messageId: messageId,
      conversationId: conversationId,
      assistantId: assistantId,
      modelId: modelId,
      startTime: DateTime.now(),
      metadata: metadata ?? {},
    );

    final newActiveStreams = Map<String, StreamingMessage>.from(activeStreams);
    newActiveStreams[messageId] = newStream;

    return copyWith(
      activeStreams: newActiveStreams,
      activeStreamCount: newActiveStreams.length,
      maxConcurrentStreams:
          math.max(maxConcurrentStreams, newActiveStreams.length),
      status: StreamingStatus.active,
      lastStreamTime: DateTime.now(),
    );
  }

  /// Update streaming content
  StreamingState updateStreamContent({
    required String messageId,
    String? contentDelta,
    String? fullContent,
    String? thinking,
  }) {
    final existingStream = activeStreams[messageId];
    if (existingStream == null) return this;

    final updatedStream = existingStream.copyWith(
      content: fullContent ?? (existingStream.content + (contentDelta ?? '')),
      thinking: thinking ?? existingStream.thinking,
      lastUpdateTime: DateTime.now(),
      updateCount: existingStream.updateCount + 1,
      contentLength:
          (fullContent ?? (existingStream.content + (contentDelta ?? '')))
              .length,
    );

    final newActiveStreams = Map<String, StreamingMessage>.from(activeStreams);
    newActiveStreams[messageId] = updatedStream;

    return copyWith(
      activeStreams: newActiveStreams,
      lastStreamTime: DateTime.now(),
    );
  }

  /// Complete a streaming message
  StreamingState completeStream(String messageId) {
    final stream = activeStreams[messageId];
    if (stream == null) return this;

    final completedStream = stream.copyWith(
      isComplete: true,
      completionTime: DateTime.now(),
    );

    final newActiveStreams = Map<String, StreamingMessage>.from(activeStreams);
    newActiveStreams.remove(messageId);

    // Add to recent completed streams (keep only last 10)
    final newRecentCompleted =
        List<StreamingMessage>.from(recentCompletedStreams);
    newRecentCompleted.add(completedStream);
    if (newRecentCompleted.length > 10) {
      newRecentCompleted.removeAt(0);
    }

    return copyWith(
      activeStreams: newActiveStreams,
      activeStreamCount: newActiveStreams.length,
      recentCompletedStreams: newRecentCompleted,
      totalStreams: totalStreams + 1,
      status: newActiveStreams.isEmpty
          ? StreamingStatus.idle
          : StreamingStatus.active,
      lastStreamTime: DateTime.now(),
    );
  }

  /// Handle streaming error
  StreamingState errorStream(String messageId, String errorMessage) {
    final stream = activeStreams[messageId];
    if (stream == null) return this;

    final errorStream = stream.copyWith(
      hasError: true,
      errorMessage: errorMessage,
      completionTime: DateTime.now(),
    );

    final newActiveStreams = Map<String, StreamingMessage>.from(activeStreams);
    newActiveStreams.remove(messageId);

    // Add to recent completed streams
    final newRecentCompleted =
        List<StreamingMessage>.from(recentCompletedStreams);
    newRecentCompleted.add(errorStream);
    if (newRecentCompleted.length > 10) {
      newRecentCompleted.removeAt(0);
    }

    return copyWith(
      activeStreams: newActiveStreams,
      activeStreamCount: newActiveStreams.length,
      recentCompletedStreams: newRecentCompleted,
      totalStreams: totalStreams + 1,
      status: newActiveStreams.isEmpty
          ? StreamingStatus.idle
          : StreamingStatus.active,
      error: errorMessage,
      lastStreamTime: DateTime.now(),
    );
  }

  /// Cancel a streaming message
  StreamingState cancelStream(String messageId) {
    final stream = activeStreams[messageId];
    if (stream == null) return this;

    final cancelledStream = stream.copyWith(
      hasError: true,
      errorMessage: 'Stream cancelled by user',
      completionTime: DateTime.now(),
    );

    final newActiveStreams = Map<String, StreamingMessage>.from(activeStreams);
    newActiveStreams.remove(messageId);

    return copyWith(
      activeStreams: newActiveStreams,
      activeStreamCount: newActiveStreams.length,
      status: newActiveStreams.isEmpty
          ? StreamingStatus.idle
          : StreamingStatus.active,
      lastStreamTime: DateTime.now(),
    );
  }

  /// Clear all streams (for cleanup)
  StreamingState clearAllStreams() {
    return copyWith(
      activeStreams: {},
      activeStreamCount: 0,
      status: StreamingStatus.idle,
      error: null,
    );
  }
}
