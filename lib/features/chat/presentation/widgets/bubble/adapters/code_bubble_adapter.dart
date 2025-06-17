import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../domain/entities/message_block.dart';
import '../../../../domain/entities/message_block_type.dart';
import '../../../../../../shared/presentation/design_system/design_constants.dart';
import '../bubble_context.dart';
import 'bubble_block_adapter.dart';

/// 代码块气泡适配器
///
/// 负责在气泡中渲染代码类型的消息块
class CodeBubbleAdapter extends BubbleBlockAdapter {
  @override
  Widget buildInBubble(
    MessageBlock block,
    BubbleContext context, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    if (!block.hasContent) {
      return buildEmptyWidget(context, message: '代码内容为空');
    }

    return _buildCodeContent(block, context);
  }

  @override
  bool canHandleBlock(MessageBlockType type) {
    return type == MessageBlockType.code;
  }

  @override
  List<MessageBlockType> get supportedTypes => [MessageBlockType.code];

  @override
  double getPreferredHeight(MessageBlock block, BubbleContext context) {
    if (!block.hasContent) return 60.0;

    final content = block.content!;
    final lines = content.split('\n').length;
    final lineHeight = getResponsiveFontSize(context, 14.0) * 1.3;
    final headerHeight = 40.0; // 代码头部高度
    final padding = 24.0; // 内边距

    return headerHeight + (lines * lineHeight) + padding;
  }

  /// 构建代码内容
  Widget _buildCodeContent(MessageBlock block, BubbleContext context) {
    final language = _getLanguage(block);
    final content = block.content!;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: getResponsiveSpacing(context, 4.0),
      ),
      decoration: buildContainerDecoration(
        context,
        backgroundColor: context.theme.colorScheme.surfaceContainerHighest,
        borderColor: context.theme.colorScheme.outline.withValues(alpha: 0.2),
        borderRadius: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCodeHeader(language, context, content),
          _buildCodeBody(content, context),
        ],
      ),
    );
  }

  /// 构建代码头部
  Widget _buildCodeHeader(
      String language, BubbleContext context, String content) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: getResponsiveSpacing(context, 12.0),
        vertical: getResponsiveSpacing(context, 8.0),
      ),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(getResponsiveSpacing(context, 8.0)),
          topRight: Radius.circular(getResponsiveSpacing(context, 8.0)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getLanguageIcon(language),
            size: getResponsiveSpacing(context, 16.0),
            color: context.theme.colorScheme.primary,
          ),
          SizedBox(width: getResponsiveSpacing(context, 8.0)),
          Text(
            language.toUpperCase(),
            style: TextStyle(
              fontSize: getResponsiveFontSize(context, 12.0),
              fontWeight: FontWeight.w600,
              color: context.theme.colorScheme.primary,
            ),
          ),
          const Spacer(),
          _buildCopyButton(content, context),
        ],
      ),
    );
  }

  /// 构建代码主体
  Widget _buildCodeBody(String content, BubbleContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(getResponsiveSpacing(context, 12.0)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          content,
          style: TextStyle(
            fontSize: getResponsiveFontSize(context, 14.0),
            fontFamily: 'monospace',
            color: context.textColor,
            height: 1.3,
          ),
        ),
      ),
    );
  }

  /// 构建复制按钮
  Widget _buildCopyButton(String content, BubbleContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _copyToClipboard(content, context),
        borderRadius: BorderRadius.circular(getResponsiveSpacing(context, 4.0)),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.copy_outlined,
                size: getResponsiveSpacing(context, 14.0),
                color:
                    context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              SizedBox(width: getResponsiveSpacing(context, 4.0)),
              Text(
                '复制',
                style: TextStyle(
                  fontSize: getResponsiveFontSize(context, 11.0),
                  color: context.theme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 获取编程语言
  String _getLanguage(MessageBlock block) {
    // 从元数据中获取语言
    final language = block.metadata?['language'] as String?;
    if (language != null && language.isNotEmpty) {
      return language;
    }

    // 尝试从内容中检测语言
    return _detectLanguage(block.content ?? '');
  }

  /// 检测编程语言
  String _detectLanguage(String content) {
    // 简单的语言检测逻辑
    if (content.contains('import ') && content.contains('class ')) {
      if (content.contains('def ')) return 'python';
      if (content.contains('public ')) return 'java';
      if (content.contains('function ')) return 'javascript';
    }

    if (content.contains('<?php')) return 'php';
    if (content.contains('#include')) return 'c';
    if (content.contains('fn main()')) return 'rust';
    if (content.contains('func main()')) return 'go';
    if (content.contains('SELECT ') || content.contains('INSERT '))
      return 'sql';
    if (content.contains('<html') || content.contains('<div')) return 'html';
    if (content.contains('{') && content.contains('color:')) return 'css';
    if (content.contains('```')) return 'markdown';
    if (content.contains('"scripts"') && content.contains('"dependencies"'))
      return 'json';

    return 'code';
  }

  /// 获取语言图标
  IconData _getLanguageIcon(String language) {
    switch (language.toLowerCase()) {
      case 'python':
        return Icons.code;
      case 'javascript':
      case 'js':
        return Icons.javascript;
      case 'dart':
        return Icons.code;
      case 'java':
        return Icons.code;
      case 'html':
        return Icons.web;
      case 'css':
        return Icons.style;
      case 'sql':
        return Icons.storage;
      case 'json':
        return Icons.data_object;
      case 'markdown':
      case 'md':
        return Icons.text_fields;
      default:
        return Icons.code;
    }
  }

  /// 复制代码到剪贴板
  void _copyToClipboard(String content, BubbleContext context) {
    Clipboard.setData(ClipboardData(text: content));

    // 显示复制成功的提示
    ScaffoldMessenger.of(context.theme.platform as BuildContext).showSnackBar(
      SnackBar(
        content: const Text('代码已复制到剪贴板'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  String get name => 'CodeBubbleAdapter';

  @override
  int get priority => AdapterPriority.high;
}

/// 代码块适配器扩展
extension CodeBubbleAdapterExtensions on CodeBubbleAdapter {
  /// 创建代码块
  static MessageBlock createCodeBlock(
    String content, {
    String? language,
    Map<String, dynamic>? metadata,
  }) {
    return MessageBlock.code(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      messageId: 'temp',
      content: content,
      language: language,
    );
  }

  /// 从Markdown代码块创建
  static MessageBlock fromMarkdownCodeBlock(String markdownCode) {
    final lines = markdownCode.split('\n');
    if (lines.isEmpty) {
      return createCodeBlock('');
    }

    String? language;
    String content;

    // 检查是否有语言标识
    final firstLine = lines.first.trim();
    if (firstLine.startsWith('```')) {
      language = firstLine.substring(3).trim();
      if (language.isEmpty) language = null;

      // 移除第一行和最后一行的```
      final codeLines = lines.skip(1).toList();
      if (codeLines.isNotEmpty && codeLines.last.trim() == '```') {
        codeLines.removeLast();
      }
      content = codeLines.join('\n');
    } else {
      content = markdownCode;
    }

    return createCodeBlock(content, language: language);
  }
}
