import 'package:flutter/material.dart';

import '../../../../domain/entities/message_block.dart';
import '../../../../domain/entities/message_block_type.dart';
import '../bubble_context.dart';
import 'bubble_block_adapter.dart';

/// 引用块气泡适配器
///
/// 负责在气泡中渲染引用类型的消息块
class QuoteBubbleAdapter extends BubbleBlockAdapter {
  @override
  Widget buildInBubble(
    MessageBlock block,
    BubbleContext context, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    if (!block.hasContent) {
      return buildEmptyWidget(context, message: '引用内容为空');
    }

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: getResponsiveSpacing(context, 4.0),
      ),
      child: _buildQuoteContent(block, context),
    );
  }

  @override
  bool canHandleBlock(MessageBlockType type) {
    return type == MessageBlockType.citation;
  }

  @override
  List<MessageBlockType> get supportedTypes => [MessageBlockType.citation];

  /// 构建引用内容
  Widget _buildQuoteContent(MessageBlock block, BubbleContext context) {
    final citationData = _parseCitationData(block);
    final isSearchResult = citationData['type'] == 'search_result';

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: getResponsiveSpacing(context, 4.0),
      ),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: context.theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: context.theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isSearchResult
          ? _buildSearchResult(citationData, context)
          : _buildSimpleCitation(citationData, context),
    );
  }

  /// 构建搜索结果样式
  Widget _buildSearchResult(Map<String, dynamic> data, BubbleContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 搜索结果头部
        Container(
          padding: EdgeInsets.all(getResponsiveSpacing(context, 12.0)),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.primaryContainer
                .withValues(alpha: 0.3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(getResponsiveSpacing(context, 6.0)),
                decoration: BoxDecoration(
                  color:
                      context.theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  Icons.search_rounded,
                  size: getResponsiveSpacing(context, 16.0),
                  color: context.theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: getResponsiveSpacing(context, 8.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] ?? '搜索结果',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(context, 14.0),
                        fontWeight: FontWeight.w600,
                        color: context.theme.colorScheme.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (data['url'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        data['url'],
                        style: TextStyle(
                          fontSize: getResponsiveFontSize(context, 11.0),
                          color: context.theme.colorScheme.primary
                              .withValues(alpha: 0.7),
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (data['confidence'] != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(data['confidence'], context)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _getConfidenceColor(data['confidence'], context)
                          .withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    '${(data['confidence'] * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: _getConfidenceColor(data['confidence'], context),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // 搜索结果内容
        Container(
          padding: EdgeInsets.all(getResponsiveSpacing(context, 12.0)),
          child: Text(
            data['content'] ?? '',
            style: TextStyle(
              fontSize: getResponsiveFontSize(context, 13.0),
              color: context.textColor.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
        ),
        // 搜索结果底部信息
        if (data['timestamp'] != null || data['source'] != null)
          Container(
            padding: EdgeInsets.fromLTRB(
              getResponsiveSpacing(context, 12.0),
              0,
              getResponsiveSpacing(context, 12.0),
              getResponsiveSpacing(context, 8.0),
            ),
            child: Row(
              children: [
                if (data['source'] != null) ...[
                  Icon(
                    Icons.source_rounded,
                    size: 12,
                    color: context.theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    data['source'],
                    style: TextStyle(
                      fontSize: 10,
                      color: context.theme.colorScheme.outline,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const Spacer(),
                if (data['timestamp'] != null)
                  Text(
                    data['timestamp'],
                    style: TextStyle(
                      fontSize: 10,
                      color: context.theme.colorScheme.outline,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  /// 构建简单引用样式
  Widget _buildSimpleCitation(
      Map<String, dynamic> data, BubbleContext context) {
    return Container(
      padding: EdgeInsets.all(getResponsiveSpacing(context, 12.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: context.theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: getResponsiveSpacing(context, 12.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data['title'] != null) ...[
                  Text(
                    data['title'],
                    style: TextStyle(
                      fontSize: getResponsiveFontSize(context, 13.0),
                      fontWeight: FontWeight.w600,
                      color: context.theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: getResponsiveSpacing(context, 4.0)),
                ],
                Text(
                  data['content'] ?? '',
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(context, 13.0),
                    color: context.textColor.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                if (data['source'] != null) ...[
                  SizedBox(height: getResponsiveSpacing(context, 4.0)),
                  Text(
                    '— ${data['source']}',
                    style: TextStyle(
                      fontSize: getResponsiveFontSize(context, 11.0),
                      color: context.theme.colorScheme.outline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 解析引用数据
  Map<String, dynamic> _parseCitationData(MessageBlock block) {
    final metadata = block.metadata ?? {};

    return {
      'type': metadata['type'] ?? 'citation',
      'title': metadata['title'],
      'content': block.content ?? '',
      'url': metadata['url'],
      'source': metadata['source'],
      'confidence': metadata['confidence'],
      'timestamp': metadata['timestamp'],
    };
  }

  /// 获取置信度颜色
  Color _getConfidenceColor(double confidence, BubbleContext context) {
    if (confidence >= 0.8) {
      return context.theme.colorScheme.primary;
    } else if (confidence >= 0.6) {
      return context.theme.colorScheme.tertiary;
    } else {
      return context.theme.colorScheme.error;
    }
  }

  @override
  String get name => 'QuoteBubbleAdapter';

  @override
  int get priority => AdapterPriority.normal;
}
