import 'package:flutter_test/flutter_test.dart';
import 'package:yumcha/core/services/deduplication_manager.dart';
import 'package:yumcha/core/services/request_deduplicator.dart';

void main() {
  group('DeduplicationManager', () {
    late DeduplicationManager manager;

    setUp(() {
      manager = DeduplicationManager.instance;
      manager.clearAll(); // Clear any previous state
    });

    tearDown(() {
      manager.clearAll();
    });

    group('Chat Message Deduplication', () {
      test('should allow first chat message', () {
        final result = manager.shouldAllowChatMessage(
          content: 'Hello world',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
          throwOnDuplicate: false,
        );

        expect(result, isTrue);
      });

      test('should prevent duplicate chat messages', () {
        // Send first message
        manager.shouldAllowChatMessage(
          content: 'Hello world',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
          throwOnDuplicate: false,
        );

        // Try to send same message again
        final result = manager.shouldAllowChatMessage(
          content: 'Hello world',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
          throwOnDuplicate: false,
        );

        expect(result, isFalse);
      });

      test('should throw exception when configured', () {
        // Send first message
        manager.shouldAllowChatMessage(
          content: 'Hello world',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
          throwOnDuplicate: false,
        );

        // Try to send same message again with throw enabled
        expect(
          () => manager.shouldAllowChatMessage(
            content: 'Hello world',
            conversationId: 'conv-1',
            assistantId: 'assistant-1',
            throwOnDuplicate: true,
          ),
          throwsA(isA<DuplicateRequestException>()),
        );
      });

      test('should allow same content in different conversations', () {
        // Send message in first conversation
        final result1 = manager.shouldAllowChatMessage(
          content: 'Hello world',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
          throwOnDuplicate: false,
        );

        // Send same content in different conversation
        final result2 = manager.shouldAllowChatMessage(
          content: 'Hello world',
          conversationId: 'conv-2',
          assistantId: 'assistant-1',
          throwOnDuplicate: false,
        );

        expect(result1, isTrue);
        expect(result2, isTrue);
      });

      test('should generate consistent chat message keys', () {
        final key1 = manager.generateChatMessageKey(
          content: 'Hello world',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );

        final key2 = manager.generateChatMessageKey(
          content: 'Hello world',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );

        expect(key1, equals(key2));
      });
    });

    group('Streaming Update Deduplication', () {
      test('should allow first streaming update', () {
        final result = manager.shouldAllowStreamingUpdate(
          messageId: 'msg-1',
          content: 'Hello',
          throwOnDuplicate: false,
        );

        expect(result, isTrue);
      });

      test('should prevent duplicate streaming updates', () {
        // Send first update
        manager.shouldAllowStreamingUpdate(
          messageId: 'msg-1',
          content: 'Hello',
          throwOnDuplicate: false,
        );

        // Try to send same update again
        final result = manager.shouldAllowStreamingUpdate(
          messageId: 'msg-1',
          content: 'Hello',
          throwOnDuplicate: false,
        );

        expect(result, isFalse);
      });

      test('should allow different content for same message', () {
        // Send first update
        final result1 = manager.shouldAllowStreamingUpdate(
          messageId: 'msg-1',
          content: 'Hello',
          throwOnDuplicate: false,
        );

        // Send different content for same message
        final result2 = manager.shouldAllowStreamingUpdate(
          messageId: 'msg-1',
          content: 'Hello World',
          throwOnDuplicate: false,
        );

        expect(result1, isTrue);
        expect(result2, isTrue);
      });
    });

    group('General Request Deduplication', () {
      test('should allow first request', () {
        final result = manager.shouldAllowRequest(
          'test-key',
          throwOnDuplicate: false,
        );

        expect(result, isTrue);
      });

      test('should prevent duplicate requests', () {
        // Send first request
        manager.shouldAllowRequest(
          'test-key',
          throwOnDuplicate: false,
        );

        // Try to send same request again
        final result = manager.shouldAllowRequest(
          'test-key',
          throwOnDuplicate: false,
        );

        expect(result, isFalse);
      });

      test('should generate consistent request keys', () {
        final key1 = manager.generateRequestKey(
          content: 'test content',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );

        final key2 = manager.generateRequestKey(
          content: 'test content',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );

        expect(key1, equals(key2));
      });
    });

    group('Event Deduplication', () {
      test('should allow first chat event', () {
        final result = manager.shouldEmitChatEvent('TestEvent');

        expect(result, isTrue);
      });

      test('should prevent duplicate chat events', () {
        // Emit first event
        manager.shouldEmitChatEvent('TestEvent');

        // Try to emit same event again
        final result = manager.shouldEmitChatEvent('TestEvent');

        expect(result, isFalse);
      });

      test('should allow first UI event', () {
        final result = manager.shouldEmitUIEvent('UITestEvent');

        expect(result, isTrue);
      });

      test('should prevent duplicate UI events', () {
        // Emit first event
        manager.shouldEmitUIEvent('UITestEvent');

        // Try to emit same event again
        final result = manager.shouldEmitUIEvent('UITestEvent');

        expect(result, isFalse);
      });

      test('should handle event type deduplication', () {
        final result1 = manager.shouldEmitChatEventType(
          'MessageAddedEvent',
          {'messageId': 'msg-1', 'content': 'Hello'},
        );

        final result2 = manager.shouldEmitChatEventType(
          'MessageAddedEvent',
          {'messageId': 'msg-1', 'content': 'Hello'},
        );

        expect(result1, isTrue);
        expect(result2, isFalse);
      });
    });

    group('Force Operations', () {
      test('should force emit chat event bypassing deduplication', () {
        // Emit event normally
        manager.shouldEmitChatEvent('TestEvent');

        // Force emit same event
        manager.forceEmitChatEvent('TestEvent');

        // Should still be able to emit after force
        final result = manager.shouldEmitChatEvent('TestEvent');
        expect(result, isFalse); // Still deduplicated
      });

      test('should force emit UI event bypassing deduplication', () {
        // Emit event normally
        manager.shouldEmitUIEvent('UITestEvent');

        // Force emit same event
        manager.forceEmitUIEvent('UITestEvent');

        // Should still be able to emit after force
        final result = manager.shouldEmitUIEvent('UITestEvent');
        expect(result, isFalse); // Still deduplicated
      });
    });

    group('Cleanup Operations', () {
      test('should clear chat deduplication', () {
        // Add some chat data
        manager.shouldAllowChatMessage(
          content: 'Hello',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
          throwOnDuplicate: false,
        );

        manager.shouldEmitChatEvent('TestEvent');

        // Clear chat deduplication
        manager.clearChatDeduplication();

        // Should be able to send same message again
        final result = manager.shouldAllowChatMessage(
          content: 'Hello',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
          throwOnDuplicate: false,
        );

        expect(result, isTrue);
      });

      test('should clear streaming deduplication', () {
        // Add streaming data
        manager.shouldAllowStreamingUpdate(
          messageId: 'msg-1',
          content: 'Hello',
          throwOnDuplicate: false,
        );

        // Clear streaming deduplication
        manager.clearStreamingDeduplication();

        // Should be able to send same update again
        final result = manager.shouldAllowStreamingUpdate(
          messageId: 'msg-1',
          content: 'Hello',
          throwOnDuplicate: false,
        );

        expect(result, isTrue);
      });

      test('should clear all deduplication', () {
        // Add various data
        manager.shouldAllowChatMessage(
          content: 'Hello',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
          throwOnDuplicate: false,
        );

        manager.shouldAllowStreamingUpdate(
          messageId: 'msg-1',
          content: 'Hello',
          throwOnDuplicate: false,
        );

        manager.shouldEmitChatEvent('TestEvent');

        // Clear all
        manager.clearAll();

        // Should be able to do everything again
        final chatResult = manager.shouldAllowChatMessage(
          content: 'Hello',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
          throwOnDuplicate: false,
        );

        final streamResult = manager.shouldAllowStreamingUpdate(
          messageId: 'msg-1',
          content: 'Hello',
          throwOnDuplicate: false,
        );

        final eventResult = manager.shouldEmitChatEvent('TestEvent');

        expect(chatResult, isTrue);
        expect(streamResult, isTrue);
        expect(eventResult, isTrue);
      });
    });

    group('Statistics', () {
      test('should provide comprehensive statistics', () {
        // Generate some activity
        manager.shouldAllowChatMessage(
          content: 'Hello',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
          throwOnDuplicate: false,
        );

        // Try duplicate
        manager.shouldAllowChatMessage(
          content: 'Hello',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
          throwOnDuplicate: false,
        );

        final stats = manager.getStatistics();

        expect(stats, isA<Map<String, dynamic>>());
        expect(stats.containsKey('chatMessages'), isTrue);
        expect(stats.containsKey('streamingUpdates'), isTrue);
        expect(stats.containsKey('generalRequests'), isTrue);
        expect(stats.containsKey('chatEvents'), isTrue);
        expect(stats.containsKey('uiEvents'), isTrue);
        expect(stats.containsKey('generalEvents'), isTrue);
      });

      test('should provide summary statistics', () {
        // Generate some activity
        manager.shouldAllowChatMessage(
          content: 'Hello',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
          throwOnDuplicate: false,
        );

        manager.shouldAllowChatMessage(
          content: 'Hello',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
          throwOnDuplicate: false,
        );

        final summary = manager.getSummaryStatistics();

        expect(summary, isA<Map<String, dynamic>>());
        expect(summary.containsKey('totalRequests'), isTrue);
        expect(summary.containsKey('totalDuplicateRequests'), isTrue);
        expect(summary.containsKey('requestDuplicateRate'), isTrue);
        expect(summary.containsKey('overallDuplicateRate'), isTrue);

        expect(summary['totalRequests'], greaterThan(0));
        expect(summary['totalDuplicateRequests'], greaterThan(0));
      });
    });
  });
}
