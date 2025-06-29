// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streaming_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$StreamingMessage {
  /// Unique message ID
  String get messageId => throw _privateConstructorUsedError;

  /// Conversation this message belongs to
  String get conversationId => throw _privateConstructorUsedError;

  /// Assistant ID generating this message
  String get assistantId => throw _privateConstructorUsedError;

  /// Model being used (optional)
  String? get modelId => throw _privateConstructorUsedError;

  /// Current accumulated content
  String get content => throw _privateConstructorUsedError;

  /// Thinking process content (for models that support it)
  String get thinking => throw _privateConstructorUsedError;

  /// Whether the stream has completed
  bool get isComplete => throw _privateConstructorUsedError;

  /// Whether the stream encountered an error
  bool get hasError => throw _privateConstructorUsedError;

  /// Error message if any
  String? get errorMessage => throw _privateConstructorUsedError;

  /// When the stream started
  DateTime? get startTime => throw _privateConstructorUsedError;

  /// Last update timestamp
  DateTime? get lastUpdateTime => throw _privateConstructorUsedError;

  /// Completion timestamp
  DateTime? get completionTime => throw _privateConstructorUsedError;

  /// Additional metadata
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Content length for performance tracking
  int get contentLength => throw _privateConstructorUsedError;

  /// Number of updates received
  int get updateCount => throw _privateConstructorUsedError;

  /// Create a copy of StreamingMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StreamingMessageCopyWith<StreamingMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreamingMessageCopyWith<$Res> {
  factory $StreamingMessageCopyWith(
          StreamingMessage value, $Res Function(StreamingMessage) then) =
      _$StreamingMessageCopyWithImpl<$Res, StreamingMessage>;
  @useResult
  $Res call(
      {String messageId,
      String conversationId,
      String assistantId,
      String? modelId,
      String content,
      String thinking,
      bool isComplete,
      bool hasError,
      String? errorMessage,
      DateTime? startTime,
      DateTime? lastUpdateTime,
      DateTime? completionTime,
      Map<String, dynamic> metadata,
      int contentLength,
      int updateCount});
}

/// @nodoc
class _$StreamingMessageCopyWithImpl<$Res, $Val extends StreamingMessage>
    implements $StreamingMessageCopyWith<$Res> {
  _$StreamingMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StreamingMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageId = null,
    Object? conversationId = null,
    Object? assistantId = null,
    Object? modelId = freezed,
    Object? content = null,
    Object? thinking = null,
    Object? isComplete = null,
    Object? hasError = null,
    Object? errorMessage = freezed,
    Object? startTime = freezed,
    Object? lastUpdateTime = freezed,
    Object? completionTime = freezed,
    Object? metadata = null,
    Object? contentLength = null,
    Object? updateCount = null,
  }) {
    return _then(_value.copyWith(
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      assistantId: null == assistantId
          ? _value.assistantId
          : assistantId // ignore: cast_nullable_to_non_nullable
              as String,
      modelId: freezed == modelId
          ? _value.modelId
          : modelId // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      thinking: null == thinking
          ? _value.thinking
          : thinking // ignore: cast_nullable_to_non_nullable
              as String,
      isComplete: null == isComplete
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastUpdateTime: freezed == lastUpdateTime
          ? _value.lastUpdateTime
          : lastUpdateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completionTime: freezed == completionTime
          ? _value.completionTime
          : completionTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      contentLength: null == contentLength
          ? _value.contentLength
          : contentLength // ignore: cast_nullable_to_non_nullable
              as int,
      updateCount: null == updateCount
          ? _value.updateCount
          : updateCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StreamingMessageImplCopyWith<$Res>
    implements $StreamingMessageCopyWith<$Res> {
  factory _$$StreamingMessageImplCopyWith(_$StreamingMessageImpl value,
          $Res Function(_$StreamingMessageImpl) then) =
      __$$StreamingMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String messageId,
      String conversationId,
      String assistantId,
      String? modelId,
      String content,
      String thinking,
      bool isComplete,
      bool hasError,
      String? errorMessage,
      DateTime? startTime,
      DateTime? lastUpdateTime,
      DateTime? completionTime,
      Map<String, dynamic> metadata,
      int contentLength,
      int updateCount});
}

/// @nodoc
class __$$StreamingMessageImplCopyWithImpl<$Res>
    extends _$StreamingMessageCopyWithImpl<$Res, _$StreamingMessageImpl>
    implements _$$StreamingMessageImplCopyWith<$Res> {
  __$$StreamingMessageImplCopyWithImpl(_$StreamingMessageImpl _value,
      $Res Function(_$StreamingMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of StreamingMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageId = null,
    Object? conversationId = null,
    Object? assistantId = null,
    Object? modelId = freezed,
    Object? content = null,
    Object? thinking = null,
    Object? isComplete = null,
    Object? hasError = null,
    Object? errorMessage = freezed,
    Object? startTime = freezed,
    Object? lastUpdateTime = freezed,
    Object? completionTime = freezed,
    Object? metadata = null,
    Object? contentLength = null,
    Object? updateCount = null,
  }) {
    return _then(_$StreamingMessageImpl(
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      assistantId: null == assistantId
          ? _value.assistantId
          : assistantId // ignore: cast_nullable_to_non_nullable
              as String,
      modelId: freezed == modelId
          ? _value.modelId
          : modelId // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      thinking: null == thinking
          ? _value.thinking
          : thinking // ignore: cast_nullable_to_non_nullable
              as String,
      isComplete: null == isComplete
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastUpdateTime: freezed == lastUpdateTime
          ? _value.lastUpdateTime
          : lastUpdateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completionTime: freezed == completionTime
          ? _value.completionTime
          : completionTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      contentLength: null == contentLength
          ? _value.contentLength
          : contentLength // ignore: cast_nullable_to_non_nullable
              as int,
      updateCount: null == updateCount
          ? _value.updateCount
          : updateCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$StreamingMessageImpl extends _StreamingMessage {
  const _$StreamingMessageImpl(
      {required this.messageId,
      required this.conversationId,
      required this.assistantId,
      this.modelId,
      this.content = '',
      this.thinking = '',
      this.isComplete = false,
      this.hasError = false,
      this.errorMessage,
      this.startTime = null,
      this.lastUpdateTime = null,
      this.completionTime = null,
      final Map<String, dynamic> metadata = const {},
      this.contentLength = 0,
      this.updateCount = 0})
      : _metadata = metadata,
        super._();

  /// Unique message ID
  @override
  final String messageId;

  /// Conversation this message belongs to
  @override
  final String conversationId;

  /// Assistant ID generating this message
  @override
  final String assistantId;

  /// Model being used (optional)
  @override
  final String? modelId;

  /// Current accumulated content
  @override
  @JsonKey()
  final String content;

  /// Thinking process content (for models that support it)
  @override
  @JsonKey()
  final String thinking;

  /// Whether the stream has completed
  @override
  @JsonKey()
  final bool isComplete;

  /// Whether the stream encountered an error
  @override
  @JsonKey()
  final bool hasError;

  /// Error message if any
  @override
  final String? errorMessage;

  /// When the stream started
  @override
  @JsonKey()
  final DateTime? startTime;

  /// Last update timestamp
  @override
  @JsonKey()
  final DateTime? lastUpdateTime;

  /// Completion timestamp
  @override
  @JsonKey()
  final DateTime? completionTime;

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

  /// Content length for performance tracking
  @override
  @JsonKey()
  final int contentLength;

  /// Number of updates received
  @override
  @JsonKey()
  final int updateCount;

  @override
  String toString() {
    return 'StreamingMessage(messageId: $messageId, conversationId: $conversationId, assistantId: $assistantId, modelId: $modelId, content: $content, thinking: $thinking, isComplete: $isComplete, hasError: $hasError, errorMessage: $errorMessage, startTime: $startTime, lastUpdateTime: $lastUpdateTime, completionTime: $completionTime, metadata: $metadata, contentLength: $contentLength, updateCount: $updateCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreamingMessageImpl &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.assistantId, assistantId) ||
                other.assistantId == assistantId) &&
            (identical(other.modelId, modelId) || other.modelId == modelId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.thinking, thinking) ||
                other.thinking == thinking) &&
            (identical(other.isComplete, isComplete) ||
                other.isComplete == isComplete) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.lastUpdateTime, lastUpdateTime) ||
                other.lastUpdateTime == lastUpdateTime) &&
            (identical(other.completionTime, completionTime) ||
                other.completionTime == completionTime) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.contentLength, contentLength) ||
                other.contentLength == contentLength) &&
            (identical(other.updateCount, updateCount) ||
                other.updateCount == updateCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      messageId,
      conversationId,
      assistantId,
      modelId,
      content,
      thinking,
      isComplete,
      hasError,
      errorMessage,
      startTime,
      lastUpdateTime,
      completionTime,
      const DeepCollectionEquality().hash(_metadata),
      contentLength,
      updateCount);

  /// Create a copy of StreamingMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StreamingMessageImplCopyWith<_$StreamingMessageImpl> get copyWith =>
      __$$StreamingMessageImplCopyWithImpl<_$StreamingMessageImpl>(
          this, _$identity);
}

abstract class _StreamingMessage extends StreamingMessage {
  const factory _StreamingMessage(
      {required final String messageId,
      required final String conversationId,
      required final String assistantId,
      final String? modelId,
      final String content,
      final String thinking,
      final bool isComplete,
      final bool hasError,
      final String? errorMessage,
      final DateTime? startTime,
      final DateTime? lastUpdateTime,
      final DateTime? completionTime,
      final Map<String, dynamic> metadata,
      final int contentLength,
      final int updateCount}) = _$StreamingMessageImpl;
  const _StreamingMessage._() : super._();

  /// Unique message ID
  @override
  String get messageId;

  /// Conversation this message belongs to
  @override
  String get conversationId;

  /// Assistant ID generating this message
  @override
  String get assistantId;

  /// Model being used (optional)
  @override
  String? get modelId;

  /// Current accumulated content
  @override
  String get content;

  /// Thinking process content (for models that support it)
  @override
  String get thinking;

  /// Whether the stream has completed
  @override
  bool get isComplete;

  /// Whether the stream encountered an error
  @override
  bool get hasError;

  /// Error message if any
  @override
  String? get errorMessage;

  /// When the stream started
  @override
  DateTime? get startTime;

  /// Last update timestamp
  @override
  DateTime? get lastUpdateTime;

  /// Completion timestamp
  @override
  DateTime? get completionTime;

  /// Additional metadata
  @override
  Map<String, dynamic> get metadata;

  /// Content length for performance tracking
  @override
  int get contentLength;

  /// Number of updates received
  @override
  int get updateCount;

  /// Create a copy of StreamingMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StreamingMessageImplCopyWith<_$StreamingMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$StreamingState {
// === Active Streams Management ===
  /// Map of active streaming messages (messageId -> StreamingMessage)
  /// Similar to Cherry Studio's block management
  Map<String, StreamingMessage> get activeStreams =>
      throw _privateConstructorUsedError; // === Global Streaming Status ===
  /// Overall streaming status
  StreamingStatus get status => throw _privateConstructorUsedError;

  /// Global streaming error
  String? get error =>
      throw _privateConstructorUsedError; // === Performance Metrics ===
  /// Total number of streams processed in this session
  int get totalStreams => throw _privateConstructorUsedError;

  /// Current number of active streams
  int get activeStreamCount => throw _privateConstructorUsedError;

  /// Maximum concurrent streams reached
  int get maxConcurrentStreams => throw _privateConstructorUsedError;

  /// Last stream activity timestamp
  DateTime? get lastStreamTime =>
      throw _privateConstructorUsedError; // === Configuration ===
  /// Maximum allowed concurrent streams
  int get maxAllowedConcurrentStreams => throw _privateConstructorUsedError;

  /// Stream timeout duration in seconds
  int get streamTimeoutSeconds =>
      throw _privateConstructorUsedError; // === Stream History (for debugging) ===
  /// Recently completed streams (limited to last 10)
  List<StreamingMessage> get recentCompletedStreams =>
      throw _privateConstructorUsedError;

  /// Stream performance metrics
  StreamingMetrics get metrics => throw _privateConstructorUsedError;

  /// Create a copy of StreamingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StreamingStateCopyWith<StreamingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreamingStateCopyWith<$Res> {
  factory $StreamingStateCopyWith(
          StreamingState value, $Res Function(StreamingState) then) =
      _$StreamingStateCopyWithImpl<$Res, StreamingState>;
  @useResult
  $Res call(
      {Map<String, StreamingMessage> activeStreams,
      StreamingStatus status,
      String? error,
      int totalStreams,
      int activeStreamCount,
      int maxConcurrentStreams,
      DateTime? lastStreamTime,
      int maxAllowedConcurrentStreams,
      int streamTimeoutSeconds,
      List<StreamingMessage> recentCompletedStreams,
      StreamingMetrics metrics});

  $StreamingMetricsCopyWith<$Res> get metrics;
}

/// @nodoc
class _$StreamingStateCopyWithImpl<$Res, $Val extends StreamingState>
    implements $StreamingStateCopyWith<$Res> {
  _$StreamingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StreamingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activeStreams = null,
    Object? status = null,
    Object? error = freezed,
    Object? totalStreams = null,
    Object? activeStreamCount = null,
    Object? maxConcurrentStreams = null,
    Object? lastStreamTime = freezed,
    Object? maxAllowedConcurrentStreams = null,
    Object? streamTimeoutSeconds = null,
    Object? recentCompletedStreams = null,
    Object? metrics = null,
  }) {
    return _then(_value.copyWith(
      activeStreams: null == activeStreams
          ? _value.activeStreams
          : activeStreams // ignore: cast_nullable_to_non_nullable
              as Map<String, StreamingMessage>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as StreamingStatus,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      totalStreams: null == totalStreams
          ? _value.totalStreams
          : totalStreams // ignore: cast_nullable_to_non_nullable
              as int,
      activeStreamCount: null == activeStreamCount
          ? _value.activeStreamCount
          : activeStreamCount // ignore: cast_nullable_to_non_nullable
              as int,
      maxConcurrentStreams: null == maxConcurrentStreams
          ? _value.maxConcurrentStreams
          : maxConcurrentStreams // ignore: cast_nullable_to_non_nullable
              as int,
      lastStreamTime: freezed == lastStreamTime
          ? _value.lastStreamTime
          : lastStreamTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      maxAllowedConcurrentStreams: null == maxAllowedConcurrentStreams
          ? _value.maxAllowedConcurrentStreams
          : maxAllowedConcurrentStreams // ignore: cast_nullable_to_non_nullable
              as int,
      streamTimeoutSeconds: null == streamTimeoutSeconds
          ? _value.streamTimeoutSeconds
          : streamTimeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      recentCompletedStreams: null == recentCompletedStreams
          ? _value.recentCompletedStreams
          : recentCompletedStreams // ignore: cast_nullable_to_non_nullable
              as List<StreamingMessage>,
      metrics: null == metrics
          ? _value.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as StreamingMetrics,
    ) as $Val);
  }

  /// Create a copy of StreamingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StreamingMetricsCopyWith<$Res> get metrics {
    return $StreamingMetricsCopyWith<$Res>(_value.metrics, (value) {
      return _then(_value.copyWith(metrics: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StreamingStateImplCopyWith<$Res>
    implements $StreamingStateCopyWith<$Res> {
  factory _$$StreamingStateImplCopyWith(_$StreamingStateImpl value,
          $Res Function(_$StreamingStateImpl) then) =
      __$$StreamingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<String, StreamingMessage> activeStreams,
      StreamingStatus status,
      String? error,
      int totalStreams,
      int activeStreamCount,
      int maxConcurrentStreams,
      DateTime? lastStreamTime,
      int maxAllowedConcurrentStreams,
      int streamTimeoutSeconds,
      List<StreamingMessage> recentCompletedStreams,
      StreamingMetrics metrics});

  @override
  $StreamingMetricsCopyWith<$Res> get metrics;
}

/// @nodoc
class __$$StreamingStateImplCopyWithImpl<$Res>
    extends _$StreamingStateCopyWithImpl<$Res, _$StreamingStateImpl>
    implements _$$StreamingStateImplCopyWith<$Res> {
  __$$StreamingStateImplCopyWithImpl(
      _$StreamingStateImpl _value, $Res Function(_$StreamingStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of StreamingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activeStreams = null,
    Object? status = null,
    Object? error = freezed,
    Object? totalStreams = null,
    Object? activeStreamCount = null,
    Object? maxConcurrentStreams = null,
    Object? lastStreamTime = freezed,
    Object? maxAllowedConcurrentStreams = null,
    Object? streamTimeoutSeconds = null,
    Object? recentCompletedStreams = null,
    Object? metrics = null,
  }) {
    return _then(_$StreamingStateImpl(
      activeStreams: null == activeStreams
          ? _value._activeStreams
          : activeStreams // ignore: cast_nullable_to_non_nullable
              as Map<String, StreamingMessage>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as StreamingStatus,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      totalStreams: null == totalStreams
          ? _value.totalStreams
          : totalStreams // ignore: cast_nullable_to_non_nullable
              as int,
      activeStreamCount: null == activeStreamCount
          ? _value.activeStreamCount
          : activeStreamCount // ignore: cast_nullable_to_non_nullable
              as int,
      maxConcurrentStreams: null == maxConcurrentStreams
          ? _value.maxConcurrentStreams
          : maxConcurrentStreams // ignore: cast_nullable_to_non_nullable
              as int,
      lastStreamTime: freezed == lastStreamTime
          ? _value.lastStreamTime
          : lastStreamTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      maxAllowedConcurrentStreams: null == maxAllowedConcurrentStreams
          ? _value.maxAllowedConcurrentStreams
          : maxAllowedConcurrentStreams // ignore: cast_nullable_to_non_nullable
              as int,
      streamTimeoutSeconds: null == streamTimeoutSeconds
          ? _value.streamTimeoutSeconds
          : streamTimeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      recentCompletedStreams: null == recentCompletedStreams
          ? _value._recentCompletedStreams
          : recentCompletedStreams // ignore: cast_nullable_to_non_nullable
              as List<StreamingMessage>,
      metrics: null == metrics
          ? _value.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as StreamingMetrics,
    ));
  }
}

/// @nodoc

class _$StreamingStateImpl extends _StreamingState {
  const _$StreamingStateImpl(
      {final Map<String, StreamingMessage> activeStreams = const {},
      this.status = StreamingStatus.idle,
      this.error = null,
      this.totalStreams = 0,
      this.activeStreamCount = 0,
      this.maxConcurrentStreams = 0,
      this.lastStreamTime = null,
      this.maxAllowedConcurrentStreams = 3,
      this.streamTimeoutSeconds = 30,
      final List<StreamingMessage> recentCompletedStreams = const [],
      this.metrics = const StreamingMetrics()})
      : _activeStreams = activeStreams,
        _recentCompletedStreams = recentCompletedStreams,
        super._();

// === Active Streams Management ===
  /// Map of active streaming messages (messageId -> StreamingMessage)
  /// Similar to Cherry Studio's block management
  final Map<String, StreamingMessage> _activeStreams;
// === Active Streams Management ===
  /// Map of active streaming messages (messageId -> StreamingMessage)
  /// Similar to Cherry Studio's block management
  @override
  @JsonKey()
  Map<String, StreamingMessage> get activeStreams {
    if (_activeStreams is EqualUnmodifiableMapView) return _activeStreams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_activeStreams);
  }

// === Global Streaming Status ===
  /// Overall streaming status
  @override
  @JsonKey()
  final StreamingStatus status;

  /// Global streaming error
  @override
  @JsonKey()
  final String? error;
// === Performance Metrics ===
  /// Total number of streams processed in this session
  @override
  @JsonKey()
  final int totalStreams;

  /// Current number of active streams
  @override
  @JsonKey()
  final int activeStreamCount;

  /// Maximum concurrent streams reached
  @override
  @JsonKey()
  final int maxConcurrentStreams;

  /// Last stream activity timestamp
  @override
  @JsonKey()
  final DateTime? lastStreamTime;
// === Configuration ===
  /// Maximum allowed concurrent streams
  @override
  @JsonKey()
  final int maxAllowedConcurrentStreams;

  /// Stream timeout duration in seconds
  @override
  @JsonKey()
  final int streamTimeoutSeconds;
// === Stream History (for debugging) ===
  /// Recently completed streams (limited to last 10)
  final List<StreamingMessage> _recentCompletedStreams;
// === Stream History (for debugging) ===
  /// Recently completed streams (limited to last 10)
  @override
  @JsonKey()
  List<StreamingMessage> get recentCompletedStreams {
    if (_recentCompletedStreams is EqualUnmodifiableListView)
      return _recentCompletedStreams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentCompletedStreams);
  }

  /// Stream performance metrics
  @override
  @JsonKey()
  final StreamingMetrics metrics;

  @override
  String toString() {
    return 'StreamingState(activeStreams: $activeStreams, status: $status, error: $error, totalStreams: $totalStreams, activeStreamCount: $activeStreamCount, maxConcurrentStreams: $maxConcurrentStreams, lastStreamTime: $lastStreamTime, maxAllowedConcurrentStreams: $maxAllowedConcurrentStreams, streamTimeoutSeconds: $streamTimeoutSeconds, recentCompletedStreams: $recentCompletedStreams, metrics: $metrics)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreamingStateImpl &&
            const DeepCollectionEquality()
                .equals(other._activeStreams, _activeStreams) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.totalStreams, totalStreams) ||
                other.totalStreams == totalStreams) &&
            (identical(other.activeStreamCount, activeStreamCount) ||
                other.activeStreamCount == activeStreamCount) &&
            (identical(other.maxConcurrentStreams, maxConcurrentStreams) ||
                other.maxConcurrentStreams == maxConcurrentStreams) &&
            (identical(other.lastStreamTime, lastStreamTime) ||
                other.lastStreamTime == lastStreamTime) &&
            (identical(other.maxAllowedConcurrentStreams,
                    maxAllowedConcurrentStreams) ||
                other.maxAllowedConcurrentStreams ==
                    maxAllowedConcurrentStreams) &&
            (identical(other.streamTimeoutSeconds, streamTimeoutSeconds) ||
                other.streamTimeoutSeconds == streamTimeoutSeconds) &&
            const DeepCollectionEquality().equals(
                other._recentCompletedStreams, _recentCompletedStreams) &&
            (identical(other.metrics, metrics) || other.metrics == metrics));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_activeStreams),
      status,
      error,
      totalStreams,
      activeStreamCount,
      maxConcurrentStreams,
      lastStreamTime,
      maxAllowedConcurrentStreams,
      streamTimeoutSeconds,
      const DeepCollectionEquality().hash(_recentCompletedStreams),
      metrics);

  /// Create a copy of StreamingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StreamingStateImplCopyWith<_$StreamingStateImpl> get copyWith =>
      __$$StreamingStateImplCopyWithImpl<_$StreamingStateImpl>(
          this, _$identity);
}

abstract class _StreamingState extends StreamingState {
  const factory _StreamingState(
      {final Map<String, StreamingMessage> activeStreams,
      final StreamingStatus status,
      final String? error,
      final int totalStreams,
      final int activeStreamCount,
      final int maxConcurrentStreams,
      final DateTime? lastStreamTime,
      final int maxAllowedConcurrentStreams,
      final int streamTimeoutSeconds,
      final List<StreamingMessage> recentCompletedStreams,
      final StreamingMetrics metrics}) = _$StreamingStateImpl;
  const _StreamingState._() : super._();

// === Active Streams Management ===
  /// Map of active streaming messages (messageId -> StreamingMessage)
  /// Similar to Cherry Studio's block management
  @override
  Map<String, StreamingMessage>
      get activeStreams; // === Global Streaming Status ===
  /// Overall streaming status
  @override
  StreamingStatus get status;

  /// Global streaming error
  @override
  String? get error; // === Performance Metrics ===
  /// Total number of streams processed in this session
  @override
  int get totalStreams;

  /// Current number of active streams
  @override
  int get activeStreamCount;

  /// Maximum concurrent streams reached
  @override
  int get maxConcurrentStreams;

  /// Last stream activity timestamp
  @override
  DateTime? get lastStreamTime; // === Configuration ===
  /// Maximum allowed concurrent streams
  @override
  int get maxAllowedConcurrentStreams;

  /// Stream timeout duration in seconds
  @override
  int get streamTimeoutSeconds; // === Stream History (for debugging) ===
  /// Recently completed streams (limited to last 10)
  @override
  List<StreamingMessage> get recentCompletedStreams;

  /// Stream performance metrics
  @override
  StreamingMetrics get metrics;

  /// Create a copy of StreamingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StreamingStateImplCopyWith<_$StreamingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$StreamingMetrics {
  /// Average stream duration in milliseconds
  double get averageStreamDuration => throw _privateConstructorUsedError;

  /// Average content length per stream
  double get averageContentLength => throw _privateConstructorUsedError;

  /// Average updates per stream
  double get averageUpdatesPerStream => throw _privateConstructorUsedError;

  /// Total characters streamed
  int get totalCharactersStreamed => throw _privateConstructorUsedError;

  /// Total updates processed
  int get totalUpdatesProcessed => throw _privateConstructorUsedError;

  /// Success rate (completed / total)
  double get successRate => throw _privateConstructorUsedError;

  /// Error rate (errors / total)
  double get errorRate => throw _privateConstructorUsedError;

  /// Create a copy of StreamingMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StreamingMetricsCopyWith<StreamingMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreamingMetricsCopyWith<$Res> {
  factory $StreamingMetricsCopyWith(
          StreamingMetrics value, $Res Function(StreamingMetrics) then) =
      _$StreamingMetricsCopyWithImpl<$Res, StreamingMetrics>;
  @useResult
  $Res call(
      {double averageStreamDuration,
      double averageContentLength,
      double averageUpdatesPerStream,
      int totalCharactersStreamed,
      int totalUpdatesProcessed,
      double successRate,
      double errorRate});
}

/// @nodoc
class _$StreamingMetricsCopyWithImpl<$Res, $Val extends StreamingMetrics>
    implements $StreamingMetricsCopyWith<$Res> {
  _$StreamingMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StreamingMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? averageStreamDuration = null,
    Object? averageContentLength = null,
    Object? averageUpdatesPerStream = null,
    Object? totalCharactersStreamed = null,
    Object? totalUpdatesProcessed = null,
    Object? successRate = null,
    Object? errorRate = null,
  }) {
    return _then(_value.copyWith(
      averageStreamDuration: null == averageStreamDuration
          ? _value.averageStreamDuration
          : averageStreamDuration // ignore: cast_nullable_to_non_nullable
              as double,
      averageContentLength: null == averageContentLength
          ? _value.averageContentLength
          : averageContentLength // ignore: cast_nullable_to_non_nullable
              as double,
      averageUpdatesPerStream: null == averageUpdatesPerStream
          ? _value.averageUpdatesPerStream
          : averageUpdatesPerStream // ignore: cast_nullable_to_non_nullable
              as double,
      totalCharactersStreamed: null == totalCharactersStreamed
          ? _value.totalCharactersStreamed
          : totalCharactersStreamed // ignore: cast_nullable_to_non_nullable
              as int,
      totalUpdatesProcessed: null == totalUpdatesProcessed
          ? _value.totalUpdatesProcessed
          : totalUpdatesProcessed // ignore: cast_nullable_to_non_nullable
              as int,
      successRate: null == successRate
          ? _value.successRate
          : successRate // ignore: cast_nullable_to_non_nullable
              as double,
      errorRate: null == errorRate
          ? _value.errorRate
          : errorRate // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StreamingMetricsImplCopyWith<$Res>
    implements $StreamingMetricsCopyWith<$Res> {
  factory _$$StreamingMetricsImplCopyWith(_$StreamingMetricsImpl value,
          $Res Function(_$StreamingMetricsImpl) then) =
      __$$StreamingMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double averageStreamDuration,
      double averageContentLength,
      double averageUpdatesPerStream,
      int totalCharactersStreamed,
      int totalUpdatesProcessed,
      double successRate,
      double errorRate});
}

/// @nodoc
class __$$StreamingMetricsImplCopyWithImpl<$Res>
    extends _$StreamingMetricsCopyWithImpl<$Res, _$StreamingMetricsImpl>
    implements _$$StreamingMetricsImplCopyWith<$Res> {
  __$$StreamingMetricsImplCopyWithImpl(_$StreamingMetricsImpl _value,
      $Res Function(_$StreamingMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of StreamingMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? averageStreamDuration = null,
    Object? averageContentLength = null,
    Object? averageUpdatesPerStream = null,
    Object? totalCharactersStreamed = null,
    Object? totalUpdatesProcessed = null,
    Object? successRate = null,
    Object? errorRate = null,
  }) {
    return _then(_$StreamingMetricsImpl(
      averageStreamDuration: null == averageStreamDuration
          ? _value.averageStreamDuration
          : averageStreamDuration // ignore: cast_nullable_to_non_nullable
              as double,
      averageContentLength: null == averageContentLength
          ? _value.averageContentLength
          : averageContentLength // ignore: cast_nullable_to_non_nullable
              as double,
      averageUpdatesPerStream: null == averageUpdatesPerStream
          ? _value.averageUpdatesPerStream
          : averageUpdatesPerStream // ignore: cast_nullable_to_non_nullable
              as double,
      totalCharactersStreamed: null == totalCharactersStreamed
          ? _value.totalCharactersStreamed
          : totalCharactersStreamed // ignore: cast_nullable_to_non_nullable
              as int,
      totalUpdatesProcessed: null == totalUpdatesProcessed
          ? _value.totalUpdatesProcessed
          : totalUpdatesProcessed // ignore: cast_nullable_to_non_nullable
              as int,
      successRate: null == successRate
          ? _value.successRate
          : successRate // ignore: cast_nullable_to_non_nullable
              as double,
      errorRate: null == errorRate
          ? _value.errorRate
          : errorRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$StreamingMetricsImpl implements _StreamingMetrics {
  const _$StreamingMetricsImpl(
      {this.averageStreamDuration = 0,
      this.averageContentLength = 0,
      this.averageUpdatesPerStream = 0,
      this.totalCharactersStreamed = 0,
      this.totalUpdatesProcessed = 0,
      this.successRate = 0.0,
      this.errorRate = 0.0});

  /// Average stream duration in milliseconds
  @override
  @JsonKey()
  final double averageStreamDuration;

  /// Average content length per stream
  @override
  @JsonKey()
  final double averageContentLength;

  /// Average updates per stream
  @override
  @JsonKey()
  final double averageUpdatesPerStream;

  /// Total characters streamed
  @override
  @JsonKey()
  final int totalCharactersStreamed;

  /// Total updates processed
  @override
  @JsonKey()
  final int totalUpdatesProcessed;

  /// Success rate (completed / total)
  @override
  @JsonKey()
  final double successRate;

  /// Error rate (errors / total)
  @override
  @JsonKey()
  final double errorRate;

  @override
  String toString() {
    return 'StreamingMetrics(averageStreamDuration: $averageStreamDuration, averageContentLength: $averageContentLength, averageUpdatesPerStream: $averageUpdatesPerStream, totalCharactersStreamed: $totalCharactersStreamed, totalUpdatesProcessed: $totalUpdatesProcessed, successRate: $successRate, errorRate: $errorRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreamingMetricsImpl &&
            (identical(other.averageStreamDuration, averageStreamDuration) ||
                other.averageStreamDuration == averageStreamDuration) &&
            (identical(other.averageContentLength, averageContentLength) ||
                other.averageContentLength == averageContentLength) &&
            (identical(
                    other.averageUpdatesPerStream, averageUpdatesPerStream) ||
                other.averageUpdatesPerStream == averageUpdatesPerStream) &&
            (identical(
                    other.totalCharactersStreamed, totalCharactersStreamed) ||
                other.totalCharactersStreamed == totalCharactersStreamed) &&
            (identical(other.totalUpdatesProcessed, totalUpdatesProcessed) ||
                other.totalUpdatesProcessed == totalUpdatesProcessed) &&
            (identical(other.successRate, successRate) ||
                other.successRate == successRate) &&
            (identical(other.errorRate, errorRate) ||
                other.errorRate == errorRate));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      averageStreamDuration,
      averageContentLength,
      averageUpdatesPerStream,
      totalCharactersStreamed,
      totalUpdatesProcessed,
      successRate,
      errorRate);

  /// Create a copy of StreamingMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StreamingMetricsImplCopyWith<_$StreamingMetricsImpl> get copyWith =>
      __$$StreamingMetricsImplCopyWithImpl<_$StreamingMetricsImpl>(
          this, _$identity);
}

abstract class _StreamingMetrics implements StreamingMetrics {
  const factory _StreamingMetrics(
      {final double averageStreamDuration,
      final double averageContentLength,
      final double averageUpdatesPerStream,
      final int totalCharactersStreamed,
      final int totalUpdatesProcessed,
      final double successRate,
      final double errorRate}) = _$StreamingMetricsImpl;

  /// Average stream duration in milliseconds
  @override
  double get averageStreamDuration;

  /// Average content length per stream
  @override
  double get averageContentLength;

  /// Average updates per stream
  @override
  double get averageUpdatesPerStream;

  /// Total characters streamed
  @override
  int get totalCharactersStreamed;

  /// Total updates processed
  @override
  int get totalUpdatesProcessed;

  /// Success rate (completed / total)
  @override
  double get successRate;

  /// Error rate (errors / total)
  @override
  double get errorRate;

  /// Create a copy of StreamingMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StreamingMetricsImplCopyWith<_$StreamingMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
