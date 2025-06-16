// 🧪 聊天显示效果测试屏幕
//
// 用于测试和演示不同聊天样式和消息块显示效果的测试界面。
// 提供各种类型的测试消息，帮助验证消息块的显示是否正常工作。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_block.dart';
import '../../domain/entities/message_block_type.dart';
import '../../domain/entities/message_block_status.dart';
import '../../domain/entities/message_status.dart';
import '../widgets/message_view_adapter.dart';
import '../providers/chat_providers.dart';
import '../providers/chat_style_provider.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';

class ChatDisplayTestScreen extends ConsumerWidget {
  const ChatDisplayTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatSettings = ref.watch(chatSettingsProvider);
    final currentStyle = ref.watch(currentChatStyleProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天显示效果测试'),
        actions: [
          // 快速切换块化视图
          IconButton(
            icon: Icon(
              chatSettings.enableBlockView 
                ? Icons.view_module_rounded 
                : Icons.view_list_rounded
            ),
            onPressed: () {
              ref.read(chatSettingsProvider.notifier).toggleBlockView();
            },
            tooltip: chatSettings.enableBlockView ? '切换到传统视图' : '切换到块化视图',
          ),
          // 打开设置
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.of(context).pushNamed('/chat/display-settings');
            },
            tooltip: '显示设置',
          ),
        ],
      ),
      body: Column(
        children: [
          // 状态指示器
          Container(
            width: double.infinity,
            padding: DesignConstants.paddingM,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Icon(
                  chatSettings.enableBlockView 
                    ? Icons.view_module_rounded 
                    : Icons.view_list_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '当前模式: ${chatSettings.enableBlockView ? "块化视图" : "传统视图"}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.palette_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '样式: ${currentStyle.displayName}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          
          // 测试消息列表
          Expanded(
            child: ListView(
              padding: DesignConstants.paddingM,
              children: [
                // 用户消息
                MessageViewAdapter(
                  message: _createUserMessage(),
                  useBlockView: chatSettings.enableBlockView,
                ),
                
                const SizedBox(height: 16),
                
                // 简单AI回复
                MessageViewAdapter(
                  message: _createSimpleAIMessage(),
                  useBlockView: chatSettings.enableBlockView,
                ),
                
                const SizedBox(height: 16),
                
                // 复杂AI回复（包含多种块类型）
                MessageViewAdapter(
                  message: _createComplexAIMessage(),
                  useBlockView: chatSettings.enableBlockView,
                ),
                
                const SizedBox(height: 16),
                
                // 错误消息
                MessageViewAdapter(
                  message: _createErrorMessage(),
                  useBlockView: chatSettings.enableBlockView,
                ),
                
                const SizedBox(height: 16),
                
                // 流式消息（处理中）
                MessageViewAdapter(
                  message: _createStreamingMessage(),
                  useBlockView: chatSettings.enableBlockView,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 创建用户消息
  Message _createUserMessage() {
    final now = DateTime.now();
    return Message(
      id: 'test_user_1',
      conversationId: 'test_conversation',
      role: 'user',
      assistantId: 'test_assistant',
      createdAt: now,
      updatedAt: now,
      status: MessageStatus.userSuccess,
      blocks: [
        MessageBlock(
          id: 'test_user_1_text',
          messageId: 'test_user_1',
          type: MessageBlockType.mainText,
          status: MessageBlockStatus.success,
          createdAt: now,
          content: '请帮我写一个Flutter的Hello World程序，并解释一下代码的结构。',
        ),
      ],
    );
  }

  /// 创建简单AI消息
  Message _createSimpleAIMessage() {
    final now = DateTime.now();
    return Message(
      id: 'test_ai_1',
      conversationId: 'test_conversation',
      role: 'assistant',
      assistantId: 'test_assistant',
      createdAt: now,
      updatedAt: now,
      status: MessageStatus.aiSuccess,
      blocks: [
        MessageBlock(
          id: 'test_ai_1_text',
          messageId: 'test_ai_1',
          type: MessageBlockType.mainText,
          status: MessageBlockStatus.success,
          createdAt: now,
          content: '好的！我来帮你创建一个Flutter的Hello World程序。这是一个很好的开始学习Flutter的方式。',
        ),
      ],
    );
  }

  /// 创建复杂AI消息（包含多种块类型）
  Message _createComplexAIMessage() {
    final now = DateTime.now();
    return Message(
      id: 'test_ai_2',
      conversationId: 'test_conversation',
      role: 'assistant',
      assistantId: 'test_assistant',
      createdAt: now,
      updatedAt: now,
      status: MessageStatus.aiSuccess,
      blocks: [
        // 思考过程块
        MessageBlock(
          id: 'test_ai_2_thinking',
          messageId: 'test_ai_2',
          type: MessageBlockType.thinking,
          status: MessageBlockStatus.success,
          createdAt: now,
          content: '用户想要一个Flutter Hello World程序。我需要提供一个完整的示例，包括main.dart文件的内容，并解释每个部分的作用。',
        ),
        
        // 主文本块
        MessageBlock(
          id: 'test_ai_2_text',
          messageId: 'test_ai_2',
          type: MessageBlockType.mainText,
          status: MessageBlockStatus.success,
          createdAt: now,
          content: '下面是一个完整的Flutter Hello World程序：',
        ),
        
        // 代码块
        MessageBlock(
          id: 'test_ai_2_code',
          messageId: 'test_ai_2',
          type: MessageBlockType.code,
          status: MessageBlockStatus.success,
          createdAt: now,
          language: 'dart',
          content: '''import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello World'),
      ),
      body: Center(
        child: Text(
          'Hello, World!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}''',
        ),
        
        // 解释文本块
        MessageBlock(
          id: 'test_ai_2_explanation',
          messageId: 'test_ai_2',
          type: MessageBlockType.mainText,
          status: MessageBlockStatus.success,
          createdAt: now,
          content: '''## 代码结构解释：

1. **导入包**: `import 'package:flutter/material.dart'` 导入Flutter的Material Design组件
2. **main函数**: 程序的入口点，调用`runApp()`启动应用
3. **MyApp类**: 应用的根组件，继承自StatelessWidget
4. **MaterialApp**: 提供Material Design的基础结构
5. **MyHomePage**: 主页面组件，包含AppBar和居中的文本

这个程序会显示一个带有"Hello World"标题的页面，中央显示"Hello, World!"文本。''',
        ),
      ],
    );
  }

  /// 创建错误消息
  Message _createErrorMessage() {
    final now = DateTime.now();
    return Message(
      id: 'test_error_1',
      conversationId: 'test_conversation',
      role: 'assistant',
      assistantId: 'test_assistant',
      createdAt: now,
      updatedAt: now,
      status: MessageStatus.aiError,
      blocks: [
        MessageBlock(
          id: 'test_error_1_error',
          messageId: 'test_error_1',
          type: MessageBlockType.error,
          status: MessageBlockStatus.error,
          createdAt: now,
          content: '抱歉，在处理您的请求时遇到了网络连接问题。请稍后重试。',
          error: {
            'code': 'NETWORK_ERROR',
            'message': 'Connection timeout',
          },
        ),
      ],
    );
  }

  /// 创建流式消息（处理中）
  Message _createStreamingMessage() {
    final now = DateTime.now();
    return Message(
      id: 'test_streaming_1',
      conversationId: 'test_conversation',
      role: 'assistant',
      assistantId: 'test_assistant',
      createdAt: now,
      updatedAt: now,
      status: MessageStatus.aiProcessing,
      blocks: [
        MessageBlock(
          id: 'test_streaming_1_text',
          messageId: 'test_streaming_1',
          type: MessageBlockType.mainText,
          status: MessageBlockStatus.streaming,
          createdAt: now,
          content: '正在为您生成回复...',
        ),
      ],
    );
  }
}
