import 'message_state_machine.dart';
import '../entities/message_status.dart';

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
  
  // aiStreaming -> aiStreaming (流式更新)
  result = stateMachine.transition(
    currentStatus: currentStatus,
    event: MessageStateEvent.streaming,
  );
  _printTransitionResult('aiStreaming -> aiStreaming', result);
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
  
  // aiPaused -> aiProcessing (恢复)
  result = stateMachine.transition(
    currentStatus: currentStatus,
    event: MessageStateEvent.resume,
  );
  _printTransitionResult('aiPaused -> aiProcessing (恢复)', result);
}

void _testInvalidTransitions(MessageStateMachine stateMachine) {
  // 尝试从用户成功状态转换到AI处理状态（应该失败）
  var result = stateMachine.transition(
    currentStatus: MessageStatus.userSuccess,
    event: MessageStateEvent.startAiProcessing,
  );
  _printTransitionResult('userSuccess -> aiProcessing (应该失败)', result);
  
  // 尝试从AI成功状态转换到流式状态（应该失败）
  result = stateMachine.transition(
    currentStatus: MessageStatus.aiSuccess,
    event: MessageStateEvent.startStreaming,
  );
  _printTransitionResult('aiSuccess -> aiStreaming (应该失败)', result);
}

void _printTransitionResult(String description, StateTransitionResult result) {
  if (result.isValid) {
    print('✅ $description: ${result.newStatus.name}');
  } else {
    print('❌ $description: ${result.errorMessage}');
  }
}

/// 测试状态机的辅助方法
void testStateMachineHelpers() {
  final stateMachine = MessageStateMachine();
  
  print('\n=== 状态机辅助方法测试 ===');
  
  // 测试状态检查方法
  print('\n状态检查方法:');
  print('aiStreaming是否为终态: ${stateMachine.isFinalState(MessageStatus.aiStreaming)}');
  print('aiSuccess是否为终态: ${stateMachine.isFinalState(MessageStatus.aiSuccess)}');
  print('aiError是否为错误态: ${stateMachine.isErrorState(MessageStatus.aiError)}');
  print('aiStreaming是否为活跃态: ${stateMachine.isActiveState(MessageStatus.aiStreaming)}');
  
  // 测试优先级
  print('\n状态优先级:');
  print('aiError优先级: ${stateMachine.getStatusPriority(MessageStatus.aiError)}');
  print('aiStreaming优先级: ${stateMachine.getStatusPriority(MessageStatus.aiStreaming)}');
  print('aiSuccess优先级: ${stateMachine.getStatusPriority(MessageStatus.aiSuccess)}');
  
  // 测试建议操作
  print('\n建议操作:');
  final errorActions = stateMachine.getSuggestedActions(MessageStatus.aiError);
  print('aiError状态的建议操作: ${errorActions.map((e) => e.name).join(', ')}');
  
  final streamingActions = stateMachine.getSuggestedActions(MessageStatus.aiStreaming);
  print('aiStreaming状态的建议操作: ${streamingActions.map((e) => e.name).join(', ')}');
}

/// 运行所有测试
void runAllTests() {
  testMessageStateMachine();
  testStateMachineHelpers();
}
