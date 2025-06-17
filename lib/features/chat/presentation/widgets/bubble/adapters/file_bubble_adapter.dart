import 'package:flutter/material.dart';

import '../../../../domain/entities/message_block.dart';
import '../../../../domain/entities/message_block_type.dart';
import '../bubble_context.dart';
import 'bubble_block_adapter.dart';

/// 文件块气泡适配器
///
/// 负责在气泡中渲染文件类型的消息块
class FileBubbleAdapter extends BubbleBlockAdapter {
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
        backgroundColor: context.theme.colorScheme.surfaceContainerHigh,
        borderColor: context.theme.colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: 8.0,
      ),
      child: _buildFileContent(block, context),
    );
  }

  @override
  bool canHandleBlock(MessageBlockType type) {
    return type == MessageBlockType.file;
  }

  @override
  List<MessageBlockType> get supportedTypes => [MessageBlockType.file];

  /// 构建文件内容
  Widget _buildFileContent(MessageBlock block, BubbleContext context) {
    return Container(
      padding: EdgeInsets.all(getResponsiveSpacing(context, 12.0)),
      child: Row(
        children: [
          Icon(
            Icons.attach_file,
            size: getResponsiveSpacing(context, 20.0),
            color: context.theme.colorScheme.primary,
          ),
          SizedBox(width: getResponsiveSpacing(context, 12.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.content ?? '未知文件',
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(context, 14.0),
                    fontWeight: FontWeight.w500,
                    color: context.textColor,
                  ),
                ),
                if (block.metadata != null) ...[
                  SizedBox(height: getResponsiveSpacing(context, 4.0)),
                  Text(
                    '${block.metadata!['size'] ?? '未知大小'}',
                    style: TextStyle(
                      fontSize: getResponsiveFontSize(context, 12.0),
                      color: context.textColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.download,
              size: getResponsiveSpacing(context, 20.0),
            ),
            onPressed: () {
              // 处理文件下载
            },
          ),
        ],
      ),
    );
  }

  @override
  String get name => 'FileBubbleAdapter';

  @override
  int get priority => AdapterPriority.normal;
}
