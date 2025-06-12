import 'package:flutter/material.dart';
import 'attachment_manager.dart';
import 'fullscreen_image_viewer.dart';
import '../../../../../shared/presentation/design_system/design_constants.dart';

/// 附件预览对话框
class AttachmentPreviewDialog extends StatefulWidget {
  const AttachmentPreviewDialog({
    super.key,
    required this.attachment,
    this.onRemove,
  });

  final AttachmentItem attachment;
  final VoidCallback? onRemove;

  @override
  State<AttachmentPreviewDialog> createState() =>
      _AttachmentPreviewDialogState();
}

class _AttachmentPreviewDialogState extends State<AttachmentPreviewDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = DesignConstants.isDesktop(context);

    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 600 : screenSize.width * 0.9,
          maxHeight: screenSize.height * 0.8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: DesignConstants.shadowL(theme),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            _buildHeader(theme, isDesktop),

            // 内容区域
            Flexible(
              child: SingleChildScrollView(
                padding: DesignConstants.paddingM,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 文件预览
                    _buildPreview(theme, isDesktop),

                    SizedBox(height: DesignConstants.spaceM),

                    // 文件信息
                    _buildFileInfo(theme, isDesktop),
                  ],
                ),
              ),
            ),

            // 操作按钮
            _buildActions(theme, isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDesktop) {
    final color = Color(widget.attachment.type.colorValue);

    return Container(
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          // 文件类型图标
          Container(
            width: isDesktop ? 32 : 28,
            height: isDesktop ? 32 : 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: DesignConstants.radiusS,
            ),
            child: Center(
              child: Text(
                widget.attachment.type.icon,
                style: TextStyle(fontSize: isDesktop ? 16 : 14),
              ),
            ),
          ),

          SizedBox(width: DesignConstants.spaceS),

          // 标题
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '附件预览',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.attachment.type.displayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          // 关闭按钮
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(ThemeData theme, bool isDesktop) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: isDesktop ? 300 : 200,
      ),
      decoration: BoxDecoration(
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: DesignConstants.radiusM,
        child: _buildPreviewContent(theme, isDesktop),
      ),
    );
  }

  Widget _buildPreviewContent(ThemeData theme, bool isDesktop) {
    switch (widget.attachment.type) {
      case AttachmentType.image:
        return Stack(
          children: [
            // 图片主体 - 可点击全屏，居中显示
            Center(
              child: GestureDetector(
                onTap: _openFullscreenViewer,
                child: Hero(
                  tag: 'attachment_${widget.attachment.id}',
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                    child: Image.memory(
                      widget.attachment.data,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildErrorPreview(theme),
                    ),
                  ),
                ),
              ),
            ),

            // 全屏按钮 - 右上角，避免与图片内容重叠
            Positioned(
              top: DesignConstants.spaceM,
              right: DesignConstants.spaceM,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _openFullscreenViewer,
                  borderRadius: BorderRadius.circular(
                    isDesktop
                        ? DesignConstants.radiusLValue
                        : DesignConstants.radiusMValue,
                  ),
                  child: AnimatedContainer(
                    duration: DesignConstants.animationFast,
                    width: isDesktop ? 40 : 36,
                    height: isDesktop ? 40 : 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(
                        alpha: DesignConstants.opacityHigh,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: DesignConstants.shadowM(theme),
                    ),
                    child: Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: isDesktop ? 20 : 18,
                    ),
                  ),
                ),
              ),
            ),

            // 悬浮提示 - 左上角显示图片可点击提示
            Positioned(
              top: DesignConstants.spaceM,
              left: DesignConstants.spaceM,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignConstants.spaceS,
                  vertical: DesignConstants.spaceXS,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(
                    alpha: DesignConstants.opacityMedium,
                  ),
                  borderRadius: DesignConstants.radiusS,
                  boxShadow: DesignConstants.shadowS(theme),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: Colors.white,
                      size: isDesktop ? 14 : 12,
                    ),
                    SizedBox(width: DesignConstants.spaceXS),
                    Text(
                      '点击查看',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isDesktop ? 12 : 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      case AttachmentType.document:
      case AttachmentType.audio:
      case AttachmentType.video:
      case AttachmentType.other:
        return _buildFilePreview(theme, isDesktop);
    }
  }

  Widget _buildFilePreview(ThemeData theme, bool isDesktop) {
    final color = Color(widget.attachment.type.colorValue);

    return Container(
      padding: DesignConstants.paddingL,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isDesktop ? 80 : 60,
            height: isDesktop ? 80 : 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: DesignConstants.radiusM,
            ),
            child: Center(
              child: Text(
                widget.attachment.type.icon,
                style: TextStyle(fontSize: isDesktop ? 32 : 24),
              ),
            ),
          ),
          SizedBox(height: DesignConstants.spaceM),
          Text(
            widget.attachment.fileName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DesignConstants.spaceS),
          Text(
            '${widget.attachment.type.displayName} • ${widget.attachment.formattedSize}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPreview(ThemeData theme) {
    return Container(
      padding: DesignConstants.paddingL,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: theme.colorScheme.error,
          ),
          SizedBox(height: DesignConstants.spaceM),
          Text(
            '预览失败',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileInfo(ThemeData theme, bool isDesktop) {
    return Container(
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: DesignConstants.opacityMedium * 0.5),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.outline
              .withValues(alpha: DesignConstants.opacityMedium * 0.2),
          width: 1,
        ),
        boxShadow: DesignConstants.shadowXS(theme),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: isDesktop ? 18 : 16,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: DesignConstants.spaceXS),
              Text(
                '文件信息',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignConstants.spaceM),
          _buildInfoRow('文件名', widget.attachment.fileName, theme, isDesktop),
          _buildInfoRow(
              '大小', widget.attachment.formattedSize, theme, isDesktop),
          if (widget.attachment.mimeType != null)
            _buildInfoRow('类型', widget.attachment.mimeType!, theme, isDesktop),
          _buildInfoRow('添加时间', _formatDateTime(widget.attachment.createdAt),
              theme, isDesktop),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, ThemeData theme, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignConstants.spaceS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isDesktop ? 90 : 80,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(
          isDesktop ? DesignConstants.spaceL : DesignConstants.spaceM),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: DesignConstants.opacityMedium * 0.3),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(12),
        ),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline
                .withValues(alpha: DesignConstants.opacityMedium * 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 移除按钮
          if (widget.onRemove != null)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onRemove!();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignConstants.spaceM,
                  vertical: DesignConstants.spaceS,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: DesignConstants.radiusS,
                ),
              ),
              icon: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
                size: isDesktop ? 18 : 16,
              ),
              label: Text(
                '移除',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          const Spacer(),

          // 关闭按钮
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop
                    ? DesignConstants.spaceXL
                    : DesignConstants.spaceL,
                vertical: DesignConstants.spaceM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: DesignConstants.radiusS,
              ),
              elevation: 2,
            ),
            child: Text(
              '关闭',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: isDesktop ? 14 : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 打开全屏图片查看器
  void _openFullscreenViewer() {
    if (widget.attachment.type == AttachmentType.image) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              FullscreenImageViewer(
            imageData: widget.attachment.data,
            fileName: widget.attachment.fileName,
            heroTag: 'attachment_${widget.attachment.id}',
            enableRotation: true,
          ),
          transitionDuration: DesignConstants.animationNormal,
          reverseTransitionDuration: DesignConstants.animationNormal,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} 分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} 小时前';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
