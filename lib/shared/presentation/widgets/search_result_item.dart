import 'package:flutter/material.dart';
import '../../../features/chat/presentation/providers/chat_search_providers.dart';
import '../../../features/chat/data/repositories/conversation_repository.dart';
import '../design_system/design_constants.dart';

// 消息搜索结果项
class MessageSearchResultItem extends StatelessWidget {
  final MessageSearchResult result;
  final String searchQuery;
  final VoidCallback? onTap;

  const MessageSearchResultItem({
    super.key,
    required this.result,
    required this.searchQuery,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceL,
        vertical: DesignConstants.spaceXS,
      ),
      child: InkWell(
        borderRadius: DesignConstants.radiusM,
        onTap: onTap,
        child: Padding(
          padding: DesignConstants.paddingL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 对话标题和时间
              Row(
                children: [
                  Expanded(
                    child: Text(
                      result.conversationTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatTime(result.message.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              SizedBox(height: DesignConstants.spaceS),

              // 消息内容（高亮关键词）
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: _highlightSearchQuery(
                    result.message.content,
                    searchQuery,
                    context,
                  ),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: DesignConstants.spaceS),

              // 作者信息
              Row(
                children: [
                  Icon(
                    result.message.isFromUser ? Icons.person : Icons.smart_toy,
                    size: DesignConstants.iconSizeS,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: DesignConstants.spaceXS),
                  Text(
                    result.message.isFromUser ? '用户' : result.message.author,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  List<TextSpan> _highlightSearchQuery(
    String text,
    String query,
    BuildContext context,
  ) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return [TextSpan(text: text)];
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final int matchIndex = lowerText.indexOf(lowerQuery, start);
      if (matchIndex == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (matchIndex > start) {
        spans.add(TextSpan(text: text.substring(start, matchIndex)));
      }

      spans.add(
        TextSpan(
          text: text.substring(matchIndex, matchIndex + query.length),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      );

      start = matchIndex + query.length;
    }

    return spans;
  }
}

// 对话搜索结果项
class ConversationSearchResultItem extends StatelessWidget {
  final ConversationSearchResult result;
  final String searchQuery;
  final VoidCallback? onTap;

  const ConversationSearchResultItem({
    super.key,
    required this.result,
    required this.searchQuery,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceL,
        vertical: DesignConstants.spaceXS,
      ),
      child: InkWell(
        borderRadius: DesignConstants.radiusM,
        onTap: onTap,
        child: Padding(
          padding: DesignConstants.paddingL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 对话标题（高亮关键词）
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  children: _highlightSearchQuery(
                    result.title,
                    searchQuery,
                    context,
                  ),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: DesignConstants.spaceS),

              // 助手信息和消息数量
              Row(
                children: [
                  Icon(
                    Icons.smart_toy,
                    size: DesignConstants.iconSizeS,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: DesignConstants.spaceXS),
                  Text(
                    result.assistantName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignConstants.spaceS,
                      vertical: DesignConstants.spaceXS / 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: DesignConstants.radiusM,
                    ),
                    child: Text(
                      '${result.messageCount} 条消息',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontSize: 10,
                          ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: DesignConstants.spaceXS),

              // 最后消息时间
              Text(
                '最后活动: ${_formatTime(result.lastMessageAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  List<TextSpan> _highlightSearchQuery(
    String text,
    String query,
    BuildContext context,
  ) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return [TextSpan(text: text)];
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final int matchIndex = lowerText.indexOf(lowerQuery, start);
      if (matchIndex == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (matchIndex > start) {
        spans.add(TextSpan(text: text.substring(start, matchIndex)));
      }

      spans.add(
        TextSpan(
          text: text.substring(matchIndex, matchIndex + query.length),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      );

      start = matchIndex + query.length;
    }

    return spans;
  }
}
