import 'package:flutter/material.dart';
import '../../../../domain/entities/enhanced_message.dart';
import '../../../../domain/entities/message.dart';
import '../../../../domain/entities/message_block.dart';
import '../../../../domain/entities/message_block_type.dart';
import '../../../../../../shared/infrastructure/services/media/media_storage_service.dart';
import '../../../../../../shared/presentation/design_system/design_constants.dart';
import 'image_display_widget.dart';
import 'audio_player_widget.dart';

/// 多媒体内容显示组件
/// 
/// 根据消息中的多媒体文件类型，自动选择合适的显示组件
class MediaContentWidget extends StatelessWidget {
  const MediaContentWidget({
    super.key,
    required this.message,
    this.onImageTap,
    this.onAudioTap,
    this.compact = false,
    this.maxImageHeight = 200.0,
    this.imageGridSpacing = 8.0,
  });

  /// 增强消息对象
  final EnhancedMessage message;

  /// 图片点击回调
  final void Function(MediaMetadata metadata, int index)? onImageTap;

  /// 音频点击回调
  final void Function(MediaMetadata metadata)? onAudioTap;

  /// 是否使用紧凑布局
  final bool compact;

  /// 图片最大高度
  final double maxImageHeight;

  /// 图片网格间距
  final double imageGridSpacing;

  @override
  Widget build(BuildContext context) {
    if (!message.hasMediaFiles) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 显示图片
        if (message.hasImages) ...[
          _buildImageSection(context),
          if (message.hasAudio || message.hasVideo)
            SizedBox(height: DesignConstants.spaceM),
        ],

        // 显示音频
        if (message.hasAudio) ...[
          _buildAudioSection(context),
          if (message.hasVideo)
            SizedBox(height: DesignConstants.spaceM),
        ],

        // 显示视频（暂时作为占位符）
        if (message.hasVideo) ...[
          _buildVideoSection(context),
        ],
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final images = message.imageFiles;
    
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    // 单张图片
    if (images.length == 1) {
      return _buildSingleImage(context, images.first);
    }

    // 多张图片网格
    return _buildImageGrid(context, images);
  }

  Widget _buildSingleImage(BuildContext context, MediaMetadata imageMetadata) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = compact ? screenWidth * 0.5 : screenWidth * 0.7;
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: maxImageHeight,
      ),
      child: ImageDisplayWidget(
        mediaMetadata: imageMetadata,
        fit: BoxFit.cover,
        onTap: onImageTap != null 
            ? () => onImageTap!(imageMetadata, 0)
            : null,
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context, List<MediaMetadata> images) {
    // 根据图片数量决定网格布局
    int crossAxisCount;
    double aspectRatio;

    if (images.length == 2) {
      crossAxisCount = 2;
      aspectRatio = 1.0;
    } else if (images.length == 3) {
      crossAxisCount = 2;
      aspectRatio = 1.0;
    } else if (images.length == 4) {
      crossAxisCount = 2;
      aspectRatio = 1.0;
    } else {
      crossAxisCount = 3;
      aspectRatio = 1.0;
    }

    // 限制显示的图片数量
    final displayImages = images.take(9).toList();
    final hasMore = images.length > 9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: imageGridSpacing,
            mainAxisSpacing: imageGridSpacing,
          ),
          itemCount: displayImages.length,
          itemBuilder: (context, index) {
            final metadata = displayImages[index];
            
            // 如果是最后一张图片且还有更多图片，显示"+N"覆盖层
            final isLastItem = index == displayImages.length - 1;
            final showMoreOverlay = hasMore && isLastItem;
            
            return Stack(
              children: [
                ImageDisplayWidget(
                  mediaMetadata: metadata,
                  fit: BoxFit.cover,
                  onTap: onImageTap != null 
                      ? () => onImageTap!(metadata, index)
                      : null,
                ),
                if (showMoreOverlay)
                  _buildMoreImagesOverlay(context, images.length - displayImages.length),
              ],
            );
          },
        ),
      ],
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
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioSection(BuildContext context) {
    final audioFiles = message.audioFiles;
    
    if (audioFiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: audioFiles.map((audioMetadata) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: audioFiles.last == audioMetadata 
                ? 0 
                : DesignConstants.spaceS,
          ),
          child: AudioPlayerWidget(
            mediaMetadata: audioMetadata,
            compact: compact,
            showDuration: true,
            showSpeed: !compact,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVideoSection(BuildContext context) {
    final videoFiles = message.videoFiles;
    
    if (videoFiles.isEmpty) {
      return const SizedBox.shrink();
    }

    // 暂时显示占位符，未来可以集成视频播放器
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: videoFiles.map((videoMetadata) {
        return _buildVideoPlaceholder(context, videoMetadata);
      }).toList(),
    );
  }

  Widget _buildVideoPlaceholder(BuildContext context, MediaMetadata videoMetadata) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      height: compact ? 80 : 120,
      margin: EdgeInsets.only(bottom: DesignConstants.spaceS),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 80 : 120,
            height: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.only(
                topLeft: DesignConstants.radiusM.topLeft,
                bottomLeft: DesignConstants.radiusM.bottomLeft,
              ),
            ),
            child: Icon(
              Icons.play_circle_outline_rounded,
              color: theme.colorScheme.primary,
              size: compact ? 32 : 48,
            ),
          ),
          Expanded(
            child: Padding(
              padding: DesignConstants.paddingM,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    videoMetadata.fileName,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: compact ? 13 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: DesignConstants.spaceXS),
                  Row(
                    children: [
                      Icon(
                        Icons.videocam_rounded,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        size: 16,
                      ),
                      SizedBox(width: DesignConstants.spaceXS),
                      Text(
                        videoMetadata.formattedSize,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: DesignConstants.spaceS),
                      Text(
                        '视频播放暂未支持',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 多媒体文件信息显示组件
/// 
/// 显示文件的基本信息，如文件名、大小、类型等
class MediaInfoWidget extends StatelessWidget {
  const MediaInfoWidget({
    super.key,
    required this.mediaMetadata,
    this.showSize = true,
    this.showType = true,
    this.compact = false,
  });

  /// 媒体元数据
  final MediaMetadata mediaMetadata;

  /// 是否显示文件大小
  final bool showSize;

  /// 是否显示文件类型
  final bool showType;

  /// 是否使用紧凑布局
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: compact 
          ? DesignConstants.paddingS 
          : DesignConstants.paddingM,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: DesignConstants.radiusS,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getFileIcon(),
            color: theme.colorScheme.primary,
            size: compact ? 16 : 20,
          ),
          SizedBox(width: DesignConstants.spaceS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mediaMetadata.fileName,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: compact ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showSize || showType) ...[
                  SizedBox(height: DesignConstants.spaceXS / 2),
                  Row(
                    children: [
                      if (showSize) ...[
                        Text(
                          mediaMetadata.formattedSize,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            fontSize: compact ? 10 : 12,
                          ),
                        ),
                        if (showType) ...[
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              fontSize: compact ? 10 : 12,
                            ),
                          ),
                        ],
                      ],
                      if (showType)
                        Text(
                          _getFileTypeDescription(),
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            fontSize: compact ? 10 : 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon() {
    if (mediaMetadata.isImage) {
      return Icons.image_rounded;
    } else if (mediaMetadata.isAudio) {
      return Icons.audiotrack_rounded;
    } else if (mediaMetadata.isVideo) {
      return Icons.videocam_rounded;
    } else {
      return Icons.insert_drive_file_rounded;
    }
  }

  String _getFileTypeDescription() {
    if (mediaMetadata.isImage) {
      return '图片';
    } else if (mediaMetadata.isAudio) {
      return '音频';
    } else if (mediaMetadata.isVideo) {
      return '视频';
    } else {
      return '文件';
    }
  }
}

/// 块化消息多媒体内容显示组件
///
/// 专门用于显示新的块化消息系统中的多媒体内容
class BlockMediaContentWidget extends StatelessWidget {
  const BlockMediaContentWidget({
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
    final mediaBlocks = message.blocks.where((block) =>
      block.type == MessageBlockType.image ||
      block.type == MessageBlockType.file
    ).toList();

    if (mediaBlocks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 显示图片块
        if (message.hasImages) ...[
          _buildImageBlocks(context),
          if (_hasFileBlocks())
            SizedBox(height: DesignConstants.spaceM),
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

  Widget _buildSingleImage(BuildContext context, MessageBlock imageBlock, int index) {
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
              _buildMoreImagesOverlay(context, imageBlocks.length - displayBlocks.length),
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
    final fileBlocks = message.blocks.where((block) => block.type == MessageBlockType.file).toList();

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
                    fontSize: 14,
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
                      fontSize: 12,
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
