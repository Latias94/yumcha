// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChatConfig {
  /// Maximum number of messages to keep in memory
  int get maxMessages => throw _privateConstructorUsedError;

  /// Whether to use streaming responses
  bool get useStreaming => throw _privateConstructorUsedError;

  /// Whether to auto-scroll to new messages
  bool get autoScroll => throw _privateConstructorUsedError;

  /// Message display settings
  MessageDisplayConfig get displayConfig => throw _privateConstructorUsedError;

  /// Performance settings
  PerformanceConfig get performanceConfig => throw _privateConstructorUsedError;

  /// Create a copy of ChatConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatConfigCopyWith<ChatConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatConfigCopyWith<$Res> {
  factory $ChatConfigCopyWith(
          ChatConfig value, $Res Function(ChatConfig) then) =
      _$ChatConfigCopyWithImpl<$Res, ChatConfig>;
  @useResult
  $Res call(
      {int maxMessages,
      bool useStreaming,
      bool autoScroll,
      MessageDisplayConfig displayConfig,
      PerformanceConfig performanceConfig});

  $MessageDisplayConfigCopyWith<$Res> get displayConfig;
  $PerformanceConfigCopyWith<$Res> get performanceConfig;
}

/// @nodoc
class _$ChatConfigCopyWithImpl<$Res, $Val extends ChatConfig>
    implements $ChatConfigCopyWith<$Res> {
  _$ChatConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxMessages = null,
    Object? useStreaming = null,
    Object? autoScroll = null,
    Object? displayConfig = null,
    Object? performanceConfig = null,
  }) {
    return _then(_value.copyWith(
      maxMessages: null == maxMessages
          ? _value.maxMessages
          : maxMessages // ignore: cast_nullable_to_non_nullable
              as int,
      useStreaming: null == useStreaming
          ? _value.useStreaming
          : useStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      autoScroll: null == autoScroll
          ? _value.autoScroll
          : autoScroll // ignore: cast_nullable_to_non_nullable
              as bool,
      displayConfig: null == displayConfig
          ? _value.displayConfig
          : displayConfig // ignore: cast_nullable_to_non_nullable
              as MessageDisplayConfig,
      performanceConfig: null == performanceConfig
          ? _value.performanceConfig
          : performanceConfig // ignore: cast_nullable_to_non_nullable
              as PerformanceConfig,
    ) as $Val);
  }

  /// Create a copy of ChatConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MessageDisplayConfigCopyWith<$Res> get displayConfig {
    return $MessageDisplayConfigCopyWith<$Res>(_value.displayConfig, (value) {
      return _then(_value.copyWith(displayConfig: value) as $Val);
    });
  }

  /// Create a copy of ChatConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PerformanceConfigCopyWith<$Res> get performanceConfig {
    return $PerformanceConfigCopyWith<$Res>(_value.performanceConfig, (value) {
      return _then(_value.copyWith(performanceConfig: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatConfigImplCopyWith<$Res>
    implements $ChatConfigCopyWith<$Res> {
  factory _$$ChatConfigImplCopyWith(
          _$ChatConfigImpl value, $Res Function(_$ChatConfigImpl) then) =
      __$$ChatConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int maxMessages,
      bool useStreaming,
      bool autoScroll,
      MessageDisplayConfig displayConfig,
      PerformanceConfig performanceConfig});

  @override
  $MessageDisplayConfigCopyWith<$Res> get displayConfig;
  @override
  $PerformanceConfigCopyWith<$Res> get performanceConfig;
}

/// @nodoc
class __$$ChatConfigImplCopyWithImpl<$Res>
    extends _$ChatConfigCopyWithImpl<$Res, _$ChatConfigImpl>
    implements _$$ChatConfigImplCopyWith<$Res> {
  __$$ChatConfigImplCopyWithImpl(
      _$ChatConfigImpl _value, $Res Function(_$ChatConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxMessages = null,
    Object? useStreaming = null,
    Object? autoScroll = null,
    Object? displayConfig = null,
    Object? performanceConfig = null,
  }) {
    return _then(_$ChatConfigImpl(
      maxMessages: null == maxMessages
          ? _value.maxMessages
          : maxMessages // ignore: cast_nullable_to_non_nullable
              as int,
      useStreaming: null == useStreaming
          ? _value.useStreaming
          : useStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      autoScroll: null == autoScroll
          ? _value.autoScroll
          : autoScroll // ignore: cast_nullable_to_non_nullable
              as bool,
      displayConfig: null == displayConfig
          ? _value.displayConfig
          : displayConfig // ignore: cast_nullable_to_non_nullable
              as MessageDisplayConfig,
      performanceConfig: null == performanceConfig
          ? _value.performanceConfig
          : performanceConfig // ignore: cast_nullable_to_non_nullable
              as PerformanceConfig,
    ));
  }
}

/// @nodoc

class _$ChatConfigImpl implements _ChatConfig {
  const _$ChatConfigImpl(
      {this.maxMessages = 100,
      this.useStreaming = true,
      this.autoScroll = true,
      this.displayConfig = const MessageDisplayConfig(),
      this.performanceConfig = const PerformanceConfig()});

  /// Maximum number of messages to keep in memory
  @override
  @JsonKey()
  final int maxMessages;

  /// Whether to use streaming responses
  @override
  @JsonKey()
  final bool useStreaming;

  /// Whether to auto-scroll to new messages
  @override
  @JsonKey()
  final bool autoScroll;

  /// Message display settings
  @override
  @JsonKey()
  final MessageDisplayConfig displayConfig;

  /// Performance settings
  @override
  @JsonKey()
  final PerformanceConfig performanceConfig;

  @override
  String toString() {
    return 'ChatConfig(maxMessages: $maxMessages, useStreaming: $useStreaming, autoScroll: $autoScroll, displayConfig: $displayConfig, performanceConfig: $performanceConfig)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatConfigImpl &&
            (identical(other.maxMessages, maxMessages) ||
                other.maxMessages == maxMessages) &&
            (identical(other.useStreaming, useStreaming) ||
                other.useStreaming == useStreaming) &&
            (identical(other.autoScroll, autoScroll) ||
                other.autoScroll == autoScroll) &&
            (identical(other.displayConfig, displayConfig) ||
                other.displayConfig == displayConfig) &&
            (identical(other.performanceConfig, performanceConfig) ||
                other.performanceConfig == performanceConfig));
  }

  @override
  int get hashCode => Object.hash(runtimeType, maxMessages, useStreaming,
      autoScroll, displayConfig, performanceConfig);

  /// Create a copy of ChatConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatConfigImplCopyWith<_$ChatConfigImpl> get copyWith =>
      __$$ChatConfigImplCopyWithImpl<_$ChatConfigImpl>(this, _$identity);
}

abstract class _ChatConfig implements ChatConfig {
  const factory _ChatConfig(
      {final int maxMessages,
      final bool useStreaming,
      final bool autoScroll,
      final MessageDisplayConfig displayConfig,
      final PerformanceConfig performanceConfig}) = _$ChatConfigImpl;

  /// Maximum number of messages to keep in memory
  @override
  int get maxMessages;

  /// Whether to use streaming responses
  @override
  bool get useStreaming;

  /// Whether to auto-scroll to new messages
  @override
  bool get autoScroll;

  /// Message display settings
  @override
  MessageDisplayConfig get displayConfig;

  /// Performance settings
  @override
  PerformanceConfig get performanceConfig;

  /// Create a copy of ChatConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatConfigImplCopyWith<_$ChatConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MessageDisplayConfig {
  /// Number of messages to display initially
  int get initialDisplayCount => throw _privateConstructorUsedError;

  /// Number of messages to load when scrolling up
  int get loadMoreCount => throw _privateConstructorUsedError;

  /// Whether to show message timestamps
  bool get showTimestamps => throw _privateConstructorUsedError;

  /// Whether to show message status indicators
  bool get showStatusIndicators => throw _privateConstructorUsedError;

  /// Create a copy of MessageDisplayConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageDisplayConfigCopyWith<MessageDisplayConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageDisplayConfigCopyWith<$Res> {
  factory $MessageDisplayConfigCopyWith(MessageDisplayConfig value,
          $Res Function(MessageDisplayConfig) then) =
      _$MessageDisplayConfigCopyWithImpl<$Res, MessageDisplayConfig>;
  @useResult
  $Res call(
      {int initialDisplayCount,
      int loadMoreCount,
      bool showTimestamps,
      bool showStatusIndicators});
}

/// @nodoc
class _$MessageDisplayConfigCopyWithImpl<$Res,
        $Val extends MessageDisplayConfig>
    implements $MessageDisplayConfigCopyWith<$Res> {
  _$MessageDisplayConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageDisplayConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? initialDisplayCount = null,
    Object? loadMoreCount = null,
    Object? showTimestamps = null,
    Object? showStatusIndicators = null,
  }) {
    return _then(_value.copyWith(
      initialDisplayCount: null == initialDisplayCount
          ? _value.initialDisplayCount
          : initialDisplayCount // ignore: cast_nullable_to_non_nullable
              as int,
      loadMoreCount: null == loadMoreCount
          ? _value.loadMoreCount
          : loadMoreCount // ignore: cast_nullable_to_non_nullable
              as int,
      showTimestamps: null == showTimestamps
          ? _value.showTimestamps
          : showTimestamps // ignore: cast_nullable_to_non_nullable
              as bool,
      showStatusIndicators: null == showStatusIndicators
          ? _value.showStatusIndicators
          : showStatusIndicators // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageDisplayConfigImplCopyWith<$Res>
    implements $MessageDisplayConfigCopyWith<$Res> {
  factory _$$MessageDisplayConfigImplCopyWith(_$MessageDisplayConfigImpl value,
          $Res Function(_$MessageDisplayConfigImpl) then) =
      __$$MessageDisplayConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int initialDisplayCount,
      int loadMoreCount,
      bool showTimestamps,
      bool showStatusIndicators});
}

/// @nodoc
class __$$MessageDisplayConfigImplCopyWithImpl<$Res>
    extends _$MessageDisplayConfigCopyWithImpl<$Res, _$MessageDisplayConfigImpl>
    implements _$$MessageDisplayConfigImplCopyWith<$Res> {
  __$$MessageDisplayConfigImplCopyWithImpl(_$MessageDisplayConfigImpl _value,
      $Res Function(_$MessageDisplayConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageDisplayConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? initialDisplayCount = null,
    Object? loadMoreCount = null,
    Object? showTimestamps = null,
    Object? showStatusIndicators = null,
  }) {
    return _then(_$MessageDisplayConfigImpl(
      initialDisplayCount: null == initialDisplayCount
          ? _value.initialDisplayCount
          : initialDisplayCount // ignore: cast_nullable_to_non_nullable
              as int,
      loadMoreCount: null == loadMoreCount
          ? _value.loadMoreCount
          : loadMoreCount // ignore: cast_nullable_to_non_nullable
              as int,
      showTimestamps: null == showTimestamps
          ? _value.showTimestamps
          : showTimestamps // ignore: cast_nullable_to_non_nullable
              as bool,
      showStatusIndicators: null == showStatusIndicators
          ? _value.showStatusIndicators
          : showStatusIndicators // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$MessageDisplayConfigImpl implements _MessageDisplayConfig {
  const _$MessageDisplayConfigImpl(
      {this.initialDisplayCount = 20,
      this.loadMoreCount = 10,
      this.showTimestamps = true,
      this.showStatusIndicators = true});

  /// Number of messages to display initially
  @override
  @JsonKey()
  final int initialDisplayCount;

  /// Number of messages to load when scrolling up
  @override
  @JsonKey()
  final int loadMoreCount;

  /// Whether to show message timestamps
  @override
  @JsonKey()
  final bool showTimestamps;

  /// Whether to show message status indicators
  @override
  @JsonKey()
  final bool showStatusIndicators;

  @override
  String toString() {
    return 'MessageDisplayConfig(initialDisplayCount: $initialDisplayCount, loadMoreCount: $loadMoreCount, showTimestamps: $showTimestamps, showStatusIndicators: $showStatusIndicators)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageDisplayConfigImpl &&
            (identical(other.initialDisplayCount, initialDisplayCount) ||
                other.initialDisplayCount == initialDisplayCount) &&
            (identical(other.loadMoreCount, loadMoreCount) ||
                other.loadMoreCount == loadMoreCount) &&
            (identical(other.showTimestamps, showTimestamps) ||
                other.showTimestamps == showTimestamps) &&
            (identical(other.showStatusIndicators, showStatusIndicators) ||
                other.showStatusIndicators == showStatusIndicators));
  }

  @override
  int get hashCode => Object.hash(runtimeType, initialDisplayCount,
      loadMoreCount, showTimestamps, showStatusIndicators);

  /// Create a copy of MessageDisplayConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageDisplayConfigImplCopyWith<_$MessageDisplayConfigImpl>
      get copyWith =>
          __$$MessageDisplayConfigImplCopyWithImpl<_$MessageDisplayConfigImpl>(
              this, _$identity);
}

abstract class _MessageDisplayConfig implements MessageDisplayConfig {
  const factory _MessageDisplayConfig(
      {final int initialDisplayCount,
      final int loadMoreCount,
      final bool showTimestamps,
      final bool showStatusIndicators}) = _$MessageDisplayConfigImpl;

  /// Number of messages to display initially
  @override
  int get initialDisplayCount;

  /// Number of messages to load when scrolling up
  @override
  int get loadMoreCount;

  /// Whether to show message timestamps
  @override
  bool get showTimestamps;

  /// Whether to show message status indicators
  @override
  bool get showStatusIndicators;

  /// Create a copy of MessageDisplayConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageDisplayConfigImplCopyWith<_$MessageDisplayConfigImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PerformanceConfig {
  /// Maximum concurrent streaming messages
  int get maxConcurrentStreams => throw _privateConstructorUsedError;

  /// Streaming update throttle delay in milliseconds
  int get streamingThrottleMs => throw _privateConstructorUsedError;

  /// Whether to enable message virtualization for large lists
  bool get enableVirtualization => throw _privateConstructorUsedError;

  /// Threshold for enabling virtualization
  int get virtualizationThreshold => throw _privateConstructorUsedError;

  /// Create a copy of PerformanceConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PerformanceConfigCopyWith<PerformanceConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PerformanceConfigCopyWith<$Res> {
  factory $PerformanceConfigCopyWith(
          PerformanceConfig value, $Res Function(PerformanceConfig) then) =
      _$PerformanceConfigCopyWithImpl<$Res, PerformanceConfig>;
  @useResult
  $Res call(
      {int maxConcurrentStreams,
      int streamingThrottleMs,
      bool enableVirtualization,
      int virtualizationThreshold});
}

/// @nodoc
class _$PerformanceConfigCopyWithImpl<$Res, $Val extends PerformanceConfig>
    implements $PerformanceConfigCopyWith<$Res> {
  _$PerformanceConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PerformanceConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxConcurrentStreams = null,
    Object? streamingThrottleMs = null,
    Object? enableVirtualization = null,
    Object? virtualizationThreshold = null,
  }) {
    return _then(_value.copyWith(
      maxConcurrentStreams: null == maxConcurrentStreams
          ? _value.maxConcurrentStreams
          : maxConcurrentStreams // ignore: cast_nullable_to_non_nullable
              as int,
      streamingThrottleMs: null == streamingThrottleMs
          ? _value.streamingThrottleMs
          : streamingThrottleMs // ignore: cast_nullable_to_non_nullable
              as int,
      enableVirtualization: null == enableVirtualization
          ? _value.enableVirtualization
          : enableVirtualization // ignore: cast_nullable_to_non_nullable
              as bool,
      virtualizationThreshold: null == virtualizationThreshold
          ? _value.virtualizationThreshold
          : virtualizationThreshold // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PerformanceConfigImplCopyWith<$Res>
    implements $PerformanceConfigCopyWith<$Res> {
  factory _$$PerformanceConfigImplCopyWith(_$PerformanceConfigImpl value,
          $Res Function(_$PerformanceConfigImpl) then) =
      __$$PerformanceConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int maxConcurrentStreams,
      int streamingThrottleMs,
      bool enableVirtualization,
      int virtualizationThreshold});
}

/// @nodoc
class __$$PerformanceConfigImplCopyWithImpl<$Res>
    extends _$PerformanceConfigCopyWithImpl<$Res, _$PerformanceConfigImpl>
    implements _$$PerformanceConfigImplCopyWith<$Res> {
  __$$PerformanceConfigImplCopyWithImpl(_$PerformanceConfigImpl _value,
      $Res Function(_$PerformanceConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of PerformanceConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxConcurrentStreams = null,
    Object? streamingThrottleMs = null,
    Object? enableVirtualization = null,
    Object? virtualizationThreshold = null,
  }) {
    return _then(_$PerformanceConfigImpl(
      maxConcurrentStreams: null == maxConcurrentStreams
          ? _value.maxConcurrentStreams
          : maxConcurrentStreams // ignore: cast_nullable_to_non_nullable
              as int,
      streamingThrottleMs: null == streamingThrottleMs
          ? _value.streamingThrottleMs
          : streamingThrottleMs // ignore: cast_nullable_to_non_nullable
              as int,
      enableVirtualization: null == enableVirtualization
          ? _value.enableVirtualization
          : enableVirtualization // ignore: cast_nullable_to_non_nullable
              as bool,
      virtualizationThreshold: null == virtualizationThreshold
          ? _value.virtualizationThreshold
          : virtualizationThreshold // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$PerformanceConfigImpl implements _PerformanceConfig {
  const _$PerformanceConfigImpl(
      {this.maxConcurrentStreams = 3,
      this.streamingThrottleMs = 50,
      this.enableVirtualization = true,
      this.virtualizationThreshold = 50});

  /// Maximum concurrent streaming messages
  @override
  @JsonKey()
  final int maxConcurrentStreams;

  /// Streaming update throttle delay in milliseconds
  @override
  @JsonKey()
  final int streamingThrottleMs;

  /// Whether to enable message virtualization for large lists
  @override
  @JsonKey()
  final bool enableVirtualization;

  /// Threshold for enabling virtualization
  @override
  @JsonKey()
  final int virtualizationThreshold;

  @override
  String toString() {
    return 'PerformanceConfig(maxConcurrentStreams: $maxConcurrentStreams, streamingThrottleMs: $streamingThrottleMs, enableVirtualization: $enableVirtualization, virtualizationThreshold: $virtualizationThreshold)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PerformanceConfigImpl &&
            (identical(other.maxConcurrentStreams, maxConcurrentStreams) ||
                other.maxConcurrentStreams == maxConcurrentStreams) &&
            (identical(other.streamingThrottleMs, streamingThrottleMs) ||
                other.streamingThrottleMs == streamingThrottleMs) &&
            (identical(other.enableVirtualization, enableVirtualization) ||
                other.enableVirtualization == enableVirtualization) &&
            (identical(
                    other.virtualizationThreshold, virtualizationThreshold) ||
                other.virtualizationThreshold == virtualizationThreshold));
  }

  @override
  int get hashCode => Object.hash(runtimeType, maxConcurrentStreams,
      streamingThrottleMs, enableVirtualization, virtualizationThreshold);

  /// Create a copy of PerformanceConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PerformanceConfigImplCopyWith<_$PerformanceConfigImpl> get copyWith =>
      __$$PerformanceConfigImplCopyWithImpl<_$PerformanceConfigImpl>(
          this, _$identity);
}

abstract class _PerformanceConfig implements PerformanceConfig {
  const factory _PerformanceConfig(
      {final int maxConcurrentStreams,
      final int streamingThrottleMs,
      final bool enableVirtualization,
      final int virtualizationThreshold}) = _$PerformanceConfigImpl;

  /// Maximum concurrent streaming messages
  @override
  int get maxConcurrentStreams;

  /// Streaming update throttle delay in milliseconds
  @override
  int get streamingThrottleMs;

  /// Whether to enable message virtualization for large lists
  @override
  bool get enableVirtualization;

  /// Threshold for enabling virtualization
  @override
  int get virtualizationThreshold;

  /// Create a copy of PerformanceConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PerformanceConfigImplCopyWith<_$PerformanceConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ChatState {
// === Conversation Management ===
  /// Current active conversation
  ConversationUiState? get currentConversation =>
      throw _privateConstructorUsedError; // === Message Management (EntityAdapter pattern) ===
  /// Ordered list of messages for display
  List<Message> get messages => throw _privateConstructorUsedError;

  /// Message lookup map for O(1) access (messageId -> Message)
  /// Similar to Cherry Studio's EntityAdapter pattern
  Map<String, Message> get messageMap => throw _privateConstructorUsedError;

  /// Messages grouped by conversation (conversationId -> messageIds)
  /// Similar to Cherry Studio's messageIdsByTopic
  Map<String, List<String>> get messagesByConversation =>
      throw _privateConstructorUsedError; // === Chat Status Management ===
  /// Overall chat status
  ChatStatus get status => throw _privateConstructorUsedError;

  /// General error message
  String? get error => throw _privateConstructorUsedError;

  /// Loading state for non-streaming operations
  bool get isLoading =>
      throw _privateConstructorUsedError; // === Configuration ===
  /// Chat configuration settings
  ChatConfig get config =>
      throw _privateConstructorUsedError; // === Performance Metrics ===
  /// Total number of messages (for quick access)
  int get messageCount => throw _privateConstructorUsedError;

  /// Last update timestamp for cache invalidation
  DateTime? get lastUpdateTime => throw _privateConstructorUsedError;

  /// Display count for pagination
  int get displayCount =>
      throw _privateConstructorUsedError; // === Loading States by Conversation ===
  /// Loading state per conversation (conversationId -> isLoading)
  /// Similar to Cherry Studio's loadingByTopic
  Map<String, bool> get loadingByConversation =>
      throw _privateConstructorUsedError;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatStateCopyWith<ChatState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatStateCopyWith<$Res> {
  factory $ChatStateCopyWith(ChatState value, $Res Function(ChatState) then) =
      _$ChatStateCopyWithImpl<$Res, ChatState>;
  @useResult
  $Res call(
      {ConversationUiState? currentConversation,
      List<Message> messages,
      Map<String, Message> messageMap,
      Map<String, List<String>> messagesByConversation,
      ChatStatus status,
      String? error,
      bool isLoading,
      ChatConfig config,
      int messageCount,
      DateTime? lastUpdateTime,
      int displayCount,
      Map<String, bool> loadingByConversation});

  $ChatConfigCopyWith<$Res> get config;
}

/// @nodoc
class _$ChatStateCopyWithImpl<$Res, $Val extends ChatState>
    implements $ChatStateCopyWith<$Res> {
  _$ChatStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentConversation = freezed,
    Object? messages = null,
    Object? messageMap = null,
    Object? messagesByConversation = null,
    Object? status = null,
    Object? error = freezed,
    Object? isLoading = null,
    Object? config = null,
    Object? messageCount = null,
    Object? lastUpdateTime = freezed,
    Object? displayCount = null,
    Object? loadingByConversation = null,
  }) {
    return _then(_value.copyWith(
      currentConversation: freezed == currentConversation
          ? _value.currentConversation
          : currentConversation // ignore: cast_nullable_to_non_nullable
              as ConversationUiState?,
      messages: null == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<Message>,
      messageMap: null == messageMap
          ? _value.messageMap
          : messageMap // ignore: cast_nullable_to_non_nullable
              as Map<String, Message>,
      messagesByConversation: null == messagesByConversation
          ? _value.messagesByConversation
          : messagesByConversation // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ChatStatus,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      config: null == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as ChatConfig,
      messageCount: null == messageCount
          ? _value.messageCount
          : messageCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastUpdateTime: freezed == lastUpdateTime
          ? _value.lastUpdateTime
          : lastUpdateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      displayCount: null == displayCount
          ? _value.displayCount
          : displayCount // ignore: cast_nullable_to_non_nullable
              as int,
      loadingByConversation: null == loadingByConversation
          ? _value.loadingByConversation
          : loadingByConversation // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
    ) as $Val);
  }

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChatConfigCopyWith<$Res> get config {
    return $ChatConfigCopyWith<$Res>(_value.config, (value) {
      return _then(_value.copyWith(config: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatStateImplCopyWith<$Res>
    implements $ChatStateCopyWith<$Res> {
  factory _$$ChatStateImplCopyWith(
          _$ChatStateImpl value, $Res Function(_$ChatStateImpl) then) =
      __$$ChatStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ConversationUiState? currentConversation,
      List<Message> messages,
      Map<String, Message> messageMap,
      Map<String, List<String>> messagesByConversation,
      ChatStatus status,
      String? error,
      bool isLoading,
      ChatConfig config,
      int messageCount,
      DateTime? lastUpdateTime,
      int displayCount,
      Map<String, bool> loadingByConversation});

  @override
  $ChatConfigCopyWith<$Res> get config;
}

/// @nodoc
class __$$ChatStateImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$ChatStateImpl>
    implements _$$ChatStateImplCopyWith<$Res> {
  __$$ChatStateImplCopyWithImpl(
      _$ChatStateImpl _value, $Res Function(_$ChatStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentConversation = freezed,
    Object? messages = null,
    Object? messageMap = null,
    Object? messagesByConversation = null,
    Object? status = null,
    Object? error = freezed,
    Object? isLoading = null,
    Object? config = null,
    Object? messageCount = null,
    Object? lastUpdateTime = freezed,
    Object? displayCount = null,
    Object? loadingByConversation = null,
  }) {
    return _then(_$ChatStateImpl(
      currentConversation: freezed == currentConversation
          ? _value.currentConversation
          : currentConversation // ignore: cast_nullable_to_non_nullable
              as ConversationUiState?,
      messages: null == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<Message>,
      messageMap: null == messageMap
          ? _value._messageMap
          : messageMap // ignore: cast_nullable_to_non_nullable
              as Map<String, Message>,
      messagesByConversation: null == messagesByConversation
          ? _value._messagesByConversation
          : messagesByConversation // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ChatStatus,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      config: null == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as ChatConfig,
      messageCount: null == messageCount
          ? _value.messageCount
          : messageCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastUpdateTime: freezed == lastUpdateTime
          ? _value.lastUpdateTime
          : lastUpdateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      displayCount: null == displayCount
          ? _value.displayCount
          : displayCount // ignore: cast_nullable_to_non_nullable
              as int,
      loadingByConversation: null == loadingByConversation
          ? _value._loadingByConversation
          : loadingByConversation // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
    ));
  }
}

/// @nodoc

class _$ChatStateImpl extends _ChatState {
  const _$ChatStateImpl(
      {this.currentConversation = null,
      final List<Message> messages = const [],
      final Map<String, Message> messageMap = const {},
      final Map<String, List<String>> messagesByConversation = const {},
      this.status = ChatStatus.idle,
      this.error = null,
      this.isLoading = false,
      this.config = const ChatConfig(),
      this.messageCount = 0,
      this.lastUpdateTime = null,
      this.displayCount = 20,
      final Map<String, bool> loadingByConversation = const {}})
      : _messages = messages,
        _messageMap = messageMap,
        _messagesByConversation = messagesByConversation,
        _loadingByConversation = loadingByConversation,
        super._();

// === Conversation Management ===
  /// Current active conversation
  @override
  @JsonKey()
  final ConversationUiState? currentConversation;
// === Message Management (EntityAdapter pattern) ===
  /// Ordered list of messages for display
  final List<Message> _messages;
// === Message Management (EntityAdapter pattern) ===
  /// Ordered list of messages for display
  @override
  @JsonKey()
  List<Message> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  /// Message lookup map for O(1) access (messageId -> Message)
  /// Similar to Cherry Studio's EntityAdapter pattern
  final Map<String, Message> _messageMap;

  /// Message lookup map for O(1) access (messageId -> Message)
  /// Similar to Cherry Studio's EntityAdapter pattern
  @override
  @JsonKey()
  Map<String, Message> get messageMap {
    if (_messageMap is EqualUnmodifiableMapView) return _messageMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_messageMap);
  }

  /// Messages grouped by conversation (conversationId -> messageIds)
  /// Similar to Cherry Studio's messageIdsByTopic
  final Map<String, List<String>> _messagesByConversation;

  /// Messages grouped by conversation (conversationId -> messageIds)
  /// Similar to Cherry Studio's messageIdsByTopic
  @override
  @JsonKey()
  Map<String, List<String>> get messagesByConversation {
    if (_messagesByConversation is EqualUnmodifiableMapView)
      return _messagesByConversation;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_messagesByConversation);
  }

// === Chat Status Management ===
  /// Overall chat status
  @override
  @JsonKey()
  final ChatStatus status;

  /// General error message
  @override
  @JsonKey()
  final String? error;

  /// Loading state for non-streaming operations
  @override
  @JsonKey()
  final bool isLoading;
// === Configuration ===
  /// Chat configuration settings
  @override
  @JsonKey()
  final ChatConfig config;
// === Performance Metrics ===
  /// Total number of messages (for quick access)
  @override
  @JsonKey()
  final int messageCount;

  /// Last update timestamp for cache invalidation
  @override
  @JsonKey()
  final DateTime? lastUpdateTime;

  /// Display count for pagination
  @override
  @JsonKey()
  final int displayCount;
// === Loading States by Conversation ===
  /// Loading state per conversation (conversationId -> isLoading)
  /// Similar to Cherry Studio's loadingByTopic
  final Map<String, bool> _loadingByConversation;
// === Loading States by Conversation ===
  /// Loading state per conversation (conversationId -> isLoading)
  /// Similar to Cherry Studio's loadingByTopic
  @override
  @JsonKey()
  Map<String, bool> get loadingByConversation {
    if (_loadingByConversation is EqualUnmodifiableMapView)
      return _loadingByConversation;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_loadingByConversation);
  }

  @override
  String toString() {
    return 'ChatState(currentConversation: $currentConversation, messages: $messages, messageMap: $messageMap, messagesByConversation: $messagesByConversation, status: $status, error: $error, isLoading: $isLoading, config: $config, messageCount: $messageCount, lastUpdateTime: $lastUpdateTime, displayCount: $displayCount, loadingByConversation: $loadingByConversation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatStateImpl &&
            (identical(other.currentConversation, currentConversation) ||
                other.currentConversation == currentConversation) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            const DeepCollectionEquality()
                .equals(other._messageMap, _messageMap) &&
            const DeepCollectionEquality().equals(
                other._messagesByConversation, _messagesByConversation) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.config, config) || other.config == config) &&
            (identical(other.messageCount, messageCount) ||
                other.messageCount == messageCount) &&
            (identical(other.lastUpdateTime, lastUpdateTime) ||
                other.lastUpdateTime == lastUpdateTime) &&
            (identical(other.displayCount, displayCount) ||
                other.displayCount == displayCount) &&
            const DeepCollectionEquality()
                .equals(other._loadingByConversation, _loadingByConversation));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentConversation,
      const DeepCollectionEquality().hash(_messages),
      const DeepCollectionEquality().hash(_messageMap),
      const DeepCollectionEquality().hash(_messagesByConversation),
      status,
      error,
      isLoading,
      config,
      messageCount,
      lastUpdateTime,
      displayCount,
      const DeepCollectionEquality().hash(_loadingByConversation));

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatStateImplCopyWith<_$ChatStateImpl> get copyWith =>
      __$$ChatStateImplCopyWithImpl<_$ChatStateImpl>(this, _$identity);
}

abstract class _ChatState extends ChatState {
  const factory _ChatState(
      {final ConversationUiState? currentConversation,
      final List<Message> messages,
      final Map<String, Message> messageMap,
      final Map<String, List<String>> messagesByConversation,
      final ChatStatus status,
      final String? error,
      final bool isLoading,
      final ChatConfig config,
      final int messageCount,
      final DateTime? lastUpdateTime,
      final int displayCount,
      final Map<String, bool> loadingByConversation}) = _$ChatStateImpl;
  const _ChatState._() : super._();

// === Conversation Management ===
  /// Current active conversation
  @override
  ConversationUiState?
      get currentConversation; // === Message Management (EntityAdapter pattern) ===
  /// Ordered list of messages for display
  @override
  List<Message> get messages;

  /// Message lookup map for O(1) access (messageId -> Message)
  /// Similar to Cherry Studio's EntityAdapter pattern
  @override
  Map<String, Message> get messageMap;

  /// Messages grouped by conversation (conversationId -> messageIds)
  /// Similar to Cherry Studio's messageIdsByTopic
  @override
  Map<String, List<String>>
      get messagesByConversation; // === Chat Status Management ===
  /// Overall chat status
  @override
  ChatStatus get status;

  /// General error message
  @override
  String? get error;

  /// Loading state for non-streaming operations
  @override
  bool get isLoading; // === Configuration ===
  /// Chat configuration settings
  @override
  ChatConfig get config; // === Performance Metrics ===
  /// Total number of messages (for quick access)
  @override
  int get messageCount;

  /// Last update timestamp for cache invalidation
  @override
  DateTime? get lastUpdateTime;

  /// Display count for pagination
  @override
  int get displayCount; // === Loading States by Conversation ===
  /// Loading state per conversation (conversationId -> isLoading)
  /// Similar to Cherry Studio's loadingByTopic
  @override
  Map<String, bool> get loadingByConversation;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatStateImplCopyWith<_$ChatStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
