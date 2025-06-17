import 'package:flutter/material.dart';

import '../../../domain/entities/message_block.dart';
import '../../../domain/entities/message_block_type.dart';
import 'bubble_context.dart';
import 'bubble_style.dart';
import '../../../../../shared/presentation/design_system/design_constants.dart';

/// 块布局管理器
///
/// 负责管理消息块的布局、间距和视觉层次
class BlockLayoutManager {
  const BlockLayoutManager._();

  static const BlockLayoutManager instance = BlockLayoutManager._();

  /// 构建优化的块列表
  List<Widget> buildOptimizedBlockList(
    List<MessageBlock> blocks,
    BubbleContext context,
    Widget Function(MessageBlock, BubbleContext,
            {required bool isFirst, required bool isLast})
        blockBuilder,
  ) {
    if (blocks.isEmpty) return [];

    final widgets = <Widget>[];

    // 按类型分组块，优化视觉层次
    final groupedBlocks = _groupBlocksByType(blocks);

    for (int groupIndex = 0; groupIndex < groupedBlocks.length; groupIndex++) {
      final group = groupedBlocks[groupIndex];
      final isFirstGroup = groupIndex == 0;
      final isLastGroup = groupIndex == groupedBlocks.length - 1;

      // 构建组内容
      final groupWidgets = _buildBlockGroup(
        group,
        context,
        blockBuilder,
        isFirstGroup: isFirstGroup,
        isLastGroup: isLastGroup,
      );

      widgets.addAll(groupWidgets);

      // 组间间距和视觉分隔
      if (!isLastGroup) {
        final nextGroup = groupedBlocks[groupIndex + 1];
        final spacing = _getGroupSpacing(group, nextGroup, context);

        if (spacing > 0) {
          // 检查是否需要视觉分隔器
          if (_needsVisualSeparator(group, nextGroup)) {
            widgets.add(_buildVisualSeparator(context, spacing));
          } else {
            widgets.add(SizedBox(height: spacing));
          }
        }
      }
    }

    return widgets;
  }

  /// 按类型和视觉层次分组块
  List<List<MessageBlock>> _groupBlocksByType(List<MessageBlock> blocks) {
    final groups = <List<MessageBlock>>[];
    List<MessageBlock>? currentGroup;
    MessageBlockType? currentType;

    for (final block in blocks) {
      // 检查是否应该与当前组合并
      if (currentType != null &&
          currentGroup != null &&
          _shouldGroupTogether(currentType, block.type)) {
        currentGroup.add(block);
        // 更新组类型为更高优先级的类型
        if (getBlockPriority(block.type) < getBlockPriority(currentType)) {
          currentType = block.type;
        }
      } else {
        // 开始新组
        if (currentGroup != null) {
          groups.add(currentGroup);
        }
        currentGroup = [block];
        currentType = block.type;
      }
    }

    // 添加最后一组
    if (currentGroup != null) {
      groups.add(currentGroup);
    }

    return groups;
  }

  /// 判断两种块类型是否应该分组在一起
  bool _shouldGroupTogether(MessageBlockType type1, MessageBlockType type2) {
    // 相同类型总是分组
    if (type1 == type2) return true;

    // 文本相关类型可以分组
    if (_isTextRelatedType(type1) && _isTextRelatedType(type2)) {
      return true;
    }

    // 媒体相关类型可以分组
    if (_isMediaType(type1) && _isMediaType(type2)) {
      return true;
    }

    return false;
  }

  /// 判断是否为文本相关类型
  bool _isTextRelatedType(MessageBlockType type) {
    return type == MessageBlockType.mainText ||
        type == MessageBlockType.thinking ||
        type == MessageBlockType.translation;
  }

  /// 判断是否为媒体类型
  bool _isMediaType(MessageBlockType type) {
    return type == MessageBlockType.image || type == MessageBlockType.file;
  }

  /// 构建块组
  List<Widget> _buildBlockGroup(
    List<MessageBlock> group,
    BubbleContext context,
    Widget Function(MessageBlock, BubbleContext,
            {required bool isFirst, required bool isLast})
        blockBuilder, {
    required bool isFirstGroup,
    required bool isLastGroup,
  }) {
    final widgets = <Widget>[];

    // 组内块的紧密布局
    for (int i = 0; i < group.length; i++) {
      final block = group[i];
      final isFirst = i == 0;
      final isLast = i == group.length - 1;

      final widget = blockBuilder(
        block,
        context,
        isFirst: isFirst && isFirstGroup,
        isLast: isLast && isLastGroup,
      );

      widgets.add(widget);

      // 组内间距（更小）
      if (!isLast) {
        final spacing = _getIntraGroupSpacing(block, group[i + 1], context);
        if (spacing > 0) {
          widgets.add(SizedBox(height: spacing));
        }
      }
    }

    return widgets;
  }

  /// 获取组间间距
  double _getGroupSpacing(
    List<MessageBlock> currentGroup,
    List<MessageBlock> nextGroup,
    BubbleContext context,
  ) {
    final currentType = currentGroup.first.type;
    final nextType = nextGroup.first.type;

    // 基础组间距
    double baseSpacing = _getBaseSpacing(context) * 1.5;

    // 特殊类型组合调整
    final multiplier = _getGroupSpacingMultiplier(currentType, nextType);

    return baseSpacing * multiplier * _getResponsiveMultiplier(context);
  }

  /// 获取组内间距
  double _getIntraGroupSpacing(
    MessageBlock currentBlock,
    MessageBlock nextBlock,
    BubbleContext context,
  ) {
    // 同类型块使用更小的间距
    double baseSpacing = _getBaseSpacing(context) * 0.3;

    return baseSpacing * _getResponsiveMultiplier(context);
  }

  /// 获取基础间距
  double _getBaseSpacing(BubbleContext context) {
    switch (context.style.type) {
      case BubbleType.bubble:
        return DesignConstants.spaceS; // 8.0
      case BubbleType.card:
        return DesignConstants.spaceM; // 12.0
      case BubbleType.list:
        return DesignConstants.spaceXS; // 4.0
    }
  }

  /// 获取组间距倍数
  double _getGroupSpacingMultiplier(
      MessageBlockType currentType, MessageBlockType nextType) {
    // 思考过程后需要更大间距
    if (currentType == MessageBlockType.thinking) {
      return 2.0;
    }

    // 代码块前后需要适中间距
    if (currentType == MessageBlockType.code ||
        nextType == MessageBlockType.code) {
      return 1.5;
    }

    // 图片前后需要适中间距
    if (currentType == MessageBlockType.image ||
        nextType == MessageBlockType.image) {
      return 1.3;
    }

    // 文本到其他类型
    if (currentType == MessageBlockType.mainText &&
        nextType != MessageBlockType.mainText) {
      return 1.2;
    }

    return 1.0;
  }

  /// 获取响应式倍数
  double _getResponsiveMultiplier(BubbleContext context) {
    if (context.isMobile) {
      return 0.8; // 移动端减少间距
    } else if (context.isTablet) {
      return 0.9; // 平板端略减间距
    } else {
      return 1.0; // 桌面端标准间距
    }
  }

  /// 计算块的优先级（用于排序和分组）
  int getBlockPriority(MessageBlockType type) {
    switch (type) {
      case MessageBlockType.thinking:
        return 1; // 最高优先级，通常在前面
      case MessageBlockType.mainText:
        return 2; // 主要内容
      case MessageBlockType.code:
        return 3; // 代码块
      case MessageBlockType.image:
        return 4; // 图片
      case MessageBlockType.file:
        return 5; // 文件
      case MessageBlockType.tool:
        return 6; // 工具调用
      case MessageBlockType.citation:
        return 7; // 引用
      case MessageBlockType.translation:
        return 8; // 翻译
      case MessageBlockType.error:
        return 9; // 错误信息通常在最后
      default:
        return 10; // 未知类型
    }
  }

  /// 是否应该合并相邻的相同类型块
  bool shouldMergeAdjacentBlocks(MessageBlockType type) {
    switch (type) {
      case MessageBlockType.mainText:
      case MessageBlockType.thinking:
        return true; // 文本和思考过程可以合并显示
      default:
        return false; // 其他类型保持独立
    }
  }

  /// 判断是否需要视觉分隔器
  bool _needsVisualSeparator(
      List<MessageBlock> currentGroup, List<MessageBlock> nextGroup) {
    final currentType = currentGroup.first.type;
    final nextType = nextGroup.first.type;

    // 思考过程和主要内容之间需要分隔器
    if (currentType == MessageBlockType.thinking &&
        nextType == MessageBlockType.mainText) {
      return true;
    }

    // 代码块前后需要分隔器
    if (currentType == MessageBlockType.code ||
        nextType == MessageBlockType.code) {
      return true;
    }

    // 不同类型的媒体内容之间需要分隔器
    if (_isMediaType(currentType) && !_isMediaType(nextType)) {
      return true;
    }

    return false;
  }

  /// 构建视觉分隔器
  Widget _buildVisualSeparator(BubbleContext context, double spacing) {
    return Container(
      height: spacing,
      margin: EdgeInsets.symmetric(vertical: spacing * 0.3),
      child: Center(
        child: Container(
          height: 1,
          width: context.calculatedMaxWidth * 0.3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                context.theme.colorScheme.outline.withValues(alpha: 0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
