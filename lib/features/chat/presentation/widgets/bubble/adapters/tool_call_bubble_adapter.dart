import 'package:flutter/material.dart';

import '../../../../domain/entities/message_block.dart';
import '../../../../domain/entities/message_block_type.dart';
import '../bubble_context.dart';
import 'bubble_block_adapter.dart';

/// 工具调用块气泡适配器
///
/// 负责在气泡中渲染工具调用类型的消息块
class ToolCallBubbleAdapter extends BubbleBlockAdapter {
  @override
  Widget buildInBubble(
    MessageBlock block,
    BubbleContext context, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: getResponsiveSpacing(context, 4.0),
      ),
      decoration: buildContainerDecoration(
        context,
        backgroundColor:
            context.theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderColor: context.theme.colorScheme.secondary.withValues(alpha: 0.3),
        borderRadius: 8.0,
      ),
      child: _buildToolCallContent(block, context),
    );
  }

  @override
  bool canHandleBlock(MessageBlockType type) {
    return type == MessageBlockType.tool;
  }

  @override
  List<MessageBlockType> get supportedTypes => [MessageBlockType.tool];

  /// 构建工具调用内容
  Widget _buildToolCallContent(MessageBlock block, BubbleContext context) {
    final toolData = _parseToolCallData(block);
    final isExpandable = _shouldBeExpandable(block);

    return Container(
      padding: EdgeInsets.all(getResponsiveSpacing(context, 12.0)),
      child: isExpandable
          ? _buildExpandableToolCall(toolData, context)
          : _buildSimpleToolCall(toolData, context),
    );
  }

  /// 构建可展开的工具调用
  Widget _buildExpandableToolCall(
      Map<String, dynamic> toolData, BubbleContext context) {
    return Theme(
      data: context.theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(getResponsiveSpacing(context, 6.0)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.theme.colorScheme.tertiaryContainer
                    .withValues(alpha: 0.8),
                context.theme.colorScheme.tertiaryContainer
                    .withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color:
                    context.theme.colorScheme.tertiary.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _getToolIcon(toolData['name']),
            size: getResponsiveSpacing(context, 18.0),
            color: context.theme.colorScheme.tertiary,
          ),
        ),
        title: Row(
          children: [
            Text(
              '🔧 ${toolData['name'] ?? '工具调用'}',
              style: TextStyle(
                fontSize: getResponsiveFontSize(context, 14.0),
                fontWeight: FontWeight.w600,
                color: context.theme.colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 8),
            _buildToolStatusBadge(toolData['status'], context),
          ],
        ),
        subtitle: Text(
          toolData['description'] ?? '点击查看工具调用详情',
          style: TextStyle(
            fontSize: getResponsiveFontSize(context, 12.0),
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        initiallyExpanded: false,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(getResponsiveSpacing(context, 8.0)),
            padding: EdgeInsets.all(getResponsiveSpacing(context, 12.0)),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: context.theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (toolData['parameters'] != null) ...[
                  _buildToolParameters(toolData['parameters'], context),
                  SizedBox(height: getResponsiveSpacing(context, 8.0)),
                ],
                if (toolData['result'] != null) ...[
                  _buildToolResult(toolData['result'], context),
                  SizedBox(height: getResponsiveSpacing(context, 8.0)),
                ],
                if (toolData['duration'] != null)
                  _buildExecutionTime(toolData['duration'], context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建简单的工具调用
  Widget _buildSimpleToolCall(
      Map<String, dynamic> toolData, BubbleContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(getResponsiveSpacing(context, 4.0)),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.tertiaryContainer
                    .withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Icon(
                _getToolIcon(toolData['name']),
                size: getResponsiveSpacing(context, 16.0),
                color: context.theme.colorScheme.tertiary,
              ),
            ),
            SizedBox(width: getResponsiveSpacing(context, 8.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '🔧 ${toolData['name'] ?? '工具调用'}',
                        style: TextStyle(
                          fontSize: getResponsiveFontSize(context, 12.0),
                          fontWeight: FontWeight.w600,
                          color: context.theme.colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildToolStatusBadge(toolData['status'], context),
                    ],
                  ),
                  if (toolData['description'] != null)
                    Text(
                      toolData['description'],
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(context, 11.0),
                        color: context.textColor.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (toolData['result'] != null) ...[
          SizedBox(height: getResponsiveSpacing(context, 8.0)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(getResponsiveSpacing(context, 8.0)),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Text(
              toolData['result'],
              style: TextStyle(
                fontSize: getResponsiveFontSize(context, 12.0),
                color: context.textColor.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 解析工具调用数据
  Map<String, dynamic> _parseToolCallData(MessageBlock block) {
    // 尝试从metadata中获取结构化数据
    final metadata = block.metadata ?? {};

    return {
      'name': metadata['toolName'] ?? metadata['name'] ?? '未知工具',
      'status': metadata['status'] ?? 'completed',
      'description': metadata['description'] ?? block.content,
      'parameters': metadata['parameters'],
      'result': metadata['result'] ?? block.content,
      'duration': metadata['duration'],
      'error': metadata['error'],
    };
  }

  /// 判断是否应该可展开
  bool _shouldBeExpandable(MessageBlock block) {
    final metadata = block.metadata ?? {};
    return metadata['parameters'] != null ||
        metadata['result'] != null ||
        (block.content?.length ?? 0) > 100;
  }

  /// 获取工具图标
  IconData _getToolIcon(String? toolName) {
    if (toolName == null) return Icons.build_outlined;

    switch (toolName.toLowerCase()) {
      case 'search':
      case 'web_search':
        return Icons.search_rounded;
      case 'calculator':
      case 'math':
        return Icons.calculate_rounded;
      case 'file':
      case 'file_read':
        return Icons.description_rounded;
      case 'image':
      case 'image_analysis':
        return Icons.image_rounded;
      case 'code':
      case 'code_execution':
        return Icons.code_rounded;
      case 'database':
      case 'sql':
        return Icons.storage_rounded;
      case 'api':
      case 'http':
        return Icons.api_rounded;
      default:
        return Icons.build_outlined;
    }
  }

  /// 构建工具状态标签
  Widget _buildToolStatusBadge(String? status, BubbleContext context) {
    if (status == null) return const SizedBox.shrink();

    Color badgeColor;
    String statusText;
    IconData? statusIcon;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        badgeColor = context.theme.colorScheme.primary;
        statusText = '成功';
        statusIcon = Icons.check_circle_outline;
        break;
      case 'running':
      case 'executing':
        badgeColor = context.theme.colorScheme.tertiary;
        statusText = '执行中';
        statusIcon = Icons.hourglass_empty;
        break;
      case 'failed':
      case 'error':
        badgeColor = context.theme.colorScheme.error;
        statusText = '失败';
        statusIcon = Icons.error_outline;
        break;
      default:
        badgeColor = context.theme.colorScheme.outline;
        statusText = status;
        statusIcon = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (statusIcon != null) ...[
            Icon(
              statusIcon,
              size: 10,
              color: badgeColor,
            ),
            const SizedBox(width: 2),
          ],
          Text(
            statusText,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建工具参数
  Widget _buildToolParameters(dynamic parameters, BubbleContext context) {
    if (parameters == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.settings_rounded,
              size: 12,
              color: context.theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              '参数',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            parameters.toString(),
            style: TextStyle(
              fontSize: 11,
              color: context.textColor.withValues(alpha: 0.8),
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  /// 构建工具结果
  Widget _buildToolResult(dynamic result, BubbleContext context) {
    if (result == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.output_rounded,
              size: 12,
              color: context.theme.colorScheme.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              '结果',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            result.toString(),
            style: TextStyle(
              fontSize: 11,
              color: context.textColor.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建执行时间
  Widget _buildExecutionTime(dynamic duration, BubbleContext context) {
    if (duration == null) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(
          Icons.timer_outlined,
          size: 12,
          color: context.theme.colorScheme.outline,
        ),
        const SizedBox(width: 4),
        Text(
          '执行时间: ${duration}ms',
          style: TextStyle(
            fontSize: 10,
            color: context.theme.colorScheme.outline,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  @override
  String get name => 'ToolCallBubbleAdapter';

  @override
  int get priority => AdapterPriority.normal;
}
