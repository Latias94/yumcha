import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yumcha/core/providers/streaming_state_provider.dart';
import 'package:yumcha/core/state/streaming_state.dart';

void main() {
  group('StreamingStateProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Stream Lifecycle Management', () {
      test('should initialize stream correctly', () {
        final notifier = container.read(streamingStateProvider.notifier);

        notifier.initializeStream(
          messageId: 'msg-1',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
          modelId: 'gpt-4',
        );

        final state = container.read(streamingStateProvider);
        expect(state.activeStreams.containsKey('msg-1'), isTrue);
        expect(state.activeStreamCount, equals(1));
        expect(state.isStreaming, isTrue);
        expect(state.status, equals(StreamingStatus.active));

        final stream = state.getStream('msg-1');
        expect(stream, isNotNull);
        expect(stream!.messageId, equals('msg-1'));
        expect(stream.conversationId, equals('conv-1'));
        expect(stream.assistantId, equals('assistant-1'));
        expect(stream.modelId, equals('gpt-4'));
        expect(stream.isActive, isTrue);
      });

      test('should prevent duplicate stream initialization', () {
        final notifier = container.read(streamingStateProvider.notifier);

        // Initialize same stream twice
        notifier.initializeStream(
          messageId: 'msg-1',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );

        notifier.initializeStream(
          messageId: 'msg-1',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );

        final state = container.read(streamingStateProvider);
        expect(state.activeStreamCount, equals(1));
      });

      test('should update stream content correctly', () {
        final notifier = container.read(streamingStateProvider.notifier);

        // Initialize stream
        notifier.initializeStream(
          messageId: 'msg-1',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );

        // Update content
        notifier.updateStreamContent(
          messageId: 'msg-1',
          contentDelta: 'Hello',
        );

        final state = container.read(streamingStateProvider);
        final stream = state.getStream('msg-1');
        expect(stream?.content, equals('Hello'));
        expect(stream?.updateCount, equals(1));

        // Update with more content
        notifier.updateStreamContent(
          messageId: 'msg-1',
          contentDelta: ' World',
        );

        final updatedState = container.read(streamingStateProvider);
        final updatedStream = updatedState.getStream('msg-1');
        expect(updatedStream?.content, equals('Hello World'));
        expect(updatedStream?.updateCount, equals(2));
      });

      test('should update stream with full content', () {
        final notifier = container.read(streamingStateProvider.notifier);

        // Initialize stream
        notifier.initializeStream(
          messageId: 'msg-1',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );

        // Update with full content
        notifier.updateStreamContent(
          messageId: 'msg-1',
          fullContent: 'Complete message',
        );

        final state = container.read(streamingStateProvider);
        final stream = state.getStream('msg-1');
        expect(stream?.content, equals('Complete message'));
      });

      test('should update thinking content', () {
        final notifier = container.read(streamingStateProvider.notifier);

        // Initialize stream
        notifier.initializeStream(
          messageId: 'msg-1',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );

        // Update thinking
        notifier.updateStreamContent(
          messageId: 'msg-1',
          thinking: 'Let me think about this...',
        );

        final state = container.read(streamingStateProvider);
        final stream = state.getStream('msg-1');
        expect(stream?.thinking, equals('Let me think about this...'));
        expect(stream?.hasThinking, isTrue);
      });

      test('should complete stream correctly', () {
        final notifier = container.read(streamingStateProvider.notifier);

        // Initialize and update stream
        notifier.initializeStream(
          messageId: 'msg-1',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );

        notifier.updateStreamContent(
          messageId: 'msg-1',
          contentDelta: 'Hello World',
        );

        // Complete stream
        notifier.completeStream('msg-1');

        final state = container.read(streamingStateProvider);
        expect(state.activeStreams.containsKey('msg-1'), isFalse);
        expect(state.activeStreamCount, equals(0));
        expect(state.isStreaming, isFalse);
        expect(state.status, equals(StreamingStatus.idle));
        expect(state.totalStreams, equals(1));
        expect(state.recentCompletedStreams.length, equals(1));

        final completedStream = state.recentCompletedStreams.first;
        expect(completedStream.messageId, equals('msg-1'));
        expect(completedStream.content, equals('Hello World'));
        expect(completedStream.isComplete, isTrue);
      });

      test('should handle stream error correctly', () {
        final notifier = container.read(streamingStateProvider.notifier);

        // Initialize stream
        notifier.initializeStream(
          messageId: 'msg-1',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );

        // Error stream
        notifier.errorStream('msg-1', 'Network error');

        final state = container.read(streamingStateProvider);
        expect(state.activeStreams.containsKey('msg-1'), isFalse);
        expect(state.activeStreamCount, equals(0));
        expect(state.error, equals('Network error'));
        expect(state.totalStreams, equals(1));
        expect(state.recentCompletedStreams.length, equals(1));

        final errorStream = state.recentCompletedStreams.first;
        expect(errorStream.hasError, isTrue);
        expect(errorStream.errorMessage, equals('Network error'));
      });

      test('should cancel stream correctly', () {
        final notifier = container.read(streamingStateProvider.notifier);

        // Initialize stream
        notifier.initializeStream(
          messageId: 'msg-1',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );

        // Cancel stream
        notifier.cancelStream('msg-1');

        final state = container.read(streamingStateProvider);
        expect(state.activeStreams.containsKey('msg-1'), isFalse);
        expect(state.activeStreamCount, equals(0));
        expect(state.isStreaming, isFalse);
      });
    });

    group('Multiple Streams Management', () {
      test('should handle multiple concurrent streams', () {
        final notifier = container.read(streamingStateProvider.notifier);

        // Initialize multiple streams
        notifier.initializeStream(
          messageId: 'msg-1',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );

        notifier.initializeStream(
          messageId: 'msg-2',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );

        notifier.initializeStream(
          messageId: 'msg-3',
          conversationId: 'conv-2',
          assistantId: 'assistant-2',
        );

        final state = container.read(streamingStateProvider);
        expect(state.activeStreamCount, equals(3));
        expect(state.maxConcurrentStreams, equals(3));
        expect(state.isStreaming, isTrue);
      });

      test('should get streams for conversation', () {
        final notifier = container.read(streamingStateProvider.notifier);

        // Initialize streams for different conversations
        notifier.initializeStream(
          messageId: 'msg-1',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );

        notifier.initializeStream(
          messageId: 'msg-2',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );

        notifier.initializeStream(
          messageId: 'msg-3',
          conversationId: 'conv-2',
          assistantId: 'assistant-2',
        );

        final state = container.read(streamingStateProvider);
        final conv1Streams = state.getStreamsForConversation('conv-1');
        final conv2Streams = state.getStreamsForConversation('conv-2');

        expect(conv1Streams.length, equals(2));
        expect(conv2Streams.length, equals(1));
        expect(conv1Streams.map((s) => s.messageId),
            containsAll(['msg-1', 'msg-2']));
        expect(conv2Streams.first.messageId, equals('msg-3'));
      });

      test('should cancel all streams', () {
        final notifier = container.read(streamingStateProvider.notifier);

        // Initialize multiple streams
        notifier.initializeStream(
          messageId: 'msg-1',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );

        notifier.initializeStream(
          messageId: 'msg-2',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );

        // Cancel all
        notifier.cancelAllStreams();

        final state = container.read(streamingStateProvider);
        expect(state.activeStreamCount, equals(0));
        expect(state.isStreaming, isFalse);
        expect(state.status, equals(StreamingStatus.idle));
      });
    });

    group('Configuration Management', () {
      test('should update max allowed concurrent streams', () {
        final notifier = container.read(streamingStateProvider.notifier);

        notifier.setMaxAllowedConcurrentStreams(5);

        final state = container.read(streamingStateProvider);
        expect(state.maxAllowedConcurrentStreams, equals(5));
      });

      test('should update stream timeout', () {
        final notifier = container.read(streamingStateProvider.notifier);

        notifier.setStreamTimeout(60);

        final state = container.read(streamingStateProvider);
        expect(state.streamTimeoutSeconds, equals(60));
      });

      test('should check if can start new stream', () {
        final notifier = container.read(streamingStateProvider.notifier);

        // Set max to 2
        notifier.setMaxAllowedConcurrentStreams(2);

        // Should be able to start
        expect(
            container.read(streamingStateProvider).canStartNewStream, isTrue);

        // Start 2 streams
        notifier.initializeStream(
          messageId: 'msg-1',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );

        notifier.initializeStream(
          messageId: 'msg-2',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );

        // Should not be able to start more
        expect(
            container.read(streamingStateProvider).canStartNewStream, isFalse);
      });
    });

    group('Error Handling', () {
      test('should set and clear global streaming error', () {
        final notifier = container.read(streamingStateProvider.notifier);

        notifier.setStreamingError('Global error');

        final state = container.read(streamingStateProvider);
        expect(state.error, equals('Global error'));
        expect(state.hasError, isTrue);

        notifier.clearStreamingError();

        final clearedState = container.read(streamingStateProvider);
        expect(clearedState.error, isNull);
        expect(clearedState.hasError, isFalse);
      });
    });

    group('Reset and Cleanup', () {
      test('should reset state correctly', () {
        final notifier = container.read(streamingStateProvider.notifier);

        // Set up some state
        notifier.initializeStream(
          messageId: 'msg-1',
          conversationId: 'conv-1',
          assistantId: 'assistant-1',
        );
        notifier.setStreamingError('Test error');

        // Reset
        notifier.reset();

        final state = container.read(streamingStateProvider);
        expect(state.activeStreamCount, equals(0));
        expect(state.error, isNull);
        expect(state.totalStreams, equals(0));
        expect(state.recentCompletedStreams.isEmpty, isTrue);
      });
    });
  });
}
