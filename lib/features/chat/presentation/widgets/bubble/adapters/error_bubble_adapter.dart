import 'package:flutter/material.dart';

import '../../../../domain/entities/message_block.dart';
import '../../../../domain/entities/message_block_type.dart';
import '../bubble_context.dart';
import 'bubble_block_adapter.dart';

/// 错误块气泡适配器
/// 
/// 负责在气泡中渲染错误类型的消息块
class ErrorBubbleAdapter extends BubbleBlockAdapter {
  @override
  Widget buildInBubble(
    MessageBlock block,
    BubbleContext context, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: getResponsiveSpacing(context, 4.0),
      ),
      decoration: buildContainerDecoration(
        context,
        backgroundColor: context.theme.colorScheme.errorContainer.withValues(alpha: 0.1),
        borderColor: context.theme.colorScheme.error.withValues(alpha: 0.3),
        borderRadius: 8.0,
      ),
      child: _buildErrorContent(block, context),
    );
  }

  @override
  bool canHandleBlock(MessageBlockType type) {
    return type == MessageBlockType.error;
  }

  @override
  List<MessageBlockType> get supportedTypes => [MessageBlockType.error];

  /// 构建错误内容
  Widget _buildErrorContent(MessageBlock block, BubbleContext context) {
    return Container(
      padding: EdgeInsets.all(getResponsiveSpacing(context, 12.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: getResponsiveSpacing(context, 16.0),
                color: context.theme.colorScheme.error,
              ),
              SizedBox(width: getResponsiveSpacing(context, 8.0)),
              Text(
                '错误',
                style: TextStyle(
                  fontSize: getResponsiveFontSize(context, 12.0),
                  fontWeight: FontWeight.w600,
                  color: context.theme.colorScheme.error,
                ),
              ),
            ],
          ),
          if (block.hasContent) ...[
            SizedBox(height: getResponsiveSpacing(context, 8.0)),
            Text(
              block.content!,
              style: TextStyle(
                fontSize: getResponsiveFontSize(context, 14.0),
                color: context.theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  String get name => 'ErrorBubbleAdapter';

  @override
  int get priority => AdapterPriority.high;
}
