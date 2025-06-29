// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_block_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EnhancedMessageBlock {
  /// Unique block ID
  String get id => throw _privateConstructorUsedError;

  /// Message this block belongs to
  String get messageId => throw _privateConstructorUsedError;

  /// Block type
  EnhancedMessageBlockType get type => throw _privateConstructorUsedError;

  /// Block content
  String get content => throw _privateConstructorUsedError;

  /// Block status
  MessageBlockStatus get status => throw _privateConstructorUsedError;

  /// Creation timestamp
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Last update timestamp
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Block metadata (tool responses, citations, etc.)
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Block order within the message
  int get order => throw _privateConstructorUsedError;

  /// Whether this block should be persisted
  bool get shouldPersist => throw _privateConstructorUsedError;

  /// Citation references (for blocks that reference other blocks)
  List<String> get citationReferences => throw _privateConstructorUsedError;

  /// Tool call information (for tool blocks)
  ToolCallInfo? get toolCallInfo => throw _privateConstructorUsedError;

  /// Thinking duration in milliseconds (for thinking blocks)
  int? get thinkingMilliseconds => throw _privateConstructorUsedError;

  /// Error details (for error blocks)
  BlockErrorInfo? get errorInfo => throw _privateConstructorUsedError;

  /// Create a copy of EnhancedMessageBlock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EnhancedMessageBlockCopyWith<EnhancedMessageBlock> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EnhancedMessageBlockCopyWith<$Res> {
  factory $EnhancedMessageBlockCopyWith(EnhancedMessageBlock value,
          $Res Function(EnhancedMessageBlock) then) =
      _$EnhancedMessageBlockCopyWithImpl<$Res, EnhancedMessageBlock>;
  @useResult
  $Res call(
      {String id,
      String messageId,
      EnhancedMessageBlockType type,
      String content,
      MessageBlockStatus status,
      DateTime createdAt,
      DateTime? updatedAt,
      Map<String, dynamic> metadata,
      int order,
      bool shouldPersist,
      List<String> citationReferences,
      ToolCallInfo? toolCallInfo,
      int? thinkingMilliseconds,
      BlockErrorInfo? errorInfo});

  $ToolCallInfoCopyWith<$Res>? get toolCallInfo;
  $BlockErrorInfoCopyWith<$Res>? get errorInfo;
}

/// @nodoc
class _$EnhancedMessageBlockCopyWithImpl<$Res,
        $Val extends EnhancedMessageBlock>
    implements $EnhancedMessageBlockCopyWith<$Res> {
  _$EnhancedMessageBlockCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EnhancedMessageBlock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messageId = null,
    Object? type = null,
    Object? content = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? metadata = null,
    Object? order = null,
    Object? shouldPersist = null,
    Object? citationReferences = null,
    Object? toolCallInfo = freezed,
    Object? thinkingMilliseconds = freezed,
    Object? errorInfo = freezed,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as EnhancedMessageBlockType,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MessageBlockStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      shouldPersist: null == shouldPersist
          ? _value.shouldPersist
          : shouldPersist // ignore: cast_nullable_to_non_nullable
              as bool,
      citationReferences: null == citationReferences
          ? _value.citationReferences
          : citationReferences // ignore: cast_nullable_to_non_nullable
              as List<String>,
      toolCallInfo: freezed == toolCallInfo
          ? _value.toolCallInfo
          : toolCallInfo // ignore: cast_nullable_to_non_nullable
              as ToolCallInfo?,
      thinkingMilliseconds: freezed == thinkingMilliseconds
          ? _value.thinkingMilliseconds
          : thinkingMilliseconds // ignore: cast_nullable_to_non_nullable
              as int?,
      errorInfo: freezed == errorInfo
          ? _value.errorInfo
          : errorInfo // ignore: cast_nullable_to_non_nullable
              as BlockErrorInfo?,
    ) as $Val);
  }

  /// Create a copy of EnhancedMessageBlock
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ToolCallInfoCopyWith<$Res>? get toolCallInfo {
    if (_value.toolCallInfo == null) {
      return null;
    }

    return $ToolCallInfoCopyWith<$Res>(_value.toolCallInfo!, (value) {
      return _then(_value.copyWith(toolCallInfo: value) as $Val);
    });
  }

  /// Create a copy of EnhancedMessageBlock
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BlockErrorInfoCopyWith<$Res>? get errorInfo {
    if (_value.errorInfo == null) {
      return null;
    }

    return $BlockErrorInfoCopyWith<$Res>(_value.errorInfo!, (value) {
      return _then(_value.copyWith(errorInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EnhancedMessageBlockImplCopyWith<$Res>
    implements $EnhancedMessageBlockCopyWith<$Res> {
  factory _$$EnhancedMessageBlockImplCopyWith(_$EnhancedMessageBlockImpl value,
          $Res Function(_$EnhancedMessageBlockImpl) then) =
      __$$EnhancedMessageBlockImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String messageId,
      EnhancedMessageBlockType type,
      String content,
      MessageBlockStatus status,
      DateTime createdAt,
      DateTime? updatedAt,
      Map<String, dynamic> metadata,
      int order,
      bool shouldPersist,
      List<String> citationReferences,
      ToolCallInfo? toolCallInfo,
      int? thinkingMilliseconds,
      BlockErrorInfo? errorInfo});

  @override
  $ToolCallInfoCopyWith<$Res>? get toolCallInfo;
  @override
  $BlockErrorInfoCopyWith<$Res>? get errorInfo;
}

/// @nodoc
class __$$EnhancedMessageBlockImplCopyWithImpl<$Res>
    extends _$EnhancedMessageBlockCopyWithImpl<$Res, _$EnhancedMessageBlockImpl>
    implements _$$EnhancedMessageBlockImplCopyWith<$Res> {
  __$$EnhancedMessageBlockImplCopyWithImpl(_$EnhancedMessageBlockImpl _value,
      $Res Function(_$EnhancedMessageBlockImpl) _then)
      : super(_value, _then);

  /// Create a copy of EnhancedMessageBlock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messageId = null,
    Object? type = null,
    Object? content = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? metadata = null,
    Object? order = null,
    Object? shouldPersist = null,
    Object? citationReferences = null,
    Object? toolCallInfo = freezed,
    Object? thinkingMilliseconds = freezed,
    Object? errorInfo = freezed,
  }) {
    return _then(_$EnhancedMessageBlockImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as EnhancedMessageBlockType,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MessageBlockStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      shouldPersist: null == shouldPersist
          ? _value.shouldPersist
          : shouldPersist // ignore: cast_nullable_to_non_nullable
              as bool,
      citationReferences: null == citationReferences
          ? _value._citationReferences
          : citationReferences // ignore: cast_nullable_to_non_nullable
              as List<String>,
      toolCallInfo: freezed == toolCallInfo
          ? _value.toolCallInfo
          : toolCallInfo // ignore: cast_nullable_to_non_nullable
              as ToolCallInfo?,
      thinkingMilliseconds: freezed == thinkingMilliseconds
          ? _value.thinkingMilliseconds
          : thinkingMilliseconds // ignore: cast_nullable_to_non_nullable
              as int?,
      errorInfo: freezed == errorInfo
          ? _value.errorInfo
          : errorInfo // ignore: cast_nullable_to_non_nullable
              as BlockErrorInfo?,
    ));
  }
}

/// @nodoc

class _$EnhancedMessageBlockImpl extends _EnhancedMessageBlock {
  const _$EnhancedMessageBlockImpl(
      {required this.id,
      required this.messageId,
      required this.type,
      this.content = '',
      this.status = MessageBlockStatus.pending,
      required this.createdAt,
      this.updatedAt = null,
      final Map<String, dynamic> metadata = const {},
      this.order = 0,
      this.shouldPersist = true,
      final List<String> citationReferences = const [],
      this.toolCallInfo = null,
      this.thinkingMilliseconds = null,
      this.errorInfo = null})
      : _metadata = metadata,
        _citationReferences = citationReferences,
        super._();

  /// Unique block ID
  @override
  final String id;

  /// Message this block belongs to
  @override
  final String messageId;

  /// Block type
  @override
  final EnhancedMessageBlockType type;

  /// Block content
  @override
  @JsonKey()
  final String content;

  /// Block status
  @override
  @JsonKey()
  final MessageBlockStatus status;

  /// Creation timestamp
  @override
  final DateTime createdAt;

  /// Last update timestamp
  @override
  @JsonKey()
  final DateTime? updatedAt;

  /// Block metadata (tool responses, citations, etc.)
  final Map<String, dynamic> _metadata;

  /// Block metadata (tool responses, citations, etc.)
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  /// Block order within the message
  @override
  @JsonKey()
  final int order;

  /// Whether this block should be persisted
  @override
  @JsonKey()
  final bool shouldPersist;

  /// Citation references (for blocks that reference other blocks)
  final List<String> _citationReferences;

  /// Citation references (for blocks that reference other blocks)
  @override
  @JsonKey()
  List<String> get citationReferences {
    if (_citationReferences is EqualUnmodifiableListView)
      return _citationReferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_citationReferences);
  }

  /// Tool call information (for tool blocks)
  @override
  @JsonKey()
  final ToolCallInfo? toolCallInfo;

  /// Thinking duration in milliseconds (for thinking blocks)
  @override
  @JsonKey()
  final int? thinkingMilliseconds;

  /// Error details (for error blocks)
  @override
  @JsonKey()
  final BlockErrorInfo? errorInfo;

  @override
  String toString() {
    return 'EnhancedMessageBlock(id: $id, messageId: $messageId, type: $type, content: $content, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata, order: $order, shouldPersist: $shouldPersist, citationReferences: $citationReferences, toolCallInfo: $toolCallInfo, thinkingMilliseconds: $thinkingMilliseconds, errorInfo: $errorInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EnhancedMessageBlockImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.shouldPersist, shouldPersist) ||
                other.shouldPersist == shouldPersist) &&
            const DeepCollectionEquality()
                .equals(other._citationReferences, _citationReferences) &&
            (identical(other.toolCallInfo, toolCallInfo) ||
                other.toolCallInfo == toolCallInfo) &&
            (identical(other.thinkingMilliseconds, thinkingMilliseconds) ||
                other.thinkingMilliseconds == thinkingMilliseconds) &&
            (identical(other.errorInfo, errorInfo) ||
                other.errorInfo == errorInfo));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      messageId,
      type,
      content,
      status,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_metadata),
      order,
      shouldPersist,
      const DeepCollectionEquality().hash(_citationReferences),
      toolCallInfo,
      thinkingMilliseconds,
      errorInfo);

  /// Create a copy of EnhancedMessageBlock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EnhancedMessageBlockImplCopyWith<_$EnhancedMessageBlockImpl>
      get copyWith =>
          __$$EnhancedMessageBlockImplCopyWithImpl<_$EnhancedMessageBlockImpl>(
              this, _$identity);
}

abstract class _EnhancedMessageBlock extends EnhancedMessageBlock {
  const factory _EnhancedMessageBlock(
      {required final String id,
      required final String messageId,
      required final EnhancedMessageBlockType type,
      final String content,
      final MessageBlockStatus status,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final Map<String, dynamic> metadata,
      final int order,
      final bool shouldPersist,
      final List<String> citationReferences,
      final ToolCallInfo? toolCallInfo,
      final int? thinkingMilliseconds,
      final BlockErrorInfo? errorInfo}) = _$EnhancedMessageBlockImpl;
  const _EnhancedMessageBlock._() : super._();

  /// Unique block ID
  @override
  String get id;

  /// Message this block belongs to
  @override
  String get messageId;

  /// Block type
  @override
  EnhancedMessageBlockType get type;

  /// Block content
  @override
  String get content;

  /// Block status
  @override
  MessageBlockStatus get status;

  /// Creation timestamp
  @override
  DateTime get createdAt;

  /// Last update timestamp
  @override
  DateTime? get updatedAt;

  /// Block metadata (tool responses, citations, etc.)
  @override
  Map<String, dynamic> get metadata;

  /// Block order within the message
  @override
  int get order;

  /// Whether this block should be persisted
  @override
  bool get shouldPersist;

  /// Citation references (for blocks that reference other blocks)
  @override
  List<String> get citationReferences;

  /// Tool call information (for tool blocks)
  @override
  ToolCallInfo? get toolCallInfo;

  /// Thinking duration in milliseconds (for thinking blocks)
  @override
  int? get thinkingMilliseconds;

  /// Error details (for error blocks)
  @override
  BlockErrorInfo? get errorInfo;

  /// Create a copy of EnhancedMessageBlock
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EnhancedMessageBlockImplCopyWith<_$EnhancedMessageBlockImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ToolCallInfo {
  /// Tool call ID
  String get callId => throw _privateConstructorUsedError;

  /// Tool name
  String get toolName => throw _privateConstructorUsedError;

  /// Tool arguments
  Map<String, dynamic> get arguments => throw _privateConstructorUsedError;

  /// Tool response
  String? get response => throw _privateConstructorUsedError;

  /// Tool call status
  ToolCallStatus get status => throw _privateConstructorUsedError;

  /// Error message if tool call failed
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Tool execution duration in milliseconds
  int? get executionTimeMs => throw _privateConstructorUsedError;

  /// Create a copy of ToolCallInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ToolCallInfoCopyWith<ToolCallInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ToolCallInfoCopyWith<$Res> {
  factory $ToolCallInfoCopyWith(
          ToolCallInfo value, $Res Function(ToolCallInfo) then) =
      _$ToolCallInfoCopyWithImpl<$Res, ToolCallInfo>;
  @useResult
  $Res call(
      {String callId,
      String toolName,
      Map<String, dynamic> arguments,
      String? response,
      ToolCallStatus status,
      String? errorMessage,
      int? executionTimeMs});
}

/// @nodoc
class _$ToolCallInfoCopyWithImpl<$Res, $Val extends ToolCallInfo>
    implements $ToolCallInfoCopyWith<$Res> {
  _$ToolCallInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ToolCallInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? callId = null,
    Object? toolName = null,
    Object? arguments = null,
    Object? response = freezed,
    Object? status = null,
    Object? errorMessage = freezed,
    Object? executionTimeMs = freezed,
  }) {
    return _then(_value.copyWith(
      callId: null == callId
          ? _value.callId
          : callId // ignore: cast_nullable_to_non_nullable
              as String,
      toolName: null == toolName
          ? _value.toolName
          : toolName // ignore: cast_nullable_to_non_nullable
              as String,
      arguments: null == arguments
          ? _value.arguments
          : arguments // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      response: freezed == response
          ? _value.response
          : response // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ToolCallStatus,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      executionTimeMs: freezed == executionTimeMs
          ? _value.executionTimeMs
          : executionTimeMs // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ToolCallInfoImplCopyWith<$Res>
    implements $ToolCallInfoCopyWith<$Res> {
  factory _$$ToolCallInfoImplCopyWith(
          _$ToolCallInfoImpl value, $Res Function(_$ToolCallInfoImpl) then) =
      __$$ToolCallInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String callId,
      String toolName,
      Map<String, dynamic> arguments,
      String? response,
      ToolCallStatus status,
      String? errorMessage,
      int? executionTimeMs});
}

/// @nodoc
class __$$ToolCallInfoImplCopyWithImpl<$Res>
    extends _$ToolCallInfoCopyWithImpl<$Res, _$ToolCallInfoImpl>
    implements _$$ToolCallInfoImplCopyWith<$Res> {
  __$$ToolCallInfoImplCopyWithImpl(
      _$ToolCallInfoImpl _value, $Res Function(_$ToolCallInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ToolCallInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? callId = null,
    Object? toolName = null,
    Object? arguments = null,
    Object? response = freezed,
    Object? status = null,
    Object? errorMessage = freezed,
    Object? executionTimeMs = freezed,
  }) {
    return _then(_$ToolCallInfoImpl(
      callId: null == callId
          ? _value.callId
          : callId // ignore: cast_nullable_to_non_nullable
              as String,
      toolName: null == toolName
          ? _value.toolName
          : toolName // ignore: cast_nullable_to_non_nullable
              as String,
      arguments: null == arguments
          ? _value._arguments
          : arguments // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      response: freezed == response
          ? _value.response
          : response // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ToolCallStatus,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      executionTimeMs: freezed == executionTimeMs
          ? _value.executionTimeMs
          : executionTimeMs // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$ToolCallInfoImpl implements _ToolCallInfo {
  const _$ToolCallInfoImpl(
      {required this.callId,
      required this.toolName,
      final Map<String, dynamic> arguments = const {},
      this.response = null,
      this.status = ToolCallStatus.pending,
      this.errorMessage = null,
      this.executionTimeMs = null})
      : _arguments = arguments;

  /// Tool call ID
  @override
  final String callId;

  /// Tool name
  @override
  final String toolName;

  /// Tool arguments
  final Map<String, dynamic> _arguments;

  /// Tool arguments
  @override
  @JsonKey()
  Map<String, dynamic> get arguments {
    if (_arguments is EqualUnmodifiableMapView) return _arguments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_arguments);
  }

  /// Tool response
  @override
  @JsonKey()
  final String? response;

  /// Tool call status
  @override
  @JsonKey()
  final ToolCallStatus status;

  /// Error message if tool call failed
  @override
  @JsonKey()
  final String? errorMessage;

  /// Tool execution duration in milliseconds
  @override
  @JsonKey()
  final int? executionTimeMs;

  @override
  String toString() {
    return 'ToolCallInfo(callId: $callId, toolName: $toolName, arguments: $arguments, response: $response, status: $status, errorMessage: $errorMessage, executionTimeMs: $executionTimeMs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ToolCallInfoImpl &&
            (identical(other.callId, callId) || other.callId == callId) &&
            (identical(other.toolName, toolName) ||
                other.toolName == toolName) &&
            const DeepCollectionEquality()
                .equals(other._arguments, _arguments) &&
            (identical(other.response, response) ||
                other.response == response) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.executionTimeMs, executionTimeMs) ||
                other.executionTimeMs == executionTimeMs));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      callId,
      toolName,
      const DeepCollectionEquality().hash(_arguments),
      response,
      status,
      errorMessage,
      executionTimeMs);

  /// Create a copy of ToolCallInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ToolCallInfoImplCopyWith<_$ToolCallInfoImpl> get copyWith =>
      __$$ToolCallInfoImplCopyWithImpl<_$ToolCallInfoImpl>(this, _$identity);
}

abstract class _ToolCallInfo implements ToolCallInfo {
  const factory _ToolCallInfo(
      {required final String callId,
      required final String toolName,
      final Map<String, dynamic> arguments,
      final String? response,
      final ToolCallStatus status,
      final String? errorMessage,
      final int? executionTimeMs}) = _$ToolCallInfoImpl;

  /// Tool call ID
  @override
  String get callId;

  /// Tool name
  @override
  String get toolName;

  /// Tool arguments
  @override
  Map<String, dynamic> get arguments;

  /// Tool response
  @override
  String? get response;

  /// Tool call status
  @override
  ToolCallStatus get status;

  /// Error message if tool call failed
  @override
  String? get errorMessage;

  /// Tool execution duration in milliseconds
  @override
  int? get executionTimeMs;

  /// Create a copy of ToolCallInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ToolCallInfoImplCopyWith<_$ToolCallInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BlockErrorInfo {
  /// Error code
  String get code => throw _privateConstructorUsedError;

  /// Error message
  String get message => throw _privateConstructorUsedError;

  /// Error details
  Map<String, dynamic> get details => throw _privateConstructorUsedError;

  /// Whether this error is recoverable
  bool get isRecoverable => throw _privateConstructorUsedError;

  /// Suggested recovery action
  String? get recoveryAction => throw _privateConstructorUsedError;

  /// Create a copy of BlockErrorInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BlockErrorInfoCopyWith<BlockErrorInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlockErrorInfoCopyWith<$Res> {
  factory $BlockErrorInfoCopyWith(
          BlockErrorInfo value, $Res Function(BlockErrorInfo) then) =
      _$BlockErrorInfoCopyWithImpl<$Res, BlockErrorInfo>;
  @useResult
  $Res call(
      {String code,
      String message,
      Map<String, dynamic> details,
      bool isRecoverable,
      String? recoveryAction});
}

/// @nodoc
class _$BlockErrorInfoCopyWithImpl<$Res, $Val extends BlockErrorInfo>
    implements $BlockErrorInfoCopyWith<$Res> {
  _$BlockErrorInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BlockErrorInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? message = null,
    Object? details = null,
    Object? isRecoverable = null,
    Object? recoveryAction = freezed,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      details: null == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isRecoverable: null == isRecoverable
          ? _value.isRecoverable
          : isRecoverable // ignore: cast_nullable_to_non_nullable
              as bool,
      recoveryAction: freezed == recoveryAction
          ? _value.recoveryAction
          : recoveryAction // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BlockErrorInfoImplCopyWith<$Res>
    implements $BlockErrorInfoCopyWith<$Res> {
  factory _$$BlockErrorInfoImplCopyWith(_$BlockErrorInfoImpl value,
          $Res Function(_$BlockErrorInfoImpl) then) =
      __$$BlockErrorInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String code,
      String message,
      Map<String, dynamic> details,
      bool isRecoverable,
      String? recoveryAction});
}

/// @nodoc
class __$$BlockErrorInfoImplCopyWithImpl<$Res>
    extends _$BlockErrorInfoCopyWithImpl<$Res, _$BlockErrorInfoImpl>
    implements _$$BlockErrorInfoImplCopyWith<$Res> {
  __$$BlockErrorInfoImplCopyWithImpl(
      _$BlockErrorInfoImpl _value, $Res Function(_$BlockErrorInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of BlockErrorInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? message = null,
    Object? details = null,
    Object? isRecoverable = null,
    Object? recoveryAction = freezed,
  }) {
    return _then(_$BlockErrorInfoImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      details: null == details
          ? _value._details
          : details // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isRecoverable: null == isRecoverable
          ? _value.isRecoverable
          : isRecoverable // ignore: cast_nullable_to_non_nullable
              as bool,
      recoveryAction: freezed == recoveryAction
          ? _value.recoveryAction
          : recoveryAction // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$BlockErrorInfoImpl implements _BlockErrorInfo {
  const _$BlockErrorInfoImpl(
      {required this.code,
      required this.message,
      final Map<String, dynamic> details = const {},
      this.isRecoverable = false,
      this.recoveryAction = null})
      : _details = details;

  /// Error code
  @override
  final String code;

  /// Error message
  @override
  final String message;

  /// Error details
  final Map<String, dynamic> _details;

  /// Error details
  @override
  @JsonKey()
  Map<String, dynamic> get details {
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_details);
  }

  /// Whether this error is recoverable
  @override
  @JsonKey()
  final bool isRecoverable;

  /// Suggested recovery action
  @override
  @JsonKey()
  final String? recoveryAction;

  @override
  String toString() {
    return 'BlockErrorInfo(code: $code, message: $message, details: $details, isRecoverable: $isRecoverable, recoveryAction: $recoveryAction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BlockErrorInfoImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._details, _details) &&
            (identical(other.isRecoverable, isRecoverable) ||
                other.isRecoverable == isRecoverable) &&
            (identical(other.recoveryAction, recoveryAction) ||
                other.recoveryAction == recoveryAction));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      code,
      message,
      const DeepCollectionEquality().hash(_details),
      isRecoverable,
      recoveryAction);

  /// Create a copy of BlockErrorInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BlockErrorInfoImplCopyWith<_$BlockErrorInfoImpl> get copyWith =>
      __$$BlockErrorInfoImplCopyWithImpl<_$BlockErrorInfoImpl>(
          this, _$identity);
}

abstract class _BlockErrorInfo implements BlockErrorInfo {
  const factory _BlockErrorInfo(
      {required final String code,
      required final String message,
      final Map<String, dynamic> details,
      final bool isRecoverable,
      final String? recoveryAction}) = _$BlockErrorInfoImpl;

  /// Error code
  @override
  String get code;

  /// Error message
  @override
  String get message;

  /// Error details
  @override
  Map<String, dynamic> get details;

  /// Whether this error is recoverable
  @override
  bool get isRecoverable;

  /// Suggested recovery action
  @override
  String? get recoveryAction;

  /// Create a copy of BlockErrorInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BlockErrorInfoImplCopyWith<_$BlockErrorInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MessageBlockState {
// === Block Storage (EntityAdapter pattern) ===
  /// All blocks indexed by ID (blockId -> EnhancedMessageBlock)
  Map<String, EnhancedMessageBlock> get blocks =>
      throw _privateConstructorUsedError;

  /// Blocks grouped by message (messageId -> List<blockId>)
  /// Similar to Cherry Studio's message-to-blocks relationship
  Map<String, List<String>> get blocksByMessage =>
      throw _privateConstructorUsedError;

  /// Blocks grouped by type for efficient filtering
  Map<EnhancedMessageBlockType, List<String>> get blocksByType =>
      throw _privateConstructorUsedError; // === Loading State ===
  /// Overall loading state
  MessageBlockLoadingState get loadingState =>
      throw _privateConstructorUsedError;

  /// Error message if loading failed
  String? get error =>
      throw _privateConstructorUsedError; // === Block Status Tracking ===
  /// Status of individual blocks (blockId -> MessageBlockStatus)
  Map<String, MessageBlockStatus> get blockStatuses =>
      throw _privateConstructorUsedError;

  /// Blocks currently being processed
  Set<String> get processingBlocks => throw _privateConstructorUsedError;

  /// Blocks with errors
  Set<String> get errorBlocks =>
      throw _privateConstructorUsedError; // === Performance Metrics ===
  /// Total number of blocks
  int get totalBlocks => throw _privateConstructorUsedError;

  /// Last update timestamp
  DateTime? get lastUpdateTime =>
      throw _privateConstructorUsedError; // === Tool Call Tracking ===
  /// Active tool calls (toolCallId -> blockId)
  /// Similar to Cherry Studio's toolCallIdToBlockIdMap
  Map<String, String> get toolCallToBlockMap =>
      throw _privateConstructorUsedError;

  /// Tool call results cache
  Map<String, dynamic> get toolCallResults =>
      throw _privateConstructorUsedError;

  /// Create a copy of MessageBlockState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageBlockStateCopyWith<MessageBlockState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageBlockStateCopyWith<$Res> {
  factory $MessageBlockStateCopyWith(
          MessageBlockState value, $Res Function(MessageBlockState) then) =
      _$MessageBlockStateCopyWithImpl<$Res, MessageBlockState>;
  @useResult
  $Res call(
      {Map<String, EnhancedMessageBlock> blocks,
      Map<String, List<String>> blocksByMessage,
      Map<EnhancedMessageBlockType, List<String>> blocksByType,
      MessageBlockLoadingState loadingState,
      String? error,
      Map<String, MessageBlockStatus> blockStatuses,
      Set<String> processingBlocks,
      Set<String> errorBlocks,
      int totalBlocks,
      DateTime? lastUpdateTime,
      Map<String, String> toolCallToBlockMap,
      Map<String, dynamic> toolCallResults});
}

/// @nodoc
class _$MessageBlockStateCopyWithImpl<$Res, $Val extends MessageBlockState>
    implements $MessageBlockStateCopyWith<$Res> {
  _$MessageBlockStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageBlockState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? blocks = null,
    Object? blocksByMessage = null,
    Object? blocksByType = null,
    Object? loadingState = null,
    Object? error = freezed,
    Object? blockStatuses = null,
    Object? processingBlocks = null,
    Object? errorBlocks = null,
    Object? totalBlocks = null,
    Object? lastUpdateTime = freezed,
    Object? toolCallToBlockMap = null,
    Object? toolCallResults = null,
  }) {
    return _then(_value.copyWith(
      blocks: null == blocks
          ? _value.blocks
          : blocks // ignore: cast_nullable_to_non_nullable
              as Map<String, EnhancedMessageBlock>,
      blocksByMessage: null == blocksByMessage
          ? _value.blocksByMessage
          : blocksByMessage // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
      blocksByType: null == blocksByType
          ? _value.blocksByType
          : blocksByType // ignore: cast_nullable_to_non_nullable
              as Map<EnhancedMessageBlockType, List<String>>,
      loadingState: null == loadingState
          ? _value.loadingState
          : loadingState // ignore: cast_nullable_to_non_nullable
              as MessageBlockLoadingState,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      blockStatuses: null == blockStatuses
          ? _value.blockStatuses
          : blockStatuses // ignore: cast_nullable_to_non_nullable
              as Map<String, MessageBlockStatus>,
      processingBlocks: null == processingBlocks
          ? _value.processingBlocks
          : processingBlocks // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      errorBlocks: null == errorBlocks
          ? _value.errorBlocks
          : errorBlocks // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      totalBlocks: null == totalBlocks
          ? _value.totalBlocks
          : totalBlocks // ignore: cast_nullable_to_non_nullable
              as int,
      lastUpdateTime: freezed == lastUpdateTime
          ? _value.lastUpdateTime
          : lastUpdateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      toolCallToBlockMap: null == toolCallToBlockMap
          ? _value.toolCallToBlockMap
          : toolCallToBlockMap // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      toolCallResults: null == toolCallResults
          ? _value.toolCallResults
          : toolCallResults // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageBlockStateImplCopyWith<$Res>
    implements $MessageBlockStateCopyWith<$Res> {
  factory _$$MessageBlockStateImplCopyWith(_$MessageBlockStateImpl value,
          $Res Function(_$MessageBlockStateImpl) then) =
      __$$MessageBlockStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<String, EnhancedMessageBlock> blocks,
      Map<String, List<String>> blocksByMessage,
      Map<EnhancedMessageBlockType, List<String>> blocksByType,
      MessageBlockLoadingState loadingState,
      String? error,
      Map<String, MessageBlockStatus> blockStatuses,
      Set<String> processingBlocks,
      Set<String> errorBlocks,
      int totalBlocks,
      DateTime? lastUpdateTime,
      Map<String, String> toolCallToBlockMap,
      Map<String, dynamic> toolCallResults});
}

/// @nodoc
class __$$MessageBlockStateImplCopyWithImpl<$Res>
    extends _$MessageBlockStateCopyWithImpl<$Res, _$MessageBlockStateImpl>
    implements _$$MessageBlockStateImplCopyWith<$Res> {
  __$$MessageBlockStateImplCopyWithImpl(_$MessageBlockStateImpl _value,
      $Res Function(_$MessageBlockStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageBlockState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? blocks = null,
    Object? blocksByMessage = null,
    Object? blocksByType = null,
    Object? loadingState = null,
    Object? error = freezed,
    Object? blockStatuses = null,
    Object? processingBlocks = null,
    Object? errorBlocks = null,
    Object? totalBlocks = null,
    Object? lastUpdateTime = freezed,
    Object? toolCallToBlockMap = null,
    Object? toolCallResults = null,
  }) {
    return _then(_$MessageBlockStateImpl(
      blocks: null == blocks
          ? _value._blocks
          : blocks // ignore: cast_nullable_to_non_nullable
              as Map<String, EnhancedMessageBlock>,
      blocksByMessage: null == blocksByMessage
          ? _value._blocksByMessage
          : blocksByMessage // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
      blocksByType: null == blocksByType
          ? _value._blocksByType
          : blocksByType // ignore: cast_nullable_to_non_nullable
              as Map<EnhancedMessageBlockType, List<String>>,
      loadingState: null == loadingState
          ? _value.loadingState
          : loadingState // ignore: cast_nullable_to_non_nullable
              as MessageBlockLoadingState,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      blockStatuses: null == blockStatuses
          ? _value._blockStatuses
          : blockStatuses // ignore: cast_nullable_to_non_nullable
              as Map<String, MessageBlockStatus>,
      processingBlocks: null == processingBlocks
          ? _value._processingBlocks
          : processingBlocks // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      errorBlocks: null == errorBlocks
          ? _value._errorBlocks
          : errorBlocks // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      totalBlocks: null == totalBlocks
          ? _value.totalBlocks
          : totalBlocks // ignore: cast_nullable_to_non_nullable
              as int,
      lastUpdateTime: freezed == lastUpdateTime
          ? _value.lastUpdateTime
          : lastUpdateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      toolCallToBlockMap: null == toolCallToBlockMap
          ? _value._toolCallToBlockMap
          : toolCallToBlockMap // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      toolCallResults: null == toolCallResults
          ? _value._toolCallResults
          : toolCallResults // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$MessageBlockStateImpl extends _MessageBlockState {
  const _$MessageBlockStateImpl(
      {final Map<String, EnhancedMessageBlock> blocks = const {},
      final Map<String, List<String>> blocksByMessage = const {},
      final Map<EnhancedMessageBlockType, List<String>> blocksByType = const {},
      this.loadingState = MessageBlockLoadingState.idle,
      this.error = null,
      final Map<String, MessageBlockStatus> blockStatuses = const {},
      final Set<String> processingBlocks = const {},
      final Set<String> errorBlocks = const {},
      this.totalBlocks = 0,
      this.lastUpdateTime = null,
      final Map<String, String> toolCallToBlockMap = const {},
      final Map<String, dynamic> toolCallResults = const {}})
      : _blocks = blocks,
        _blocksByMessage = blocksByMessage,
        _blocksByType = blocksByType,
        _blockStatuses = blockStatuses,
        _processingBlocks = processingBlocks,
        _errorBlocks = errorBlocks,
        _toolCallToBlockMap = toolCallToBlockMap,
        _toolCallResults = toolCallResults,
        super._();

// === Block Storage (EntityAdapter pattern) ===
  /// All blocks indexed by ID (blockId -> EnhancedMessageBlock)
  final Map<String, EnhancedMessageBlock> _blocks;
// === Block Storage (EntityAdapter pattern) ===
  /// All blocks indexed by ID (blockId -> EnhancedMessageBlock)
  @override
  @JsonKey()
  Map<String, EnhancedMessageBlock> get blocks {
    if (_blocks is EqualUnmodifiableMapView) return _blocks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_blocks);
  }

  /// Blocks grouped by message (messageId -> List<blockId>)
  /// Similar to Cherry Studio's message-to-blocks relationship
  final Map<String, List<String>> _blocksByMessage;

  /// Blocks grouped by message (messageId -> List<blockId>)
  /// Similar to Cherry Studio's message-to-blocks relationship
  @override
  @JsonKey()
  Map<String, List<String>> get blocksByMessage {
    if (_blocksByMessage is EqualUnmodifiableMapView) return _blocksByMessage;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_blocksByMessage);
  }

  /// Blocks grouped by type for efficient filtering
  final Map<EnhancedMessageBlockType, List<String>> _blocksByType;

  /// Blocks grouped by type for efficient filtering
  @override
  @JsonKey()
  Map<EnhancedMessageBlockType, List<String>> get blocksByType {
    if (_blocksByType is EqualUnmodifiableMapView) return _blocksByType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_blocksByType);
  }

// === Loading State ===
  /// Overall loading state
  @override
  @JsonKey()
  final MessageBlockLoadingState loadingState;

  /// Error message if loading failed
  @override
  @JsonKey()
  final String? error;
// === Block Status Tracking ===
  /// Status of individual blocks (blockId -> MessageBlockStatus)
  final Map<String, MessageBlockStatus> _blockStatuses;
// === Block Status Tracking ===
  /// Status of individual blocks (blockId -> MessageBlockStatus)
  @override
  @JsonKey()
  Map<String, MessageBlockStatus> get blockStatuses {
    if (_blockStatuses is EqualUnmodifiableMapView) return _blockStatuses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_blockStatuses);
  }

  /// Blocks currently being processed
  final Set<String> _processingBlocks;

  /// Blocks currently being processed
  @override
  @JsonKey()
  Set<String> get processingBlocks {
    if (_processingBlocks is EqualUnmodifiableSetView) return _processingBlocks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_processingBlocks);
  }

  /// Blocks with errors
  final Set<String> _errorBlocks;

  /// Blocks with errors
  @override
  @JsonKey()
  Set<String> get errorBlocks {
    if (_errorBlocks is EqualUnmodifiableSetView) return _errorBlocks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_errorBlocks);
  }

// === Performance Metrics ===
  /// Total number of blocks
  @override
  @JsonKey()
  final int totalBlocks;

  /// Last update timestamp
  @override
  @JsonKey()
  final DateTime? lastUpdateTime;
// === Tool Call Tracking ===
  /// Active tool calls (toolCallId -> blockId)
  /// Similar to Cherry Studio's toolCallIdToBlockIdMap
  final Map<String, String> _toolCallToBlockMap;
// === Tool Call Tracking ===
  /// Active tool calls (toolCallId -> blockId)
  /// Similar to Cherry Studio's toolCallIdToBlockIdMap
  @override
  @JsonKey()
  Map<String, String> get toolCallToBlockMap {
    if (_toolCallToBlockMap is EqualUnmodifiableMapView)
      return _toolCallToBlockMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_toolCallToBlockMap);
  }

  /// Tool call results cache
  final Map<String, dynamic> _toolCallResults;

  /// Tool call results cache
  @override
  @JsonKey()
  Map<String, dynamic> get toolCallResults {
    if (_toolCallResults is EqualUnmodifiableMapView) return _toolCallResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_toolCallResults);
  }

  @override
  String toString() {
    return 'MessageBlockState(blocks: $blocks, blocksByMessage: $blocksByMessage, blocksByType: $blocksByType, loadingState: $loadingState, error: $error, blockStatuses: $blockStatuses, processingBlocks: $processingBlocks, errorBlocks: $errorBlocks, totalBlocks: $totalBlocks, lastUpdateTime: $lastUpdateTime, toolCallToBlockMap: $toolCallToBlockMap, toolCallResults: $toolCallResults)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageBlockStateImpl &&
            const DeepCollectionEquality().equals(other._blocks, _blocks) &&
            const DeepCollectionEquality()
                .equals(other._blocksByMessage, _blocksByMessage) &&
            const DeepCollectionEquality()
                .equals(other._blocksByType, _blocksByType) &&
            (identical(other.loadingState, loadingState) ||
                other.loadingState == loadingState) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other._blockStatuses, _blockStatuses) &&
            const DeepCollectionEquality()
                .equals(other._processingBlocks, _processingBlocks) &&
            const DeepCollectionEquality()
                .equals(other._errorBlocks, _errorBlocks) &&
            (identical(other.totalBlocks, totalBlocks) ||
                other.totalBlocks == totalBlocks) &&
            (identical(other.lastUpdateTime, lastUpdateTime) ||
                other.lastUpdateTime == lastUpdateTime) &&
            const DeepCollectionEquality()
                .equals(other._toolCallToBlockMap, _toolCallToBlockMap) &&
            const DeepCollectionEquality()
                .equals(other._toolCallResults, _toolCallResults));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_blocks),
      const DeepCollectionEquality().hash(_blocksByMessage),
      const DeepCollectionEquality().hash(_blocksByType),
      loadingState,
      error,
      const DeepCollectionEquality().hash(_blockStatuses),
      const DeepCollectionEquality().hash(_processingBlocks),
      const DeepCollectionEquality().hash(_errorBlocks),
      totalBlocks,
      lastUpdateTime,
      const DeepCollectionEquality().hash(_toolCallToBlockMap),
      const DeepCollectionEquality().hash(_toolCallResults));

  /// Create a copy of MessageBlockState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageBlockStateImplCopyWith<_$MessageBlockStateImpl> get copyWith =>
      __$$MessageBlockStateImplCopyWithImpl<_$MessageBlockStateImpl>(
          this, _$identity);
}

abstract class _MessageBlockState extends MessageBlockState {
  const factory _MessageBlockState(
      {final Map<String, EnhancedMessageBlock> blocks,
      final Map<String, List<String>> blocksByMessage,
      final Map<EnhancedMessageBlockType, List<String>> blocksByType,
      final MessageBlockLoadingState loadingState,
      final String? error,
      final Map<String, MessageBlockStatus> blockStatuses,
      final Set<String> processingBlocks,
      final Set<String> errorBlocks,
      final int totalBlocks,
      final DateTime? lastUpdateTime,
      final Map<String, String> toolCallToBlockMap,
      final Map<String, dynamic> toolCallResults}) = _$MessageBlockStateImpl;
  const _MessageBlockState._() : super._();

// === Block Storage (EntityAdapter pattern) ===
  /// All blocks indexed by ID (blockId -> EnhancedMessageBlock)
  @override
  Map<String, EnhancedMessageBlock> get blocks;

  /// Blocks grouped by message (messageId -> List<blockId>)
  /// Similar to Cherry Studio's message-to-blocks relationship
  @override
  Map<String, List<String>> get blocksByMessage;

  /// Blocks grouped by type for efficient filtering
  @override
  Map<EnhancedMessageBlockType, List<String>>
      get blocksByType; // === Loading State ===
  /// Overall loading state
  @override
  MessageBlockLoadingState get loadingState;

  /// Error message if loading failed
  @override
  String? get error; // === Block Status Tracking ===
  /// Status of individual blocks (blockId -> MessageBlockStatus)
  @override
  Map<String, MessageBlockStatus> get blockStatuses;

  /// Blocks currently being processed
  @override
  Set<String> get processingBlocks;

  /// Blocks with errors
  @override
  Set<String> get errorBlocks; // === Performance Metrics ===
  /// Total number of blocks
  @override
  int get totalBlocks;

  /// Last update timestamp
  @override
  DateTime? get lastUpdateTime; // === Tool Call Tracking ===
  /// Active tool calls (toolCallId -> blockId)
  /// Similar to Cherry Studio's toolCallIdToBlockIdMap
  @override
  Map<String, String> get toolCallToBlockMap;

  /// Tool call results cache
  @override
  Map<String, dynamic> get toolCallResults;

  /// Create a copy of MessageBlockState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageBlockStateImplCopyWith<_$MessageBlockStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
