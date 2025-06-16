import 'package:flutter/material.dart';

import '../../../../domain/entities/message_block.dart';
import '../../../../domain/entities/message_block_type.dart';
import '../bubble_context.dart';
import 'bubble_block_adapter.dart';

/// 工具调用块气泡适配器
/// 
/// 负责在气泡中渲染工具调用类型的消息块
class ToolCallBubbleAdapter extends BubbleBlockAdapter {
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
        backgroundColor: context.theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderColor: context.theme.colorScheme.secondary.withValues(alpha: 0.3),
        borderRadius: 8.0,
      ),
      child: _buildToolCallContent(block, context),
    );
  }

  @override
  bool canHandleBlock(MessageBlockType type) {
    return type == MessageBlockType.tool;
  }

  @override
  List<MessageBlockType> get supportedTypes => [MessageBlockType.tool];

  /// 构建工具调用内容
  Widget _buildToolCallContent(MessageBlock block, BubbleContext context) {
    return Container(
      padding: EdgeInsets.all(getResponsiveSpacing(context, 12.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.build_outlined,
                size: getResponsiveSpacing(context, 16.0),
                color: context.theme.colorScheme.secondary,
              ),
              SizedBox(width: getResponsiveSpacing(context, 8.0)),
              Text(
                '工具调用',
                style: TextStyle(
                  fontSize: getResponsiveFontSize(context, 12.0),
                  fontWeight: FontWeight.w600,
                  color: context.theme.colorScheme.secondary,
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
                color: context.textColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  String get name => 'ToolCallBubbleAdapter';

  @override
  int get priority => AdapterPriority.normal;
}
