import 'dart:async';
import 'dart:developer' as developer;
import '../state/streaming_state.dart';
import 'deduplication_manager.dart';

/// Streaming update data
class StreamingUpdate {
  final String messageId;
  final String? contentDelta;
  final String? fullContent;
  final String? thinking;
  final bool isDone;
  final String? error;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  const StreamingUpdate({
    required this.messageId,
    this.contentDelta,
    this.fullContent,
    this.thinking,
    this.isDone = false,
    this.error,
    this.metadata,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get hasError => error != null;
  bool get hasContent =>
      (contentDelta?.isNotEmpty ?? false) || (fullContent?.isNotEmpty ?? false);

  @override
  String toString() =>
      'StreamingUpdate(messageId: $messageId, isDone: $isDone, hasError: $hasError)';
}

/// Streaming service for managing real-time message updates
///
/// This service handles streaming message updates with proper content accumulation,
/// deduplication, and error handling. It's inspired by Cherry Studio's streaming
/// management but adapted for Dart.
///
/// Key features:
/// - Proper content accumulation (fixes the 35-character truncation issue)
/// - Request deduplication to prevent duplicate updates
/// - Throttled UI updates for performance
/// - Complete error handling and recovery
/// - Memory-efficient streaming state management
class StreamingService {
  /// Current streaming state
  StreamingState _state = const StreamingState();

  /// Update stream controller
  late final StreamController<StreamingUpdate> _updateController;

  /// State change stream controller
  late final StreamController<StreamingState> _stateController;

  /// Throttle timers for UI updates (messageId -> Timer)
  final Map<String, Timer> _throttleTimers = {};

  /// Content accumulators (messageId -> accumulated content)
  final Map<String, String> _contentAccumulators = {};

  /// Thinking accumulators (messageId -> accumulated thinking)
  final Map<String, String> _thinkingAccumulators = {};

  /// Last update timestamps (messageId -> timestamp)
  final Map<String, DateTime> _lastUpdateTimes = {};

  /// Deduplication manager
  late final DeduplicationManager _deduplicationManager;

  /// Throttle delay for UI updates
  static const Duration _throttleDelay = Duration(milliseconds: 50);

  /// Maximum content length for safety
  static const int _maxContentLength = 1000000; // 1MB

  StreamingService() {
    _updateController = StreamController<StreamingUpdate>.broadcast();
    _stateController = StreamController<StreamingState>.broadcast();
    _deduplicationManager = DeduplicationManager.instance;

    // Listen to update stream and handle updates
    _updateController.stream.listen(_handleStreamingUpdate);
  }

  /// Get current state
  StreamingState get state => _state;

  /// Get state stream
  Stream<StreamingState> get stateStream => _stateController.stream;

  /// Update state and notify listeners
  void _updateState(StreamingState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  /// Get the update stream for external listeners
  Stream<StreamingUpdate> get updateStream => _updateController.stream;

  /// Initialize a new streaming message
  Future<void> initializeStreaming({
    required String messageId,
    required String conversationId,
    required String assistantId,
    String? modelId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      developer.log('Initializing streaming for message: $messageId',
          name: 'StreamingService');

      // Initialize content accumulators
      _contentAccumulators[messageId] = '';
      _thinkingAccumulators[messageId] = '';
      _lastUpdateTimes[messageId] = DateTime.now();

      // Update streaming state
      _updateState(_state.initializeStream(
        messageId: messageId,
        conversationId: conversationId,
        assistantId: assistantId,
        modelId: modelId,
        metadata: metadata,
      ));

      developer.log(
          'Streaming initialized successfully for message: $messageId',
          name: 'StreamingService');
    } catch (error) {
      developer.log(
          'Failed to initialize streaming for message: $messageId, error: $error',
          name: 'StreamingService');
      rethrow;
    }
  }

  /// Update streaming content with proper accumulation
  Future<void> updateContent({
    required String messageId,
    String? contentDelta,
    String? fullContent,
    String? thinking,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Check if this update should be allowed (deduplication)
      final updateKey =
          '${messageId}_${contentDelta ?? fullContent ?? ''}_${DateTime.now().millisecondsSinceEpoch}';
      if (!_deduplicationManager.shouldAllowStreamingUpdate(
        messageId: messageId,
        content: contentDelta ?? fullContent ?? '',
        throwOnDuplicate: false,
      )) {
        return; // Skip duplicate update
      }

      // Get current accumulators
      String currentContent = _contentAccumulators[messageId] ?? '';
      String currentThinking = _thinkingAccumulators[messageId] ?? '';

      // Update content accumulator
      if (fullContent != null) {
        // Full content update - replace accumulator
        currentContent = fullContent;
      } else if (contentDelta != null && contentDelta.isNotEmpty) {
        // Delta update - append to accumulator
        currentContent += contentDelta;
      }

      // Update thinking accumulator
      if (thinking != null) {
        currentThinking = thinking;
      }

      // Safety check for content length
      if (currentContent.length > _maxContentLength) {
        developer.log('Content length exceeded maximum, truncating: $messageId',
            name: 'StreamingService');
        currentContent = currentContent.substring(0, _maxContentLength);
      }

      // Update accumulators
      _contentAccumulators[messageId] = currentContent;
      _thinkingAccumulators[messageId] = currentThinking;
      _lastUpdateTimes[messageId] = DateTime.now();

      // Update streaming state
      _updateState(_state.updateStreamContent(
        messageId: messageId,
        fullContent: currentContent,
        thinking: currentThinking,
      ));

      // Throttled UI update
      _scheduleThrottledUpdate(
        messageId: messageId,
        contentDelta: contentDelta,
        fullContent: currentContent,
        thinking: currentThinking.isNotEmpty ? currentThinking : null,
        metadata: metadata,
      );

      developer.log(
          'Content updated for message: $messageId, length: ${currentContent.length}',
          name: 'StreamingService');
    } catch (error) {
      developer.log(
          'Failed to update content for message: $messageId, error: $error',
          name: 'StreamingService');
      await handleError(messageId, error.toString());
    }
  }

  /// Complete streaming for a message
  Future<void> completeStreaming({
    required String messageId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      developer.log('Completing streaming for message: $messageId',
          name: 'StreamingService');

      // Cancel any pending throttled updates
      _throttleTimers[messageId]?.cancel();
      _throttleTimers.remove(messageId);

      // Get final content
      final finalContent = _contentAccumulators[messageId] ?? '';
      final finalThinking = _thinkingAccumulators[messageId] ?? '';

      // Update streaming state
      _updateState(_state.completeStream(messageId));

      // Send final update
      _updateController.add(StreamingUpdate(
        messageId: messageId,
        fullContent: finalContent,
        thinking: finalThinking.isNotEmpty ? finalThinking : null,
        isDone: true,
        metadata: metadata,
      ));

      // Clean up accumulators
      _contentAccumulators.remove(messageId);
      _thinkingAccumulators.remove(messageId);
      _lastUpdateTimes.remove(messageId);

      developer.log(
          'Streaming completed for message: $messageId, final length: ${finalContent.length}',
          name: 'StreamingService');
    } catch (error) {
      developer.log(
          'Failed to complete streaming for message: $messageId, error: $error',
          name: 'StreamingService');
      await handleError(messageId, error.toString());
    }
  }

  /// Handle streaming error
  Future<void> handleError(String messageId, String errorMessage) async {
    try {
      developer.log(
          'Handling streaming error for message: $messageId, error: $errorMessage',
          name: 'StreamingService');

      // Cancel any pending updates
      _throttleTimers[messageId]?.cancel();
      _throttleTimers.remove(messageId);

      // Get partial content
      final partialContent = _contentAccumulators[messageId];
      final partialThinking = _thinkingAccumulators[messageId];

      // Update streaming state
      _updateState(_state.errorStream(messageId, errorMessage));

      // Send error update
      _updateController.add(StreamingUpdate(
        messageId: messageId,
        fullContent: partialContent,
        thinking: partialThinking?.isNotEmpty == true ? partialThinking : null,
        error: errorMessage,
        isDone: true,
      ));

      // Clean up accumulators
      _contentAccumulators.remove(messageId);
      _thinkingAccumulators.remove(messageId);
      _lastUpdateTimes.remove(messageId);

      developer.log('Streaming error handled for message: $messageId',
          name: 'StreamingService');
    } catch (error) {
      developer.log(
          'Failed to handle streaming error for message: $messageId, error: $error',
          name: 'StreamingService');
    }
  }

  /// Cancel streaming for a message
  Future<void> cancelStreaming(String messageId) async {
    try {
      developer.log('Cancelling streaming for message: $messageId',
          name: 'StreamingService');

      // Cancel any pending updates
      _throttleTimers[messageId]?.cancel();
      _throttleTimers.remove(messageId);

      // Update streaming state
      _updateState(_state.cancelStream(messageId));

      // Send cancellation update
      _updateController.add(StreamingUpdate(
        messageId: messageId,
        error: 'Streaming cancelled by user',
        isDone: true,
      ));

      // Clean up accumulators
      _contentAccumulators.remove(messageId);
      _thinkingAccumulators.remove(messageId);
      _lastUpdateTimes.remove(messageId);

      developer.log('Streaming cancelled for message: $messageId',
          name: 'StreamingService');
    } catch (error) {
      developer.log(
          'Failed to cancel streaming for message: $messageId, error: $error',
          name: 'StreamingService');
    }
  }

  /// Get current content for a streaming message
  String? getCurrentContent(String messageId) {
    return _contentAccumulators[messageId];
  }

  /// Get current thinking for a streaming message
  String? getCurrentThinking(String messageId) {
    return _thinkingAccumulators[messageId];
  }

  /// Check if a message is currently streaming
  bool isStreaming(String messageId) {
    return _state.isMessageStreaming(messageId);
  }

  /// Get streaming statistics
  Map<String, dynamic> getStatistics() {
    return {
      'activeStreams': _state.activeStreamCount,
      'totalStreams': _state.totalStreams,
      'maxConcurrentStreams': _state.maxConcurrentStreams,
      'activeAccumulators': _contentAccumulators.length,
      'activeThrottleTimers': _throttleTimers.length,
      'metrics': _state.metrics,
    };
  }

  /// Schedule a throttled UI update
  void _scheduleThrottledUpdate({
    required String messageId,
    String? contentDelta,
    required String fullContent,
    String? thinking,
    Map<String, dynamic>? metadata,
  }) {
    // Cancel existing timer
    _throttleTimers[messageId]?.cancel();

    // Schedule new update
    _throttleTimers[messageId] = Timer(_throttleDelay, () {
      _updateController.add(StreamingUpdate(
        messageId: messageId,
        contentDelta: contentDelta,
        fullContent: fullContent,
        thinking: thinking,
        metadata: metadata,
      ));
      _throttleTimers.remove(messageId);
    });
  }

  /// Handle streaming update from the stream
  void _handleStreamingUpdate(StreamingUpdate update) {
    try {
      // Additional processing can be added here if needed
      developer.log('Handled streaming update for message: ${update.messageId}',
          name: 'StreamingService');
    } catch (error) {
      developer.log('Error handling streaming update: $error',
          name: 'StreamingService');
    }
  }

  /// Dispose of the service
  void dispose() {
    // Cancel all timers
    for (final timer in _throttleTimers.values) {
      timer.cancel();
    }
    _throttleTimers.clear();

    // Clear accumulators
    _contentAccumulators.clear();
    _thinkingAccumulators.clear();
    _lastUpdateTimes.clear();

    // Close stream controller
    _updateController.close();
  }
}
