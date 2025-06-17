import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:typed_data';
import '../../../../../../shared/infrastructure/services/media/media_storage_service.dart';
import '../../../../../../shared/presentation/design_system/design_constants.dart';

/// 图片显示组件
///
/// 支持多种图片来源：
/// - 网络图片（URL）
/// - 本地文件
/// - Base64数据
/// - 缓存图片
class ImageDisplayWidget extends StatefulWidget {
  const ImageDisplayWidget({
    super.key,
    required this.mediaMetadata,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.onTap,
    this.showLoadingIndicator = true,
    this.showErrorWidget = true,
    this.placeholder,
    this.errorWidget,
  });

  /// 媒体元数据
  final MediaMetadata mediaMetadata;

  /// 图片宽度
  final double? width;

  /// 图片高度
  final double? height;

  /// 图片适应方式
  final BoxFit fit;

  /// 圆角半径
  final BorderRadius? borderRadius;

  /// 点击回调
  final VoidCallback? onTap;

  /// 是否显示加载指示器
  final bool showLoadingIndicator;

  /// 是否显示错误组件
  final bool showErrorWidget;

  /// 自定义占位符
  final Widget? placeholder;

  /// 自定义错误组件
  final Widget? errorWidget;

  @override
  State<ImageDisplayWidget> createState() => _ImageDisplayWidgetState();
}

class _ImageDisplayWidgetState extends State<ImageDisplayWidget> {
  Uint8List? _imageData;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(ImageDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaMetadata.id != widget.mediaMetadata.id) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _imageData = null;
    });

    try {
      final mediaService = MediaStorageService();
      await mediaService.initialize();

      final data = await mediaService.retrieveMedia(widget.mediaMetadata);

      if (mounted) {
        setState(() {
          _imageData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget imageWidget;

    if (_isLoading && widget.showLoadingIndicator) {
      imageWidget = _buildLoadingWidget(theme);
    } else if (_errorMessage != null && widget.showErrorWidget) {
      imageWidget = _buildErrorWidget(theme);
    } else {
      imageWidget = _buildImageWidget();
    }

    // 应用圆角和点击事件
    Widget finalWidget = ClipRRect(
      borderRadius: widget.borderRadius ?? DesignConstants.radiusM,
      child: imageWidget,
    );

    if (widget.onTap != null) {
      finalWidget = GestureDetector(
        onTap: widget.onTap,
        child: finalWidget,
      );
    }

    return finalWidget;
  }

  Widget _buildImageWidget() {
    final metadata = widget.mediaMetadata;

    // 根据存储策略选择显示方式
    switch (metadata.strategy) {
      case MediaStorageStrategy.networkUrl:
        if (metadata.networkUrl != null) {
          return _buildNetworkImage(metadata.networkUrl!);
        }
        break;

      case MediaStorageStrategy.database:
        if (_imageData != null) {
          return _buildMemoryImage(_imageData!);
        }
        break;

      case MediaStorageStrategy.localFile:
      case MediaStorageStrategy.cache:
        if (_imageData != null) {
          return _buildMemoryImage(_imageData!);
        }
        break;
    }

    // 降级显示
    return _buildErrorWidget(Theme.of(context));
  }

  Widget _buildNetworkImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: widget.placeholder != null
          ? (context, url) => widget.placeholder!
          : (context, url) => _buildLoadingWidget(Theme.of(context)),
      errorWidget: widget.errorWidget != null
          ? (context, url, error) => widget.errorWidget!
          : (context, url, error) => _buildErrorWidget(Theme.of(context)),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }

  Widget _buildMemoryImage(Uint8List data) {
    return Image.memory(
      data,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget(Theme.of(context));
      },
    );
  }

  Widget _buildLoadingWidget(ThemeData theme) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: widget.borderRadius ?? DesignConstants.radiusM,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
            SizedBox(height: DesignConstants.spaceXS),
            Text(
              '加载中...',
              style: TextStyle(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: widget.borderRadius ?? DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.broken_image_rounded,
              color: theme.colorScheme.error.withValues(alpha: 0.7),
              size: 32,
            ),
            SizedBox(height: DesignConstants.spaceXS),
            Text(
              '图片加载失败',
              style: TextStyle(
                color: theme.colorScheme.error.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: DesignConstants.spaceXS / 2),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color:
                      theme.colorScheme.onErrorContainer.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 图片网格显示组件
///
/// 用于显示多张图片的网格布局
class ImageGridWidget extends StatelessWidget {
  const ImageGridWidget({
    super.key,
    required this.imageMetadataList,
    this.crossAxisCount = 2,
    this.aspectRatio = 1.0,
    this.spacing = 8.0,
    this.onImageTap,
  });

  /// 图片元数据列表
  final List<MediaMetadata> imageMetadataList;

  /// 每行图片数量
  final int crossAxisCount;

  /// 图片宽高比
  final double aspectRatio;

  /// 图片间距
  final double spacing;

  /// 图片点击回调
  final void Function(MediaMetadata metadata, int index)? onImageTap;

  @override
  Widget build(BuildContext context) {
    if (imageMetadataList.isEmpty) {
      return const SizedBox.shrink();
    }

    // 单张图片特殊处理
    if (imageMetadataList.length == 1) {
      return _buildSingleImage(context);
    }

    // 多张图片网格布局
    return _buildImageGrid(context);
  }

  Widget _buildSingleImage(BuildContext context) {
    final metadata = imageMetadataList.first;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * 0.7; // 最大宽度为屏幕的70%

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: maxWidth, // 保持正方形比例
      ),
      child: ImageDisplayWidget(
        mediaMetadata: metadata,
        fit: BoxFit.cover,
        onTap: onImageTap != null ? () => onImageTap!(metadata, 0) : null,
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: imageMetadataList.length,
      itemBuilder: (context, index) {
        final metadata = imageMetadataList[index];
        return ImageDisplayWidget(
          mediaMetadata: metadata,
          fit: BoxFit.cover,
          onTap: onImageTap != null ? () => onImageTap!(metadata, index) : null,
        );
      },
    );
  }
}
