import 'package:flutter_test/flutter_test.dart';
import 'package:yumcha/models/message.dart';

/// 模拟消息过滤逻辑的函数
List<Message> filterEmptyAiMessages(List<Message> messages) {
  return messages.where((message) {
    // 跳过空内容的AI消息（流式传输的占位符）
    if (!message.isFromUser && message.content.trim().isEmpty) {
      return false;
    }
    return true;
  }).toList();
}

void main() {
  group('流式消息处理测试', () {
    test('应该跳过空内容的AI消息', () {
      final messages = [
        // 用户消息
        Message(
          content: '你好',
          timestamp: DateTime.now(),
          isFromUser: true,
          author: '用户',
        ),
        // 空的AI消息（流式传输占位符）
        Message(
          content: '',
          timestamp: DateTime.now(),
          isFromUser: false,
          author: 'AI助手',
        ),
        // 完整的AI消息
        Message(
          content: '你好！我是AI助手，很高兴为您服务。',
          timestamp: DateTime.now(),
          isFromUser: false,
          author: 'AI助手',
        ),
      ];

      // 过滤消息
      final filteredMessages = filterEmptyAiMessages(messages);

      // 验证只保留了2条消息（用户消息 + 完整的AI消息），空的AI消息被跳过
      expect(filteredMessages.length, equals(2));

      // 验证消息内容
      expect(filteredMessages[0].content, equals('你好'));
      expect(filteredMessages[0].isFromUser, isTrue);

      expect(filteredMessages[1].content, equals('你好！我是AI助手，很高兴为您服务。'));
      expect(filteredMessages[1].isFromUser, isFalse);
    });

    test('应该保留空内容的用户消息', () {
      final messages = [
        // 空的用户消息（应该保留）
        Message(
          content: '',
          timestamp: DateTime.now(),
          isFromUser: true,
          author: '用户',
        ),
        // 空的AI消息（应该被过滤）
        Message(
          content: '',
          timestamp: DateTime.now(),
          isFromUser: false,
          author: 'AI助手',
        ),
      ];

      // 过滤消息
      final filteredMessages = filterEmptyAiMessages(messages);

      // 验证只保留了1条消息（用户消息），空的AI消息被跳过
      expect(filteredMessages.length, equals(1));
      expect(filteredMessages[0].isFromUser, isTrue);
    });

    test('应该保留只有空格的AI消息', () {
      final messages = [
        // 只有空格的AI消息（应该被过滤）
        Message(
          content: '   ',
          timestamp: DateTime.now(),
          isFromUser: false,
          author: 'AI助手',
        ),
        // 有内容的AI消息（应该保留）
        Message(
          content: '你好',
          timestamp: DateTime.now(),
          isFromUser: false,
          author: 'AI助手',
        ),
      ];

      // 过滤消息
      final filteredMessages = filterEmptyAiMessages(messages);

      // 验证只保留了1条消息（有内容的AI消息）
      expect(filteredMessages.length, equals(1));
      expect(filteredMessages[0].content, equals('你好'));
    });
  });
}
