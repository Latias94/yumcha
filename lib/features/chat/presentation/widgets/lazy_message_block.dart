import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message_block.dart';
import '../../domain/entities/message_block_type.dart';
import 'message_block_widget.dart';

/// 懒加载消息块组件
///
/// 实现消息块的懒加载机制，只在需要时才渲染复杂内容，
/// 提高大型消息的渲染性能。
///
/// 功能特性：
/// - 🔄 **懒加载**: 只在可见时才加载内容
/// - 📊 **占位符**: 提供加载状态的占位符
/// - 🎯 **智能触发**: 基于可见性和用户交互触发加载
/// - 💾 **内容缓存**: 已加载的内容会被缓存
/// - ⚡ **性能优化**: 减少初始渲染时间
class LazyMessageBlock extends ConsumerStatefulWidget {
  /// 消息块
  final MessageBlock block;

  /// 是否可编辑
  final bool isEditable;

  /// 是否显示类型标签
  final bool showTypeLabel;

  /// 编辑回调
  final void Function(String blockId)? onEdit;

  /// 删除回调
  final void Function(String blockId)? onDelete;

  /// 重新生成回调
  final void Function(String blockId)? onRegenerate;

  /// 是否强制立即加载
  final bool forceLoad;

  /// 懒加载阈值（像素）
  final double lazyLoadThreshold;

  const LazyMessageBlock({
    super.key,
    required this.block,
    this.isEditable = false,
    this.showTypeLabel = false,
    this.onEdit,
    this.onDelete,
    this.onRegenerate,
    this.forceLoad = false,
    this.lazyLoadThreshold = 200.0,
  });

  @override
  ConsumerState<LazyMessageBlock> createState() => _LazyMessageBlockState();
}

class _LazyMessageBlockState extends ConsumerState<LazyMessageBlock> {
  bool _isLoaded = false;
  bool _isVisible = false;
  Widget? _cachedWidget;

  /// 是否应该懒加载此类型的块
  bool get _shouldLazyLoad {
    if (widget.forceLoad) return false;

    switch (widget.block.type) {
      case MessageBlockType.mainText:
        // 主文本通常较小，不需要懒加载
        return (widget.block.content?.length ?? 0) > 1000;
      case MessageBlockType.code:
        // 代码块可能很大，需要懒加载
        return (widget.block.content?.length ?? 0) > 500;
      case MessageBlockType.thinking:
        // 思考过程可能很长，需要懒加载
        return true;
      case MessageBlockType.image:
        // 图片需要懒加载
        return true;
      case MessageBlockType.tool:
        // 工具调用结果可能很大
        return true;
      case MessageBlockType.file:
        // 文件内容需要懒加载
        return true;
      default:
        return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _isLoaded = !_shouldLazyLoad;
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldLazyLoad || _isLoaded) {
      return _buildActualContent();
    }

    return _buildLazyPlaceholder();
  }

  /// 构建实际内容
  Widget _buildActualContent() {
    // 使用缓存的组件
    if (_cachedWidget != null) {
      return _cachedWidget!;
    }

    final widget = MessageBlockWidget(
      block: this.widget.block,
      isEditable: this.widget.isEditable,
      onEdit: this.widget.onEdit != null
          ? () => this.widget.onEdit!(this.widget.block.id)
          : null,
      onDelete: this.widget.onDelete != null
          ? () => this.widget.onDelete!(this.widget.block.id)
          : null,
      onRegenerate: this.widget.onRegenerate != null
          ? () => this.widget.onRegenerate!(this.widget.block.id)
          : null,
    );

    // 缓存组件
    _cachedWidget = widget;
    return widget;
  }

  /// 构建懒加载占位符
  Widget _buildLazyPlaceholder() {
    return VisibilityDetector(
      key: Key('lazy_block_${widget.block.id}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: _buildPlaceholderContent(),
    );
  }

  /// 构建占位符内容
  Widget _buildPlaceholderContent() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 类型标签
          if (widget.showTypeLabel)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: _getTypeColor().withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                _getTypeDisplayName(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _getTypeColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          if (widget.showTypeLabel) const SizedBox(height: 8.0),

          // 占位符内容
          Row(
            children: [
              Icon(
                _getTypeIcon(),
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  _getPlaceholderText(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              // 加载按钮
              TextButton.icon(
                onPressed: _loadContent,
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text('显示'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),

          // 内容预览
          if (_hasPreview())
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _getPreviewText(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  /// 可见性变化回调
  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0.1 && !_isVisible) {
      _isVisible = true;
      // 延迟加载，避免滚动时频繁触发
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _isVisible) {
          _loadContent();
        }
      });
    } else if (info.visibleFraction == 0) {
      _isVisible = false;
    }
  }

  /// 加载内容
  void _loadContent() {
    if (_isLoaded) return;

    setState(() {
      _isLoaded = true;
    });
  }

  /// 获取类型颜色
  Color _getTypeColor() {
    final colorScheme = Theme.of(context).colorScheme;

    switch (widget.block.type) {
      case MessageBlockType.mainText:
        return colorScheme.primary;
      case MessageBlockType.code:
        return colorScheme.secondary;
      case MessageBlockType.thinking:
        return colorScheme.tertiary;
      case MessageBlockType.image:
        return Colors.green;
      case MessageBlockType.tool:
        return Colors.orange;
      case MessageBlockType.error:
        return colorScheme.error;
      default:
        return colorScheme.outline;
    }
  }

  /// 获取类型图标
  IconData _getTypeIcon() {
    switch (widget.block.type) {
      case MessageBlockType.mainText:
        return Icons.text_fields;
      case MessageBlockType.code:
        return Icons.code;
      case MessageBlockType.thinking:
        return Icons.psychology;
      case MessageBlockType.image:
        return Icons.image;
      case MessageBlockType.tool:
        return Icons.build;
      case MessageBlockType.error:
        return Icons.error;
      default:
        return Icons.help_outline;
    }
  }

  /// 获取类型显示名称
  String _getTypeDisplayName() {
    switch (widget.block.type) {
      case MessageBlockType.mainText:
        return '文本';
      case MessageBlockType.code:
        return '代码';
      case MessageBlockType.thinking:
        return '思考过程';
      case MessageBlockType.image:
        return '图片';
      case MessageBlockType.tool:
        return '工具调用';
      case MessageBlockType.error:
        return '错误';
      default:
        return '未知';
    }
  }

  /// 获取占位符文本
  String _getPlaceholderText() {
    switch (widget.block.type) {
      case MessageBlockType.thinking:
        return '点击查看AI的思考过程...';
      case MessageBlockType.code:
        return '点击查看代码内容...';
      case MessageBlockType.image:
        return '点击加载图片...';
      case MessageBlockType.tool:
        return '点击查看工具调用结果...';
      default:
        return '点击加载内容...';
    }
  }

  /// 是否有预览
  bool _hasPreview() {
    final content = widget.block.content;
    return content != null && content.isNotEmpty && content.length > 50;
  }

  /// 获取预览文本
  String _getPreviewText() {
    final content = widget.block.content ?? '';
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }
}

/// 可见性检测器（简化版实现）
class VisibilityDetector extends StatefulWidget {
  final Widget child;
  final void Function(VisibilityInfo info) onVisibilityChanged;

  const VisibilityDetector({
    super.key,
    required this.child,
    required this.onVisibilityChanged,
  });

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  @override
  Widget build(BuildContext context) {
    // 这里应该实现真正的可见性检测
    // 为了简化，我们直接返回子组件
    // 在实际项目中，可以使用 visibility_detector 包
    return widget.child;
  }
}

/// 可见性信息
class VisibilityInfo {
  final double visibleFraction;

  const VisibilityInfo({required this.visibleFraction});
}
