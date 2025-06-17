// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mcp_server_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$McpServerState {
  String get serverId => throw _privateConstructorUsedError;
  String get serverName => throw _privateConstructorUsedError;
  McpConnectionStatus get status => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;
  List<McpTool> get tools => throw _privateConstructorUsedError;
  List<McpError> get errors => throw _privateConstructorUsedError;
  List<String> get warnings => throw _privateConstructorUsedError;
  bool get isConnecting => throw _privateConstructorUsedError;
  bool get isReconnecting => throw _privateConstructorUsedError;
  int get reconnectAttempts => throw _privateConstructorUsedError;
  int get maxReconnectAttempts => throw _privateConstructorUsedError;
  McpServerCapabilities? get capabilities => throw _privateConstructorUsedError;
  McpServerMetrics? get metrics => throw _privateConstructorUsedError;
  Map<String, dynamic>? get configuration => throw _privateConstructorUsedError;

  /// Create a copy of McpServerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $McpServerStateCopyWith<McpServerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $McpServerStateCopyWith<$Res> {
  factory $McpServerStateCopyWith(
          McpServerState value, $Res Function(McpServerState) then) =
      _$McpServerStateCopyWithImpl<$Res, McpServerState>;
  @useResult
  $Res call(
      {String serverId,
      String serverName,
      McpConnectionStatus status,
      DateTime lastUpdated,
      List<McpTool> tools,
      List<McpError> errors,
      List<String> warnings,
      bool isConnecting,
      bool isReconnecting,
      int reconnectAttempts,
      int maxReconnectAttempts,
      McpServerCapabilities? capabilities,
      McpServerMetrics? metrics,
      Map<String, dynamic>? configuration});

  $McpServerCapabilitiesCopyWith<$Res>? get capabilities;
  $McpServerMetricsCopyWith<$Res>? get metrics;
}

/// @nodoc
class _$McpServerStateCopyWithImpl<$Res, $Val extends McpServerState>
    implements $McpServerStateCopyWith<$Res> {
  _$McpServerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of McpServerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serverId = null,
    Object? serverName = null,
    Object? status = null,
    Object? lastUpdated = null,
    Object? tools = null,
    Object? errors = null,
    Object? warnings = null,
    Object? isConnecting = null,
    Object? isReconnecting = null,
    Object? reconnectAttempts = null,
    Object? maxReconnectAttempts = null,
    Object? capabilities = freezed,
    Object? metrics = freezed,
    Object? configuration = freezed,
  }) {
    return _then(_value.copyWith(
      serverId: null == serverId
          ? _value.serverId
          : serverId // ignore: cast_nullable_to_non_nullable
              as String,
      serverName: null == serverName
          ? _value.serverName
          : serverName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as McpConnectionStatus,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tools: null == tools
          ? _value.tools
          : tools // ignore: cast_nullable_to_non_nullable
              as List<McpTool>,
      errors: null == errors
          ? _value.errors
          : errors // ignore: cast_nullable_to_non_nullable
              as List<McpError>,
      warnings: null == warnings
          ? _value.warnings
          : warnings // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isConnecting: null == isConnecting
          ? _value.isConnecting
          : isConnecting // ignore: cast_nullable_to_non_nullable
              as bool,
      isReconnecting: null == isReconnecting
          ? _value.isReconnecting
          : isReconnecting // ignore: cast_nullable_to_non_nullable
              as bool,
      reconnectAttempts: null == reconnectAttempts
          ? _value.reconnectAttempts
          : reconnectAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      maxReconnectAttempts: null == maxReconnectAttempts
          ? _value.maxReconnectAttempts
          : maxReconnectAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      capabilities: freezed == capabilities
          ? _value.capabilities
          : capabilities // ignore: cast_nullable_to_non_nullable
              as McpServerCapabilities?,
      metrics: freezed == metrics
          ? _value.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as McpServerMetrics?,
      configuration: freezed == configuration
          ? _value.configuration
          : configuration // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }

  /// Create a copy of McpServerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $McpServerCapabilitiesCopyWith<$Res>? get capabilities {
    if (_value.capabilities == null) {
      return null;
    }

    return $McpServerCapabilitiesCopyWith<$Res>(_value.capabilities!, (value) {
      return _then(_value.copyWith(capabilities: value) as $Val);
    });
  }

  /// Create a copy of McpServerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $McpServerMetricsCopyWith<$Res>? get metrics {
    if (_value.metrics == null) {
      return null;
    }

    return $McpServerMetricsCopyWith<$Res>(_value.metrics!, (value) {
      return _then(_value.copyWith(metrics: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$McpServerStateImplCopyWith<$Res>
    implements $McpServerStateCopyWith<$Res> {
  factory _$$McpServerStateImplCopyWith(_$McpServerStateImpl value,
          $Res Function(_$McpServerStateImpl) then) =
      __$$McpServerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String serverId,
      String serverName,
      McpConnectionStatus status,
      DateTime lastUpdated,
      List<McpTool> tools,
      List<McpError> errors,
      List<String> warnings,
      bool isConnecting,
      bool isReconnecting,
      int reconnectAttempts,
      int maxReconnectAttempts,
      McpServerCapabilities? capabilities,
      McpServerMetrics? metrics,
      Map<String, dynamic>? configuration});

  @override
  $McpServerCapabilitiesCopyWith<$Res>? get capabilities;
  @override
  $McpServerMetricsCopyWith<$Res>? get metrics;
}

/// @nodoc
class __$$McpServerStateImplCopyWithImpl<$Res>
    extends _$McpServerStateCopyWithImpl<$Res, _$McpServerStateImpl>
    implements _$$McpServerStateImplCopyWith<$Res> {
  __$$McpServerStateImplCopyWithImpl(
      _$McpServerStateImpl _value, $Res Function(_$McpServerStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of McpServerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serverId = null,
    Object? serverName = null,
    Object? status = null,
    Object? lastUpdated = null,
    Object? tools = null,
    Object? errors = null,
    Object? warnings = null,
    Object? isConnecting = null,
    Object? isReconnecting = null,
    Object? reconnectAttempts = null,
    Object? maxReconnectAttempts = null,
    Object? capabilities = freezed,
    Object? metrics = freezed,
    Object? configuration = freezed,
  }) {
    return _then(_$McpServerStateImpl(
      serverId: null == serverId
          ? _value.serverId
          : serverId // ignore: cast_nullable_to_non_nullable
              as String,
      serverName: null == serverName
          ? _value.serverName
          : serverName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as McpConnectionStatus,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tools: null == tools
          ? _value._tools
          : tools // ignore: cast_nullable_to_non_nullable
              as List<McpTool>,
      errors: null == errors
          ? _value._errors
          : errors // ignore: cast_nullable_to_non_nullable
              as List<McpError>,
      warnings: null == warnings
          ? _value._warnings
          : warnings // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isConnecting: null == isConnecting
          ? _value.isConnecting
          : isConnecting // ignore: cast_nullable_to_non_nullable
              as bool,
      isReconnecting: null == isReconnecting
          ? _value.isReconnecting
          : isReconnecting // ignore: cast_nullable_to_non_nullable
              as bool,
      reconnectAttempts: null == reconnectAttempts
          ? _value.reconnectAttempts
          : reconnectAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      maxReconnectAttempts: null == maxReconnectAttempts
          ? _value.maxReconnectAttempts
          : maxReconnectAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      capabilities: freezed == capabilities
          ? _value.capabilities
          : capabilities // ignore: cast_nullable_to_non_nullable
              as McpServerCapabilities?,
      metrics: freezed == metrics
          ? _value.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as McpServerMetrics?,
      configuration: freezed == configuration
          ? _value._configuration
          : configuration // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$McpServerStateImpl extends _McpServerState {
  const _$McpServerStateImpl(
      {required this.serverId,
      required this.serverName,
      required this.status,
      required this.lastUpdated,
      required final List<McpTool> tools,
      required final List<McpError> errors,
      final List<String> warnings = const [],
      this.isConnecting = false,
      this.isReconnecting = false,
      this.reconnectAttempts = 0,
      this.maxReconnectAttempts = 5,
      this.capabilities,
      this.metrics,
      final Map<String, dynamic>? configuration})
      : _tools = tools,
        _errors = errors,
        _warnings = warnings,
        _configuration = configuration,
        super._();

  @override
  final String serverId;
  @override
  final String serverName;
  @override
  final McpConnectionStatus status;
  @override
  final DateTime lastUpdated;
  final List<McpTool> _tools;
  @override
  List<McpTool> get tools {
    if (_tools is EqualUnmodifiableListView) return _tools;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tools);
  }

  final List<McpError> _errors;
  @override
  List<McpError> get errors {
    if (_errors is EqualUnmodifiableListView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_errors);
  }

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
  final bool isConnecting;
  @override
  @JsonKey()
  final bool isReconnecting;
  @override
  @JsonKey()
  final int reconnectAttempts;
  @override
  @JsonKey()
  final int maxReconnectAttempts;
  @override
  final McpServerCapabilities? capabilities;
  @override
  final McpServerMetrics? metrics;
  final Map<String, dynamic>? _configuration;
  @override
  Map<String, dynamic>? get configuration {
    final value = _configuration;
    if (value == null) return null;
    if (_configuration is EqualUnmodifiableMapView) return _configuration;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'McpServerState(serverId: $serverId, serverName: $serverName, status: $status, lastUpdated: $lastUpdated, tools: $tools, errors: $errors, warnings: $warnings, isConnecting: $isConnecting, isReconnecting: $isReconnecting, reconnectAttempts: $reconnectAttempts, maxReconnectAttempts: $maxReconnectAttempts, capabilities: $capabilities, metrics: $metrics, configuration: $configuration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$McpServerStateImpl &&
            (identical(other.serverId, serverId) ||
                other.serverId == serverId) &&
            (identical(other.serverName, serverName) ||
                other.serverName == serverName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            const DeepCollectionEquality().equals(other._tools, _tools) &&
            const DeepCollectionEquality().equals(other._errors, _errors) &&
            const DeepCollectionEquality().equals(other._warnings, _warnings) &&
            (identical(other.isConnecting, isConnecting) ||
                other.isConnecting == isConnecting) &&
            (identical(other.isReconnecting, isReconnecting) ||
                other.isReconnecting == isReconnecting) &&
            (identical(other.reconnectAttempts, reconnectAttempts) ||
                other.reconnectAttempts == reconnectAttempts) &&
            (identical(other.maxReconnectAttempts, maxReconnectAttempts) ||
                other.maxReconnectAttempts == maxReconnectAttempts) &&
            (identical(other.capabilities, capabilities) ||
                other.capabilities == capabilities) &&
            (identical(other.metrics, metrics) || other.metrics == metrics) &&
            const DeepCollectionEquality()
                .equals(other._configuration, _configuration));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      serverId,
      serverName,
      status,
      lastUpdated,
      const DeepCollectionEquality().hash(_tools),
      const DeepCollectionEquality().hash(_errors),
      const DeepCollectionEquality().hash(_warnings),
      isConnecting,
      isReconnecting,
      reconnectAttempts,
      maxReconnectAttempts,
      capabilities,
      metrics,
      const DeepCollectionEquality().hash(_configuration));

  /// Create a copy of McpServerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$McpServerStateImplCopyWith<_$McpServerStateImpl> get copyWith =>
      __$$McpServerStateImplCopyWithImpl<_$McpServerStateImpl>(
          this, _$identity);
}

abstract class _McpServerState extends McpServerState {
  const factory _McpServerState(
      {required final String serverId,
      required final String serverName,
      required final McpConnectionStatus status,
      required final DateTime lastUpdated,
      required final List<McpTool> tools,
      required final List<McpError> errors,
      final List<String> warnings,
      final bool isConnecting,
      final bool isReconnecting,
      final int reconnectAttempts,
      final int maxReconnectAttempts,
      final McpServerCapabilities? capabilities,
      final McpServerMetrics? metrics,
      final Map<String, dynamic>? configuration}) = _$McpServerStateImpl;
  const _McpServerState._() : super._();

  @override
  String get serverId;
  @override
  String get serverName;
  @override
  McpConnectionStatus get status;
  @override
  DateTime get lastUpdated;
  @override
  List<McpTool> get tools;
  @override
  List<McpError> get errors;
  @override
  List<String> get warnings;
  @override
  bool get isConnecting;
  @override
  bool get isReconnecting;
  @override
  int get reconnectAttempts;
  @override
  int get maxReconnectAttempts;
  @override
  McpServerCapabilities? get capabilities;
  @override
  McpServerMetrics? get metrics;
  @override
  Map<String, dynamic>? get configuration;

  /// Create a copy of McpServerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$McpServerStateImplCopyWith<_$McpServerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$McpTool {
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  Map<String, dynamic> get schema => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  bool get isEnabled => throw _privateConstructorUsedError;
  DateTime? get lastUsed => throw _privateConstructorUsedError;
  int? get usageCount => throw _privateConstructorUsedError;

  /// Create a copy of McpTool
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $McpToolCopyWith<McpTool> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $McpToolCopyWith<$Res> {
  factory $McpToolCopyWith(McpTool value, $Res Function(McpTool) then) =
      _$McpToolCopyWithImpl<$Res, McpTool>;
  @useResult
  $Res call(
      {String name,
      String description,
      Map<String, dynamic> schema,
      List<String> tags,
      bool isEnabled,
      DateTime? lastUsed,
      int? usageCount});
}

/// @nodoc
class _$McpToolCopyWithImpl<$Res, $Val extends McpTool>
    implements $McpToolCopyWith<$Res> {
  _$McpToolCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of McpTool
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? schema = null,
    Object? tags = null,
    Object? isEnabled = null,
    Object? lastUsed = freezed,
    Object? usageCount = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      schema: null == schema
          ? _value.schema
          : schema // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUsed: freezed == lastUsed
          ? _value.lastUsed
          : lastUsed // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      usageCount: freezed == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$McpToolImplCopyWith<$Res> implements $McpToolCopyWith<$Res> {
  factory _$$McpToolImplCopyWith(
          _$McpToolImpl value, $Res Function(_$McpToolImpl) then) =
      __$$McpToolImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String description,
      Map<String, dynamic> schema,
      List<String> tags,
      bool isEnabled,
      DateTime? lastUsed,
      int? usageCount});
}

/// @nodoc
class __$$McpToolImplCopyWithImpl<$Res>
    extends _$McpToolCopyWithImpl<$Res, _$McpToolImpl>
    implements _$$McpToolImplCopyWith<$Res> {
  __$$McpToolImplCopyWithImpl(
      _$McpToolImpl _value, $Res Function(_$McpToolImpl) _then)
      : super(_value, _then);

  /// Create a copy of McpTool
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? schema = null,
    Object? tags = null,
    Object? isEnabled = null,
    Object? lastUsed = freezed,
    Object? usageCount = freezed,
  }) {
    return _then(_$McpToolImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      schema: null == schema
          ? _value._schema
          : schema // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUsed: freezed == lastUsed
          ? _value.lastUsed
          : lastUsed // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      usageCount: freezed == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$McpToolImpl extends _McpTool {
  const _$McpToolImpl(
      {required this.name,
      required this.description,
      required final Map<String, dynamic> schema,
      final List<String> tags = const [],
      this.isEnabled = true,
      this.lastUsed,
      this.usageCount})
      : _schema = schema,
        _tags = tags,
        super._();

  @override
  final String name;
  @override
  final String description;
  final Map<String, dynamic> _schema;
  @override
  Map<String, dynamic> get schema {
    if (_schema is EqualUnmodifiableMapView) return _schema;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_schema);
  }

  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final bool isEnabled;
  @override
  final DateTime? lastUsed;
  @override
  final int? usageCount;

  @override
  String toString() {
    return 'McpTool(name: $name, description: $description, schema: $schema, tags: $tags, isEnabled: $isEnabled, lastUsed: $lastUsed, usageCount: $usageCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$McpToolImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._schema, _schema) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.lastUsed, lastUsed) ||
                other.lastUsed == lastUsed) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      description,
      const DeepCollectionEquality().hash(_schema),
      const DeepCollectionEquality().hash(_tags),
      isEnabled,
      lastUsed,
      usageCount);

  /// Create a copy of McpTool
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$McpToolImplCopyWith<_$McpToolImpl> get copyWith =>
      __$$McpToolImplCopyWithImpl<_$McpToolImpl>(this, _$identity);
}

abstract class _McpTool extends McpTool {
  const factory _McpTool(
      {required final String name,
      required final String description,
      required final Map<String, dynamic> schema,
      final List<String> tags,
      final bool isEnabled,
      final DateTime? lastUsed,
      final int? usageCount}) = _$McpToolImpl;
  const _McpTool._() : super._();

  @override
  String get name;
  @override
  String get description;
  @override
  Map<String, dynamic> get schema;
  @override
  List<String> get tags;
  @override
  bool get isEnabled;
  @override
  DateTime? get lastUsed;
  @override
  int? get usageCount;

  /// Create a copy of McpTool
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$McpToolImplCopyWith<_$McpToolImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$McpError {
  String get id => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  McpErrorType get type => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get code => throw _privateConstructorUsedError;
  String? get serverId => throw _privateConstructorUsedError;
  String? get toolName => throw _privateConstructorUsedError;
  Map<String, dynamic>? get details => throw _privateConstructorUsedError;

  /// Create a copy of McpError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $McpErrorCopyWith<McpError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $McpErrorCopyWith<$Res> {
  factory $McpErrorCopyWith(McpError value, $Res Function(McpError) then) =
      _$McpErrorCopyWithImpl<$Res, McpError>;
  @useResult
  $Res call(
      {String id,
      String message,
      McpErrorType type,
      DateTime timestamp,
      String? code,
      String? serverId,
      String? toolName,
      Map<String, dynamic>? details});
}

/// @nodoc
class _$McpErrorCopyWithImpl<$Res, $Val extends McpError>
    implements $McpErrorCopyWith<$Res> {
  _$McpErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of McpError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? message = null,
    Object? type = null,
    Object? timestamp = null,
    Object? code = freezed,
    Object? serverId = freezed,
    Object? toolName = freezed,
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
              as McpErrorType,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      serverId: freezed == serverId
          ? _value.serverId
          : serverId // ignore: cast_nullable_to_non_nullable
              as String?,
      toolName: freezed == toolName
          ? _value.toolName
          : toolName // ignore: cast_nullable_to_non_nullable
              as String?,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$McpErrorImplCopyWith<$Res>
    implements $McpErrorCopyWith<$Res> {
  factory _$$McpErrorImplCopyWith(
          _$McpErrorImpl value, $Res Function(_$McpErrorImpl) then) =
      __$$McpErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String message,
      McpErrorType type,
      DateTime timestamp,
      String? code,
      String? serverId,
      String? toolName,
      Map<String, dynamic>? details});
}

/// @nodoc
class __$$McpErrorImplCopyWithImpl<$Res>
    extends _$McpErrorCopyWithImpl<$Res, _$McpErrorImpl>
    implements _$$McpErrorImplCopyWith<$Res> {
  __$$McpErrorImplCopyWithImpl(
      _$McpErrorImpl _value, $Res Function(_$McpErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of McpError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? message = null,
    Object? type = null,
    Object? timestamp = null,
    Object? code = freezed,
    Object? serverId = freezed,
    Object? toolName = freezed,
    Object? details = freezed,
  }) {
    return _then(_$McpErrorImpl(
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
              as McpErrorType,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      serverId: freezed == serverId
          ? _value.serverId
          : serverId // ignore: cast_nullable_to_non_nullable
              as String?,
      toolName: freezed == toolName
          ? _value.toolName
          : toolName // ignore: cast_nullable_to_non_nullable
              as String?,
      details: freezed == details
          ? _value._details
          : details // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$McpErrorImpl extends _McpError {
  const _$McpErrorImpl(
      {required this.id,
      required this.message,
      required this.type,
      required this.timestamp,
      this.code,
      this.serverId,
      this.toolName,
      final Map<String, dynamic>? details})
      : _details = details,
        super._();

  @override
  final String id;
  @override
  final String message;
  @override
  final McpErrorType type;
  @override
  final DateTime timestamp;
  @override
  final String? code;
  @override
  final String? serverId;
  @override
  final String? toolName;
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
    return 'McpError(id: $id, message: $message, type: $type, timestamp: $timestamp, code: $code, serverId: $serverId, toolName: $toolName, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$McpErrorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.serverId, serverId) ||
                other.serverId == serverId) &&
            (identical(other.toolName, toolName) ||
                other.toolName == toolName) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, message, type, timestamp,
      code, serverId, toolName, const DeepCollectionEquality().hash(_details));

  /// Create a copy of McpError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$McpErrorImplCopyWith<_$McpErrorImpl> get copyWith =>
      __$$McpErrorImplCopyWithImpl<_$McpErrorImpl>(this, _$identity);
}

abstract class _McpError extends McpError {
  const factory _McpError(
      {required final String id,
      required final String message,
      required final McpErrorType type,
      required final DateTime timestamp,
      final String? code,
      final String? serverId,
      final String? toolName,
      final Map<String, dynamic>? details}) = _$McpErrorImpl;
  const _McpError._() : super._();

  @override
  String get id;
  @override
  String get message;
  @override
  McpErrorType get type;
  @override
  DateTime get timestamp;
  @override
  String? get code;
  @override
  String? get serverId;
  @override
  String? get toolName;
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of McpError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$McpErrorImplCopyWith<_$McpErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$McpServerCapabilities {
  bool get supportsTools => throw _privateConstructorUsedError;
  bool get supportsResources => throw _privateConstructorUsedError;
  bool get supportsPrompts => throw _privateConstructorUsedError;
  List<String> get supportedProtocols => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;

  /// Create a copy of McpServerCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $McpServerCapabilitiesCopyWith<McpServerCapabilities> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $McpServerCapabilitiesCopyWith<$Res> {
  factory $McpServerCapabilitiesCopyWith(McpServerCapabilities value,
          $Res Function(McpServerCapabilities) then) =
      _$McpServerCapabilitiesCopyWithImpl<$Res, McpServerCapabilities>;
  @useResult
  $Res call(
      {bool supportsTools,
      bool supportsResources,
      bool supportsPrompts,
      List<String> supportedProtocols,
      String version});
}

/// @nodoc
class _$McpServerCapabilitiesCopyWithImpl<$Res,
        $Val extends McpServerCapabilities>
    implements $McpServerCapabilitiesCopyWith<$Res> {
  _$McpServerCapabilitiesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of McpServerCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? supportsTools = null,
    Object? supportsResources = null,
    Object? supportsPrompts = null,
    Object? supportedProtocols = null,
    Object? version = null,
  }) {
    return _then(_value.copyWith(
      supportsTools: null == supportsTools
          ? _value.supportsTools
          : supportsTools // ignore: cast_nullable_to_non_nullable
              as bool,
      supportsResources: null == supportsResources
          ? _value.supportsResources
          : supportsResources // ignore: cast_nullable_to_non_nullable
              as bool,
      supportsPrompts: null == supportsPrompts
          ? _value.supportsPrompts
          : supportsPrompts // ignore: cast_nullable_to_non_nullable
              as bool,
      supportedProtocols: null == supportedProtocols
          ? _value.supportedProtocols
          : supportedProtocols // ignore: cast_nullable_to_non_nullable
              as List<String>,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$McpServerCapabilitiesImplCopyWith<$Res>
    implements $McpServerCapabilitiesCopyWith<$Res> {
  factory _$$McpServerCapabilitiesImplCopyWith(
          _$McpServerCapabilitiesImpl value,
          $Res Function(_$McpServerCapabilitiesImpl) then) =
      __$$McpServerCapabilitiesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool supportsTools,
      bool supportsResources,
      bool supportsPrompts,
      List<String> supportedProtocols,
      String version});
}

/// @nodoc
class __$$McpServerCapabilitiesImplCopyWithImpl<$Res>
    extends _$McpServerCapabilitiesCopyWithImpl<$Res,
        _$McpServerCapabilitiesImpl>
    implements _$$McpServerCapabilitiesImplCopyWith<$Res> {
  __$$McpServerCapabilitiesImplCopyWithImpl(_$McpServerCapabilitiesImpl _value,
      $Res Function(_$McpServerCapabilitiesImpl) _then)
      : super(_value, _then);

  /// Create a copy of McpServerCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? supportsTools = null,
    Object? supportsResources = null,
    Object? supportsPrompts = null,
    Object? supportedProtocols = null,
    Object? version = null,
  }) {
    return _then(_$McpServerCapabilitiesImpl(
      supportsTools: null == supportsTools
          ? _value.supportsTools
          : supportsTools // ignore: cast_nullable_to_non_nullable
              as bool,
      supportsResources: null == supportsResources
          ? _value.supportsResources
          : supportsResources // ignore: cast_nullable_to_non_nullable
              as bool,
      supportsPrompts: null == supportsPrompts
          ? _value.supportsPrompts
          : supportsPrompts // ignore: cast_nullable_to_non_nullable
              as bool,
      supportedProtocols: null == supportedProtocols
          ? _value._supportedProtocols
          : supportedProtocols // ignore: cast_nullable_to_non_nullable
              as List<String>,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$McpServerCapabilitiesImpl extends _McpServerCapabilities {
  const _$McpServerCapabilitiesImpl(
      {required this.supportsTools,
      required this.supportsResources,
      required this.supportsPrompts,
      required final List<String> supportedProtocols,
      this.version = '1.0'})
      : _supportedProtocols = supportedProtocols,
        super._();

  @override
  final bool supportsTools;
  @override
  final bool supportsResources;
  @override
  final bool supportsPrompts;
  final List<String> _supportedProtocols;
  @override
  List<String> get supportedProtocols {
    if (_supportedProtocols is EqualUnmodifiableListView)
      return _supportedProtocols;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_supportedProtocols);
  }

  @override
  @JsonKey()
  final String version;

  @override
  String toString() {
    return 'McpServerCapabilities(supportsTools: $supportsTools, supportsResources: $supportsResources, supportsPrompts: $supportsPrompts, supportedProtocols: $supportedProtocols, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$McpServerCapabilitiesImpl &&
            (identical(other.supportsTools, supportsTools) ||
                other.supportsTools == supportsTools) &&
            (identical(other.supportsResources, supportsResources) ||
                other.supportsResources == supportsResources) &&
            (identical(other.supportsPrompts, supportsPrompts) ||
                other.supportsPrompts == supportsPrompts) &&
            const DeepCollectionEquality()
                .equals(other._supportedProtocols, _supportedProtocols) &&
            (identical(other.version, version) || other.version == version));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      supportsTools,
      supportsResources,
      supportsPrompts,
      const DeepCollectionEquality().hash(_supportedProtocols),
      version);

  /// Create a copy of McpServerCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$McpServerCapabilitiesImplCopyWith<_$McpServerCapabilitiesImpl>
      get copyWith => __$$McpServerCapabilitiesImplCopyWithImpl<
          _$McpServerCapabilitiesImpl>(this, _$identity);
}

abstract class _McpServerCapabilities extends McpServerCapabilities {
  const factory _McpServerCapabilities(
      {required final bool supportsTools,
      required final bool supportsResources,
      required final bool supportsPrompts,
      required final List<String> supportedProtocols,
      final String version}) = _$McpServerCapabilitiesImpl;
  const _McpServerCapabilities._() : super._();

  @override
  bool get supportsTools;
  @override
  bool get supportsResources;
  @override
  bool get supportsPrompts;
  @override
  List<String> get supportedProtocols;
  @override
  String get version;

  /// Create a copy of McpServerCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$McpServerCapabilitiesImplCopyWith<_$McpServerCapabilitiesImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$McpServerMetrics {
  double get averageResponseTime => throw _privateConstructorUsedError;
  double get lastResponseTime => throw _privateConstructorUsedError;
  int get totalRequests => throw _privateConstructorUsedError;
  int get successfulRequests => throw _privateConstructorUsedError;
  int get failedRequests => throw _privateConstructorUsedError;
  DateTime get lastMeasurement => throw _privateConstructorUsedError;
  int get activeConnections => throw _privateConstructorUsedError;

  /// Create a copy of McpServerMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $McpServerMetricsCopyWith<McpServerMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $McpServerMetricsCopyWith<$Res> {
  factory $McpServerMetricsCopyWith(
          McpServerMetrics value, $Res Function(McpServerMetrics) then) =
      _$McpServerMetricsCopyWithImpl<$Res, McpServerMetrics>;
  @useResult
  $Res call(
      {double averageResponseTime,
      double lastResponseTime,
      int totalRequests,
      int successfulRequests,
      int failedRequests,
      DateTime lastMeasurement,
      int activeConnections});
}

/// @nodoc
class _$McpServerMetricsCopyWithImpl<$Res, $Val extends McpServerMetrics>
    implements $McpServerMetricsCopyWith<$Res> {
  _$McpServerMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of McpServerMetrics
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
    Object? activeConnections = null,
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
      activeConnections: null == activeConnections
          ? _value.activeConnections
          : activeConnections // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$McpServerMetricsImplCopyWith<$Res>
    implements $McpServerMetricsCopyWith<$Res> {
  factory _$$McpServerMetricsImplCopyWith(_$McpServerMetricsImpl value,
          $Res Function(_$McpServerMetricsImpl) then) =
      __$$McpServerMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double averageResponseTime,
      double lastResponseTime,
      int totalRequests,
      int successfulRequests,
      int failedRequests,
      DateTime lastMeasurement,
      int activeConnections});
}

/// @nodoc
class __$$McpServerMetricsImplCopyWithImpl<$Res>
    extends _$McpServerMetricsCopyWithImpl<$Res, _$McpServerMetricsImpl>
    implements _$$McpServerMetricsImplCopyWith<$Res> {
  __$$McpServerMetricsImplCopyWithImpl(_$McpServerMetricsImpl _value,
      $Res Function(_$McpServerMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of McpServerMetrics
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
    Object? activeConnections = null,
  }) {
    return _then(_$McpServerMetricsImpl(
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
      activeConnections: null == activeConnections
          ? _value.activeConnections
          : activeConnections // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$McpServerMetricsImpl extends _McpServerMetrics {
  const _$McpServerMetricsImpl(
      {required this.averageResponseTime,
      required this.lastResponseTime,
      required this.totalRequests,
      required this.successfulRequests,
      required this.failedRequests,
      required this.lastMeasurement,
      this.activeConnections = 0})
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
  @JsonKey()
  final int activeConnections;

  @override
  String toString() {
    return 'McpServerMetrics(averageResponseTime: $averageResponseTime, lastResponseTime: $lastResponseTime, totalRequests: $totalRequests, successfulRequests: $successfulRequests, failedRequests: $failedRequests, lastMeasurement: $lastMeasurement, activeConnections: $activeConnections)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$McpServerMetricsImpl &&
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
                other.lastMeasurement == lastMeasurement) &&
            (identical(other.activeConnections, activeConnections) ||
                other.activeConnections == activeConnections));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      averageResponseTime,
      lastResponseTime,
      totalRequests,
      successfulRequests,
      failedRequests,
      lastMeasurement,
      activeConnections);

  /// Create a copy of McpServerMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$McpServerMetricsImplCopyWith<_$McpServerMetricsImpl> get copyWith =>
      __$$McpServerMetricsImplCopyWithImpl<_$McpServerMetricsImpl>(
          this, _$identity);
}

abstract class _McpServerMetrics extends McpServerMetrics {
  const factory _McpServerMetrics(
      {required final double averageResponseTime,
      required final double lastResponseTime,
      required final int totalRequests,
      required final int successfulRequests,
      required final int failedRequests,
      required final DateTime lastMeasurement,
      final int activeConnections}) = _$McpServerMetricsImpl;
  const _McpServerMetrics._() : super._();

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
  @override
  int get activeConnections;

  /// Create a copy of McpServerMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$McpServerMetricsImplCopyWith<_$McpServerMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
