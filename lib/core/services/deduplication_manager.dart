import 'request_deduplicator.dart';
import 'event_deduplicator.dart';

/// Centralized deduplication manager
///
/// This class provides a unified interface for all deduplication needs in the app.
/// It manages both request deduplication (for API calls) and event deduplication
/// (for state changes and UI updates).
///
/// Inspired by Cherry Studio's approach to preventing duplicate operations.
class DeduplicationManager {
  static DeduplicationManager? _instance;

  /// Singleton instance
  static DeduplicationManager get instance {
    _instance ??= DeduplicationManager._internal();
    return _instance!;
  }

  DeduplicationManager._internal() {
    _initialize();
  }

  // === Request Deduplicators ===
  late final ChatMessageDeduplicator _chatMessageDeduplicator;
  late final StreamingUpdateDeduplicator _streamingUpdateDeduplicator;
  late final RequestDeduplicator _generalRequestDeduplicator;

  // === Event Deduplicators ===
  late final ChatEventDeduplicator _chatEventDeduplicator;
  late final UIEventDeduplicator _uiEventDeduplicator;
  late final EventDeduplicator _generalEventDeduplicator;

  /// Initialize all deduplicators
  void _initialize() {
    // Request deduplicators
    _chatMessageDeduplicator = ChatMessageDeduplicator();
    _streamingUpdateDeduplicator = StreamingUpdateDeduplicator();
    _generalRequestDeduplicator = RequestDeduplicator();

    // Event deduplicators
    _chatEventDeduplicator = ChatEventDeduplicator();
    _uiEventDeduplicator = UIEventDeduplicator();
    _generalEventDeduplicator = EventDeduplicator();
  }

  // === Chat Message Deduplication ===

  /// Check if a chat message should be allowed
  bool shouldAllowChatMessage({
    required String content,
    required String conversationId,
    String? assistantId,
    String? modelId,
    String? userId,
    bool throwOnDuplicate = true,
  }) {
    return _chatMessageDeduplicator.shouldAllowChatMessage(
      content: content,
      conversationId: conversationId,
      assistantId: assistantId,
      modelId: modelId,
      userId: userId,
      throwOnDuplicate: throwOnDuplicate,
    );
  }

  /// Generate a chat message request key
  String generateChatMessageKey({
    required String content,
    required String conversationId,
    String? assistantId,
    String? modelId,
    String? userId,
  }) {
    return _chatMessageDeduplicator.generateRequestKey(
      content: content,
      conversationId: conversationId,
      assistantId: assistantId,
      modelId: modelId,
      userId: userId,
    );
  }

  // === Streaming Update Deduplication ===

  /// Check if a streaming update should be allowed
  bool shouldAllowStreamingUpdate({
    required String messageId,
    required String content,
    bool throwOnDuplicate = false,
  }) {
    return _streamingUpdateDeduplicator.shouldAllowStreamingUpdate(
      messageId: messageId,
      content: content,
      throwOnDuplicate: throwOnDuplicate,
    );
  }

  // === General Request Deduplication ===

  /// Check if a general request should be allowed
  bool shouldAllowRequest(
    String requestKey, {
    Map<String, dynamic>? metadata,
    String? userId,
    String? conversationId,
    bool throwOnDuplicate = true,
  }) {
    return _generalRequestDeduplicator.shouldAllowRequest(
      requestKey,
      metadata: metadata,
      userId: userId,
      conversationId: conversationId,
      throwOnDuplicate: throwOnDuplicate,
    );
  }

  /// Generate a general request key
  String generateRequestKey({
    required String content,
    String? conversationId,
    String? assistantId,
    String? modelId,
    String? userId,
    Map<String, dynamic>? additionalContext,
  }) {
    return _generalRequestDeduplicator.generateRequestKey(
      content: content,
      conversationId: conversationId,
      assistantId: assistantId,
      modelId: modelId,
      userId: userId,
      additionalContext: additionalContext,
    );
  }

  // === Chat Event Deduplication ===

  /// Check if a chat event should be emitted
  bool shouldEmitChatEvent(dynamic event) {
    return _chatEventDeduplicator.shouldEmitEvent(event);
  }

  /// Check if a specific chat event type should be emitted
  bool shouldEmitChatEventType(
      String eventType, Map<String, dynamic> eventData) {
    return _chatEventDeduplicator.shouldEmitEventType(eventType, eventData);
  }

  // === UI Event Deduplication ===

  /// Check if a UI event should be emitted
  bool shouldEmitUIEvent(dynamic event) {
    return _uiEventDeduplicator.shouldEmitEvent(event);
  }

  /// Check if a specific UI event type should be emitted
  bool shouldEmitUIEventType(String eventType, Map<String, dynamic> eventData) {
    return _uiEventDeduplicator.shouldEmitEventType(eventType, eventData);
  }

  // === General Event Deduplication ===

  /// Check if a general event should be emitted
  bool shouldEmitEvent(dynamic event) {
    return _generalEventDeduplicator.shouldEmitEvent(event);
  }

  /// Check if a specific event type should be emitted
  bool shouldEmitEventType(String eventType, Map<String, dynamic> eventData) {
    return _generalEventDeduplicator.shouldEmitEventType(eventType, eventData);
  }

  // === Force Operations (Bypass Deduplication) ===

  /// Force emit a chat event (bypass deduplication)
  void forceEmitChatEvent(dynamic event) {
    _chatEventDeduplicator.forceEmitEvent(event);
  }

  /// Force emit a UI event (bypass deduplication)
  void forceEmitUIEvent(dynamic event) {
    _uiEventDeduplicator.forceEmitEvent(event);
  }

  // === Cleanup Operations ===

  /// Clear all chat-related deduplication data
  void clearChatDeduplication() {
    _chatMessageDeduplicator.clearAll();
    _chatEventDeduplicator.clearAll();
  }

  /// Clear all streaming-related deduplication data
  void clearStreamingDeduplication() {
    _streamingUpdateDeduplicator.clearAll();
  }

  /// Clear all UI-related deduplication data
  void clearUIDeduplication() {
    _uiEventDeduplicator.clearAll();
  }

  /// Clear all deduplication data
  void clearAll() {
    _chatMessageDeduplicator.clearAll();
    _streamingUpdateDeduplicator.clearAll();
    _generalRequestDeduplicator.clearAll();
    _chatEventDeduplicator.clearAll();
    _uiEventDeduplicator.clearAll();
    _generalEventDeduplicator.clearAll();
  }

  // === Statistics and Monitoring ===

  /// Get comprehensive statistics
  Map<String, dynamic> getStatistics() {
    return {
      'chatMessages': _chatMessageDeduplicator.getStatistics(),
      'streamingUpdates': _streamingUpdateDeduplicator.getStatistics(),
      'generalRequests': _generalRequestDeduplicator.getStatistics(),
      'chatEvents': _chatEventDeduplicator.getStatistics(),
      'uiEvents': _uiEventDeduplicator.getStatistics(),
      'generalEvents': _generalEventDeduplicator.getStatistics(),
    };
  }

  /// Get statistics for a specific component
  Map<String, dynamic> getComponentStatistics(String component) {
    switch (component.toLowerCase()) {
      case 'chat':
      case 'chatmessages':
        return _chatMessageDeduplicator.getStatistics();
      case 'streaming':
      case 'streamingupdates':
        return _streamingUpdateDeduplicator.getStatistics();
      case 'requests':
      case 'generalrequests':
        return _generalRequestDeduplicator.getStatistics();
      case 'chatevents':
        return _chatEventDeduplicator.getStatistics();
      case 'ui':
      case 'uievents':
        return _uiEventDeduplicator.getStatistics();
      case 'events':
      case 'generalevents':
        return _generalEventDeduplicator.getStatistics();
      default:
        return {};
    }
  }

  /// Get summary statistics
  Map<String, dynamic> getSummaryStatistics() {
    final stats = getStatistics();

    int totalRequests = 0;
    int totalDuplicateRequests = 0;
    int totalEvents = 0;
    int totalDuplicateEvents = 0;

    // Sum up request statistics
    for (final component in [
      'chatMessages',
      'streamingUpdates',
      'generalRequests'
    ]) {
      final componentStats = stats[component] as Map<String, dynamic>? ?? {};
      totalRequests += (componentStats['totalRequests'] as int? ?? 0);
      totalDuplicateRequests +=
          (componentStats['duplicateRequests'] as int? ?? 0);
    }

    // Sum up event statistics
    for (final component in ['chatEvents', 'uiEvents', 'generalEvents']) {
      final componentStats = stats[component] as Map<String, dynamic>? ?? {};
      totalEvents += (componentStats['totalEvents'] as int? ?? 0);
      totalDuplicateEvents += (componentStats['duplicateEvents'] as int? ?? 0);
    }

    return {
      'totalRequests': totalRequests,
      'totalDuplicateRequests': totalDuplicateRequests,
      'requestDuplicateRate':
          totalRequests > 0 ? totalDuplicateRequests / totalRequests : 0.0,
      'totalEvents': totalEvents,
      'totalDuplicateEvents': totalDuplicateEvents,
      'eventDuplicateRate':
          totalEvents > 0 ? totalDuplicateEvents / totalEvents : 0.0,
      'overallDuplicateRate': (totalRequests + totalEvents) > 0
          ? (totalDuplicateRequests + totalDuplicateEvents) /
              (totalRequests + totalEvents)
          : 0.0,
    };
  }

  // === Configuration ===

  /// Configure event type windows
  void configureEventTypeWindows(
      String component, Map<String, Duration> windows) {
    switch (component.toLowerCase()) {
      case 'chat':
      case 'chatevents':
        _chatEventDeduplicator.configureEventTypes(windows);
        break;
      case 'ui':
      case 'uievents':
        _uiEventDeduplicator.configureEventTypes(windows);
        break;
      case 'general':
      case 'generalevents':
        _generalEventDeduplicator.configureEventTypes(windows);
        break;
    }
  }

  // === Disposal ===

  /// Dispose of all deduplicators
  void dispose() {
    _chatMessageDeduplicator.dispose();
    _streamingUpdateDeduplicator.dispose();
    _generalRequestDeduplicator.dispose();
    _chatEventDeduplicator.dispose();
    _uiEventDeduplicator.dispose();
    _generalEventDeduplicator.dispose();
    _instance = null;
  }
}
