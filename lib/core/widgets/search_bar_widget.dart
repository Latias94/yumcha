import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/search_state_provider.dart';
import '../state/search_state.dart';
import '../../shared/presentation/design_system/design_constants.dart';

/// Search bar widget
///
/// Provides a search input with options and navigation controls.
/// Inspired by Cherry Studio's ContentSearch but adapted for Flutter.
class SearchBarWidget extends ConsumerStatefulWidget {
  const SearchBarWidget({
    super.key,
    this.onResultSelected,
    this.onClose,
  });

  /// Callback when a search result is selected
  final void Function(SearchResult result)? onResultSelected;

  /// Callback when search is closed
  final VoidCallback? onClose;

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    // Auto-focus when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSearchActive = ref.watch(isSearchActiveProvider);

    if (!isSearchActive) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSearchInput(theme),
          _buildSearchResults(theme),
        ],
      ),
    );
  }

  /// Build the search input with controls
  Widget _buildSearchInput(ThemeData theme) {
    final isSearching = ref.watch(isSearchingProvider);
    final currentPosition = ref.watch(currentResultPositionProvider);
    final canNavigatePrevious = ref.watch(canNavigatePreviousProvider);
    final canNavigateNext = ref.watch(canNavigateNextProvider);

    return Container(
      padding: DesignConstants.paddingM,
      child: Row(
        children: [
          // Search input
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search messages...',
                prefixIcon: isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: DesignConstants.radiusM,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (query) {
                ref.read(searchStateProvider.notifier).updateQuery(query);
              },
              onSubmitted: (query) {
                ref.read(searchStateProvider.notifier).performImmediateSearch();
              },
            ),
          ),

          SizedBox(width: DesignConstants.spaceM),

          // Search options
          _buildSearchOptions(theme),

          SizedBox(width: DesignConstants.spaceM),

          // Results counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: DesignConstants.radiusS,
            ),
            child: Text(
              currentPosition,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          SizedBox(width: DesignConstants.spaceS),

          // Navigation buttons
          IconButton(
            onPressed: canNavigatePrevious
                ? () =>
                    ref.read(searchStateProvider.notifier).navigateToPrevious()
                : null,
            icon: const Icon(Icons.keyboard_arrow_up),
            tooltip: 'Previous result',
          ),

          IconButton(
            onPressed: canNavigateNext
                ? () => ref.read(searchStateProvider.notifier).navigateToNext()
                : null,
            icon: const Icon(Icons.keyboard_arrow_down),
            tooltip: 'Next result',
          ),

          // Close button
          IconButton(
            onPressed: () {
              ref.read(searchStateProvider.notifier).deactivateSearch();
              widget.onClose?.call();
            },
            icon: const Icon(Icons.close),
            tooltip: 'Close search',
          ),
        ],
      ),
    );
  }

  /// Build search options menu
  Widget _buildSearchOptions(ThemeData theme) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.tune,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      tooltip: 'Search options',
      itemBuilder: (context) => [
        _buildOptionMenuItem(
          'case_sensitive',
          'Case sensitive',
          Icons.text_fields,
          ref.watch(
              searchStateProvider.select((state) => state.isCaseSensitive)),
        ),
        _buildOptionMenuItem(
          'whole_word',
          'Whole word',
          Icons.crop_free,
          ref.watch(searchStateProvider.select((state) => state.isWholeWord)),
        ),
        _buildOptionMenuItem(
          'regex',
          'Regular expression',
          Icons.code,
          ref.watch(searchStateProvider.select((state) => state.useRegex)),
        ),
        const PopupMenuDivider(),
        _buildOptionMenuItem(
          'include_user',
          'Include user messages',
          Icons.person,
          ref.watch(
              searchStateProvider.select((state) => state.includeUserMessages)),
        ),
        _buildOptionMenuItem(
          'include_assistant',
          'Include assistant messages',
          Icons.smart_toy,
          ref.watch(searchStateProvider
              .select((state) => state.includeAssistantMessages)),
        ),
      ],
      onSelected: _handleSearchOption,
    );
  }

  /// Build option menu item
  PopupMenuItem<String> _buildOptionMenuItem(
    String value,
    String label,
    IconData icon,
    bool isSelected,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.blue : null,
          ),
          SizedBox(width: DesignConstants.spaceS),
          Text(label),
          const Spacer(),
          if (isSelected)
            Icon(
              Icons.check,
              size: 16,
              color: Colors.blue,
            ),
        ],
      ),
    );
  }

  /// Build search results preview
  Widget _buildSearchResults(ThemeData theme) {
    final hasResults = ref.watch(hasSearchResultsProvider);
    final currentResult = ref.watch(currentSearchResultProvider);
    final resultsSummary = ref.watch(searchResultsSummaryProvider);

    if (!hasResults) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results summary
          Row(
            children: [
              Icon(
                Icons.search,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: DesignConstants.spaceS),
              Text(
                resultsSummary,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          if (currentResult != null) ...[
            SizedBox(height: DesignConstants.spaceS),
            _buildCurrentResultPreview(theme, currentResult),
          ],
        ],
      ),
    );
  }

  /// Build current result preview
  Widget _buildCurrentResultPreview(ThemeData theme, SearchResult result) {
    return Container(
      padding: DesignConstants.paddingS,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: DesignConstants.radiusS,
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message info
          Row(
            children: [
              Icon(
                result.isUserMessage ? Icons.person : Icons.smart_toy,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: DesignConstants.spaceS),
              Text(
                result.isUserMessage ? 'User' : 'Assistant',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                _formatTimestamp(result.timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          SizedBox(height: DesignConstants.spaceS),

          // Content preview with highlighting
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                if (result.beforeContext.isNotEmpty)
                  TextSpan(
                    text: result.beforeContext,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                TextSpan(
                  text: result.content,
                  style: TextStyle(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (result.afterContext.isNotEmpty)
                  TextSpan(
                    text: result.afterContext,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: DesignConstants.spaceS),

          // Action button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                widget.onResultSelected?.call(result);
              },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Go to message'),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === Event Handlers ===

  void _handleSearchOption(String option) {
    final notifier = ref.read(searchStateProvider.notifier);

    switch (option) {
      case 'case_sensitive':
        notifier.toggleCaseSensitive();
        break;
      case 'whole_word':
        notifier.toggleWholeWord();
        break;
      case 'regex':
        notifier.toggleRegex();
        break;
      case 'include_user':
        notifier.toggleIncludeUserMessages();
        break;
      case 'include_assistant':
        notifier.toggleIncludeAssistantMessages();
        break;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Search activation button
class SearchActivationButton extends ConsumerWidget {
  const SearchActivationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSearchActive = ref.watch(isSearchActiveProvider);

    return IconButton(
      onPressed: isSearchActive
          ? null
          : () => ref.read(searchStateProvider.notifier).activateSearch(),
      icon: const Icon(Icons.search),
      tooltip: 'Search messages (Ctrl+F)',
    );
  }
}
