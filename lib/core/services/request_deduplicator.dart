import 'dart:async';
import 'dart:collection';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Exception thrown when a duplicate request is detected
class DuplicateRequestException implements Exception {
  final String message;
  final String requestKey;
  final DateTime originalRequestTime;

  const DuplicateRequestException(
    this.message,
    this.requestKey,
    this.originalRequestTime,
  );

  @override
  String toString() => 'DuplicateRequestException: $message (key: $requestKey)';
}

/// Request information for tracking
class RequestInfo {
  final String key;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final String? userId;
  final String? conversationId;

  const RequestInfo({
    required this.key,
    required this.timestamp,
    this.metadata = const {},
    this.userId,
    this.conversationId,
  });

  /// Check if this request has expired
  bool isExpired(Duration window) {
    return DateTime.now().difference(timestamp) > window;
  }

  @override
  String toString() => 'RequestInfo(key: $key, timestamp: $timestamp)';
}

/// Request deduplicator to prevent duplicate API calls
///
/// This class prevents duplicate requests from being sent within a specified time window.
/// It's inspired by Cherry Studio's approach but adapted for Dart/Flutter.
///
/// Key features:
/// - Time-based deduplication window
/// - Automatic cleanup of expired requests
/// - Support for different request types
/// - Configurable per-user and per-conversation deduplication
/// - Memory-efficient with LRU cache behavior
class RequestDeduplicator {
  /// Default deduplication window
  static const Duration defaultWindow = Duration(seconds: 2);

  /// Maximum number of requests to track
  static const int defaultMaxRequests = 1000;

  /// Cleanup interval
  static const Duration defaultCleanupInterval = Duration(minutes: 5);

  final Duration _deduplicationWindow;
  final int _maxRequests;
  final Duration _cleanupInterval;

  /// Active requests map (requestKey -> RequestInfo)
  final Map<String, RequestInfo> _activeRequests = LinkedHashMap();

  /// Cleanup timer
  Timer? _cleanupTimer;

  /// Statistics
  int _totalRequests = 0;
  int _duplicateRequests = 0;
  int _cleanupOperations = 0;

  RequestDeduplicator({
    Duration deduplicationWindow = defaultWindow,
    int maxRequests = defaultMaxRequests,
    Duration cleanupInterval = defaultCleanupInterval,
  })  : _deduplicationWindow = deduplicationWindow,
        _maxRequests = maxRequests,
        _cleanupInterval = cleanupInterval {
    _startCleanupTimer();
  }

  /// Check if a request should be allowed
  ///
  /// Returns true if the request is new or outside the deduplication window.
  /// Returns false if it's a duplicate within the window.
  ///
  /// Throws [DuplicateRequestException] if [throwOnDuplicate] is true.
  bool shouldAllowRequest(
    String requestKey, {
    Map<String, dynamic>? metadata,
    String? userId,
    String? conversationId,
    bool throwOnDuplicate = true,
  }) {
    _totalRequests++;

    final now = DateTime.now();
    final existingRequest = _activeRequests[requestKey];

    // Check if request already exists and is within window
    if (existingRequest != null &&
        !existingRequest.isExpired(_deduplicationWindow)) {
      _duplicateRequests++;

      if (throwOnDuplicate) {
        throw DuplicateRequestException(
          'Duplicate request detected within ${_deduplicationWindow.inSeconds}s window',
          requestKey,
          existingRequest.timestamp,
        );
      }

      return false;
    }

    // Add or update request
    final requestInfo = RequestInfo(
      key: requestKey,
      timestamp: now,
      metadata: metadata ?? {},
      userId: userId,
      conversationId: conversationId,
    );

    _activeRequests[requestKey] = requestInfo;

    // Enforce max requests limit (LRU behavior)
    if (_activeRequests.length > _maxRequests) {
      _evictOldestRequests();
    }

    return true;
  }

  /// Generate a request key from content and context
  ///
  /// This creates a unique key based on the request content and context.
  /// Similar requests will generate the same key for deduplication.
  String generateRequestKey({
    required String content,
    String? conversationId,
    String? assistantId,
    String? modelId,
    String? userId,
    Map<String, dynamic>? additionalContext,
  }) {
    final keyData = {
      'content': content.trim(),
      'conversationId': conversationId,
      'assistantId': assistantId,
      'modelId': modelId,
      'userId': userId,
      if (additionalContext != null) ...additionalContext,
    };

    // Create a stable hash of the key data
    final keyString = json.encode(keyData);
    final bytes = utf8.encode(keyString);
    final digest = sha256.convert(bytes);

    return digest.toString().substring(0, 16); // Use first 16 chars for brevity
  }

  /// Generate a simple request key for basic deduplication
  String generateSimpleRequestKey(String content, String conversationId) {
    return generateRequestKey(
      content: content,
      conversationId: conversationId,
    );
  }

  /// Remove a specific request from tracking
  void removeRequest(String requestKey) {
    _activeRequests.remove(requestKey);
  }

  /// Clear all tracked requests
  void clearAll() {
    _activeRequests.clear();
  }

  /// Get current statistics
  Map<String, dynamic> getStatistics() {
    return {
      'totalRequests': _totalRequests,
      'duplicateRequests': _duplicateRequests,
      'activeRequests': _activeRequests.length,
      'duplicateRate':
          _totalRequests > 0 ? _duplicateRequests / _totalRequests : 0.0,
      'cleanupOperations': _cleanupOperations,
      'deduplicationWindowSeconds': _deduplicationWindow.inSeconds,
      'maxRequests': _maxRequests,
    };
  }

  /// Get requests for a specific conversation
  List<RequestInfo> getRequestsForConversation(String conversationId) {
    return _activeRequests.values
        .where((request) => request.conversationId == conversationId)
        .toList();
  }

  /// Get requests for a specific user
  List<RequestInfo> getRequestsForUser(String userId) {
    return _activeRequests.values
        .where((request) => request.userId == userId)
        .toList();
  }

  /// Check if a specific request is being tracked
  bool isRequestTracked(String requestKey) {
    final request = _activeRequests[requestKey];
    return request != null && !request.isExpired(_deduplicationWindow);
  }

  /// Get the time remaining for a tracked request
  Duration? getRequestTimeRemaining(String requestKey) {
    final request = _activeRequests[requestKey];
    if (request == null) return null;

    final elapsed = DateTime.now().difference(request.timestamp);
    final remaining = _deduplicationWindow - elapsed;

    return remaining.isNegative ? null : remaining;
  }

  /// Start the cleanup timer
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer =
        Timer.periodic(_cleanupInterval, (_) => _cleanupExpiredRequests());
  }

  /// Clean up expired requests
  void _cleanupExpiredRequests() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final entry in _activeRequests.entries) {
      if (entry.value.isExpired(_deduplicationWindow)) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _activeRequests.remove(key);
    }

    if (keysToRemove.isNotEmpty) {
      _cleanupOperations++;
    }
  }

  /// Evict oldest requests when max limit is reached
  void _evictOldestRequests() {
    final targetSize =
        (_maxRequests * 0.8).round(); // Remove 20% when limit reached
    final keysToRemove =
        _activeRequests.keys.take(_activeRequests.length - targetSize);

    for (final key in keysToRemove) {
      _activeRequests.remove(key);
    }
  }

  /// Dispose of the deduplicator
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _activeRequests.clear();
  }
}

/// Specialized deduplicator for chat messages
class ChatMessageDeduplicator extends RequestDeduplicator {
  ChatMessageDeduplicator({
    Duration deduplicationWindow = const Duration(seconds: 3),
    int maxRequests = 500,
  }) : super(
          deduplicationWindow: deduplicationWindow,
          maxRequests: maxRequests,
        );

  /// Check if a chat message should be allowed
  bool shouldAllowChatMessage({
    required String content,
    required String conversationId,
    String? assistantId,
    String? modelId,
    String? userId,
    bool throwOnDuplicate = true,
  }) {
    final requestKey = generateRequestKey(
      content: content,
      conversationId: conversationId,
      assistantId: assistantId,
      modelId: modelId,
      userId: userId,
    );

    return shouldAllowRequest(
      requestKey,
      metadata: {
        'type': 'chat_message',
        'contentLength': content.length,
        'timestamp': DateTime.now().toIso8601String(),
      },
      userId: userId,
      conversationId: conversationId,
      throwOnDuplicate: throwOnDuplicate,
    );
  }
}

/// Specialized deduplicator for streaming updates
class StreamingUpdateDeduplicator extends RequestDeduplicator {
  StreamingUpdateDeduplicator({
    Duration deduplicationWindow = const Duration(milliseconds: 100),
    int maxRequests = 1000,
  }) : super(
          deduplicationWindow: deduplicationWindow,
          maxRequests: maxRequests,
        );

  /// Check if a streaming update should be allowed
  bool shouldAllowStreamingUpdate({
    required String messageId,
    required String content,
    bool throwOnDuplicate = false, // Usually don't throw for streaming
  }) {
    // For streaming, we use messageId + content hash as key
    final contentHash = content.hashCode.toString();
    final requestKey = '${messageId}_$contentHash';

    return shouldAllowRequest(
      requestKey,
      metadata: {
        'type': 'streaming_update',
        'messageId': messageId,
        'contentLength': content.length,
      },
      throwOnDuplicate: throwOnDuplicate,
    );
  }
}
