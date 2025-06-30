import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../lib/features/chat/domain/entities/message.dart';
import '../../../../../lib/features/chat/domain/entities/message_status.dart';
import '../../../../../lib/features/chat/domain/services/message_state_machine.dart';
import '../../../../../lib/features/chat/presentation/providers/message_state_manager.dart';

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
      expect(stateManager.getTransitionStatistics()['totalTransitions'],
          equals(0));
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

    test('消息状态转换 - 流式处理', () {
      // 创建测试消息
      final message = Message.assistant(
        id: 'test_message_2',
        conversationId: 'test_conversation',
        assistantId: 'test_assistant',
        status: MessageStatus.aiPending,
      );

      // 开始流式处理
      final result1 = stateManager.transitionMessageState(
        message: message,
        event: MessageStateEvent.startStreaming,
      );

      expect(result1.isSuccess, isTrue);
      expect(result1.newStatus, equals(MessageStatus.aiStreaming));

      // 暂停流式处理
      final updatedMessage1 = result1.updatedMessage!;
      final result2 = stateManager.transitionMessageState(
        message: updatedMessage1,
        event: MessageStateEvent.pause,
      );

      expect(result2.isSuccess, isTrue);
      expect(result2.newStatus, equals(MessageStatus.aiPaused));

      // 恢复流式处理
      final updatedMessage2 = result2.updatedMessage!;
      final result3 = stateManager.transitionMessageState(
        message: updatedMessage2,
        event: MessageStateEvent.resume,
      );

      expect(result3.isSuccess, isTrue);
      expect(result3.newStatus, equals(MessageStatus.aiStreaming));

      // 完成流式处理
      final updatedMessage3 = result3.updatedMessage!;
      final result4 = stateManager.transitionMessageState(
        message: updatedMessage3,
        event: MessageStateEvent.complete,
      );

      expect(result4.isSuccess, isTrue);
      expect(result4.newStatus, equals(MessageStatus.aiSuccess));
    });

    test('消息状态转换 - 错误处理', () {
      // 创建流式处理中的消息
      final message = Message.assistant(
        id: 'test_message_3',
        conversationId: 'test_conversation',
        assistantId: 'test_assistant',
        status: MessageStatus.aiStreaming,
      );

      // 触发错误
      final result1 = stateManager.transitionMessageState(
        message: message,
        event: MessageStateEvent.error,
      );

      expect(result1.isSuccess, isTrue);
      expect(result1.newStatus, equals(MessageStatus.aiError));

      // 重试
      final updatedMessage = result1.updatedMessage!;
      final result2 = stateManager.transitionMessageState(
        message: updatedMessage,
        event: MessageStateEvent.retry,
      );

      expect(result2.isSuccess, isTrue);
      expect(result2.newStatus, equals(MessageStatus.aiPending));
    });

    test('无效状态转换', () {
      // 创建已完成的消息
      final message = Message.assistant(
        id: 'test_message_4',
        conversationId: 'test_conversation',
        assistantId: 'test_assistant',
        status: MessageStatus.aiSuccess,
      );

      // 尝试无效转换
      final result = stateManager.transitionMessageState(
        message: message,
        event: MessageStateEvent.startAiProcessing,
      );

      expect(result.isSuccess, isFalse);
      expect(result.error, isNotNull);
    });

    test('批量状态转换', () {
      // 创建多个测试消息
      final messages = List.generate(
          3,
          (index) => Message.assistant(
                id: 'test_message_batch_$index',
                conversationId: 'test_conversation',
                assistantId: 'test_assistant',
                status: MessageStatus.aiPending,
              ));

      // 批量转换状态
      final results = stateManager.batchTransitionMessageStates(
        messages: messages,
        event: MessageStateEvent.startAiProcessing,
      );

      expect(results.length, equals(3));
      for (final result in results.values) {
        expect(result.isSuccess, isTrue);
        expect(result.newStatus, equals(MessageStatus.aiProcessing));
      }
    });

    test('状态转换统计', () {
      // 执行一些状态转换
      final message = Message.assistant(
        id: 'test_message_stats',
        conversationId: 'test_conversation',
        assistantId: 'test_assistant',
        status: MessageStatus.aiPending,
      );

      stateManager.transitionMessageState(
        message: message,
        event: MessageStateEvent.startAiProcessing,
      );

      // 检查统计信息
      final stats = stateManager.getTransitionStatistics();
      expect(stats['totalTransitions'], greaterThan(0));
      expect(stats['successfulTransitions'], greaterThan(0));
    });

    test('状态转换历史记录', () {
      final message = Message.assistant(
        id: 'test_message_history',
        conversationId: 'test_conversation',
        assistantId: 'test_assistant',
        status: MessageStatus.aiPending,
      );

      // 执行状态转换
      stateManager.transitionMessageState(
        message: message,
        event: MessageStateEvent.startAiProcessing,
      );

      // 检查历史记录
      final history = stateManager.getTransitionHistory();
      expect(history, isNotEmpty);
      expect(history.last.fromStatus, equals(MessageStatus.aiPending));
      expect(history.last.toStatus, equals(MessageStatus.aiProcessing));
    });

    test('状态转换历史记录', () {
      // 注意：MessageStateManager 没有监听器功能，这里测试历史记录功能

      final message = Message.assistant(
        id: 'test_message_listener',
        conversationId: 'test_conversation',
        assistantId: 'test_assistant',
        status: MessageStatus.aiPending,
      );

      // 执行状态转换
      final result = stateManager.transitionMessageState(
        message: message,
        event: MessageStateEvent.startAiProcessing,
      );

      // 验证状态转换成功
      expect(result.isSuccess, isTrue);
      expect(result.newStatus, equals(MessageStatus.aiProcessing));
    });

    test('状态转换性能测试', () {
      final stopwatch = Stopwatch()..start();

      // 执行大量状态转换
      for (int i = 0; i < 1000; i++) {
        final message = Message.assistant(
          id: 'test_message_perf_$i',
          conversationId: 'test_conversation',
          assistantId: 'test_assistant',
          status: MessageStatus.aiPending,
        );

        stateManager.transitionMessageState(
          message: message,
          event: MessageStateEvent.startAiProcessing,
        );
      }

      stopwatch.stop();
      // 移除 print 语句，在测试中不需要输出

      // 验证性能在合理范围内（应该在1秒内完成）
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });
}
