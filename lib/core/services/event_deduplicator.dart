import 'dart:async';
import 'dart:collection';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Event information for tracking
class EventInfo {
  final String eventKey;
  final String eventType;
  final DateTime timestamp;
  final Map<String, dynamic> eventData;
  final int eventHash;

  const EventInfo({
    required this.eventKey,
    required this.eventType,
    required this.timestamp,
    required this.eventData,
    required this.eventHash,
  });

  /// Check if this event has expired
  bool isExpired(Duration window) {
    return DateTime.now().difference(timestamp) > window;
  }

  @override
  String toString() =>
      'EventInfo(type: $eventType, key: $eventKey, timestamp: $timestamp)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventInfo &&
        other.eventKey == eventKey &&
        other.eventHash == eventHash;
  }

  @override
  int get hashCode => Object.hash(eventKey, eventHash);
}

/// Event deduplicator to prevent duplicate event emissions
///
/// This class prevents duplicate events from being emitted within a specified time window.
/// It's particularly useful for preventing UI update storms and redundant state changes.
///
/// Key features:
/// - Content-based deduplication (same event data = duplicate)
/// - Time-based deduplication window
/// - Event type specific configuration
/// - Automatic cleanup of expired events
/// - Memory-efficient with configurable limits
class EventDeduplicator {
  /// Default deduplication window
  static const Duration defaultWindow = Duration(milliseconds: 500);

  /// Maximum number of events to track
  static const int defaultMaxEvents = 1000;

  /// Cleanup interval
  static const Duration defaultCleanupInterval = Duration(minutes: 2);

  final Duration _deduplicationWindow;
  final int _maxEvents;
  final Duration _cleanupInterval;

  /// Event type specific windows
  final Map<String, Duration> _eventTypeWindows = {};

  /// Recent events map (eventKey -> EventInfo)
  final Map<String, EventInfo> _recentEvents = LinkedHashMap();

  /// Cleanup timer
  Timer? _cleanupTimer;

  /// Statistics
  int _totalEvents = 0;
  int _duplicateEvents = 0;
  int _cleanupOperations = 0;
  final Map<String, int> _eventTypeCounts = {};
  final Map<String, int> _eventTypeDuplicates = {};

  EventDeduplicator({
    Duration deduplicationWindow = defaultWindow,
    int maxEvents = defaultMaxEvents,
    Duration cleanupInterval = defaultCleanupInterval,
  })  : _deduplicationWindow = deduplicationWindow,
        _maxEvents = maxEvents,
        _cleanupInterval = cleanupInterval {
    _startCleanupTimer();
  }

  /// Configure deduplication window for specific event types
  void configureEventType(String eventType, Duration window) {
    _eventTypeWindows[eventType] = window;
  }

  /// Configure multiple event types at once
  void configureEventTypes(Map<String, Duration> eventTypeWindows) {
    _eventTypeWindows.addAll(eventTypeWindows);
  }

  /// Check if an event should be emitted
  ///
  /// Returns true if the event is new or different from recent events.
  /// Returns false if it's a duplicate within the deduplication window.
  bool shouldEmitEvent(dynamic event) {
    _totalEvents++;

    final eventType = event.runtimeType.toString();
    _eventTypeCounts[eventType] = (_eventTypeCounts[eventType] ?? 0) + 1;

    final eventData = _extractEventData(event);
    final eventKey = _generateEventKey(eventType, eventData);
    final eventHash = _generateEventHash(eventData);

    final now = DateTime.now();
    final window = _eventTypeWindows[eventType] ?? _deduplicationWindow;

    // Check for recent duplicate
    final recentEvent = _recentEvents[eventKey];
    if (recentEvent != null &&
        !recentEvent.isExpired(window) &&
        recentEvent.eventHash == eventHash) {
      _duplicateEvents++;
      _eventTypeDuplicates[eventType] =
          (_eventTypeDuplicates[eventType] ?? 0) + 1;
      return false;
    }

    // Record this event
    final eventInfo = EventInfo(
      eventKey: eventKey,
      eventType: eventType,
      timestamp: now,
      eventData: eventData,
      eventHash: eventHash,
    );

    _recentEvents[eventKey] = eventInfo;

    // Enforce max events limit
    if (_recentEvents.length > _maxEvents) {
      _evictOldestEvents();
    }

    return true;
  }

  /// Check if a specific event type should be emitted
  bool shouldEmitEventType(String eventType, Map<String, dynamic> eventData) {
    _totalEvents++;
    _eventTypeCounts[eventType] = (_eventTypeCounts[eventType] ?? 0) + 1;

    final eventKey = _generateEventKey(eventType, eventData);
    final eventHash = _generateEventHash(eventData);

    final now = DateTime.now();
    final window = _eventTypeWindows[eventType] ?? _deduplicationWindow;

    final recentEvent = _recentEvents[eventKey];
    if (recentEvent != null &&
        !recentEvent.isExpired(window) &&
        recentEvent.eventHash == eventHash) {
      _duplicateEvents++;
      _eventTypeDuplicates[eventType] =
          (_eventTypeDuplicates[eventType] ?? 0) + 1;
      return false;
    }

    final eventInfo = EventInfo(
      eventKey: eventKey,
      eventType: eventType,
      timestamp: now,
      eventData: eventData,
      eventHash: eventHash,
    );

    _recentEvents[eventKey] = eventInfo;

    if (_recentEvents.length > _maxEvents) {
      _evictOldestEvents();
    }

    return true;
  }

  /// Force emit an event (bypass deduplication)
  void forceEmitEvent(dynamic event) {
    final eventType = event.runtimeType.toString();
    final eventData = _extractEventData(event);
    final eventKey = _generateEventKey(eventType, eventData);
    final eventHash = _generateEventHash(eventData);

    final eventInfo = EventInfo(
      eventKey: eventKey,
      eventType: eventType,
      timestamp: DateTime.now(),
      eventData: eventData,
      eventHash: eventHash,
    );

    _recentEvents[eventKey] = eventInfo;
  }

  /// Clear events of a specific type
  void clearEventType(String eventType) {
    final keysToRemove = _recentEvents.entries
        .where((entry) => entry.value.eventType == eventType)
        .map((entry) => entry.key)
        .toList();

    for (final key in keysToRemove) {
      _recentEvents.remove(key);
    }
  }

  /// Clear all events
  void clearAll() {
    _recentEvents.clear();
    _eventTypeCounts.clear();
    _eventTypeDuplicates.clear();
  }

  /// Get current statistics
  Map<String, dynamic> getStatistics() {
    return {
      'totalEvents': _totalEvents,
      'duplicateEvents': _duplicateEvents,
      'activeEvents': _recentEvents.length,
      'duplicateRate': _totalEvents > 0 ? _duplicateEvents / _totalEvents : 0.0,
      'cleanupOperations': _cleanupOperations,
      'eventTypeCounts': Map.from(_eventTypeCounts),
      'eventTypeDuplicates': Map.from(_eventTypeDuplicates),
      'deduplicationWindowMs': _deduplicationWindow.inMilliseconds,
      'maxEvents': _maxEvents,
    };
  }

  /// Get statistics for a specific event type
  Map<String, dynamic> getEventTypeStatistics(String eventType) {
    final totalCount = _eventTypeCounts[eventType] ?? 0;
    final duplicateCount = _eventTypeDuplicates[eventType] ?? 0;

    return {
      'eventType': eventType,
      'totalCount': totalCount,
      'duplicateCount': duplicateCount,
      'duplicateRate': totalCount > 0 ? duplicateCount / totalCount : 0.0,
      'window': _eventTypeWindows[eventType]?.inMilliseconds ??
          _deduplicationWindow.inMilliseconds,
    };
  }

  /// Get recent events for debugging
  List<EventInfo> getRecentEvents({String? eventType, int? limit}) {
    var events = _recentEvents.values.toList();

    if (eventType != null) {
      events = events.where((e) => e.eventType == eventType).toList();
    }

    // Sort by timestamp (newest first)
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null && events.length > limit) {
      events = events.take(limit).toList();
    }

    return events;
  }

  /// Extract event data from an event object
  Map<String, dynamic> _extractEventData(dynamic event) {
    if (event == null) return {};

    // Handle common event types
    if (event is Map<String, dynamic>) {
      return Map.from(event);
    }

    // Use reflection-like approach for objects with properties
    try {
      // For objects with toJson method
      if (event is Object && event.toString().contains('{')) {
        // Try to extract data from toString representation
        final str = event.toString();
        final match = RegExp(r'\{(.+)\}').firstMatch(str);
        if (match != null) {
          return {'toString': match.group(1)};
        }
      }

      // Fallback to basic representation
      return {
        'type': event.runtimeType.toString(),
        'hashCode': event.hashCode,
        'toString': event.toString(),
      };
    } catch (e) {
      return {
        'type': event.runtimeType.toString(),
        'error': 'Failed to extract data: $e',
      };
    }
  }

  /// Generate event key for deduplication
  String _generateEventKey(String eventType, Map<String, dynamic> eventData) {
    // Create a stable key based on event type and relevant data
    final keyData = {
      'type': eventType,
      ...eventData,
    };

    final keyString = json.encode(keyData);
    final bytes = utf8.encode(keyString);
    final digest = sha256.convert(bytes);

    return '${eventType}_${digest.toString().substring(0, 12)}';
  }

  /// Generate event hash for content comparison
  int _generateEventHash(Map<String, dynamic> eventData) {
    final dataString = json.encode(eventData);
    return dataString.hashCode;
  }

  /// Start the cleanup timer
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer =
        Timer.periodic(_cleanupInterval, (_) => _cleanupExpiredEvents());
  }

  /// Clean up expired events
  void _cleanupExpiredEvents() {
    final keysToRemove = <String>[];

    for (final entry in _recentEvents.entries) {
      final window =
          _eventTypeWindows[entry.value.eventType] ?? _deduplicationWindow;
      if (entry.value.isExpired(window)) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _recentEvents.remove(key);
    }

    if (keysToRemove.isNotEmpty) {
      _cleanupOperations++;
    }
  }

  /// Evict oldest events when max limit is reached
  void _evictOldestEvents() {
    final targetSize = (_maxEvents * 0.8).round();
    final keysToRemove =
        _recentEvents.keys.take(_recentEvents.length - targetSize);

    for (final key in keysToRemove) {
      _recentEvents.remove(key);
    }
  }

  /// Dispose of the deduplicator
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _recentEvents.clear();
    _eventTypeCounts.clear();
    _eventTypeDuplicates.clear();
  }
}

/// Specialized event deduplicator for chat events
class ChatEventDeduplicator extends EventDeduplicator {
  ChatEventDeduplicator()
      : super(
          deduplicationWindow: const Duration(milliseconds: 300),
          maxEvents: 500,
        ) {
    // Configure specific windows for different chat event types
    configureEventTypes({
      'MessageAddedEvent': const Duration(milliseconds: 100),
      'MessageUpdatedEvent': const Duration(milliseconds: 50),
      'StreamingStartedEvent': const Duration(milliseconds: 200),
      'StreamingCompletedEvent': const Duration(milliseconds: 100),
      'ErrorOccurredEvent': const Duration(seconds: 1),
      'ConversationChangedEvent': const Duration(milliseconds: 500),
    });
  }
}

/// Specialized event deduplicator for UI events
class UIEventDeduplicator extends EventDeduplicator {
  UIEventDeduplicator()
      : super(
          deduplicationWindow: const Duration(milliseconds: 100),
          maxEvents: 200,
        ) {
    // Configure specific windows for UI events
    configureEventTypes({
      'ScrollEvent': const Duration(milliseconds: 50),
      'ResizeEvent': const Duration(milliseconds: 100),
      'FocusEvent': const Duration(milliseconds: 200),
      'ThemeChangedEvent': const Duration(milliseconds: 500),
      'LayoutChangedEvent': const Duration(milliseconds: 300),
    });
  }
}
