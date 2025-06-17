import 'package:flutter/material.dart';
import '../../../../domain/entities/message.dart';
import '../../../../domain/entities/message_block.dart';
import '../../../../domain/entities/message_block_type.dart';

import '../../../../../../shared/presentation/design_system/design_constants.dart';

/// 多媒体内容显示组件
///
/// 专门用于显示新的块化消息系统中的多媒体内容
class MediaContentWidget extends StatelessWidget {
  const MediaContentWidget({
    super.key,
    required this.message,
    this.onImageTap,
    this.onFileTap,
    this.compact = false,
    this.maxImageHeight = 200.0,
    this.imageGridSpacing = 8.0,
  });

  /// 块化消息对象
  final Message message;

  /// 图片点击回调
  final void Function(MessageBlock block, int index)? onImageTap;

  /// 文件点击回调
  final void Function(MessageBlock block)? onFileTap;

  /// 是否使用紧凑布局
  final bool compact;

  /// 图片最大高度
  final double maxImageHeight;

  /// 图片网格间距
  final double imageGridSpacing;

  @override
  Widget build(BuildContext context) {
    final mediaBlocks = message.blocks
        .where((block) =>
            block.type == MessageBlockType.image ||
            block.type == MessageBlockType.file)
        .toList();

    if (mediaBlocks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 显示图片块
        if (message.hasImages) ...[
          _buildImageBlocks(context),
          if (_hasFileBlocks()) SizedBox(height: DesignConstants.spaceM),
        ],

        // 显示文件块
        if (_hasFileBlocks()) ...[
          _buildFileBlocks(context),
        ],
      ],
    );
  }

  bool _hasFileBlocks() {
    return message.blocks.any((block) => block.type == MessageBlockType.file);
  }

  Widget _buildImageBlocks(BuildContext context) {
    final imageBlocks = message.imageBlocks;

    if (imageBlocks.isEmpty) {
      return const SizedBox.shrink();
    }

    // 单张图片
    if (imageBlocks.length == 1) {
      return _buildSingleImage(context, imageBlocks.first, 0);
    }

    // 多张图片网格
    return _buildImageGrid(context, imageBlocks);
  }

  Widget _buildSingleImage(
      BuildContext context, MessageBlock imageBlock, int index) {
    if (imageBlock.url == null) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = compact ? screenWidth * 0.5 : screenWidth * 0.7;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: maxImageHeight,
      ),
      child: ClipRRect(
        borderRadius: DesignConstants.radiusM,
        child: Image.network(
          imageBlock.url!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageError(context);
          },
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context, List<MessageBlock> imageBlocks) {
    // 根据图片数量决定网格布局
    int crossAxisCount;
    double aspectRatio;

    if (imageBlocks.length == 2) {
      crossAxisCount = 2;
      aspectRatio = 1.0;
    } else if (imageBlocks.length == 3) {
      crossAxisCount = 2;
      aspectRatio = 1.0;
    } else if (imageBlocks.length == 4) {
      crossAxisCount = 2;
      aspectRatio = 1.0;
    } else {
      crossAxisCount = 3;
      aspectRatio = 1.0;
    }

    // 限制显示的图片数量
    final displayBlocks = imageBlocks.take(9).toList();
    final hasMore = imageBlocks.length > 9;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: imageGridSpacing,
        mainAxisSpacing: imageGridSpacing,
      ),
      itemCount: displayBlocks.length,
      itemBuilder: (context, index) {
        final block = displayBlocks[index];

        // 如果是最后一张图片且还有更多图片，显示"+N"覆盖层
        final isLastItem = index == displayBlocks.length - 1;
        final showMoreOverlay = hasMore && isLastItem;

        return Stack(
          children: [
            ClipRRect(
              borderRadius: DesignConstants.radiusM,
              child: block.url != null
                  ? Image.network(
                      block.url!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImageError(context);
                      },
                    )
                  : _buildImageError(context),
            ),
            if (showMoreOverlay)
              _buildMoreImagesOverlay(
                  context, imageBlocks.length - displayBlocks.length),
          ],
        );
      },
    );
  }

  Widget _buildImageError(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: DesignConstants.radiusM,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.broken_image_outlined,
              color: theme.colorScheme.onErrorContainer,
              size: DesignConstants.iconSizeM,
            ),
            SizedBox(height: DesignConstants.spaceXS),
            Text(
              '图片加载失败',
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreImagesOverlay(BuildContext context, int moreCount) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: DesignConstants.radiusM,
        ),
        child: Center(
          child: Text(
            '+$moreCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileBlocks(BuildContext context) {
    final fileBlocks = message.blocks
        .where((block) => block.type == MessageBlockType.file)
        .toList();

    if (fileBlocks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fileBlocks.map((block) {
        return Container(
          margin: EdgeInsets.only(bottom: DesignConstants.spaceS),
          child: _buildFileBlock(context, block),
        );
      }).toList(),
    );
  }

  Widget _buildFileBlock(BuildContext context, MessageBlock block) {
    final theme = Theme.of(context);
    final fileName = block.metadata?['fileName'] as String? ?? '未知文件';
    final fileSize = block.metadata?['sizeBytes'] as int?;
    final mimeType = block.metadata?['mimeType'] as String?;

    return Container(
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getFileIcon(mimeType),
            color: theme.colorScheme.primary,
            size: DesignConstants.iconSizeM,
          ),
          SizedBox(width: DesignConstants.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: DesignConstants.getResponsiveFontSize(
                      context,
                      mobile: 13,
                      tablet: 14,
                      desktop: 14,
                    ),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (fileSize != null) ...[
                  SizedBox(height: DesignConstants.spaceXS),
                  Text(
                    _formatFileSize(fileSize),
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: DesignConstants.getResponsiveFontSize(
                        context,
                        mobile: 11,
                        tablet: 12,
                        desktop: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (block.url != null)
            IconButton(
              onPressed: () => onFileTap?.call(block),
              icon: Icon(
                Icons.download_rounded,
                color: theme.colorScheme.primary,
                size: DesignConstants.iconSizeS,
              ),
              tooltip: '下载文件',
            ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file_outlined;

    if (mimeType.startsWith('image/')) return Icons.image_outlined;
    if (mimeType.startsWith('audio/')) return Icons.audio_file_outlined;
    if (mimeType.startsWith('video/')) return Icons.video_file_outlined;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (mimeType.contains('text/')) return Icons.text_snippet_outlined;

    return Icons.insert_drive_file_outlined;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
