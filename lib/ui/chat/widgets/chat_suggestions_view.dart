import 'package:flutter/material.dart';

/// 聊天建议显示组件
class ChatSuggestionsView extends StatelessWidget {
  const ChatSuggestionsView({
    super.key,
    required this.suggestions,
    required this.onSelectSuggestion,
  });

  /// 建议列表
  final List<String> suggestions;

  /// 选择建议回调
  final void Function(String suggestion) onSelectSuggestion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '推荐话题',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((suggestion) {
            return _buildSuggestionChip(context, suggestion, theme);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(
    BuildContext context,
    String suggestion,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ActionChip(
        label: Text(
          suggestion,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        onPressed: () => onSelectSuggestion(suggestion),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
