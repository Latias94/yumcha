import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_state.freezed.dart';

/// Search state management
///
/// Manages content search functionality similar to Cherry Studio's ContentSearch component
/// but adapted for Riverpod state management with better performance and features.
@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    // === Search Status ===
    /// Whether search is currently active
    @Default(false) bool isSearchActive,

    /// Whether search is currently in progress
    @Default(false) bool isSearching,

    /// Current search query
    @Default('') String query,

    /// Previous search query for comparison
    @Default('') String previousQuery,

    // === Search Options ===
    /// Whether to include user messages in search
    @Default(true) bool includeUserMessages,

    /// Whether to include assistant messages in search
    @Default(true) bool includeAssistantMessages,

    /// Whether search is case sensitive
    @Default(false) bool isCaseSensitive,

    /// Whether to match whole words only
    @Default(false) bool isWholeWord,

    /// Whether to use regex search
    @Default(false) bool useRegex,

    // === Search Results ===
    /// All search results
    @Default([]) List<SearchResult> results,

    /// Currently highlighted result index
    @Default(0) int currentResultIndex,

    /// Total number of results
    @Default(0) int totalResults,

    /// Results per page for pagination
    @Default(50) int resultsPerPage,

    /// Current page number
    @Default(0) int currentPage,

    /// Whether there are more results to load
    @Default(false) bool hasMoreResults,

    // === Search Performance ===
    /// Search start time for performance tracking
    @Default(null) DateTime? searchStartTime,

    /// Search duration in milliseconds
    @Default(0) int searchDurationMs,

    /// Number of messages searched
    @Default(0) int messagesSearched,

    // === Search History ===
    /// Recent search queries
    @Default([]) List<String> searchHistory,

    /// Maximum search history entries
    @Default(20) int maxHistoryEntries,

    // === Search Filters ===
    /// Filter by conversation ID
    @Default(null) String? conversationFilter,

    /// Filter by date range
    @Default(null) DateRange? dateFilter,

    /// Filter by message type
    @Default(null) MessageTypeFilter? messageTypeFilter,

    // === Search State ===
    /// Search error message
    @Default(null) String? error,

    /// Whether search was cancelled
    @Default(false) bool wasCancelled,

    /// Search completion state
    @Default(SearchCompletionState.notStarted)
    SearchCompletionState completionState,

    // === Highlighting ===
    /// Currently highlighted elements for UI
    @Default([]) List<HighlightedElement> highlightedElements,

    /// Highlight color scheme
    @Default(HighlightColorScheme()) HighlightColorScheme colorScheme,

    // === Auto-complete ===
    /// Auto-complete suggestions
    @Default([]) List<String> suggestions,

    /// Whether to show suggestions
    @Default(false) bool showSuggestions,

    // === Search Analytics ===
    /// Total searches performed
    @Default(0) int totalSearches,

    /// Average search duration
    @Default(0.0) double averageSearchDuration,

    /// Most searched terms
    @Default({}) Map<String, int> searchTermFrequency,
  }) = _SearchState;

  const SearchState._();

  // === Computed Properties ===

  /// Whether search has results
  bool get hasResults => results.isNotEmpty;

  /// Whether search is ready to perform
  bool get canSearch => query.trim().isNotEmpty && !isSearching;

  /// Whether there is a current result
  bool get hasCurrentResult =>
      hasResults && currentResultIndex < results.length;

  /// Get current search result
  SearchResult? get currentResult =>
      hasCurrentResult ? results[currentResultIndex] : null;

  /// Whether can navigate to previous result
  bool get canNavigatePrevious => hasResults && currentResultIndex > 0;

  /// Whether can navigate to next result
  bool get canNavigateNext =>
      hasResults && currentResultIndex < results.length - 1;

  /// Search progress (0.0 to 1.0)
  double get searchProgress {
    if (!isSearching || messagesSearched == 0) return 0.0;
    // This would need to be calculated based on total messages to search
    return 1.0; // Simplified for now
  }

  /// Search results summary text
  String get resultsSummary {
    if (!hasResults) return 'No results';
    if (results.length == 1) return '1 result';
    return '${results.length} results';
  }

  /// Current result position text (e.g., "1 of 5")
  String get currentResultPosition {
    if (!hasResults) return '0/0';
    return '${currentResultIndex + 1}/${results.length}';
  }

  /// Whether search query has changed
  bool get queryChanged => query != previousQuery;

  /// Whether search is in a completed state
  bool get isCompleted =>
      completionState == SearchCompletionState.completed ||
      completionState == SearchCompletionState.cancelled ||
      completionState == SearchCompletionState.error;

  /// Get search statistics
  SearchStatistics get statistics => SearchStatistics(
        totalResults: totalResults,
        searchDurationMs: searchDurationMs,
        messagesSearched: messagesSearched,
        averageDuration: averageSearchDuration,
        totalSearches: totalSearches,
      );
}

/// Search result model
@freezed
class SearchResult with _$SearchResult {
  const factory SearchResult({
    /// Unique result ID
    required String id,

    /// Message ID that contains the match
    required String messageId,

    /// Conversation ID
    required String conversationId,

    /// Matched content
    required String content,

    /// Full message content for context
    required String fullContent,

    /// Match start position in content
    required int startIndex,

    /// Match end position in content
    required int endIndex,

    /// Context before the match
    @Default('') String beforeContext,

    /// Context after the match
    @Default('') String afterContext,

    /// Match score (relevance)
    @Default(1.0) double score,

    /// Whether this is from a user message
    @Default(false) bool isUserMessage,

    /// Message timestamp
    required DateTime timestamp,

    /// Additional metadata
    @Default({}) Map<String, dynamic> metadata,
  }) = _SearchResult;
}

/// Highlighted element for UI rendering
@freezed
class HighlightedElement with _$HighlightedElement {
  const factory HighlightedElement({
    /// Element ID
    required String id,

    /// Message ID
    required String messageId,

    /// Start position in message
    required int startIndex,

    /// End position in message
    required int endIndex,

    /// Whether this element is currently active
    @Default(false) bool isActive,

    /// Highlight color
    @Default(null) String? color,
  }) = _HighlightedElement;
}

/// Highlight color scheme
@freezed
class HighlightColorScheme with _$HighlightColorScheme {
  const factory HighlightColorScheme({
    /// Primary highlight color
    @Default('#FFD700') String primary,

    /// Secondary highlight color
    @Default('#FFA500') String secondary,

    /// Active highlight color
    @Default('#FF6347') String active,

    /// Text color on highlights
    @Default('#000000') String textColor,
  }) = _HighlightColorScheme;
}

/// Date range filter
@freezed
class DateRange with _$DateRange {
  const factory DateRange({
    /// Start date (inclusive)
    required DateTime start,

    /// End date (inclusive)
    required DateTime end,
  }) = _DateRange;
}

/// Message type filter
enum MessageTypeFilter {
  /// Only user messages
  userOnly,

  /// Only assistant messages
  assistantOnly,

  /// Only system messages
  systemOnly,

  /// All message types
  all,
}

/// Search completion state
enum SearchCompletionState {
  /// Search not started
  notStarted,

  /// Search in progress
  inProgress,

  /// Search completed successfully
  completed,

  /// Search was cancelled
  cancelled,

  /// Search failed with error
  error,
}

/// Search statistics
@freezed
class SearchStatistics with _$SearchStatistics {
  const factory SearchStatistics({
    /// Total results found
    required int totalResults,

    /// Search duration in milliseconds
    required int searchDurationMs,

    /// Number of messages searched
    required int messagesSearched,

    /// Average search duration
    required double averageDuration,

    /// Total searches performed
    required int totalSearches,
  }) = _SearchStatistics;
}
