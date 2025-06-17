import 'package:flutter/material.dart';

import '../../../domain/entities/message_block.dart';
import '../../../domain/entities/message_block_type.dart';
import 'bubble_context.dart';
import 'adapters/bubble_block_adapter.dart';
import 'adapters/text_bubble_adapter.dart';
import 'adapters/code_bubble_adapter.dart';
import 'adapters/image_bubble_adapter.dart';
import 'adapters/thinking_bubble_adapter.dart';
import 'adapters/tool_call_bubble_adapter.dart';
import 'adapters/file_bubble_adapter.dart';
import 'adapters/error_bubble_adapter.dart';
import 'adapters/quote_bubble_adapter.dart';

/// 气泡块渲染器
///
/// 负责管理和调度不同类型消息块的渲染适配器
class BubbleBlockRenderer {
  BubbleBlockRenderer._();

  static final BubbleBlockRenderer _instance = BubbleBlockRenderer._();
  static BubbleBlockRenderer get instance => _instance;

  /// 适配器映射表
  final Map<MessageBlockType, BubbleBlockAdapter> _adapters = {};

  /// 默认适配器
  late final BubbleBlockAdapter _defaultAdapter;

  /// 初始化渲染器
  void initialize() {
    // 注册所有内置适配器
    _registerBuiltinAdapters();

    // 设置默认适配器
    _defaultAdapter = TextBubbleAdapter();
  }

  /// 注册内置适配器
  void _registerBuiltinAdapters() {
    registerAdapter(MessageBlockType.mainText, TextBubbleAdapter());
    registerAdapter(MessageBlockType.thinking, ThinkingBubbleAdapter());
    registerAdapter(MessageBlockType.image, ImageBubbleAdapter());
    registerAdapter(MessageBlockType.code, CodeBubbleAdapter());
    registerAdapter(MessageBlockType.tool, ToolCallBubbleAdapter());
    registerAdapter(MessageBlockType.file, FileBubbleAdapter());
    registerAdapter(MessageBlockType.error, ErrorBubbleAdapter());
    registerAdapter(MessageBlockType.citation, QuoteBubbleAdapter());
  }

  /// 注册适配器
  void registerAdapter(MessageBlockType type, BubbleBlockAdapter adapter) {
    _adapters[type] = adapter;
  }

  /// 注销适配器
  void unregisterAdapter(MessageBlockType type) {
    _adapters.remove(type);
  }

  /// 获取适配器
  BubbleBlockAdapter? getAdapter(MessageBlockType type) {
    return _adapters[type];
  }

  /// 渲染消息块
  Widget renderBlock(
    MessageBlock block,
    BubbleContext context, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final adapter = _getAdapterForBlock(block);

    try {
      return adapter.buildInBubble(
        block,
        context,
        isFirst: isFirst,
        isLast: isLast,
      );
    } catch (e, stackTrace) {
      // 渲染失败时显示错误信息
      return _buildErrorFallback(block, context, e, stackTrace);
    }
  }

  /// 获取块的适配器
  BubbleBlockAdapter _getAdapterForBlock(MessageBlock block) {
    final adapter = _adapters[block.type];
    if (adapter != null && adapter.canHandleBlock(block.type)) {
      return adapter;
    }

    // 尝试找到能处理该块类型的适配器
    for (final adapter in _adapters.values) {
      if (adapter.canHandleBlock(block.type)) {
        return adapter;
      }
    }

    // 使用默认适配器
    return _defaultAdapter;
  }

  /// 构建错误回退组件
  Widget _buildErrorFallback(
    MessageBlock block,
    BubbleContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.theme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: context.theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                '渲染失败',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '块类型: ${block.type.name}',
            style: TextStyle(
              fontSize: 12,
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if (block.hasContent) ...[
            const SizedBox(height: 4),
            Text(
              '内容: ${block.content!.length > 50 ? '${block.content!.substring(0, 50)}...' : block.content!}',
              style: TextStyle(
                fontSize: 12,
                color:
                    context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '错误: $error',
            style: TextStyle(
              fontSize: 11,
              color: context.theme.colorScheme.error.withValues(alpha: 0.8),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  /// 预计算块的首选高度
  double calculatePreferredHeight(
    MessageBlock block,
    BubbleContext context,
  ) {
    final adapter = _getAdapterForBlock(block);

    try {
      return adapter.getPreferredHeight(block, context);
    } catch (e) {
      // 计算失败时返回默认高度
      return 50.0;
    }
  }

  /// 检查块是否可以渲染
  bool canRenderBlock(MessageBlock block) {
    final adapter = _getAdapterForBlock(block);
    return adapter.canHandleBlock(block.type);
  }

  /// 获取所有支持的块类型
  Set<MessageBlockType> getSupportedBlockTypes() {
    final types = <MessageBlockType>{};

    for (final entry in _adapters.entries) {
      if (entry.value.canHandleBlock(entry.key)) {
        types.add(entry.key);
      }
    }

    return types;
  }

  /// 获取适配器统计信息
  Map<String, dynamic> getAdapterStats() {
    return {
      'totalAdapters': _adapters.length,
      'supportedTypes': getSupportedBlockTypes().length,
      'adapters': _adapters.entries
          .map((entry) => {
                'type': entry.key.name,
                'adapter': entry.value.runtimeType.toString(),
              })
          .toList(),
    };
  }

  /// 清理资源
  void dispose() {
    for (final adapter in _adapters.values) {
      adapter.dispose();
    }
    _adapters.clear();
  }
}

/// 渲染器扩展方法
extension BubbleBlockRendererExtensions on BubbleBlockRenderer {
  /// 批量渲染消息块
  List<Widget> renderBlocks(
    List<MessageBlock> blocks,
    BubbleContext context,
  ) {
    final widgets = <Widget>[];

    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      final isFirst = i == 0;
      final isLast = i == blocks.length - 1;

      final widget = renderBlock(
        block,
        context,
        isFirst: isFirst,
        isLast: isLast,
      );

      widgets.add(widget);
    }

    return widgets;
  }

  /// 渲染带间距的消息块
  List<Widget> renderBlocksWithSpacing(
    List<MessageBlock> blocks,
    BubbleContext context, {
    double spacing = 8.0,
  }) {
    final widgets = <Widget>[];

    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      final isFirst = i == 0;
      final isLast = i == blocks.length - 1;

      final widget = renderBlock(
        block,
        context,
        isFirst: isFirst,
        isLast: isLast,
      );

      widgets.add(widget);

      // 在块之间添加间距（除了最后一个）
      if (!isLast) {
        widgets.add(SizedBox(height: spacing));
      }
    }

    return widgets;
  }

  /// 计算所有块的总高度
  double calculateTotalHeight(
    List<MessageBlock> blocks,
    BubbleContext context, {
    double spacing = 8.0,
  }) {
    double totalHeight = 0.0;

    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      totalHeight += calculatePreferredHeight(block, context);

      // 添加间距（除了最后一个）
      if (i < blocks.length - 1) {
        totalHeight += spacing;
      }
    }

    return totalHeight;
  }
}
