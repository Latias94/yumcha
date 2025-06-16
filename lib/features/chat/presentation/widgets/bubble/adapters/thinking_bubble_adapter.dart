import 'package:flutter/material.dart';

import '../../../../domain/entities/message_block.dart';
import '../../../../domain/entities/message_block_type.dart';
import '../bubble_context.dart';
import 'bubble_block_adapter.dart';

/// 思考过程块气泡适配器
/// 
/// 负责在气泡中渲染思考过程类型的消息块
class ThinkingBubbleAdapter extends BubbleBlockAdapter {
  @override
  Widget buildInBubble(
    MessageBlock block,
    BubbleContext context, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    if (!block.hasContent) {
      return buildEmptyWidget(context, message: '思考过程为空');
    }

    return _buildThinkingContent(block, context);
  }

  @override
  bool canHandleBlock(MessageBlockType type) {
    return type == MessageBlockType.thinking;
  }

  @override
  List<MessageBlockType> get supportedTypes => [MessageBlockType.thinking];

  @override
  double getPreferredHeight(MessageBlock block, BubbleContext context) {
    if (!block.hasContent) return 60.0;

    final content = block.content!;
    final lines = content.split('\n').length;
    final lineHeight = getResponsiveFontSize(context, 14.0) * 1.4;
    final headerHeight = 32.0; // 思考过程头部高度
    final padding = 24.0; // 内边距
    
    return headerHeight + (lines * lineHeight) + padding;
  }

  /// 构建思考过程内容
  Widget _buildThinkingContent(MessageBlock block, BubbleContext context) {
    final content = block.content!;
    final isCollapsible = _shouldBeCollapsible(content);

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: getResponsiveSpacing(context, 4.0),
      ),
      decoration: buildContainerDecoration(
        context,
        backgroundColor: context.theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderColor: context.theme.colorScheme.outline.withValues(alpha: 0.2),
        borderRadius: 8.0,
      ),
      child: isCollapsible
          ? _buildCollapsibleThinking(content, context)
          : _buildSimpleThinking(content, context),
    );
  }

  /// 构建可折叠的思考过程
  Widget _buildCollapsibleThinking(String content, BubbleContext context) {
    return Theme(
      data: context.theme.copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        leading: Icon(
          Icons.psychology_rounded,
          size: getResponsiveSpacing(context, 20.0),
          color: context.theme.colorScheme.primary,
        ),
        title: Text(
          '思考过程',
          style: TextStyle(
            fontSize: getResponsiveFontSize(context, 14.0),
            fontWeight: FontWeight.w600,
            color: context.theme.colorScheme.primary,
          ),
        ),
        subtitle: Text(
          _getThinkingSummary(content),
          style: TextStyle(
            fontSize: getResponsiveFontSize(context, 12.0),
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        initiallyExpanded: false,
        tilePadding: EdgeInsets.symmetric(
          horizontal: getResponsiveSpacing(context, 12.0),
          vertical: getResponsiveSpacing(context, 4.0),
        ),
        childrenPadding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(getResponsiveSpacing(context, 12.0)),
            child: _buildThinkingText(content, context),
          ),
        ],
      ),
    );
  }

  /// 构建简单的思考过程
  Widget _buildSimpleThinking(String content, BubbleContext context) {
    return Container(
      padding: EdgeInsets.all(getResponsiveSpacing(context, 12.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_rounded,
                size: getResponsiveSpacing(context, 16.0),
                color: context.theme.colorScheme.primary,
              ),
              SizedBox(width: getResponsiveSpacing(context, 8.0)),
              Text(
                '思考过程',
                style: TextStyle(
                  fontSize: getResponsiveFontSize(context, 12.0),
                  fontWeight: FontWeight.w600,
                  color: context.theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: getResponsiveSpacing(context, 8.0)),
          _buildThinkingText(content, context),
        ],
      ),
    );
  }

  /// 构建思考过程文本
  Widget _buildThinkingText(String content, BubbleContext context) {
    return SelectableText(
      content,
      style: TextStyle(
        fontSize: getResponsiveFontSize(context, 14.0),
        color: context.textColor.withValues(alpha: 0.8),
        height: 1.4,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  /// 判断是否应该可折叠
  bool _shouldBeCollapsible(String content) {
    // 如果内容超过3行或150个字符，则设为可折叠
    return content.split('\n').length > 3 || content.length > 150;
  }

  /// 获取思考过程摘要
  String _getThinkingSummary(String content) {
    // 取第一行作为摘要，如果太长则截断
    final firstLine = content.split('\n').first.trim();
    if (firstLine.length <= 50) {
      return firstLine;
    }
    return '${firstLine.substring(0, 47)}...';
  }

  @override
  String get name => 'ThinkingBubbleAdapter';

  @override
  int get priority => AdapterPriority.high;
}

/// 思考过程块适配器扩展
extension ThinkingBubbleAdapterExtensions on ThinkingBubbleAdapter {
  /// 创建思考过程块
  static MessageBlock createThinkingBlock(
    String content, {
    Map<String, dynamic>? metadata,
  }) {
    return MessageBlock.thinking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      messageId: 'temp',
      content: content,
    );
  }

  /// 从思考标签创建思考过程块
  static MessageBlock fromThinkingTags(String content) {
    // 移除 <thinking> 标签
    String cleanContent = content
        .replaceAll(RegExp(r'<thinking[^>]*>'), '')
        .replaceAll('</thinking>', '')
        .trim();

    return createThinkingBlock(cleanContent);
  }

  /// 检查文本是否包含思考过程标签
  static bool containsThinkingTags(String text) {
    return text.contains(RegExp(r'<thinking[^>]*>.*?</thinking>', dotAll: true));
  }

  /// 从文本中提取思考过程
  static List<String> extractThinkingProcesses(String text) {
    final regex = RegExp(r'<thinking[^>]*>(.*?)</thinking>', dotAll: true);
    final matches = regex.allMatches(text);
    
    return matches.map((match) => match.group(1)?.trim() ?? '').toList();
  }

  /// 移除文本中的思考过程标签
  static String removeThinkingTags(String text) {
    return text.replaceAll(RegExp(r'<thinking[^>]*>.*?</thinking>', dotAll: true), '').trim();
  }
}
