import 'package:flutter/material.dart';
import '../../../chat/domain/entities/message.dart';
import '../../../chat/presentation/screens/widgets/chat_message_view.dart';

/// 思考过程功能演示页面
class ThinkingProcessDemo extends StatelessWidget {
  const ThinkingProcessDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('思考过程演示'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 说明文本
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '思考过程功能演示',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '这个页面演示了AI推理模型的思考过程显示功能。'
                    '当AI回复包含 <think>...</think> 标签时，'
                    '思考过程会被提取并显示在一个可折叠的组件中。',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 用户消息
          ChatMessageView(
            message: Message(
              author: '用户',
              content: '请帮我分析一下Flutter和React Native的优缺点，并给出选择建议。',
              timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
              isFromUser: true,
            ),
          ),
          const SizedBox(height: 8),

          // 包含思考过程的AI回复
          ChatMessageView(
            message: Message(
              author: 'AI助手',
              content: '''<think>
这是一个关于移动开发框架选择的问题，我需要从多个角度来分析：

1. 技术架构对比：
   - Flutter使用Dart语言，自绘UI，性能接近原生
   - React Native使用JavaScript，桥接原生组件

2. 开发体验：
   - Flutter：热重载快，工具链完整，但需要学习Dart
   - React Native：可以复用Web开发经验，但调试相对复杂

3. 性能表现：
   - Flutter：渲染性能更好，UI一致性强
   - React Native：依赖原生组件，可能有性能瓶颈

4. 生态系统：
   - Flutter：Google支持，生态快速发展
   - React Native：Facebook支持，生态更成熟

5. 学习成本：
   - Flutter：需要学习Dart，但概念相对简单
   - React Native：前端开发者容易上手

基于这些分析，我需要给出平衡的建议，考虑不同场景的适用性。
</think>

关于Flutter和React Native的选择，我来为你详细分析一下：

## 技术架构对比

**Flutter**
- 使用Dart语言开发
- 自绘UI引擎，直接调用GPU
- 编译为原生代码，性能接近原生应用

**React Native**
- 使用JavaScript/TypeScript开发
- 桥接原生UI组件
- 通过Bridge与原生代码通信

## 主要优缺点

### Flutter优势：
1. **性能优秀**：自绘UI，60fps流畅体验
2. **UI一致性**：跨平台UI完全一致
3. **开发效率**：热重载极快，开发体验好
4. **Google支持**：持续投入，生态快速发展

### Flutter劣势：
1. **学习成本**：需要学习Dart语言
2. **包体积**：相对较大
3. **生态相对年轻**：某些第三方库可能不够成熟

### React Native优势：
1. **技术栈熟悉**：前端开发者容易上手
2. **生态成熟**：大量可用的第三方库
3. **代码复用**：可以与Web项目共享部分代码
4. **Facebook支持**：大厂背书，稳定性好

### React Native劣势：
1. **性能瓶颈**：Bridge通信可能影响性能
2. **平台差异**：不同平台可能有UI差异
3. **调试复杂**：跨语言调试相对困难

## 选择建议

**选择Flutter的场景：**
- 追求高性能和流畅体验
- 需要跨平台UI完全一致
- 团队愿意学习新技术
- 项目对包体积不敏感

**选择React Native的场景：**
- 团队有丰富的前端经验
- 需要快速上手和开发
- 希望与Web项目共享代码
- 对第三方生态依赖较重

总的来说，如果你是新项目且追求性能，我更推荐Flutter；如果团队有React经验且希望快速开发，React Native是不错的选择。''',
              timestamp: DateTime.now(),
              isFromUser: false,
            ),
          ),
          const SizedBox(height: 16),

          // 用户消息
          ChatMessageView(
            message: Message(
              author: '用户',
              content: '那学习Flutter需要多长时间？',
              timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
              isFromUser: true,
            ),
          ),
          const SizedBox(height: 8),

          // 简单的AI回复（无思考过程）
          ChatMessageView(
            message: Message(
              author: 'AI助手',
              content: '''学习Flutter的时间因人而异，大致可以分为几个阶段：

**基础入门（1-2周）**
- Dart语言基础
- Flutter基本概念和Widget
- 简单的UI布局

**进阶开发（1-2个月）**
- 状态管理（Provider/Riverpod）
- 网络请求和数据处理
- 导航和路由

**熟练应用（3-6个月）**
- 复杂UI设计
- 性能优化
- 原生插件集成

如果你有编程基础，特别是移动开发经验，学习会更快一些。建议从官方文档和实际项目开始！''',
              timestamp: DateTime.now(),
              isFromUser: false,
            ),
          ),
          const SizedBox(height: 16),

          // 另一个包含思考过程的例子
          ChatMessageView(
            message: Message(
              author: 'AI助手',
              content: '''<think>
用户问的是一个技术实现问题，我需要考虑：

1. 状态管理的复杂度
2. 性能影响
3. 代码可维护性
4. 最佳实践

对于这种场景，我应该推荐使用Riverpod，因为：
- 类型安全更好
- 依赖注入更清晰
- 测试更容易
- 是Provider的进化版本

我需要给出具体的代码示例来说明。
</think>

对于Flutter的状态管理，我推荐使用**Riverpod**。

这里是一个简单的计数器例子：

```dart
// 1. 定义Provider
final counterProvider = StateProvider<int>((ref) => 0);

// 2. 在Widget中使用
class CounterWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);

    return Column(
      children: [
        Text('Count: \$counter'),
        ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).state++,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

Riverpod的主要优势：
- **类型安全**：编译时检查
- **依赖注入**：清晰的依赖关系
- **测试友好**：容易mock和测试''',
              timestamp: DateTime.now(),
              isFromUser: false,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
