import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_widget/markdown_widget.dart';
import '../../domain/entities/message_block.dart';
import '../../domain/entities/message_block_type.dart';
import '../../domain/entities/message_block_status.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';

/// 消息块组件
/// 
/// 渲染单个消息块，支持不同类型的内容和状态
class MessageBlockWidget extends ConsumerStatefulWidget {
  const MessageBlockWidget({
    super.key,
    required this.block,
    this.onEdit,
    this.onDelete,
    this.onRegenerate,
    this.isEditable = false,
  });

  /// 消息块数据
  final MessageBlock block;

  /// 编辑回调
  final VoidCallback? onEdit;

  /// 删除回调
  final VoidCallback? onDelete;

  /// 重新生成回调
  final VoidCallback? onRegenerate;

  /// 是否可编辑
  final bool isEditable;

  @override
  ConsumerState<MessageBlockWidget> createState() => _MessageBlockWidgetState();
}

class _MessageBlockWidgetState extends ConsumerState<MessageBlockWidget>
    with TickerProviderStateMixin {
  bool _isCopied = false;
  late AnimationController _streamingController;
  late Animation<double> _streamingAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化流式动画控制器
    _streamingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _streamingAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _streamingController,
      curve: Curves.easeInOut,
    ));

    // 如果是流式状态，启动动画
    if (widget.block.status == MessageBlockStatus.streaming) {
      _streamingController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MessageBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 监听状态变化
    if (widget.block.status == MessageBlockStatus.streaming &&
        oldWidget.block.status != MessageBlockStatus.streaming) {
      _streamingController.repeat(reverse: true);
    } else if (widget.block.status != MessageBlockStatus.streaming &&
        oldWidget.block.status == MessageBlockStatus.streaming) {
      _streamingController.stop();
    }
  }

  @override
  void dispose() {
    _streamingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: DesignConstants.spaceS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 块类型标识（仅在调试模式或特定类型时显示）
          if (_shouldShowBlockHeader()) _buildBlockHeader(theme),
          
          // 块内容
          _buildBlockContent(theme),
          
          // 块状态指示器
          if (widget.block.status != MessageBlockStatus.success)
            _buildStatusIndicator(theme),
        ],
      ),
    );
  }

  /// 是否显示块头部
  bool _shouldShowBlockHeader() {
    // 对于特殊类型的块，显示头部标识
    return widget.block.type == MessageBlockType.thinking ||
           widget.block.type == MessageBlockType.code ||
           widget.block.type == MessageBlockType.tool ||
           widget.block.type == MessageBlockType.error ||
           widget.block.type == MessageBlockType.citation;
  }

  /// 构建块头部
  Widget _buildBlockHeader(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignConstants.spaceXS),
      child: Row(
        children: [
          Icon(
            _getBlockIcon(),
            size: DesignConstants.iconSizeS,
            color: _getBlockColor(theme),
          ),
          SizedBox(width: DesignConstants.spaceXS),
          Text(
            widget.block.type.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getBlockColor(theme),
            ),
          ),
          if (widget.isEditable) ...[
            const Spacer(),
            _buildBlockActions(theme),
          ],
        ],
      ),
    );
  }

  /// 构建块内容
  Widget _buildBlockContent(ThemeData theme) {
    switch (widget.block.type) {
      case MessageBlockType.mainText:
        return _buildTextContent(theme);
      case MessageBlockType.thinking:
        return _buildThinkingContent(theme);
      case MessageBlockType.translation:
        return _buildTranslationContent(theme);
      case MessageBlockType.image:
        return _buildImageContent(theme);
      case MessageBlockType.code:
        return _buildCodeContent(theme);
      case MessageBlockType.tool:
        return _buildToolContent(theme);
      case MessageBlockType.file:
        return _buildFileContent(theme);
      case MessageBlockType.error:
        return _buildErrorContent(theme);
      case MessageBlockType.citation:
        return _buildCitationContent(theme);
      case MessageBlockType.unknown:
        return _buildUnknownContent(theme);
    }
  }

  /// 构建文本内容
  Widget _buildTextContent(ThemeData theme) {
    if (!widget.block.hasContent) {
      return _buildEmptyContent(theme);
    }

    return _buildMarkdownContent(
      widget.block.content!,
      theme.colorScheme.onSurface,
      theme,
    );
  }

  /// 构建思考过程内容
  Widget _buildThinkingContent(ThemeData theme) {
    return Container(
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_rounded,
                size: DesignConstants.iconSizeS,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: DesignConstants.spaceXS),
              Text(
                '思考过程',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignConstants.spaceS),
          _buildMarkdownContent(
            widget.block.content ?? '',
            theme.colorScheme.onSurface.withValues(alpha: 0.8),
            theme,
          ),
        ],
      ),
    );
  }

  /// 构建图片内容
  Widget _buildImageContent(ThemeData theme) {
    if (!widget.block.hasContent) {
      return _buildEmptyContent(theme);
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: 300,
        maxWidth: double.infinity,
      ),
      child: ClipRRect(
        borderRadius: DesignConstants.radiusM,
        child: Image.network(
          widget.block.content!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: DesignConstants.radiusM,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_rounded,
                      color: theme.colorScheme.onErrorContainer,
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
          },
        ),
      ),
    );
  }

  /// 构建代码内容
  Widget _buildCodeContent(ThemeData theme) {
    final language = widget.block.language ?? 'text';
    
    return Container(
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code_rounded,
                size: DesignConstants.iconSizeS,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: DesignConstants.spaceXS),
              Text(
                language.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              _buildCopyButton(theme),
            ],
          ),
          SizedBox(height: DesignConstants.spaceS),
          SelectableText(
            widget.block.content ?? '',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建工具调用内容
  Widget _buildToolContent(ThemeData theme) {
    final toolName = widget.block.toolName ?? '未知工具';
    final arguments = widget.block.toolArguments;
    final result = widget.block.content;

    return Container(
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.build_rounded,
                size: DesignConstants.iconSizeS,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: DesignConstants.spaceXS),
              Text(
                '工具调用: $toolName',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          if (arguments != null) ...[
            SizedBox(height: DesignConstants.spaceS),
            Text(
              '参数:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: DesignConstants.spaceXS),
            Container(
              padding: DesignConstants.paddingS,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: DesignConstants.radiusS,
              ),
              child: SelectableText(
                arguments.toString(),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
          if (result != null && result.isNotEmpty) ...[
            SizedBox(height: DesignConstants.spaceS),
            Text(
              '结果:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: DesignConstants.spaceXS),
            _buildMarkdownContent(
              result,
              theme.colorScheme.onSurface,
              theme,
            ),
          ],
        ],
      ),
    );
  }

  /// 构建文件内容
  Widget _buildFileContent(ThemeData theme) {
    return Container(
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.3),
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.attach_file_rounded,
            color: theme.colorScheme.secondary,
          ),
          SizedBox(width: DesignConstants.spaceM),
          Expanded(
            child: Text(
              widget.block.content ?? '文件',
              style: TextStyle(
                color: theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: 实现文件下载
            },
            icon: Icon(
              Icons.download_rounded,
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建错误内容
  Widget _buildErrorContent(ThemeData theme) {
    return Container(
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.5),
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_rounded,
                size: DesignConstants.iconSizeS,
                color: theme.colorScheme.error,
              ),
              SizedBox(width: DesignConstants.spaceXS),
              Text(
                '错误信息',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignConstants.spaceS),
          Text(
            widget.block.content ?? '未知错误',
            style: TextStyle(
              color: theme.colorScheme.onErrorContainer,
              fontSize: 13,
            ),
          ),
          if (widget.block.error != null && widget.block.error!['code'] != null) ...[
            SizedBox(height: DesignConstants.spaceS),
            Text(
              '错误代码: ${widget.block.error!['code']}',
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer.withValues(alpha: 0.7),
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建引用内容
  Widget _buildCitationContent(ThemeData theme) {
    return Container(
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                size: DesignConstants.iconSizeS,
                color: theme.colorScheme.tertiary,
              ),
              SizedBox(width: DesignConstants.spaceXS),
              Text(
                '引用',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignConstants.spaceS),
          _buildMarkdownContent(
            widget.block.content ?? '',
            theme.colorScheme.onTertiaryContainer,
            theme,
          ),
        ],
      ),
    );
  }

  /// 构建翻译内容
  Widget _buildTranslationContent(ThemeData theme) {
    return Container(
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.3),
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.translate_rounded,
                size: DesignConstants.iconSizeS,
                color: theme.colorScheme.secondary,
              ),
              SizedBox(width: DesignConstants.spaceXS),
              Text(
                '翻译',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignConstants.spaceS),
          _buildMarkdownContent(
            widget.block.content ?? '',
            theme.colorScheme.onSecondaryContainer,
            theme,
          ),
        ],
      ),
    );
  }

  /// 构建未知类型内容
  Widget _buildUnknownContent(ThemeData theme) {
    return Container(
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline_rounded,
                size: DesignConstants.iconSizeS,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              SizedBox(width: DesignConstants.spaceXS),
              Text(
                '未知类型',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          SizedBox(height: DesignConstants.spaceS),
          Text(
            widget.block.content ?? '无内容',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建空内容占位符
  Widget _buildEmptyContent(ThemeData theme) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Center(
        child: Text(
          '内容为空',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  /// 构建Markdown内容
  Widget _buildMarkdownContent(String content, Color textColor, ThemeData theme) {
    return MarkdownWidget(
      data: content,
      shrinkWrap: true,
      selectable: true,
      config: MarkdownConfig(
        configs: [
          PreConfig(
            theme: PreConfig.darkConfig.theme,
          ),
          CodeConfig(
            style: TextStyle(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: textColor,
              fontFamily: 'monospace',
            ),
          ),
          PConfig(
            textStyle: TextStyle(
              color: textColor,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建状态指示器
  Widget _buildStatusIndicator(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(top: DesignConstants.spaceXS),
      child: Row(
        children: [
          if (widget.block.status == MessageBlockStatus.streaming)
            AnimatedBuilder(
              animation: _streamingAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _streamingAnimation.value,
                  child: Icon(
                    Icons.more_horiz_rounded,
                    size: DesignConstants.iconSizeS,
                    color: theme.colorScheme.primary,
                  ),
                );
              },
            )
          else
            Icon(
              _getStatusIcon(),
              size: DesignConstants.iconSizeS,
              color: _getStatusColor(theme),
            ),
          SizedBox(width: DesignConstants.spaceXS),
          Text(
            widget.block.status.displayName,
            style: TextStyle(
              fontSize: 11,
              color: _getStatusColor(theme),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建块操作按钮
  Widget _buildBlockActions(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.block.type.isEditable && widget.onEdit != null)
          IconButton(
            onPressed: widget.onEdit,
            icon: Icon(
              Icons.edit_rounded,
              size: DesignConstants.iconSizeS,
            ),
            tooltip: '编辑',
          ),
        if (widget.block.type.isDeletable && widget.onDelete != null)
          IconButton(
            onPressed: widget.onDelete,
            icon: Icon(
              Icons.delete_rounded,
              size: DesignConstants.iconSizeS,
            ),
            tooltip: '删除',
          ),
        if (widget.onRegenerate != null)
          IconButton(
            onPressed: widget.onRegenerate,
            icon: Icon(
              Icons.refresh_rounded,
              size: DesignConstants.iconSizeS,
            ),
            tooltip: '重新生成',
          ),
      ],
    );
  }

  /// 构建复制按钮
  Widget _buildCopyButton(ThemeData theme) {
    return IconButton(
      onPressed: () => _copyToClipboard(widget.block.content ?? ''),
      icon: Icon(
        _isCopied ? Icons.check_rounded : Icons.copy_rounded,
        size: DesignConstants.iconSizeS,
        color: _isCopied ? theme.colorScheme.primary : theme.colorScheme.onSurface,
      ),
      tooltip: _isCopied ? '已复制' : '复制',
    );
  }

  /// 复制到剪贴板
  void _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    setState(() {
      _isCopied = true;
    });

    // 2秒后重置状态
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  /// 获取块图标
  IconData _getBlockIcon() {
    switch (widget.block.type) {
      case MessageBlockType.mainText:
        return Icons.text_fields_rounded;
      case MessageBlockType.thinking:
        return Icons.psychology_rounded;
      case MessageBlockType.translation:
        return Icons.translate_rounded;
      case MessageBlockType.image:
        return Icons.image_rounded;
      case MessageBlockType.code:
        return Icons.code_rounded;
      case MessageBlockType.tool:
        return Icons.build_rounded;
      case MessageBlockType.file:
        return Icons.attach_file_rounded;
      case MessageBlockType.error:
        return Icons.error_rounded;
      case MessageBlockType.citation:
        return Icons.format_quote_rounded;
      case MessageBlockType.unknown:
        return Icons.help_outline_rounded;
    }
  }

  /// 获取块颜色
  Color _getBlockColor(ThemeData theme) {
    switch (widget.block.type) {
      case MessageBlockType.mainText:
        return theme.colorScheme.onSurface;
      case MessageBlockType.thinking:
        return theme.colorScheme.primary;
      case MessageBlockType.translation:
        return theme.colorScheme.secondary;
      case MessageBlockType.image:
        return theme.colorScheme.secondary;
      case MessageBlockType.code:
        return theme.colorScheme.primary;
      case MessageBlockType.tool:
        return theme.colorScheme.primary;
      case MessageBlockType.file:
        return theme.colorScheme.secondary;
      case MessageBlockType.error:
        return theme.colorScheme.error;
      case MessageBlockType.citation:
        return theme.colorScheme.tertiary;
      case MessageBlockType.unknown:
        return theme.colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  /// 获取状态图标
  IconData _getStatusIcon() {
    switch (widget.block.status) {
      case MessageBlockStatus.pending:
        return Icons.schedule_rounded;
      case MessageBlockStatus.processing:
        return Icons.hourglass_empty_rounded;
      case MessageBlockStatus.streaming:
        return Icons.more_horiz_rounded;
      case MessageBlockStatus.success:
        return Icons.check_rounded;
      case MessageBlockStatus.error:
        return Icons.error_rounded;
      case MessageBlockStatus.paused:
        return Icons.pause_rounded;
    }
  }

  /// 获取状态颜色
  Color _getStatusColor(ThemeData theme) {
    switch (widget.block.status) {
      case MessageBlockStatus.pending:
        return theme.colorScheme.onSurface.withValues(alpha: 0.6);
      case MessageBlockStatus.processing:
        return theme.colorScheme.primary;
      case MessageBlockStatus.streaming:
        return theme.colorScheme.primary;
      case MessageBlockStatus.success:
        return theme.colorScheme.primary;
      case MessageBlockStatus.error:
        return theme.colorScheme.error;
      case MessageBlockStatus.paused:
        return theme.colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }
}
