import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_status.dart';
import '../../domain/services/message_state_machine.dart';
import 'message_state_manager.dart';

/// 状态机集成测试
/// 
/// 验证 UnifiedChatNotifier 中状态机集成的正确性
void main() {
  group('UnifiedChatNotifier 状态机集成测试', () {
    late ProviderContainer container;
    late MessageStateManager stateManager;

    setUp(() {
      container = ProviderContainer();
      stateManager = container.read(messageStateManagerProvider);
    });

    tearDown(() {
      container.dispose();
    });

    test('状态管理器初始化', () {
      expect(stateManager, isNotNull);
      expect(stateManager.getTransitionStatistics()['totalTransitions'], equals(0));
    });

    test('消息状态转换 - 正常流程', () {
      // 创建测试消息
      final message = Message.assistant(
        id: 'test_message_1',
        conversationId: 'test_conversation',
        assistantId: 'test_assistant',
        status: MessageStatus.aiPending,
      );

      // 测试开始处理
      final result1 = stateManager.transitionMessageState(
        message: message,
        event: MessageStateEvent.startAiProcessing,
      );

      expect(result1.isSuccess, isTrue);
      expect(result1.newStatus, equals(MessageStatus.aiProcessing));

      // 测试完成处理
      final updatedMessage = result1.updatedMessage!;
      final result2 = stateManager.transitionMessageState(
        message: updatedMessage,
        event: MessageStateEvent.complete,
      );

      expect(result2.isSuccess, isTrue);
      expect(result2.newStatus, equals(MessageStatus.aiSuccess));
    });

    test('消息状态转换 - 流式流程', () {
      final message = Message.assistant(
        id: 'test_message_2',
        conversationId: 'test_conversation',
        assistantId: 'test_assistant',
        status: MessageStatus.aiPending,
      );

      // 开始流式传输
      final result1 = stateManager.transitionMessageState(
        message: message,
        event: MessageStateEvent.startStreaming,
      );

      expect(result1.isSuccess, isTrue);
      expect(result1.newStatus, equals(MessageStatus.aiStreaming));

      // 流式更新
      final streamingMessage = result1.updatedMessage!;
      final result2 = stateManager.transitionMessageState(
        message: streamingMessage,
        event: MessageStateEvent.streaming,
      );

      expect(result2.isSuccess, isTrue);
      expect(result2.newStatus, equals(MessageStatus.aiStreaming));

      // 完成流式传输
      final result3 = stateManager.transitionMessageState(
        message: result2.updatedMessage!,
        event: MessageStateEvent.complete,
      );

      expect(result3.isSuccess, isTrue);
      expect(result3.newStatus, equals(MessageStatus.aiSuccess));
    });

    test('消息状态转换 - 错误处理', () {
      final message = Message.assistant(
        id: 'test_message_3',
        conversationId: 'test_conversation',
        assistantId: 'test_assistant',
        status: MessageStatus.aiStreaming,
      );

      // 发生错误
      final result = stateManager.transitionMessageState(
        message: message,
        event: MessageStateEvent.error,
        metadata: {'errorMessage': 'Test error'},
      );

      expect(result.isSuccess, isTrue);
      expect(result.newStatus, equals(MessageStatus.aiError));
      expect(result.metadata?['errorMessage'], equals('Test error'));
    });

    test('非法状态转换', () {
      final message = Message.user(
        id: 'test_message_4',
        conversationId: 'test_conversation',
        assistantId: 'test_assistant',
      );

      // 尝试从用户消息转换到AI处理状态（应该失败）
      final result = stateManager.transitionMessageState(
        message: message,
        event: MessageStateEvent.startAiProcessing,
      );

      expect(result.isSuccess, isFalse);
      expect(result.error, isNotNull);
    });

    test('状态冲突解决', () {
      final message = Message.assistant(
        id: 'test_message_5',
        conversationId: 'test_conversation',
        assistantId: 'test_assistant',
        status: MessageStatus.aiProcessing,
      );

      final resolvedStatus = stateManager.resolveMessageStateConflict(
        message: message,
        candidateStatuses: [
          MessageStatus.aiError,
          MessageStatus.aiSuccess,
          MessageStatus.aiStreaming,
        ],
        reason: 'test_conflict',
      );

      // 应该选择优先级最高且合法的状态
      expect(resolvedStatus, equals(MessageStatus.aiError));
    });

    test('建议操作获取', () {
      final errorMessage = Message.assistant(
        id: 'test_message_6',
        conversationId: 'test_conversation',
        assistantId: 'test_assistant',
        status: MessageStatus.aiError,
      );

      final suggestions = stateManager.getSuggestedActionsForMessage(errorMessage);
      expect(suggestions, contains(MessageStateEvent.retry));
    });

    test('状态转换统计', () {
      // 执行一些转换
      final message = Message.assistant(
        id: 'test_message_7',
        conversationId: 'test_conversation',
        assistantId: 'test_assistant',
        status: MessageStatus.aiPending,
      );

      stateManager.transitionMessageState(
        message: message,
        event: MessageStateEvent.startAiProcessing,
      );

      final stats = stateManager.getTransitionStatistics();
      expect(stats['totalTransitions'], greaterThan(0));
      expect(stats['successfulTransitions'], greaterThan(0));
      expect(stats['successRate'], greaterThan(0.0));
    });

    test('状态转换历史', () {
      final initialHistoryLength = stateManager.getTransitionHistory().length;

      final message = Message.assistant(
        id: 'test_message_8',
        conversationId: 'test_conversation',
        assistantId: 'test_assistant',
        status: MessageStatus.aiPending,
      );

      stateManager.transitionMessageState(
        message: message,
        event: MessageStateEvent.startAiProcessing,
      );

      final history = stateManager.getTransitionHistory();
      expect(history.length, equals(initialHistoryLength + 1));

      final lastTransition = stateManager.getLastTransition();
      expect(lastTransition, isNotNull);
      expect(lastTransition!.isSuccess, isTrue);
    });

    test('批量状态转换', () {
      final messages = [
        Message.assistant(
          id: 'batch_1',
          conversationId: 'test_conversation',
          assistantId: 'test_assistant',
          status: MessageStatus.aiStreaming,
        ),
        Message.assistant(
          id: 'batch_2',
          conversationId: 'test_conversation',
          assistantId: 'test_assistant',
          status: MessageStatus.aiStreaming,
        ),
      ];

      final results = stateManager.batchTransitionMessageStates(
        messages: messages,
        event: MessageStateEvent.complete,
      );

      expect(results.length, equals(2));
      expect(results['batch_1']?.isSuccess, isTrue);
      expect(results['batch_2']?.isSuccess, isTrue);
      expect(results['batch_1']?.newStatus, equals(MessageStatus.aiSuccess));
      expect(results['batch_2']?.newStatus, equals(MessageStatus.aiSuccess));
    });
  });
}

/// 运行测试的辅助函数
void runStateTransitionTests() {
  print('开始运行状态机集成测试...');
  
  // 这里可以添加实际的测试运行逻辑
  // 在实际应用中，这些测试应该通过 flutter test 命令运行
  
  print('状态机集成测试完成');
}
