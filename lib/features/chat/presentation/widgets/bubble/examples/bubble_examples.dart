import 'package:flutter/material.dart';

import '../../../../domain/entities/message.dart';
import '../../../../domain/entities/message_block.dart';
import '../../../../domain/entities/message_block_type.dart';
import '../../../../domain/entities/message_block_status.dart';
import '../../../../domain/entities/message_status.dart';
import '../bubble_system.dart';

/// 气泡系统使用示例
///
/// 展示如何使用新的MessageBubble组件系统
class BubbleExamples extends StatefulWidget {
  const BubbleExamples({super.key});

  @override
  State<BubbleExamples> createState() => _BubbleExamplesState();
}

class _BubbleExamplesState extends State<BubbleExamples> {
  @override
  void initState() {
    super.initState();
    // 初始化气泡系统
    BubbleSystem.initialize();
  }

  /// 创建带有blocks的用户消息的辅助方法
  Message _createUserMessage(String id, List<MessageBlock> blocks) {
    return Message.user(
      id: id,
      conversationId: 'conv_1',
      assistantId: 'assistant_1',
      blockIds: blocks.map((b) => b.id).toList(),
    ).copyWith(blocks: blocks);
  }

  /// 创建带有blocks的AI消息的辅助方法
  Message _createAiMessage(String id, List<MessageBlock> blocks,
      {MessageStatus? status}) {
    return Message.assistant(
      id: id,
      conversationId: 'conv_1',
      assistantId: 'assistant_1',
      status: status ?? MessageStatus.aiSuccess,
      blockIds: blocks.map((b) => b.id).toList(),
    ).copyWith(blocks: blocks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('气泡系统示例'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('用户消息'),
          _buildUserTextMessage(),
          const SizedBox(height: 16),
          _buildSectionTitle('AI消息 - 文本'),
          _buildAiTextMessage(),
          const SizedBox(height: 16),
          _buildSectionTitle('不同样式对比'),
          _buildStyleComparison(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildUserTextMessage() {
    final textBlock = MessageBlock.text(
      id: 'block_1',
      messageId: 'user_1',
      content: '你好！请帮我写一个Flutter的Hello World程序。',
    );

    final message = Message.user(
      id: 'user_1',
      conversationId: 'conv_1',
      assistantId: 'assistant_1',
      blockIds: ['block_1'],
    ).copyWith(blocks: [textBlock]);

    return MessageBubble(
      message: message,
      style: BubbleStyle.bubble(),
      onTap: () => _showMessage('用户消息被点击'),
    );
  }

  Widget _buildAiTextMessage() {
    final textBlock = MessageBlock.text(
      id: 'block_2',
      messageId: 'ai_1',
      content:
          '当然可以！我来为您创建一个简单的Flutter Hello World程序。\n\n这是一个基础的Flutter应用程序结构，包含了必要的组件和布局。',
    );

    final message = _createAiMessage('ai_1', [textBlock]);

    return MessageBubble(
      message: message,
      style: BubbleStyle.bubble(),
      onEdit: () => _showMessage('编辑AI消息'),
      onRegenerate: () => _showMessage('重新生成AI消息'),
    );
  }

  Widget _buildStyleComparison() {
    final textBlock = MessageBlock.text(
      id: 'block_10',
      messageId: 'ai_5',
      content: '这是相同内容在不同样式下的显示效果。',
    );

    final message = _createAiMessage('ai_5', [textBlock]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('气泡样式:', style: Theme.of(context).textTheme.bodySmall),
        MessageBubble(message: message, style: BubbleStyle.bubble()),
        const SizedBox(height: 8),
        Text('卡片样式:', style: Theme.of(context).textTheme.bodySmall),
        MessageBubble(message: message, style: BubbleStyle.card()),
        const SizedBox(height: 8),
        Text('列表样式:', style: Theme.of(context).textTheme.bodySmall),
        MessageBubble(message: message, style: BubbleStyle.list()),
      ],
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    BubbleSystem.dispose();
    super.dispose();
  }
}
