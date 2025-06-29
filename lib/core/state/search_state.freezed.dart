// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SearchState {
// === Search Status ===
  /// Whether search is currently active
  bool get isSearchActive => throw _privateConstructorUsedError;

  /// Whether search is currently in progress
  bool get isSearching => throw _privateConstructorUsedError;

  /// Current search query
  String get query => throw _privateConstructorUsedError;

  /// Previous search query for comparison
  String get previousQuery =>
      throw _privateConstructorUsedError; // === Search Options ===
  /// Whether to include user messages in search
  bool get includeUserMessages => throw _privateConstructorUsedError;

  /// Whether to include assistant messages in search
  bool get includeAssistantMessages => throw _privateConstructorUsedError;

  /// Whether search is case sensitive
  bool get isCaseSensitive => throw _privateConstructorUsedError;

  /// Whether to match whole words only
  bool get isWholeWord => throw _privateConstructorUsedError;

  /// Whether to use regex search
  bool get useRegex =>
      throw _privateConstructorUsedError; // === Search Results ===
  /// All search results
  List<SearchResult> get results => throw _privateConstructorUsedError;

  /// Currently highlighted result index
  int get currentResultIndex => throw _privateConstructorUsedError;

  /// Total number of results
  int get totalResults => throw _privateConstructorUsedError;

  /// Results per page for pagination
  int get resultsPerPage => throw _privateConstructorUsedError;

  /// Current page number
  int get currentPage => throw _privateConstructorUsedError;

  /// Whether there are more results to load
  bool get hasMoreResults =>
      throw _privateConstructorUsedError; // === Search Performance ===
  /// Search start time for performance tracking
  DateTime? get searchStartTime => throw _privateConstructorUsedError;

  /// Search duration in milliseconds
  int get searchDurationMs => throw _privateConstructorUsedError;

  /// Number of messages searched
  int get messagesSearched =>
      throw _privateConstructorUsedError; // === Search History ===
  /// Recent search queries
  List<String> get searchHistory => throw _privateConstructorUsedError;

  /// Maximum search history entries
  int get maxHistoryEntries =>
      throw _privateConstructorUsedError; // === Search Filters ===
  /// Filter by conversation ID
  String? get conversationFilter => throw _privateConstructorUsedError;

  /// Filter by date range
  DateRange? get dateFilter => throw _privateConstructorUsedError;

  /// Filter by message type
  MessageTypeFilter? get messageTypeFilter =>
      throw _privateConstructorUsedError; // === Search State ===
  /// Search error message
  String? get error => throw _privateConstructorUsedError;

  /// Whether search was cancelled
  bool get wasCancelled => throw _privateConstructorUsedError;

  /// Search completion state
  SearchCompletionState get completionState =>
      throw _privateConstructorUsedError; // === Highlighting ===
  /// Currently highlighted elements for UI
  List<HighlightedElement> get highlightedElements =>
      throw _privateConstructorUsedError;

  /// Highlight color scheme
  HighlightColorScheme get colorScheme =>
      throw _privateConstructorUsedError; // === Auto-complete ===
  /// Auto-complete suggestions
  List<String> get suggestions => throw _privateConstructorUsedError;

  /// Whether to show suggestions
  bool get showSuggestions =>
      throw _privateConstructorUsedError; // === Search Analytics ===
  /// Total searches performed
  int get totalSearches => throw _privateConstructorUsedError;

  /// Average search duration
  double get averageSearchDuration => throw _privateConstructorUsedError;

  /// Most searched terms
  Map<String, int> get searchTermFrequency =>
      throw _privateConstructorUsedError;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchStateCopyWith<SearchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchStateCopyWith<$Res> {
  factory $SearchStateCopyWith(
          SearchState value, $Res Function(SearchState) then) =
      _$SearchStateCopyWithImpl<$Res, SearchState>;
  @useResult
  $Res call(
      {bool isSearchActive,
      bool isSearching,
      String query,
      String previousQuery,
      bool includeUserMessages,
      bool includeAssistantMessages,
      bool isCaseSensitive,
      bool isWholeWord,
      bool useRegex,
      List<SearchResult> results,
      int currentResultIndex,
      int totalResults,
      int resultsPerPage,
      int currentPage,
      bool hasMoreResults,
      DateTime? searchStartTime,
      int searchDurationMs,
      int messagesSearched,
      List<String> searchHistory,
      int maxHistoryEntries,
      String? conversationFilter,
      DateRange? dateFilter,
      MessageTypeFilter? messageTypeFilter,
      String? error,
      bool wasCancelled,
      SearchCompletionState completionState,
      List<HighlightedElement> highlightedElements,
      HighlightColorScheme colorScheme,
      List<String> suggestions,
      bool showSuggestions,
      int totalSearches,
      double averageSearchDuration,
      Map<String, int> searchTermFrequency});

  $DateRangeCopyWith<$Res>? get dateFilter;
  $HighlightColorSchemeCopyWith<$Res> get colorScheme;
}

/// @nodoc
class _$SearchStateCopyWithImpl<$Res, $Val extends SearchState>
    implements $SearchStateCopyWith<$Res> {
  _$SearchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSearchActive = null,
    Object? isSearching = null,
    Object? query = null,
    Object? previousQuery = null,
    Object? includeUserMessages = null,
    Object? includeAssistantMessages = null,
    Object? isCaseSensitive = null,
    Object? isWholeWord = null,
    Object? useRegex = null,
    Object? results = null,
    Object? currentResultIndex = null,
    Object? totalResults = null,
    Object? resultsPerPage = null,
    Object? currentPage = null,
    Object? hasMoreResults = null,
    Object? searchStartTime = freezed,
    Object? searchDurationMs = null,
    Object? messagesSearched = null,
    Object? searchHistory = null,
    Object? maxHistoryEntries = null,
    Object? conversationFilter = freezed,
    Object? dateFilter = freezed,
    Object? messageTypeFilter = freezed,
    Object? error = freezed,
    Object? wasCancelled = null,
    Object? completionState = null,
    Object? highlightedElements = null,
    Object? colorScheme = null,
    Object? suggestions = null,
    Object? showSuggestions = null,
    Object? totalSearches = null,
    Object? averageSearchDuration = null,
    Object? searchTermFrequency = null,
  }) {
    return _then(_value.copyWith(
      isSearchActive: null == isSearchActive
          ? _value.isSearchActive
          : isSearchActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isSearching: null == isSearching
          ? _value.isSearching
          : isSearching // ignore: cast_nullable_to_non_nullable
              as bool,
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      previousQuery: null == previousQuery
          ? _value.previousQuery
          : previousQuery // ignore: cast_nullable_to_non_nullable
              as String,
      includeUserMessages: null == includeUserMessages
          ? _value.includeUserMessages
          : includeUserMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      includeAssistantMessages: null == includeAssistantMessages
          ? _value.includeAssistantMessages
          : includeAssistantMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      isCaseSensitive: null == isCaseSensitive
          ? _value.isCaseSensitive
          : isCaseSensitive // ignore: cast_nullable_to_non_nullable
              as bool,
      isWholeWord: null == isWholeWord
          ? _value.isWholeWord
          : isWholeWord // ignore: cast_nullable_to_non_nullable
              as bool,
      useRegex: null == useRegex
          ? _value.useRegex
          : useRegex // ignore: cast_nullable_to_non_nullable
              as bool,
      results: null == results
          ? _value.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<SearchResult>,
      currentResultIndex: null == currentResultIndex
          ? _value.currentResultIndex
          : currentResultIndex // ignore: cast_nullable_to_non_nullable
              as int,
      totalResults: null == totalResults
          ? _value.totalResults
          : totalResults // ignore: cast_nullable_to_non_nullable
              as int,
      resultsPerPage: null == resultsPerPage
          ? _value.resultsPerPage
          : resultsPerPage // ignore: cast_nullable_to_non_nullable
              as int,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      hasMoreResults: null == hasMoreResults
          ? _value.hasMoreResults
          : hasMoreResults // ignore: cast_nullable_to_non_nullable
              as bool,
      searchStartTime: freezed == searchStartTime
          ? _value.searchStartTime
          : searchStartTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      searchDurationMs: null == searchDurationMs
          ? _value.searchDurationMs
          : searchDurationMs // ignore: cast_nullable_to_non_nullable
              as int,
      messagesSearched: null == messagesSearched
          ? _value.messagesSearched
          : messagesSearched // ignore: cast_nullable_to_non_nullable
              as int,
      searchHistory: null == searchHistory
          ? _value.searchHistory
          : searchHistory // ignore: cast_nullable_to_non_nullable
              as List<String>,
      maxHistoryEntries: null == maxHistoryEntries
          ? _value.maxHistoryEntries
          : maxHistoryEntries // ignore: cast_nullable_to_non_nullable
              as int,
      conversationFilter: freezed == conversationFilter
          ? _value.conversationFilter
          : conversationFilter // ignore: cast_nullable_to_non_nullable
              as String?,
      dateFilter: freezed == dateFilter
          ? _value.dateFilter
          : dateFilter // ignore: cast_nullable_to_non_nullable
              as DateRange?,
      messageTypeFilter: freezed == messageTypeFilter
          ? _value.messageTypeFilter
          : messageTypeFilter // ignore: cast_nullable_to_non_nullable
              as MessageTypeFilter?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      wasCancelled: null == wasCancelled
          ? _value.wasCancelled
          : wasCancelled // ignore: cast_nullable_to_non_nullable
              as bool,
      completionState: null == completionState
          ? _value.completionState
          : completionState // ignore: cast_nullable_to_non_nullable
              as SearchCompletionState,
      highlightedElements: null == highlightedElements
          ? _value.highlightedElements
          : highlightedElements // ignore: cast_nullable_to_non_nullable
              as List<HighlightedElement>,
      colorScheme: null == colorScheme
          ? _value.colorScheme
          : colorScheme // ignore: cast_nullable_to_non_nullable
              as HighlightColorScheme,
      suggestions: null == suggestions
          ? _value.suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      showSuggestions: null == showSuggestions
          ? _value.showSuggestions
          : showSuggestions // ignore: cast_nullable_to_non_nullable
              as bool,
      totalSearches: null == totalSearches
          ? _value.totalSearches
          : totalSearches // ignore: cast_nullable_to_non_nullable
              as int,
      averageSearchDuration: null == averageSearchDuration
          ? _value.averageSearchDuration
          : averageSearchDuration // ignore: cast_nullable_to_non_nullable
              as double,
      searchTermFrequency: null == searchTermFrequency
          ? _value.searchTermFrequency
          : searchTermFrequency // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ) as $Val);
  }

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DateRangeCopyWith<$Res>? get dateFilter {
    if (_value.dateFilter == null) {
      return null;
    }

    return $DateRangeCopyWith<$Res>(_value.dateFilter!, (value) {
      return _then(_value.copyWith(dateFilter: value) as $Val);
    });
  }

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HighlightColorSchemeCopyWith<$Res> get colorScheme {
    return $HighlightColorSchemeCopyWith<$Res>(_value.colorScheme, (value) {
      return _then(_value.copyWith(colorScheme: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SearchStateImplCopyWith<$Res>
    implements $SearchStateCopyWith<$Res> {
  factory _$$SearchStateImplCopyWith(
          _$SearchStateImpl value, $Res Function(_$SearchStateImpl) then) =
      __$$SearchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isSearchActive,
      bool isSearching,
      String query,
      String previousQuery,
      bool includeUserMessages,
      bool includeAssistantMessages,
      bool isCaseSensitive,
      bool isWholeWord,
      bool useRegex,
      List<SearchResult> results,
      int currentResultIndex,
      int totalResults,
      int resultsPerPage,
      int currentPage,
      bool hasMoreResults,
      DateTime? searchStartTime,
      int searchDurationMs,
      int messagesSearched,
      List<String> searchHistory,
      int maxHistoryEntries,
      String? conversationFilter,
      DateRange? dateFilter,
      MessageTypeFilter? messageTypeFilter,
      String? error,
      bool wasCancelled,
      SearchCompletionState completionState,
      List<HighlightedElement> highlightedElements,
      HighlightColorScheme colorScheme,
      List<String> suggestions,
      bool showSuggestions,
      int totalSearches,
      double averageSearchDuration,
      Map<String, int> searchTermFrequency});

  @override
  $DateRangeCopyWith<$Res>? get dateFilter;
  @override
  $HighlightColorSchemeCopyWith<$Res> get colorScheme;
}

/// @nodoc
class __$$SearchStateImplCopyWithImpl<$Res>
    extends _$SearchStateCopyWithImpl<$Res, _$SearchStateImpl>
    implements _$$SearchStateImplCopyWith<$Res> {
  __$$SearchStateImplCopyWithImpl(
      _$SearchStateImpl _value, $Res Function(_$SearchStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSearchActive = null,
    Object? isSearching = null,
    Object? query = null,
    Object? previousQuery = null,
    Object? includeUserMessages = null,
    Object? includeAssistantMessages = null,
    Object? isCaseSensitive = null,
    Object? isWholeWord = null,
    Object? useRegex = null,
    Object? results = null,
    Object? currentResultIndex = null,
    Object? totalResults = null,
    Object? resultsPerPage = null,
    Object? currentPage = null,
    Object? hasMoreResults = null,
    Object? searchStartTime = freezed,
    Object? searchDurationMs = null,
    Object? messagesSearched = null,
    Object? searchHistory = null,
    Object? maxHistoryEntries = null,
    Object? conversationFilter = freezed,
    Object? dateFilter = freezed,
    Object? messageTypeFilter = freezed,
    Object? error = freezed,
    Object? wasCancelled = null,
    Object? completionState = null,
    Object? highlightedElements = null,
    Object? colorScheme = null,
    Object? suggestions = null,
    Object? showSuggestions = null,
    Object? totalSearches = null,
    Object? averageSearchDuration = null,
    Object? searchTermFrequency = null,
  }) {
    return _then(_$SearchStateImpl(
      isSearchActive: null == isSearchActive
          ? _value.isSearchActive
          : isSearchActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isSearching: null == isSearching
          ? _value.isSearching
          : isSearching // ignore: cast_nullable_to_non_nullable
              as bool,
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      previousQuery: null == previousQuery
          ? _value.previousQuery
          : previousQuery // ignore: cast_nullable_to_non_nullable
              as String,
      includeUserMessages: null == includeUserMessages
          ? _value.includeUserMessages
          : includeUserMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      includeAssistantMessages: null == includeAssistantMessages
          ? _value.includeAssistantMessages
          : includeAssistantMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      isCaseSensitive: null == isCaseSensitive
          ? _value.isCaseSensitive
          : isCaseSensitive // ignore: cast_nullable_to_non_nullable
              as bool,
      isWholeWord: null == isWholeWord
          ? _value.isWholeWord
          : isWholeWord // ignore: cast_nullable_to_non_nullable
              as bool,
      useRegex: null == useRegex
          ? _value.useRegex
          : useRegex // ignore: cast_nullable_to_non_nullable
              as bool,
      results: null == results
          ? _value._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<SearchResult>,
      currentResultIndex: null == currentResultIndex
          ? _value.currentResultIndex
          : currentResultIndex // ignore: cast_nullable_to_non_nullable
              as int,
      totalResults: null == totalResults
          ? _value.totalResults
          : totalResults // ignore: cast_nullable_to_non_nullable
              as int,
      resultsPerPage: null == resultsPerPage
          ? _value.resultsPerPage
          : resultsPerPage // ignore: cast_nullable_to_non_nullable
              as int,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      hasMoreResults: null == hasMoreResults
          ? _value.hasMoreResults
          : hasMoreResults // ignore: cast_nullable_to_non_nullable
              as bool,
      searchStartTime: freezed == searchStartTime
          ? _value.searchStartTime
          : searchStartTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      searchDurationMs: null == searchDurationMs
          ? _value.searchDurationMs
          : searchDurationMs // ignore: cast_nullable_to_non_nullable
              as int,
      messagesSearched: null == messagesSearched
          ? _value.messagesSearched
          : messagesSearched // ignore: cast_nullable_to_non_nullable
              as int,
      searchHistory: null == searchHistory
          ? _value._searchHistory
          : searchHistory // ignore: cast_nullable_to_non_nullable
              as List<String>,
      maxHistoryEntries: null == maxHistoryEntries
          ? _value.maxHistoryEntries
          : maxHistoryEntries // ignore: cast_nullable_to_non_nullable
              as int,
      conversationFilter: freezed == conversationFilter
          ? _value.conversationFilter
          : conversationFilter // ignore: cast_nullable_to_non_nullable
              as String?,
      dateFilter: freezed == dateFilter
          ? _value.dateFilter
          : dateFilter // ignore: cast_nullable_to_non_nullable
              as DateRange?,
      messageTypeFilter: freezed == messageTypeFilter
          ? _value.messageTypeFilter
          : messageTypeFilter // ignore: cast_nullable_to_non_nullable
              as MessageTypeFilter?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      wasCancelled: null == wasCancelled
          ? _value.wasCancelled
          : wasCancelled // ignore: cast_nullable_to_non_nullable
              as bool,
      completionState: null == completionState
          ? _value.completionState
          : completionState // ignore: cast_nullable_to_non_nullable
              as SearchCompletionState,
      highlightedElements: null == highlightedElements
          ? _value._highlightedElements
          : highlightedElements // ignore: cast_nullable_to_non_nullable
              as List<HighlightedElement>,
      colorScheme: null == colorScheme
          ? _value.colorScheme
          : colorScheme // ignore: cast_nullable_to_non_nullable
              as HighlightColorScheme,
      suggestions: null == suggestions
          ? _value._suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      showSuggestions: null == showSuggestions
          ? _value.showSuggestions
          : showSuggestions // ignore: cast_nullable_to_non_nullable
              as bool,
      totalSearches: null == totalSearches
          ? _value.totalSearches
          : totalSearches // ignore: cast_nullable_to_non_nullable
              as int,
      averageSearchDuration: null == averageSearchDuration
          ? _value.averageSearchDuration
          : averageSearchDuration // ignore: cast_nullable_to_non_nullable
              as double,
      searchTermFrequency: null == searchTermFrequency
          ? _value._searchTermFrequency
          : searchTermFrequency // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

/// @nodoc

class _$SearchStateImpl extends _SearchState {
  const _$SearchStateImpl(
      {this.isSearchActive = false,
      this.isSearching = false,
      this.query = '',
      this.previousQuery = '',
      this.includeUserMessages = true,
      this.includeAssistantMessages = true,
      this.isCaseSensitive = false,
      this.isWholeWord = false,
      this.useRegex = false,
      final List<SearchResult> results = const [],
      this.currentResultIndex = 0,
      this.totalResults = 0,
      this.resultsPerPage = 50,
      this.currentPage = 0,
      this.hasMoreResults = false,
      this.searchStartTime = null,
      this.searchDurationMs = 0,
      this.messagesSearched = 0,
      final List<String> searchHistory = const [],
      this.maxHistoryEntries = 20,
      this.conversationFilter = null,
      this.dateFilter = null,
      this.messageTypeFilter = null,
      this.error = null,
      this.wasCancelled = false,
      this.completionState = SearchCompletionState.notStarted,
      final List<HighlightedElement> highlightedElements = const [],
      this.colorScheme = const HighlightColorScheme(),
      final List<String> suggestions = const [],
      this.showSuggestions = false,
      this.totalSearches = 0,
      this.averageSearchDuration = 0.0,
      final Map<String, int> searchTermFrequency = const {}})
      : _results = results,
        _searchHistory = searchHistory,
        _highlightedElements = highlightedElements,
        _suggestions = suggestions,
        _searchTermFrequency = searchTermFrequency,
        super._();

// === Search Status ===
  /// Whether search is currently active
  @override
  @JsonKey()
  final bool isSearchActive;

  /// Whether search is currently in progress
  @override
  @JsonKey()
  final bool isSearching;

  /// Current search query
  @override
  @JsonKey()
  final String query;

  /// Previous search query for comparison
  @override
  @JsonKey()
  final String previousQuery;
// === Search Options ===
  /// Whether to include user messages in search
  @override
  @JsonKey()
  final bool includeUserMessages;

  /// Whether to include assistant messages in search
  @override
  @JsonKey()
  final bool includeAssistantMessages;

  /// Whether search is case sensitive
  @override
  @JsonKey()
  final bool isCaseSensitive;

  /// Whether to match whole words only
  @override
  @JsonKey()
  final bool isWholeWord;

  /// Whether to use regex search
  @override
  @JsonKey()
  final bool useRegex;
// === Search Results ===
  /// All search results
  final List<SearchResult> _results;
// === Search Results ===
  /// All search results
  @override
  @JsonKey()
  List<SearchResult> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  /// Currently highlighted result index
  @override
  @JsonKey()
  final int currentResultIndex;

  /// Total number of results
  @override
  @JsonKey()
  final int totalResults;

  /// Results per page for pagination
  @override
  @JsonKey()
  final int resultsPerPage;

  /// Current page number
  @override
  @JsonKey()
  final int currentPage;

  /// Whether there are more results to load
  @override
  @JsonKey()
  final bool hasMoreResults;
// === Search Performance ===
  /// Search start time for performance tracking
  @override
  @JsonKey()
  final DateTime? searchStartTime;

  /// Search duration in milliseconds
  @override
  @JsonKey()
  final int searchDurationMs;

  /// Number of messages searched
  @override
  @JsonKey()
  final int messagesSearched;
// === Search History ===
  /// Recent search queries
  final List<String> _searchHistory;
// === Search History ===
  /// Recent search queries
  @override
  @JsonKey()
  List<String> get searchHistory {
    if (_searchHistory is EqualUnmodifiableListView) return _searchHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_searchHistory);
  }

  /// Maximum search history entries
  @override
  @JsonKey()
  final int maxHistoryEntries;
// === Search Filters ===
  /// Filter by conversation ID
  @override
  @JsonKey()
  final String? conversationFilter;

  /// Filter by date range
  @override
  @JsonKey()
  final DateRange? dateFilter;

  /// Filter by message type
  @override
  @JsonKey()
  final MessageTypeFilter? messageTypeFilter;
// === Search State ===
  /// Search error message
  @override
  @JsonKey()
  final String? error;

  /// Whether search was cancelled
  @override
  @JsonKey()
  final bool wasCancelled;

  /// Search completion state
  @override
  @JsonKey()
  final SearchCompletionState completionState;
// === Highlighting ===
  /// Currently highlighted elements for UI
  final List<HighlightedElement> _highlightedElements;
// === Highlighting ===
  /// Currently highlighted elements for UI
  @override
  @JsonKey()
  List<HighlightedElement> get highlightedElements {
    if (_highlightedElements is EqualUnmodifiableListView)
      return _highlightedElements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_highlightedElements);
  }

  /// Highlight color scheme
  @override
  @JsonKey()
  final HighlightColorScheme colorScheme;
// === Auto-complete ===
  /// Auto-complete suggestions
  final List<String> _suggestions;
// === Auto-complete ===
  /// Auto-complete suggestions
  @override
  @JsonKey()
  List<String> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  /// Whether to show suggestions
  @override
  @JsonKey()
  final bool showSuggestions;
// === Search Analytics ===
  /// Total searches performed
  @override
  @JsonKey()
  final int totalSearches;

  /// Average search duration
  @override
  @JsonKey()
  final double averageSearchDuration;

  /// Most searched terms
  final Map<String, int> _searchTermFrequency;

  /// Most searched terms
  @override
  @JsonKey()
  Map<String, int> get searchTermFrequency {
    if (_searchTermFrequency is EqualUnmodifiableMapView)
      return _searchTermFrequency;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_searchTermFrequency);
  }

  @override
  String toString() {
    return 'SearchState(isSearchActive: $isSearchActive, isSearching: $isSearching, query: $query, previousQuery: $previousQuery, includeUserMessages: $includeUserMessages, includeAssistantMessages: $includeAssistantMessages, isCaseSensitive: $isCaseSensitive, isWholeWord: $isWholeWord, useRegex: $useRegex, results: $results, currentResultIndex: $currentResultIndex, totalResults: $totalResults, resultsPerPage: $resultsPerPage, currentPage: $currentPage, hasMoreResults: $hasMoreResults, searchStartTime: $searchStartTime, searchDurationMs: $searchDurationMs, messagesSearched: $messagesSearched, searchHistory: $searchHistory, maxHistoryEntries: $maxHistoryEntries, conversationFilter: $conversationFilter, dateFilter: $dateFilter, messageTypeFilter: $messageTypeFilter, error: $error, wasCancelled: $wasCancelled, completionState: $completionState, highlightedElements: $highlightedElements, colorScheme: $colorScheme, suggestions: $suggestions, showSuggestions: $showSuggestions, totalSearches: $totalSearches, averageSearchDuration: $averageSearchDuration, searchTermFrequency: $searchTermFrequency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchStateImpl &&
            (identical(other.isSearchActive, isSearchActive) ||
                other.isSearchActive == isSearchActive) &&
            (identical(other.isSearching, isSearching) ||
                other.isSearching == isSearching) &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.previousQuery, previousQuery) ||
                other.previousQuery == previousQuery) &&
            (identical(other.includeUserMessages, includeUserMessages) ||
                other.includeUserMessages == includeUserMessages) &&
            (identical(
                    other.includeAssistantMessages, includeAssistantMessages) ||
                other.includeAssistantMessages == includeAssistantMessages) &&
            (identical(other.isCaseSensitive, isCaseSensitive) ||
                other.isCaseSensitive == isCaseSensitive) &&
            (identical(other.isWholeWord, isWholeWord) ||
                other.isWholeWord == isWholeWord) &&
            (identical(other.useRegex, useRegex) ||
                other.useRegex == useRegex) &&
            const DeepCollectionEquality().equals(other._results, _results) &&
            (identical(other.currentResultIndex, currentResultIndex) ||
                other.currentResultIndex == currentResultIndex) &&
            (identical(other.totalResults, totalResults) ||
                other.totalResults == totalResults) &&
            (identical(other.resultsPerPage, resultsPerPage) ||
                other.resultsPerPage == resultsPerPage) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.hasMoreResults, hasMoreResults) ||
                other.hasMoreResults == hasMoreResults) &&
            (identical(other.searchStartTime, searchStartTime) ||
                other.searchStartTime == searchStartTime) &&
            (identical(other.searchDurationMs, searchDurationMs) ||
                other.searchDurationMs == searchDurationMs) &&
            (identical(other.messagesSearched, messagesSearched) ||
                other.messagesSearched == messagesSearched) &&
            const DeepCollectionEquality()
                .equals(other._searchHistory, _searchHistory) &&
            (identical(other.maxHistoryEntries, maxHistoryEntries) ||
                other.maxHistoryEntries == maxHistoryEntries) &&
            (identical(other.conversationFilter, conversationFilter) ||
                other.conversationFilter == conversationFilter) &&
            (identical(other.dateFilter, dateFilter) ||
                other.dateFilter == dateFilter) &&
            (identical(other.messageTypeFilter, messageTypeFilter) ||
                other.messageTypeFilter == messageTypeFilter) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.wasCancelled, wasCancelled) ||
                other.wasCancelled == wasCancelled) &&
            (identical(other.completionState, completionState) ||
                other.completionState == completionState) &&
            const DeepCollectionEquality()
                .equals(other._highlightedElements, _highlightedElements) &&
            (identical(other.colorScheme, colorScheme) ||
                other.colorScheme == colorScheme) &&
            const DeepCollectionEquality()
                .equals(other._suggestions, _suggestions) &&
            (identical(other.showSuggestions, showSuggestions) ||
                other.showSuggestions == showSuggestions) &&
            (identical(other.totalSearches, totalSearches) ||
                other.totalSearches == totalSearches) &&
            (identical(other.averageSearchDuration, averageSearchDuration) ||
                other.averageSearchDuration == averageSearchDuration) &&
            const DeepCollectionEquality()
                .equals(other._searchTermFrequency, _searchTermFrequency));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        isSearchActive,
        isSearching,
        query,
        previousQuery,
        includeUserMessages,
        includeAssistantMessages,
        isCaseSensitive,
        isWholeWord,
        useRegex,
        const DeepCollectionEquality().hash(_results),
        currentResultIndex,
        totalResults,
        resultsPerPage,
        currentPage,
        hasMoreResults,
        searchStartTime,
        searchDurationMs,
        messagesSearched,
        const DeepCollectionEquality().hash(_searchHistory),
        maxHistoryEntries,
        conversationFilter,
        dateFilter,
        messageTypeFilter,
        error,
        wasCancelled,
        completionState,
        const DeepCollectionEquality().hash(_highlightedElements),
        colorScheme,
        const DeepCollectionEquality().hash(_suggestions),
        showSuggestions,
        totalSearches,
        averageSearchDuration,
        const DeepCollectionEquality().hash(_searchTermFrequency)
      ]);

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      __$$SearchStateImplCopyWithImpl<_$SearchStateImpl>(this, _$identity);
}

abstract class _SearchState extends SearchState {
  const factory _SearchState(
      {final bool isSearchActive,
      final bool isSearching,
      final String query,
      final String previousQuery,
      final bool includeUserMessages,
      final bool includeAssistantMessages,
      final bool isCaseSensitive,
      final bool isWholeWord,
      final bool useRegex,
      final List<SearchResult> results,
      final int currentResultIndex,
      final int totalResults,
      final int resultsPerPage,
      final int currentPage,
      final bool hasMoreResults,
      final DateTime? searchStartTime,
      final int searchDurationMs,
      final int messagesSearched,
      final List<String> searchHistory,
      final int maxHistoryEntries,
      final String? conversationFilter,
      final DateRange? dateFilter,
      final MessageTypeFilter? messageTypeFilter,
      final String? error,
      final bool wasCancelled,
      final SearchCompletionState completionState,
      final List<HighlightedElement> highlightedElements,
      final HighlightColorScheme colorScheme,
      final List<String> suggestions,
      final bool showSuggestions,
      final int totalSearches,
      final double averageSearchDuration,
      final Map<String, int> searchTermFrequency}) = _$SearchStateImpl;
  const _SearchState._() : super._();

// === Search Status ===
  /// Whether search is currently active
  @override
  bool get isSearchActive;

  /// Whether search is currently in progress
  @override
  bool get isSearching;

  /// Current search query
  @override
  String get query;

  /// Previous search query for comparison
  @override
  String get previousQuery; // === Search Options ===
  /// Whether to include user messages in search
  @override
  bool get includeUserMessages;

  /// Whether to include assistant messages in search
  @override
  bool get includeAssistantMessages;

  /// Whether search is case sensitive
  @override
  bool get isCaseSensitive;

  /// Whether to match whole words only
  @override
  bool get isWholeWord;

  /// Whether to use regex search
  @override
  bool get useRegex; // === Search Results ===
  /// All search results
  @override
  List<SearchResult> get results;

  /// Currently highlighted result index
  @override
  int get currentResultIndex;

  /// Total number of results
  @override
  int get totalResults;

  /// Results per page for pagination
  @override
  int get resultsPerPage;

  /// Current page number
  @override
  int get currentPage;

  /// Whether there are more results to load
  @override
  bool get hasMoreResults; // === Search Performance ===
  /// Search start time for performance tracking
  @override
  DateTime? get searchStartTime;

  /// Search duration in milliseconds
  @override
  int get searchDurationMs;

  /// Number of messages searched
  @override
  int get messagesSearched; // === Search History ===
  /// Recent search queries
  @override
  List<String> get searchHistory;

  /// Maximum search history entries
  @override
  int get maxHistoryEntries; // === Search Filters ===
  /// Filter by conversation ID
  @override
  String? get conversationFilter;

  /// Filter by date range
  @override
  DateRange? get dateFilter;

  /// Filter by message type
  @override
  MessageTypeFilter? get messageTypeFilter; // === Search State ===
  /// Search error message
  @override
  String? get error;

  /// Whether search was cancelled
  @override
  bool get wasCancelled;

  /// Search completion state
  @override
  SearchCompletionState get completionState; // === Highlighting ===
  /// Currently highlighted elements for UI
  @override
  List<HighlightedElement> get highlightedElements;

  /// Highlight color scheme
  @override
  HighlightColorScheme get colorScheme; // === Auto-complete ===
  /// Auto-complete suggestions
  @override
  List<String> get suggestions;

  /// Whether to show suggestions
  @override
  bool get showSuggestions; // === Search Analytics ===
  /// Total searches performed
  @override
  int get totalSearches;

  /// Average search duration
  @override
  double get averageSearchDuration;

  /// Most searched terms
  @override
  Map<String, int> get searchTermFrequency;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SearchResult {
  /// Unique result ID
  String get id => throw _privateConstructorUsedError;

  /// Message ID that contains the match
  String get messageId => throw _privateConstructorUsedError;

  /// Conversation ID
  String get conversationId => throw _privateConstructorUsedError;

  /// Matched content
  String get content => throw _privateConstructorUsedError;

  /// Full message content for context
  String get fullContent => throw _privateConstructorUsedError;

  /// Match start position in content
  int get startIndex => throw _privateConstructorUsedError;

  /// Match end position in content
  int get endIndex => throw _privateConstructorUsedError;

  /// Context before the match
  String get beforeContext => throw _privateConstructorUsedError;

  /// Context after the match
  String get afterContext => throw _privateConstructorUsedError;

  /// Match score (relevance)
  double get score => throw _privateConstructorUsedError;

  /// Whether this is from a user message
  bool get isUserMessage => throw _privateConstructorUsedError;

  /// Message timestamp
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Additional metadata
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchResultCopyWith<SearchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchResultCopyWith<$Res> {
  factory $SearchResultCopyWith(
          SearchResult value, $Res Function(SearchResult) then) =
      _$SearchResultCopyWithImpl<$Res, SearchResult>;
  @useResult
  $Res call(
      {String id,
      String messageId,
      String conversationId,
      String content,
      String fullContent,
      int startIndex,
      int endIndex,
      String beforeContext,
      String afterContext,
      double score,
      bool isUserMessage,
      DateTime timestamp,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$SearchResultCopyWithImpl<$Res, $Val extends SearchResult>
    implements $SearchResultCopyWith<$Res> {
  _$SearchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messageId = null,
    Object? conversationId = null,
    Object? content = null,
    Object? fullContent = null,
    Object? startIndex = null,
    Object? endIndex = null,
    Object? beforeContext = null,
    Object? afterContext = null,
    Object? score = null,
    Object? isUserMessage = null,
    Object? timestamp = null,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      fullContent: null == fullContent
          ? _value.fullContent
          : fullContent // ignore: cast_nullable_to_non_nullable
              as String,
      startIndex: null == startIndex
          ? _value.startIndex
          : startIndex // ignore: cast_nullable_to_non_nullable
              as int,
      endIndex: null == endIndex
          ? _value.endIndex
          : endIndex // ignore: cast_nullable_to_non_nullable
              as int,
      beforeContext: null == beforeContext
          ? _value.beforeContext
          : beforeContext // ignore: cast_nullable_to_non_nullable
              as String,
      afterContext: null == afterContext
          ? _value.afterContext
          : afterContext // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      isUserMessage: null == isUserMessage
          ? _value.isUserMessage
          : isUserMessage // ignore: cast_nullable_to_non_nullable
              as bool,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchResultImplCopyWith<$Res>
    implements $SearchResultCopyWith<$Res> {
  factory _$$SearchResultImplCopyWith(
          _$SearchResultImpl value, $Res Function(_$SearchResultImpl) then) =
      __$$SearchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String messageId,
      String conversationId,
      String content,
      String fullContent,
      int startIndex,
      int endIndex,
      String beforeContext,
      String afterContext,
      double score,
      bool isUserMessage,
      DateTime timestamp,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$SearchResultImplCopyWithImpl<$Res>
    extends _$SearchResultCopyWithImpl<$Res, _$SearchResultImpl>
    implements _$$SearchResultImplCopyWith<$Res> {
  __$$SearchResultImplCopyWithImpl(
      _$SearchResultImpl _value, $Res Function(_$SearchResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messageId = null,
    Object? conversationId = null,
    Object? content = null,
    Object? fullContent = null,
    Object? startIndex = null,
    Object? endIndex = null,
    Object? beforeContext = null,
    Object? afterContext = null,
    Object? score = null,
    Object? isUserMessage = null,
    Object? timestamp = null,
    Object? metadata = null,
  }) {
    return _then(_$SearchResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      fullContent: null == fullContent
          ? _value.fullContent
          : fullContent // ignore: cast_nullable_to_non_nullable
              as String,
      startIndex: null == startIndex
          ? _value.startIndex
          : startIndex // ignore: cast_nullable_to_non_nullable
              as int,
      endIndex: null == endIndex
          ? _value.endIndex
          : endIndex // ignore: cast_nullable_to_non_nullable
              as int,
      beforeContext: null == beforeContext
          ? _value.beforeContext
          : beforeContext // ignore: cast_nullable_to_non_nullable
              as String,
      afterContext: null == afterContext
          ? _value.afterContext
          : afterContext // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      isUserMessage: null == isUserMessage
          ? _value.isUserMessage
          : isUserMessage // ignore: cast_nullable_to_non_nullable
              as bool,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$SearchResultImpl implements _SearchResult {
  const _$SearchResultImpl(
      {required this.id,
      required this.messageId,
      required this.conversationId,
      required this.content,
      required this.fullContent,
      required this.startIndex,
      required this.endIndex,
      this.beforeContext = '',
      this.afterContext = '',
      this.score = 1.0,
      this.isUserMessage = false,
      required this.timestamp,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata;

  /// Unique result ID
  @override
  final String id;

  /// Message ID that contains the match
  @override
  final String messageId;

  /// Conversation ID
  @override
  final String conversationId;

  /// Matched content
  @override
  final String content;

  /// Full message content for context
  @override
  final String fullContent;

  /// Match start position in content
  @override
  final int startIndex;

  /// Match end position in content
  @override
  final int endIndex;

  /// Context before the match
  @override
  @JsonKey()
  final String beforeContext;

  /// Context after the match
  @override
  @JsonKey()
  final String afterContext;

  /// Match score (relevance)
  @override
  @JsonKey()
  final double score;

  /// Whether this is from a user message
  @override
  @JsonKey()
  final bool isUserMessage;

  /// Message timestamp
  @override
  final DateTime timestamp;

  /// Additional metadata
  final Map<String, dynamic> _metadata;

  /// Additional metadata
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'SearchResult(id: $id, messageId: $messageId, conversationId: $conversationId, content: $content, fullContent: $fullContent, startIndex: $startIndex, endIndex: $endIndex, beforeContext: $beforeContext, afterContext: $afterContext, score: $score, isUserMessage: $isUserMessage, timestamp: $timestamp, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.fullContent, fullContent) ||
                other.fullContent == fullContent) &&
            (identical(other.startIndex, startIndex) ||
                other.startIndex == startIndex) &&
            (identical(other.endIndex, endIndex) ||
                other.endIndex == endIndex) &&
            (identical(other.beforeContext, beforeContext) ||
                other.beforeContext == beforeContext) &&
            (identical(other.afterContext, afterContext) ||
                other.afterContext == afterContext) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.isUserMessage, isUserMessage) ||
                other.isUserMessage == isUserMessage) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      messageId,
      conversationId,
      content,
      fullContent,
      startIndex,
      endIndex,
      beforeContext,
      afterContext,
      score,
      isUserMessage,
      timestamp,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchResultImplCopyWith<_$SearchResultImpl> get copyWith =>
      __$$SearchResultImplCopyWithImpl<_$SearchResultImpl>(this, _$identity);
}

abstract class _SearchResult implements SearchResult {
  const factory _SearchResult(
      {required final String id,
      required final String messageId,
      required final String conversationId,
      required final String content,
      required final String fullContent,
      required final int startIndex,
      required final int endIndex,
      final String beforeContext,
      final String afterContext,
      final double score,
      final bool isUserMessage,
      required final DateTime timestamp,
      final Map<String, dynamic> metadata}) = _$SearchResultImpl;

  /// Unique result ID
  @override
  String get id;

  /// Message ID that contains the match
  @override
  String get messageId;

  /// Conversation ID
  @override
  String get conversationId;

  /// Matched content
  @override
  String get content;

  /// Full message content for context
  @override
  String get fullContent;

  /// Match start position in content
  @override
  int get startIndex;

  /// Match end position in content
  @override
  int get endIndex;

  /// Context before the match
  @override
  String get beforeContext;

  /// Context after the match
  @override
  String get afterContext;

  /// Match score (relevance)
  @override
  double get score;

  /// Whether this is from a user message
  @override
  bool get isUserMessage;

  /// Message timestamp
  @override
  DateTime get timestamp;

  /// Additional metadata
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchResultImplCopyWith<_$SearchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$HighlightedElement {
  /// Element ID
  String get id => throw _privateConstructorUsedError;

  /// Message ID
  String get messageId => throw _privateConstructorUsedError;

  /// Start position in message
  int get startIndex => throw _privateConstructorUsedError;

  /// End position in message
  int get endIndex => throw _privateConstructorUsedError;

  /// Whether this element is currently active
  bool get isActive => throw _privateConstructorUsedError;

  /// Highlight color
  String? get color => throw _privateConstructorUsedError;

  /// Create a copy of HighlightedElement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HighlightedElementCopyWith<HighlightedElement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HighlightedElementCopyWith<$Res> {
  factory $HighlightedElementCopyWith(
          HighlightedElement value, $Res Function(HighlightedElement) then) =
      _$HighlightedElementCopyWithImpl<$Res, HighlightedElement>;
  @useResult
  $Res call(
      {String id,
      String messageId,
      int startIndex,
      int endIndex,
      bool isActive,
      String? color});
}

/// @nodoc
class _$HighlightedElementCopyWithImpl<$Res, $Val extends HighlightedElement>
    implements $HighlightedElementCopyWith<$Res> {
  _$HighlightedElementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HighlightedElement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messageId = null,
    Object? startIndex = null,
    Object? endIndex = null,
    Object? isActive = null,
    Object? color = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String,
      startIndex: null == startIndex
          ? _value.startIndex
          : startIndex // ignore: cast_nullable_to_non_nullable
              as int,
      endIndex: null == endIndex
          ? _value.endIndex
          : endIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HighlightedElementImplCopyWith<$Res>
    implements $HighlightedElementCopyWith<$Res> {
  factory _$$HighlightedElementImplCopyWith(_$HighlightedElementImpl value,
          $Res Function(_$HighlightedElementImpl) then) =
      __$$HighlightedElementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String messageId,
      int startIndex,
      int endIndex,
      bool isActive,
      String? color});
}

/// @nodoc
class __$$HighlightedElementImplCopyWithImpl<$Res>
    extends _$HighlightedElementCopyWithImpl<$Res, _$HighlightedElementImpl>
    implements _$$HighlightedElementImplCopyWith<$Res> {
  __$$HighlightedElementImplCopyWithImpl(_$HighlightedElementImpl _value,
      $Res Function(_$HighlightedElementImpl) _then)
      : super(_value, _then);

  /// Create a copy of HighlightedElement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messageId = null,
    Object? startIndex = null,
    Object? endIndex = null,
    Object? isActive = null,
    Object? color = freezed,
  }) {
    return _then(_$HighlightedElementImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String,
      startIndex: null == startIndex
          ? _value.startIndex
          : startIndex // ignore: cast_nullable_to_non_nullable
              as int,
      endIndex: null == endIndex
          ? _value.endIndex
          : endIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$HighlightedElementImpl implements _HighlightedElement {
  const _$HighlightedElementImpl(
      {required this.id,
      required this.messageId,
      required this.startIndex,
      required this.endIndex,
      this.isActive = false,
      this.color = null});

  /// Element ID
  @override
  final String id;

  /// Message ID
  @override
  final String messageId;

  /// Start position in message
  @override
  final int startIndex;

  /// End position in message
  @override
  final int endIndex;

  /// Whether this element is currently active
  @override
  @JsonKey()
  final bool isActive;

  /// Highlight color
  @override
  @JsonKey()
  final String? color;

  @override
  String toString() {
    return 'HighlightedElement(id: $id, messageId: $messageId, startIndex: $startIndex, endIndex: $endIndex, isActive: $isActive, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HighlightedElementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.startIndex, startIndex) ||
                other.startIndex == startIndex) &&
            (identical(other.endIndex, endIndex) ||
                other.endIndex == endIndex) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.color, color) || other.color == color));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, messageId, startIndex, endIndex, isActive, color);

  /// Create a copy of HighlightedElement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HighlightedElementImplCopyWith<_$HighlightedElementImpl> get copyWith =>
      __$$HighlightedElementImplCopyWithImpl<_$HighlightedElementImpl>(
          this, _$identity);
}

abstract class _HighlightedElement implements HighlightedElement {
  const factory _HighlightedElement(
      {required final String id,
      required final String messageId,
      required final int startIndex,
      required final int endIndex,
      final bool isActive,
      final String? color}) = _$HighlightedElementImpl;

  /// Element ID
  @override
  String get id;

  /// Message ID
  @override
  String get messageId;

  /// Start position in message
  @override
  int get startIndex;

  /// End position in message
  @override
  int get endIndex;

  /// Whether this element is currently active
  @override
  bool get isActive;

  /// Highlight color
  @override
  String? get color;

  /// Create a copy of HighlightedElement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HighlightedElementImplCopyWith<_$HighlightedElementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$HighlightColorScheme {
  /// Primary highlight color
  String get primary => throw _privateConstructorUsedError;

  /// Secondary highlight color
  String get secondary => throw _privateConstructorUsedError;

  /// Active highlight color
  String get active => throw _privateConstructorUsedError;

  /// Text color on highlights
  String get textColor => throw _privateConstructorUsedError;

  /// Create a copy of HighlightColorScheme
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HighlightColorSchemeCopyWith<HighlightColorScheme> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HighlightColorSchemeCopyWith<$Res> {
  factory $HighlightColorSchemeCopyWith(HighlightColorScheme value,
          $Res Function(HighlightColorScheme) then) =
      _$HighlightColorSchemeCopyWithImpl<$Res, HighlightColorScheme>;
  @useResult
  $Res call(
      {String primary, String secondary, String active, String textColor});
}

/// @nodoc
class _$HighlightColorSchemeCopyWithImpl<$Res,
        $Val extends HighlightColorScheme>
    implements $HighlightColorSchemeCopyWith<$Res> {
  _$HighlightColorSchemeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HighlightColorScheme
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? primary = null,
    Object? secondary = null,
    Object? active = null,
    Object? textColor = null,
  }) {
    return _then(_value.copyWith(
      primary: null == primary
          ? _value.primary
          : primary // ignore: cast_nullable_to_non_nullable
              as String,
      secondary: null == secondary
          ? _value.secondary
          : secondary // ignore: cast_nullable_to_non_nullable
              as String,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as String,
      textColor: null == textColor
          ? _value.textColor
          : textColor // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HighlightColorSchemeImplCopyWith<$Res>
    implements $HighlightColorSchemeCopyWith<$Res> {
  factory _$$HighlightColorSchemeImplCopyWith(_$HighlightColorSchemeImpl value,
          $Res Function(_$HighlightColorSchemeImpl) then) =
      __$$HighlightColorSchemeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String primary, String secondary, String active, String textColor});
}

/// @nodoc
class __$$HighlightColorSchemeImplCopyWithImpl<$Res>
    extends _$HighlightColorSchemeCopyWithImpl<$Res, _$HighlightColorSchemeImpl>
    implements _$$HighlightColorSchemeImplCopyWith<$Res> {
  __$$HighlightColorSchemeImplCopyWithImpl(_$HighlightColorSchemeImpl _value,
      $Res Function(_$HighlightColorSchemeImpl) _then)
      : super(_value, _then);

  /// Create a copy of HighlightColorScheme
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? primary = null,
    Object? secondary = null,
    Object? active = null,
    Object? textColor = null,
  }) {
    return _then(_$HighlightColorSchemeImpl(
      primary: null == primary
          ? _value.primary
          : primary // ignore: cast_nullable_to_non_nullable
              as String,
      secondary: null == secondary
          ? _value.secondary
          : secondary // ignore: cast_nullable_to_non_nullable
              as String,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as String,
      textColor: null == textColor
          ? _value.textColor
          : textColor // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$HighlightColorSchemeImpl implements _HighlightColorScheme {
  const _$HighlightColorSchemeImpl(
      {this.primary = '#FFD700',
      this.secondary = '#FFA500',
      this.active = '#FF6347',
      this.textColor = '#000000'});

  /// Primary highlight color
  @override
  @JsonKey()
  final String primary;

  /// Secondary highlight color
  @override
  @JsonKey()
  final String secondary;

  /// Active highlight color
  @override
  @JsonKey()
  final String active;

  /// Text color on highlights
  @override
  @JsonKey()
  final String textColor;

  @override
  String toString() {
    return 'HighlightColorScheme(primary: $primary, secondary: $secondary, active: $active, textColor: $textColor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HighlightColorSchemeImpl &&
            (identical(other.primary, primary) || other.primary == primary) &&
            (identical(other.secondary, secondary) ||
                other.secondary == secondary) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.textColor, textColor) ||
                other.textColor == textColor));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, primary, secondary, active, textColor);

  /// Create a copy of HighlightColorScheme
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HighlightColorSchemeImplCopyWith<_$HighlightColorSchemeImpl>
      get copyWith =>
          __$$HighlightColorSchemeImplCopyWithImpl<_$HighlightColorSchemeImpl>(
              this, _$identity);
}

abstract class _HighlightColorScheme implements HighlightColorScheme {
  const factory _HighlightColorScheme(
      {final String primary,
      final String secondary,
      final String active,
      final String textColor}) = _$HighlightColorSchemeImpl;

  /// Primary highlight color
  @override
  String get primary;

  /// Secondary highlight color
  @override
  String get secondary;

  /// Active highlight color
  @override
  String get active;

  /// Text color on highlights
  @override
  String get textColor;

  /// Create a copy of HighlightColorScheme
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HighlightColorSchemeImplCopyWith<_$HighlightColorSchemeImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DateRange {
  /// Start date (inclusive)
  DateTime get start => throw _privateConstructorUsedError;

  /// End date (inclusive)
  DateTime get end => throw _privateConstructorUsedError;

  /// Create a copy of DateRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DateRangeCopyWith<DateRange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DateRangeCopyWith<$Res> {
  factory $DateRangeCopyWith(DateRange value, $Res Function(DateRange) then) =
      _$DateRangeCopyWithImpl<$Res, DateRange>;
  @useResult
  $Res call({DateTime start, DateTime end});
}

/// @nodoc
class _$DateRangeCopyWithImpl<$Res, $Val extends DateRange>
    implements $DateRangeCopyWith<$Res> {
  _$DateRangeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DateRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = null,
    Object? end = null,
  }) {
    return _then(_value.copyWith(
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as DateTime,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DateRangeImplCopyWith<$Res>
    implements $DateRangeCopyWith<$Res> {
  factory _$$DateRangeImplCopyWith(
          _$DateRangeImpl value, $Res Function(_$DateRangeImpl) then) =
      __$$DateRangeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime start, DateTime end});
}

/// @nodoc
class __$$DateRangeImplCopyWithImpl<$Res>
    extends _$DateRangeCopyWithImpl<$Res, _$DateRangeImpl>
    implements _$$DateRangeImplCopyWith<$Res> {
  __$$DateRangeImplCopyWithImpl(
      _$DateRangeImpl _value, $Res Function(_$DateRangeImpl) _then)
      : super(_value, _then);

  /// Create a copy of DateRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = null,
    Object? end = null,
  }) {
    return _then(_$DateRangeImpl(
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as DateTime,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$DateRangeImpl implements _DateRange {
  const _$DateRangeImpl({required this.start, required this.end});

  /// Start date (inclusive)
  @override
  final DateTime start;

  /// End date (inclusive)
  @override
  final DateTime end;

  @override
  String toString() {
    return 'DateRange(start: $start, end: $end)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DateRangeImpl &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end));
  }

  @override
  int get hashCode => Object.hash(runtimeType, start, end);

  /// Create a copy of DateRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DateRangeImplCopyWith<_$DateRangeImpl> get copyWith =>
      __$$DateRangeImplCopyWithImpl<_$DateRangeImpl>(this, _$identity);
}

abstract class _DateRange implements DateRange {
  const factory _DateRange(
      {required final DateTime start,
      required final DateTime end}) = _$DateRangeImpl;

  /// Start date (inclusive)
  @override
  DateTime get start;

  /// End date (inclusive)
  @override
  DateTime get end;

  /// Create a copy of DateRange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DateRangeImplCopyWith<_$DateRangeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SearchStatistics {
  /// Total results found
  int get totalResults => throw _privateConstructorUsedError;

  /// Search duration in milliseconds
  int get searchDurationMs => throw _privateConstructorUsedError;

  /// Number of messages searched
  int get messagesSearched => throw _privateConstructorUsedError;

  /// Average search duration
  double get averageDuration => throw _privateConstructorUsedError;

  /// Total searches performed
  int get totalSearches => throw _privateConstructorUsedError;

  /// Create a copy of SearchStatistics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchStatisticsCopyWith<SearchStatistics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchStatisticsCopyWith<$Res> {
  factory $SearchStatisticsCopyWith(
          SearchStatistics value, $Res Function(SearchStatistics) then) =
      _$SearchStatisticsCopyWithImpl<$Res, SearchStatistics>;
  @useResult
  $Res call(
      {int totalResults,
      int searchDurationMs,
      int messagesSearched,
      double averageDuration,
      int totalSearches});
}

/// @nodoc
class _$SearchStatisticsCopyWithImpl<$Res, $Val extends SearchStatistics>
    implements $SearchStatisticsCopyWith<$Res> {
  _$SearchStatisticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchStatistics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalResults = null,
    Object? searchDurationMs = null,
    Object? messagesSearched = null,
    Object? averageDuration = null,
    Object? totalSearches = null,
  }) {
    return _then(_value.copyWith(
      totalResults: null == totalResults
          ? _value.totalResults
          : totalResults // ignore: cast_nullable_to_non_nullable
              as int,
      searchDurationMs: null == searchDurationMs
          ? _value.searchDurationMs
          : searchDurationMs // ignore: cast_nullable_to_non_nullable
              as int,
      messagesSearched: null == messagesSearched
          ? _value.messagesSearched
          : messagesSearched // ignore: cast_nullable_to_non_nullable
              as int,
      averageDuration: null == averageDuration
          ? _value.averageDuration
          : averageDuration // ignore: cast_nullable_to_non_nullable
              as double,
      totalSearches: null == totalSearches
          ? _value.totalSearches
          : totalSearches // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchStatisticsImplCopyWith<$Res>
    implements $SearchStatisticsCopyWith<$Res> {
  factory _$$SearchStatisticsImplCopyWith(_$SearchStatisticsImpl value,
          $Res Function(_$SearchStatisticsImpl) then) =
      __$$SearchStatisticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalResults,
      int searchDurationMs,
      int messagesSearched,
      double averageDuration,
      int totalSearches});
}

/// @nodoc
class __$$SearchStatisticsImplCopyWithImpl<$Res>
    extends _$SearchStatisticsCopyWithImpl<$Res, _$SearchStatisticsImpl>
    implements _$$SearchStatisticsImplCopyWith<$Res> {
  __$$SearchStatisticsImplCopyWithImpl(_$SearchStatisticsImpl _value,
      $Res Function(_$SearchStatisticsImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchStatistics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalResults = null,
    Object? searchDurationMs = null,
    Object? messagesSearched = null,
    Object? averageDuration = null,
    Object? totalSearches = null,
  }) {
    return _then(_$SearchStatisticsImpl(
      totalResults: null == totalResults
          ? _value.totalResults
          : totalResults // ignore: cast_nullable_to_non_nullable
              as int,
      searchDurationMs: null == searchDurationMs
          ? _value.searchDurationMs
          : searchDurationMs // ignore: cast_nullable_to_non_nullable
              as int,
      messagesSearched: null == messagesSearched
          ? _value.messagesSearched
          : messagesSearched // ignore: cast_nullable_to_non_nullable
              as int,
      averageDuration: null == averageDuration
          ? _value.averageDuration
          : averageDuration // ignore: cast_nullable_to_non_nullable
              as double,
      totalSearches: null == totalSearches
          ? _value.totalSearches
          : totalSearches // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$SearchStatisticsImpl implements _SearchStatistics {
  const _$SearchStatisticsImpl(
      {required this.totalResults,
      required this.searchDurationMs,
      required this.messagesSearched,
      required this.averageDuration,
      required this.totalSearches});

  /// Total results found
  @override
  final int totalResults;

  /// Search duration in milliseconds
  @override
  final int searchDurationMs;

  /// Number of messages searched
  @override
  final int messagesSearched;

  /// Average search duration
  @override
  final double averageDuration;

  /// Total searches performed
  @override
  final int totalSearches;

  @override
  String toString() {
    return 'SearchStatistics(totalResults: $totalResults, searchDurationMs: $searchDurationMs, messagesSearched: $messagesSearched, averageDuration: $averageDuration, totalSearches: $totalSearches)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchStatisticsImpl &&
            (identical(other.totalResults, totalResults) ||
                other.totalResults == totalResults) &&
            (identical(other.searchDurationMs, searchDurationMs) ||
                other.searchDurationMs == searchDurationMs) &&
            (identical(other.messagesSearched, messagesSearched) ||
                other.messagesSearched == messagesSearched) &&
            (identical(other.averageDuration, averageDuration) ||
                other.averageDuration == averageDuration) &&
            (identical(other.totalSearches, totalSearches) ||
                other.totalSearches == totalSearches));
  }

  @override
  int get hashCode => Object.hash(runtimeType, totalResults, searchDurationMs,
      messagesSearched, averageDuration, totalSearches);

  /// Create a copy of SearchStatistics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchStatisticsImplCopyWith<_$SearchStatisticsImpl> get copyWith =>
      __$$SearchStatisticsImplCopyWithImpl<_$SearchStatisticsImpl>(
          this, _$identity);
}

abstract class _SearchStatistics implements SearchStatistics {
  const factory _SearchStatistics(
      {required final int totalResults,
      required final int searchDurationMs,
      required final int messagesSearched,
      required final double averageDuration,
      required final int totalSearches}) = _$SearchStatisticsImpl;

  /// Total results found
  @override
  int get totalResults;

  /// Search duration in milliseconds
  @override
  int get searchDurationMs;

  /// Number of messages searched
  @override
  int get messagesSearched;

  /// Average search duration
  @override
  double get averageDuration;

  /// Total searches performed
  @override
  int get totalSearches;

  /// Create a copy of SearchStatistics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchStatisticsImplCopyWith<_$SearchStatisticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
