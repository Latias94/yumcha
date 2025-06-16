import 'package:flutter/material.dart';

import '../../../../domain/entities/message_block.dart';
import '../../../../domain/entities/message_block_type.dart';
import '../bubble_context.dart';
import 'bubble_block_adapter.dart';

/// 引用块气泡适配器
/// 
/// 负责在气泡中渲染引用类型的消息块
class QuoteBubbleAdapter extends BubbleBlockAdapter {
  @override
  Widget buildInBubble(
    MessageBlock block,
    BubbleContext context, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    if (!block.hasContent) {
      return buildEmptyWidget(context, message: '引用内容为空');
    }

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: getResponsiveSpacing(context, 4.0),
      ),
      child: _buildQuoteContent(block, context),
    );
  }

  @override
  bool canHandleBlock(MessageBlockType type) {
    return type == MessageBlockType.citation;
  }

  @override
  List<MessageBlockType> get supportedTypes => [MessageBlockType.citation];

  /// 构建引用内容
  Widget _buildQuoteContent(MessageBlock block, BubbleContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: context.theme.colorScheme.primary,
            width: 4.0,
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(
          left: getResponsiveSpacing(context, 12.0),
          top: getResponsiveSpacing(context, 8.0),
          bottom: getResponsiveSpacing(context, 8.0),
          right: getResponsiveSpacing(context, 8.0),
        ),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        child: Text(
          block.content!,
          style: TextStyle(
            fontSize: getResponsiveFontSize(context, 14.0),
            color: context.textColor.withValues(alpha: 0.8),
            fontStyle: FontStyle.italic,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  @override
  String get name => 'QuoteBubbleAdapter';

  @override
  int get priority => AdapterPriority.normal;
}
