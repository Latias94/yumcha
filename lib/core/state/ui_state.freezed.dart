// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ui_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ScrollConfig {
  /// Whether to auto-scroll to new messages
  bool get autoScroll => throw _privateConstructorUsedError;

  /// Auto-scroll threshold (distance from bottom to trigger auto-scroll)
  double get autoScrollThreshold => throw _privateConstructorUsedError;

  /// Scroll animation duration in milliseconds
  int get scrollAnimationDuration => throw _privateConstructorUsedError;

  /// Whether to show scroll-to-bottom button
  bool get showScrollToBottomButton => throw _privateConstructorUsedError;

  /// Scroll physics type
  ScrollPhysicsType get physicsType => throw _privateConstructorUsedError;

  /// Create a copy of ScrollConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScrollConfigCopyWith<ScrollConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScrollConfigCopyWith<$Res> {
  factory $ScrollConfigCopyWith(
          ScrollConfig value, $Res Function(ScrollConfig) then) =
      _$ScrollConfigCopyWithImpl<$Res, ScrollConfig>;
  @useResult
  $Res call(
      {bool autoScroll,
      double autoScrollThreshold,
      int scrollAnimationDuration,
      bool showScrollToBottomButton,
      ScrollPhysicsType physicsType});
}

/// @nodoc
class _$ScrollConfigCopyWithImpl<$Res, $Val extends ScrollConfig>
    implements $ScrollConfigCopyWith<$Res> {
  _$ScrollConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScrollConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? autoScroll = null,
    Object? autoScrollThreshold = null,
    Object? scrollAnimationDuration = null,
    Object? showScrollToBottomButton = null,
    Object? physicsType = null,
  }) {
    return _then(_value.copyWith(
      autoScroll: null == autoScroll
          ? _value.autoScroll
          : autoScroll // ignore: cast_nullable_to_non_nullable
              as bool,
      autoScrollThreshold: null == autoScrollThreshold
          ? _value.autoScrollThreshold
          : autoScrollThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      scrollAnimationDuration: null == scrollAnimationDuration
          ? _value.scrollAnimationDuration
          : scrollAnimationDuration // ignore: cast_nullable_to_non_nullable
              as int,
      showScrollToBottomButton: null == showScrollToBottomButton
          ? _value.showScrollToBottomButton
          : showScrollToBottomButton // ignore: cast_nullable_to_non_nullable
              as bool,
      physicsType: null == physicsType
          ? _value.physicsType
          : physicsType // ignore: cast_nullable_to_non_nullable
              as ScrollPhysicsType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScrollConfigImplCopyWith<$Res>
    implements $ScrollConfigCopyWith<$Res> {
  factory _$$ScrollConfigImplCopyWith(
          _$ScrollConfigImpl value, $Res Function(_$ScrollConfigImpl) then) =
      __$$ScrollConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool autoScroll,
      double autoScrollThreshold,
      int scrollAnimationDuration,
      bool showScrollToBottomButton,
      ScrollPhysicsType physicsType});
}

/// @nodoc
class __$$ScrollConfigImplCopyWithImpl<$Res>
    extends _$ScrollConfigCopyWithImpl<$Res, _$ScrollConfigImpl>
    implements _$$ScrollConfigImplCopyWith<$Res> {
  __$$ScrollConfigImplCopyWithImpl(
      _$ScrollConfigImpl _value, $Res Function(_$ScrollConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScrollConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? autoScroll = null,
    Object? autoScrollThreshold = null,
    Object? scrollAnimationDuration = null,
    Object? showScrollToBottomButton = null,
    Object? physicsType = null,
  }) {
    return _then(_$ScrollConfigImpl(
      autoScroll: null == autoScroll
          ? _value.autoScroll
          : autoScroll // ignore: cast_nullable_to_non_nullable
              as bool,
      autoScrollThreshold: null == autoScrollThreshold
          ? _value.autoScrollThreshold
          : autoScrollThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      scrollAnimationDuration: null == scrollAnimationDuration
          ? _value.scrollAnimationDuration
          : scrollAnimationDuration // ignore: cast_nullable_to_non_nullable
              as int,
      showScrollToBottomButton: null == showScrollToBottomButton
          ? _value.showScrollToBottomButton
          : showScrollToBottomButton // ignore: cast_nullable_to_non_nullable
              as bool,
      physicsType: null == physicsType
          ? _value.physicsType
          : physicsType // ignore: cast_nullable_to_non_nullable
              as ScrollPhysicsType,
    ));
  }
}

/// @nodoc

class _$ScrollConfigImpl implements _ScrollConfig {
  const _$ScrollConfigImpl(
      {this.autoScroll = true,
      this.autoScrollThreshold = 100.0,
      this.scrollAnimationDuration = 300,
      this.showScrollToBottomButton = true,
      this.physicsType = ScrollPhysicsType.platform});

  /// Whether to auto-scroll to new messages
  @override
  @JsonKey()
  final bool autoScroll;

  /// Auto-scroll threshold (distance from bottom to trigger auto-scroll)
  @override
  @JsonKey()
  final double autoScrollThreshold;

  /// Scroll animation duration in milliseconds
  @override
  @JsonKey()
  final int scrollAnimationDuration;

  /// Whether to show scroll-to-bottom button
  @override
  @JsonKey()
  final bool showScrollToBottomButton;

  /// Scroll physics type
  @override
  @JsonKey()
  final ScrollPhysicsType physicsType;

  @override
  String toString() {
    return 'ScrollConfig(autoScroll: $autoScroll, autoScrollThreshold: $autoScrollThreshold, scrollAnimationDuration: $scrollAnimationDuration, showScrollToBottomButton: $showScrollToBottomButton, physicsType: $physicsType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScrollConfigImpl &&
            (identical(other.autoScroll, autoScroll) ||
                other.autoScroll == autoScroll) &&
            (identical(other.autoScrollThreshold, autoScrollThreshold) ||
                other.autoScrollThreshold == autoScrollThreshold) &&
            (identical(
                    other.scrollAnimationDuration, scrollAnimationDuration) ||
                other.scrollAnimationDuration == scrollAnimationDuration) &&
            (identical(
                    other.showScrollToBottomButton, showScrollToBottomButton) ||
                other.showScrollToBottomButton == showScrollToBottomButton) &&
            (identical(other.physicsType, physicsType) ||
                other.physicsType == physicsType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, autoScroll, autoScrollThreshold,
      scrollAnimationDuration, showScrollToBottomButton, physicsType);

  /// Create a copy of ScrollConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScrollConfigImplCopyWith<_$ScrollConfigImpl> get copyWith =>
      __$$ScrollConfigImplCopyWithImpl<_$ScrollConfigImpl>(this, _$identity);
}

abstract class _ScrollConfig implements ScrollConfig {
  const factory _ScrollConfig(
      {final bool autoScroll,
      final double autoScrollThreshold,
      final int scrollAnimationDuration,
      final bool showScrollToBottomButton,
      final ScrollPhysicsType physicsType}) = _$ScrollConfigImpl;

  /// Whether to auto-scroll to new messages
  @override
  bool get autoScroll;

  /// Auto-scroll threshold (distance from bottom to trigger auto-scroll)
  @override
  double get autoScrollThreshold;

  /// Scroll animation duration in milliseconds
  @override
  int get scrollAnimationDuration;

  /// Whether to show scroll-to-bottom button
  @override
  bool get showScrollToBottomButton;

  /// Scroll physics type
  @override
  ScrollPhysicsType get physicsType;

  /// Create a copy of ScrollConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScrollConfigImplCopyWith<_$ScrollConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$VirtualScrollConfig {
  /// Whether virtual scrolling is enabled
  bool get enabled => throw _privateConstructorUsedError;

  /// Threshold for enabling virtual scrolling (number of items)
  int get enableThreshold => throw _privateConstructorUsedError;

  /// Number of items to render outside visible area
  int get overscan => throw _privateConstructorUsedError;

  /// Estimated item height for virtual scrolling
  double get estimatedItemHeight => throw _privateConstructorUsedError;

  /// Whether to cache item heights
  bool get cacheItemHeights => throw _privateConstructorUsedError;

  /// Create a copy of VirtualScrollConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VirtualScrollConfigCopyWith<VirtualScrollConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VirtualScrollConfigCopyWith<$Res> {
  factory $VirtualScrollConfigCopyWith(
          VirtualScrollConfig value, $Res Function(VirtualScrollConfig) then) =
      _$VirtualScrollConfigCopyWithImpl<$Res, VirtualScrollConfig>;
  @useResult
  $Res call(
      {bool enabled,
      int enableThreshold,
      int overscan,
      double estimatedItemHeight,
      bool cacheItemHeights});
}

/// @nodoc
class _$VirtualScrollConfigCopyWithImpl<$Res, $Val extends VirtualScrollConfig>
    implements $VirtualScrollConfigCopyWith<$Res> {
  _$VirtualScrollConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VirtualScrollConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? enableThreshold = null,
    Object? overscan = null,
    Object? estimatedItemHeight = null,
    Object? cacheItemHeights = null,
  }) {
    return _then(_value.copyWith(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      enableThreshold: null == enableThreshold
          ? _value.enableThreshold
          : enableThreshold // ignore: cast_nullable_to_non_nullable
              as int,
      overscan: null == overscan
          ? _value.overscan
          : overscan // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedItemHeight: null == estimatedItemHeight
          ? _value.estimatedItemHeight
          : estimatedItemHeight // ignore: cast_nullable_to_non_nullable
              as double,
      cacheItemHeights: null == cacheItemHeights
          ? _value.cacheItemHeights
          : cacheItemHeights // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VirtualScrollConfigImplCopyWith<$Res>
    implements $VirtualScrollConfigCopyWith<$Res> {
  factory _$$VirtualScrollConfigImplCopyWith(_$VirtualScrollConfigImpl value,
          $Res Function(_$VirtualScrollConfigImpl) then) =
      __$$VirtualScrollConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enabled,
      int enableThreshold,
      int overscan,
      double estimatedItemHeight,
      bool cacheItemHeights});
}

/// @nodoc
class __$$VirtualScrollConfigImplCopyWithImpl<$Res>
    extends _$VirtualScrollConfigCopyWithImpl<$Res, _$VirtualScrollConfigImpl>
    implements _$$VirtualScrollConfigImplCopyWith<$Res> {
  __$$VirtualScrollConfigImplCopyWithImpl(_$VirtualScrollConfigImpl _value,
      $Res Function(_$VirtualScrollConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of VirtualScrollConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? enableThreshold = null,
    Object? overscan = null,
    Object? estimatedItemHeight = null,
    Object? cacheItemHeights = null,
  }) {
    return _then(_$VirtualScrollConfigImpl(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      enableThreshold: null == enableThreshold
          ? _value.enableThreshold
          : enableThreshold // ignore: cast_nullable_to_non_nullable
              as int,
      overscan: null == overscan
          ? _value.overscan
          : overscan // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedItemHeight: null == estimatedItemHeight
          ? _value.estimatedItemHeight
          : estimatedItemHeight // ignore: cast_nullable_to_non_nullable
              as double,
      cacheItemHeights: null == cacheItemHeights
          ? _value.cacheItemHeights
          : cacheItemHeights // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$VirtualScrollConfigImpl implements _VirtualScrollConfig {
  const _$VirtualScrollConfigImpl(
      {this.enabled = true,
      this.enableThreshold = 50,
      this.overscan = 5,
      this.estimatedItemHeight = 100.0,
      this.cacheItemHeights = true});

  /// Whether virtual scrolling is enabled
  @override
  @JsonKey()
  final bool enabled;

  /// Threshold for enabling virtual scrolling (number of items)
  @override
  @JsonKey()
  final int enableThreshold;

  /// Number of items to render outside visible area
  @override
  @JsonKey()
  final int overscan;

  /// Estimated item height for virtual scrolling
  @override
  @JsonKey()
  final double estimatedItemHeight;

  /// Whether to cache item heights
  @override
  @JsonKey()
  final bool cacheItemHeights;

  @override
  String toString() {
    return 'VirtualScrollConfig(enabled: $enabled, enableThreshold: $enableThreshold, overscan: $overscan, estimatedItemHeight: $estimatedItemHeight, cacheItemHeights: $cacheItemHeights)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VirtualScrollConfigImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.enableThreshold, enableThreshold) ||
                other.enableThreshold == enableThreshold) &&
            (identical(other.overscan, overscan) ||
                other.overscan == overscan) &&
            (identical(other.estimatedItemHeight, estimatedItemHeight) ||
                other.estimatedItemHeight == estimatedItemHeight) &&
            (identical(other.cacheItemHeights, cacheItemHeights) ||
                other.cacheItemHeights == cacheItemHeights));
  }

  @override
  int get hashCode => Object.hash(runtimeType, enabled, enableThreshold,
      overscan, estimatedItemHeight, cacheItemHeights);

  /// Create a copy of VirtualScrollConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VirtualScrollConfigImplCopyWith<_$VirtualScrollConfigImpl> get copyWith =>
      __$$VirtualScrollConfigImplCopyWithImpl<_$VirtualScrollConfigImpl>(
          this, _$identity);
}

abstract class _VirtualScrollConfig implements VirtualScrollConfig {
  const factory _VirtualScrollConfig(
      {final bool enabled,
      final int enableThreshold,
      final int overscan,
      final double estimatedItemHeight,
      final bool cacheItemHeights}) = _$VirtualScrollConfigImpl;

  /// Whether virtual scrolling is enabled
  @override
  bool get enabled;

  /// Threshold for enabling virtual scrolling (number of items)
  @override
  int get enableThreshold;

  /// Number of items to render outside visible area
  @override
  int get overscan;

  /// Estimated item height for virtual scrolling
  @override
  double get estimatedItemHeight;

  /// Whether to cache item heights
  @override
  bool get cacheItemHeights;

  /// Create a copy of VirtualScrollConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VirtualScrollConfigImplCopyWith<_$VirtualScrollConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PaginationConfig {
  /// Initial page size
  int get initialPageSize => throw _privateConstructorUsedError;

  /// Load more page size
  int get loadMorePageSize => throw _privateConstructorUsedError;

  /// Whether to enable infinite scroll
  bool get enableInfiniteScroll => throw _privateConstructorUsedError;

  /// Distance from top to trigger load more
  double get loadMoreThreshold => throw _privateConstructorUsedError;

  /// Whether to show load more button
  bool get showLoadMoreButton => throw _privateConstructorUsedError;

  /// Create a copy of PaginationConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaginationConfigCopyWith<PaginationConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaginationConfigCopyWith<$Res> {
  factory $PaginationConfigCopyWith(
          PaginationConfig value, $Res Function(PaginationConfig) then) =
      _$PaginationConfigCopyWithImpl<$Res, PaginationConfig>;
  @useResult
  $Res call(
      {int initialPageSize,
      int loadMorePageSize,
      bool enableInfiniteScroll,
      double loadMoreThreshold,
      bool showLoadMoreButton});
}

/// @nodoc
class _$PaginationConfigCopyWithImpl<$Res, $Val extends PaginationConfig>
    implements $PaginationConfigCopyWith<$Res> {
  _$PaginationConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaginationConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? initialPageSize = null,
    Object? loadMorePageSize = null,
    Object? enableInfiniteScroll = null,
    Object? loadMoreThreshold = null,
    Object? showLoadMoreButton = null,
  }) {
    return _then(_value.copyWith(
      initialPageSize: null == initialPageSize
          ? _value.initialPageSize
          : initialPageSize // ignore: cast_nullable_to_non_nullable
              as int,
      loadMorePageSize: null == loadMorePageSize
          ? _value.loadMorePageSize
          : loadMorePageSize // ignore: cast_nullable_to_non_nullable
              as int,
      enableInfiniteScroll: null == enableInfiniteScroll
          ? _value.enableInfiniteScroll
          : enableInfiniteScroll // ignore: cast_nullable_to_non_nullable
              as bool,
      loadMoreThreshold: null == loadMoreThreshold
          ? _value.loadMoreThreshold
          : loadMoreThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      showLoadMoreButton: null == showLoadMoreButton
          ? _value.showLoadMoreButton
          : showLoadMoreButton // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaginationConfigImplCopyWith<$Res>
    implements $PaginationConfigCopyWith<$Res> {
  factory _$$PaginationConfigImplCopyWith(_$PaginationConfigImpl value,
          $Res Function(_$PaginationConfigImpl) then) =
      __$$PaginationConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int initialPageSize,
      int loadMorePageSize,
      bool enableInfiniteScroll,
      double loadMoreThreshold,
      bool showLoadMoreButton});
}

/// @nodoc
class __$$PaginationConfigImplCopyWithImpl<$Res>
    extends _$PaginationConfigCopyWithImpl<$Res, _$PaginationConfigImpl>
    implements _$$PaginationConfigImplCopyWith<$Res> {
  __$$PaginationConfigImplCopyWithImpl(_$PaginationConfigImpl _value,
      $Res Function(_$PaginationConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaginationConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? initialPageSize = null,
    Object? loadMorePageSize = null,
    Object? enableInfiniteScroll = null,
    Object? loadMoreThreshold = null,
    Object? showLoadMoreButton = null,
  }) {
    return _then(_$PaginationConfigImpl(
      initialPageSize: null == initialPageSize
          ? _value.initialPageSize
          : initialPageSize // ignore: cast_nullable_to_non_nullable
              as int,
      loadMorePageSize: null == loadMorePageSize
          ? _value.loadMorePageSize
          : loadMorePageSize // ignore: cast_nullable_to_non_nullable
              as int,
      enableInfiniteScroll: null == enableInfiniteScroll
          ? _value.enableInfiniteScroll
          : enableInfiniteScroll // ignore: cast_nullable_to_non_nullable
              as bool,
      loadMoreThreshold: null == loadMoreThreshold
          ? _value.loadMoreThreshold
          : loadMoreThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      showLoadMoreButton: null == showLoadMoreButton
          ? _value.showLoadMoreButton
          : showLoadMoreButton // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$PaginationConfigImpl implements _PaginationConfig {
  const _$PaginationConfigImpl(
      {this.initialPageSize = 20,
      this.loadMorePageSize = 10,
      this.enableInfiniteScroll = true,
      this.loadMoreThreshold = 200.0,
      this.showLoadMoreButton = false});

  /// Initial page size
  @override
  @JsonKey()
  final int initialPageSize;

  /// Load more page size
  @override
  @JsonKey()
  final int loadMorePageSize;

  /// Whether to enable infinite scroll
  @override
  @JsonKey()
  final bool enableInfiniteScroll;

  /// Distance from top to trigger load more
  @override
  @JsonKey()
  final double loadMoreThreshold;

  /// Whether to show load more button
  @override
  @JsonKey()
  final bool showLoadMoreButton;

  @override
  String toString() {
    return 'PaginationConfig(initialPageSize: $initialPageSize, loadMorePageSize: $loadMorePageSize, enableInfiniteScroll: $enableInfiniteScroll, loadMoreThreshold: $loadMoreThreshold, showLoadMoreButton: $showLoadMoreButton)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginationConfigImpl &&
            (identical(other.initialPageSize, initialPageSize) ||
                other.initialPageSize == initialPageSize) &&
            (identical(other.loadMorePageSize, loadMorePageSize) ||
                other.loadMorePageSize == loadMorePageSize) &&
            (identical(other.enableInfiniteScroll, enableInfiniteScroll) ||
                other.enableInfiniteScroll == enableInfiniteScroll) &&
            (identical(other.loadMoreThreshold, loadMoreThreshold) ||
                other.loadMoreThreshold == loadMoreThreshold) &&
            (identical(other.showLoadMoreButton, showLoadMoreButton) ||
                other.showLoadMoreButton == showLoadMoreButton));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      initialPageSize,
      loadMorePageSize,
      enableInfiniteScroll,
      loadMoreThreshold,
      showLoadMoreButton);

  /// Create a copy of PaginationConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaginationConfigImplCopyWith<_$PaginationConfigImpl> get copyWith =>
      __$$PaginationConfigImplCopyWithImpl<_$PaginationConfigImpl>(
          this, _$identity);
}

abstract class _PaginationConfig implements PaginationConfig {
  const factory _PaginationConfig(
      {final int initialPageSize,
      final int loadMorePageSize,
      final bool enableInfiniteScroll,
      final double loadMoreThreshold,
      final bool showLoadMoreButton}) = _$PaginationConfigImpl;

  /// Initial page size
  @override
  int get initialPageSize;

  /// Load more page size
  @override
  int get loadMorePageSize;

  /// Whether to enable infinite scroll
  @override
  bool get enableInfiniteScroll;

  /// Distance from top to trigger load more
  @override
  double get loadMoreThreshold;

  /// Whether to show load more button
  @override
  bool get showLoadMoreButton;

  /// Create a copy of PaginationConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaginationConfigImplCopyWith<_$PaginationConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ThemeConfig {
  /// Current theme mode
  ThemeMode get themeMode => throw _privateConstructorUsedError;

  /// Font size multiplier
  double get fontSizeMultiplier => throw _privateConstructorUsedError;

  /// Whether to use compact mode
  bool get isCompactMode => throw _privateConstructorUsedError;

  /// Primary color seed
  Color? get primaryColorSeed => throw _privateConstructorUsedError;

  /// Whether to use material 3 design
  bool get useMaterial3 => throw _privateConstructorUsedError;

  /// Custom theme name
  String? get customThemeName => throw _privateConstructorUsedError;

  /// Create a copy of ThemeConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ThemeConfigCopyWith<ThemeConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ThemeConfigCopyWith<$Res> {
  factory $ThemeConfigCopyWith(
          ThemeConfig value, $Res Function(ThemeConfig) then) =
      _$ThemeConfigCopyWithImpl<$Res, ThemeConfig>;
  @useResult
  $Res call(
      {ThemeMode themeMode,
      double fontSizeMultiplier,
      bool isCompactMode,
      Color? primaryColorSeed,
      bool useMaterial3,
      String? customThemeName});
}

/// @nodoc
class _$ThemeConfigCopyWithImpl<$Res, $Val extends ThemeConfig>
    implements $ThemeConfigCopyWith<$Res> {
  _$ThemeConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ThemeConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? fontSizeMultiplier = null,
    Object? isCompactMode = null,
    Object? primaryColorSeed = freezed,
    Object? useMaterial3 = null,
    Object? customThemeName = freezed,
  }) {
    return _then(_value.copyWith(
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      fontSizeMultiplier: null == fontSizeMultiplier
          ? _value.fontSizeMultiplier
          : fontSizeMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      isCompactMode: null == isCompactMode
          ? _value.isCompactMode
          : isCompactMode // ignore: cast_nullable_to_non_nullable
              as bool,
      primaryColorSeed: freezed == primaryColorSeed
          ? _value.primaryColorSeed
          : primaryColorSeed // ignore: cast_nullable_to_non_nullable
              as Color?,
      useMaterial3: null == useMaterial3
          ? _value.useMaterial3
          : useMaterial3 // ignore: cast_nullable_to_non_nullable
              as bool,
      customThemeName: freezed == customThemeName
          ? _value.customThemeName
          : customThemeName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ThemeConfigImplCopyWith<$Res>
    implements $ThemeConfigCopyWith<$Res> {
  factory _$$ThemeConfigImplCopyWith(
          _$ThemeConfigImpl value, $Res Function(_$ThemeConfigImpl) then) =
      __$$ThemeConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ThemeMode themeMode,
      double fontSizeMultiplier,
      bool isCompactMode,
      Color? primaryColorSeed,
      bool useMaterial3,
      String? customThemeName});
}

/// @nodoc
class __$$ThemeConfigImplCopyWithImpl<$Res>
    extends _$ThemeConfigCopyWithImpl<$Res, _$ThemeConfigImpl>
    implements _$$ThemeConfigImplCopyWith<$Res> {
  __$$ThemeConfigImplCopyWithImpl(
      _$ThemeConfigImpl _value, $Res Function(_$ThemeConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of ThemeConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? fontSizeMultiplier = null,
    Object? isCompactMode = null,
    Object? primaryColorSeed = freezed,
    Object? useMaterial3 = null,
    Object? customThemeName = freezed,
  }) {
    return _then(_$ThemeConfigImpl(
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      fontSizeMultiplier: null == fontSizeMultiplier
          ? _value.fontSizeMultiplier
          : fontSizeMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      isCompactMode: null == isCompactMode
          ? _value.isCompactMode
          : isCompactMode // ignore: cast_nullable_to_non_nullable
              as bool,
      primaryColorSeed: freezed == primaryColorSeed
          ? _value.primaryColorSeed
          : primaryColorSeed // ignore: cast_nullable_to_non_nullable
              as Color?,
      useMaterial3: null == useMaterial3
          ? _value.useMaterial3
          : useMaterial3 // ignore: cast_nullable_to_non_nullable
              as bool,
      customThemeName: freezed == customThemeName
          ? _value.customThemeName
          : customThemeName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ThemeConfigImpl implements _ThemeConfig {
  const _$ThemeConfigImpl(
      {this.themeMode = ThemeMode.system,
      this.fontSizeMultiplier = 1.0,
      this.isCompactMode = false,
      this.primaryColorSeed = null,
      this.useMaterial3 = true,
      this.customThemeName = null});

  /// Current theme mode
  @override
  @JsonKey()
  final ThemeMode themeMode;

  /// Font size multiplier
  @override
  @JsonKey()
  final double fontSizeMultiplier;

  /// Whether to use compact mode
  @override
  @JsonKey()
  final bool isCompactMode;

  /// Primary color seed
  @override
  @JsonKey()
  final Color? primaryColorSeed;

  /// Whether to use material 3 design
  @override
  @JsonKey()
  final bool useMaterial3;

  /// Custom theme name
  @override
  @JsonKey()
  final String? customThemeName;

  @override
  String toString() {
    return 'ThemeConfig(themeMode: $themeMode, fontSizeMultiplier: $fontSizeMultiplier, isCompactMode: $isCompactMode, primaryColorSeed: $primaryColorSeed, useMaterial3: $useMaterial3, customThemeName: $customThemeName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ThemeConfigImpl &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.fontSizeMultiplier, fontSizeMultiplier) ||
                other.fontSizeMultiplier == fontSizeMultiplier) &&
            (identical(other.isCompactMode, isCompactMode) ||
                other.isCompactMode == isCompactMode) &&
            (identical(other.primaryColorSeed, primaryColorSeed) ||
                other.primaryColorSeed == primaryColorSeed) &&
            (identical(other.useMaterial3, useMaterial3) ||
                other.useMaterial3 == useMaterial3) &&
            (identical(other.customThemeName, customThemeName) ||
                other.customThemeName == customThemeName));
  }

  @override
  int get hashCode => Object.hash(runtimeType, themeMode, fontSizeMultiplier,
      isCompactMode, primaryColorSeed, useMaterial3, customThemeName);

  /// Create a copy of ThemeConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ThemeConfigImplCopyWith<_$ThemeConfigImpl> get copyWith =>
      __$$ThemeConfigImplCopyWithImpl<_$ThemeConfigImpl>(this, _$identity);
}

abstract class _ThemeConfig implements ThemeConfig {
  const factory _ThemeConfig(
      {final ThemeMode themeMode,
      final double fontSizeMultiplier,
      final bool isCompactMode,
      final Color? primaryColorSeed,
      final bool useMaterial3,
      final String? customThemeName}) = _$ThemeConfigImpl;

  /// Current theme mode
  @override
  ThemeMode get themeMode;

  /// Font size multiplier
  @override
  double get fontSizeMultiplier;

  /// Whether to use compact mode
  @override
  bool get isCompactMode;

  /// Primary color seed
  @override
  Color? get primaryColorSeed;

  /// Whether to use material 3 design
  @override
  bool get useMaterial3;

  /// Custom theme name
  @override
  String? get customThemeName;

  /// Create a copy of ThemeConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ThemeConfigImplCopyWith<_$ThemeConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$LayoutConfig {
  /// Sidebar width
  double get sidebarWidth => throw _privateConstructorUsedError;

  /// Whether sidebar is collapsible
  bool get sidebarCollapsible => throw _privateConstructorUsedError;

  /// Chat area max width
  double get chatMaxWidth => throw _privateConstructorUsedError;

  /// Message bubble max width percentage
  double get messageBubbleMaxWidthPercent => throw _privateConstructorUsedError;

  /// Whether to show message avatars
  bool get showMessageAvatars => throw _privateConstructorUsedError;

  /// Whether to show message timestamps
  bool get showMessageTimestamps => throw _privateConstructorUsedError;

  /// Message spacing
  double get messageSpacing => throw _privateConstructorUsedError;

  /// Create a copy of LayoutConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LayoutConfigCopyWith<LayoutConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LayoutConfigCopyWith<$Res> {
  factory $LayoutConfigCopyWith(
          LayoutConfig value, $Res Function(LayoutConfig) then) =
      _$LayoutConfigCopyWithImpl<$Res, LayoutConfig>;
  @useResult
  $Res call(
      {double sidebarWidth,
      bool sidebarCollapsible,
      double chatMaxWidth,
      double messageBubbleMaxWidthPercent,
      bool showMessageAvatars,
      bool showMessageTimestamps,
      double messageSpacing});
}

/// @nodoc
class _$LayoutConfigCopyWithImpl<$Res, $Val extends LayoutConfig>
    implements $LayoutConfigCopyWith<$Res> {
  _$LayoutConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LayoutConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sidebarWidth = null,
    Object? sidebarCollapsible = null,
    Object? chatMaxWidth = null,
    Object? messageBubbleMaxWidthPercent = null,
    Object? showMessageAvatars = null,
    Object? showMessageTimestamps = null,
    Object? messageSpacing = null,
  }) {
    return _then(_value.copyWith(
      sidebarWidth: null == sidebarWidth
          ? _value.sidebarWidth
          : sidebarWidth // ignore: cast_nullable_to_non_nullable
              as double,
      sidebarCollapsible: null == sidebarCollapsible
          ? _value.sidebarCollapsible
          : sidebarCollapsible // ignore: cast_nullable_to_non_nullable
              as bool,
      chatMaxWidth: null == chatMaxWidth
          ? _value.chatMaxWidth
          : chatMaxWidth // ignore: cast_nullable_to_non_nullable
              as double,
      messageBubbleMaxWidthPercent: null == messageBubbleMaxWidthPercent
          ? _value.messageBubbleMaxWidthPercent
          : messageBubbleMaxWidthPercent // ignore: cast_nullable_to_non_nullable
              as double,
      showMessageAvatars: null == showMessageAvatars
          ? _value.showMessageAvatars
          : showMessageAvatars // ignore: cast_nullable_to_non_nullable
              as bool,
      showMessageTimestamps: null == showMessageTimestamps
          ? _value.showMessageTimestamps
          : showMessageTimestamps // ignore: cast_nullable_to_non_nullable
              as bool,
      messageSpacing: null == messageSpacing
          ? _value.messageSpacing
          : messageSpacing // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LayoutConfigImplCopyWith<$Res>
    implements $LayoutConfigCopyWith<$Res> {
  factory _$$LayoutConfigImplCopyWith(
          _$LayoutConfigImpl value, $Res Function(_$LayoutConfigImpl) then) =
      __$$LayoutConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double sidebarWidth,
      bool sidebarCollapsible,
      double chatMaxWidth,
      double messageBubbleMaxWidthPercent,
      bool showMessageAvatars,
      bool showMessageTimestamps,
      double messageSpacing});
}

/// @nodoc
class __$$LayoutConfigImplCopyWithImpl<$Res>
    extends _$LayoutConfigCopyWithImpl<$Res, _$LayoutConfigImpl>
    implements _$$LayoutConfigImplCopyWith<$Res> {
  __$$LayoutConfigImplCopyWithImpl(
      _$LayoutConfigImpl _value, $Res Function(_$LayoutConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of LayoutConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sidebarWidth = null,
    Object? sidebarCollapsible = null,
    Object? chatMaxWidth = null,
    Object? messageBubbleMaxWidthPercent = null,
    Object? showMessageAvatars = null,
    Object? showMessageTimestamps = null,
    Object? messageSpacing = null,
  }) {
    return _then(_$LayoutConfigImpl(
      sidebarWidth: null == sidebarWidth
          ? _value.sidebarWidth
          : sidebarWidth // ignore: cast_nullable_to_non_nullable
              as double,
      sidebarCollapsible: null == sidebarCollapsible
          ? _value.sidebarCollapsible
          : sidebarCollapsible // ignore: cast_nullable_to_non_nullable
              as bool,
      chatMaxWidth: null == chatMaxWidth
          ? _value.chatMaxWidth
          : chatMaxWidth // ignore: cast_nullable_to_non_nullable
              as double,
      messageBubbleMaxWidthPercent: null == messageBubbleMaxWidthPercent
          ? _value.messageBubbleMaxWidthPercent
          : messageBubbleMaxWidthPercent // ignore: cast_nullable_to_non_nullable
              as double,
      showMessageAvatars: null == showMessageAvatars
          ? _value.showMessageAvatars
          : showMessageAvatars // ignore: cast_nullable_to_non_nullable
              as bool,
      showMessageTimestamps: null == showMessageTimestamps
          ? _value.showMessageTimestamps
          : showMessageTimestamps // ignore: cast_nullable_to_non_nullable
              as bool,
      messageSpacing: null == messageSpacing
          ? _value.messageSpacing
          : messageSpacing // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$LayoutConfigImpl implements _LayoutConfig {
  const _$LayoutConfigImpl(
      {this.sidebarWidth = 280.0,
      this.sidebarCollapsible = true,
      this.chatMaxWidth = 800.0,
      this.messageBubbleMaxWidthPercent = 0.8,
      this.showMessageAvatars = true,
      this.showMessageTimestamps = true,
      this.messageSpacing = 8.0});

  /// Sidebar width
  @override
  @JsonKey()
  final double sidebarWidth;

  /// Whether sidebar is collapsible
  @override
  @JsonKey()
  final bool sidebarCollapsible;

  /// Chat area max width
  @override
  @JsonKey()
  final double chatMaxWidth;

  /// Message bubble max width percentage
  @override
  @JsonKey()
  final double messageBubbleMaxWidthPercent;

  /// Whether to show message avatars
  @override
  @JsonKey()
  final bool showMessageAvatars;

  /// Whether to show message timestamps
  @override
  @JsonKey()
  final bool showMessageTimestamps;

  /// Message spacing
  @override
  @JsonKey()
  final double messageSpacing;

  @override
  String toString() {
    return 'LayoutConfig(sidebarWidth: $sidebarWidth, sidebarCollapsible: $sidebarCollapsible, chatMaxWidth: $chatMaxWidth, messageBubbleMaxWidthPercent: $messageBubbleMaxWidthPercent, showMessageAvatars: $showMessageAvatars, showMessageTimestamps: $showMessageTimestamps, messageSpacing: $messageSpacing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LayoutConfigImpl &&
            (identical(other.sidebarWidth, sidebarWidth) ||
                other.sidebarWidth == sidebarWidth) &&
            (identical(other.sidebarCollapsible, sidebarCollapsible) ||
                other.sidebarCollapsible == sidebarCollapsible) &&
            (identical(other.chatMaxWidth, chatMaxWidth) ||
                other.chatMaxWidth == chatMaxWidth) &&
            (identical(other.messageBubbleMaxWidthPercent,
                    messageBubbleMaxWidthPercent) ||
                other.messageBubbleMaxWidthPercent ==
                    messageBubbleMaxWidthPercent) &&
            (identical(other.showMessageAvatars, showMessageAvatars) ||
                other.showMessageAvatars == showMessageAvatars) &&
            (identical(other.showMessageTimestamps, showMessageTimestamps) ||
                other.showMessageTimestamps == showMessageTimestamps) &&
            (identical(other.messageSpacing, messageSpacing) ||
                other.messageSpacing == messageSpacing));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      sidebarWidth,
      sidebarCollapsible,
      chatMaxWidth,
      messageBubbleMaxWidthPercent,
      showMessageAvatars,
      showMessageTimestamps,
      messageSpacing);

  /// Create a copy of LayoutConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LayoutConfigImplCopyWith<_$LayoutConfigImpl> get copyWith =>
      __$$LayoutConfigImplCopyWithImpl<_$LayoutConfigImpl>(this, _$identity);
}

abstract class _LayoutConfig implements LayoutConfig {
  const factory _LayoutConfig(
      {final double sidebarWidth,
      final bool sidebarCollapsible,
      final double chatMaxWidth,
      final double messageBubbleMaxWidthPercent,
      final bool showMessageAvatars,
      final bool showMessageTimestamps,
      final double messageSpacing}) = _$LayoutConfigImpl;

  /// Sidebar width
  @override
  double get sidebarWidth;

  /// Whether sidebar is collapsible
  @override
  bool get sidebarCollapsible;

  /// Chat area max width
  @override
  double get chatMaxWidth;

  /// Message bubble max width percentage
  @override
  double get messageBubbleMaxWidthPercent;

  /// Whether to show message avatars
  @override
  bool get showMessageAvatars;

  /// Whether to show message timestamps
  @override
  bool get showMessageTimestamps;

  /// Message spacing
  @override
  double get messageSpacing;

  /// Create a copy of LayoutConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LayoutConfigImplCopyWith<_$LayoutConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AnimationConfig {
  /// Whether animations are enabled
  bool get enabled => throw _privateConstructorUsedError;

  /// Animation duration multiplier
  double get durationMultiplier => throw _privateConstructorUsedError;

  /// Whether to use reduced motion
  bool get useReducedMotion => throw _privateConstructorUsedError;

  /// Page transition type
  PageTransitionType get pageTransitionType =>
      throw _privateConstructorUsedError;

  /// Message animation type
  MessageAnimationType get messageAnimationType =>
      throw _privateConstructorUsedError;

  /// Create a copy of AnimationConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnimationConfigCopyWith<AnimationConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnimationConfigCopyWith<$Res> {
  factory $AnimationConfigCopyWith(
          AnimationConfig value, $Res Function(AnimationConfig) then) =
      _$AnimationConfigCopyWithImpl<$Res, AnimationConfig>;
  @useResult
  $Res call(
      {bool enabled,
      double durationMultiplier,
      bool useReducedMotion,
      PageTransitionType pageTransitionType,
      MessageAnimationType messageAnimationType});
}

/// @nodoc
class _$AnimationConfigCopyWithImpl<$Res, $Val extends AnimationConfig>
    implements $AnimationConfigCopyWith<$Res> {
  _$AnimationConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnimationConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? durationMultiplier = null,
    Object? useReducedMotion = null,
    Object? pageTransitionType = null,
    Object? messageAnimationType = null,
  }) {
    return _then(_value.copyWith(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      durationMultiplier: null == durationMultiplier
          ? _value.durationMultiplier
          : durationMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      useReducedMotion: null == useReducedMotion
          ? _value.useReducedMotion
          : useReducedMotion // ignore: cast_nullable_to_non_nullable
              as bool,
      pageTransitionType: null == pageTransitionType
          ? _value.pageTransitionType
          : pageTransitionType // ignore: cast_nullable_to_non_nullable
              as PageTransitionType,
      messageAnimationType: null == messageAnimationType
          ? _value.messageAnimationType
          : messageAnimationType // ignore: cast_nullable_to_non_nullable
              as MessageAnimationType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnimationConfigImplCopyWith<$Res>
    implements $AnimationConfigCopyWith<$Res> {
  factory _$$AnimationConfigImplCopyWith(_$AnimationConfigImpl value,
          $Res Function(_$AnimationConfigImpl) then) =
      __$$AnimationConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enabled,
      double durationMultiplier,
      bool useReducedMotion,
      PageTransitionType pageTransitionType,
      MessageAnimationType messageAnimationType});
}

/// @nodoc
class __$$AnimationConfigImplCopyWithImpl<$Res>
    extends _$AnimationConfigCopyWithImpl<$Res, _$AnimationConfigImpl>
    implements _$$AnimationConfigImplCopyWith<$Res> {
  __$$AnimationConfigImplCopyWithImpl(
      _$AnimationConfigImpl _value, $Res Function(_$AnimationConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnimationConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? durationMultiplier = null,
    Object? useReducedMotion = null,
    Object? pageTransitionType = null,
    Object? messageAnimationType = null,
  }) {
    return _then(_$AnimationConfigImpl(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      durationMultiplier: null == durationMultiplier
          ? _value.durationMultiplier
          : durationMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      useReducedMotion: null == useReducedMotion
          ? _value.useReducedMotion
          : useReducedMotion // ignore: cast_nullable_to_non_nullable
              as bool,
      pageTransitionType: null == pageTransitionType
          ? _value.pageTransitionType
          : pageTransitionType // ignore: cast_nullable_to_non_nullable
              as PageTransitionType,
      messageAnimationType: null == messageAnimationType
          ? _value.messageAnimationType
          : messageAnimationType // ignore: cast_nullable_to_non_nullable
              as MessageAnimationType,
    ));
  }
}

/// @nodoc

class _$AnimationConfigImpl implements _AnimationConfig {
  const _$AnimationConfigImpl(
      {this.enabled = true,
      this.durationMultiplier = 1.0,
      this.useReducedMotion = false,
      this.pageTransitionType = PageTransitionType.slide,
      this.messageAnimationType = MessageAnimationType.fadeIn});

  /// Whether animations are enabled
  @override
  @JsonKey()
  final bool enabled;

  /// Animation duration multiplier
  @override
  @JsonKey()
  final double durationMultiplier;

  /// Whether to use reduced motion
  @override
  @JsonKey()
  final bool useReducedMotion;

  /// Page transition type
  @override
  @JsonKey()
  final PageTransitionType pageTransitionType;

  /// Message animation type
  @override
  @JsonKey()
  final MessageAnimationType messageAnimationType;

  @override
  String toString() {
    return 'AnimationConfig(enabled: $enabled, durationMultiplier: $durationMultiplier, useReducedMotion: $useReducedMotion, pageTransitionType: $pageTransitionType, messageAnimationType: $messageAnimationType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnimationConfigImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.durationMultiplier, durationMultiplier) ||
                other.durationMultiplier == durationMultiplier) &&
            (identical(other.useReducedMotion, useReducedMotion) ||
                other.useReducedMotion == useReducedMotion) &&
            (identical(other.pageTransitionType, pageTransitionType) ||
                other.pageTransitionType == pageTransitionType) &&
            (identical(other.messageAnimationType, messageAnimationType) ||
                other.messageAnimationType == messageAnimationType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, enabled, durationMultiplier,
      useReducedMotion, pageTransitionType, messageAnimationType);

  /// Create a copy of AnimationConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnimationConfigImplCopyWith<_$AnimationConfigImpl> get copyWith =>
      __$$AnimationConfigImplCopyWithImpl<_$AnimationConfigImpl>(
          this, _$identity);
}

abstract class _AnimationConfig implements AnimationConfig {
  const factory _AnimationConfig(
      {final bool enabled,
      final double durationMultiplier,
      final bool useReducedMotion,
      final PageTransitionType pageTransitionType,
      final MessageAnimationType messageAnimationType}) = _$AnimationConfigImpl;

  /// Whether animations are enabled
  @override
  bool get enabled;

  /// Animation duration multiplier
  @override
  double get durationMultiplier;

  /// Whether to use reduced motion
  @override
  bool get useReducedMotion;

  /// Page transition type
  @override
  PageTransitionType get pageTransitionType;

  /// Message animation type
  @override
  MessageAnimationType get messageAnimationType;

  /// Create a copy of AnimationConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnimationConfigImplCopyWith<_$AnimationConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UIState {
// === Scroll Management ===
  /// Current scroll position
  double get scrollPosition => throw _privateConstructorUsedError;

  /// Whether auto-scroll is enabled
  bool get shouldAutoScroll => throw _privateConstructorUsedError;

  /// Target message ID to scroll to
  String? get scrollToMessageId => throw _privateConstructorUsedError;

  /// Scroll configuration
  ScrollConfig get scrollConfig =>
      throw _privateConstructorUsedError; // === Virtual Scrolling ===
  /// Visible range start index
  int get visibleStartIndex => throw _privateConstructorUsedError;

  /// Visible range end index
  int get visibleEndIndex => throw _privateConstructorUsedError;

  /// Item heights cache (messageId -> height)
  Map<String, double> get itemHeights => throw _privateConstructorUsedError;

  /// Virtual scroll configuration
  VirtualScrollConfig get virtualScrollConfig =>
      throw _privateConstructorUsedError; // === Pagination ===
  /// Whether more content is being loaded
  bool get isLoadingMore => throw _privateConstructorUsedError;

  /// Whether there's more content to load
  bool get hasMore => throw _privateConstructorUsedError;

  /// Current page size
  int get currentPageSize => throw _privateConstructorUsedError;

  /// Pagination configuration
  PaginationConfig get paginationConfig =>
      throw _privateConstructorUsedError; // === Theme and Appearance ===
  /// Theme configuration
  ThemeConfig get themeConfig => throw _privateConstructorUsedError;

  /// Layout configuration
  LayoutConfig get layoutConfig => throw _privateConstructorUsedError;

  /// Animation configuration
  AnimationConfig get animationConfig =>
      throw _privateConstructorUsedError; // === Window and Viewport ===
  /// Current viewport size
  Size? get viewportSize => throw _privateConstructorUsedError;

  /// Whether window is focused
  bool get isWindowFocused => throw _privateConstructorUsedError;

  /// Whether app is in foreground
  bool get isAppInForeground =>
      throw _privateConstructorUsedError; // === Input State ===
  /// Whether input field is focused
  bool get isInputFocused => throw _privateConstructorUsedError;

  /// Input field height
  double get inputHeight => throw _privateConstructorUsedError;

  /// Whether input is expanded (multiline)
  bool get isInputExpanded =>
      throw _privateConstructorUsedError; // === Loading and Progress ===
  /// Global loading state
  bool get isGlobalLoading => throw _privateConstructorUsedError;

  /// Loading message
  String? get loadingMessage => throw _privateConstructorUsedError;

  /// Progress value (0.0 to 1.0)
  double? get progressValue =>
      throw _privateConstructorUsedError; // === Error Display ===
  /// Whether error overlay is shown
  bool get showErrorOverlay => throw _privateConstructorUsedError;

  /// Error overlay message
  String? get errorOverlayMessage => throw _privateConstructorUsedError;

  /// Error overlay type
  ErrorOverlayType get errorOverlayType =>
      throw _privateConstructorUsedError; // === Responsive Design ===
  /// Current screen size category
  ScreenSize get screenSize => throw _privateConstructorUsedError;

  /// Whether in mobile layout
  bool get isMobileLayout => throw _privateConstructorUsedError;

  /// Whether in tablet layout
  bool get isTabletLayout => throw _privateConstructorUsedError;

  /// Whether in desktop layout
  bool get isDesktopLayout =>
      throw _privateConstructorUsedError; // === Performance Monitoring ===
  /// Frame rate (FPS)
  double get frameRate => throw _privateConstructorUsedError;

  /// Memory usage in MB
  double get memoryUsage => throw _privateConstructorUsedError;

  /// Whether performance overlay is shown
  bool get showPerformanceOverlay =>
      throw _privateConstructorUsedError; // === Accessibility ===
  /// Whether high contrast mode is enabled
  bool get highContrastMode => throw _privateConstructorUsedError;

  /// Whether large text mode is enabled
  bool get largeTextMode => throw _privateConstructorUsedError;

  /// Whether screen reader is active
  bool get screenReaderActive =>
      throw _privateConstructorUsedError; // === Last Update ===
  /// Last UI update timestamp
  DateTime? get lastUpdateTime => throw _privateConstructorUsedError;

  /// Create a copy of UIState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UIStateCopyWith<UIState> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UIStateCopyWith<$Res> {
  factory $UIStateCopyWith(UIState value, $Res Function(UIState) then) =
      _$UIStateCopyWithImpl<$Res, UIState>;
  @useResult
  $Res call(
      {double scrollPosition,
      bool shouldAutoScroll,
      String? scrollToMessageId,
      ScrollConfig scrollConfig,
      int visibleStartIndex,
      int visibleEndIndex,
      Map<String, double> itemHeights,
      VirtualScrollConfig virtualScrollConfig,
      bool isLoadingMore,
      bool hasMore,
      int currentPageSize,
      PaginationConfig paginationConfig,
      ThemeConfig themeConfig,
      LayoutConfig layoutConfig,
      AnimationConfig animationConfig,
      Size? viewportSize,
      bool isWindowFocused,
      bool isAppInForeground,
      bool isInputFocused,
      double inputHeight,
      bool isInputExpanded,
      bool isGlobalLoading,
      String? loadingMessage,
      double? progressValue,
      bool showErrorOverlay,
      String? errorOverlayMessage,
      ErrorOverlayType errorOverlayType,
      ScreenSize screenSize,
      bool isMobileLayout,
      bool isTabletLayout,
      bool isDesktopLayout,
      double frameRate,
      double memoryUsage,
      bool showPerformanceOverlay,
      bool highContrastMode,
      bool largeTextMode,
      bool screenReaderActive,
      DateTime? lastUpdateTime});

  $ScrollConfigCopyWith<$Res> get scrollConfig;
  $VirtualScrollConfigCopyWith<$Res> get virtualScrollConfig;
  $PaginationConfigCopyWith<$Res> get paginationConfig;
  $ThemeConfigCopyWith<$Res> get themeConfig;
  $LayoutConfigCopyWith<$Res> get layoutConfig;
  $AnimationConfigCopyWith<$Res> get animationConfig;
}

/// @nodoc
class _$UIStateCopyWithImpl<$Res, $Val extends UIState>
    implements $UIStateCopyWith<$Res> {
  _$UIStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UIState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scrollPosition = null,
    Object? shouldAutoScroll = null,
    Object? scrollToMessageId = freezed,
    Object? scrollConfig = null,
    Object? visibleStartIndex = null,
    Object? visibleEndIndex = null,
    Object? itemHeights = null,
    Object? virtualScrollConfig = null,
    Object? isLoadingMore = null,
    Object? hasMore = null,
    Object? currentPageSize = null,
    Object? paginationConfig = null,
    Object? themeConfig = null,
    Object? layoutConfig = null,
    Object? animationConfig = null,
    Object? viewportSize = freezed,
    Object? isWindowFocused = null,
    Object? isAppInForeground = null,
    Object? isInputFocused = null,
    Object? inputHeight = null,
    Object? isInputExpanded = null,
    Object? isGlobalLoading = null,
    Object? loadingMessage = freezed,
    Object? progressValue = freezed,
    Object? showErrorOverlay = null,
    Object? errorOverlayMessage = freezed,
    Object? errorOverlayType = null,
    Object? screenSize = null,
    Object? isMobileLayout = null,
    Object? isTabletLayout = null,
    Object? isDesktopLayout = null,
    Object? frameRate = null,
    Object? memoryUsage = null,
    Object? showPerformanceOverlay = null,
    Object? highContrastMode = null,
    Object? largeTextMode = null,
    Object? screenReaderActive = null,
    Object? lastUpdateTime = freezed,
  }) {
    return _then(_value.copyWith(
      scrollPosition: null == scrollPosition
          ? _value.scrollPosition
          : scrollPosition // ignore: cast_nullable_to_non_nullable
              as double,
      shouldAutoScroll: null == shouldAutoScroll
          ? _value.shouldAutoScroll
          : shouldAutoScroll // ignore: cast_nullable_to_non_nullable
              as bool,
      scrollToMessageId: freezed == scrollToMessageId
          ? _value.scrollToMessageId
          : scrollToMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      scrollConfig: null == scrollConfig
          ? _value.scrollConfig
          : scrollConfig // ignore: cast_nullable_to_non_nullable
              as ScrollConfig,
      visibleStartIndex: null == visibleStartIndex
          ? _value.visibleStartIndex
          : visibleStartIndex // ignore: cast_nullable_to_non_nullable
              as int,
      visibleEndIndex: null == visibleEndIndex
          ? _value.visibleEndIndex
          : visibleEndIndex // ignore: cast_nullable_to_non_nullable
              as int,
      itemHeights: null == itemHeights
          ? _value.itemHeights
          : itemHeights // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      virtualScrollConfig: null == virtualScrollConfig
          ? _value.virtualScrollConfig
          : virtualScrollConfig // ignore: cast_nullable_to_non_nullable
              as VirtualScrollConfig,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      currentPageSize: null == currentPageSize
          ? _value.currentPageSize
          : currentPageSize // ignore: cast_nullable_to_non_nullable
              as int,
      paginationConfig: null == paginationConfig
          ? _value.paginationConfig
          : paginationConfig // ignore: cast_nullable_to_non_nullable
              as PaginationConfig,
      themeConfig: null == themeConfig
          ? _value.themeConfig
          : themeConfig // ignore: cast_nullable_to_non_nullable
              as ThemeConfig,
      layoutConfig: null == layoutConfig
          ? _value.layoutConfig
          : layoutConfig // ignore: cast_nullable_to_non_nullable
              as LayoutConfig,
      animationConfig: null == animationConfig
          ? _value.animationConfig
          : animationConfig // ignore: cast_nullable_to_non_nullable
              as AnimationConfig,
      viewportSize: freezed == viewportSize
          ? _value.viewportSize
          : viewportSize // ignore: cast_nullable_to_non_nullable
              as Size?,
      isWindowFocused: null == isWindowFocused
          ? _value.isWindowFocused
          : isWindowFocused // ignore: cast_nullable_to_non_nullable
              as bool,
      isAppInForeground: null == isAppInForeground
          ? _value.isAppInForeground
          : isAppInForeground // ignore: cast_nullable_to_non_nullable
              as bool,
      isInputFocused: null == isInputFocused
          ? _value.isInputFocused
          : isInputFocused // ignore: cast_nullable_to_non_nullable
              as bool,
      inputHeight: null == inputHeight
          ? _value.inputHeight
          : inputHeight // ignore: cast_nullable_to_non_nullable
              as double,
      isInputExpanded: null == isInputExpanded
          ? _value.isInputExpanded
          : isInputExpanded // ignore: cast_nullable_to_non_nullable
              as bool,
      isGlobalLoading: null == isGlobalLoading
          ? _value.isGlobalLoading
          : isGlobalLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      loadingMessage: freezed == loadingMessage
          ? _value.loadingMessage
          : loadingMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      progressValue: freezed == progressValue
          ? _value.progressValue
          : progressValue // ignore: cast_nullable_to_non_nullable
              as double?,
      showErrorOverlay: null == showErrorOverlay
          ? _value.showErrorOverlay
          : showErrorOverlay // ignore: cast_nullable_to_non_nullable
              as bool,
      errorOverlayMessage: freezed == errorOverlayMessage
          ? _value.errorOverlayMessage
          : errorOverlayMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      errorOverlayType: null == errorOverlayType
          ? _value.errorOverlayType
          : errorOverlayType // ignore: cast_nullable_to_non_nullable
              as ErrorOverlayType,
      screenSize: null == screenSize
          ? _value.screenSize
          : screenSize // ignore: cast_nullable_to_non_nullable
              as ScreenSize,
      isMobileLayout: null == isMobileLayout
          ? _value.isMobileLayout
          : isMobileLayout // ignore: cast_nullable_to_non_nullable
              as bool,
      isTabletLayout: null == isTabletLayout
          ? _value.isTabletLayout
          : isTabletLayout // ignore: cast_nullable_to_non_nullable
              as bool,
      isDesktopLayout: null == isDesktopLayout
          ? _value.isDesktopLayout
          : isDesktopLayout // ignore: cast_nullable_to_non_nullable
              as bool,
      frameRate: null == frameRate
          ? _value.frameRate
          : frameRate // ignore: cast_nullable_to_non_nullable
              as double,
      memoryUsage: null == memoryUsage
          ? _value.memoryUsage
          : memoryUsage // ignore: cast_nullable_to_non_nullable
              as double,
      showPerformanceOverlay: null == showPerformanceOverlay
          ? _value.showPerformanceOverlay
          : showPerformanceOverlay // ignore: cast_nullable_to_non_nullable
              as bool,
      highContrastMode: null == highContrastMode
          ? _value.highContrastMode
          : highContrastMode // ignore: cast_nullable_to_non_nullable
              as bool,
      largeTextMode: null == largeTextMode
          ? _value.largeTextMode
          : largeTextMode // ignore: cast_nullable_to_non_nullable
              as bool,
      screenReaderActive: null == screenReaderActive
          ? _value.screenReaderActive
          : screenReaderActive // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUpdateTime: freezed == lastUpdateTime
          ? _value.lastUpdateTime
          : lastUpdateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of UIState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScrollConfigCopyWith<$Res> get scrollConfig {
    return $ScrollConfigCopyWith<$Res>(_value.scrollConfig, (value) {
      return _then(_value.copyWith(scrollConfig: value) as $Val);
    });
  }

  /// Create a copy of UIState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VirtualScrollConfigCopyWith<$Res> get virtualScrollConfig {
    return $VirtualScrollConfigCopyWith<$Res>(_value.virtualScrollConfig,
        (value) {
      return _then(_value.copyWith(virtualScrollConfig: value) as $Val);
    });
  }

  /// Create a copy of UIState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaginationConfigCopyWith<$Res> get paginationConfig {
    return $PaginationConfigCopyWith<$Res>(_value.paginationConfig, (value) {
      return _then(_value.copyWith(paginationConfig: value) as $Val);
    });
  }

  /// Create a copy of UIState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ThemeConfigCopyWith<$Res> get themeConfig {
    return $ThemeConfigCopyWith<$Res>(_value.themeConfig, (value) {
      return _then(_value.copyWith(themeConfig: value) as $Val);
    });
  }

  /// Create a copy of UIState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LayoutConfigCopyWith<$Res> get layoutConfig {
    return $LayoutConfigCopyWith<$Res>(_value.layoutConfig, (value) {
      return _then(_value.copyWith(layoutConfig: value) as $Val);
    });
  }

  /// Create a copy of UIState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AnimationConfigCopyWith<$Res> get animationConfig {
    return $AnimationConfigCopyWith<$Res>(_value.animationConfig, (value) {
      return _then(_value.copyWith(animationConfig: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UIStateImplCopyWith<$Res> implements $UIStateCopyWith<$Res> {
  factory _$$UIStateImplCopyWith(
          _$UIStateImpl value, $Res Function(_$UIStateImpl) then) =
      __$$UIStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double scrollPosition,
      bool shouldAutoScroll,
      String? scrollToMessageId,
      ScrollConfig scrollConfig,
      int visibleStartIndex,
      int visibleEndIndex,
      Map<String, double> itemHeights,
      VirtualScrollConfig virtualScrollConfig,
      bool isLoadingMore,
      bool hasMore,
      int currentPageSize,
      PaginationConfig paginationConfig,
      ThemeConfig themeConfig,
      LayoutConfig layoutConfig,
      AnimationConfig animationConfig,
      Size? viewportSize,
      bool isWindowFocused,
      bool isAppInForeground,
      bool isInputFocused,
      double inputHeight,
      bool isInputExpanded,
      bool isGlobalLoading,
      String? loadingMessage,
      double? progressValue,
      bool showErrorOverlay,
      String? errorOverlayMessage,
      ErrorOverlayType errorOverlayType,
      ScreenSize screenSize,
      bool isMobileLayout,
      bool isTabletLayout,
      bool isDesktopLayout,
      double frameRate,
      double memoryUsage,
      bool showPerformanceOverlay,
      bool highContrastMode,
      bool largeTextMode,
      bool screenReaderActive,
      DateTime? lastUpdateTime});

  @override
  $ScrollConfigCopyWith<$Res> get scrollConfig;
  @override
  $VirtualScrollConfigCopyWith<$Res> get virtualScrollConfig;
  @override
  $PaginationConfigCopyWith<$Res> get paginationConfig;
  @override
  $ThemeConfigCopyWith<$Res> get themeConfig;
  @override
  $LayoutConfigCopyWith<$Res> get layoutConfig;
  @override
  $AnimationConfigCopyWith<$Res> get animationConfig;
}

/// @nodoc
class __$$UIStateImplCopyWithImpl<$Res>
    extends _$UIStateCopyWithImpl<$Res, _$UIStateImpl>
    implements _$$UIStateImplCopyWith<$Res> {
  __$$UIStateImplCopyWithImpl(
      _$UIStateImpl _value, $Res Function(_$UIStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of UIState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scrollPosition = null,
    Object? shouldAutoScroll = null,
    Object? scrollToMessageId = freezed,
    Object? scrollConfig = null,
    Object? visibleStartIndex = null,
    Object? visibleEndIndex = null,
    Object? itemHeights = null,
    Object? virtualScrollConfig = null,
    Object? isLoadingMore = null,
    Object? hasMore = null,
    Object? currentPageSize = null,
    Object? paginationConfig = null,
    Object? themeConfig = null,
    Object? layoutConfig = null,
    Object? animationConfig = null,
    Object? viewportSize = freezed,
    Object? isWindowFocused = null,
    Object? isAppInForeground = null,
    Object? isInputFocused = null,
    Object? inputHeight = null,
    Object? isInputExpanded = null,
    Object? isGlobalLoading = null,
    Object? loadingMessage = freezed,
    Object? progressValue = freezed,
    Object? showErrorOverlay = null,
    Object? errorOverlayMessage = freezed,
    Object? errorOverlayType = null,
    Object? screenSize = null,
    Object? isMobileLayout = null,
    Object? isTabletLayout = null,
    Object? isDesktopLayout = null,
    Object? frameRate = null,
    Object? memoryUsage = null,
    Object? showPerformanceOverlay = null,
    Object? highContrastMode = null,
    Object? largeTextMode = null,
    Object? screenReaderActive = null,
    Object? lastUpdateTime = freezed,
  }) {
    return _then(_$UIStateImpl(
      scrollPosition: null == scrollPosition
          ? _value.scrollPosition
          : scrollPosition // ignore: cast_nullable_to_non_nullable
              as double,
      shouldAutoScroll: null == shouldAutoScroll
          ? _value.shouldAutoScroll
          : shouldAutoScroll // ignore: cast_nullable_to_non_nullable
              as bool,
      scrollToMessageId: freezed == scrollToMessageId
          ? _value.scrollToMessageId
          : scrollToMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      scrollConfig: null == scrollConfig
          ? _value.scrollConfig
          : scrollConfig // ignore: cast_nullable_to_non_nullable
              as ScrollConfig,
      visibleStartIndex: null == visibleStartIndex
          ? _value.visibleStartIndex
          : visibleStartIndex // ignore: cast_nullable_to_non_nullable
              as int,
      visibleEndIndex: null == visibleEndIndex
          ? _value.visibleEndIndex
          : visibleEndIndex // ignore: cast_nullable_to_non_nullable
              as int,
      itemHeights: null == itemHeights
          ? _value._itemHeights
          : itemHeights // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      virtualScrollConfig: null == virtualScrollConfig
          ? _value.virtualScrollConfig
          : virtualScrollConfig // ignore: cast_nullable_to_non_nullable
              as VirtualScrollConfig,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      currentPageSize: null == currentPageSize
          ? _value.currentPageSize
          : currentPageSize // ignore: cast_nullable_to_non_nullable
              as int,
      paginationConfig: null == paginationConfig
          ? _value.paginationConfig
          : paginationConfig // ignore: cast_nullable_to_non_nullable
              as PaginationConfig,
      themeConfig: null == themeConfig
          ? _value.themeConfig
          : themeConfig // ignore: cast_nullable_to_non_nullable
              as ThemeConfig,
      layoutConfig: null == layoutConfig
          ? _value.layoutConfig
          : layoutConfig // ignore: cast_nullable_to_non_nullable
              as LayoutConfig,
      animationConfig: null == animationConfig
          ? _value.animationConfig
          : animationConfig // ignore: cast_nullable_to_non_nullable
              as AnimationConfig,
      viewportSize: freezed == viewportSize
          ? _value.viewportSize
          : viewportSize // ignore: cast_nullable_to_non_nullable
              as Size?,
      isWindowFocused: null == isWindowFocused
          ? _value.isWindowFocused
          : isWindowFocused // ignore: cast_nullable_to_non_nullable
              as bool,
      isAppInForeground: null == isAppInForeground
          ? _value.isAppInForeground
          : isAppInForeground // ignore: cast_nullable_to_non_nullable
              as bool,
      isInputFocused: null == isInputFocused
          ? _value.isInputFocused
          : isInputFocused // ignore: cast_nullable_to_non_nullable
              as bool,
      inputHeight: null == inputHeight
          ? _value.inputHeight
          : inputHeight // ignore: cast_nullable_to_non_nullable
              as double,
      isInputExpanded: null == isInputExpanded
          ? _value.isInputExpanded
          : isInputExpanded // ignore: cast_nullable_to_non_nullable
              as bool,
      isGlobalLoading: null == isGlobalLoading
          ? _value.isGlobalLoading
          : isGlobalLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      loadingMessage: freezed == loadingMessage
          ? _value.loadingMessage
          : loadingMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      progressValue: freezed == progressValue
          ? _value.progressValue
          : progressValue // ignore: cast_nullable_to_non_nullable
              as double?,
      showErrorOverlay: null == showErrorOverlay
          ? _value.showErrorOverlay
          : showErrorOverlay // ignore: cast_nullable_to_non_nullable
              as bool,
      errorOverlayMessage: freezed == errorOverlayMessage
          ? _value.errorOverlayMessage
          : errorOverlayMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      errorOverlayType: null == errorOverlayType
          ? _value.errorOverlayType
          : errorOverlayType // ignore: cast_nullable_to_non_nullable
              as ErrorOverlayType,
      screenSize: null == screenSize
          ? _value.screenSize
          : screenSize // ignore: cast_nullable_to_non_nullable
              as ScreenSize,
      isMobileLayout: null == isMobileLayout
          ? _value.isMobileLayout
          : isMobileLayout // ignore: cast_nullable_to_non_nullable
              as bool,
      isTabletLayout: null == isTabletLayout
          ? _value.isTabletLayout
          : isTabletLayout // ignore: cast_nullable_to_non_nullable
              as bool,
      isDesktopLayout: null == isDesktopLayout
          ? _value.isDesktopLayout
          : isDesktopLayout // ignore: cast_nullable_to_non_nullable
              as bool,
      frameRate: null == frameRate
          ? _value.frameRate
          : frameRate // ignore: cast_nullable_to_non_nullable
              as double,
      memoryUsage: null == memoryUsage
          ? _value.memoryUsage
          : memoryUsage // ignore: cast_nullable_to_non_nullable
              as double,
      showPerformanceOverlay: null == showPerformanceOverlay
          ? _value.showPerformanceOverlay
          : showPerformanceOverlay // ignore: cast_nullable_to_non_nullable
              as bool,
      highContrastMode: null == highContrastMode
          ? _value.highContrastMode
          : highContrastMode // ignore: cast_nullable_to_non_nullable
              as bool,
      largeTextMode: null == largeTextMode
          ? _value.largeTextMode
          : largeTextMode // ignore: cast_nullable_to_non_nullable
              as bool,
      screenReaderActive: null == screenReaderActive
          ? _value.screenReaderActive
          : screenReaderActive // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUpdateTime: freezed == lastUpdateTime
          ? _value.lastUpdateTime
          : lastUpdateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$UIStateImpl extends _UIState {
  const _$UIStateImpl(
      {this.scrollPosition = 0.0,
      this.shouldAutoScroll = true,
      this.scrollToMessageId = null,
      this.scrollConfig = const ScrollConfig(),
      this.visibleStartIndex = 0,
      this.visibleEndIndex = 50,
      final Map<String, double> itemHeights = const {},
      this.virtualScrollConfig = const VirtualScrollConfig(),
      this.isLoadingMore = false,
      this.hasMore = true,
      this.currentPageSize = 20,
      this.paginationConfig = const PaginationConfig(),
      this.themeConfig = const ThemeConfig(),
      this.layoutConfig = const LayoutConfig(),
      this.animationConfig = const AnimationConfig(),
      this.viewportSize = null,
      this.isWindowFocused = true,
      this.isAppInForeground = true,
      this.isInputFocused = false,
      this.inputHeight = 56.0,
      this.isInputExpanded = false,
      this.isGlobalLoading = false,
      this.loadingMessage = null,
      this.progressValue = null,
      this.showErrorOverlay = false,
      this.errorOverlayMessage = null,
      this.errorOverlayType = ErrorOverlayType.general,
      this.screenSize = ScreenSize.desktop,
      this.isMobileLayout = false,
      this.isTabletLayout = false,
      this.isDesktopLayout = true,
      this.frameRate = 60.0,
      this.memoryUsage = 0.0,
      this.showPerformanceOverlay = false,
      this.highContrastMode = false,
      this.largeTextMode = false,
      this.screenReaderActive = false,
      this.lastUpdateTime = null})
      : _itemHeights = itemHeights,
        super._();

// === Scroll Management ===
  /// Current scroll position
  @override
  @JsonKey()
  final double scrollPosition;

  /// Whether auto-scroll is enabled
  @override
  @JsonKey()
  final bool shouldAutoScroll;

  /// Target message ID to scroll to
  @override
  @JsonKey()
  final String? scrollToMessageId;

  /// Scroll configuration
  @override
  @JsonKey()
  final ScrollConfig scrollConfig;
// === Virtual Scrolling ===
  /// Visible range start index
  @override
  @JsonKey()
  final int visibleStartIndex;

  /// Visible range end index
  @override
  @JsonKey()
  final int visibleEndIndex;

  /// Item heights cache (messageId -> height)
  final Map<String, double> _itemHeights;

  /// Item heights cache (messageId -> height)
  @override
  @JsonKey()
  Map<String, double> get itemHeights {
    if (_itemHeights is EqualUnmodifiableMapView) return _itemHeights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_itemHeights);
  }

  /// Virtual scroll configuration
  @override
  @JsonKey()
  final VirtualScrollConfig virtualScrollConfig;
// === Pagination ===
  /// Whether more content is being loaded
  @override
  @JsonKey()
  final bool isLoadingMore;

  /// Whether there's more content to load
  @override
  @JsonKey()
  final bool hasMore;

  /// Current page size
  @override
  @JsonKey()
  final int currentPageSize;

  /// Pagination configuration
  @override
  @JsonKey()
  final PaginationConfig paginationConfig;
// === Theme and Appearance ===
  /// Theme configuration
  @override
  @JsonKey()
  final ThemeConfig themeConfig;

  /// Layout configuration
  @override
  @JsonKey()
  final LayoutConfig layoutConfig;

  /// Animation configuration
  @override
  @JsonKey()
  final AnimationConfig animationConfig;
// === Window and Viewport ===
  /// Current viewport size
  @override
  @JsonKey()
  final Size? viewportSize;

  /// Whether window is focused
  @override
  @JsonKey()
  final bool isWindowFocused;

  /// Whether app is in foreground
  @override
  @JsonKey()
  final bool isAppInForeground;
// === Input State ===
  /// Whether input field is focused
  @override
  @JsonKey()
  final bool isInputFocused;

  /// Input field height
  @override
  @JsonKey()
  final double inputHeight;

  /// Whether input is expanded (multiline)
  @override
  @JsonKey()
  final bool isInputExpanded;
// === Loading and Progress ===
  /// Global loading state
  @override
  @JsonKey()
  final bool isGlobalLoading;

  /// Loading message
  @override
  @JsonKey()
  final String? loadingMessage;

  /// Progress value (0.0 to 1.0)
  @override
  @JsonKey()
  final double? progressValue;
// === Error Display ===
  /// Whether error overlay is shown
  @override
  @JsonKey()
  final bool showErrorOverlay;

  /// Error overlay message
  @override
  @JsonKey()
  final String? errorOverlayMessage;

  /// Error overlay type
  @override
  @JsonKey()
  final ErrorOverlayType errorOverlayType;
// === Responsive Design ===
  /// Current screen size category
  @override
  @JsonKey()
  final ScreenSize screenSize;

  /// Whether in mobile layout
  @override
  @JsonKey()
  final bool isMobileLayout;

  /// Whether in tablet layout
  @override
  @JsonKey()
  final bool isTabletLayout;

  /// Whether in desktop layout
  @override
  @JsonKey()
  final bool isDesktopLayout;
// === Performance Monitoring ===
  /// Frame rate (FPS)
  @override
  @JsonKey()
  final double frameRate;

  /// Memory usage in MB
  @override
  @JsonKey()
  final double memoryUsage;

  /// Whether performance overlay is shown
  @override
  @JsonKey()
  final bool showPerformanceOverlay;
// === Accessibility ===
  /// Whether high contrast mode is enabled
  @override
  @JsonKey()
  final bool highContrastMode;

  /// Whether large text mode is enabled
  @override
  @JsonKey()
  final bool largeTextMode;

  /// Whether screen reader is active
  @override
  @JsonKey()
  final bool screenReaderActive;
// === Last Update ===
  /// Last UI update timestamp
  @override
  @JsonKey()
  final DateTime? lastUpdateTime;

  @override
  String toString() {
    return 'UIState(scrollPosition: $scrollPosition, shouldAutoScroll: $shouldAutoScroll, scrollToMessageId: $scrollToMessageId, scrollConfig: $scrollConfig, visibleStartIndex: $visibleStartIndex, visibleEndIndex: $visibleEndIndex, itemHeights: $itemHeights, virtualScrollConfig: $virtualScrollConfig, isLoadingMore: $isLoadingMore, hasMore: $hasMore, currentPageSize: $currentPageSize, paginationConfig: $paginationConfig, themeConfig: $themeConfig, layoutConfig: $layoutConfig, animationConfig: $animationConfig, viewportSize: $viewportSize, isWindowFocused: $isWindowFocused, isAppInForeground: $isAppInForeground, isInputFocused: $isInputFocused, inputHeight: $inputHeight, isInputExpanded: $isInputExpanded, isGlobalLoading: $isGlobalLoading, loadingMessage: $loadingMessage, progressValue: $progressValue, showErrorOverlay: $showErrorOverlay, errorOverlayMessage: $errorOverlayMessage, errorOverlayType: $errorOverlayType, screenSize: $screenSize, isMobileLayout: $isMobileLayout, isTabletLayout: $isTabletLayout, isDesktopLayout: $isDesktopLayout, frameRate: $frameRate, memoryUsage: $memoryUsage, showPerformanceOverlay: $showPerformanceOverlay, highContrastMode: $highContrastMode, largeTextMode: $largeTextMode, screenReaderActive: $screenReaderActive, lastUpdateTime: $lastUpdateTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UIStateImpl &&
            (identical(other.scrollPosition, scrollPosition) ||
                other.scrollPosition == scrollPosition) &&
            (identical(other.shouldAutoScroll, shouldAutoScroll) ||
                other.shouldAutoScroll == shouldAutoScroll) &&
            (identical(other.scrollToMessageId, scrollToMessageId) ||
                other.scrollToMessageId == scrollToMessageId) &&
            (identical(other.scrollConfig, scrollConfig) ||
                other.scrollConfig == scrollConfig) &&
            (identical(other.visibleStartIndex, visibleStartIndex) ||
                other.visibleStartIndex == visibleStartIndex) &&
            (identical(other.visibleEndIndex, visibleEndIndex) ||
                other.visibleEndIndex == visibleEndIndex) &&
            const DeepCollectionEquality()
                .equals(other._itemHeights, _itemHeights) &&
            (identical(other.virtualScrollConfig, virtualScrollConfig) ||
                other.virtualScrollConfig == virtualScrollConfig) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.currentPageSize, currentPageSize) ||
                other.currentPageSize == currentPageSize) &&
            (identical(other.paginationConfig, paginationConfig) ||
                other.paginationConfig == paginationConfig) &&
            (identical(other.themeConfig, themeConfig) ||
                other.themeConfig == themeConfig) &&
            (identical(other.layoutConfig, layoutConfig) ||
                other.layoutConfig == layoutConfig) &&
            (identical(other.animationConfig, animationConfig) ||
                other.animationConfig == animationConfig) &&
            (identical(other.viewportSize, viewportSize) ||
                other.viewportSize == viewportSize) &&
            (identical(other.isWindowFocused, isWindowFocused) ||
                other.isWindowFocused == isWindowFocused) &&
            (identical(other.isAppInForeground, isAppInForeground) ||
                other.isAppInForeground == isAppInForeground) &&
            (identical(other.isInputFocused, isInputFocused) ||
                other.isInputFocused == isInputFocused) &&
            (identical(other.inputHeight, inputHeight) ||
                other.inputHeight == inputHeight) &&
            (identical(other.isInputExpanded, isInputExpanded) ||
                other.isInputExpanded == isInputExpanded) &&
            (identical(other.isGlobalLoading, isGlobalLoading) ||
                other.isGlobalLoading == isGlobalLoading) &&
            (identical(other.loadingMessage, loadingMessage) ||
                other.loadingMessage == loadingMessage) &&
            (identical(other.progressValue, progressValue) ||
                other.progressValue == progressValue) &&
            (identical(other.showErrorOverlay, showErrorOverlay) ||
                other.showErrorOverlay == showErrorOverlay) &&
            (identical(other.errorOverlayMessage, errorOverlayMessage) ||
                other.errorOverlayMessage == errorOverlayMessage) &&
            (identical(other.errorOverlayType, errorOverlayType) ||
                other.errorOverlayType == errorOverlayType) &&
            (identical(other.screenSize, screenSize) ||
                other.screenSize == screenSize) &&
            (identical(other.isMobileLayout, isMobileLayout) ||
                other.isMobileLayout == isMobileLayout) &&
            (identical(other.isTabletLayout, isTabletLayout) ||
                other.isTabletLayout == isTabletLayout) &&
            (identical(other.isDesktopLayout, isDesktopLayout) ||
                other.isDesktopLayout == isDesktopLayout) &&
            (identical(other.frameRate, frameRate) ||
                other.frameRate == frameRate) &&
            (identical(other.memoryUsage, memoryUsage) ||
                other.memoryUsage == memoryUsage) &&
            (identical(other.showPerformanceOverlay, showPerformanceOverlay) ||
                other.showPerformanceOverlay == showPerformanceOverlay) &&
            (identical(other.highContrastMode, highContrastMode) ||
                other.highContrastMode == highContrastMode) &&
            (identical(other.largeTextMode, largeTextMode) ||
                other.largeTextMode == largeTextMode) &&
            (identical(other.screenReaderActive, screenReaderActive) ||
                other.screenReaderActive == screenReaderActive) &&
            (identical(other.lastUpdateTime, lastUpdateTime) ||
                other.lastUpdateTime == lastUpdateTime));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        scrollPosition,
        shouldAutoScroll,
        scrollToMessageId,
        scrollConfig,
        visibleStartIndex,
        visibleEndIndex,
        const DeepCollectionEquality().hash(_itemHeights),
        virtualScrollConfig,
        isLoadingMore,
        hasMore,
        currentPageSize,
        paginationConfig,
        themeConfig,
        layoutConfig,
        animationConfig,
        viewportSize,
        isWindowFocused,
        isAppInForeground,
        isInputFocused,
        inputHeight,
        isInputExpanded,
        isGlobalLoading,
        loadingMessage,
        progressValue,
        showErrorOverlay,
        errorOverlayMessage,
        errorOverlayType,
        screenSize,
        isMobileLayout,
        isTabletLayout,
        isDesktopLayout,
        frameRate,
        memoryUsage,
        showPerformanceOverlay,
        highContrastMode,
        largeTextMode,
        screenReaderActive,
        lastUpdateTime
      ]);

  /// Create a copy of UIState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UIStateImplCopyWith<_$UIStateImpl> get copyWith =>
      __$$UIStateImplCopyWithImpl<_$UIStateImpl>(this, _$identity);
}

abstract class _UIState extends UIState {
  const factory _UIState(
      {final double scrollPosition,
      final bool shouldAutoScroll,
      final String? scrollToMessageId,
      final ScrollConfig scrollConfig,
      final int visibleStartIndex,
      final int visibleEndIndex,
      final Map<String, double> itemHeights,
      final VirtualScrollConfig virtualScrollConfig,
      final bool isLoadingMore,
      final bool hasMore,
      final int currentPageSize,
      final PaginationConfig paginationConfig,
      final ThemeConfig themeConfig,
      final LayoutConfig layoutConfig,
      final AnimationConfig animationConfig,
      final Size? viewportSize,
      final bool isWindowFocused,
      final bool isAppInForeground,
      final bool isInputFocused,
      final double inputHeight,
      final bool isInputExpanded,
      final bool isGlobalLoading,
      final String? loadingMessage,
      final double? progressValue,
      final bool showErrorOverlay,
      final String? errorOverlayMessage,
      final ErrorOverlayType errorOverlayType,
      final ScreenSize screenSize,
      final bool isMobileLayout,
      final bool isTabletLayout,
      final bool isDesktopLayout,
      final double frameRate,
      final double memoryUsage,
      final bool showPerformanceOverlay,
      final bool highContrastMode,
      final bool largeTextMode,
      final bool screenReaderActive,
      final DateTime? lastUpdateTime}) = _$UIStateImpl;
  const _UIState._() : super._();

// === Scroll Management ===
  /// Current scroll position
  @override
  double get scrollPosition;

  /// Whether auto-scroll is enabled
  @override
  bool get shouldAutoScroll;

  /// Target message ID to scroll to
  @override
  String? get scrollToMessageId;

  /// Scroll configuration
  @override
  ScrollConfig get scrollConfig; // === Virtual Scrolling ===
  /// Visible range start index
  @override
  int get visibleStartIndex;

  /// Visible range end index
  @override
  int get visibleEndIndex;

  /// Item heights cache (messageId -> height)
  @override
  Map<String, double> get itemHeights;

  /// Virtual scroll configuration
  @override
  VirtualScrollConfig get virtualScrollConfig; // === Pagination ===
  /// Whether more content is being loaded
  @override
  bool get isLoadingMore;

  /// Whether there's more content to load
  @override
  bool get hasMore;

  /// Current page size
  @override
  int get currentPageSize;

  /// Pagination configuration
  @override
  PaginationConfig get paginationConfig; // === Theme and Appearance ===
  /// Theme configuration
  @override
  ThemeConfig get themeConfig;

  /// Layout configuration
  @override
  LayoutConfig get layoutConfig;

  /// Animation configuration
  @override
  AnimationConfig get animationConfig; // === Window and Viewport ===
  /// Current viewport size
  @override
  Size? get viewportSize;

  /// Whether window is focused
  @override
  bool get isWindowFocused;

  /// Whether app is in foreground
  @override
  bool get isAppInForeground; // === Input State ===
  /// Whether input field is focused
  @override
  bool get isInputFocused;

  /// Input field height
  @override
  double get inputHeight;

  /// Whether input is expanded (multiline)
  @override
  bool get isInputExpanded; // === Loading and Progress ===
  /// Global loading state
  @override
  bool get isGlobalLoading;

  /// Loading message
  @override
  String? get loadingMessage;

  /// Progress value (0.0 to 1.0)
  @override
  double? get progressValue; // === Error Display ===
  /// Whether error overlay is shown
  @override
  bool get showErrorOverlay;

  /// Error overlay message
  @override
  String? get errorOverlayMessage;

  /// Error overlay type
  @override
  ErrorOverlayType get errorOverlayType; // === Responsive Design ===
  /// Current screen size category
  @override
  ScreenSize get screenSize;

  /// Whether in mobile layout
  @override
  bool get isMobileLayout;

  /// Whether in tablet layout
  @override
  bool get isTabletLayout;

  /// Whether in desktop layout
  @override
  bool get isDesktopLayout; // === Performance Monitoring ===
  /// Frame rate (FPS)
  @override
  double get frameRate;

  /// Memory usage in MB
  @override
  double get memoryUsage;

  /// Whether performance overlay is shown
  @override
  bool get showPerformanceOverlay; // === Accessibility ===
  /// Whether high contrast mode is enabled
  @override
  bool get highContrastMode;

  /// Whether large text mode is enabled
  @override
  bool get largeTextMode;

  /// Whether screen reader is active
  @override
  bool get screenReaderActive; // === Last Update ===
  /// Last UI update timestamp
  @override
  DateTime? get lastUpdateTime;

  /// Create a copy of UIState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UIStateImplCopyWith<_$UIStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
