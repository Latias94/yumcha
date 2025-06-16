import 'package:flutter/material.dart';

import '../../../../domain/entities/message_block.dart';
import '../../../../domain/entities/message_block_type.dart';
import '../bubble_context.dart';
import 'bubble_block_adapter.dart';

/// 图片块气泡适配器
/// 
/// 负责在气泡中渲染图片类型的消息块
class ImageBubbleAdapter extends BubbleBlockAdapter {
  @override
  Widget buildInBubble(
    MessageBlock block,
    BubbleContext context, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    if (!block.hasContent) {
      return buildEmptyWidget(context, message: '图片内容为空');
    }

    return _buildImageContent(block, context);
  }

  @override
  bool canHandleBlock(MessageBlockType type) {
    return type == MessageBlockType.image;
  }

  @override
  List<MessageBlockType> get supportedTypes => [MessageBlockType.image];

  @override
  double getPreferredHeight(MessageBlock block, BubbleContext context) {
    // 图片的默认高度，实际应该根据图片尺寸计算
    return 200.0;
  }

  /// 构建图片内容
  Widget _buildImageContent(MessageBlock block, BubbleContext context) {
    final imageUrl = block.content!;
    
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: getResponsiveSpacing(context, 4.0),
      ),
      decoration: buildContainerDecoration(
        context,
        borderRadius: 8.0,
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildImage(imageUrl, context),
    );
  }

  /// 构建图片组件
  Widget _buildImage(String imageUrl, BubbleContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return Container(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / 
                    loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 8),
                Text(
                  '图片加载失败',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  String get name => 'ImageBubbleAdapter';

  @override
  int get priority => AdapterPriority.normal;
}
