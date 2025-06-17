// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_configuration_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AiConfigurationState {
  UserAiConfiguration get configuration => throw _privateConstructorUsedError;
  bool get isValid => throw _privateConstructorUsedError;
  ConfigurationStatus get status => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;
  List<ValidationError> get validationErrors =>
      throw _privateConstructorUsedError;
  List<String> get warnings => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;

  /// Create a copy of AiConfigurationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiConfigurationStateCopyWith<AiConfigurationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiConfigurationStateCopyWith<$Res> {
  factory $AiConfigurationStateCopyWith(AiConfigurationState value,
          $Res Function(AiConfigurationState) then) =
      _$AiConfigurationStateCopyWithImpl<$Res, AiConfigurationState>;
  @useResult
  $Res call(
      {UserAiConfiguration configuration,
      bool isValid,
      ConfigurationStatus status,
      DateTime lastUpdated,
      List<ValidationError> validationErrors,
      List<String> warnings,
      bool isLoading});
}

/// @nodoc
class _$AiConfigurationStateCopyWithImpl<$Res,
        $Val extends AiConfigurationState>
    implements $AiConfigurationStateCopyWith<$Res> {
  _$AiConfigurationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiConfigurationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? configuration = null,
    Object? isValid = null,
    Object? status = null,
    Object? lastUpdated = null,
    Object? validationErrors = null,
    Object? warnings = null,
    Object? isLoading = null,
  }) {
    return _then(_value.copyWith(
      configuration: null == configuration
          ? _value.configuration
          : configuration // ignore: cast_nullable_to_non_nullable
              as UserAiConfiguration,
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ConfigurationStatus,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      validationErrors: null == validationErrors
          ? _value.validationErrors
          : validationErrors // ignore: cast_nullable_to_non_nullable
              as List<ValidationError>,
      warnings: null == warnings
          ? _value.warnings
          : warnings // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiConfigurationStateImplCopyWith<$Res>
    implements $AiConfigurationStateCopyWith<$Res> {
  factory _$$AiConfigurationStateImplCopyWith(_$AiConfigurationStateImpl value,
          $Res Function(_$AiConfigurationStateImpl) then) =
      __$$AiConfigurationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {UserAiConfiguration configuration,
      bool isValid,
      ConfigurationStatus status,
      DateTime lastUpdated,
      List<ValidationError> validationErrors,
      List<String> warnings,
      bool isLoading});
}

/// @nodoc
class __$$AiConfigurationStateImplCopyWithImpl<$Res>
    extends _$AiConfigurationStateCopyWithImpl<$Res, _$AiConfigurationStateImpl>
    implements _$$AiConfigurationStateImplCopyWith<$Res> {
  __$$AiConfigurationStateImplCopyWithImpl(_$AiConfigurationStateImpl _value,
      $Res Function(_$AiConfigurationStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AiConfigurationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? configuration = null,
    Object? isValid = null,
    Object? status = null,
    Object? lastUpdated = null,
    Object? validationErrors = null,
    Object? warnings = null,
    Object? isLoading = null,
  }) {
    return _then(_$AiConfigurationStateImpl(
      configuration: null == configuration
          ? _value.configuration
          : configuration // ignore: cast_nullable_to_non_nullable
              as UserAiConfiguration,
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ConfigurationStatus,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      validationErrors: null == validationErrors
          ? _value._validationErrors
          : validationErrors // ignore: cast_nullable_to_non_nullable
              as List<ValidationError>,
      warnings: null == warnings
          ? _value._warnings
          : warnings // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$AiConfigurationStateImpl extends _AiConfigurationState {
  const _$AiConfigurationStateImpl(
      {required this.configuration,
      required this.isValid,
      required this.status,
      required this.lastUpdated,
      required final List<ValidationError> validationErrors,
      final List<String> warnings = const [],
      this.isLoading = false})
      : _validationErrors = validationErrors,
        _warnings = warnings,
        super._();

  @override
  final UserAiConfiguration configuration;
  @override
  final bool isValid;
  @override
  final ConfigurationStatus status;
  @override
  final DateTime lastUpdated;
  final List<ValidationError> _validationErrors;
  @override
  List<ValidationError> get validationErrors {
    if (_validationErrors is EqualUnmodifiableListView)
      return _validationErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_validationErrors);
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
  final bool isLoading;

  @override
  String toString() {
    return 'AiConfigurationState(configuration: $configuration, isValid: $isValid, status: $status, lastUpdated: $lastUpdated, validationErrors: $validationErrors, warnings: $warnings, isLoading: $isLoading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiConfigurationStateImpl &&
            (identical(other.configuration, configuration) ||
                other.configuration == configuration) &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            const DeepCollectionEquality()
                .equals(other._validationErrors, _validationErrors) &&
            const DeepCollectionEquality().equals(other._warnings, _warnings) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      configuration,
      isValid,
      status,
      lastUpdated,
      const DeepCollectionEquality().hash(_validationErrors),
      const DeepCollectionEquality().hash(_warnings),
      isLoading);

  /// Create a copy of AiConfigurationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiConfigurationStateImplCopyWith<_$AiConfigurationStateImpl>
      get copyWith =>
          __$$AiConfigurationStateImplCopyWithImpl<_$AiConfigurationStateImpl>(
              this, _$identity);
}

abstract class _AiConfigurationState extends AiConfigurationState {
  const factory _AiConfigurationState(
      {required final UserAiConfiguration configuration,
      required final bool isValid,
      required final ConfigurationStatus status,
      required final DateTime lastUpdated,
      required final List<ValidationError> validationErrors,
      final List<String> warnings,
      final bool isLoading}) = _$AiConfigurationStateImpl;
  const _AiConfigurationState._() : super._();

  @override
  UserAiConfiguration get configuration;
  @override
  bool get isValid;
  @override
  ConfigurationStatus get status;
  @override
  DateTime get lastUpdated;
  @override
  List<ValidationError> get validationErrors;
  @override
  List<String> get warnings;
  @override
  bool get isLoading;

  /// Create a copy of AiConfigurationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiConfigurationStateImplCopyWith<_$AiConfigurationStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ValidationError {
  String get field => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  ValidationErrorType get type => throw _privateConstructorUsedError;
  String? get code => throw _privateConstructorUsedError;
  Map<String, dynamic>? get details => throw _privateConstructorUsedError;

  /// Create a copy of ValidationError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ValidationErrorCopyWith<ValidationError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValidationErrorCopyWith<$Res> {
  factory $ValidationErrorCopyWith(
          ValidationError value, $Res Function(ValidationError) then) =
      _$ValidationErrorCopyWithImpl<$Res, ValidationError>;
  @useResult
  $Res call(
      {String field,
      String message,
      ValidationErrorType type,
      String? code,
      Map<String, dynamic>? details});
}

/// @nodoc
class _$ValidationErrorCopyWithImpl<$Res, $Val extends ValidationError>
    implements $ValidationErrorCopyWith<$Res> {
  _$ValidationErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ValidationError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field = null,
    Object? message = null,
    Object? type = null,
    Object? code = freezed,
    Object? details = freezed,
  }) {
    return _then(_value.copyWith(
      field: null == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ValidationErrorType,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ValidationErrorImplCopyWith<$Res>
    implements $ValidationErrorCopyWith<$Res> {
  factory _$$ValidationErrorImplCopyWith(_$ValidationErrorImpl value,
          $Res Function(_$ValidationErrorImpl) then) =
      __$$ValidationErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String field,
      String message,
      ValidationErrorType type,
      String? code,
      Map<String, dynamic>? details});
}

/// @nodoc
class __$$ValidationErrorImplCopyWithImpl<$Res>
    extends _$ValidationErrorCopyWithImpl<$Res, _$ValidationErrorImpl>
    implements _$$ValidationErrorImplCopyWith<$Res> {
  __$$ValidationErrorImplCopyWithImpl(
      _$ValidationErrorImpl _value, $Res Function(_$ValidationErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of ValidationError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field = null,
    Object? message = null,
    Object? type = null,
    Object? code = freezed,
    Object? details = freezed,
  }) {
    return _then(_$ValidationErrorImpl(
      field: null == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ValidationErrorType,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      details: freezed == details
          ? _value._details
          : details // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$ValidationErrorImpl extends _ValidationError {
  const _$ValidationErrorImpl(
      {required this.field,
      required this.message,
      required this.type,
      this.code,
      final Map<String, dynamic>? details})
      : _details = details,
        super._();

  @override
  final String field;
  @override
  final String message;
  @override
  final ValidationErrorType type;
  @override
  final String? code;
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
    return 'ValidationError(field: $field, message: $message, type: $type, code: $code, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationErrorImpl &&
            (identical(other.field, field) || other.field == field) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field, message, type, code,
      const DeepCollectionEquality().hash(_details));

  /// Create a copy of ValidationError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      __$$ValidationErrorImplCopyWithImpl<_$ValidationErrorImpl>(
          this, _$identity);
}

abstract class _ValidationError extends ValidationError {
  const factory _ValidationError(
      {required final String field,
      required final String message,
      required final ValidationErrorType type,
      final String? code,
      final Map<String, dynamic>? details}) = _$ValidationErrorImpl;
  const _ValidationError._() : super._();

  @override
  String get field;
  @override
  String get message;
  @override
  ValidationErrorType get type;
  @override
  String? get code;
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of ValidationError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
