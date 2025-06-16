import 'package:flutter/material.dart';

import '../../../../domain/entities/message_block.dart';
import '../../../../domain/entities/message_block_type.dart';
import '../bubble_context.dart';
import 'bubble_block_adapter.dart';

/// 文本块气泡适配器
/// 
/// 负责在气泡中渲染文本类型的消息块
class TextBubbleAdapter extends BubbleBlockAdapter {
  @override
  Widget buildInBubble(
    MessageBlock block,
    BubbleContext context, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    if (!block.hasContent) {
      return buildEmptyWidget(context, message: '文本内容为空');
    }

    return _buildTextContent(block, context);
  }

  @override
  bool canHandleBlock(MessageBlockType type) {
    return type == MessageBlockType.mainText;
  }

  @override
  List<MessageBlockType> get supportedTypes => [MessageBlockType.mainText];

  @override
  double getPreferredHeight(MessageBlock block, BubbleContext context) {
    if (!block.hasContent) return 40.0;

    final content = block.content!;
    final lines = content.split('\n').length;
    final baseLineHeight = getResponsiveFontSize(context, 16.0) * 1.4;
    
    return (lines * baseLineHeight) + 16.0; // 额外的16像素用于内边距
  }

  /// 构建文本内容
  Widget _buildTextContent(MessageBlock block, BubbleContext context) {
    final content = block.content!;
    
    // 检查是否包含Markdown格式
    if (_containsMarkdown(content)) {
      return _buildMarkdownContent(content, context);
    } else {
      return _buildPlainTextContent(content, context);
    }
  }

  /// 构建Markdown内容
  Widget _buildMarkdownContent(String content, BubbleContext context) {
    return SelectableText(
      content,
      style: TextStyle(
        fontSize: getResponsiveFontSize(context, 16.0),
        color: context.textColor,
        height: 1.4,
      ),
    );
  }

  /// 构建纯文本内容
  Widget _buildPlainTextContent(String content, BubbleContext context) {
    return SelectableText(
      content,
      style: TextStyle(
        fontSize: getResponsiveFontSize(context, 16.0),
        color: context.textColor,
        height: 1.4,
      ),
    );
  }



  /// 检查内容是否包含Markdown格式
  bool _containsMarkdown(String content) {
    // 简单的Markdown检测
    final markdownPatterns = [
      RegExp(r'#{1,6}\s'), // 标题
      RegExp(r'\*\*.*\*\*'), // 粗体
      RegExp(r'\*.*\*'), // 斜体
      RegExp(r'`.*`'), // 行内代码
      RegExp(r'```'), // 代码块
      RegExp(r'^\s*[-*+]\s', multiLine: true), // 列表
      RegExp(r'^\s*\d+\.\s', multiLine: true), // 有序列表
      RegExp(r'\[.*\]\(.*\)'), // 链接
      RegExp(r'!\[.*\]\(.*\)'), // 图片
      RegExp(r'^>', multiLine: true), // 引用
    ];

    return markdownPatterns.any((pattern) => pattern.hasMatch(content));
  }



  @override
  String get name => 'TextBubbleAdapter';

  @override
  int get priority => AdapterPriority.normal;
}

/// 文本块适配器扩展
extension TextBubbleAdapterExtensions on TextBubbleAdapter {
  /// 创建简单文本块
  static MessageBlock createTextBlock(String content) {
    return MessageBlock.text(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      messageId: 'temp',
      content: content,
    );
  }

  /// 创建Markdown文本块
  static MessageBlock createMarkdownBlock(String markdown) {
    return MessageBlock.text(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      messageId: 'temp',
      content: markdown,
    );
  }
}
