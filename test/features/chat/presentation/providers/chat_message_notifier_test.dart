import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:yumcha/features/chat/presentation/providers/chat_message_notifier.dart';
import 'package:yumcha/features/chat/domain/entities/message.dart';
import 'package:yumcha/shared/infrastructure/services/ai/chat/chat_service.dart';
import 'package:yumcha/shared/presentation/providers/dependency_providers.dart';

// 生成 Mock 类
@GenerateMocks([ChatService])
import 'chat_message_notifier_test.mocks.dart';

void main() {
  group('ChatMessageNotifier', () {
    late ProviderContainer container;
    late MockChatService mockChatService;

    setUp(() {
      mockChatService = MockChatService();

      container = ProviderContainer(
        overrides: [
          // Mock ChatService
          aiChatServiceProvider.overrideWithValue(mockChatService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with empty state', () {
      final notifier = container.read(
        chatMessageNotifierProvider('test-conversation').notifier,
      );
      final state = container.read(
        chatMessageNotifierProvider('test-conversation'),
      );

      expect(state.messages, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.streamingMessageIds, isEmpty);
      expect(state.pendingRequests, isEmpty);
    });

    test('should initialize messages correctly', () {
      final testMessages = [
        Message(
          content: 'Hello',
          timestamp: DateTime.now(),
          isFromUser: true,
          author: 'User',
        ),
        Message(
          content: 'Hi there!',
          timestamp: DateTime.now(),
          isFromUser: false,
          author: 'AI',
        ),
      ];

      final notifier = container.read(
        chatMessageNotifierProvider('test-conversation').notifier,
      );

      notifier.initializeMessages(testMessages);

      final state = container.read(
        chatMessageNotifierProvider('test-conversation'),
      );

      expect(state.messages.length, 2);
      expect(state.messages[0].content, 'Hello');
      expect(state.messages[1].content, 'Hi there!');
    });

    test('should handle error state correctly', () {
      final notifier = container.read(
        chatMessageNotifierProvider('test-conversation').notifier,
      );

      // 模拟错误
      notifier.clearError();

      final state = container.read(
        chatMessageNotifierProvider('test-conversation'),
      );

      expect(state.error, isNull);
    });

    test('should cancel streaming correctly', () {
      final notifier = container.read(
        chatMessageNotifierProvider('test-conversation').notifier,
      );

      notifier.cancelStreaming();

      final state = container.read(
        chatMessageNotifierProvider('test-conversation'),
      );

      expect(state.isLoading, false);
      expect(state.streamingMessageIds, isEmpty);
    });

    test('should clear all messages', () {
      final testMessages = [
        Message(
          content: 'Test message',
          timestamp: DateTime.now(),
          isFromUser: true,
          author: 'User',
        ),
      ];

      final notifier = container.read(
        chatMessageNotifierProvider('test-conversation').notifier,
      );

      // 先添加消息
      notifier.initializeMessages(testMessages);

      // 验证消息已添加
      var state = container.read(
        chatMessageNotifierProvider('test-conversation'),
      );
      expect(state.messages.length, 1);

      // 清空消息
      notifier.clearAllMessages();

      // 验证消息已清空
      state = container.read(
        chatMessageNotifierProvider('test-conversation'),
      );
      expect(state.messages, isEmpty);
      expect(state.error, isNull);
    });

    test('should handle message deletion', () {
      final testMessage = Message(
        content: 'Test message',
        timestamp: DateTime.now(),
        isFromUser: true,
        author: 'User',
      );

      final notifier = container.read(
        chatMessageNotifierProvider('test-conversation').notifier,
      );

      // 添加消息
      notifier.initializeMessages([testMessage]);

      // 验证消息已添加
      var state = container.read(
        chatMessageNotifierProvider('test-conversation'),
      );
      expect(state.messages.length, 1);

      // 删除消息
      notifier.deleteMessage(testMessage);

      // 验证消息已删除
      state = container.read(
        chatMessageNotifierProvider('test-conversation'),
      );
      expect(state.messages, isEmpty);
    });

    test('should provide correct history messages', () {
      final testMessages = [
        Message(
          content: 'Normal message',
          timestamp: DateTime.now(),
          isFromUser: true,
          author: 'User',
          status: MessageStatus.normal,
        ),
        Message(
          content: 'Temporary message',
          timestamp: DateTime.now(),
          isFromUser: false,
          author: 'AI',
          status: MessageStatus.temporary,
        ),
        Message(
          content: 'Error message',
          timestamp: DateTime.now(),
          isFromUser: false,
          author: 'AI',
          status: MessageStatus.error,
        ),
      ];

      final notifier = container.read(
        chatMessageNotifierProvider('test-conversation').notifier,
      );

      notifier.initializeMessages(testMessages);

      final state = container.read(
        chatMessageNotifierProvider('test-conversation'),
      );

      // 只有 normal 状态的消息应该被包含在历史消息中
      expect(state.historyMessages.length, 1);
      expect(state.historyMessages[0].content, 'Normal message');
    });

    test('should detect streaming message correctly', () {
      final streamingMessage = Message(
        content: 'Streaming...',
        timestamp: DateTime.now(),
        isFromUser: false,
        author: 'AI',
        status: MessageStatus.streaming,
      );

      final notifier = container.read(
        chatMessageNotifierProvider('test-conversation').notifier,
      );

      notifier.initializeMessages([streamingMessage]);

      final state = container.read(
        chatMessageNotifierProvider('test-conversation'),
      );

      expect(state.messages.length, 1);
      expect(state.messages[0].status, MessageStatus.streaming);
    });

    test('should support multiple streaming messages', () {
      final notifier = container.read(
        chatMessageNotifierProvider('test-conversation').notifier,
      );

      notifier.initializeMessages([]);

      // 模拟多个流式消息的状态
      final state = container.read(
        chatMessageNotifierProvider('test-conversation'),
      );

      // 测试多流式消息的便捷方法
      expect(state.streamingMessageIds, isEmpty);
      expect(state.hasStreamingMessage, false);
      expect(state.streamingMessages, isEmpty);
    });

    test('should check assistant busy status', () {
      final messages = [
        Message(
          content: 'Hello',
          timestamp: DateTime.now(),
          isFromUser: false,
          author: 'Assistant1',
          status: MessageStatus.streaming,
        ),
      ];

      final notifier = container.read(
        chatMessageNotifierProvider('test-conversation').notifier,
      );

      notifier.initializeMessages(messages);

      final state = container.read(
        chatMessageNotifierProvider('test-conversation'),
      );

      // 测试助手忙碌状态检查
      expect(state.isAssistantBusy('Assistant1'), false); // 需要在流式集合中才算忙碌
      expect(state.isAssistantBusy('Assistant2'), false);
    });

    test('should get assistant streaming messages', () {
      final messages = [
        Message(
          content: 'Message from AI1',
          timestamp: DateTime.now(),
          isFromUser: false,
          author: 'AI1',
          status: MessageStatus.streaming,
        ),
        Message(
          content: 'Message from AI2',
          timestamp: DateTime.now(),
          isFromUser: false,
          author: 'AI2',
          status: MessageStatus.streaming,
        ),
      ];

      final notifier = container.read(
        chatMessageNotifierProvider('test-conversation').notifier,
      );

      notifier.initializeMessages(messages);

      final state = container.read(
        chatMessageNotifierProvider('test-conversation'),
      );

      // 测试获取特定助手的流式消息
      final ai1Messages = state.getAssistantStreamingMessages('AI1');
      final ai2Messages = state.getAssistantStreamingMessages('AI2');

      expect(ai1Messages, isEmpty); // 需要在流式集合中
      expect(ai2Messages, isEmpty); // 需要在流式集合中
    });
  });

  group('ChatMessageState', () {
    test('should create state with correct defaults', () {
      const state = ChatMessageState(messages: []);

      expect(state.messages, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.streamingMessageIds, isEmpty);
      expect(state.hasStreamingMessage, false);
      expect(state.streamingMessage, isNull);
    });

    test('should copy state correctly', () {
      const originalState = ChatMessageState(
        messages: [],
        isLoading: false,
        error: null,
      );

      final newState = originalState.copyWith(
        isLoading: true,
        error: 'Test error',
      );

      expect(newState.isLoading, true);
      expect(newState.error, 'Test error');
      expect(newState.messages, isEmpty); // 保持原值
    });

    test('should filter history messages correctly', () {
      final messages = [
        Message(
          content: 'Normal',
          timestamp: DateTime.now(),
          isFromUser: true,
          author: 'User',
          status: MessageStatus.normal,
        ),
        Message(
          content: 'Temporary',
          timestamp: DateTime.now(),
          isFromUser: false,
          author: 'AI',
          status: MessageStatus.temporary,
        ),
      ];

      final state = ChatMessageState(messages: messages);

      expect(state.historyMessages.length, 1);
      expect(state.historyMessages[0].content, 'Normal');
    });
  });
}
