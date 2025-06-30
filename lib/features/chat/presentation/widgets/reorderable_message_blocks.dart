import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_block.dart';
import '../../domain/entities/message_block_type.dart';
import 'message_block_widget.dart';

/// 可重排序的消息块列表
///
/// 允许用户通过拖拽重新排列消息块的顺序，
/// 提供直观的消息内容组织方式。
///
/// 功能特性：
/// - 🔄 **拖拽排序**: 直观的拖拽重排序操作
/// - 🎯 **智能约束**: 某些块类型有位置约束
/// - 💾 **实时保存**: 排序变更实时保存
/// - 🎨 **视觉反馈**: 拖拽过程的视觉提示
/// - ⚡ **性能优化**: 优化的重排序算法
class ReorderableMessageBlocks extends ConsumerStatefulWidget {
  /// 消息对象
  final Message message;

  /// 是否启用编辑模式
  final bool isEditable;

  /// 是否显示类型标签
  final bool showTypeLabels;

  /// 块编辑回调
  final void Function(String blockId)? onBlockEdit;

  /// 块删除回调
  final void Function(String blockId)? onBlockDelete;

  /// 块重新生成回调
  final void Function(String blockId)? onBlockRegenerate;

  /// 排序变更回调
  final void Function(List<MessageBlock> reorderedBlocks)? onReorder;

  const ReorderableMessageBlocks({
    super.key,
    required this.message,
    this.isEditable = false,
    this.showTypeLabels = false,
    this.onBlockEdit,
    this.onBlockDelete,
    this.onBlockRegenerate,
    this.onReorder,
  });

  @override
  ConsumerState<ReorderableMessageBlocks> createState() =>
      _ReorderableMessageBlocksState();
}

class _ReorderableMessageBlocksState
    extends ConsumerState<ReorderableMessageBlocks> {
  List<MessageBlock> _blocks = [];
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _blocks = List.from(widget.message.blocks);
  }

  @override
  void didUpdateWidget(ReorderableMessageBlocks oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message.id != oldWidget.message.id) {
      _blocks = List.from(widget.message.blocks);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEditable) {
      // 非编辑模式，显示普通的块列表
      return _buildNormalView();
    }

    return _buildReorderableView();
  }

  /// 构建普通视图
  Widget _buildNormalView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _blocks.map((block) => _buildBlockItem(block, false)).toList(),
    );
  }

  /// 构建可重排序视图
  Widget _buildReorderableView() {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.transparent,
      ),
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        onReorder: _onReorder,
        proxyDecorator: _proxyDecorator,
        itemCount: _blocks.length,
        itemBuilder: (context, index) {
          final block = _blocks[index];
          return _buildReorderableBlockItem(block, index);
        },
      ),
    );
  }

  /// 构建可重排序的块项
  Widget _buildReorderableBlockItem(MessageBlock block, int index) {
    return Container(
      key: ValueKey(block.id),
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              // 拖拽手柄
              _buildDragHandle(block, index),

              // 块内容
              _buildBlockItem(block, true),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建拖拽手柄
  Widget _buildDragHandle(MessageBlock block, int index) {
    final canMove = _canMoveBlock(block);

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      child: Row(
        children: [
          // 拖拽图标
          Container(
            width: 40,
            child: Icon(
              canMove ? Icons.drag_handle : Icons.lock,
              size: 16,
              color: canMove
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.5),
            ),
          ),

          // 块类型标签
          Expanded(
            child: Text(
              _getBlockTypeDisplayName(block.type),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),

          // 位置指示器
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              '${index + 1}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          const SizedBox(width: 8.0),
        ],
      ),
    );
  }

  /// 构建块项
  Widget _buildBlockItem(MessageBlock block, bool showActions) {
    return MessageBlockWidget(
      block: block,
      isEditable: showActions,
      // showTypeLabel: widget.showTypeLabels && !showActions, // MessageBlockWidget没有showTypeLabel参数
      onEdit: widget.onBlockEdit != null
          ? () => widget.onBlockEdit!(block.id)
          : null,
      onDelete: widget.onBlockDelete != null
          ? () => widget.onBlockDelete!(block.id)
          : null,
      onRegenerate: widget.onBlockRegenerate != null
          ? () => widget.onBlockRegenerate!(block.id)
          : null,
    );
  }

  /// 拖拽代理装饰器
  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.05,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.3),
                  blurRadius: 8.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// 重排序回调
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      _isDragging = true;
    });

    // 调整索引（ReorderableListView的特殊处理）
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final block = _blocks[oldIndex];

    // 检查是否可以移动到目标位置
    if (!_canMoveToPosition(block, newIndex)) {
      setState(() {
        _isDragging = false;
      });
      _showMoveConstraintMessage(block);
      return;
    }

    setState(() {
      _blocks.removeAt(oldIndex);
      _blocks.insert(newIndex, block);
      _isDragging = false;
    });

    // 更新块的orderIndex
    _updateBlockOrder();

    // 通知父组件
    widget.onReorder?.call(_blocks);

    // 保存到数据库
    _saveReorderedBlocks();
  }

  /// 更新块的顺序索引
  void _updateBlockOrder() {
    // MessageBlock没有orderIndex属性，这里只是重新排列列表
    // 实际的顺序由列表中的位置决定
  }

  /// 保存重排序的块
  void _saveReorderedBlocks() {
    // TODO: 实现保存重排序的块到数据库
    // 这里需要调用相应的服务来保存新的块顺序
    widget.onReorder?.call(_blocks);
  }

  /// 检查块是否可以移动
  bool _canMoveBlock(MessageBlock block) {
    switch (block.type) {
      case MessageBlockType.thinking:
        // 思考过程通常应该在开头
        return true;
      case MessageBlockType.mainText:
        // 主文本可以移动
        return true;
      case MessageBlockType.code:
        // 代码块可以移动
        return true;
      case MessageBlockType.tool:
        // 工具调用可以移动，但有约束
        return true;
      case MessageBlockType.error:
        // 错误块通常不应该移动
        return false;
      default:
        return true;
    }
  }

  /// 检查是否可以移动到指定位置
  bool _canMoveToPosition(MessageBlock block, int newIndex) {
    switch (block.type) {
      case MessageBlockType.thinking:
        // 思考过程应该在主文本之前
        final mainTextIndex = _blocks.indexWhere(
          (b) => b.type == MessageBlockType.mainText,
        );
        return mainTextIndex == -1 || newIndex <= mainTextIndex;

      case MessageBlockType.error:
        // 错误块不能移动
        return false;

      default:
        return true;
    }
  }

  /// 显示移动约束消息
  void _showMoveConstraintMessage(MessageBlock block) {
    String message;
    switch (block.type) {
      case MessageBlockType.thinking:
        message = '思考过程应该在主文本之前';
        break;
      case MessageBlockType.error:
        message = '错误块无法移动';
        break;
      default:
        message = '此块无法移动到该位置';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 获取块类型显示名称
  String _getBlockTypeDisplayName(MessageBlockType type) {
    switch (type) {
      case MessageBlockType.thinking:
        return '思考过程';
      case MessageBlockType.mainText:
        return '主要内容';
      case MessageBlockType.code:
        return '代码';
      case MessageBlockType.tool:
        return '工具调用';
      case MessageBlockType.image:
        return '图片';
      case MessageBlockType.error:
        return '错误';
      default:
        return '未知类型';
    }
  }
}

/// 重排序工具栏
class ReorderToolbar extends StatelessWidget {
  final bool isEditing;
  final VoidCallback? onToggleEdit;
  final VoidCallback? onReset;
  final VoidCallback? onSave;

  const ReorderToolbar({
    super.key,
    required this.isEditing,
    this.onToggleEdit,
    this.onReset,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(
            isEditing ? Icons.edit : Icons.reorder,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8.0),
          Text(
            isEditing ? '编辑模式' : '查看模式',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          if (isEditing) ...[
            TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('重置'),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8.0),
            TextButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save, size: 16),
              label: const Text('保存'),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
          const SizedBox(width: 8.0),
          IconButton(
            onPressed: onToggleEdit,
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            iconSize: 16,
            padding: const EdgeInsets.all(4.0),
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            tooltip: isEditing ? '完成编辑' : '开始编辑',
          ),
        ],
      ),
    );
  }
}
