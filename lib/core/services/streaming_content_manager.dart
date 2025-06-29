import 'dart:async';
import 'dart:developer' as developer;

/// Content accumulation strategy
enum ContentAccumulationStrategy {
  /// Replace entire content with new content
  replace,

  /// Append new content to existing content
  append,

  /// Smart merge - detect if new content is delta or full content
  smartMerge,
}

/// Content block for managing different types of content
class ContentBlock {
  final String id;
  final String type;
  String content;
  DateTime lastUpdated;
  int updateCount;

  ContentBlock({
    required this.id,
    required this.type,
    this.content = '',
    DateTime? lastUpdated,
    this.updateCount = 0,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// Update content with new data
  void updateContent(String newContent, ContentAccumulationStrategy strategy) {
    switch (strategy) {
      case ContentAccumulationStrategy.replace:
        content = newContent;
        break;
      case ContentAccumulationStrategy.append:
        content += newContent;
        break;
      case ContentAccumulationStrategy.smartMerge:
        // If new content is longer and contains existing content, replace
        if (newContent.length > content.length &&
            newContent.contains(content)) {
          content = newContent;
        } else {
          // Otherwise append
          content += newContent;
        }
        break;
    }

    lastUpdated = DateTime.now();
    updateCount++;
  }

  /// Get content length
  int get length => content.length;

  /// Check if content is empty
  bool get isEmpty => content.isEmpty;

  /// Check if content is not empty
  bool get isNotEmpty => content.isNotEmpty;

  @override
  String toString() => 'ContentBlock(id: $id, type: $type, length: $length)';
}

/// Streaming content manager for handling content accumulation
///
/// This class manages the accumulation of streaming content with proper
/// deduplication, content merging, and performance optimization.
/// Inspired by Cherry Studio's content management but adapted for Dart.
class StreamingContentManager {
  /// Content blocks by message ID and block type
  final Map<String, Map<String, ContentBlock>> _contentBlocks = {};

  /// Content change listeners
  final Map<String,
          List<Function(String messageId, String blockType, String content)>>
      _listeners = {};

  /// Throttle timers for content updates
  final Map<String, Timer> _throttleTimers = {};

  /// Default throttle delay
  static const Duration _defaultThrottleDelay = Duration(milliseconds: 50);

  /// Maximum content length per block
  static const int _maxContentLength = 1000000; // 1MB

  /// Initialize content for a message
  void initializeMessage(String messageId, {List<String>? blockTypes}) {
    if (_contentBlocks.containsKey(messageId)) {
      developer.log('Message already initialized: $messageId',
          name: 'StreamingContentManager');
      return;
    }

    _contentBlocks[messageId] = {};
    _listeners[messageId] = [];

    // Initialize default block types
    final types = blockTypes ?? ['mainText', 'thinking'];
    for (final type in types) {
      _contentBlocks[messageId]![type] = ContentBlock(
        id: '${messageId}_$type',
        type: type,
      );
    }

    developer.log('Initialized message: $messageId with blocks: $types',
        name: 'StreamingContentManager');
  }

  /// Update content for a specific block
  void updateContent({
    required String messageId,
    required String blockType,
    String? contentDelta,
    String? fullContent,
    ContentAccumulationStrategy strategy =
        ContentAccumulationStrategy.smartMerge,
    bool throttle = true,
  }) {
    // Ensure message is initialized
    if (!_contentBlocks.containsKey(messageId)) {
      initializeMessage(messageId);
    }

    // Ensure block exists
    if (!_contentBlocks[messageId]!.containsKey(blockType)) {
      _contentBlocks[messageId]![blockType] = ContentBlock(
        id: '${messageId}_$blockType',
        type: blockType,
      );
    }

    final block = _contentBlocks[messageId]![blockType]!;

    // Determine content to use
    String contentToAdd = '';
    if (fullContent != null) {
      contentToAdd = fullContent;
      strategy = ContentAccumulationStrategy.replace;
    } else if (contentDelta != null) {
      contentToAdd = contentDelta;
      strategy = ContentAccumulationStrategy.append;
    } else {
      return; // No content to add
    }

    // Safety check for content length
    final potentialLength = strategy == ContentAccumulationStrategy.replace
        ? contentToAdd.length
        : block.length + contentToAdd.length;

    if (potentialLength > _maxContentLength) {
      developer.log(
          'Content length would exceed maximum for $messageId:$blockType',
          name: 'StreamingContentManager');

      if (strategy == ContentAccumulationStrategy.replace) {
        contentToAdd = contentToAdd.substring(0, _maxContentLength);
      } else {
        final availableSpace = _maxContentLength - block.length;
        if (availableSpace > 0) {
          contentToAdd = contentToAdd.substring(0, availableSpace);
        } else {
          return; // No space left
        }
      }
    }

    // Update content
    block.updateContent(contentToAdd, strategy);

    developer.log(
        'Updated content for $messageId:$blockType, length: ${block.length}',
        name: 'StreamingContentManager');

    // Notify listeners (with throttling if enabled)
    if (throttle) {
      _scheduleThrottledNotification(messageId, blockType, block.content);
    } else {
      _notifyListeners(messageId, blockType, block.content);
    }
  }

  /// Get content for a specific block
  String getContent(String messageId, String blockType) {
    return _contentBlocks[messageId]?[blockType]?.content ?? '';
  }

  /// Get all content for a message
  Map<String, String> getAllContent(String messageId) {
    final blocks = _contentBlocks[messageId];
    if (blocks == null) return {};

    return blocks.map((type, block) => MapEntry(type, block.content));
  }

  /// Get content block
  ContentBlock? getContentBlock(String messageId, String blockType) {
    return _contentBlocks[messageId]?[blockType];
  }

  /// Get all content blocks for a message
  Map<String, ContentBlock> getContentBlocks(String messageId) {
    return Map.from(_contentBlocks[messageId] ?? {});
  }

  /// Check if message has content
  bool hasContent(String messageId, [String? blockType]) {
    final blocks = _contentBlocks[messageId];
    if (blocks == null) return false;

    if (blockType != null) {
      return blocks[blockType]?.isNotEmpty ?? false;
    }

    return blocks.values.any((block) => block.isNotEmpty);
  }

  /// Get total content length for a message
  int getTotalContentLength(String messageId) {
    final blocks = _contentBlocks[messageId];
    if (blocks == null) return 0;

    return blocks.values.fold(0, (sum, block) => sum + block.length);
  }

  /// Add content change listener
  void addListener(String messageId,
      Function(String messageId, String blockType, String content) listener) {
    if (!_listeners.containsKey(messageId)) {
      _listeners[messageId] = [];
    }
    _listeners[messageId]!.add(listener);
  }

  /// Remove content change listener
  void removeListener(String messageId,
      Function(String messageId, String blockType, String content) listener) {
    _listeners[messageId]?.remove(listener);
  }

  /// Complete content for a message (flush any pending updates)
  void completeMessage(String messageId) {
    // Cancel any pending throttled updates
    final timerKey = messageId;
    _throttleTimers[timerKey]?.cancel();
    _throttleTimers.remove(timerKey);

    // Send final notifications for all blocks
    final blocks = _contentBlocks[messageId];
    if (blocks != null) {
      for (final entry in blocks.entries) {
        _notifyListeners(messageId, entry.key, entry.value.content);
      }
    }

    developer.log('Completed message: $messageId',
        name: 'StreamingContentManager');
  }

  /// Clear content for a message
  void clearMessage(String messageId) {
    // Cancel any pending updates
    _throttleTimers[messageId]?.cancel();
    _throttleTimers.remove(messageId);

    // Remove content and listeners
    _contentBlocks.remove(messageId);
    _listeners.remove(messageId);

    developer.log('Cleared message: $messageId',
        name: 'StreamingContentManager');
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    int totalMessages = _contentBlocks.length;
    int totalBlocks =
        _contentBlocks.values.fold(0, (sum, blocks) => sum + blocks.length);
    int totalContentLength = 0;
    int totalUpdates = 0;

    for (final blocks in _contentBlocks.values) {
      for (final block in blocks.values) {
        totalContentLength += block.length;
        totalUpdates += block.updateCount;
      }
    }

    return {
      'totalMessages': totalMessages,
      'totalBlocks': totalBlocks,
      'totalContentLength': totalContentLength,
      'totalUpdates': totalUpdates,
      'activeThrottleTimers': _throttleTimers.length,
      'averageContentPerMessage':
          totalMessages > 0 ? totalContentLength / totalMessages : 0,
      'averageUpdatesPerBlock':
          totalBlocks > 0 ? totalUpdates / totalBlocks : 0,
    };
  }

  /// Schedule throttled notification
  void _scheduleThrottledNotification(
      String messageId, String blockType, String content) {
    final timerKey = '${messageId}_$blockType';

    // Cancel existing timer
    _throttleTimers[timerKey]?.cancel();

    // Schedule new notification
    _throttleTimers[timerKey] = Timer(_defaultThrottleDelay, () {
      _notifyListeners(messageId, blockType, content);
      _throttleTimers.remove(timerKey);
    });
  }

  /// Notify listeners immediately
  void _notifyListeners(String messageId, String blockType, String content) {
    final listeners = _listeners[messageId];
    if (listeners != null) {
      for (final listener in listeners) {
        try {
          listener(messageId, blockType, content);
        } catch (error) {
          developer.log('Error in content listener: $error',
              name: 'StreamingContentManager');
        }
      }
    }
  }

  /// Dispose of the manager
  void dispose() {
    // Cancel all timers
    for (final timer in _throttleTimers.values) {
      timer.cancel();
    }
    _throttleTimers.clear();

    // Clear all data
    _contentBlocks.clear();
    _listeners.clear();

    developer.log('StreamingContentManager disposed',
        name: 'StreamingContentManager');
  }
}
