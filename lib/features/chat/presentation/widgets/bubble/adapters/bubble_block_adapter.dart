import 'package:flutter/material.dart';

import '../../../../domain/entities/message_block.dart';
import '../../../../domain/entities/message_block_type.dart';
import '../bubble_context.dart';

/// 气泡块适配器抽象基类
///
/// 定义了消息块在气泡中的渲染接口
abstract class BubbleBlockAdapter {
  /// 在气泡中构建消息块组件
  ///
  /// [block] 要渲染的消息块
  /// [context] 气泡上下文信息
  /// [isFirst] 是否为第一个块
  /// [isLast] 是否为最后一个块
  Widget buildInBubble(
    MessageBlock block,
    BubbleContext context, {
    bool isFirst = false,
    bool isLast = false,
  });

  /// 检查是否可以处理指定类型的消息块
  ///
  /// [type] 消息块类型
  bool canHandleBlock(MessageBlockType type);

  /// 获取消息块的首选高度
  ///
  /// [block] 消息块
  /// [context] 气泡上下文
  double getPreferredHeight(MessageBlock block, BubbleContext context) {
    // 默认返回估算高度
    return _estimateHeight(block, context);
  }

  /// 获取消息块的首选宽度
  ///
  /// [block] 消息块
  /// [context] 气泡上下文
  double getPreferredWidth(MessageBlock block, BubbleContext context) {
    // 默认返回最大可用宽度
    return context.calculatedMaxWidth;
  }

  /// 检查消息块是否需要特殊处理
  ///
  /// [block] 消息块
  bool requiresSpecialHandling(MessageBlock block) {
    return false;
  }

  /// 获取适配器的优先级
  ///
  /// 数值越高优先级越高，用于解决多个适配器都能处理同一类型块的情况
  int get priority => 0;

  /// 获取适配器名称
  String get name => runtimeType.toString();

  /// 获取适配器版本
  String get version => '1.0.0';

  /// 获取支持的块类型列表
  List<MessageBlockType> get supportedTypes;

  /// 清理资源
  void dispose() {
    // 子类可以重写此方法来清理资源
  }

  /// 估算消息块高度的默认实现
  double _estimateHeight(MessageBlock block, BubbleContext context) {
    if (!block.hasContent) {
      return 40.0; // 空内容的默认高度
    }

    final content = block.content!;
    final lines = content.split('\n').length;
    final baseLineHeight = 20.0;
    final padding = context.padding.vertical;

    return (lines * baseLineHeight) + padding + 16.0; // 额外的16像素用于边距
  }

  /// 构建通用的错误显示组件
  Widget buildErrorWidget(
    String message,
    BubbleContext context, {
    IconData icon = Icons.error_outline,
  }) {
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
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: context.theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: context.theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建通用的加载指示器
  Widget buildLoadingWidget(
    BubbleContext context, {
    String? message,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.theme.colorScheme.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(width: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: context.theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建通用的空内容占位符
  Widget buildEmptyWidget(
    BubbleContext context, {
    String message = '内容为空',
    IconData icon = Icons.info_outline,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建通用的容器装饰
  BoxDecoration buildContainerDecoration(
    BubbleContext context, {
    Color? backgroundColor,
    Color? borderColor,
    double borderRadius = 8.0,
    double borderWidth = 1.0,
  }) {
    return BoxDecoration(
      color:
          backgroundColor ?? context.theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(borderRadius),
      border: borderColor != null
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
    );
  }

  /// 获取响应式字体大小
  double getResponsiveFontSize(BubbleContext context, double baseFontSize) {
    if (context.isDesktop) {
      return baseFontSize * 1.1;
    } else if (context.isTablet) {
      return baseFontSize;
    } else {
      return baseFontSize * 0.95;
    }
  }

  /// 获取响应式间距
  double getResponsiveSpacing(BubbleContext context, double baseSpacing) {
    if (context.isDesktop) {
      return baseSpacing * 1.2;
    } else if (context.isTablet) {
      return baseSpacing;
    } else {
      return baseSpacing * 0.8;
    }
  }

  /// 检查是否应该显示复制按钮
  bool shouldShowCopyButton(MessageBlock block) {
    return block.hasContent && block.content!.trim().isNotEmpty;
  }

  /// 构建复制按钮
  Widget buildCopyButton(
    MessageBlock block,
    BubbleContext context, {
    VoidCallback? onCopy,
  }) {
    return IconButton(
      icon: Icon(
        Icons.copy_outlined,
        size: 16,
        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      onPressed: onCopy ?? () => _copyToClipboard(block.content ?? ''),
      tooltip: '复制',
      constraints: const BoxConstraints(
        minWidth: 32,
        minHeight: 32,
      ),
      padding: const EdgeInsets.all(4),
    );
  }

  /// 复制内容到剪贴板
  void _copyToClipboard(String content) {
    // 这里需要实现复制到剪贴板的功能
    // 可以使用 flutter/services 包的 Clipboard.setData
  }
}

/// 适配器优先级常量
class AdapterPriority {
  static const int lowest = 0;
  static const int low = 25;
  static const int normal = 50;
  static const int high = 75;
  static const int highest = 100;
}

/// 适配器注册信息
class AdapterRegistration {
  const AdapterRegistration({
    required this.type,
    required this.adapter,
    this.priority = AdapterPriority.normal,
  });

  final MessageBlockType type;
  final BubbleBlockAdapter adapter;
  final int priority;
}

/// 适配器工厂接口
abstract class BubbleBlockAdapterFactory {
  /// 创建适配器实例
  BubbleBlockAdapter createAdapter();

  /// 获取支持的块类型
  List<MessageBlockType> getSupportedTypes();

  /// 获取工厂名称
  String get name;
}
