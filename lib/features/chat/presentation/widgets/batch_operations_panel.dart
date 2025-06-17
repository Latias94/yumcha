import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_block.dart';
import '../../domain/entities/message_block_type.dart';

/// 批量操作面板
///
/// 提供消息和消息块的批量操作功能，
/// 包括选择、删除、导出、复制等操作。
///
/// 功能特性：
/// - ✅ **多选模式**: 支持消息和消息块的多选
/// - 🗑️ **批量删除**: 一次删除多个项目
/// - 📋 **批量复制**: 复制选中内容到剪贴板
/// - 📤 **批量导出**: 导出选中内容为文件
/// - 🏷️ **批量标记**: 批量添加标签或标记
/// - 🔄 **批量操作**: 支持自定义批量操作
class BatchOperationsPanel extends ConsumerStatefulWidget {
  /// 对话ID
  final String conversationId;

  /// 可操作的消息列表
  final List<Message> messages;

  /// 是否启用批量模式
  final bool isBatchMode;

  /// 批量模式切换回调
  final void Function(bool enabled)? onBatchModeToggle;

  /// 操作完成回调
  final void Function(String operation, List<String> itemIds)?
      onOperationComplete;

  const BatchOperationsPanel({
    super.key,
    required this.conversationId,
    required this.messages,
    this.isBatchMode = false,
    this.onBatchModeToggle,
    this.onOperationComplete,
  });

  @override
  ConsumerState<BatchOperationsPanel> createState() =>
      _BatchOperationsPanelState();
}

class _BatchOperationsPanelState extends ConsumerState<BatchOperationsPanel> {
  final Set<String> _selectedMessageIds = {};
  final Set<String> _selectedBlockIds = {};
  bool _selectAll = false;

  @override
  void didUpdateWidget(BatchOperationsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果退出批量模式，清除选择
    if (!widget.isBatchMode && oldWidget.isBatchMode) {
      _clearSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isBatchMode) {
      return _buildBatchModeToggle();
    }

    return _buildBatchOperationsPanel();
  }

  /// 构建批量模式切换按钮
  Widget _buildBatchModeToggle() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Spacer(),
          TextButton.icon(
            onPressed: () => widget.onBatchModeToggle?.call(true),
            icon: const Icon(Icons.checklist, size: 18),
            label: const Text('批量操作'),
            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建批量操作面板
  Widget _buildBatchOperationsPanel() {
    final selectedCount = _selectedMessageIds.length + _selectedBlockIds.length;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          _buildTitleBar(selectedCount),

          // 选择控制
          _buildSelectionControls(),

          // 操作按钮
          if (selectedCount > 0) _buildOperationButtons(),

          // 选中项列表
          if (selectedCount > 0) _buildSelectedItemsList(),
        ],
      ),
    );
  }

  /// 构建标题栏
  Widget _buildTitleBar(int selectedCount) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(
            Icons.checklist,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8.0),
          Text(
            '批量操作',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (selectedCount > 0) ...[
            const SizedBox(width: 8.0),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                '$selectedCount',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            onPressed: () => widget.onBatchModeToggle?.call(false),
            icon: const Icon(Icons.close),
            tooltip: '退出批量模式',
          ),
        ],
      ),
    );
  }

  /// 构建选择控制
  Widget _buildSelectionControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Checkbox(
            value: _selectAll,
            onChanged: _onSelectAllChanged,
            tristate: true,
          ),
          const SizedBox(width: 8.0),
          Text(
            _selectAll ? '取消全选' : '全选',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          TextButton(
            onPressed: _clearSelection,
            child: const Text('清除选择'),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildOperationButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: [
          _buildOperationButton(
            icon: Icons.copy,
            label: '复制',
            onPressed: _copySelected,
          ),
          _buildOperationButton(
            icon: Icons.download,
            label: '导出',
            onPressed: _exportSelected,
          ),
          _buildOperationButton(
            icon: Icons.label,
            label: '标记',
            onPressed: _markSelected,
          ),
          _buildOperationButton(
            icon: Icons.delete,
            label: '删除',
            onPressed: _deleteSelected,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildOperationButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isDestructive ? Theme.of(context).colorScheme.errorContainer : null,
        foregroundColor: isDestructive
            ? Theme.of(context).colorScheme.onErrorContainer
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  /// 构建选中项列表
  Widget _buildSelectedItemsList() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView(
        shrinkWrap: true,
        children: [
          // 选中的消息
          if (_selectedMessageIds.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '选中的消息 (${_selectedMessageIds.length})',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            ..._selectedMessageIds.map((messageId) {
              final message = widget.messages.firstWhere(
                (m) => m.id == messageId,
                orElse: () => throw StateError('Message not found'),
              );
              return _buildSelectedMessageItem(message);
            }),
          ],

          // 选中的消息块
          if (_selectedBlockIds.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '选中的消息块 (${_selectedBlockIds.length})',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            ..._selectedBlockIds.map((blockId) {
              final block = _findBlockById(blockId);
              return block != null
                  ? _buildSelectedBlockItem(block)
                  : const SizedBox.shrink();
            }),
          ],
        ],
      ),
    );
  }

  /// 构建选中的消息项
  Widget _buildSelectedMessageItem(Message message) {
    return ListTile(
      dense: true,
      leading: Icon(
        message.isFromUser ? Icons.person : Icons.smart_toy,
        size: 16,
      ),
      title: Text(
        message.content.length > 50
            ? '${message.content.substring(0, 50)}...'
            : message.content,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      subtitle: Text(
        '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}',
        style: Theme.of(context).textTheme.labelSmall,
      ),
      trailing: IconButton(
        onPressed: () => _toggleMessageSelection(message.id),
        icon: const Icon(Icons.close, size: 16),
      ),
    );
  }

  /// 构建选中的消息块项
  Widget _buildSelectedBlockItem(MessageBlock block) {
    return ListTile(
      dense: true,
      leading: Icon(
        _getBlockTypeIcon(block.type),
        size: 16,
      ),
      title: Text(
        block.content?.length != null && block.content!.length > 50
            ? '${block.content!.substring(0, 50)}...'
            : block.content ?? '',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      subtitle: Text(
        _getBlockTypeName(block.type),
        style: Theme.of(context).textTheme.labelSmall,
      ),
      trailing: IconButton(
        onPressed: () => _toggleBlockSelection(block.id),
        icon: const Icon(Icons.close, size: 16),
      ),
    );
  }

  /// 全选状态变更
  void _onSelectAllChanged(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      if (_selectAll) {
        _selectedMessageIds.addAll(widget.messages.map((m) => m.id));
        for (final message in widget.messages) {
          _selectedBlockIds.addAll(message.blocks.map((b) => b.id));
        }
      } else {
        _clearSelection();
      }
    });
  }

  /// 切换消息选择状态
  void _toggleMessageSelection(String messageId) {
    setState(() {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
      } else {
        _selectedMessageIds.add(messageId);
      }
      _updateSelectAllState();
    });
  }

  /// 切换消息块选择状态
  void _toggleBlockSelection(String blockId) {
    setState(() {
      if (_selectedBlockIds.contains(blockId)) {
        _selectedBlockIds.remove(blockId);
      } else {
        _selectedBlockIds.add(blockId);
      }
      _updateSelectAllState();
    });
  }

  /// 更新全选状态
  void _updateSelectAllState() {
    final totalItems = widget.messages.length +
        widget.messages.fold(0, (sum, m) => sum + m.blocks.length);
    final selectedItems = _selectedMessageIds.length + _selectedBlockIds.length;

    setState(() {
      _selectAll = selectedItems == totalItems;
    });
  }

  /// 清除选择
  void _clearSelection() {
    setState(() {
      _selectedMessageIds.clear();
      _selectedBlockIds.clear();
      _selectAll = false;
    });
  }

  /// 复制选中项
  void _copySelected() {
    // TODO: 实现复制功能
    widget.onOperationComplete?.call('copy', [
      ..._selectedMessageIds,
      ..._selectedBlockIds,
    ]);
  }

  /// 导出选中项
  void _exportSelected() {
    // TODO: 实现导出功能
    widget.onOperationComplete?.call('export', [
      ..._selectedMessageIds,
      ..._selectedBlockIds,
    ]);
  }

  /// 标记选中项
  void _markSelected() {
    // TODO: 实现标记功能
    widget.onOperationComplete?.call('mark', [
      ..._selectedMessageIds,
      ..._selectedBlockIds,
    ]);
  }

  /// 删除选中项
  void _deleteSelected() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text(
            '确定要删除选中的 ${_selectedMessageIds.length + _selectedBlockIds.length} 个项目吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onOperationComplete?.call('delete', [
                ..._selectedMessageIds,
                ..._selectedBlockIds,
              ]);
              _clearSelection();
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 根据ID查找消息块
  MessageBlock? _findBlockById(String blockId) {
    for (final message in widget.messages) {
      for (final block in message.blocks) {
        if (block.id == blockId) {
          return block;
        }
      }
    }
    return null;
  }

  /// 获取块类型图标
  IconData _getBlockTypeIcon(MessageBlockType type) {
    switch (type) {
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
      default:
        return Icons.help_outline;
    }
  }

  /// 获取块类型名称
  String _getBlockTypeName(MessageBlockType type) {
    switch (type) {
      case MessageBlockType.mainText:
        return '文本';
      case MessageBlockType.code:
        return '代码';
      case MessageBlockType.thinking:
        return '思考';
      case MessageBlockType.image:
        return '图片';
      case MessageBlockType.tool:
        return '工具';
      default:
        return '未知';
    }
  }
}
