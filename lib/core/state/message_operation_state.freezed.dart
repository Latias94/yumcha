// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_operation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MessageOperationState {
// === Active Operations ===
  /// Map of message ID to operation type currently being performed
  Map<String, MessageOperationType> get activeOperations =>
      throw _privateConstructorUsedError;

  /// Map of message ID to operation progress (0.0 to 1.0)
  Map<String, double> get operationProgress =>
      throw _privateConstructorUsedError;

  /// Map of message ID to operation error messages
  Map<String, String> get operationErrors =>
      throw _privateConstructorUsedError; // === Branch Management ===
  /// Map of message ID to list of branch IDs
  Map<String, List<String>> get messageBranches =>
      throw _privateConstructorUsedError;

  /// Currently active branch ID
  String? get activeBranchId => throw _privateConstructorUsedError;

  /// Messages that have branches
  Set<String> get messagesWithBranches =>
      throw _privateConstructorUsedError; // === Pause/Resume State ===
  /// Messages that are currently paused
  Set<String> get pausedMessageIds => throw _privateConstructorUsedError;

  /// Messages that can be resumed
  Set<String> get resumableMessageIds =>
      throw _privateConstructorUsedError; // === Copy/Export State ===
  /// Messages currently being copied
  Set<String> get copyingMessageIds => throw _privateConstructorUsedError;

  /// Messages currently being exported
  Set<String> get exportingMessageIds => throw _privateConstructorUsedError;

  /// Last copied content for clipboard management
  String? get lastCopiedContent =>
      throw _privateConstructorUsedError; // === Translation State ===
  /// Messages currently being translated
  Map<String, TranslationOperation> get translatingMessages =>
      throw _privateConstructorUsedError;

  /// Available translation languages
  List<String> get availableLanguages =>
      throw _privateConstructorUsedError; // === Regeneration State ===
  /// Messages currently being regenerated
  Map<String, RegenerationOperation> get regeneratingMessages =>
      throw _privateConstructorUsedError;

  /// Regeneration options/settings
  RegenerationOptions get regenerationOptions =>
      throw _privateConstructorUsedError; // === Batch Operations ===
  /// Whether batch operation mode is active
  bool get isBatchMode => throw _privateConstructorUsedError;

  /// Selected messages for batch operations
  Set<String> get batchSelectedMessages => throw _privateConstructorUsedError;

  /// Current batch operation type
  BatchOperationType? get currentBatchOperation =>
      throw _privateConstructorUsedError;

  /// Batch operation progress
  double get batchProgress =>
      throw _privateConstructorUsedError; // === Operation History ===
  /// Recent operations for undo functionality
  List<OperationHistoryEntry> get operationHistory =>
      throw _privateConstructorUsedError;

  /// Maximum history entries to keep
  int get maxHistoryEntries =>
      throw _privateConstructorUsedError; // === Performance Metrics ===
  /// Total operations performed
  int get totalOperations => throw _privateConstructorUsedError;

  /// Average operation duration in milliseconds
  double get averageOperationDuration => throw _privateConstructorUsedError;

  /// Last operation timestamp
  DateTime? get lastOperationTime => throw _privateConstructorUsedError;

  /// Create a copy of MessageOperationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageOperationStateCopyWith<MessageOperationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageOperationStateCopyWith<$Res> {
  factory $MessageOperationStateCopyWith(MessageOperationState value,
          $Res Function(MessageOperationState) then) =
      _$MessageOperationStateCopyWithImpl<$Res, MessageOperationState>;
  @useResult
  $Res call(
      {Map<String, MessageOperationType> activeOperations,
      Map<String, double> operationProgress,
      Map<String, String> operationErrors,
      Map<String, List<String>> messageBranches,
      String? activeBranchId,
      Set<String> messagesWithBranches,
      Set<String> pausedMessageIds,
      Set<String> resumableMessageIds,
      Set<String> copyingMessageIds,
      Set<String> exportingMessageIds,
      String? lastCopiedContent,
      Map<String, TranslationOperation> translatingMessages,
      List<String> availableLanguages,
      Map<String, RegenerationOperation> regeneratingMessages,
      RegenerationOptions regenerationOptions,
      bool isBatchMode,
      Set<String> batchSelectedMessages,
      BatchOperationType? currentBatchOperation,
      double batchProgress,
      List<OperationHistoryEntry> operationHistory,
      int maxHistoryEntries,
      int totalOperations,
      double averageOperationDuration,
      DateTime? lastOperationTime});

  $RegenerationOptionsCopyWith<$Res> get regenerationOptions;
}

/// @nodoc
class _$MessageOperationStateCopyWithImpl<$Res,
        $Val extends MessageOperationState>
    implements $MessageOperationStateCopyWith<$Res> {
  _$MessageOperationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageOperationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activeOperations = null,
    Object? operationProgress = null,
    Object? operationErrors = null,
    Object? messageBranches = null,
    Object? activeBranchId = freezed,
    Object? messagesWithBranches = null,
    Object? pausedMessageIds = null,
    Object? resumableMessageIds = null,
    Object? copyingMessageIds = null,
    Object? exportingMessageIds = null,
    Object? lastCopiedContent = freezed,
    Object? translatingMessages = null,
    Object? availableLanguages = null,
    Object? regeneratingMessages = null,
    Object? regenerationOptions = null,
    Object? isBatchMode = null,
    Object? batchSelectedMessages = null,
    Object? currentBatchOperation = freezed,
    Object? batchProgress = null,
    Object? operationHistory = null,
    Object? maxHistoryEntries = null,
    Object? totalOperations = null,
    Object? averageOperationDuration = null,
    Object? lastOperationTime = freezed,
  }) {
    return _then(_value.copyWith(
      activeOperations: null == activeOperations
          ? _value.activeOperations
          : activeOperations // ignore: cast_nullable_to_non_nullable
              as Map<String, MessageOperationType>,
      operationProgress: null == operationProgress
          ? _value.operationProgress
          : operationProgress // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      operationErrors: null == operationErrors
          ? _value.operationErrors
          : operationErrors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      messageBranches: null == messageBranches
          ? _value.messageBranches
          : messageBranches // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
      activeBranchId: freezed == activeBranchId
          ? _value.activeBranchId
          : activeBranchId // ignore: cast_nullable_to_non_nullable
              as String?,
      messagesWithBranches: null == messagesWithBranches
          ? _value.messagesWithBranches
          : messagesWithBranches // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      pausedMessageIds: null == pausedMessageIds
          ? _value.pausedMessageIds
          : pausedMessageIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      resumableMessageIds: null == resumableMessageIds
          ? _value.resumableMessageIds
          : resumableMessageIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      copyingMessageIds: null == copyingMessageIds
          ? _value.copyingMessageIds
          : copyingMessageIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      exportingMessageIds: null == exportingMessageIds
          ? _value.exportingMessageIds
          : exportingMessageIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      lastCopiedContent: freezed == lastCopiedContent
          ? _value.lastCopiedContent
          : lastCopiedContent // ignore: cast_nullable_to_non_nullable
              as String?,
      translatingMessages: null == translatingMessages
          ? _value.translatingMessages
          : translatingMessages // ignore: cast_nullable_to_non_nullable
              as Map<String, TranslationOperation>,
      availableLanguages: null == availableLanguages
          ? _value.availableLanguages
          : availableLanguages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      regeneratingMessages: null == regeneratingMessages
          ? _value.regeneratingMessages
          : regeneratingMessages // ignore: cast_nullable_to_non_nullable
              as Map<String, RegenerationOperation>,
      regenerationOptions: null == regenerationOptions
          ? _value.regenerationOptions
          : regenerationOptions // ignore: cast_nullable_to_non_nullable
              as RegenerationOptions,
      isBatchMode: null == isBatchMode
          ? _value.isBatchMode
          : isBatchMode // ignore: cast_nullable_to_non_nullable
              as bool,
      batchSelectedMessages: null == batchSelectedMessages
          ? _value.batchSelectedMessages
          : batchSelectedMessages // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      currentBatchOperation: freezed == currentBatchOperation
          ? _value.currentBatchOperation
          : currentBatchOperation // ignore: cast_nullable_to_non_nullable
              as BatchOperationType?,
      batchProgress: null == batchProgress
          ? _value.batchProgress
          : batchProgress // ignore: cast_nullable_to_non_nullable
              as double,
      operationHistory: null == operationHistory
          ? _value.operationHistory
          : operationHistory // ignore: cast_nullable_to_non_nullable
              as List<OperationHistoryEntry>,
      maxHistoryEntries: null == maxHistoryEntries
          ? _value.maxHistoryEntries
          : maxHistoryEntries // ignore: cast_nullable_to_non_nullable
              as int,
      totalOperations: null == totalOperations
          ? _value.totalOperations
          : totalOperations // ignore: cast_nullable_to_non_nullable
              as int,
      averageOperationDuration: null == averageOperationDuration
          ? _value.averageOperationDuration
          : averageOperationDuration // ignore: cast_nullable_to_non_nullable
              as double,
      lastOperationTime: freezed == lastOperationTime
          ? _value.lastOperationTime
          : lastOperationTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of MessageOperationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RegenerationOptionsCopyWith<$Res> get regenerationOptions {
    return $RegenerationOptionsCopyWith<$Res>(_value.regenerationOptions,
        (value) {
      return _then(_value.copyWith(regenerationOptions: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MessageOperationStateImplCopyWith<$Res>
    implements $MessageOperationStateCopyWith<$Res> {
  factory _$$MessageOperationStateImplCopyWith(
          _$MessageOperationStateImpl value,
          $Res Function(_$MessageOperationStateImpl) then) =
      __$$MessageOperationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<String, MessageOperationType> activeOperations,
      Map<String, double> operationProgress,
      Map<String, String> operationErrors,
      Map<String, List<String>> messageBranches,
      String? activeBranchId,
      Set<String> messagesWithBranches,
      Set<String> pausedMessageIds,
      Set<String> resumableMessageIds,
      Set<String> copyingMessageIds,
      Set<String> exportingMessageIds,
      String? lastCopiedContent,
      Map<String, TranslationOperation> translatingMessages,
      List<String> availableLanguages,
      Map<String, RegenerationOperation> regeneratingMessages,
      RegenerationOptions regenerationOptions,
      bool isBatchMode,
      Set<String> batchSelectedMessages,
      BatchOperationType? currentBatchOperation,
      double batchProgress,
      List<OperationHistoryEntry> operationHistory,
      int maxHistoryEntries,
      int totalOperations,
      double averageOperationDuration,
      DateTime? lastOperationTime});

  @override
  $RegenerationOptionsCopyWith<$Res> get regenerationOptions;
}

/// @nodoc
class __$$MessageOperationStateImplCopyWithImpl<$Res>
    extends _$MessageOperationStateCopyWithImpl<$Res,
        _$MessageOperationStateImpl>
    implements _$$MessageOperationStateImplCopyWith<$Res> {
  __$$MessageOperationStateImplCopyWithImpl(_$MessageOperationStateImpl _value,
      $Res Function(_$MessageOperationStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageOperationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activeOperations = null,
    Object? operationProgress = null,
    Object? operationErrors = null,
    Object? messageBranches = null,
    Object? activeBranchId = freezed,
    Object? messagesWithBranches = null,
    Object? pausedMessageIds = null,
    Object? resumableMessageIds = null,
    Object? copyingMessageIds = null,
    Object? exportingMessageIds = null,
    Object? lastCopiedContent = freezed,
    Object? translatingMessages = null,
    Object? availableLanguages = null,
    Object? regeneratingMessages = null,
    Object? regenerationOptions = null,
    Object? isBatchMode = null,
    Object? batchSelectedMessages = null,
    Object? currentBatchOperation = freezed,
    Object? batchProgress = null,
    Object? operationHistory = null,
    Object? maxHistoryEntries = null,
    Object? totalOperations = null,
    Object? averageOperationDuration = null,
    Object? lastOperationTime = freezed,
  }) {
    return _then(_$MessageOperationStateImpl(
      activeOperations: null == activeOperations
          ? _value._activeOperations
          : activeOperations // ignore: cast_nullable_to_non_nullable
              as Map<String, MessageOperationType>,
      operationProgress: null == operationProgress
          ? _value._operationProgress
          : operationProgress // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      operationErrors: null == operationErrors
          ? _value._operationErrors
          : operationErrors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      messageBranches: null == messageBranches
          ? _value._messageBranches
          : messageBranches // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
      activeBranchId: freezed == activeBranchId
          ? _value.activeBranchId
          : activeBranchId // ignore: cast_nullable_to_non_nullable
              as String?,
      messagesWithBranches: null == messagesWithBranches
          ? _value._messagesWithBranches
          : messagesWithBranches // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      pausedMessageIds: null == pausedMessageIds
          ? _value._pausedMessageIds
          : pausedMessageIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      resumableMessageIds: null == resumableMessageIds
          ? _value._resumableMessageIds
          : resumableMessageIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      copyingMessageIds: null == copyingMessageIds
          ? _value._copyingMessageIds
          : copyingMessageIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      exportingMessageIds: null == exportingMessageIds
          ? _value._exportingMessageIds
          : exportingMessageIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      lastCopiedContent: freezed == lastCopiedContent
          ? _value.lastCopiedContent
          : lastCopiedContent // ignore: cast_nullable_to_non_nullable
              as String?,
      translatingMessages: null == translatingMessages
          ? _value._translatingMessages
          : translatingMessages // ignore: cast_nullable_to_non_nullable
              as Map<String, TranslationOperation>,
      availableLanguages: null == availableLanguages
          ? _value._availableLanguages
          : availableLanguages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      regeneratingMessages: null == regeneratingMessages
          ? _value._regeneratingMessages
          : regeneratingMessages // ignore: cast_nullable_to_non_nullable
              as Map<String, RegenerationOperation>,
      regenerationOptions: null == regenerationOptions
          ? _value.regenerationOptions
          : regenerationOptions // ignore: cast_nullable_to_non_nullable
              as RegenerationOptions,
      isBatchMode: null == isBatchMode
          ? _value.isBatchMode
          : isBatchMode // ignore: cast_nullable_to_non_nullable
              as bool,
      batchSelectedMessages: null == batchSelectedMessages
          ? _value._batchSelectedMessages
          : batchSelectedMessages // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      currentBatchOperation: freezed == currentBatchOperation
          ? _value.currentBatchOperation
          : currentBatchOperation // ignore: cast_nullable_to_non_nullable
              as BatchOperationType?,
      batchProgress: null == batchProgress
          ? _value.batchProgress
          : batchProgress // ignore: cast_nullable_to_non_nullable
              as double,
      operationHistory: null == operationHistory
          ? _value._operationHistory
          : operationHistory // ignore: cast_nullable_to_non_nullable
              as List<OperationHistoryEntry>,
      maxHistoryEntries: null == maxHistoryEntries
          ? _value.maxHistoryEntries
          : maxHistoryEntries // ignore: cast_nullable_to_non_nullable
              as int,
      totalOperations: null == totalOperations
          ? _value.totalOperations
          : totalOperations // ignore: cast_nullable_to_non_nullable
              as int,
      averageOperationDuration: null == averageOperationDuration
          ? _value.averageOperationDuration
          : averageOperationDuration // ignore: cast_nullable_to_non_nullable
              as double,
      lastOperationTime: freezed == lastOperationTime
          ? _value.lastOperationTime
          : lastOperationTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$MessageOperationStateImpl extends _MessageOperationState {
  const _$MessageOperationStateImpl(
      {final Map<String, MessageOperationType> activeOperations = const {},
      final Map<String, double> operationProgress = const {},
      final Map<String, String> operationErrors = const {},
      final Map<String, List<String>> messageBranches = const {},
      this.activeBranchId = null,
      final Set<String> messagesWithBranches = const {},
      final Set<String> pausedMessageIds = const {},
      final Set<String> resumableMessageIds = const {},
      final Set<String> copyingMessageIds = const {},
      final Set<String> exportingMessageIds = const {},
      this.lastCopiedContent = null,
      final Map<String, TranslationOperation> translatingMessages = const {},
      final List<String> availableLanguages = const [],
      final Map<String, RegenerationOperation> regeneratingMessages = const {},
      this.regenerationOptions = const RegenerationOptions(),
      this.isBatchMode = false,
      final Set<String> batchSelectedMessages = const {},
      this.currentBatchOperation = null,
      this.batchProgress = 0.0,
      final List<OperationHistoryEntry> operationHistory = const [],
      this.maxHistoryEntries = 50,
      this.totalOperations = 0,
      this.averageOperationDuration = 0.0,
      this.lastOperationTime = null})
      : _activeOperations = activeOperations,
        _operationProgress = operationProgress,
        _operationErrors = operationErrors,
        _messageBranches = messageBranches,
        _messagesWithBranches = messagesWithBranches,
        _pausedMessageIds = pausedMessageIds,
        _resumableMessageIds = resumableMessageIds,
        _copyingMessageIds = copyingMessageIds,
        _exportingMessageIds = exportingMessageIds,
        _translatingMessages = translatingMessages,
        _availableLanguages = availableLanguages,
        _regeneratingMessages = regeneratingMessages,
        _batchSelectedMessages = batchSelectedMessages,
        _operationHistory = operationHistory,
        super._();

// === Active Operations ===
  /// Map of message ID to operation type currently being performed
  final Map<String, MessageOperationType> _activeOperations;
// === Active Operations ===
  /// Map of message ID to operation type currently being performed
  @override
  @JsonKey()
  Map<String, MessageOperationType> get activeOperations {
    if (_activeOperations is EqualUnmodifiableMapView) return _activeOperations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_activeOperations);
  }

  /// Map of message ID to operation progress (0.0 to 1.0)
  final Map<String, double> _operationProgress;

  /// Map of message ID to operation progress (0.0 to 1.0)
  @override
  @JsonKey()
  Map<String, double> get operationProgress {
    if (_operationProgress is EqualUnmodifiableMapView)
      return _operationProgress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_operationProgress);
  }

  /// Map of message ID to operation error messages
  final Map<String, String> _operationErrors;

  /// Map of message ID to operation error messages
  @override
  @JsonKey()
  Map<String, String> get operationErrors {
    if (_operationErrors is EqualUnmodifiableMapView) return _operationErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_operationErrors);
  }

// === Branch Management ===
  /// Map of message ID to list of branch IDs
  final Map<String, List<String>> _messageBranches;
// === Branch Management ===
  /// Map of message ID to list of branch IDs
  @override
  @JsonKey()
  Map<String, List<String>> get messageBranches {
    if (_messageBranches is EqualUnmodifiableMapView) return _messageBranches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_messageBranches);
  }

  /// Currently active branch ID
  @override
  @JsonKey()
  final String? activeBranchId;

  /// Messages that have branches
  final Set<String> _messagesWithBranches;

  /// Messages that have branches
  @override
  @JsonKey()
  Set<String> get messagesWithBranches {
    if (_messagesWithBranches is EqualUnmodifiableSetView)
      return _messagesWithBranches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_messagesWithBranches);
  }

// === Pause/Resume State ===
  /// Messages that are currently paused
  final Set<String> _pausedMessageIds;
// === Pause/Resume State ===
  /// Messages that are currently paused
  @override
  @JsonKey()
  Set<String> get pausedMessageIds {
    if (_pausedMessageIds is EqualUnmodifiableSetView) return _pausedMessageIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_pausedMessageIds);
  }

  /// Messages that can be resumed
  final Set<String> _resumableMessageIds;

  /// Messages that can be resumed
  @override
  @JsonKey()
  Set<String> get resumableMessageIds {
    if (_resumableMessageIds is EqualUnmodifiableSetView)
      return _resumableMessageIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_resumableMessageIds);
  }

// === Copy/Export State ===
  /// Messages currently being copied
  final Set<String> _copyingMessageIds;
// === Copy/Export State ===
  /// Messages currently being copied
  @override
  @JsonKey()
  Set<String> get copyingMessageIds {
    if (_copyingMessageIds is EqualUnmodifiableSetView)
      return _copyingMessageIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_copyingMessageIds);
  }

  /// Messages currently being exported
  final Set<String> _exportingMessageIds;

  /// Messages currently being exported
  @override
  @JsonKey()
  Set<String> get exportingMessageIds {
    if (_exportingMessageIds is EqualUnmodifiableSetView)
      return _exportingMessageIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_exportingMessageIds);
  }

  /// Last copied content for clipboard management
  @override
  @JsonKey()
  final String? lastCopiedContent;
// === Translation State ===
  /// Messages currently being translated
  final Map<String, TranslationOperation> _translatingMessages;
// === Translation State ===
  /// Messages currently being translated
  @override
  @JsonKey()
  Map<String, TranslationOperation> get translatingMessages {
    if (_translatingMessages is EqualUnmodifiableMapView)
      return _translatingMessages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_translatingMessages);
  }

  /// Available translation languages
  final List<String> _availableLanguages;

  /// Available translation languages
  @override
  @JsonKey()
  List<String> get availableLanguages {
    if (_availableLanguages is EqualUnmodifiableListView)
      return _availableLanguages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableLanguages);
  }

// === Regeneration State ===
  /// Messages currently being regenerated
  final Map<String, RegenerationOperation> _regeneratingMessages;
// === Regeneration State ===
  /// Messages currently being regenerated
  @override
  @JsonKey()
  Map<String, RegenerationOperation> get regeneratingMessages {
    if (_regeneratingMessages is EqualUnmodifiableMapView)
      return _regeneratingMessages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_regeneratingMessages);
  }

  /// Regeneration options/settings
  @override
  @JsonKey()
  final RegenerationOptions regenerationOptions;
// === Batch Operations ===
  /// Whether batch operation mode is active
  @override
  @JsonKey()
  final bool isBatchMode;

  /// Selected messages for batch operations
  final Set<String> _batchSelectedMessages;

  /// Selected messages for batch operations
  @override
  @JsonKey()
  Set<String> get batchSelectedMessages {
    if (_batchSelectedMessages is EqualUnmodifiableSetView)
      return _batchSelectedMessages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_batchSelectedMessages);
  }

  /// Current batch operation type
  @override
  @JsonKey()
  final BatchOperationType? currentBatchOperation;

  /// Batch operation progress
  @override
  @JsonKey()
  final double batchProgress;
// === Operation History ===
  /// Recent operations for undo functionality
  final List<OperationHistoryEntry> _operationHistory;
// === Operation History ===
  /// Recent operations for undo functionality
  @override
  @JsonKey()
  List<OperationHistoryEntry> get operationHistory {
    if (_operationHistory is EqualUnmodifiableListView)
      return _operationHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_operationHistory);
  }

  /// Maximum history entries to keep
  @override
  @JsonKey()
  final int maxHistoryEntries;
// === Performance Metrics ===
  /// Total operations performed
  @override
  @JsonKey()
  final int totalOperations;

  /// Average operation duration in milliseconds
  @override
  @JsonKey()
  final double averageOperationDuration;

  /// Last operation timestamp
  @override
  @JsonKey()
  final DateTime? lastOperationTime;

  @override
  String toString() {
    return 'MessageOperationState(activeOperations: $activeOperations, operationProgress: $operationProgress, operationErrors: $operationErrors, messageBranches: $messageBranches, activeBranchId: $activeBranchId, messagesWithBranches: $messagesWithBranches, pausedMessageIds: $pausedMessageIds, resumableMessageIds: $resumableMessageIds, copyingMessageIds: $copyingMessageIds, exportingMessageIds: $exportingMessageIds, lastCopiedContent: $lastCopiedContent, translatingMessages: $translatingMessages, availableLanguages: $availableLanguages, regeneratingMessages: $regeneratingMessages, regenerationOptions: $regenerationOptions, isBatchMode: $isBatchMode, batchSelectedMessages: $batchSelectedMessages, currentBatchOperation: $currentBatchOperation, batchProgress: $batchProgress, operationHistory: $operationHistory, maxHistoryEntries: $maxHistoryEntries, totalOperations: $totalOperations, averageOperationDuration: $averageOperationDuration, lastOperationTime: $lastOperationTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageOperationStateImpl &&
            const DeepCollectionEquality()
                .equals(other._activeOperations, _activeOperations) &&
            const DeepCollectionEquality()
                .equals(other._operationProgress, _operationProgress) &&
            const DeepCollectionEquality()
                .equals(other._operationErrors, _operationErrors) &&
            const DeepCollectionEquality()
                .equals(other._messageBranches, _messageBranches) &&
            (identical(other.activeBranchId, activeBranchId) ||
                other.activeBranchId == activeBranchId) &&
            const DeepCollectionEquality()
                .equals(other._messagesWithBranches, _messagesWithBranches) &&
            const DeepCollectionEquality()
                .equals(other._pausedMessageIds, _pausedMessageIds) &&
            const DeepCollectionEquality()
                .equals(other._resumableMessageIds, _resumableMessageIds) &&
            const DeepCollectionEquality()
                .equals(other._copyingMessageIds, _copyingMessageIds) &&
            const DeepCollectionEquality()
                .equals(other._exportingMessageIds, _exportingMessageIds) &&
            (identical(other.lastCopiedContent, lastCopiedContent) ||
                other.lastCopiedContent == lastCopiedContent) &&
            const DeepCollectionEquality()
                .equals(other._translatingMessages, _translatingMessages) &&
            const DeepCollectionEquality()
                .equals(other._availableLanguages, _availableLanguages) &&
            const DeepCollectionEquality()
                .equals(other._regeneratingMessages, _regeneratingMessages) &&
            (identical(other.regenerationOptions, regenerationOptions) ||
                other.regenerationOptions == regenerationOptions) &&
            (identical(other.isBatchMode, isBatchMode) ||
                other.isBatchMode == isBatchMode) &&
            const DeepCollectionEquality()
                .equals(other._batchSelectedMessages, _batchSelectedMessages) &&
            (identical(other.currentBatchOperation, currentBatchOperation) ||
                other.currentBatchOperation == currentBatchOperation) &&
            (identical(other.batchProgress, batchProgress) ||
                other.batchProgress == batchProgress) &&
            const DeepCollectionEquality()
                .equals(other._operationHistory, _operationHistory) &&
            (identical(other.maxHistoryEntries, maxHistoryEntries) ||
                other.maxHistoryEntries == maxHistoryEntries) &&
            (identical(other.totalOperations, totalOperations) ||
                other.totalOperations == totalOperations) &&
            (identical(
                    other.averageOperationDuration, averageOperationDuration) ||
                other.averageOperationDuration == averageOperationDuration) &&
            (identical(other.lastOperationTime, lastOperationTime) ||
                other.lastOperationTime == lastOperationTime));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        const DeepCollectionEquality().hash(_activeOperations),
        const DeepCollectionEquality().hash(_operationProgress),
        const DeepCollectionEquality().hash(_operationErrors),
        const DeepCollectionEquality().hash(_messageBranches),
        activeBranchId,
        const DeepCollectionEquality().hash(_messagesWithBranches),
        const DeepCollectionEquality().hash(_pausedMessageIds),
        const DeepCollectionEquality().hash(_resumableMessageIds),
        const DeepCollectionEquality().hash(_copyingMessageIds),
        const DeepCollectionEquality().hash(_exportingMessageIds),
        lastCopiedContent,
        const DeepCollectionEquality().hash(_translatingMessages),
        const DeepCollectionEquality().hash(_availableLanguages),
        const DeepCollectionEquality().hash(_regeneratingMessages),
        regenerationOptions,
        isBatchMode,
        const DeepCollectionEquality().hash(_batchSelectedMessages),
        currentBatchOperation,
        batchProgress,
        const DeepCollectionEquality().hash(_operationHistory),
        maxHistoryEntries,
        totalOperations,
        averageOperationDuration,
        lastOperationTime
      ]);

  /// Create a copy of MessageOperationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageOperationStateImplCopyWith<_$MessageOperationStateImpl>
      get copyWith => __$$MessageOperationStateImplCopyWithImpl<
          _$MessageOperationStateImpl>(this, _$identity);
}

abstract class _MessageOperationState extends MessageOperationState {
  const factory _MessageOperationState(
      {final Map<String, MessageOperationType> activeOperations,
      final Map<String, double> operationProgress,
      final Map<String, String> operationErrors,
      final Map<String, List<String>> messageBranches,
      final String? activeBranchId,
      final Set<String> messagesWithBranches,
      final Set<String> pausedMessageIds,
      final Set<String> resumableMessageIds,
      final Set<String> copyingMessageIds,
      final Set<String> exportingMessageIds,
      final String? lastCopiedContent,
      final Map<String, TranslationOperation> translatingMessages,
      final List<String> availableLanguages,
      final Map<String, RegenerationOperation> regeneratingMessages,
      final RegenerationOptions regenerationOptions,
      final bool isBatchMode,
      final Set<String> batchSelectedMessages,
      final BatchOperationType? currentBatchOperation,
      final double batchProgress,
      final List<OperationHistoryEntry> operationHistory,
      final int maxHistoryEntries,
      final int totalOperations,
      final double averageOperationDuration,
      final DateTime? lastOperationTime}) = _$MessageOperationStateImpl;
  const _MessageOperationState._() : super._();

// === Active Operations ===
  /// Map of message ID to operation type currently being performed
  @override
  Map<String, MessageOperationType> get activeOperations;

  /// Map of message ID to operation progress (0.0 to 1.0)
  @override
  Map<String, double> get operationProgress;

  /// Map of message ID to operation error messages
  @override
  Map<String, String> get operationErrors; // === Branch Management ===
  /// Map of message ID to list of branch IDs
  @override
  Map<String, List<String>> get messageBranches;

  /// Currently active branch ID
  @override
  String? get activeBranchId;

  /// Messages that have branches
  @override
  Set<String> get messagesWithBranches; // === Pause/Resume State ===
  /// Messages that are currently paused
  @override
  Set<String> get pausedMessageIds;

  /// Messages that can be resumed
  @override
  Set<String> get resumableMessageIds; // === Copy/Export State ===
  /// Messages currently being copied
  @override
  Set<String> get copyingMessageIds;

  /// Messages currently being exported
  @override
  Set<String> get exportingMessageIds;

  /// Last copied content for clipboard management
  @override
  String? get lastCopiedContent; // === Translation State ===
  /// Messages currently being translated
  @override
  Map<String, TranslationOperation> get translatingMessages;

  /// Available translation languages
  @override
  List<String> get availableLanguages; // === Regeneration State ===
  /// Messages currently being regenerated
  @override
  Map<String, RegenerationOperation> get regeneratingMessages;

  /// Regeneration options/settings
  @override
  RegenerationOptions get regenerationOptions; // === Batch Operations ===
  /// Whether batch operation mode is active
  @override
  bool get isBatchMode;

  /// Selected messages for batch operations
  @override
  Set<String> get batchSelectedMessages;

  /// Current batch operation type
  @override
  BatchOperationType? get currentBatchOperation;

  /// Batch operation progress
  @override
  double get batchProgress; // === Operation History ===
  /// Recent operations for undo functionality
  @override
  List<OperationHistoryEntry> get operationHistory;

  /// Maximum history entries to keep
  @override
  int get maxHistoryEntries; // === Performance Metrics ===
  /// Total operations performed
  @override
  int get totalOperations;

  /// Average operation duration in milliseconds
  @override
  double get averageOperationDuration;

  /// Last operation timestamp
  @override
  DateTime? get lastOperationTime;

  /// Create a copy of MessageOperationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageOperationStateImplCopyWith<_$MessageOperationStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TranslationOperation {
  /// Source language
  String get sourceLanguage => throw _privateConstructorUsedError;

  /// Target language
  String get targetLanguage => throw _privateConstructorUsedError;

  /// Translation progress (0.0 to 1.0)
  double get progress => throw _privateConstructorUsedError;

  /// Translation start time
  DateTime get startTime => throw _privateConstructorUsedError;

  /// Translation options
  Map<String, dynamic> get options => throw _privateConstructorUsedError;

  /// Create a copy of TranslationOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TranslationOperationCopyWith<TranslationOperation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TranslationOperationCopyWith<$Res> {
  factory $TranslationOperationCopyWith(TranslationOperation value,
          $Res Function(TranslationOperation) then) =
      _$TranslationOperationCopyWithImpl<$Res, TranslationOperation>;
  @useResult
  $Res call(
      {String sourceLanguage,
      String targetLanguage,
      double progress,
      DateTime startTime,
      Map<String, dynamic> options});
}

/// @nodoc
class _$TranslationOperationCopyWithImpl<$Res,
        $Val extends TranslationOperation>
    implements $TranslationOperationCopyWith<$Res> {
  _$TranslationOperationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TranslationOperation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourceLanguage = null,
    Object? targetLanguage = null,
    Object? progress = null,
    Object? startTime = null,
    Object? options = null,
  }) {
    return _then(_value.copyWith(
      sourceLanguage: null == sourceLanguage
          ? _value.sourceLanguage
          : sourceLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      targetLanguage: null == targetLanguage
          ? _value.targetLanguage
          : targetLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TranslationOperationImplCopyWith<$Res>
    implements $TranslationOperationCopyWith<$Res> {
  factory _$$TranslationOperationImplCopyWith(_$TranslationOperationImpl value,
          $Res Function(_$TranslationOperationImpl) then) =
      __$$TranslationOperationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String sourceLanguage,
      String targetLanguage,
      double progress,
      DateTime startTime,
      Map<String, dynamic> options});
}

/// @nodoc
class __$$TranslationOperationImplCopyWithImpl<$Res>
    extends _$TranslationOperationCopyWithImpl<$Res, _$TranslationOperationImpl>
    implements _$$TranslationOperationImplCopyWith<$Res> {
  __$$TranslationOperationImplCopyWithImpl(_$TranslationOperationImpl _value,
      $Res Function(_$TranslationOperationImpl) _then)
      : super(_value, _then);

  /// Create a copy of TranslationOperation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourceLanguage = null,
    Object? targetLanguage = null,
    Object? progress = null,
    Object? startTime = null,
    Object? options = null,
  }) {
    return _then(_$TranslationOperationImpl(
      sourceLanguage: null == sourceLanguage
          ? _value.sourceLanguage
          : sourceLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      targetLanguage: null == targetLanguage
          ? _value.targetLanguage
          : targetLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$TranslationOperationImpl implements _TranslationOperation {
  const _$TranslationOperationImpl(
      {required this.sourceLanguage,
      required this.targetLanguage,
      this.progress = 0.0,
      required this.startTime,
      final Map<String, dynamic> options = const {}})
      : _options = options;

  /// Source language
  @override
  final String sourceLanguage;

  /// Target language
  @override
  final String targetLanguage;

  /// Translation progress (0.0 to 1.0)
  @override
  @JsonKey()
  final double progress;

  /// Translation start time
  @override
  final DateTime startTime;

  /// Translation options
  final Map<String, dynamic> _options;

  /// Translation options
  @override
  @JsonKey()
  Map<String, dynamic> get options {
    if (_options is EqualUnmodifiableMapView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_options);
  }

  @override
  String toString() {
    return 'TranslationOperation(sourceLanguage: $sourceLanguage, targetLanguage: $targetLanguage, progress: $progress, startTime: $startTime, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranslationOperationImpl &&
            (identical(other.sourceLanguage, sourceLanguage) ||
                other.sourceLanguage == sourceLanguage) &&
            (identical(other.targetLanguage, targetLanguage) ||
                other.targetLanguage == targetLanguage) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            const DeepCollectionEquality().equals(other._options, _options));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sourceLanguage, targetLanguage,
      progress, startTime, const DeepCollectionEquality().hash(_options));

  /// Create a copy of TranslationOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TranslationOperationImplCopyWith<_$TranslationOperationImpl>
      get copyWith =>
          __$$TranslationOperationImplCopyWithImpl<_$TranslationOperationImpl>(
              this, _$identity);
}

abstract class _TranslationOperation implements TranslationOperation {
  const factory _TranslationOperation(
      {required final String sourceLanguage,
      required final String targetLanguage,
      final double progress,
      required final DateTime startTime,
      final Map<String, dynamic> options}) = _$TranslationOperationImpl;

  /// Source language
  @override
  String get sourceLanguage;

  /// Target language
  @override
  String get targetLanguage;

  /// Translation progress (0.0 to 1.0)
  @override
  double get progress;

  /// Translation start time
  @override
  DateTime get startTime;

  /// Translation options
  @override
  Map<String, dynamic> get options;

  /// Create a copy of TranslationOperation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TranslationOperationImplCopyWith<_$TranslationOperationImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RegenerationOperation {
  /// Regeneration start time
  DateTime get startTime => throw _privateConstructorUsedError;

  /// Regeneration progress (0.0 to 1.0)
  double get progress => throw _privateConstructorUsedError;

  /// Model used for regeneration
  String? get modelId => throw _privateConstructorUsedError;

  /// Assistant used for regeneration
  String? get assistantId => throw _privateConstructorUsedError;

  /// Regeneration options
  Map<String, dynamic> get options => throw _privateConstructorUsedError;

  /// Create a copy of RegenerationOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegenerationOperationCopyWith<RegenerationOperation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegenerationOperationCopyWith<$Res> {
  factory $RegenerationOperationCopyWith(RegenerationOperation value,
          $Res Function(RegenerationOperation) then) =
      _$RegenerationOperationCopyWithImpl<$Res, RegenerationOperation>;
  @useResult
  $Res call(
      {DateTime startTime,
      double progress,
      String? modelId,
      String? assistantId,
      Map<String, dynamic> options});
}

/// @nodoc
class _$RegenerationOperationCopyWithImpl<$Res,
        $Val extends RegenerationOperation>
    implements $RegenerationOperationCopyWith<$Res> {
  _$RegenerationOperationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegenerationOperation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startTime = null,
    Object? progress = null,
    Object? modelId = freezed,
    Object? assistantId = freezed,
    Object? options = null,
  }) {
    return _then(_value.copyWith(
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      modelId: freezed == modelId
          ? _value.modelId
          : modelId // ignore: cast_nullable_to_non_nullable
              as String?,
      assistantId: freezed == assistantId
          ? _value.assistantId
          : assistantId // ignore: cast_nullable_to_non_nullable
              as String?,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RegenerationOperationImplCopyWith<$Res>
    implements $RegenerationOperationCopyWith<$Res> {
  factory _$$RegenerationOperationImplCopyWith(
          _$RegenerationOperationImpl value,
          $Res Function(_$RegenerationOperationImpl) then) =
      __$$RegenerationOperationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime startTime,
      double progress,
      String? modelId,
      String? assistantId,
      Map<String, dynamic> options});
}

/// @nodoc
class __$$RegenerationOperationImplCopyWithImpl<$Res>
    extends _$RegenerationOperationCopyWithImpl<$Res,
        _$RegenerationOperationImpl>
    implements _$$RegenerationOperationImplCopyWith<$Res> {
  __$$RegenerationOperationImplCopyWithImpl(_$RegenerationOperationImpl _value,
      $Res Function(_$RegenerationOperationImpl) _then)
      : super(_value, _then);

  /// Create a copy of RegenerationOperation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startTime = null,
    Object? progress = null,
    Object? modelId = freezed,
    Object? assistantId = freezed,
    Object? options = null,
  }) {
    return _then(_$RegenerationOperationImpl(
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      modelId: freezed == modelId
          ? _value.modelId
          : modelId // ignore: cast_nullable_to_non_nullable
              as String?,
      assistantId: freezed == assistantId
          ? _value.assistantId
          : assistantId // ignore: cast_nullable_to_non_nullable
              as String?,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$RegenerationOperationImpl implements _RegenerationOperation {
  const _$RegenerationOperationImpl(
      {required this.startTime,
      this.progress = 0.0,
      this.modelId = null,
      this.assistantId = null,
      final Map<String, dynamic> options = const {}})
      : _options = options;

  /// Regeneration start time
  @override
  final DateTime startTime;

  /// Regeneration progress (0.0 to 1.0)
  @override
  @JsonKey()
  final double progress;

  /// Model used for regeneration
  @override
  @JsonKey()
  final String? modelId;

  /// Assistant used for regeneration
  @override
  @JsonKey()
  final String? assistantId;

  /// Regeneration options
  final Map<String, dynamic> _options;

  /// Regeneration options
  @override
  @JsonKey()
  Map<String, dynamic> get options {
    if (_options is EqualUnmodifiableMapView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_options);
  }

  @override
  String toString() {
    return 'RegenerationOperation(startTime: $startTime, progress: $progress, modelId: $modelId, assistantId: $assistantId, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegenerationOperationImpl &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.modelId, modelId) || other.modelId == modelId) &&
            (identical(other.assistantId, assistantId) ||
                other.assistantId == assistantId) &&
            const DeepCollectionEquality().equals(other._options, _options));
  }

  @override
  int get hashCode => Object.hash(runtimeType, startTime, progress, modelId,
      assistantId, const DeepCollectionEquality().hash(_options));

  /// Create a copy of RegenerationOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegenerationOperationImplCopyWith<_$RegenerationOperationImpl>
      get copyWith => __$$RegenerationOperationImplCopyWithImpl<
          _$RegenerationOperationImpl>(this, _$identity);
}

abstract class _RegenerationOperation implements RegenerationOperation {
  const factory _RegenerationOperation(
      {required final DateTime startTime,
      final double progress,
      final String? modelId,
      final String? assistantId,
      final Map<String, dynamic> options}) = _$RegenerationOperationImpl;

  /// Regeneration start time
  @override
  DateTime get startTime;

  /// Regeneration progress (0.0 to 1.0)
  @override
  double get progress;

  /// Model used for regeneration
  @override
  String? get modelId;

  /// Assistant used for regeneration
  @override
  String? get assistantId;

  /// Regeneration options
  @override
  Map<String, dynamic> get options;

  /// Create a copy of RegenerationOperation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegenerationOperationImplCopyWith<_$RegenerationOperationImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RegenerationOptions {
  /// Whether to use streaming for regeneration
  bool get useStreaming => throw _privateConstructorUsedError;

  /// Whether to preserve message history
  bool get preserveHistory => throw _privateConstructorUsedError;

  /// Maximum regeneration attempts
  int get maxAttempts => throw _privateConstructorUsedError;

  /// Timeout in seconds
  int get timeoutSeconds => throw _privateConstructorUsedError;

  /// Custom regeneration prompt
  String? get customPrompt => throw _privateConstructorUsedError;

  /// Create a copy of RegenerationOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegenerationOptionsCopyWith<RegenerationOptions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegenerationOptionsCopyWith<$Res> {
  factory $RegenerationOptionsCopyWith(
          RegenerationOptions value, $Res Function(RegenerationOptions) then) =
      _$RegenerationOptionsCopyWithImpl<$Res, RegenerationOptions>;
  @useResult
  $Res call(
      {bool useStreaming,
      bool preserveHistory,
      int maxAttempts,
      int timeoutSeconds,
      String? customPrompt});
}

/// @nodoc
class _$RegenerationOptionsCopyWithImpl<$Res, $Val extends RegenerationOptions>
    implements $RegenerationOptionsCopyWith<$Res> {
  _$RegenerationOptionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegenerationOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? useStreaming = null,
    Object? preserveHistory = null,
    Object? maxAttempts = null,
    Object? timeoutSeconds = null,
    Object? customPrompt = freezed,
  }) {
    return _then(_value.copyWith(
      useStreaming: null == useStreaming
          ? _value.useStreaming
          : useStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      preserveHistory: null == preserveHistory
          ? _value.preserveHistory
          : preserveHistory // ignore: cast_nullable_to_non_nullable
              as bool,
      maxAttempts: null == maxAttempts
          ? _value.maxAttempts
          : maxAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      timeoutSeconds: null == timeoutSeconds
          ? _value.timeoutSeconds
          : timeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      customPrompt: freezed == customPrompt
          ? _value.customPrompt
          : customPrompt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RegenerationOptionsImplCopyWith<$Res>
    implements $RegenerationOptionsCopyWith<$Res> {
  factory _$$RegenerationOptionsImplCopyWith(_$RegenerationOptionsImpl value,
          $Res Function(_$RegenerationOptionsImpl) then) =
      __$$RegenerationOptionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool useStreaming,
      bool preserveHistory,
      int maxAttempts,
      int timeoutSeconds,
      String? customPrompt});
}

/// @nodoc
class __$$RegenerationOptionsImplCopyWithImpl<$Res>
    extends _$RegenerationOptionsCopyWithImpl<$Res, _$RegenerationOptionsImpl>
    implements _$$RegenerationOptionsImplCopyWith<$Res> {
  __$$RegenerationOptionsImplCopyWithImpl(_$RegenerationOptionsImpl _value,
      $Res Function(_$RegenerationOptionsImpl) _then)
      : super(_value, _then);

  /// Create a copy of RegenerationOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? useStreaming = null,
    Object? preserveHistory = null,
    Object? maxAttempts = null,
    Object? timeoutSeconds = null,
    Object? customPrompt = freezed,
  }) {
    return _then(_$RegenerationOptionsImpl(
      useStreaming: null == useStreaming
          ? _value.useStreaming
          : useStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      preserveHistory: null == preserveHistory
          ? _value.preserveHistory
          : preserveHistory // ignore: cast_nullable_to_non_nullable
              as bool,
      maxAttempts: null == maxAttempts
          ? _value.maxAttempts
          : maxAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      timeoutSeconds: null == timeoutSeconds
          ? _value.timeoutSeconds
          : timeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      customPrompt: freezed == customPrompt
          ? _value.customPrompt
          : customPrompt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$RegenerationOptionsImpl implements _RegenerationOptions {
  const _$RegenerationOptionsImpl(
      {this.useStreaming = true,
      this.preserveHistory = true,
      this.maxAttempts = 3,
      this.timeoutSeconds = 60,
      this.customPrompt = null});

  /// Whether to use streaming for regeneration
  @override
  @JsonKey()
  final bool useStreaming;

  /// Whether to preserve message history
  @override
  @JsonKey()
  final bool preserveHistory;

  /// Maximum regeneration attempts
  @override
  @JsonKey()
  final int maxAttempts;

  /// Timeout in seconds
  @override
  @JsonKey()
  final int timeoutSeconds;

  /// Custom regeneration prompt
  @override
  @JsonKey()
  final String? customPrompt;

  @override
  String toString() {
    return 'RegenerationOptions(useStreaming: $useStreaming, preserveHistory: $preserveHistory, maxAttempts: $maxAttempts, timeoutSeconds: $timeoutSeconds, customPrompt: $customPrompt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegenerationOptionsImpl &&
            (identical(other.useStreaming, useStreaming) ||
                other.useStreaming == useStreaming) &&
            (identical(other.preserveHistory, preserveHistory) ||
                other.preserveHistory == preserveHistory) &&
            (identical(other.maxAttempts, maxAttempts) ||
                other.maxAttempts == maxAttempts) &&
            (identical(other.timeoutSeconds, timeoutSeconds) ||
                other.timeoutSeconds == timeoutSeconds) &&
            (identical(other.customPrompt, customPrompt) ||
                other.customPrompt == customPrompt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, useStreaming, preserveHistory,
      maxAttempts, timeoutSeconds, customPrompt);

  /// Create a copy of RegenerationOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegenerationOptionsImplCopyWith<_$RegenerationOptionsImpl> get copyWith =>
      __$$RegenerationOptionsImplCopyWithImpl<_$RegenerationOptionsImpl>(
          this, _$identity);
}

abstract class _RegenerationOptions implements RegenerationOptions {
  const factory _RegenerationOptions(
      {final bool useStreaming,
      final bool preserveHistory,
      final int maxAttempts,
      final int timeoutSeconds,
      final String? customPrompt}) = _$RegenerationOptionsImpl;

  /// Whether to use streaming for regeneration
  @override
  bool get useStreaming;

  /// Whether to preserve message history
  @override
  bool get preserveHistory;

  /// Maximum regeneration attempts
  @override
  int get maxAttempts;

  /// Timeout in seconds
  @override
  int get timeoutSeconds;

  /// Custom regeneration prompt
  @override
  String? get customPrompt;

  /// Create a copy of RegenerationOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegenerationOptionsImplCopyWith<_$RegenerationOptionsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$OperationHistoryEntry {
  /// Operation ID
  String get id => throw _privateConstructorUsedError;

  /// Operation type
  MessageOperationType get type => throw _privateConstructorUsedError;

  /// Message ID that was operated on
  String get messageId => throw _privateConstructorUsedError;

  /// Operation timestamp
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Operation duration in milliseconds
  int get durationMs => throw _privateConstructorUsedError;

  /// Previous state for undo
  Map<String, dynamic> get previousState => throw _privateConstructorUsedError;

  /// Operation result
  Map<String, dynamic> get result => throw _privateConstructorUsedError;

  /// Whether operation was successful
  bool get wasSuccessful => throw _privateConstructorUsedError;

  /// Error message if operation failed
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of OperationHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OperationHistoryEntryCopyWith<OperationHistoryEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OperationHistoryEntryCopyWith<$Res> {
  factory $OperationHistoryEntryCopyWith(OperationHistoryEntry value,
          $Res Function(OperationHistoryEntry) then) =
      _$OperationHistoryEntryCopyWithImpl<$Res, OperationHistoryEntry>;
  @useResult
  $Res call(
      {String id,
      MessageOperationType type,
      String messageId,
      DateTime timestamp,
      int durationMs,
      Map<String, dynamic> previousState,
      Map<String, dynamic> result,
      bool wasSuccessful,
      String? errorMessage});
}

/// @nodoc
class _$OperationHistoryEntryCopyWithImpl<$Res,
        $Val extends OperationHistoryEntry>
    implements $OperationHistoryEntryCopyWith<$Res> {
  _$OperationHistoryEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OperationHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? messageId = null,
    Object? timestamp = null,
    Object? durationMs = null,
    Object? previousState = null,
    Object? result = null,
    Object? wasSuccessful = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageOperationType,
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      durationMs: null == durationMs
          ? _value.durationMs
          : durationMs // ignore: cast_nullable_to_non_nullable
              as int,
      previousState: null == previousState
          ? _value.previousState
          : previousState // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      result: null == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      wasSuccessful: null == wasSuccessful
          ? _value.wasSuccessful
          : wasSuccessful // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OperationHistoryEntryImplCopyWith<$Res>
    implements $OperationHistoryEntryCopyWith<$Res> {
  factory _$$OperationHistoryEntryImplCopyWith(
          _$OperationHistoryEntryImpl value,
          $Res Function(_$OperationHistoryEntryImpl) then) =
      __$$OperationHistoryEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      MessageOperationType type,
      String messageId,
      DateTime timestamp,
      int durationMs,
      Map<String, dynamic> previousState,
      Map<String, dynamic> result,
      bool wasSuccessful,
      String? errorMessage});
}

/// @nodoc
class __$$OperationHistoryEntryImplCopyWithImpl<$Res>
    extends _$OperationHistoryEntryCopyWithImpl<$Res,
        _$OperationHistoryEntryImpl>
    implements _$$OperationHistoryEntryImplCopyWith<$Res> {
  __$$OperationHistoryEntryImplCopyWithImpl(_$OperationHistoryEntryImpl _value,
      $Res Function(_$OperationHistoryEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of OperationHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? messageId = null,
    Object? timestamp = null,
    Object? durationMs = null,
    Object? previousState = null,
    Object? result = null,
    Object? wasSuccessful = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$OperationHistoryEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageOperationType,
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      durationMs: null == durationMs
          ? _value.durationMs
          : durationMs // ignore: cast_nullable_to_non_nullable
              as int,
      previousState: null == previousState
          ? _value._previousState
          : previousState // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      result: null == result
          ? _value._result
          : result // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      wasSuccessful: null == wasSuccessful
          ? _value.wasSuccessful
          : wasSuccessful // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$OperationHistoryEntryImpl implements _OperationHistoryEntry {
  const _$OperationHistoryEntryImpl(
      {required this.id,
      required this.type,
      required this.messageId,
      required this.timestamp,
      this.durationMs = 0,
      final Map<String, dynamic> previousState = const {},
      final Map<String, dynamic> result = const {},
      this.wasSuccessful = true,
      this.errorMessage = null})
      : _previousState = previousState,
        _result = result;

  /// Operation ID
  @override
  final String id;

  /// Operation type
  @override
  final MessageOperationType type;

  /// Message ID that was operated on
  @override
  final String messageId;

  /// Operation timestamp
  @override
  final DateTime timestamp;

  /// Operation duration in milliseconds
  @override
  @JsonKey()
  final int durationMs;

  /// Previous state for undo
  final Map<String, dynamic> _previousState;

  /// Previous state for undo
  @override
  @JsonKey()
  Map<String, dynamic> get previousState {
    if (_previousState is EqualUnmodifiableMapView) return _previousState;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_previousState);
  }

  /// Operation result
  final Map<String, dynamic> _result;

  /// Operation result
  @override
  @JsonKey()
  Map<String, dynamic> get result {
    if (_result is EqualUnmodifiableMapView) return _result;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_result);
  }

  /// Whether operation was successful
  @override
  @JsonKey()
  final bool wasSuccessful;

  /// Error message if operation failed
  @override
  @JsonKey()
  final String? errorMessage;

  @override
  String toString() {
    return 'OperationHistoryEntry(id: $id, type: $type, messageId: $messageId, timestamp: $timestamp, durationMs: $durationMs, previousState: $previousState, result: $result, wasSuccessful: $wasSuccessful, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OperationHistoryEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.durationMs, durationMs) ||
                other.durationMs == durationMs) &&
            const DeepCollectionEquality()
                .equals(other._previousState, _previousState) &&
            const DeepCollectionEquality().equals(other._result, _result) &&
            (identical(other.wasSuccessful, wasSuccessful) ||
                other.wasSuccessful == wasSuccessful) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      messageId,
      timestamp,
      durationMs,
      const DeepCollectionEquality().hash(_previousState),
      const DeepCollectionEquality().hash(_result),
      wasSuccessful,
      errorMessage);

  /// Create a copy of OperationHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OperationHistoryEntryImplCopyWith<_$OperationHistoryEntryImpl>
      get copyWith => __$$OperationHistoryEntryImplCopyWithImpl<
          _$OperationHistoryEntryImpl>(this, _$identity);
}

abstract class _OperationHistoryEntry implements OperationHistoryEntry {
  const factory _OperationHistoryEntry(
      {required final String id,
      required final MessageOperationType type,
      required final String messageId,
      required final DateTime timestamp,
      final int durationMs,
      final Map<String, dynamic> previousState,
      final Map<String, dynamic> result,
      final bool wasSuccessful,
      final String? errorMessage}) = _$OperationHistoryEntryImpl;

  /// Operation ID
  @override
  String get id;

  /// Operation type
  @override
  MessageOperationType get type;

  /// Message ID that was operated on
  @override
  String get messageId;

  /// Operation timestamp
  @override
  DateTime get timestamp;

  /// Operation duration in milliseconds
  @override
  int get durationMs;

  /// Previous state for undo
  @override
  Map<String, dynamic> get previousState;

  /// Operation result
  @override
  Map<String, dynamic> get result;

  /// Whether operation was successful
  @override
  bool get wasSuccessful;

  /// Error message if operation failed
  @override
  String? get errorMessage;

  /// Create a copy of OperationHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OperationHistoryEntryImplCopyWith<_$OperationHistoryEntryImpl>
      get copyWith => throw _privateConstructorUsedError;
}
