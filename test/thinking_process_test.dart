import 'package:flutter_test/flutter_test.dart';
import 'package:yumcha/features/chat/presentation/screens/widgets/thinking_process_widget.dart';

void main() {
  group('ThinkingProcessParser', () {
    test('should parse message with thinking process', () {
      const messageWithThinking = '''
<think>
这是一个复杂的问题，我需要仔细思考。

首先，我需要分析用户的需求：
1. 用户想要了解Flutter的状态管理
2. 需要比较不同的解决方案
3. 给出实际的建议

让我从几个角度来分析：
- Provider vs Riverpod
- 性能考虑
- 学习曲线
- 社区支持

基于这些分析，我认为Riverpod是更好的选择，因为：
- 更好的类型安全
- 更清晰的依赖注入
- 更好的测试支持
</think>

关于Flutter状态管理，我推荐使用Riverpod。

Riverpod相比Provider有以下优势：

1. **类型安全**：编译时检查，减少运行时错误
2. **依赖注入**：更清晰的依赖关系管理
3. **测试友好**：更容易进行单元测试

这里是一个简单的例子：

```dart
final counterProvider = StateProvider<int>((ref) => 0);

class CounterWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Text('Count: \$count');
  }
}
```

希望这个回答对你有帮助！
''';

      final result = ThinkingProcessParser.parseMessage(messageWithThinking);

      expect(result.hasThinkingProcess, true);
      expect(result.thinkingContent, contains('这是一个复杂的问题'));
      expect(result.thinkingContent, contains('基于这些分析'));
      expect(result.actualContent, contains('关于Flutter状态管理'));
      expect(result.actualContent, contains('希望这个回答对你有帮助'));
      expect(result.actualContent, isNot(contains('<think>')));
      expect(result.actualContent, isNot(contains('</think>')));
    });

    test('should handle message without thinking process', () {
      const normalMessage = '''
这是一个普通的回复消息，没有思考过程。

只是简单的回答用户的问题。
''';

      final result = ThinkingProcessParser.parseMessage(normalMessage);

      expect(result.hasThinkingProcess, false);
      expect(result.thinkingContent, isEmpty);
      expect(result.actualContent, equals(normalMessage));
    });

    test('should handle empty thinking tags', () {
      const messageWithEmptyThinking = '''
<think></think>

这是实际的回复内容。
''';

      final result =
          ThinkingProcessParser.parseMessage(messageWithEmptyThinking);

      expect(result.hasThinkingProcess, true);
      expect(result.thinkingContent, isEmpty);
      expect(result.actualContent, equals('这是实际的回复内容。'));
    });

    test('should handle multiple thinking blocks', () {
      const messageWithMultipleThinking = '''
<think>
第一个思考过程
</think>

中间的内容

<think>
第二个思考过程
</think>

最终的回复内容
''';

      final result =
          ThinkingProcessParser.parseMessage(messageWithMultipleThinking);

      expect(result.hasThinkingProcess, true);
      expect(result.actualContent, contains('中间的内容'));
      expect(result.actualContent, contains('最终的回复内容'));
      expect(result.actualContent, isNot(contains('<think>')));
      expect(result.actualContent, isNot(contains('</think>')));
    });

    test('should handle malformed thinking tags', () {
      const messageWithMalformedThinking = '''
<think>
这是一个没有结束标签的思考过程

这应该被当作普通内容处理。
''';

      final result =
          ThinkingProcessParser.parseMessage(messageWithMalformedThinking);

      expect(result.hasThinkingProcess, false);
      expect(result.actualContent, equals(messageWithMalformedThinking));
    });

    test('should preserve whitespace and formatting in thinking content', () {
      const messageWithFormattedThinking = '''
<think>
让我分析一下这个问题：

1. 首先考虑A方案
   - 优点：简单易懂
   - 缺点：性能较差

2. 然后考虑B方案
   - 优点：性能好
   - 缺点：复杂度高

结论：选择B方案
</think>

基于分析，我推荐B方案。
''';

      final result =
          ThinkingProcessParser.parseMessage(messageWithFormattedThinking);

      expect(result.hasThinkingProcess, true);
      expect(result.thinkingContent, contains('1. 首先考虑A方案'));
      expect(result.thinkingContent, contains('   - 优点：简单易懂'));
      expect(result.thinkingContent, contains('2. 然后考虑B方案'));
      expect(result.actualContent, equals('基于分析，我推荐B方案。'));
    });
  });
}
