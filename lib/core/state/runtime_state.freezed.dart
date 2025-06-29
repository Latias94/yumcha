// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'runtime_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SearchResult {
  /// Result ID
  String get id => throw _privateConstructorUsedError;

  /// Result type (message, conversation, etc.)
  SearchResultType get type => throw _privateConstructorUsedError;

  /// Matched content
  String get content => throw _privateConstructorUsedError;

  /// Context around the match
  String get context => throw _privateConstructorUsedError;

  /// Match score (0.0 to 1.0)
  double get score => throw _privateConstructorUsedError;

  /// Highlighted content with match markers
  String get highlightedContent => throw _privateConstructorUsedError;

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
      SearchResultType type,
      String content,
      String context,
      double score,
      String highlightedContent,
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
    Object? type = null,
    Object? content = null,
    Object? context = null,
    Object? score = null,
    Object? highlightedContent = null,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SearchResultType,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      context: null == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      highlightedContent: null == highlightedContent
          ? _value.highlightedContent
          : highlightedContent // ignore: cast_nullable_to_non_nullable
              as String,
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
      SearchResultType type,
      String content,
      String context,
      double score,
      String highlightedContent,
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
    Object? type = null,
    Object? content = null,
    Object? context = null,
    Object? score = null,
    Object? highlightedContent = null,
    Object? metadata = null,
  }) {
    return _then(_$SearchResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SearchResultType,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      context: null == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      highlightedContent: null == highlightedContent
          ? _value.highlightedContent
          : highlightedContent // ignore: cast_nullable_to_non_nullable
              as String,
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
      required this.type,
      required this.content,
      this.context = '',
      this.score = 0.0,
      this.highlightedContent = '',
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata;

  /// Result ID
  @override
  final String id;

  /// Result type (message, conversation, etc.)
  @override
  final SearchResultType type;

  /// Matched content
  @override
  final String content;

  /// Context around the match
  @override
  @JsonKey()
  final String context;

  /// Match score (0.0 to 1.0)
  @override
  @JsonKey()
  final double score;

  /// Highlighted content with match markers
  @override
  @JsonKey()
  final String highlightedContent;

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
    return 'SearchResult(id: $id, type: $type, content: $content, context: $context, score: $score, highlightedContent: $highlightedContent, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.context, context) || other.context == context) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.highlightedContent, highlightedContent) ||
                other.highlightedContent == highlightedContent) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      content,
      context,
      score,
      highlightedContent,
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
      required final SearchResultType type,
      required final String content,
      final String context,
      final double score,
      final String highlightedContent,
      final Map<String, dynamic> metadata}) = _$SearchResultImpl;

  /// Result ID
  @override
  String get id;

  /// Result type (message, conversation, etc.)
  @override
  SearchResultType get type;

  /// Matched content
  @override
  String get content;

  /// Context around the match
  @override
  String get context;

  /// Match score (0.0 to 1.0)
  @override
  double get score;

  /// Highlighted content with match markers
  @override
  String get highlightedContent;

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
mixin _$RuntimeState {
// === Multi-Selection Mode (Cherry Studio: isMultiSelectMode) ===
  /// Whether multi-select mode is active
  bool get isMultiSelectMode => throw _privateConstructorUsedError;

  /// Set of selected message IDs
  Set<String> get selectedMessageIds => throw _privateConstructorUsedError;

  /// Whether selection mode is for deletion
  bool get isSelectionForDeletion =>
      throw _privateConstructorUsedError; // === Topic/Conversation Management (Cherry Studio: activeTopic) ===
  /// Currently active topic/conversation ID
  String? get activeTopicId => throw _privateConstructorUsedError;

  /// Topic IDs currently being renamed
  Set<String> get renamingTopicIds => throw _privateConstructorUsedError;

  /// Topic IDs that were recently renamed (for UI feedback)
  Set<String> get newlyRenamedTopicIds =>
      throw _privateConstructorUsedError; // === Message Editing State ===
  /// Message ID currently being edited
  String? get editingMessageId => throw _privateConstructorUsedError;

  /// Original content before editing (for cancel functionality)
  String? get originalEditingContent => throw _privateConstructorUsedError;

  /// Current editing content
  String? get editingContent => throw _privateConstructorUsedError;

  /// Whether editing is in progress
  bool get isEditing =>
      throw _privateConstructorUsedError; // === Search State ===
  /// Whether search mode is active
  bool get isSearching => throw _privateConstructorUsedError;

  /// Current search query
  String get searchQuery => throw _privateConstructorUsedError;

  /// Search results
  List<SearchResult> get searchResults => throw _privateConstructorUsedError;

  /// Current search result index (for navigation)
  int get currentSearchIndex => throw _privateConstructorUsedError;

  /// Whether search is loading
  bool get isSearchLoading => throw _privateConstructorUsedError;

  /// Search error message
  String? get searchError =>
      throw _privateConstructorUsedError; // === Message Operations State ===
  /// Messages currently being processed for operations
  Set<String> get processingMessageIds => throw _privateConstructorUsedError;

  /// Messages being regenerated
  Set<String> get regeneratingMessageIds => throw _privateConstructorUsedError;

  /// Messages being translated
  Set<String> get translatingMessageIds => throw _privateConstructorUsedError;

  /// Messages being deleted
  Set<String> get deletingMessageIds =>
      throw _privateConstructorUsedError; // === UI Interaction State ===
  /// Whether any modal/dialog is open
  bool get isModalOpen => throw _privateConstructorUsedError;

  /// Current modal type
  String? get currentModalType => throw _privateConstructorUsedError;

  /// Whether sidebar is collapsed
  bool get isSidebarCollapsed => throw _privateConstructorUsedError;

  /// Whether settings panel is open
  bool get isSettingsPanelOpen => throw _privateConstructorUsedError;

  /// Current view mode (chat, settings, etc.)
  ViewMode get currentViewMode =>
      throw _privateConstructorUsedError; // === Drag and Drop State ===
  /// Whether drag operation is in progress
  bool get isDragging => throw _privateConstructorUsedError;

  /// Type of item being dragged
  String? get dragItemType => throw _privateConstructorUsedError;

  /// Data of item being dragged
  Map<String, dynamic> get dragItemData =>
      throw _privateConstructorUsedError; // === Keyboard Shortcuts State ===
  /// Whether keyboard shortcuts are enabled
  bool get keyboardShortcutsEnabled => throw _privateConstructorUsedError;

  /// Currently pressed modifier keys
  Set<String> get pressedModifierKeys =>
      throw _privateConstructorUsedError; // === Performance and Debug State ===
  /// Whether debug mode is enabled
  bool get isDebugMode => throw _privateConstructorUsedError;

  /// Performance metrics visibility
  bool get showPerformanceMetrics => throw _privateConstructorUsedError;

  /// Last interaction timestamp
  DateTime? get lastInteractionTime =>
      throw _privateConstructorUsedError; // === Notification State ===
  /// Active notifications
  List<RuntimeNotification> get activeNotifications =>
      throw _privateConstructorUsedError;

  /// Whether notifications are muted
  bool get notificationsMuted => throw _privateConstructorUsedError;

  /// Create a copy of RuntimeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RuntimeStateCopyWith<RuntimeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RuntimeStateCopyWith<$Res> {
  factory $RuntimeStateCopyWith(
          RuntimeState value, $Res Function(RuntimeState) then) =
      _$RuntimeStateCopyWithImpl<$Res, RuntimeState>;
  @useResult
  $Res call(
      {bool isMultiSelectMode,
      Set<String> selectedMessageIds,
      bool isSelectionForDeletion,
      String? activeTopicId,
      Set<String> renamingTopicIds,
      Set<String> newlyRenamedTopicIds,
      String? editingMessageId,
      String? originalEditingContent,
      String? editingContent,
      bool isEditing,
      bool isSearching,
      String searchQuery,
      List<SearchResult> searchResults,
      int currentSearchIndex,
      bool isSearchLoading,
      String? searchError,
      Set<String> processingMessageIds,
      Set<String> regeneratingMessageIds,
      Set<String> translatingMessageIds,
      Set<String> deletingMessageIds,
      bool isModalOpen,
      String? currentModalType,
      bool isSidebarCollapsed,
      bool isSettingsPanelOpen,
      ViewMode currentViewMode,
      bool isDragging,
      String? dragItemType,
      Map<String, dynamic> dragItemData,
      bool keyboardShortcutsEnabled,
      Set<String> pressedModifierKeys,
      bool isDebugMode,
      bool showPerformanceMetrics,
      DateTime? lastInteractionTime,
      List<RuntimeNotification> activeNotifications,
      bool notificationsMuted});
}

/// @nodoc
class _$RuntimeStateCopyWithImpl<$Res, $Val extends RuntimeState>
    implements $RuntimeStateCopyWith<$Res> {
  _$RuntimeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RuntimeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isMultiSelectMode = null,
    Object? selectedMessageIds = null,
    Object? isSelectionForDeletion = null,
    Object? activeTopicId = freezed,
    Object? renamingTopicIds = null,
    Object? newlyRenamedTopicIds = null,
    Object? editingMessageId = freezed,
    Object? originalEditingContent = freezed,
    Object? editingContent = freezed,
    Object? isEditing = null,
    Object? isSearching = null,
    Object? searchQuery = null,
    Object? searchResults = null,
    Object? currentSearchIndex = null,
    Object? isSearchLoading = null,
    Object? searchError = freezed,
    Object? processingMessageIds = null,
    Object? regeneratingMessageIds = null,
    Object? translatingMessageIds = null,
    Object? deletingMessageIds = null,
    Object? isModalOpen = null,
    Object? currentModalType = freezed,
    Object? isSidebarCollapsed = null,
    Object? isSettingsPanelOpen = null,
    Object? currentViewMode = null,
    Object? isDragging = null,
    Object? dragItemType = freezed,
    Object? dragItemData = null,
    Object? keyboardShortcutsEnabled = null,
    Object? pressedModifierKeys = null,
    Object? isDebugMode = null,
    Object? showPerformanceMetrics = null,
    Object? lastInteractionTime = freezed,
    Object? activeNotifications = null,
    Object? notificationsMuted = null,
  }) {
    return _then(_value.copyWith(
      isMultiSelectMode: null == isMultiSelectMode
          ? _value.isMultiSelectMode
          : isMultiSelectMode // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedMessageIds: null == selectedMessageIds
          ? _value.selectedMessageIds
          : selectedMessageIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      isSelectionForDeletion: null == isSelectionForDeletion
          ? _value.isSelectionForDeletion
          : isSelectionForDeletion // ignore: cast_nullable_to_non_nullable
              as bool,
      activeTopicId: freezed == activeTopicId
          ? _value.activeTopicId
          : activeTopicId // ignore: cast_nullable_to_non_nullable
              as String?,
      renamingTopicIds: null == renamingTopicIds
          ? _value.renamingTopicIds
          : renamingTopicIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      newlyRenamedTopicIds: null == newlyRenamedTopicIds
          ? _value.newlyRenamedTopicIds
          : newlyRenamedTopicIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      editingMessageId: freezed == editingMessageId
          ? _value.editingMessageId
          : editingMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      originalEditingContent: freezed == originalEditingContent
          ? _value.originalEditingContent
          : originalEditingContent // ignore: cast_nullable_to_non_nullable
              as String?,
      editingContent: freezed == editingContent
          ? _value.editingContent
          : editingContent // ignore: cast_nullable_to_non_nullable
              as String?,
      isEditing: null == isEditing
          ? _value.isEditing
          : isEditing // ignore: cast_nullable_to_non_nullable
              as bool,
      isSearching: null == isSearching
          ? _value.isSearching
          : isSearching // ignore: cast_nullable_to_non_nullable
              as bool,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      searchResults: null == searchResults
          ? _value.searchResults
          : searchResults // ignore: cast_nullable_to_non_nullable
              as List<SearchResult>,
      currentSearchIndex: null == currentSearchIndex
          ? _value.currentSearchIndex
          : currentSearchIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isSearchLoading: null == isSearchLoading
          ? _value.isSearchLoading
          : isSearchLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      searchError: freezed == searchError
          ? _value.searchError
          : searchError // ignore: cast_nullable_to_non_nullable
              as String?,
      processingMessageIds: null == processingMessageIds
          ? _value.processingMessageIds
          : processingMessageIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      regeneratingMessageIds: null == regeneratingMessageIds
          ? _value.regeneratingMessageIds
          : regeneratingMessageIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      translatingMessageIds: null == translatingMessageIds
          ? _value.translatingMessageIds
          : translatingMessageIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      deletingMessageIds: null == deletingMessageIds
          ? _value.deletingMessageIds
          : deletingMessageIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      isModalOpen: null == isModalOpen
          ? _value.isModalOpen
          : isModalOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      currentModalType: freezed == currentModalType
          ? _value.currentModalType
          : currentModalType // ignore: cast_nullable_to_non_nullable
              as String?,
      isSidebarCollapsed: null == isSidebarCollapsed
          ? _value.isSidebarCollapsed
          : isSidebarCollapsed // ignore: cast_nullable_to_non_nullable
              as bool,
      isSettingsPanelOpen: null == isSettingsPanelOpen
          ? _value.isSettingsPanelOpen
          : isSettingsPanelOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      currentViewMode: null == currentViewMode
          ? _value.currentViewMode
          : currentViewMode // ignore: cast_nullable_to_non_nullable
              as ViewMode,
      isDragging: null == isDragging
          ? _value.isDragging
          : isDragging // ignore: cast_nullable_to_non_nullable
              as bool,
      dragItemType: freezed == dragItemType
          ? _value.dragItemType
          : dragItemType // ignore: cast_nullable_to_non_nullable
              as String?,
      dragItemData: null == dragItemData
          ? _value.dragItemData
          : dragItemData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      keyboardShortcutsEnabled: null == keyboardShortcutsEnabled
          ? _value.keyboardShortcutsEnabled
          : keyboardShortcutsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      pressedModifierKeys: null == pressedModifierKeys
          ? _value.pressedModifierKeys
          : pressedModifierKeys // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      isDebugMode: null == isDebugMode
          ? _value.isDebugMode
          : isDebugMode // ignore: cast_nullable_to_non_nullable
              as bool,
      showPerformanceMetrics: null == showPerformanceMetrics
          ? _value.showPerformanceMetrics
          : showPerformanceMetrics // ignore: cast_nullable_to_non_nullable
              as bool,
      lastInteractionTime: freezed == lastInteractionTime
          ? _value.lastInteractionTime
          : lastInteractionTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      activeNotifications: null == activeNotifications
          ? _value.activeNotifications
          : activeNotifications // ignore: cast_nullable_to_non_nullable
              as List<RuntimeNotification>,
      notificationsMuted: null == notificationsMuted
          ? _value.notificationsMuted
          : notificationsMuted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RuntimeStateImplCopyWith<$Res>
    implements $RuntimeStateCopyWith<$Res> {
  factory _$$RuntimeStateImplCopyWith(
          _$RuntimeStateImpl value, $Res Function(_$RuntimeStateImpl) then) =
      __$$RuntimeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isMultiSelectMode,
      Set<String> selectedMessageIds,
      bool isSelectionForDeletion,
      String? activeTopicId,
      Set<String> renamingTopicIds,
      Set<String> newlyRenamedTopicIds,
      String? editingMessageId,
      String? originalEditingContent,
      String? editingContent,
      bool isEditing,
      bool isSearching,
      String searchQuery,
      List<SearchResult> searchResults,
      int currentSearchIndex,
      bool isSearchLoading,
      String? searchError,
      Set<String> processingMessageIds,
      Set<String> regeneratingMessageIds,
      Set<String> translatingMessageIds,
      Set<String> deletingMessageIds,
      bool isModalOpen,
      String? currentModalType,
      bool isSidebarCollapsed,
      bool isSettingsPanelOpen,
      ViewMode currentViewMode,
      bool isDragging,
      String? dragItemType,
      Map<String, dynamic> dragItemData,
      bool keyboardShortcutsEnabled,
      Set<String> pressedModifierKeys,
      bool isDebugMode,
      bool showPerformanceMetrics,
      DateTime? lastInteractionTime,
      List<RuntimeNotification> activeNotifications,
      bool notificationsMuted});
}

/// @nodoc
class __$$RuntimeStateImplCopyWithImpl<$Res>
    extends _$RuntimeStateCopyWithImpl<$Res, _$RuntimeStateImpl>
    implements _$$RuntimeStateImplCopyWith<$Res> {
  __$$RuntimeStateImplCopyWithImpl(
      _$RuntimeStateImpl _value, $Res Function(_$RuntimeStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of RuntimeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isMultiSelectMode = null,
    Object? selectedMessageIds = null,
    Object? isSelectionForDeletion = null,
    Object? activeTopicId = freezed,
    Object? renamingTopicIds = null,
    Object? newlyRenamedTopicIds = null,
    Object? editingMessageId = freezed,
    Object? originalEditingContent = freezed,
    Object? editingContent = freezed,
    Object? isEditing = null,
    Object? isSearching = null,
    Object? searchQuery = null,
    Object? searchResults = null,
    Object? currentSearchIndex = null,
    Object? isSearchLoading = null,
    Object? searchError = freezed,
    Object? processingMessageIds = null,
    Object? regeneratingMessageIds = null,
    Object? translatingMessageIds = null,
    Object? deletingMessageIds = null,
    Object? isModalOpen = null,
    Object? currentModalType = freezed,
    Object? isSidebarCollapsed = null,
    Object? isSettingsPanelOpen = null,
    Object? currentViewMode = null,
    Object? isDragging = null,
    Object? dragItemType = freezed,
    Object? dragItemData = null,
    Object? keyboardShortcutsEnabled = null,
    Object? pressedModifierKeys = null,
    Object? isDebugMode = null,
    Object? showPerformanceMetrics = null,
    Object? lastInteractionTime = freezed,
    Object? activeNotifications = null,
    Object? notificationsMuted = null,
  }) {
    return _then(_$RuntimeStateImpl(
      isMultiSelectMode: null == isMultiSelectMode
          ? _value.isMultiSelectMode
          : isMultiSelectMode // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedMessageIds: null == selectedMessageIds
          ? _value._selectedMessageIds
          : selectedMessageIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      isSelectionForDeletion: null == isSelectionForDeletion
          ? _value.isSelectionForDeletion
          : isSelectionForDeletion // ignore: cast_nullable_to_non_nullable
              as bool,
      activeTopicId: freezed == activeTopicId
          ? _value.activeTopicId
          : activeTopicId // ignore: cast_nullable_to_non_nullable
              as String?,
      renamingTopicIds: null == renamingTopicIds
          ? _value._renamingTopicIds
          : renamingTopicIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      newlyRenamedTopicIds: null == newlyRenamedTopicIds
          ? _value._newlyRenamedTopicIds
          : newlyRenamedTopicIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      editingMessageId: freezed == editingMessageId
          ? _value.editingMessageId
          : editingMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      originalEditingContent: freezed == originalEditingContent
          ? _value.originalEditingContent
          : originalEditingContent // ignore: cast_nullable_to_non_nullable
              as String?,
      editingContent: freezed == editingContent
          ? _value.editingContent
          : editingContent // ignore: cast_nullable_to_non_nullable
              as String?,
      isEditing: null == isEditing
          ? _value.isEditing
          : isEditing // ignore: cast_nullable_to_non_nullable
              as bool,
      isSearching: null == isSearching
          ? _value.isSearching
          : isSearching // ignore: cast_nullable_to_non_nullable
              as bool,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      searchResults: null == searchResults
          ? _value._searchResults
          : searchResults // ignore: cast_nullable_to_non_nullable
              as List<SearchResult>,
      currentSearchIndex: null == currentSearchIndex
          ? _value.currentSearchIndex
          : currentSearchIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isSearchLoading: null == isSearchLoading
          ? _value.isSearchLoading
          : isSearchLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      searchError: freezed == searchError
          ? _value.searchError
          : searchError // ignore: cast_nullable_to_non_nullable
              as String?,
      processingMessageIds: null == processingMessageIds
          ? _value._processingMessageIds
          : processingMessageIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      regeneratingMessageIds: null == regeneratingMessageIds
          ? _value._regeneratingMessageIds
          : regeneratingMessageIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      translatingMessageIds: null == translatingMessageIds
          ? _value._translatingMessageIds
          : translatingMessageIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      deletingMessageIds: null == deletingMessageIds
          ? _value._deletingMessageIds
          : deletingMessageIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      isModalOpen: null == isModalOpen
          ? _value.isModalOpen
          : isModalOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      currentModalType: freezed == currentModalType
          ? _value.currentModalType
          : currentModalType // ignore: cast_nullable_to_non_nullable
              as String?,
      isSidebarCollapsed: null == isSidebarCollapsed
          ? _value.isSidebarCollapsed
          : isSidebarCollapsed // ignore: cast_nullable_to_non_nullable
              as bool,
      isSettingsPanelOpen: null == isSettingsPanelOpen
          ? _value.isSettingsPanelOpen
          : isSettingsPanelOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      currentViewMode: null == currentViewMode
          ? _value.currentViewMode
          : currentViewMode // ignore: cast_nullable_to_non_nullable
              as ViewMode,
      isDragging: null == isDragging
          ? _value.isDragging
          : isDragging // ignore: cast_nullable_to_non_nullable
              as bool,
      dragItemType: freezed == dragItemType
          ? _value.dragItemType
          : dragItemType // ignore: cast_nullable_to_non_nullable
              as String?,
      dragItemData: null == dragItemData
          ? _value._dragItemData
          : dragItemData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      keyboardShortcutsEnabled: null == keyboardShortcutsEnabled
          ? _value.keyboardShortcutsEnabled
          : keyboardShortcutsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      pressedModifierKeys: null == pressedModifierKeys
          ? _value._pressedModifierKeys
          : pressedModifierKeys // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      isDebugMode: null == isDebugMode
          ? _value.isDebugMode
          : isDebugMode // ignore: cast_nullable_to_non_nullable
              as bool,
      showPerformanceMetrics: null == showPerformanceMetrics
          ? _value.showPerformanceMetrics
          : showPerformanceMetrics // ignore: cast_nullable_to_non_nullable
              as bool,
      lastInteractionTime: freezed == lastInteractionTime
          ? _value.lastInteractionTime
          : lastInteractionTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      activeNotifications: null == activeNotifications
          ? _value._activeNotifications
          : activeNotifications // ignore: cast_nullable_to_non_nullable
              as List<RuntimeNotification>,
      notificationsMuted: null == notificationsMuted
          ? _value.notificationsMuted
          : notificationsMuted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$RuntimeStateImpl extends _RuntimeState {
  const _$RuntimeStateImpl(
      {this.isMultiSelectMode = false,
      final Set<String> selectedMessageIds = const {},
      this.isSelectionForDeletion = false,
      this.activeTopicId = null,
      final Set<String> renamingTopicIds = const {},
      final Set<String> newlyRenamedTopicIds = const {},
      this.editingMessageId = null,
      this.originalEditingContent = null,
      this.editingContent = null,
      this.isEditing = false,
      this.isSearching = false,
      this.searchQuery = '',
      final List<SearchResult> searchResults = const [],
      this.currentSearchIndex = 0,
      this.isSearchLoading = false,
      this.searchError = null,
      final Set<String> processingMessageIds = const {},
      final Set<String> regeneratingMessageIds = const {},
      final Set<String> translatingMessageIds = const {},
      final Set<String> deletingMessageIds = const {},
      this.isModalOpen = false,
      this.currentModalType = null,
      this.isSidebarCollapsed = false,
      this.isSettingsPanelOpen = false,
      this.currentViewMode = ViewMode.chat,
      this.isDragging = false,
      this.dragItemType = null,
      final Map<String, dynamic> dragItemData = const {},
      this.keyboardShortcutsEnabled = true,
      final Set<String> pressedModifierKeys = const {},
      this.isDebugMode = false,
      this.showPerformanceMetrics = false,
      this.lastInteractionTime = null,
      final List<RuntimeNotification> activeNotifications = const [],
      this.notificationsMuted = false})
      : _selectedMessageIds = selectedMessageIds,
        _renamingTopicIds = renamingTopicIds,
        _newlyRenamedTopicIds = newlyRenamedTopicIds,
        _searchResults = searchResults,
        _processingMessageIds = processingMessageIds,
        _regeneratingMessageIds = regeneratingMessageIds,
        _translatingMessageIds = translatingMessageIds,
        _deletingMessageIds = deletingMessageIds,
        _dragItemData = dragItemData,
        _pressedModifierKeys = pressedModifierKeys,
        _activeNotifications = activeNotifications,
        super._();

// === Multi-Selection Mode (Cherry Studio: isMultiSelectMode) ===
  /// Whether multi-select mode is active
  @override
  @JsonKey()
  final bool isMultiSelectMode;

  /// Set of selected message IDs
  final Set<String> _selectedMessageIds;

  /// Set of selected message IDs
  @override
  @JsonKey()
  Set<String> get selectedMessageIds {
    if (_selectedMessageIds is EqualUnmodifiableSetView)
      return _selectedMessageIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_selectedMessageIds);
  }

  /// Whether selection mode is for deletion
  @override
  @JsonKey()
  final bool isSelectionForDeletion;
// === Topic/Conversation Management (Cherry Studio: activeTopic) ===
  /// Currently active topic/conversation ID
  @override
  @JsonKey()
  final String? activeTopicId;

  /// Topic IDs currently being renamed
  final Set<String> _renamingTopicIds;

  /// Topic IDs currently being renamed
  @override
  @JsonKey()
  Set<String> get renamingTopicIds {
    if (_renamingTopicIds is EqualUnmodifiableSetView) return _renamingTopicIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_renamingTopicIds);
  }

  /// Topic IDs that were recently renamed (for UI feedback)
  final Set<String> _newlyRenamedTopicIds;

  /// Topic IDs that were recently renamed (for UI feedback)
  @override
  @JsonKey()
  Set<String> get newlyRenamedTopicIds {
    if (_newlyRenamedTopicIds is EqualUnmodifiableSetView)
      return _newlyRenamedTopicIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_newlyRenamedTopicIds);
  }

// === Message Editing State ===
  /// Message ID currently being edited
  @override
  @JsonKey()
  final String? editingMessageId;

  /// Original content before editing (for cancel functionality)
  @override
  @JsonKey()
  final String? originalEditingContent;

  /// Current editing content
  @override
  @JsonKey()
  final String? editingContent;

  /// Whether editing is in progress
  @override
  @JsonKey()
  final bool isEditing;
// === Search State ===
  /// Whether search mode is active
  @override
  @JsonKey()
  final bool isSearching;

  /// Current search query
  @override
  @JsonKey()
  final String searchQuery;

  /// Search results
  final List<SearchResult> _searchResults;

  /// Search results
  @override
  @JsonKey()
  List<SearchResult> get searchResults {
    if (_searchResults is EqualUnmodifiableListView) return _searchResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_searchResults);
  }

  /// Current search result index (for navigation)
  @override
  @JsonKey()
  final int currentSearchIndex;

  /// Whether search is loading
  @override
  @JsonKey()
  final bool isSearchLoading;

  /// Search error message
  @override
  @JsonKey()
  final String? searchError;
// === Message Operations State ===
  /// Messages currently being processed for operations
  final Set<String> _processingMessageIds;
// === Message Operations State ===
  /// Messages currently being processed for operations
  @override
  @JsonKey()
  Set<String> get processingMessageIds {
    if (_processingMessageIds is EqualUnmodifiableSetView)
      return _processingMessageIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_processingMessageIds);
  }

  /// Messages being regenerated
  final Set<String> _regeneratingMessageIds;

  /// Messages being regenerated
  @override
  @JsonKey()
  Set<String> get regeneratingMessageIds {
    if (_regeneratingMessageIds is EqualUnmodifiableSetView)
      return _regeneratingMessageIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_regeneratingMessageIds);
  }

  /// Messages being translated
  final Set<String> _translatingMessageIds;

  /// Messages being translated
  @override
  @JsonKey()
  Set<String> get translatingMessageIds {
    if (_translatingMessageIds is EqualUnmodifiableSetView)
      return _translatingMessageIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_translatingMessageIds);
  }

  /// Messages being deleted
  final Set<String> _deletingMessageIds;

  /// Messages being deleted
  @override
  @JsonKey()
  Set<String> get deletingMessageIds {
    if (_deletingMessageIds is EqualUnmodifiableSetView)
      return _deletingMessageIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_deletingMessageIds);
  }

// === UI Interaction State ===
  /// Whether any modal/dialog is open
  @override
  @JsonKey()
  final bool isModalOpen;

  /// Current modal type
  @override
  @JsonKey()
  final String? currentModalType;

  /// Whether sidebar is collapsed
  @override
  @JsonKey()
  final bool isSidebarCollapsed;

  /// Whether settings panel is open
  @override
  @JsonKey()
  final bool isSettingsPanelOpen;

  /// Current view mode (chat, settings, etc.)
  @override
  @JsonKey()
  final ViewMode currentViewMode;
// === Drag and Drop State ===
  /// Whether drag operation is in progress
  @override
  @JsonKey()
  final bool isDragging;

  /// Type of item being dragged
  @override
  @JsonKey()
  final String? dragItemType;

  /// Data of item being dragged
  final Map<String, dynamic> _dragItemData;

  /// Data of item being dragged
  @override
  @JsonKey()
  Map<String, dynamic> get dragItemData {
    if (_dragItemData is EqualUnmodifiableMapView) return _dragItemData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_dragItemData);
  }

// === Keyboard Shortcuts State ===
  /// Whether keyboard shortcuts are enabled
  @override
  @JsonKey()
  final bool keyboardShortcutsEnabled;

  /// Currently pressed modifier keys
  final Set<String> _pressedModifierKeys;

  /// Currently pressed modifier keys
  @override
  @JsonKey()
  Set<String> get pressedModifierKeys {
    if (_pressedModifierKeys is EqualUnmodifiableSetView)
      return _pressedModifierKeys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_pressedModifierKeys);
  }

// === Performance and Debug State ===
  /// Whether debug mode is enabled
  @override
  @JsonKey()
  final bool isDebugMode;

  /// Performance metrics visibility
  @override
  @JsonKey()
  final bool showPerformanceMetrics;

  /// Last interaction timestamp
  @override
  @JsonKey()
  final DateTime? lastInteractionTime;
// === Notification State ===
  /// Active notifications
  final List<RuntimeNotification> _activeNotifications;
// === Notification State ===
  /// Active notifications
  @override
  @JsonKey()
  List<RuntimeNotification> get activeNotifications {
    if (_activeNotifications is EqualUnmodifiableListView)
      return _activeNotifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeNotifications);
  }

  /// Whether notifications are muted
  @override
  @JsonKey()
  final bool notificationsMuted;

  @override
  String toString() {
    return 'RuntimeState(isMultiSelectMode: $isMultiSelectMode, selectedMessageIds: $selectedMessageIds, isSelectionForDeletion: $isSelectionForDeletion, activeTopicId: $activeTopicId, renamingTopicIds: $renamingTopicIds, newlyRenamedTopicIds: $newlyRenamedTopicIds, editingMessageId: $editingMessageId, originalEditingContent: $originalEditingContent, editingContent: $editingContent, isEditing: $isEditing, isSearching: $isSearching, searchQuery: $searchQuery, searchResults: $searchResults, currentSearchIndex: $currentSearchIndex, isSearchLoading: $isSearchLoading, searchError: $searchError, processingMessageIds: $processingMessageIds, regeneratingMessageIds: $regeneratingMessageIds, translatingMessageIds: $translatingMessageIds, deletingMessageIds: $deletingMessageIds, isModalOpen: $isModalOpen, currentModalType: $currentModalType, isSidebarCollapsed: $isSidebarCollapsed, isSettingsPanelOpen: $isSettingsPanelOpen, currentViewMode: $currentViewMode, isDragging: $isDragging, dragItemType: $dragItemType, dragItemData: $dragItemData, keyboardShortcutsEnabled: $keyboardShortcutsEnabled, pressedModifierKeys: $pressedModifierKeys, isDebugMode: $isDebugMode, showPerformanceMetrics: $showPerformanceMetrics, lastInteractionTime: $lastInteractionTime, activeNotifications: $activeNotifications, notificationsMuted: $notificationsMuted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RuntimeStateImpl &&
            (identical(other.isMultiSelectMode, isMultiSelectMode) ||
                other.isMultiSelectMode == isMultiSelectMode) &&
            const DeepCollectionEquality()
                .equals(other._selectedMessageIds, _selectedMessageIds) &&
            (identical(other.isSelectionForDeletion, isSelectionForDeletion) ||
                other.isSelectionForDeletion == isSelectionForDeletion) &&
            (identical(other.activeTopicId, activeTopicId) ||
                other.activeTopicId == activeTopicId) &&
            const DeepCollectionEquality()
                .equals(other._renamingTopicIds, _renamingTopicIds) &&
            const DeepCollectionEquality()
                .equals(other._newlyRenamedTopicIds, _newlyRenamedTopicIds) &&
            (identical(other.editingMessageId, editingMessageId) ||
                other.editingMessageId == editingMessageId) &&
            (identical(other.originalEditingContent, originalEditingContent) ||
                other.originalEditingContent == originalEditingContent) &&
            (identical(other.editingContent, editingContent) ||
                other.editingContent == editingContent) &&
            (identical(other.isEditing, isEditing) ||
                other.isEditing == isEditing) &&
            (identical(other.isSearching, isSearching) ||
                other.isSearching == isSearching) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            const DeepCollectionEquality()
                .equals(other._searchResults, _searchResults) &&
            (identical(other.currentSearchIndex, currentSearchIndex) ||
                other.currentSearchIndex == currentSearchIndex) &&
            (identical(other.isSearchLoading, isSearchLoading) ||
                other.isSearchLoading == isSearchLoading) &&
            (identical(other.searchError, searchError) ||
                other.searchError == searchError) &&
            const DeepCollectionEquality()
                .equals(other._processingMessageIds, _processingMessageIds) &&
            const DeepCollectionEquality().equals(
                other._regeneratingMessageIds, _regeneratingMessageIds) &&
            const DeepCollectionEquality()
                .equals(other._translatingMessageIds, _translatingMessageIds) &&
            const DeepCollectionEquality()
                .equals(other._deletingMessageIds, _deletingMessageIds) &&
            (identical(other.isModalOpen, isModalOpen) ||
                other.isModalOpen == isModalOpen) &&
            (identical(other.currentModalType, currentModalType) ||
                other.currentModalType == currentModalType) &&
            (identical(other.isSidebarCollapsed, isSidebarCollapsed) ||
                other.isSidebarCollapsed == isSidebarCollapsed) &&
            (identical(other.isSettingsPanelOpen, isSettingsPanelOpen) ||
                other.isSettingsPanelOpen == isSettingsPanelOpen) &&
            (identical(other.currentViewMode, currentViewMode) ||
                other.currentViewMode == currentViewMode) &&
            (identical(other.isDragging, isDragging) ||
                other.isDragging == isDragging) &&
            (identical(other.dragItemType, dragItemType) ||
                other.dragItemType == dragItemType) &&
            const DeepCollectionEquality()
                .equals(other._dragItemData, _dragItemData) &&
            (identical(
                    other.keyboardShortcutsEnabled, keyboardShortcutsEnabled) ||
                other.keyboardShortcutsEnabled == keyboardShortcutsEnabled) &&
            const DeepCollectionEquality()
                .equals(other._pressedModifierKeys, _pressedModifierKeys) &&
            (identical(other.isDebugMode, isDebugMode) ||
                other.isDebugMode == isDebugMode) &&
            (identical(other.showPerformanceMetrics, showPerformanceMetrics) ||
                other.showPerformanceMetrics == showPerformanceMetrics) &&
            (identical(other.lastInteractionTime, lastInteractionTime) ||
                other.lastInteractionTime == lastInteractionTime) &&
            const DeepCollectionEquality()
                .equals(other._activeNotifications, _activeNotifications) &&
            (identical(other.notificationsMuted, notificationsMuted) ||
                other.notificationsMuted == notificationsMuted));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        isMultiSelectMode,
        const DeepCollectionEquality().hash(_selectedMessageIds),
        isSelectionForDeletion,
        activeTopicId,
        const DeepCollectionEquality().hash(_renamingTopicIds),
        const DeepCollectionEquality().hash(_newlyRenamedTopicIds),
        editingMessageId,
        originalEditingContent,
        editingContent,
        isEditing,
        isSearching,
        searchQuery,
        const DeepCollectionEquality().hash(_searchResults),
        currentSearchIndex,
        isSearchLoading,
        searchError,
        const DeepCollectionEquality().hash(_processingMessageIds),
        const DeepCollectionEquality().hash(_regeneratingMessageIds),
        const DeepCollectionEquality().hash(_translatingMessageIds),
        const DeepCollectionEquality().hash(_deletingMessageIds),
        isModalOpen,
        currentModalType,
        isSidebarCollapsed,
        isSettingsPanelOpen,
        currentViewMode,
        isDragging,
        dragItemType,
        const DeepCollectionEquality().hash(_dragItemData),
        keyboardShortcutsEnabled,
        const DeepCollectionEquality().hash(_pressedModifierKeys),
        isDebugMode,
        showPerformanceMetrics,
        lastInteractionTime,
        const DeepCollectionEquality().hash(_activeNotifications),
        notificationsMuted
      ]);

  /// Create a copy of RuntimeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RuntimeStateImplCopyWith<_$RuntimeStateImpl> get copyWith =>
      __$$RuntimeStateImplCopyWithImpl<_$RuntimeStateImpl>(this, _$identity);
}

abstract class _RuntimeState extends RuntimeState {
  const factory _RuntimeState(
      {final bool isMultiSelectMode,
      final Set<String> selectedMessageIds,
      final bool isSelectionForDeletion,
      final String? activeTopicId,
      final Set<String> renamingTopicIds,
      final Set<String> newlyRenamedTopicIds,
      final String? editingMessageId,
      final String? originalEditingContent,
      final String? editingContent,
      final bool isEditing,
      final bool isSearching,
      final String searchQuery,
      final List<SearchResult> searchResults,
      final int currentSearchIndex,
      final bool isSearchLoading,
      final String? searchError,
      final Set<String> processingMessageIds,
      final Set<String> regeneratingMessageIds,
      final Set<String> translatingMessageIds,
      final Set<String> deletingMessageIds,
      final bool isModalOpen,
      final String? currentModalType,
      final bool isSidebarCollapsed,
      final bool isSettingsPanelOpen,
      final ViewMode currentViewMode,
      final bool isDragging,
      final String? dragItemType,
      final Map<String, dynamic> dragItemData,
      final bool keyboardShortcutsEnabled,
      final Set<String> pressedModifierKeys,
      final bool isDebugMode,
      final bool showPerformanceMetrics,
      final DateTime? lastInteractionTime,
      final List<RuntimeNotification> activeNotifications,
      final bool notificationsMuted}) = _$RuntimeStateImpl;
  const _RuntimeState._() : super._();

// === Multi-Selection Mode (Cherry Studio: isMultiSelectMode) ===
  /// Whether multi-select mode is active
  @override
  bool get isMultiSelectMode;

  /// Set of selected message IDs
  @override
  Set<String> get selectedMessageIds;

  /// Whether selection mode is for deletion
  @override
  bool
      get isSelectionForDeletion; // === Topic/Conversation Management (Cherry Studio: activeTopic) ===
  /// Currently active topic/conversation ID
  @override
  String? get activeTopicId;

  /// Topic IDs currently being renamed
  @override
  Set<String> get renamingTopicIds;

  /// Topic IDs that were recently renamed (for UI feedback)
  @override
  Set<String> get newlyRenamedTopicIds; // === Message Editing State ===
  /// Message ID currently being edited
  @override
  String? get editingMessageId;

  /// Original content before editing (for cancel functionality)
  @override
  String? get originalEditingContent;

  /// Current editing content
  @override
  String? get editingContent;

  /// Whether editing is in progress
  @override
  bool get isEditing; // === Search State ===
  /// Whether search mode is active
  @override
  bool get isSearching;

  /// Current search query
  @override
  String get searchQuery;

  /// Search results
  @override
  List<SearchResult> get searchResults;

  /// Current search result index (for navigation)
  @override
  int get currentSearchIndex;

  /// Whether search is loading
  @override
  bool get isSearchLoading;

  /// Search error message
  @override
  String? get searchError; // === Message Operations State ===
  /// Messages currently being processed for operations
  @override
  Set<String> get processingMessageIds;

  /// Messages being regenerated
  @override
  Set<String> get regeneratingMessageIds;

  /// Messages being translated
  @override
  Set<String> get translatingMessageIds;

  /// Messages being deleted
  @override
  Set<String> get deletingMessageIds; // === UI Interaction State ===
  /// Whether any modal/dialog is open
  @override
  bool get isModalOpen;

  /// Current modal type
  @override
  String? get currentModalType;

  /// Whether sidebar is collapsed
  @override
  bool get isSidebarCollapsed;

  /// Whether settings panel is open
  @override
  bool get isSettingsPanelOpen;

  /// Current view mode (chat, settings, etc.)
  @override
  ViewMode get currentViewMode; // === Drag and Drop State ===
  /// Whether drag operation is in progress
  @override
  bool get isDragging;

  /// Type of item being dragged
  @override
  String? get dragItemType;

  /// Data of item being dragged
  @override
  Map<String, dynamic> get dragItemData; // === Keyboard Shortcuts State ===
  /// Whether keyboard shortcuts are enabled
  @override
  bool get keyboardShortcutsEnabled;

  /// Currently pressed modifier keys
  @override
  Set<String> get pressedModifierKeys; // === Performance and Debug State ===
  /// Whether debug mode is enabled
  @override
  bool get isDebugMode;

  /// Performance metrics visibility
  @override
  bool get showPerformanceMetrics;

  /// Last interaction timestamp
  @override
  DateTime? get lastInteractionTime; // === Notification State ===
  /// Active notifications
  @override
  List<RuntimeNotification> get activeNotifications;

  /// Whether notifications are muted
  @override
  bool get notificationsMuted;

  /// Create a copy of RuntimeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RuntimeStateImplCopyWith<_$RuntimeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RuntimeNotification {
  /// Notification ID
  String get id => throw _privateConstructorUsedError;

  /// Notification type
  NotificationType get type => throw _privateConstructorUsedError;

  /// Notification title
  String get title => throw _privateConstructorUsedError;

  /// Notification message
  String get message => throw _privateConstructorUsedError;

  /// Whether notification is persistent (doesn't auto-dismiss)
  bool get isPersistent => throw _privateConstructorUsedError;

  /// Auto-dismiss duration in seconds
  int get autoDismissSeconds => throw _privateConstructorUsedError;

  /// Creation timestamp
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Whether notification was read
  bool get isRead => throw _privateConstructorUsedError;

  /// Action buttons
  List<NotificationAction> get actions => throw _privateConstructorUsedError;

  /// Additional metadata
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Create a copy of RuntimeNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RuntimeNotificationCopyWith<RuntimeNotification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RuntimeNotificationCopyWith<$Res> {
  factory $RuntimeNotificationCopyWith(
          RuntimeNotification value, $Res Function(RuntimeNotification) then) =
      _$RuntimeNotificationCopyWithImpl<$Res, RuntimeNotification>;
  @useResult
  $Res call(
      {String id,
      NotificationType type,
      String title,
      String message,
      bool isPersistent,
      int autoDismissSeconds,
      DateTime createdAt,
      bool isRead,
      List<NotificationAction> actions,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$RuntimeNotificationCopyWithImpl<$Res, $Val extends RuntimeNotification>
    implements $RuntimeNotificationCopyWith<$Res> {
  _$RuntimeNotificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RuntimeNotification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? message = null,
    Object? isPersistent = null,
    Object? autoDismissSeconds = null,
    Object? createdAt = null,
    Object? isRead = null,
    Object? actions = null,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      isPersistent: null == isPersistent
          ? _value.isPersistent
          : isPersistent // ignore: cast_nullable_to_non_nullable
              as bool,
      autoDismissSeconds: null == autoDismissSeconds
          ? _value.autoDismissSeconds
          : autoDismissSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      actions: null == actions
          ? _value.actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<NotificationAction>,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RuntimeNotificationImplCopyWith<$Res>
    implements $RuntimeNotificationCopyWith<$Res> {
  factory _$$RuntimeNotificationImplCopyWith(_$RuntimeNotificationImpl value,
          $Res Function(_$RuntimeNotificationImpl) then) =
      __$$RuntimeNotificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      NotificationType type,
      String title,
      String message,
      bool isPersistent,
      int autoDismissSeconds,
      DateTime createdAt,
      bool isRead,
      List<NotificationAction> actions,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$RuntimeNotificationImplCopyWithImpl<$Res>
    extends _$RuntimeNotificationCopyWithImpl<$Res, _$RuntimeNotificationImpl>
    implements _$$RuntimeNotificationImplCopyWith<$Res> {
  __$$RuntimeNotificationImplCopyWithImpl(_$RuntimeNotificationImpl _value,
      $Res Function(_$RuntimeNotificationImpl) _then)
      : super(_value, _then);

  /// Create a copy of RuntimeNotification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? message = null,
    Object? isPersistent = null,
    Object? autoDismissSeconds = null,
    Object? createdAt = null,
    Object? isRead = null,
    Object? actions = null,
    Object? metadata = null,
  }) {
    return _then(_$RuntimeNotificationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      isPersistent: null == isPersistent
          ? _value.isPersistent
          : isPersistent // ignore: cast_nullable_to_non_nullable
              as bool,
      autoDismissSeconds: null == autoDismissSeconds
          ? _value.autoDismissSeconds
          : autoDismissSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      actions: null == actions
          ? _value._actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<NotificationAction>,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$RuntimeNotificationImpl implements _RuntimeNotification {
  const _$RuntimeNotificationImpl(
      {required this.id,
      required this.type,
      required this.title,
      this.message = '',
      this.isPersistent = false,
      this.autoDismissSeconds = 5,
      required this.createdAt,
      this.isRead = false,
      final List<NotificationAction> actions = const [],
      final Map<String, dynamic> metadata = const {}})
      : _actions = actions,
        _metadata = metadata;

  /// Notification ID
  @override
  final String id;

  /// Notification type
  @override
  final NotificationType type;

  /// Notification title
  @override
  final String title;

  /// Notification message
  @override
  @JsonKey()
  final String message;

  /// Whether notification is persistent (doesn't auto-dismiss)
  @override
  @JsonKey()
  final bool isPersistent;

  /// Auto-dismiss duration in seconds
  @override
  @JsonKey()
  final int autoDismissSeconds;

  /// Creation timestamp
  @override
  final DateTime createdAt;

  /// Whether notification was read
  @override
  @JsonKey()
  final bool isRead;

  /// Action buttons
  final List<NotificationAction> _actions;

  /// Action buttons
  @override
  @JsonKey()
  List<NotificationAction> get actions {
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actions);
  }

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
    return 'RuntimeNotification(id: $id, type: $type, title: $title, message: $message, isPersistent: $isPersistent, autoDismissSeconds: $autoDismissSeconds, createdAt: $createdAt, isRead: $isRead, actions: $actions, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RuntimeNotificationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.isPersistent, isPersistent) ||
                other.isPersistent == isPersistent) &&
            (identical(other.autoDismissSeconds, autoDismissSeconds) ||
                other.autoDismissSeconds == autoDismissSeconds) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            const DeepCollectionEquality().equals(other._actions, _actions) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      title,
      message,
      isPersistent,
      autoDismissSeconds,
      createdAt,
      isRead,
      const DeepCollectionEquality().hash(_actions),
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of RuntimeNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RuntimeNotificationImplCopyWith<_$RuntimeNotificationImpl> get copyWith =>
      __$$RuntimeNotificationImplCopyWithImpl<_$RuntimeNotificationImpl>(
          this, _$identity);
}

abstract class _RuntimeNotification implements RuntimeNotification {
  const factory _RuntimeNotification(
      {required final String id,
      required final NotificationType type,
      required final String title,
      final String message,
      final bool isPersistent,
      final int autoDismissSeconds,
      required final DateTime createdAt,
      final bool isRead,
      final List<NotificationAction> actions,
      final Map<String, dynamic> metadata}) = _$RuntimeNotificationImpl;

  /// Notification ID
  @override
  String get id;

  /// Notification type
  @override
  NotificationType get type;

  /// Notification title
  @override
  String get title;

  /// Notification message
  @override
  String get message;

  /// Whether notification is persistent (doesn't auto-dismiss)
  @override
  bool get isPersistent;

  /// Auto-dismiss duration in seconds
  @override
  int get autoDismissSeconds;

  /// Creation timestamp
  @override
  DateTime get createdAt;

  /// Whether notification was read
  @override
  bool get isRead;

  /// Action buttons
  @override
  List<NotificationAction> get actions;

  /// Additional metadata
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of RuntimeNotification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RuntimeNotificationImplCopyWith<_$RuntimeNotificationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$NotificationAction {
  /// Action ID
  String get id => throw _privateConstructorUsedError;

  /// Action label
  String get label => throw _privateConstructorUsedError;

  /// Action type
  NotificationActionType get type => throw _privateConstructorUsedError;

  /// Whether action is primary
  bool get isPrimary => throw _privateConstructorUsedError;

  /// Whether action dismisses notification
  bool get dismissesNotification => throw _privateConstructorUsedError;

  /// Action metadata
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationActionCopyWith<NotificationAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationActionCopyWith<$Res> {
  factory $NotificationActionCopyWith(
          NotificationAction value, $Res Function(NotificationAction) then) =
      _$NotificationActionCopyWithImpl<$Res, NotificationAction>;
  @useResult
  $Res call(
      {String id,
      String label,
      NotificationActionType type,
      bool isPrimary,
      bool dismissesNotification,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$NotificationActionCopyWithImpl<$Res, $Val extends NotificationAction>
    implements $NotificationActionCopyWith<$Res> {
  _$NotificationActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? type = null,
    Object? isPrimary = null,
    Object? dismissesNotification = null,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationActionType,
      isPrimary: null == isPrimary
          ? _value.isPrimary
          : isPrimary // ignore: cast_nullable_to_non_nullable
              as bool,
      dismissesNotification: null == dismissesNotification
          ? _value.dismissesNotification
          : dismissesNotification // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationActionImplCopyWith<$Res>
    implements $NotificationActionCopyWith<$Res> {
  factory _$$NotificationActionImplCopyWith(_$NotificationActionImpl value,
          $Res Function(_$NotificationActionImpl) then) =
      __$$NotificationActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String label,
      NotificationActionType type,
      bool isPrimary,
      bool dismissesNotification,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$NotificationActionImplCopyWithImpl<$Res>
    extends _$NotificationActionCopyWithImpl<$Res, _$NotificationActionImpl>
    implements _$$NotificationActionImplCopyWith<$Res> {
  __$$NotificationActionImplCopyWithImpl(_$NotificationActionImpl _value,
      $Res Function(_$NotificationActionImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? type = null,
    Object? isPrimary = null,
    Object? dismissesNotification = null,
    Object? metadata = null,
  }) {
    return _then(_$NotificationActionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationActionType,
      isPrimary: null == isPrimary
          ? _value.isPrimary
          : isPrimary // ignore: cast_nullable_to_non_nullable
              as bool,
      dismissesNotification: null == dismissesNotification
          ? _value.dismissesNotification
          : dismissesNotification // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$NotificationActionImpl implements _NotificationAction {
  const _$NotificationActionImpl(
      {required this.id,
      required this.label,
      this.type = NotificationActionType.button,
      this.isPrimary = false,
      this.dismissesNotification = true,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata;

  /// Action ID
  @override
  final String id;

  /// Action label
  @override
  final String label;

  /// Action type
  @override
  @JsonKey()
  final NotificationActionType type;

  /// Whether action is primary
  @override
  @JsonKey()
  final bool isPrimary;

  /// Whether action dismisses notification
  @override
  @JsonKey()
  final bool dismissesNotification;

  /// Action metadata
  final Map<String, dynamic> _metadata;

  /// Action metadata
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'NotificationAction(id: $id, label: $label, type: $type, isPrimary: $isPrimary, dismissesNotification: $dismissesNotification, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationActionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary) &&
            (identical(other.dismissesNotification, dismissesNotification) ||
                other.dismissesNotification == dismissesNotification) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, label, type, isPrimary,
      dismissesNotification, const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationActionImplCopyWith<_$NotificationActionImpl> get copyWith =>
      __$$NotificationActionImplCopyWithImpl<_$NotificationActionImpl>(
          this, _$identity);
}

abstract class _NotificationAction implements NotificationAction {
  const factory _NotificationAction(
      {required final String id,
      required final String label,
      final NotificationActionType type,
      final bool isPrimary,
      final bool dismissesNotification,
      final Map<String, dynamic> metadata}) = _$NotificationActionImpl;

  /// Action ID
  @override
  String get id;

  /// Action label
  @override
  String get label;

  /// Action type
  @override
  NotificationActionType get type;

  /// Whether action is primary
  @override
  bool get isPrimary;

  /// Whether action dismisses notification
  @override
  bool get dismissesNotification;

  /// Action metadata
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationActionImplCopyWith<_$NotificationActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
