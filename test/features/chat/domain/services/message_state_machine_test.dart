import '../../../../../lib/features/chat/domain/services/message_state_machine.dart';
import '../../../../../lib/features/chat/domain/entities/message_status.dart';

/// 消息状态机测试
///
/// 验证状态转换的正确性和状态机的行为
void testMessageStateMachine() {
  final stateMachine = MessageStateMachine();

  print('=== 消息状态机测试 ===');

  // 测试1: 正常的AI消息流程
  print('\n测试1: 正常的AI消息流程');
  _testNormalAiFlow(stateMachine);

  // 测试2: 流式消息流程
  print('\n测试2: 流式消息流程');
  _testStreamingFlow(stateMachine);

  // 测试3: 错误处理流程
  print('\n测试3: 错误处理流程');
  _testErrorFlow(stateMachine);

  // 测试4: 暂停和恢复流程
  print('\n测试4: 暂停和恢复流程');
  _testPauseResumeFlow(stateMachine);

  // 测试5: 非法状态转换
  print('\n测试5: 非法状态转换');
  _testInvalidTransitions(stateMachine);

  print('\n=== 测试完成 ===');
}

void _testNormalAiFlow(MessageStateMachine stateMachine) {
  var currentStatus = MessageStatus.aiPending;

  // aiPending -> aiProcessing
  var result = stateMachine.transition(
    currentStatus: currentStatus,
    event: MessageStateEvent.startAiProcessing,
  );
  _printTransitionResult('aiPending -> aiProcessing', result);
  if (result.isValid) currentStatus = result.newStatus;

  // aiProcessing -> aiSuccess
  result = stateMachine.transition(
    currentStatus: currentStatus,
    event: MessageStateEvent.complete,
  );
  _printTransitionResult('aiProcessing -> aiSuccess', result);
}

void _testStreamingFlow(MessageStateMachine stateMachine) {
  var currentStatus = MessageStatus.aiPending;

  // aiPending -> aiStreaming
  var result = stateMachine.transition(
    currentStatus: currentStatus,
    event: MessageStateEvent.startStreaming,
  );
  _printTransitionResult('aiPending -> aiStreaming', result);
  if (result.isValid) currentStatus = result.newStatus;

  // aiStreaming -> aiPaused
  result = stateMachine.transition(
    currentStatus: currentStatus,
    event: MessageStateEvent.pause,
  );
  _printTransitionResult('aiStreaming -> aiPaused', result);
  if (result.isValid) currentStatus = result.newStatus;

  // aiPaused -> aiStreaming
  result = stateMachine.transition(
    currentStatus: currentStatus,
    event: MessageStateEvent.resume,
  );
  _printTransitionResult('aiPaused -> aiStreaming', result);
  if (result.isValid) currentStatus = result.newStatus;

  // aiStreaming -> aiSuccess
  result = stateMachine.transition(
    currentStatus: currentStatus,
    event: MessageStateEvent.complete,
  );
  _printTransitionResult('aiStreaming -> aiSuccess', result);
}

void _testErrorFlow(MessageStateMachine stateMachine) {
  var currentStatus = MessageStatus.aiStreaming;

  // aiStreaming -> aiError
  var result = stateMachine.transition(
    currentStatus: currentStatus,
    event: MessageStateEvent.error,
  );
  _printTransitionResult('aiStreaming -> aiError', result);
  if (result.isValid) currentStatus = result.newStatus;

  // aiError -> aiPending (重试)
  result = stateMachine.transition(
    currentStatus: currentStatus,
    event: MessageStateEvent.retry,
  );
  _printTransitionResult('aiError -> aiPending (重试)', result);
}

void _testPauseResumeFlow(MessageStateMachine stateMachine) {
  var currentStatus = MessageStatus.aiStreaming;

  // aiStreaming -> aiPaused
  var result = stateMachine.transition(
    currentStatus: currentStatus,
    event: MessageStateEvent.pause,
  );
  _printTransitionResult('aiStreaming -> aiPaused', result);
  if (result.isValid) currentStatus = result.newStatus;

  // aiPaused -> aiProcessing
  result = stateMachine.transition(
    currentStatus: currentStatus,
    event: MessageStateEvent.resume,
  );
  _printTransitionResult('aiPaused -> aiProcessing', result);
  if (result.isValid) currentStatus = result.newStatus;

  // aiProcessing -> aiError (cancelled)
  result = stateMachine.transition(
    currentStatus: currentStatus,
    event: MessageStateEvent.cancel,
  );
  _printTransitionResult('aiProcessing -> aiError (cancelled)', result);
}

void _testInvalidTransitions(MessageStateMachine stateMachine) {
  // 尝试从 aiSuccess 转换到 aiPending (无效)
  var result = stateMachine.transition(
    currentStatus: MessageStatus.aiSuccess,
    event: MessageStateEvent.startAiProcessing,
  );
  _printTransitionResult('aiSuccess -> aiPending (应该无效)', result);

  // 尝试从 userSuccess 转换到 aiStreaming (无效)
  result = stateMachine.transition(
    currentStatus: MessageStatus.userSuccess,
    event: MessageStateEvent.startStreaming,
  );
  _printTransitionResult('userSuccess -> aiStreaming (应该无效)', result);

  // 尝试从 aiPending 暂停流式传输 (无效)
  result = stateMachine.transition(
    currentStatus: MessageStatus.aiPending,
    event: MessageStateEvent.pause,
  );
  _printTransitionResult('aiPending -> pause (应该无效)', result);
}

void _printTransitionResult(String description, StateTransitionResult result) {
  if (result.isValid) {
    print('✅ $description: -> ${result.newStatus}');
    if (result.metadata != null && result.metadata!.isNotEmpty) {
      print('   元数据: ${result.metadata}');
    }
  } else {
    print('❌ $description: 转换无效');
    if (result.errorMessage != null) {
      print('   原因: ${result.errorMessage}');
    }
  }
}

// 运行测试的主函数
void main() {
  testMessageStateMachine();
}
