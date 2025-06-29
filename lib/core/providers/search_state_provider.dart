import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/search_state.dart';
import '../services/search_service.dart';

/// Search state notifier
///
/// Manages search functionality including content search, navigation, and highlighting.
/// Inspired by Cherry Studio's ContentSearch but adapted for Riverpod with better performance.
class SearchStateNotifier extends StateNotifier<SearchState> {
  final Ref _ref;
  Timer? _searchDebounceTimer;
  StreamSubscription? _searchSubscription;

  SearchStateNotifier(this._ref) : super(const SearchState());

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchSubscription?.cancel();
    super.dispose();
  }

  // === Search Control ===

  /// Activate search mode
  void activateSearch() {
    state = state.copyWith(
      isSearchActive: true,
      completionState: SearchCompletionState.notStarted,
    );
  }

  /// Deactivate search mode and clear results
  void deactivateSearch() {
    _cancelCurrentSearch();
    state = state.copyWith(
      isSearchActive: false,
      isSearching: false,
      query: '',
      previousQuery: '',
      results: [],
      currentResultIndex: 0,
      totalResults: 0,
      highlightedElements: [],
      error: null,
      completionState: SearchCompletionState.notStarted,
    );
  }

  /// Update search query with debouncing
  void updateQuery(String query) {
    state = state.copyWith(
      query: query,
      showSuggestions: query.isNotEmpty,
    );

    // Cancel previous search timer
    _searchDebounceTimer?.cancel();

    if (query.trim().isEmpty) {
      _clearResults();
      return;
    }

    // Debounce search execution
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  /// Perform immediate search without debouncing
  Future<void> performImmediateSearch() async {
    _searchDebounceTimer?.cancel();
    await _performSearch();
  }

  /// Cancel current search
  void cancelSearch() {
    _cancelCurrentSearch();
    state = state.copyWith(
      isSearching: false,
      wasCancelled: true,
      completionState: SearchCompletionState.cancelled,
    );
  }

  // === Search Options ===

  /// Toggle case sensitivity
  void toggleCaseSensitive() {
    state = state.copyWith(isCaseSensitive: !state.isCaseSensitive);
    if (state.query.isNotEmpty) {
      _performSearch();
    }
  }

  /// Toggle whole word matching
  void toggleWholeWord() {
    state = state.copyWith(isWholeWord: !state.isWholeWord);
    if (state.query.isNotEmpty) {
      _performSearch();
    }
  }

  /// Toggle regex search
  void toggleRegex() {
    state = state.copyWith(useRegex: !state.useRegex);
    if (state.query.isNotEmpty) {
      _performSearch();
    }
  }

  /// Toggle include user messages
  void toggleIncludeUserMessages() {
    state = state.copyWith(includeUserMessages: !state.includeUserMessages);
    if (state.query.isNotEmpty) {
      _performSearch();
    }
  }

  /// Toggle include assistant messages
  void toggleIncludeAssistantMessages() {
    state = state.copyWith(
        includeAssistantMessages: !state.includeAssistantMessages);
    if (state.query.isNotEmpty) {
      _performSearch();
    }
  }

  // === Result Navigation ===

  /// Navigate to next search result
  void navigateToNext() {
    if (!state.canNavigateNext) return;

    final newIndex = state.currentResultIndex + 1;
    state = state.copyWith(currentResultIndex: newIndex);
    _updateHighlighting();
  }

  /// Navigate to previous search result
  void navigateToPrevious() {
    if (!state.canNavigatePrevious) return;

    final newIndex = state.currentResultIndex - 1;
    state = state.copyWith(currentResultIndex: newIndex);
    _updateHighlighting();
  }

  /// Navigate to specific result index
  void navigateToIndex(int index) {
    if (index < 0 || index >= state.results.length) return;

    state = state.copyWith(currentResultIndex: index);
    _updateHighlighting();
  }

  // === Search Filters ===

  /// Set conversation filter
  void setConversationFilter(String? conversationId) {
    state = state.copyWith(conversationFilter: conversationId);
    if (state.query.isNotEmpty) {
      _performSearch();
    }
  }

  /// Set date range filter
  void setDateFilter(DateRange? dateRange) {
    state = state.copyWith(dateFilter: dateRange);
    if (state.query.isNotEmpty) {
      _performSearch();
    }
  }

  /// Set message type filter
  void setMessageTypeFilter(MessageTypeFilter? filter) {
    state = state.copyWith(messageTypeFilter: filter);
    if (state.query.isNotEmpty) {
      _performSearch();
    }
  }

  // === Search History ===

  /// Add query to search history
  void _addToHistory(String query) {
    if (query.trim().isEmpty) return;

    final history = List<String>.from(state.searchHistory);

    // Remove if already exists
    history.remove(query);

    // Add to beginning
    history.insert(0, query);

    // Limit history size
    if (history.length > state.maxHistoryEntries) {
      history.removeRange(state.maxHistoryEntries, history.length);
    }

    state = state.copyWith(searchHistory: history);
  }

  /// Clear search history
  void clearHistory() {
    state = state.copyWith(searchHistory: []);
  }

  // === Auto-complete ===

  /// Update suggestions based on query
  void updateSuggestions(List<String> suggestions) {
    state = state.copyWith(
      suggestions: suggestions,
      showSuggestions: suggestions.isNotEmpty && state.query.isNotEmpty,
    );
  }

  /// Hide suggestions
  void hideSuggestions() {
    state = state.copyWith(showSuggestions: false);
  }

  // === Private Methods ===

  /// Perform the actual search
  Future<void> _performSearch() async {
    final query = state.query.trim();
    if (query.isEmpty) {
      _clearResults();
      return;
    }

    // Cancel any existing search
    _cancelCurrentSearch();

    // Update state to searching
    state = state.copyWith(
      isSearching: true,
      previousQuery: query,
      searchStartTime: DateTime.now(),
      wasCancelled: false,
      error: null,
      completionState: SearchCompletionState.inProgress,
    );

    try {
      final service = _ref.read(searchServiceProvider);
      final searchOptions = SearchOptions(
        query: query,
        caseSensitive: state.isCaseSensitive,
        wholeWord: state.isWholeWord,
        useRegex: state.useRegex,
        includeUserMessages: state.includeUserMessages,
        includeAssistantMessages: state.includeAssistantMessages,
        conversationFilter: state.conversationFilter,
        dateFilter: state.dateFilter,
        messageTypeFilter: state.messageTypeFilter,
        maxResults: state.resultsPerPage,
      );

      // Perform search
      final results = await service.searchMessages(searchOptions);

      // Calculate search duration
      final duration =
          DateTime.now().difference(state.searchStartTime!).inMilliseconds;

      // Update state with results
      state = state.copyWith(
        isSearching: false,
        results: results,
        totalResults: results.length,
        currentResultIndex: results.isNotEmpty ? 0 : -1,
        searchDurationMs: duration,
        completionState: SearchCompletionState.completed,
        totalSearches: state.totalSearches + 1,
        averageSearchDuration: _calculateAverageSearchDuration(duration),
      );

      // Add to history
      _addToHistory(query);

      // Update highlighting
      _updateHighlighting();

      // Update search term frequency
      _updateSearchTermFrequency(query);
    } catch (error) {
      final duration = state.searchStartTime != null
          ? DateTime.now().difference(state.searchStartTime!).inMilliseconds
          : 0;

      state = state.copyWith(
        isSearching: false,
        error: error.toString(),
        searchDurationMs: duration,
        completionState: SearchCompletionState.error,
      );
    }
  }

  /// Cancel current search operation
  void _cancelCurrentSearch() {
    _searchSubscription?.cancel();
    _searchSubscription = null;
  }

  /// Clear search results
  void _clearResults() {
    state = state.copyWith(
      results: [],
      totalResults: 0,
      currentResultIndex: 0,
      highlightedElements: [],
      completionState: SearchCompletionState.notStarted,
    );
  }

  /// Update highlighting for current result
  void _updateHighlighting() {
    if (!state.hasCurrentResult) {
      state = state.copyWith(highlightedElements: []);
      return;
    }

    final currentResult = state.currentResult!;
    final highlightedElements = [
      HighlightedElement(
        id: 'current-${currentResult.id}',
        messageId: currentResult.messageId,
        startIndex: currentResult.startIndex,
        endIndex: currentResult.endIndex,
        isActive: true,
        color: state.colorScheme.active,
      ),
    ];

    state = state.copyWith(highlightedElements: highlightedElements);
  }

  /// Calculate average search duration
  double _calculateAverageSearchDuration(int newDuration) {
    final totalSearches = state.totalSearches;
    if (totalSearches == 0) return newDuration.toDouble();

    return (state.averageSearchDuration * totalSearches + newDuration) /
        (totalSearches + 1);
  }

  /// Update search term frequency
  void _updateSearchTermFrequency(String query) {
    final frequency = Map<String, int>.from(state.searchTermFrequency);
    frequency[query] = (frequency[query] ?? 0) + 1;
    state = state.copyWith(searchTermFrequency: frequency);
  }
}

/// Search state provider
final searchStateProvider =
    StateNotifierProvider<SearchStateNotifier, SearchState>(
  (ref) => SearchStateNotifier(ref),
);

// === Convenience Providers ===

/// Whether search is active
final isSearchActiveProvider = Provider<bool>((ref) {
  return ref.watch(searchStateProvider.select((state) => state.isSearchActive));
});

/// Whether search is in progress
final isSearchingProvider = Provider<bool>((ref) {
  return ref.watch(searchStateProvider.select((state) => state.isSearching));
});

/// Current search query
final searchQueryProvider = Provider<String>((ref) {
  return ref.watch(searchStateProvider.select((state) => state.query));
});

/// Search results count
final searchResultsCountProvider = Provider<int>((ref) {
  return ref.watch(searchStateProvider.select((state) => state.totalResults));
});

/// Whether search has results
final hasSearchResultsProvider = Provider<bool>((ref) {
  return ref.watch(searchStateProvider.select((state) => state.hasResults));
});

/// Current search result
final currentSearchResultProvider = Provider<SearchResult?>((ref) {
  return ref.watch(searchStateProvider.select((state) => state.currentResult));
});

/// Search results summary
final searchResultsSummaryProvider = Provider<String>((ref) {
  return ref.watch(searchStateProvider.select((state) => state.resultsSummary));
});

/// Current result position
final currentResultPositionProvider = Provider<String>((ref) {
  return ref.watch(
      searchStateProvider.select((state) => state.currentResultPosition));
});

/// Whether can navigate to previous result
final canNavigatePreviousProvider = Provider<bool>((ref) {
  return ref
      .watch(searchStateProvider.select((state) => state.canNavigatePrevious));
});

/// Whether can navigate to next result
final canNavigateNextProvider = Provider<bool>((ref) {
  return ref
      .watch(searchStateProvider.select((state) => state.canNavigateNext));
});

/// Search statistics
final searchStatisticsProvider = Provider<SearchStatistics>((ref) {
  return ref.watch(searchStateProvider.select((state) => state.statistics));
});

/// Highlighted elements for UI
final highlightedElementsProvider = Provider<List<HighlightedElement>>((ref) {
  return ref
      .watch(searchStateProvider.select((state) => state.highlightedElements));
});

/// Search suggestions
final searchSuggestionsProvider = Provider<List<String>>((ref) {
  return ref.watch(searchStateProvider.select((state) => state.suggestions));
});

/// Whether to show suggestions
final showSearchSuggestionsProvider = Provider<bool>((ref) {
  return ref
      .watch(searchStateProvider.select((state) => state.showSuggestions));
});
