// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_status_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChatStatusSummary {
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isReady => throw _privateConstructorUsedError;
  bool get hasStreamingMessages => throw _privateConstructorUsedError;
  int get totalMessages => throw _privateConstructorUsedError;
  int get pendingMessages => throw _privateConstructorUsedError;
  int get errorMessages => throw _privateConstructorUsedError;
  List<ChatError> get errors => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;
  List<String> get warnings => throw _privateConstructorUsedError;
  bool get isConnected => throw _privateConstructorUsedError;
  int get activeConnections => throw _privateConstructorUsedError;
  ChatPerformanceMetrics? get performance => throw _privateConstructorUsedError;

  /// Create a copy of ChatStatusSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatStatusSummaryCopyWith<ChatStatusSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatStatusSummaryCopyWith<$Res> {
  factory $ChatStatusSummaryCopyWith(
          ChatStatusSummary value, $Res Function(ChatStatusSummary) then) =
      _$ChatStatusSummaryCopyWithImpl<$Res, ChatStatusSummary>;
  @useResult
  $Res call(
      {bool isLoading,
      bool isReady,
      bool hasStreamingMessages,
      int totalMessages,
      int pendingMessages,
      int errorMessages,
      List<ChatError> errors,
      DateTime lastUpdated,
      List<String> warnings,
      bool isConnected,
      int activeConnections,
      ChatPerformanceMetrics? performance});

  $ChatPerformanceMetricsCopyWith<$Res>? get performance;
}

/// @nodoc
class _$ChatStatusSummaryCopyWithImpl<$Res, $Val extends ChatStatusSummary>
    implements $ChatStatusSummaryCopyWith<$Res> {
  _$ChatStatusSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatStatusSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isReady = null,
    Object? hasStreamingMessages = null,
    Object? totalMessages = null,
    Object? pendingMessages = null,
    Object? errorMessages = null,
    Object? errors = null,
    Object? lastUpdated = null,
    Object? warnings = null,
    Object? isConnected = null,
    Object? activeConnections = null,
    Object? performance = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isReady: null == isReady
          ? _value.isReady
          : isReady // ignore: cast_nullable_to_non_nullable
              as bool,
      hasStreamingMessages: null == hasStreamingMessages
          ? _value.hasStreamingMessages
          : hasStreamingMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      totalMessages: null == totalMessages
          ? _value.totalMessages
          : totalMessages // ignore: cast_nullable_to_non_nullable
              as int,
      pendingMessages: null == pendingMessages
          ? _value.pendingMessages
          : pendingMessages // ignore: cast_nullable_to_non_nullable
              as int,
      errorMessages: null == errorMessages
          ? _value.errorMessages
          : errorMessages // ignore: cast_nullable_to_non_nullable
              as int,
      errors: null == errors
          ? _value.errors
          : errors // ignore: cast_nullable_to_non_nullable
              as List<ChatError>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      warnings: null == warnings
          ? _value.warnings
          : warnings // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isConnected: null == isConnected
          ? _value.isConnected
          : isConnected // ignore: cast_nullable_to_non_nullable
              as bool,
      activeConnections: null == activeConnections
          ? _value.activeConnections
          : activeConnections // ignore: cast_nullable_to_non_nullable
              as int,
      performance: freezed == performance
          ? _value.performance
          : performance // ignore: cast_nullable_to_non_nullable
              as ChatPerformanceMetrics?,
    ) as $Val);
  }

  /// Create a copy of ChatStatusSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChatPerformanceMetricsCopyWith<$Res>? get performance {
    if (_value.performance == null) {
      return null;
    }

    return $ChatPerformanceMetricsCopyWith<$Res>(_value.performance!, (value) {
      return _then(_value.copyWith(performance: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatStatusSummaryImplCopyWith<$Res>
    implements $ChatStatusSummaryCopyWith<$Res> {
  factory _$$ChatStatusSummaryImplCopyWith(_$ChatStatusSummaryImpl value,
          $Res Function(_$ChatStatusSummaryImpl) then) =
      __$$ChatStatusSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isReady,
      bool hasStreamingMessages,
      int totalMessages,
      int pendingMessages,
      int errorMessages,
      List<ChatError> errors,
      DateTime lastUpdated,
      List<String> warnings,
      bool isConnected,
      int activeConnections,
      ChatPerformanceMetrics? performance});

  @override
  $ChatPerformanceMetricsCopyWith<$Res>? get performance;
}

/// @nodoc
class __$$ChatStatusSummaryImplCopyWithImpl<$Res>
    extends _$ChatStatusSummaryCopyWithImpl<$Res, _$ChatStatusSummaryImpl>
    implements _$$ChatStatusSummaryImplCopyWith<$Res> {
  __$$ChatStatusSummaryImplCopyWithImpl(_$ChatStatusSummaryImpl _value,
      $Res Function(_$ChatStatusSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatStatusSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isReady = null,
    Object? hasStreamingMessages = null,
    Object? totalMessages = null,
    Object? pendingMessages = null,
    Object? errorMessages = null,
    Object? errors = null,
    Object? lastUpdated = null,
    Object? warnings = null,
    Object? isConnected = null,
    Object? activeConnections = null,
    Object? performance = freezed,
  }) {
    return _then(_$ChatStatusSummaryImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isReady: null == isReady
          ? _value.isReady
          : isReady // ignore: cast_nullable_to_non_nullable
              as bool,
      hasStreamingMessages: null == hasStreamingMessages
          ? _value.hasStreamingMessages
          : hasStreamingMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      totalMessages: null == totalMessages
          ? _value.totalMessages
          : totalMessages // ignore: cast_nullable_to_non_nullable
              as int,
      pendingMessages: null == pendingMessages
          ? _value.pendingMessages
          : pendingMessages // ignore: cast_nullable_to_non_nullable
              as int,
      errorMessages: null == errorMessages
          ? _value.errorMessages
          : errorMessages // ignore: cast_nullable_to_non_nullable
              as int,
      errors: null == errors
          ? _value._errors
          : errors // ignore: cast_nullable_to_non_nullable
              as List<ChatError>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      warnings: null == warnings
          ? _value._warnings
          : warnings // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isConnected: null == isConnected
          ? _value.isConnected
          : isConnected // ignore: cast_nullable_to_non_nullable
              as bool,
      activeConnections: null == activeConnections
          ? _value.activeConnections
          : activeConnections // ignore: cast_nullable_to_non_nullable
              as int,
      performance: freezed == performance
          ? _value.performance
          : performance // ignore: cast_nullable_to_non_nullable
              as ChatPerformanceMetrics?,
    ));
  }
}

/// @nodoc

class _$ChatStatusSummaryImpl extends _ChatStatusSummary {
  const _$ChatStatusSummaryImpl(
      {required this.isLoading,
      required this.isReady,
      required this.hasStreamingMessages,
      required this.totalMessages,
      required this.pendingMessages,
      required this.errorMessages,
      required final List<ChatError> errors,
      required this.lastUpdated,
      final List<String> warnings = const [],
      this.isConnected = false,
      this.activeConnections = 0,
      this.performance})
      : _errors = errors,
        _warnings = warnings,
        super._();

  @override
  final bool isLoading;
  @override
  final bool isReady;
  @override
  final bool hasStreamingMessages;
  @override
  final int totalMessages;
  @override
  final int pendingMessages;
  @override
  final int errorMessages;
  final List<ChatError> _errors;
  @override
  List<ChatError> get errors {
    if (_errors is EqualUnmodifiableListView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_errors);
  }

  @override
  final DateTime lastUpdated;
  final List<String> _warnings;
  @override
  @JsonKey()
  List<String> get warnings {
    if (_warnings is EqualUnmodifiableListView) return _warnings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_warnings);
  }

  @override
  @JsonKey()
  final bool isConnected;
  @override
  @JsonKey()
  final int activeConnections;
  @override
  final ChatPerformanceMetrics? performance;

  @override
  String toString() {
    return 'ChatStatusSummary(isLoading: $isLoading, isReady: $isReady, hasStreamingMessages: $hasStreamingMessages, totalMessages: $totalMessages, pendingMessages: $pendingMessages, errorMessages: $errorMessages, errors: $errors, lastUpdated: $lastUpdated, warnings: $warnings, isConnected: $isConnected, activeConnections: $activeConnections, performance: $performance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatStatusSummaryImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isReady, isReady) || other.isReady == isReady) &&
            (identical(other.hasStreamingMessages, hasStreamingMessages) ||
                other.hasStreamingMessages == hasStreamingMessages) &&
            (identical(other.totalMessages, totalMessages) ||
                other.totalMessages == totalMessages) &&
            (identical(other.pendingMessages, pendingMessages) ||
                other.pendingMessages == pendingMessages) &&
            (identical(other.errorMessages, errorMessages) ||
                other.errorMessages == errorMessages) &&
            const DeepCollectionEquality().equals(other._errors, _errors) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            const DeepCollectionEquality().equals(other._warnings, _warnings) &&
            (identical(other.isConnected, isConnected) ||
                other.isConnected == isConnected) &&
            (identical(other.activeConnections, activeConnections) ||
                other.activeConnections == activeConnections) &&
            (identical(other.performance, performance) ||
                other.performance == performance));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      isReady,
      hasStreamingMessages,
      totalMessages,
      pendingMessages,
      errorMessages,
      const DeepCollectionEquality().hash(_errors),
      lastUpdated,
      const DeepCollectionEquality().hash(_warnings),
      isConnected,
      activeConnections,
      performance);

  /// Create a copy of ChatStatusSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatStatusSummaryImplCopyWith<_$ChatStatusSummaryImpl> get copyWith =>
      __$$ChatStatusSummaryImplCopyWithImpl<_$ChatStatusSummaryImpl>(
          this, _$identity);
}

abstract class _ChatStatusSummary extends ChatStatusSummary {
  const factory _ChatStatusSummary(
      {required final bool isLoading,
      required final bool isReady,
      required final bool hasStreamingMessages,
      required final int totalMessages,
      required final int pendingMessages,
      required final int errorMessages,
      required final List<ChatError> errors,
      required final DateTime lastUpdated,
      final List<String> warnings,
      final bool isConnected,
      final int activeConnections,
      final ChatPerformanceMetrics? performance}) = _$ChatStatusSummaryImpl;
  const _ChatStatusSummary._() : super._();

  @override
  bool get isLoading;
  @override
  bool get isReady;
  @override
  bool get hasStreamingMessages;
  @override
  int get totalMessages;
  @override
  int get pendingMessages;
  @override
  int get errorMessages;
  @override
  List<ChatError> get errors;
  @override
  DateTime get lastUpdated;
  @override
  List<String> get warnings;
  @override
  bool get isConnected;
  @override
  int get activeConnections;
  @override
  ChatPerformanceMetrics? get performance;

  /// Create a copy of ChatStatusSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatStatusSummaryImplCopyWith<_$ChatStatusSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ChatError {
  String get id => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  ChatErrorType get type => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get code => throw _privateConstructorUsedError;
  String? get conversationId => throw _privateConstructorUsedError;
  String? get messageId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get details => throw _privateConstructorUsedError;

  /// Create a copy of ChatError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatErrorCopyWith<ChatError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatErrorCopyWith<$Res> {
  factory $ChatErrorCopyWith(ChatError value, $Res Function(ChatError) then) =
      _$ChatErrorCopyWithImpl<$Res, ChatError>;
  @useResult
  $Res call(
      {String id,
      String message,
      ChatErrorType type,
      DateTime timestamp,
      String? code,
      String? conversationId,
      String? messageId,
      Map<String, dynamic>? details});
}

/// @nodoc
class _$ChatErrorCopyWithImpl<$Res, $Val extends ChatError>
    implements $ChatErrorCopyWith<$Res> {
  _$ChatErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? message = null,
    Object? type = null,
    Object? timestamp = null,
    Object? code = freezed,
    Object? conversationId = freezed,
    Object? messageId = freezed,
    Object? details = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ChatErrorType,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      conversationId: freezed == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String?,
      messageId: freezed == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String?,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatErrorImplCopyWith<$Res>
    implements $ChatErrorCopyWith<$Res> {
  factory _$$ChatErrorImplCopyWith(
          _$ChatErrorImpl value, $Res Function(_$ChatErrorImpl) then) =
      __$$ChatErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String message,
      ChatErrorType type,
      DateTime timestamp,
      String? code,
      String? conversationId,
      String? messageId,
      Map<String, dynamic>? details});
}

/// @nodoc
class __$$ChatErrorImplCopyWithImpl<$Res>
    extends _$ChatErrorCopyWithImpl<$Res, _$ChatErrorImpl>
    implements _$$ChatErrorImplCopyWith<$Res> {
  __$$ChatErrorImplCopyWithImpl(
      _$ChatErrorImpl _value, $Res Function(_$ChatErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? message = null,
    Object? type = null,
    Object? timestamp = null,
    Object? code = freezed,
    Object? conversationId = freezed,
    Object? messageId = freezed,
    Object? details = freezed,
  }) {
    return _then(_$ChatErrorImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ChatErrorType,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      conversationId: freezed == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String?,
      messageId: freezed == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String?,
      details: freezed == details
          ? _value._details
          : details // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$ChatErrorImpl extends _ChatError {
  const _$ChatErrorImpl(
      {required this.id,
      required this.message,
      required this.type,
      required this.timestamp,
      this.code,
      this.conversationId,
      this.messageId,
      final Map<String, dynamic>? details})
      : _details = details,
        super._();

  @override
  final String id;
  @override
  final String message;
  @override
  final ChatErrorType type;
  @override
  final DateTime timestamp;
  @override
  final String? code;
  @override
  final String? conversationId;
  @override
  final String? messageId;
  final Map<String, dynamic>? _details;
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ChatError(id: $id, message: $message, type: $type, timestamp: $timestamp, code: $code, conversationId: $conversationId, messageId: $messageId, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatErrorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      message,
      type,
      timestamp,
      code,
      conversationId,
      messageId,
      const DeepCollectionEquality().hash(_details));

  /// Create a copy of ChatError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatErrorImplCopyWith<_$ChatErrorImpl> get copyWith =>
      __$$ChatErrorImplCopyWithImpl<_$ChatErrorImpl>(this, _$identity);
}

abstract class _ChatError extends ChatError {
  const factory _ChatError(
      {required final String id,
      required final String message,
      required final ChatErrorType type,
      required final DateTime timestamp,
      final String? code,
      final String? conversationId,
      final String? messageId,
      final Map<String, dynamic>? details}) = _$ChatErrorImpl;
  const _ChatError._() : super._();

  @override
  String get id;
  @override
  String get message;
  @override
  ChatErrorType get type;
  @override
  DateTime get timestamp;
  @override
  String? get code;
  @override
  String? get conversationId;
  @override
  String? get messageId;
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of ChatError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatErrorImplCopyWith<_$ChatErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ChatPerformanceMetrics {
  double get averageResponseTime => throw _privateConstructorUsedError;
  double get lastResponseTime => throw _privateConstructorUsedError;
  int get totalRequests => throw _privateConstructorUsedError;
  int get successfulRequests => throw _privateConstructorUsedError;
  int get failedRequests => throw _privateConstructorUsedError;
  DateTime get lastMeasurement => throw _privateConstructorUsedError;

  /// Create a copy of ChatPerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatPerformanceMetricsCopyWith<ChatPerformanceMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatPerformanceMetricsCopyWith<$Res> {
  factory $ChatPerformanceMetricsCopyWith(ChatPerformanceMetrics value,
          $Res Function(ChatPerformanceMetrics) then) =
      _$ChatPerformanceMetricsCopyWithImpl<$Res, ChatPerformanceMetrics>;
  @useResult
  $Res call(
      {double averageResponseTime,
      double lastResponseTime,
      int totalRequests,
      int successfulRequests,
      int failedRequests,
      DateTime lastMeasurement});
}

/// @nodoc
class _$ChatPerformanceMetricsCopyWithImpl<$Res,
        $Val extends ChatPerformanceMetrics>
    implements $ChatPerformanceMetricsCopyWith<$Res> {
  _$ChatPerformanceMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatPerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? averageResponseTime = null,
    Object? lastResponseTime = null,
    Object? totalRequests = null,
    Object? successfulRequests = null,
    Object? failedRequests = null,
    Object? lastMeasurement = null,
  }) {
    return _then(_value.copyWith(
      averageResponseTime: null == averageResponseTime
          ? _value.averageResponseTime
          : averageResponseTime // ignore: cast_nullable_to_non_nullable
              as double,
      lastResponseTime: null == lastResponseTime
          ? _value.lastResponseTime
          : lastResponseTime // ignore: cast_nullable_to_non_nullable
              as double,
      totalRequests: null == totalRequests
          ? _value.totalRequests
          : totalRequests // ignore: cast_nullable_to_non_nullable
              as int,
      successfulRequests: null == successfulRequests
          ? _value.successfulRequests
          : successfulRequests // ignore: cast_nullable_to_non_nullable
              as int,
      failedRequests: null == failedRequests
          ? _value.failedRequests
          : failedRequests // ignore: cast_nullable_to_non_nullable
              as int,
      lastMeasurement: null == lastMeasurement
          ? _value.lastMeasurement
          : lastMeasurement // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatPerformanceMetricsImplCopyWith<$Res>
    implements $ChatPerformanceMetricsCopyWith<$Res> {
  factory _$$ChatPerformanceMetricsImplCopyWith(
          _$ChatPerformanceMetricsImpl value,
          $Res Function(_$ChatPerformanceMetricsImpl) then) =
      __$$ChatPerformanceMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double averageResponseTime,
      double lastResponseTime,
      int totalRequests,
      int successfulRequests,
      int failedRequests,
      DateTime lastMeasurement});
}

/// @nodoc
class __$$ChatPerformanceMetricsImplCopyWithImpl<$Res>
    extends _$ChatPerformanceMetricsCopyWithImpl<$Res,
        _$ChatPerformanceMetricsImpl>
    implements _$$ChatPerformanceMetricsImplCopyWith<$Res> {
  __$$ChatPerformanceMetricsImplCopyWithImpl(
      _$ChatPerformanceMetricsImpl _value,
      $Res Function(_$ChatPerformanceMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatPerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? averageResponseTime = null,
    Object? lastResponseTime = null,
    Object? totalRequests = null,
    Object? successfulRequests = null,
    Object? failedRequests = null,
    Object? lastMeasurement = null,
  }) {
    return _then(_$ChatPerformanceMetricsImpl(
      averageResponseTime: null == averageResponseTime
          ? _value.averageResponseTime
          : averageResponseTime // ignore: cast_nullable_to_non_nullable
              as double,
      lastResponseTime: null == lastResponseTime
          ? _value.lastResponseTime
          : lastResponseTime // ignore: cast_nullable_to_non_nullable
              as double,
      totalRequests: null == totalRequests
          ? _value.totalRequests
          : totalRequests // ignore: cast_nullable_to_non_nullable
              as int,
      successfulRequests: null == successfulRequests
          ? _value.successfulRequests
          : successfulRequests // ignore: cast_nullable_to_non_nullable
              as int,
      failedRequests: null == failedRequests
          ? _value.failedRequests
          : failedRequests // ignore: cast_nullable_to_non_nullable
              as int,
      lastMeasurement: null == lastMeasurement
          ? _value.lastMeasurement
          : lastMeasurement // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$ChatPerformanceMetricsImpl extends _ChatPerformanceMetrics {
  const _$ChatPerformanceMetricsImpl(
      {required this.averageResponseTime,
      required this.lastResponseTime,
      required this.totalRequests,
      required this.successfulRequests,
      required this.failedRequests,
      required this.lastMeasurement})
      : super._();

  @override
  final double averageResponseTime;
  @override
  final double lastResponseTime;
  @override
  final int totalRequests;
  @override
  final int successfulRequests;
  @override
  final int failedRequests;
  @override
  final DateTime lastMeasurement;

  @override
  String toString() {
    return 'ChatPerformanceMetrics(averageResponseTime: $averageResponseTime, lastResponseTime: $lastResponseTime, totalRequests: $totalRequests, successfulRequests: $successfulRequests, failedRequests: $failedRequests, lastMeasurement: $lastMeasurement)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatPerformanceMetricsImpl &&
            (identical(other.averageResponseTime, averageResponseTime) ||
                other.averageResponseTime == averageResponseTime) &&
            (identical(other.lastResponseTime, lastResponseTime) ||
                other.lastResponseTime == lastResponseTime) &&
            (identical(other.totalRequests, totalRequests) ||
                other.totalRequests == totalRequests) &&
            (identical(other.successfulRequests, successfulRequests) ||
                other.successfulRequests == successfulRequests) &&
            (identical(other.failedRequests, failedRequests) ||
                other.failedRequests == failedRequests) &&
            (identical(other.lastMeasurement, lastMeasurement) ||
                other.lastMeasurement == lastMeasurement));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      averageResponseTime,
      lastResponseTime,
      totalRequests,
      successfulRequests,
      failedRequests,
      lastMeasurement);

  /// Create a copy of ChatPerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatPerformanceMetricsImplCopyWith<_$ChatPerformanceMetricsImpl>
      get copyWith => __$$ChatPerformanceMetricsImplCopyWithImpl<
          _$ChatPerformanceMetricsImpl>(this, _$identity);
}

abstract class _ChatPerformanceMetrics extends ChatPerformanceMetrics {
  const factory _ChatPerformanceMetrics(
      {required final double averageResponseTime,
      required final double lastResponseTime,
      required final int totalRequests,
      required final int successfulRequests,
      required final int failedRequests,
      required final DateTime lastMeasurement}) = _$ChatPerformanceMetricsImpl;
  const _ChatPerformanceMetrics._() : super._();

  @override
  double get averageResponseTime;
  @override
  double get lastResponseTime;
  @override
  int get totalRequests;
  @override
  int get successfulRequests;
  @override
  int get failedRequests;
  @override
  DateTime get lastMeasurement;

  /// Create a copy of ChatPerformanceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatPerformanceMetricsImplCopyWith<_$ChatPerformanceMetricsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
