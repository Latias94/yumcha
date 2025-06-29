// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SettingsState {
// === Loading State ===
  /// Whether settings are currently loading
  bool get isLoading => throw _privateConstructorUsedError;

  /// Whether settings have been initialized
  bool get isInitialized => throw _privateConstructorUsedError;

  /// Settings loading error
  String? get error =>
      throw _privateConstructorUsedError; // === Theme Settings ===
  /// Current theme mode
  ThemeMode get themeMode => throw _privateConstructorUsedError;

  /// Custom theme configuration
  CustomThemeConfig? get customTheme => throw _privateConstructorUsedError;

  /// Whether to use system accent color
  bool get useSystemAccentColor => throw _privateConstructorUsedError;

  /// Custom accent color
  String? get customAccentColor =>
      throw _privateConstructorUsedError; // === Language Settings ===
  /// Current language code
  String get languageCode => throw _privateConstructorUsedError;

  /// Available languages
  List<LanguageOption> get availableLanguages =>
      throw _privateConstructorUsedError;

  /// Whether to use system language
  bool get useSystemLanguage =>
      throw _privateConstructorUsedError; // === Display Settings ===
  /// Window style (transparent, opaque)
  WindowStyle get windowStyle => throw _privateConstructorUsedError;

  /// Zoom factor for UI scaling
  double get zoomFactor => throw _privateConstructorUsedError;

  /// Whether to show sidebar icons
  bool get showSidebarIcons => throw _privateConstructorUsedError;

  /// Sidebar icon configuration
  SidebarIconConfig get sidebarIconConfig => throw _privateConstructorUsedError;

  /// Whether to pin topics to top
  bool get pinTopicsToTop => throw _privateConstructorUsedError;

  /// Topic position (left, right)
  TopicPosition get topicPosition => throw _privateConstructorUsedError;

  /// Whether to show topic time
  bool get showTopicTime => throw _privateConstructorUsedError;

  /// Assistant icon type
  AssistantIconType get assistantIconType =>
      throw _privateConstructorUsedError; // === Behavior Settings ===
  /// Send message shortcut
  SendMessageShortcut get sendMessageShortcut =>
      throw _privateConstructorUsedError;

  /// Whether to launch on system boot
  bool get launchOnBoot => throw _privateConstructorUsedError;

  /// Whether to launch to system tray
  bool get launchToTray => throw _privateConstructorUsedError;

  /// Whether to show in system tray
  bool get showInTray => throw _privateConstructorUsedError;

  /// Whether to minimize to tray on close
  bool get minimizeToTrayOnClose =>
      throw _privateConstructorUsedError; // === Chat Settings ===
  /// Default chat model
  String? get defaultChatModel => throw _privateConstructorUsedError;

  /// Default title generation model
  String? get defaultTitleModel => throw _privateConstructorUsedError;

  /// Whether to show tokens in UI
  bool get showTokens => throw _privateConstructorUsedError;

  /// Whether to enable streaming responses
  bool get enableStreaming => throw _privateConstructorUsedError;

  /// Maximum conversation history length
  int get maxConversationHistory => throw _privateConstructorUsedError;

  /// Whether to auto-save conversations
  bool get autoSaveConversations =>
      throw _privateConstructorUsedError; // === Privacy Settings ===
  /// Whether to enable data collection
  bool get enableDataCollection => throw _privateConstructorUsedError;

  /// Whether to enable spell check
  bool get enableSpellCheck => throw _privateConstructorUsedError;

  /// Spell check languages
  List<String> get spellCheckLanguages => throw _privateConstructorUsedError;

  /// Whether to enable quick panel triggers
  bool get enableQuickPanelTriggers => throw _privateConstructorUsedError;

  /// Whether to enable backspace delete model
  bool get enableBackspaceDeleteModel =>
      throw _privateConstructorUsedError; // === Export Settings ===
  /// Export menu options
  ExportMenuOptions get exportMenuOptions =>
      throw _privateConstructorUsedError; // === Update Settings ===
  /// Whether to auto-check for updates
  bool get autoCheckUpdates => throw _privateConstructorUsedError;

  /// Whether to enable early access updates
  bool get enableEarlyAccess => throw _privateConstructorUsedError;

  /// Update channel
  UpdateChannel get updateChannel =>
      throw _privateConstructorUsedError; // === Advanced Settings ===
  /// Custom CSS for theming
  String get customCss => throw _privateConstructorUsedError;

  /// Developer mode enabled
  bool get developerMode => throw _privateConstructorUsedError;

  /// Debug logging enabled
  bool get debugLogging => throw _privateConstructorUsedError;

  /// Performance monitoring enabled
  bool get performanceMonitoring =>
      throw _privateConstructorUsedError; // === Integration Settings ===
  /// MCP server configurations
  List<McpServerConfig> get mcpServers => throw _privateConstructorUsedError;

  /// Knowledge base settings
  KnowledgeBaseSettings get knowledgeBaseSettings =>
      throw _privateConstructorUsedError;

  /// External service integrations
  Map<String, dynamic> get integrations =>
      throw _privateConstructorUsedError; // === Backup Settings ===
  /// Whether to enable automatic backups
  bool get enableAutoBackup => throw _privateConstructorUsedError;

  /// Backup frequency in hours
  int get backupFrequencyHours => throw _privateConstructorUsedError;

  /// Maximum number of backups to keep
  int get maxBackupCount => throw _privateConstructorUsedError;

  /// Backup location
  String? get backupLocation =>
      throw _privateConstructorUsedError; // === Experimental Features ===
  /// Enabled experimental features
  Set<String> get enabledExperimentalFeatures =>
      throw _privateConstructorUsedError;

  /// Feature flags
  Map<String, bool> get featureFlags => throw _privateConstructorUsedError;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettingsStateCopyWith<SettingsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsStateCopyWith<$Res> {
  factory $SettingsStateCopyWith(
          SettingsState value, $Res Function(SettingsState) then) =
      _$SettingsStateCopyWithImpl<$Res, SettingsState>;
  @useResult
  $Res call(
      {bool isLoading,
      bool isInitialized,
      String? error,
      ThemeMode themeMode,
      CustomThemeConfig? customTheme,
      bool useSystemAccentColor,
      String? customAccentColor,
      String languageCode,
      List<LanguageOption> availableLanguages,
      bool useSystemLanguage,
      WindowStyle windowStyle,
      double zoomFactor,
      bool showSidebarIcons,
      SidebarIconConfig sidebarIconConfig,
      bool pinTopicsToTop,
      TopicPosition topicPosition,
      bool showTopicTime,
      AssistantIconType assistantIconType,
      SendMessageShortcut sendMessageShortcut,
      bool launchOnBoot,
      bool launchToTray,
      bool showInTray,
      bool minimizeToTrayOnClose,
      String? defaultChatModel,
      String? defaultTitleModel,
      bool showTokens,
      bool enableStreaming,
      int maxConversationHistory,
      bool autoSaveConversations,
      bool enableDataCollection,
      bool enableSpellCheck,
      List<String> spellCheckLanguages,
      bool enableQuickPanelTriggers,
      bool enableBackspaceDeleteModel,
      ExportMenuOptions exportMenuOptions,
      bool autoCheckUpdates,
      bool enableEarlyAccess,
      UpdateChannel updateChannel,
      String customCss,
      bool developerMode,
      bool debugLogging,
      bool performanceMonitoring,
      List<McpServerConfig> mcpServers,
      KnowledgeBaseSettings knowledgeBaseSettings,
      Map<String, dynamic> integrations,
      bool enableAutoBackup,
      int backupFrequencyHours,
      int maxBackupCount,
      String? backupLocation,
      Set<String> enabledExperimentalFeatures,
      Map<String, bool> featureFlags});

  $CustomThemeConfigCopyWith<$Res>? get customTheme;
  $SidebarIconConfigCopyWith<$Res> get sidebarIconConfig;
  $ExportMenuOptionsCopyWith<$Res> get exportMenuOptions;
  $KnowledgeBaseSettingsCopyWith<$Res> get knowledgeBaseSettings;
}

/// @nodoc
class _$SettingsStateCopyWithImpl<$Res, $Val extends SettingsState>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isInitialized = null,
    Object? error = freezed,
    Object? themeMode = null,
    Object? customTheme = freezed,
    Object? useSystemAccentColor = null,
    Object? customAccentColor = freezed,
    Object? languageCode = null,
    Object? availableLanguages = null,
    Object? useSystemLanguage = null,
    Object? windowStyle = null,
    Object? zoomFactor = null,
    Object? showSidebarIcons = null,
    Object? sidebarIconConfig = null,
    Object? pinTopicsToTop = null,
    Object? topicPosition = null,
    Object? showTopicTime = null,
    Object? assistantIconType = null,
    Object? sendMessageShortcut = null,
    Object? launchOnBoot = null,
    Object? launchToTray = null,
    Object? showInTray = null,
    Object? minimizeToTrayOnClose = null,
    Object? defaultChatModel = freezed,
    Object? defaultTitleModel = freezed,
    Object? showTokens = null,
    Object? enableStreaming = null,
    Object? maxConversationHistory = null,
    Object? autoSaveConversations = null,
    Object? enableDataCollection = null,
    Object? enableSpellCheck = null,
    Object? spellCheckLanguages = null,
    Object? enableQuickPanelTriggers = null,
    Object? enableBackspaceDeleteModel = null,
    Object? exportMenuOptions = null,
    Object? autoCheckUpdates = null,
    Object? enableEarlyAccess = null,
    Object? updateChannel = null,
    Object? customCss = null,
    Object? developerMode = null,
    Object? debugLogging = null,
    Object? performanceMonitoring = null,
    Object? mcpServers = null,
    Object? knowledgeBaseSettings = null,
    Object? integrations = null,
    Object? enableAutoBackup = null,
    Object? backupFrequencyHours = null,
    Object? maxBackupCount = null,
    Object? backupLocation = freezed,
    Object? enabledExperimentalFeatures = null,
    Object? featureFlags = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      customTheme: freezed == customTheme
          ? _value.customTheme
          : customTheme // ignore: cast_nullable_to_non_nullable
              as CustomThemeConfig?,
      useSystemAccentColor: null == useSystemAccentColor
          ? _value.useSystemAccentColor
          : useSystemAccentColor // ignore: cast_nullable_to_non_nullable
              as bool,
      customAccentColor: freezed == customAccentColor
          ? _value.customAccentColor
          : customAccentColor // ignore: cast_nullable_to_non_nullable
              as String?,
      languageCode: null == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String,
      availableLanguages: null == availableLanguages
          ? _value.availableLanguages
          : availableLanguages // ignore: cast_nullable_to_non_nullable
              as List<LanguageOption>,
      useSystemLanguage: null == useSystemLanguage
          ? _value.useSystemLanguage
          : useSystemLanguage // ignore: cast_nullable_to_non_nullable
              as bool,
      windowStyle: null == windowStyle
          ? _value.windowStyle
          : windowStyle // ignore: cast_nullable_to_non_nullable
              as WindowStyle,
      zoomFactor: null == zoomFactor
          ? _value.zoomFactor
          : zoomFactor // ignore: cast_nullable_to_non_nullable
              as double,
      showSidebarIcons: null == showSidebarIcons
          ? _value.showSidebarIcons
          : showSidebarIcons // ignore: cast_nullable_to_non_nullable
              as bool,
      sidebarIconConfig: null == sidebarIconConfig
          ? _value.sidebarIconConfig
          : sidebarIconConfig // ignore: cast_nullable_to_non_nullable
              as SidebarIconConfig,
      pinTopicsToTop: null == pinTopicsToTop
          ? _value.pinTopicsToTop
          : pinTopicsToTop // ignore: cast_nullable_to_non_nullable
              as bool,
      topicPosition: null == topicPosition
          ? _value.topicPosition
          : topicPosition // ignore: cast_nullable_to_non_nullable
              as TopicPosition,
      showTopicTime: null == showTopicTime
          ? _value.showTopicTime
          : showTopicTime // ignore: cast_nullable_to_non_nullable
              as bool,
      assistantIconType: null == assistantIconType
          ? _value.assistantIconType
          : assistantIconType // ignore: cast_nullable_to_non_nullable
              as AssistantIconType,
      sendMessageShortcut: null == sendMessageShortcut
          ? _value.sendMessageShortcut
          : sendMessageShortcut // ignore: cast_nullable_to_non_nullable
              as SendMessageShortcut,
      launchOnBoot: null == launchOnBoot
          ? _value.launchOnBoot
          : launchOnBoot // ignore: cast_nullable_to_non_nullable
              as bool,
      launchToTray: null == launchToTray
          ? _value.launchToTray
          : launchToTray // ignore: cast_nullable_to_non_nullable
              as bool,
      showInTray: null == showInTray
          ? _value.showInTray
          : showInTray // ignore: cast_nullable_to_non_nullable
              as bool,
      minimizeToTrayOnClose: null == minimizeToTrayOnClose
          ? _value.minimizeToTrayOnClose
          : minimizeToTrayOnClose // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultChatModel: freezed == defaultChatModel
          ? _value.defaultChatModel
          : defaultChatModel // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultTitleModel: freezed == defaultTitleModel
          ? _value.defaultTitleModel
          : defaultTitleModel // ignore: cast_nullable_to_non_nullable
              as String?,
      showTokens: null == showTokens
          ? _value.showTokens
          : showTokens // ignore: cast_nullable_to_non_nullable
              as bool,
      enableStreaming: null == enableStreaming
          ? _value.enableStreaming
          : enableStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      maxConversationHistory: null == maxConversationHistory
          ? _value.maxConversationHistory
          : maxConversationHistory // ignore: cast_nullable_to_non_nullable
              as int,
      autoSaveConversations: null == autoSaveConversations
          ? _value.autoSaveConversations
          : autoSaveConversations // ignore: cast_nullable_to_non_nullable
              as bool,
      enableDataCollection: null == enableDataCollection
          ? _value.enableDataCollection
          : enableDataCollection // ignore: cast_nullable_to_non_nullable
              as bool,
      enableSpellCheck: null == enableSpellCheck
          ? _value.enableSpellCheck
          : enableSpellCheck // ignore: cast_nullable_to_non_nullable
              as bool,
      spellCheckLanguages: null == spellCheckLanguages
          ? _value.spellCheckLanguages
          : spellCheckLanguages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      enableQuickPanelTriggers: null == enableQuickPanelTriggers
          ? _value.enableQuickPanelTriggers
          : enableQuickPanelTriggers // ignore: cast_nullable_to_non_nullable
              as bool,
      enableBackspaceDeleteModel: null == enableBackspaceDeleteModel
          ? _value.enableBackspaceDeleteModel
          : enableBackspaceDeleteModel // ignore: cast_nullable_to_non_nullable
              as bool,
      exportMenuOptions: null == exportMenuOptions
          ? _value.exportMenuOptions
          : exportMenuOptions // ignore: cast_nullable_to_non_nullable
              as ExportMenuOptions,
      autoCheckUpdates: null == autoCheckUpdates
          ? _value.autoCheckUpdates
          : autoCheckUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
      enableEarlyAccess: null == enableEarlyAccess
          ? _value.enableEarlyAccess
          : enableEarlyAccess // ignore: cast_nullable_to_non_nullable
              as bool,
      updateChannel: null == updateChannel
          ? _value.updateChannel
          : updateChannel // ignore: cast_nullable_to_non_nullable
              as UpdateChannel,
      customCss: null == customCss
          ? _value.customCss
          : customCss // ignore: cast_nullable_to_non_nullable
              as String,
      developerMode: null == developerMode
          ? _value.developerMode
          : developerMode // ignore: cast_nullable_to_non_nullable
              as bool,
      debugLogging: null == debugLogging
          ? _value.debugLogging
          : debugLogging // ignore: cast_nullable_to_non_nullable
              as bool,
      performanceMonitoring: null == performanceMonitoring
          ? _value.performanceMonitoring
          : performanceMonitoring // ignore: cast_nullable_to_non_nullable
              as bool,
      mcpServers: null == mcpServers
          ? _value.mcpServers
          : mcpServers // ignore: cast_nullable_to_non_nullable
              as List<McpServerConfig>,
      knowledgeBaseSettings: null == knowledgeBaseSettings
          ? _value.knowledgeBaseSettings
          : knowledgeBaseSettings // ignore: cast_nullable_to_non_nullable
              as KnowledgeBaseSettings,
      integrations: null == integrations
          ? _value.integrations
          : integrations // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      enableAutoBackup: null == enableAutoBackup
          ? _value.enableAutoBackup
          : enableAutoBackup // ignore: cast_nullable_to_non_nullable
              as bool,
      backupFrequencyHours: null == backupFrequencyHours
          ? _value.backupFrequencyHours
          : backupFrequencyHours // ignore: cast_nullable_to_non_nullable
              as int,
      maxBackupCount: null == maxBackupCount
          ? _value.maxBackupCount
          : maxBackupCount // ignore: cast_nullable_to_non_nullable
              as int,
      backupLocation: freezed == backupLocation
          ? _value.backupLocation
          : backupLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      enabledExperimentalFeatures: null == enabledExperimentalFeatures
          ? _value.enabledExperimentalFeatures
          : enabledExperimentalFeatures // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      featureFlags: null == featureFlags
          ? _value.featureFlags
          : featureFlags // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
    ) as $Val);
  }

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CustomThemeConfigCopyWith<$Res>? get customTheme {
    if (_value.customTheme == null) {
      return null;
    }

    return $CustomThemeConfigCopyWith<$Res>(_value.customTheme!, (value) {
      return _then(_value.copyWith(customTheme: value) as $Val);
    });
  }

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SidebarIconConfigCopyWith<$Res> get sidebarIconConfig {
    return $SidebarIconConfigCopyWith<$Res>(_value.sidebarIconConfig, (value) {
      return _then(_value.copyWith(sidebarIconConfig: value) as $Val);
    });
  }

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExportMenuOptionsCopyWith<$Res> get exportMenuOptions {
    return $ExportMenuOptionsCopyWith<$Res>(_value.exportMenuOptions, (value) {
      return _then(_value.copyWith(exportMenuOptions: value) as $Val);
    });
  }

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $KnowledgeBaseSettingsCopyWith<$Res> get knowledgeBaseSettings {
    return $KnowledgeBaseSettingsCopyWith<$Res>(_value.knowledgeBaseSettings,
        (value) {
      return _then(_value.copyWith(knowledgeBaseSettings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SettingsStateImplCopyWith<$Res>
    implements $SettingsStateCopyWith<$Res> {
  factory _$$SettingsStateImplCopyWith(
          _$SettingsStateImpl value, $Res Function(_$SettingsStateImpl) then) =
      __$$SettingsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isInitialized,
      String? error,
      ThemeMode themeMode,
      CustomThemeConfig? customTheme,
      bool useSystemAccentColor,
      String? customAccentColor,
      String languageCode,
      List<LanguageOption> availableLanguages,
      bool useSystemLanguage,
      WindowStyle windowStyle,
      double zoomFactor,
      bool showSidebarIcons,
      SidebarIconConfig sidebarIconConfig,
      bool pinTopicsToTop,
      TopicPosition topicPosition,
      bool showTopicTime,
      AssistantIconType assistantIconType,
      SendMessageShortcut sendMessageShortcut,
      bool launchOnBoot,
      bool launchToTray,
      bool showInTray,
      bool minimizeToTrayOnClose,
      String? defaultChatModel,
      String? defaultTitleModel,
      bool showTokens,
      bool enableStreaming,
      int maxConversationHistory,
      bool autoSaveConversations,
      bool enableDataCollection,
      bool enableSpellCheck,
      List<String> spellCheckLanguages,
      bool enableQuickPanelTriggers,
      bool enableBackspaceDeleteModel,
      ExportMenuOptions exportMenuOptions,
      bool autoCheckUpdates,
      bool enableEarlyAccess,
      UpdateChannel updateChannel,
      String customCss,
      bool developerMode,
      bool debugLogging,
      bool performanceMonitoring,
      List<McpServerConfig> mcpServers,
      KnowledgeBaseSettings knowledgeBaseSettings,
      Map<String, dynamic> integrations,
      bool enableAutoBackup,
      int backupFrequencyHours,
      int maxBackupCount,
      String? backupLocation,
      Set<String> enabledExperimentalFeatures,
      Map<String, bool> featureFlags});

  @override
  $CustomThemeConfigCopyWith<$Res>? get customTheme;
  @override
  $SidebarIconConfigCopyWith<$Res> get sidebarIconConfig;
  @override
  $ExportMenuOptionsCopyWith<$Res> get exportMenuOptions;
  @override
  $KnowledgeBaseSettingsCopyWith<$Res> get knowledgeBaseSettings;
}

/// @nodoc
class __$$SettingsStateImplCopyWithImpl<$Res>
    extends _$SettingsStateCopyWithImpl<$Res, _$SettingsStateImpl>
    implements _$$SettingsStateImplCopyWith<$Res> {
  __$$SettingsStateImplCopyWithImpl(
      _$SettingsStateImpl _value, $Res Function(_$SettingsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isInitialized = null,
    Object? error = freezed,
    Object? themeMode = null,
    Object? customTheme = freezed,
    Object? useSystemAccentColor = null,
    Object? customAccentColor = freezed,
    Object? languageCode = null,
    Object? availableLanguages = null,
    Object? useSystemLanguage = null,
    Object? windowStyle = null,
    Object? zoomFactor = null,
    Object? showSidebarIcons = null,
    Object? sidebarIconConfig = null,
    Object? pinTopicsToTop = null,
    Object? topicPosition = null,
    Object? showTopicTime = null,
    Object? assistantIconType = null,
    Object? sendMessageShortcut = null,
    Object? launchOnBoot = null,
    Object? launchToTray = null,
    Object? showInTray = null,
    Object? minimizeToTrayOnClose = null,
    Object? defaultChatModel = freezed,
    Object? defaultTitleModel = freezed,
    Object? showTokens = null,
    Object? enableStreaming = null,
    Object? maxConversationHistory = null,
    Object? autoSaveConversations = null,
    Object? enableDataCollection = null,
    Object? enableSpellCheck = null,
    Object? spellCheckLanguages = null,
    Object? enableQuickPanelTriggers = null,
    Object? enableBackspaceDeleteModel = null,
    Object? exportMenuOptions = null,
    Object? autoCheckUpdates = null,
    Object? enableEarlyAccess = null,
    Object? updateChannel = null,
    Object? customCss = null,
    Object? developerMode = null,
    Object? debugLogging = null,
    Object? performanceMonitoring = null,
    Object? mcpServers = null,
    Object? knowledgeBaseSettings = null,
    Object? integrations = null,
    Object? enableAutoBackup = null,
    Object? backupFrequencyHours = null,
    Object? maxBackupCount = null,
    Object? backupLocation = freezed,
    Object? enabledExperimentalFeatures = null,
    Object? featureFlags = null,
  }) {
    return _then(_$SettingsStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      customTheme: freezed == customTheme
          ? _value.customTheme
          : customTheme // ignore: cast_nullable_to_non_nullable
              as CustomThemeConfig?,
      useSystemAccentColor: null == useSystemAccentColor
          ? _value.useSystemAccentColor
          : useSystemAccentColor // ignore: cast_nullable_to_non_nullable
              as bool,
      customAccentColor: freezed == customAccentColor
          ? _value.customAccentColor
          : customAccentColor // ignore: cast_nullable_to_non_nullable
              as String?,
      languageCode: null == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String,
      availableLanguages: null == availableLanguages
          ? _value._availableLanguages
          : availableLanguages // ignore: cast_nullable_to_non_nullable
              as List<LanguageOption>,
      useSystemLanguage: null == useSystemLanguage
          ? _value.useSystemLanguage
          : useSystemLanguage // ignore: cast_nullable_to_non_nullable
              as bool,
      windowStyle: null == windowStyle
          ? _value.windowStyle
          : windowStyle // ignore: cast_nullable_to_non_nullable
              as WindowStyle,
      zoomFactor: null == zoomFactor
          ? _value.zoomFactor
          : zoomFactor // ignore: cast_nullable_to_non_nullable
              as double,
      showSidebarIcons: null == showSidebarIcons
          ? _value.showSidebarIcons
          : showSidebarIcons // ignore: cast_nullable_to_non_nullable
              as bool,
      sidebarIconConfig: null == sidebarIconConfig
          ? _value.sidebarIconConfig
          : sidebarIconConfig // ignore: cast_nullable_to_non_nullable
              as SidebarIconConfig,
      pinTopicsToTop: null == pinTopicsToTop
          ? _value.pinTopicsToTop
          : pinTopicsToTop // ignore: cast_nullable_to_non_nullable
              as bool,
      topicPosition: null == topicPosition
          ? _value.topicPosition
          : topicPosition // ignore: cast_nullable_to_non_nullable
              as TopicPosition,
      showTopicTime: null == showTopicTime
          ? _value.showTopicTime
          : showTopicTime // ignore: cast_nullable_to_non_nullable
              as bool,
      assistantIconType: null == assistantIconType
          ? _value.assistantIconType
          : assistantIconType // ignore: cast_nullable_to_non_nullable
              as AssistantIconType,
      sendMessageShortcut: null == sendMessageShortcut
          ? _value.sendMessageShortcut
          : sendMessageShortcut // ignore: cast_nullable_to_non_nullable
              as SendMessageShortcut,
      launchOnBoot: null == launchOnBoot
          ? _value.launchOnBoot
          : launchOnBoot // ignore: cast_nullable_to_non_nullable
              as bool,
      launchToTray: null == launchToTray
          ? _value.launchToTray
          : launchToTray // ignore: cast_nullable_to_non_nullable
              as bool,
      showInTray: null == showInTray
          ? _value.showInTray
          : showInTray // ignore: cast_nullable_to_non_nullable
              as bool,
      minimizeToTrayOnClose: null == minimizeToTrayOnClose
          ? _value.minimizeToTrayOnClose
          : minimizeToTrayOnClose // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultChatModel: freezed == defaultChatModel
          ? _value.defaultChatModel
          : defaultChatModel // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultTitleModel: freezed == defaultTitleModel
          ? _value.defaultTitleModel
          : defaultTitleModel // ignore: cast_nullable_to_non_nullable
              as String?,
      showTokens: null == showTokens
          ? _value.showTokens
          : showTokens // ignore: cast_nullable_to_non_nullable
              as bool,
      enableStreaming: null == enableStreaming
          ? _value.enableStreaming
          : enableStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      maxConversationHistory: null == maxConversationHistory
          ? _value.maxConversationHistory
          : maxConversationHistory // ignore: cast_nullable_to_non_nullable
              as int,
      autoSaveConversations: null == autoSaveConversations
          ? _value.autoSaveConversations
          : autoSaveConversations // ignore: cast_nullable_to_non_nullable
              as bool,
      enableDataCollection: null == enableDataCollection
          ? _value.enableDataCollection
          : enableDataCollection // ignore: cast_nullable_to_non_nullable
              as bool,
      enableSpellCheck: null == enableSpellCheck
          ? _value.enableSpellCheck
          : enableSpellCheck // ignore: cast_nullable_to_non_nullable
              as bool,
      spellCheckLanguages: null == spellCheckLanguages
          ? _value._spellCheckLanguages
          : spellCheckLanguages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      enableQuickPanelTriggers: null == enableQuickPanelTriggers
          ? _value.enableQuickPanelTriggers
          : enableQuickPanelTriggers // ignore: cast_nullable_to_non_nullable
              as bool,
      enableBackspaceDeleteModel: null == enableBackspaceDeleteModel
          ? _value.enableBackspaceDeleteModel
          : enableBackspaceDeleteModel // ignore: cast_nullable_to_non_nullable
              as bool,
      exportMenuOptions: null == exportMenuOptions
          ? _value.exportMenuOptions
          : exportMenuOptions // ignore: cast_nullable_to_non_nullable
              as ExportMenuOptions,
      autoCheckUpdates: null == autoCheckUpdates
          ? _value.autoCheckUpdates
          : autoCheckUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
      enableEarlyAccess: null == enableEarlyAccess
          ? _value.enableEarlyAccess
          : enableEarlyAccess // ignore: cast_nullable_to_non_nullable
              as bool,
      updateChannel: null == updateChannel
          ? _value.updateChannel
          : updateChannel // ignore: cast_nullable_to_non_nullable
              as UpdateChannel,
      customCss: null == customCss
          ? _value.customCss
          : customCss // ignore: cast_nullable_to_non_nullable
              as String,
      developerMode: null == developerMode
          ? _value.developerMode
          : developerMode // ignore: cast_nullable_to_non_nullable
              as bool,
      debugLogging: null == debugLogging
          ? _value.debugLogging
          : debugLogging // ignore: cast_nullable_to_non_nullable
              as bool,
      performanceMonitoring: null == performanceMonitoring
          ? _value.performanceMonitoring
          : performanceMonitoring // ignore: cast_nullable_to_non_nullable
              as bool,
      mcpServers: null == mcpServers
          ? _value._mcpServers
          : mcpServers // ignore: cast_nullable_to_non_nullable
              as List<McpServerConfig>,
      knowledgeBaseSettings: null == knowledgeBaseSettings
          ? _value.knowledgeBaseSettings
          : knowledgeBaseSettings // ignore: cast_nullable_to_non_nullable
              as KnowledgeBaseSettings,
      integrations: null == integrations
          ? _value._integrations
          : integrations // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      enableAutoBackup: null == enableAutoBackup
          ? _value.enableAutoBackup
          : enableAutoBackup // ignore: cast_nullable_to_non_nullable
              as bool,
      backupFrequencyHours: null == backupFrequencyHours
          ? _value.backupFrequencyHours
          : backupFrequencyHours // ignore: cast_nullable_to_non_nullable
              as int,
      maxBackupCount: null == maxBackupCount
          ? _value.maxBackupCount
          : maxBackupCount // ignore: cast_nullable_to_non_nullable
              as int,
      backupLocation: freezed == backupLocation
          ? _value.backupLocation
          : backupLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      enabledExperimentalFeatures: null == enabledExperimentalFeatures
          ? _value._enabledExperimentalFeatures
          : enabledExperimentalFeatures // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      featureFlags: null == featureFlags
          ? _value._featureFlags
          : featureFlags // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
    ));
  }
}

/// @nodoc

class _$SettingsStateImpl extends _SettingsState {
  const _$SettingsStateImpl(
      {this.isLoading = false,
      this.isInitialized = false,
      this.error = null,
      this.themeMode = ThemeMode.system,
      this.customTheme = null,
      this.useSystemAccentColor = true,
      this.customAccentColor = null,
      this.languageCode = 'en',
      final List<LanguageOption> availableLanguages = const [],
      this.useSystemLanguage = true,
      this.windowStyle = WindowStyle.opaque,
      this.zoomFactor = 1.0,
      this.showSidebarIcons = true,
      this.sidebarIconConfig = const SidebarIconConfig(),
      this.pinTopicsToTop = false,
      this.topicPosition = TopicPosition.left,
      this.showTopicTime = true,
      this.assistantIconType = AssistantIconType.avatar,
      this.sendMessageShortcut = SendMessageShortcut.enter,
      this.launchOnBoot = false,
      this.launchToTray = false,
      this.showInTray = true,
      this.minimizeToTrayOnClose = true,
      this.defaultChatModel = null,
      this.defaultTitleModel = null,
      this.showTokens = false,
      this.enableStreaming = true,
      this.maxConversationHistory = 100,
      this.autoSaveConversations = true,
      this.enableDataCollection = false,
      this.enableSpellCheck = true,
      final List<String> spellCheckLanguages = const ['en'],
      this.enableQuickPanelTriggers = true,
      this.enableBackspaceDeleteModel = false,
      this.exportMenuOptions = const ExportMenuOptions(),
      this.autoCheckUpdates = true,
      this.enableEarlyAccess = false,
      this.updateChannel = UpdateChannel.stable,
      this.customCss = '',
      this.developerMode = false,
      this.debugLogging = false,
      this.performanceMonitoring = false,
      final List<McpServerConfig> mcpServers = const [],
      this.knowledgeBaseSettings = const KnowledgeBaseSettings(),
      final Map<String, dynamic> integrations = const {},
      this.enableAutoBackup = true,
      this.backupFrequencyHours = 24,
      this.maxBackupCount = 7,
      this.backupLocation = null,
      final Set<String> enabledExperimentalFeatures = const {},
      final Map<String, bool> featureFlags = const {}})
      : _availableLanguages = availableLanguages,
        _spellCheckLanguages = spellCheckLanguages,
        _mcpServers = mcpServers,
        _integrations = integrations,
        _enabledExperimentalFeatures = enabledExperimentalFeatures,
        _featureFlags = featureFlags,
        super._();

// === Loading State ===
  /// Whether settings are currently loading
  @override
  @JsonKey()
  final bool isLoading;

  /// Whether settings have been initialized
  @override
  @JsonKey()
  final bool isInitialized;

  /// Settings loading error
  @override
  @JsonKey()
  final String? error;
// === Theme Settings ===
  /// Current theme mode
  @override
  @JsonKey()
  final ThemeMode themeMode;

  /// Custom theme configuration
  @override
  @JsonKey()
  final CustomThemeConfig? customTheme;

  /// Whether to use system accent color
  @override
  @JsonKey()
  final bool useSystemAccentColor;

  /// Custom accent color
  @override
  @JsonKey()
  final String? customAccentColor;
// === Language Settings ===
  /// Current language code
  @override
  @JsonKey()
  final String languageCode;

  /// Available languages
  final List<LanguageOption> _availableLanguages;

  /// Available languages
  @override
  @JsonKey()
  List<LanguageOption> get availableLanguages {
    if (_availableLanguages is EqualUnmodifiableListView)
      return _availableLanguages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableLanguages);
  }

  /// Whether to use system language
  @override
  @JsonKey()
  final bool useSystemLanguage;
// === Display Settings ===
  /// Window style (transparent, opaque)
  @override
  @JsonKey()
  final WindowStyle windowStyle;

  /// Zoom factor for UI scaling
  @override
  @JsonKey()
  final double zoomFactor;

  /// Whether to show sidebar icons
  @override
  @JsonKey()
  final bool showSidebarIcons;

  /// Sidebar icon configuration
  @override
  @JsonKey()
  final SidebarIconConfig sidebarIconConfig;

  /// Whether to pin topics to top
  @override
  @JsonKey()
  final bool pinTopicsToTop;

  /// Topic position (left, right)
  @override
  @JsonKey()
  final TopicPosition topicPosition;

  /// Whether to show topic time
  @override
  @JsonKey()
  final bool showTopicTime;

  /// Assistant icon type
  @override
  @JsonKey()
  final AssistantIconType assistantIconType;
// === Behavior Settings ===
  /// Send message shortcut
  @override
  @JsonKey()
  final SendMessageShortcut sendMessageShortcut;

  /// Whether to launch on system boot
  @override
  @JsonKey()
  final bool launchOnBoot;

  /// Whether to launch to system tray
  @override
  @JsonKey()
  final bool launchToTray;

  /// Whether to show in system tray
  @override
  @JsonKey()
  final bool showInTray;

  /// Whether to minimize to tray on close
  @override
  @JsonKey()
  final bool minimizeToTrayOnClose;
// === Chat Settings ===
  /// Default chat model
  @override
  @JsonKey()
  final String? defaultChatModel;

  /// Default title generation model
  @override
  @JsonKey()
  final String? defaultTitleModel;

  /// Whether to show tokens in UI
  @override
  @JsonKey()
  final bool showTokens;

  /// Whether to enable streaming responses
  @override
  @JsonKey()
  final bool enableStreaming;

  /// Maximum conversation history length
  @override
  @JsonKey()
  final int maxConversationHistory;

  /// Whether to auto-save conversations
  @override
  @JsonKey()
  final bool autoSaveConversations;
// === Privacy Settings ===
  /// Whether to enable data collection
  @override
  @JsonKey()
  final bool enableDataCollection;

  /// Whether to enable spell check
  @override
  @JsonKey()
  final bool enableSpellCheck;

  /// Spell check languages
  final List<String> _spellCheckLanguages;

  /// Spell check languages
  @override
  @JsonKey()
  List<String> get spellCheckLanguages {
    if (_spellCheckLanguages is EqualUnmodifiableListView)
      return _spellCheckLanguages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_spellCheckLanguages);
  }

  /// Whether to enable quick panel triggers
  @override
  @JsonKey()
  final bool enableQuickPanelTriggers;

  /// Whether to enable backspace delete model
  @override
  @JsonKey()
  final bool enableBackspaceDeleteModel;
// === Export Settings ===
  /// Export menu options
  @override
  @JsonKey()
  final ExportMenuOptions exportMenuOptions;
// === Update Settings ===
  /// Whether to auto-check for updates
  @override
  @JsonKey()
  final bool autoCheckUpdates;

  /// Whether to enable early access updates
  @override
  @JsonKey()
  final bool enableEarlyAccess;

  /// Update channel
  @override
  @JsonKey()
  final UpdateChannel updateChannel;
// === Advanced Settings ===
  /// Custom CSS for theming
  @override
  @JsonKey()
  final String customCss;

  /// Developer mode enabled
  @override
  @JsonKey()
  final bool developerMode;

  /// Debug logging enabled
  @override
  @JsonKey()
  final bool debugLogging;

  /// Performance monitoring enabled
  @override
  @JsonKey()
  final bool performanceMonitoring;
// === Integration Settings ===
  /// MCP server configurations
  final List<McpServerConfig> _mcpServers;
// === Integration Settings ===
  /// MCP server configurations
  @override
  @JsonKey()
  List<McpServerConfig> get mcpServers {
    if (_mcpServers is EqualUnmodifiableListView) return _mcpServers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mcpServers);
  }

  /// Knowledge base settings
  @override
  @JsonKey()
  final KnowledgeBaseSettings knowledgeBaseSettings;

  /// External service integrations
  final Map<String, dynamic> _integrations;

  /// External service integrations
  @override
  @JsonKey()
  Map<String, dynamic> get integrations {
    if (_integrations is EqualUnmodifiableMapView) return _integrations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_integrations);
  }

// === Backup Settings ===
  /// Whether to enable automatic backups
  @override
  @JsonKey()
  final bool enableAutoBackup;

  /// Backup frequency in hours
  @override
  @JsonKey()
  final int backupFrequencyHours;

  /// Maximum number of backups to keep
  @override
  @JsonKey()
  final int maxBackupCount;

  /// Backup location
  @override
  @JsonKey()
  final String? backupLocation;
// === Experimental Features ===
  /// Enabled experimental features
  final Set<String> _enabledExperimentalFeatures;
// === Experimental Features ===
  /// Enabled experimental features
  @override
  @JsonKey()
  Set<String> get enabledExperimentalFeatures {
    if (_enabledExperimentalFeatures is EqualUnmodifiableSetView)
      return _enabledExperimentalFeatures;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_enabledExperimentalFeatures);
  }

  /// Feature flags
  final Map<String, bool> _featureFlags;

  /// Feature flags
  @override
  @JsonKey()
  Map<String, bool> get featureFlags {
    if (_featureFlags is EqualUnmodifiableMapView) return _featureFlags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_featureFlags);
  }

  @override
  String toString() {
    return 'SettingsState(isLoading: $isLoading, isInitialized: $isInitialized, error: $error, themeMode: $themeMode, customTheme: $customTheme, useSystemAccentColor: $useSystemAccentColor, customAccentColor: $customAccentColor, languageCode: $languageCode, availableLanguages: $availableLanguages, useSystemLanguage: $useSystemLanguage, windowStyle: $windowStyle, zoomFactor: $zoomFactor, showSidebarIcons: $showSidebarIcons, sidebarIconConfig: $sidebarIconConfig, pinTopicsToTop: $pinTopicsToTop, topicPosition: $topicPosition, showTopicTime: $showTopicTime, assistantIconType: $assistantIconType, sendMessageShortcut: $sendMessageShortcut, launchOnBoot: $launchOnBoot, launchToTray: $launchToTray, showInTray: $showInTray, minimizeToTrayOnClose: $minimizeToTrayOnClose, defaultChatModel: $defaultChatModel, defaultTitleModel: $defaultTitleModel, showTokens: $showTokens, enableStreaming: $enableStreaming, maxConversationHistory: $maxConversationHistory, autoSaveConversations: $autoSaveConversations, enableDataCollection: $enableDataCollection, enableSpellCheck: $enableSpellCheck, spellCheckLanguages: $spellCheckLanguages, enableQuickPanelTriggers: $enableQuickPanelTriggers, enableBackspaceDeleteModel: $enableBackspaceDeleteModel, exportMenuOptions: $exportMenuOptions, autoCheckUpdates: $autoCheckUpdates, enableEarlyAccess: $enableEarlyAccess, updateChannel: $updateChannel, customCss: $customCss, developerMode: $developerMode, debugLogging: $debugLogging, performanceMonitoring: $performanceMonitoring, mcpServers: $mcpServers, knowledgeBaseSettings: $knowledgeBaseSettings, integrations: $integrations, enableAutoBackup: $enableAutoBackup, backupFrequencyHours: $backupFrequencyHours, maxBackupCount: $maxBackupCount, backupLocation: $backupLocation, enabledExperimentalFeatures: $enabledExperimentalFeatures, featureFlags: $featureFlags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingsStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.customTheme, customTheme) ||
                other.customTheme == customTheme) &&
            (identical(other.useSystemAccentColor, useSystemAccentColor) ||
                other.useSystemAccentColor == useSystemAccentColor) &&
            (identical(other.customAccentColor, customAccentColor) ||
                other.customAccentColor == customAccentColor) &&
            (identical(other.languageCode, languageCode) ||
                other.languageCode == languageCode) &&
            const DeepCollectionEquality()
                .equals(other._availableLanguages, _availableLanguages) &&
            (identical(other.useSystemLanguage, useSystemLanguage) ||
                other.useSystemLanguage == useSystemLanguage) &&
            (identical(other.windowStyle, windowStyle) ||
                other.windowStyle == windowStyle) &&
            (identical(other.zoomFactor, zoomFactor) ||
                other.zoomFactor == zoomFactor) &&
            (identical(other.showSidebarIcons, showSidebarIcons) ||
                other.showSidebarIcons == showSidebarIcons) &&
            (identical(other.sidebarIconConfig, sidebarIconConfig) ||
                other.sidebarIconConfig == sidebarIconConfig) &&
            (identical(other.pinTopicsToTop, pinTopicsToTop) ||
                other.pinTopicsToTop == pinTopicsToTop) &&
            (identical(other.topicPosition, topicPosition) ||
                other.topicPosition == topicPosition) &&
            (identical(other.showTopicTime, showTopicTime) ||
                other.showTopicTime == showTopicTime) &&
            (identical(other.assistantIconType, assistantIconType) ||
                other.assistantIconType == assistantIconType) &&
            (identical(other.sendMessageShortcut, sendMessageShortcut) ||
                other.sendMessageShortcut == sendMessageShortcut) &&
            (identical(other.launchOnBoot, launchOnBoot) ||
                other.launchOnBoot == launchOnBoot) &&
            (identical(other.launchToTray, launchToTray) ||
                other.launchToTray == launchToTray) &&
            (identical(other.showInTray, showInTray) ||
                other.showInTray == showInTray) &&
            (identical(other.minimizeToTrayOnClose, minimizeToTrayOnClose) ||
                other.minimizeToTrayOnClose == minimizeToTrayOnClose) &&
            (identical(other.defaultChatModel, defaultChatModel) ||
                other.defaultChatModel == defaultChatModel) &&
            (identical(other.defaultTitleModel, defaultTitleModel) ||
                other.defaultTitleModel == defaultTitleModel) &&
            (identical(other.showTokens, showTokens) ||
                other.showTokens == showTokens) &&
            (identical(other.enableStreaming, enableStreaming) ||
                other.enableStreaming == enableStreaming) &&
            (identical(other.maxConversationHistory, maxConversationHistory) ||
                other.maxConversationHistory == maxConversationHistory) &&
            (identical(other.autoSaveConversations, autoSaveConversations) ||
                other.autoSaveConversations == autoSaveConversations) &&
            (identical(other.enableDataCollection, enableDataCollection) ||
                other.enableDataCollection == enableDataCollection) &&
            (identical(other.enableSpellCheck, enableSpellCheck) ||
                other.enableSpellCheck == enableSpellCheck) &&
            const DeepCollectionEquality()
                .equals(other._spellCheckLanguages, _spellCheckLanguages) &&
            (identical(other.enableQuickPanelTriggers, enableQuickPanelTriggers) ||
                other.enableQuickPanelTriggers == enableQuickPanelTriggers) &&
            (identical(other.enableBackspaceDeleteModel, enableBackspaceDeleteModel) ||
                other.enableBackspaceDeleteModel ==
                    enableBackspaceDeleteModel) &&
            (identical(other.exportMenuOptions, exportMenuOptions) ||
                other.exportMenuOptions == exportMenuOptions) &&
            (identical(other.autoCheckUpdates, autoCheckUpdates) ||
                other.autoCheckUpdates == autoCheckUpdates) &&
            (identical(other.enableEarlyAccess, enableEarlyAccess) ||
                other.enableEarlyAccess == enableEarlyAccess) &&
            (identical(other.updateChannel, updateChannel) ||
                other.updateChannel == updateChannel) &&
            (identical(other.customCss, customCss) ||
                other.customCss == customCss) &&
            (identical(other.developerMode, developerMode) ||
                other.developerMode == developerMode) &&
            (identical(other.debugLogging, debugLogging) ||
                other.debugLogging == debugLogging) &&
            (identical(other.performanceMonitoring, performanceMonitoring) ||
                other.performanceMonitoring == performanceMonitoring) &&
            const DeepCollectionEquality().equals(other._mcpServers, _mcpServers) &&
            (identical(other.knowledgeBaseSettings, knowledgeBaseSettings) || other.knowledgeBaseSettings == knowledgeBaseSettings) &&
            const DeepCollectionEquality().equals(other._integrations, _integrations) &&
            (identical(other.enableAutoBackup, enableAutoBackup) || other.enableAutoBackup == enableAutoBackup) &&
            (identical(other.backupFrequencyHours, backupFrequencyHours) || other.backupFrequencyHours == backupFrequencyHours) &&
            (identical(other.maxBackupCount, maxBackupCount) || other.maxBackupCount == maxBackupCount) &&
            (identical(other.backupLocation, backupLocation) || other.backupLocation == backupLocation) &&
            const DeepCollectionEquality().equals(other._enabledExperimentalFeatures, _enabledExperimentalFeatures) &&
            const DeepCollectionEquality().equals(other._featureFlags, _featureFlags));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        isLoading,
        isInitialized,
        error,
        themeMode,
        customTheme,
        useSystemAccentColor,
        customAccentColor,
        languageCode,
        const DeepCollectionEquality().hash(_availableLanguages),
        useSystemLanguage,
        windowStyle,
        zoomFactor,
        showSidebarIcons,
        sidebarIconConfig,
        pinTopicsToTop,
        topicPosition,
        showTopicTime,
        assistantIconType,
        sendMessageShortcut,
        launchOnBoot,
        launchToTray,
        showInTray,
        minimizeToTrayOnClose,
        defaultChatModel,
        defaultTitleModel,
        showTokens,
        enableStreaming,
        maxConversationHistory,
        autoSaveConversations,
        enableDataCollection,
        enableSpellCheck,
        const DeepCollectionEquality().hash(_spellCheckLanguages),
        enableQuickPanelTriggers,
        enableBackspaceDeleteModel,
        exportMenuOptions,
        autoCheckUpdates,
        enableEarlyAccess,
        updateChannel,
        customCss,
        developerMode,
        debugLogging,
        performanceMonitoring,
        const DeepCollectionEquality().hash(_mcpServers),
        knowledgeBaseSettings,
        const DeepCollectionEquality().hash(_integrations),
        enableAutoBackup,
        backupFrequencyHours,
        maxBackupCount,
        backupLocation,
        const DeepCollectionEquality().hash(_enabledExperimentalFeatures),
        const DeepCollectionEquality().hash(_featureFlags)
      ]);

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      __$$SettingsStateImplCopyWithImpl<_$SettingsStateImpl>(this, _$identity);
}

abstract class _SettingsState extends SettingsState {
  const factory _SettingsState(
      {final bool isLoading,
      final bool isInitialized,
      final String? error,
      final ThemeMode themeMode,
      final CustomThemeConfig? customTheme,
      final bool useSystemAccentColor,
      final String? customAccentColor,
      final String languageCode,
      final List<LanguageOption> availableLanguages,
      final bool useSystemLanguage,
      final WindowStyle windowStyle,
      final double zoomFactor,
      final bool showSidebarIcons,
      final SidebarIconConfig sidebarIconConfig,
      final bool pinTopicsToTop,
      final TopicPosition topicPosition,
      final bool showTopicTime,
      final AssistantIconType assistantIconType,
      final SendMessageShortcut sendMessageShortcut,
      final bool launchOnBoot,
      final bool launchToTray,
      final bool showInTray,
      final bool minimizeToTrayOnClose,
      final String? defaultChatModel,
      final String? defaultTitleModel,
      final bool showTokens,
      final bool enableStreaming,
      final int maxConversationHistory,
      final bool autoSaveConversations,
      final bool enableDataCollection,
      final bool enableSpellCheck,
      final List<String> spellCheckLanguages,
      final bool enableQuickPanelTriggers,
      final bool enableBackspaceDeleteModel,
      final ExportMenuOptions exportMenuOptions,
      final bool autoCheckUpdates,
      final bool enableEarlyAccess,
      final UpdateChannel updateChannel,
      final String customCss,
      final bool developerMode,
      final bool debugLogging,
      final bool performanceMonitoring,
      final List<McpServerConfig> mcpServers,
      final KnowledgeBaseSettings knowledgeBaseSettings,
      final Map<String, dynamic> integrations,
      final bool enableAutoBackup,
      final int backupFrequencyHours,
      final int maxBackupCount,
      final String? backupLocation,
      final Set<String> enabledExperimentalFeatures,
      final Map<String, bool> featureFlags}) = _$SettingsStateImpl;
  const _SettingsState._() : super._();

// === Loading State ===
  /// Whether settings are currently loading
  @override
  bool get isLoading;

  /// Whether settings have been initialized
  @override
  bool get isInitialized;

  /// Settings loading error
  @override
  String? get error; // === Theme Settings ===
  /// Current theme mode
  @override
  ThemeMode get themeMode;

  /// Custom theme configuration
  @override
  CustomThemeConfig? get customTheme;

  /// Whether to use system accent color
  @override
  bool get useSystemAccentColor;

  /// Custom accent color
  @override
  String? get customAccentColor; // === Language Settings ===
  /// Current language code
  @override
  String get languageCode;

  /// Available languages
  @override
  List<LanguageOption> get availableLanguages;

  /// Whether to use system language
  @override
  bool get useSystemLanguage; // === Display Settings ===
  /// Window style (transparent, opaque)
  @override
  WindowStyle get windowStyle;

  /// Zoom factor for UI scaling
  @override
  double get zoomFactor;

  /// Whether to show sidebar icons
  @override
  bool get showSidebarIcons;

  /// Sidebar icon configuration
  @override
  SidebarIconConfig get sidebarIconConfig;

  /// Whether to pin topics to top
  @override
  bool get pinTopicsToTop;

  /// Topic position (left, right)
  @override
  TopicPosition get topicPosition;

  /// Whether to show topic time
  @override
  bool get showTopicTime;

  /// Assistant icon type
  @override
  AssistantIconType get assistantIconType; // === Behavior Settings ===
  /// Send message shortcut
  @override
  SendMessageShortcut get sendMessageShortcut;

  /// Whether to launch on system boot
  @override
  bool get launchOnBoot;

  /// Whether to launch to system tray
  @override
  bool get launchToTray;

  /// Whether to show in system tray
  @override
  bool get showInTray;

  /// Whether to minimize to tray on close
  @override
  bool get minimizeToTrayOnClose; // === Chat Settings ===
  /// Default chat model
  @override
  String? get defaultChatModel;

  /// Default title generation model
  @override
  String? get defaultTitleModel;

  /// Whether to show tokens in UI
  @override
  bool get showTokens;

  /// Whether to enable streaming responses
  @override
  bool get enableStreaming;

  /// Maximum conversation history length
  @override
  int get maxConversationHistory;

  /// Whether to auto-save conversations
  @override
  bool get autoSaveConversations; // === Privacy Settings ===
  /// Whether to enable data collection
  @override
  bool get enableDataCollection;

  /// Whether to enable spell check
  @override
  bool get enableSpellCheck;

  /// Spell check languages
  @override
  List<String> get spellCheckLanguages;

  /// Whether to enable quick panel triggers
  @override
  bool get enableQuickPanelTriggers;

  /// Whether to enable backspace delete model
  @override
  bool get enableBackspaceDeleteModel; // === Export Settings ===
  /// Export menu options
  @override
  ExportMenuOptions get exportMenuOptions; // === Update Settings ===
  /// Whether to auto-check for updates
  @override
  bool get autoCheckUpdates;

  /// Whether to enable early access updates
  @override
  bool get enableEarlyAccess;

  /// Update channel
  @override
  UpdateChannel get updateChannel; // === Advanced Settings ===
  /// Custom CSS for theming
  @override
  String get customCss;

  /// Developer mode enabled
  @override
  bool get developerMode;

  /// Debug logging enabled
  @override
  bool get debugLogging;

  /// Performance monitoring enabled
  @override
  bool get performanceMonitoring; // === Integration Settings ===
  /// MCP server configurations
  @override
  List<McpServerConfig> get mcpServers;

  /// Knowledge base settings
  @override
  KnowledgeBaseSettings get knowledgeBaseSettings;

  /// External service integrations
  @override
  Map<String, dynamic> get integrations; // === Backup Settings ===
  /// Whether to enable automatic backups
  @override
  bool get enableAutoBackup;

  /// Backup frequency in hours
  @override
  int get backupFrequencyHours;

  /// Maximum number of backups to keep
  @override
  int get maxBackupCount;

  /// Backup location
  @override
  String? get backupLocation; // === Experimental Features ===
  /// Enabled experimental features
  @override
  Set<String> get enabledExperimentalFeatures;

  /// Feature flags
  @override
  Map<String, bool> get featureFlags;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CustomThemeConfig {
  /// Primary color
  String get primaryColor => throw _privateConstructorUsedError;

  /// Secondary color
  String get secondaryColor => throw _privateConstructorUsedError;

  /// Background color
  String get backgroundColor => throw _privateConstructorUsedError;

  /// Surface color
  String get surfaceColor => throw _privateConstructorUsedError;

  /// Text color
  String get textColor => throw _privateConstructorUsedError;

  /// Border radius
  double get borderRadius => throw _privateConstructorUsedError;

  /// Font family
  String get fontFamily => throw _privateConstructorUsedError;

  /// Font size scale
  double get fontSizeScale => throw _privateConstructorUsedError;

  /// Create a copy of CustomThemeConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomThemeConfigCopyWith<CustomThemeConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomThemeConfigCopyWith<$Res> {
  factory $CustomThemeConfigCopyWith(
          CustomThemeConfig value, $Res Function(CustomThemeConfig) then) =
      _$CustomThemeConfigCopyWithImpl<$Res, CustomThemeConfig>;
  @useResult
  $Res call(
      {String primaryColor,
      String secondaryColor,
      String backgroundColor,
      String surfaceColor,
      String textColor,
      double borderRadius,
      String fontFamily,
      double fontSizeScale});
}

/// @nodoc
class _$CustomThemeConfigCopyWithImpl<$Res, $Val extends CustomThemeConfig>
    implements $CustomThemeConfigCopyWith<$Res> {
  _$CustomThemeConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomThemeConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? primaryColor = null,
    Object? secondaryColor = null,
    Object? backgroundColor = null,
    Object? surfaceColor = null,
    Object? textColor = null,
    Object? borderRadius = null,
    Object? fontFamily = null,
    Object? fontSizeScale = null,
  }) {
    return _then(_value.copyWith(
      primaryColor: null == primaryColor
          ? _value.primaryColor
          : primaryColor // ignore: cast_nullable_to_non_nullable
              as String,
      secondaryColor: null == secondaryColor
          ? _value.secondaryColor
          : secondaryColor // ignore: cast_nullable_to_non_nullable
              as String,
      backgroundColor: null == backgroundColor
          ? _value.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as String,
      surfaceColor: null == surfaceColor
          ? _value.surfaceColor
          : surfaceColor // ignore: cast_nullable_to_non_nullable
              as String,
      textColor: null == textColor
          ? _value.textColor
          : textColor // ignore: cast_nullable_to_non_nullable
              as String,
      borderRadius: null == borderRadius
          ? _value.borderRadius
          : borderRadius // ignore: cast_nullable_to_non_nullable
              as double,
      fontFamily: null == fontFamily
          ? _value.fontFamily
          : fontFamily // ignore: cast_nullable_to_non_nullable
              as String,
      fontSizeScale: null == fontSizeScale
          ? _value.fontSizeScale
          : fontSizeScale // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CustomThemeConfigImplCopyWith<$Res>
    implements $CustomThemeConfigCopyWith<$Res> {
  factory _$$CustomThemeConfigImplCopyWith(_$CustomThemeConfigImpl value,
          $Res Function(_$CustomThemeConfigImpl) then) =
      __$$CustomThemeConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String primaryColor,
      String secondaryColor,
      String backgroundColor,
      String surfaceColor,
      String textColor,
      double borderRadius,
      String fontFamily,
      double fontSizeScale});
}

/// @nodoc
class __$$CustomThemeConfigImplCopyWithImpl<$Res>
    extends _$CustomThemeConfigCopyWithImpl<$Res, _$CustomThemeConfigImpl>
    implements _$$CustomThemeConfigImplCopyWith<$Res> {
  __$$CustomThemeConfigImplCopyWithImpl(_$CustomThemeConfigImpl _value,
      $Res Function(_$CustomThemeConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of CustomThemeConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? primaryColor = null,
    Object? secondaryColor = null,
    Object? backgroundColor = null,
    Object? surfaceColor = null,
    Object? textColor = null,
    Object? borderRadius = null,
    Object? fontFamily = null,
    Object? fontSizeScale = null,
  }) {
    return _then(_$CustomThemeConfigImpl(
      primaryColor: null == primaryColor
          ? _value.primaryColor
          : primaryColor // ignore: cast_nullable_to_non_nullable
              as String,
      secondaryColor: null == secondaryColor
          ? _value.secondaryColor
          : secondaryColor // ignore: cast_nullable_to_non_nullable
              as String,
      backgroundColor: null == backgroundColor
          ? _value.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as String,
      surfaceColor: null == surfaceColor
          ? _value.surfaceColor
          : surfaceColor // ignore: cast_nullable_to_non_nullable
              as String,
      textColor: null == textColor
          ? _value.textColor
          : textColor // ignore: cast_nullable_to_non_nullable
              as String,
      borderRadius: null == borderRadius
          ? _value.borderRadius
          : borderRadius // ignore: cast_nullable_to_non_nullable
              as double,
      fontFamily: null == fontFamily
          ? _value.fontFamily
          : fontFamily // ignore: cast_nullable_to_non_nullable
              as String,
      fontSizeScale: null == fontSizeScale
          ? _value.fontSizeScale
          : fontSizeScale // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$CustomThemeConfigImpl implements _CustomThemeConfig {
  const _$CustomThemeConfigImpl(
      {this.primaryColor = '#2196F3',
      this.secondaryColor = '#FF9800',
      this.backgroundColor = '#FFFFFF',
      this.surfaceColor = '#F5F5F5',
      this.textColor = '#212121',
      this.borderRadius = 8.0,
      this.fontFamily = 'system',
      this.fontSizeScale = 1.0});

  /// Primary color
  @override
  @JsonKey()
  final String primaryColor;

  /// Secondary color
  @override
  @JsonKey()
  final String secondaryColor;

  /// Background color
  @override
  @JsonKey()
  final String backgroundColor;

  /// Surface color
  @override
  @JsonKey()
  final String surfaceColor;

  /// Text color
  @override
  @JsonKey()
  final String textColor;

  /// Border radius
  @override
  @JsonKey()
  final double borderRadius;

  /// Font family
  @override
  @JsonKey()
  final String fontFamily;

  /// Font size scale
  @override
  @JsonKey()
  final double fontSizeScale;

  @override
  String toString() {
    return 'CustomThemeConfig(primaryColor: $primaryColor, secondaryColor: $secondaryColor, backgroundColor: $backgroundColor, surfaceColor: $surfaceColor, textColor: $textColor, borderRadius: $borderRadius, fontFamily: $fontFamily, fontSizeScale: $fontSizeScale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomThemeConfigImpl &&
            (identical(other.primaryColor, primaryColor) ||
                other.primaryColor == primaryColor) &&
            (identical(other.secondaryColor, secondaryColor) ||
                other.secondaryColor == secondaryColor) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.surfaceColor, surfaceColor) ||
                other.surfaceColor == surfaceColor) &&
            (identical(other.textColor, textColor) ||
                other.textColor == textColor) &&
            (identical(other.borderRadius, borderRadius) ||
                other.borderRadius == borderRadius) &&
            (identical(other.fontFamily, fontFamily) ||
                other.fontFamily == fontFamily) &&
            (identical(other.fontSizeScale, fontSizeScale) ||
                other.fontSizeScale == fontSizeScale));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      primaryColor,
      secondaryColor,
      backgroundColor,
      surfaceColor,
      textColor,
      borderRadius,
      fontFamily,
      fontSizeScale);

  /// Create a copy of CustomThemeConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomThemeConfigImplCopyWith<_$CustomThemeConfigImpl> get copyWith =>
      __$$CustomThemeConfigImplCopyWithImpl<_$CustomThemeConfigImpl>(
          this, _$identity);
}

abstract class _CustomThemeConfig implements CustomThemeConfig {
  const factory _CustomThemeConfig(
      {final String primaryColor,
      final String secondaryColor,
      final String backgroundColor,
      final String surfaceColor,
      final String textColor,
      final double borderRadius,
      final String fontFamily,
      final double fontSizeScale}) = _$CustomThemeConfigImpl;

  /// Primary color
  @override
  String get primaryColor;

  /// Secondary color
  @override
  String get secondaryColor;

  /// Background color
  @override
  String get backgroundColor;

  /// Surface color
  @override
  String get surfaceColor;

  /// Text color
  @override
  String get textColor;

  /// Border radius
  @override
  double get borderRadius;

  /// Font family
  @override
  String get fontFamily;

  /// Font size scale
  @override
  double get fontSizeScale;

  /// Create a copy of CustomThemeConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomThemeConfigImplCopyWith<_$CustomThemeConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$LanguageOption {
  /// Language code (e.g., 'en', 'zh-CN')
  String get code => throw _privateConstructorUsedError;

  /// Display name
  String get name => throw _privateConstructorUsedError;

  /// Native name
  String get nativeName => throw _privateConstructorUsedError;

  /// Whether this language is supported
  bool get isSupported => throw _privateConstructorUsedError;

  /// Create a copy of LanguageOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LanguageOptionCopyWith<LanguageOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LanguageOptionCopyWith<$Res> {
  factory $LanguageOptionCopyWith(
          LanguageOption value, $Res Function(LanguageOption) then) =
      _$LanguageOptionCopyWithImpl<$Res, LanguageOption>;
  @useResult
  $Res call({String code, String name, String nativeName, bool isSupported});
}

/// @nodoc
class _$LanguageOptionCopyWithImpl<$Res, $Val extends LanguageOption>
    implements $LanguageOptionCopyWith<$Res> {
  _$LanguageOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LanguageOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? nativeName = null,
    Object? isSupported = null,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nativeName: null == nativeName
          ? _value.nativeName
          : nativeName // ignore: cast_nullable_to_non_nullable
              as String,
      isSupported: null == isSupported
          ? _value.isSupported
          : isSupported // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LanguageOptionImplCopyWith<$Res>
    implements $LanguageOptionCopyWith<$Res> {
  factory _$$LanguageOptionImplCopyWith(_$LanguageOptionImpl value,
          $Res Function(_$LanguageOptionImpl) then) =
      __$$LanguageOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, String name, String nativeName, bool isSupported});
}

/// @nodoc
class __$$LanguageOptionImplCopyWithImpl<$Res>
    extends _$LanguageOptionCopyWithImpl<$Res, _$LanguageOptionImpl>
    implements _$$LanguageOptionImplCopyWith<$Res> {
  __$$LanguageOptionImplCopyWithImpl(
      _$LanguageOptionImpl _value, $Res Function(_$LanguageOptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of LanguageOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? nativeName = null,
    Object? isSupported = null,
  }) {
    return _then(_$LanguageOptionImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nativeName: null == nativeName
          ? _value.nativeName
          : nativeName // ignore: cast_nullable_to_non_nullable
              as String,
      isSupported: null == isSupported
          ? _value.isSupported
          : isSupported // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$LanguageOptionImpl implements _LanguageOption {
  const _$LanguageOptionImpl(
      {required this.code,
      required this.name,
      required this.nativeName,
      this.isSupported = true});

  /// Language code (e.g., 'en', 'zh-CN')
  @override
  final String code;

  /// Display name
  @override
  final String name;

  /// Native name
  @override
  final String nativeName;

  /// Whether this language is supported
  @override
  @JsonKey()
  final bool isSupported;

  @override
  String toString() {
    return 'LanguageOption(code: $code, name: $name, nativeName: $nativeName, isSupported: $isSupported)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LanguageOptionImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nativeName, nativeName) ||
                other.nativeName == nativeName) &&
            (identical(other.isSupported, isSupported) ||
                other.isSupported == isSupported));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, code, name, nativeName, isSupported);

  /// Create a copy of LanguageOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LanguageOptionImplCopyWith<_$LanguageOptionImpl> get copyWith =>
      __$$LanguageOptionImplCopyWithImpl<_$LanguageOptionImpl>(
          this, _$identity);
}

abstract class _LanguageOption implements LanguageOption {
  const factory _LanguageOption(
      {required final String code,
      required final String name,
      required final String nativeName,
      final bool isSupported}) = _$LanguageOptionImpl;

  /// Language code (e.g., 'en', 'zh-CN')
  @override
  String get code;

  /// Display name
  @override
  String get name;

  /// Native name
  @override
  String get nativeName;

  /// Whether this language is supported
  @override
  bool get isSupported;

  /// Create a copy of LanguageOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LanguageOptionImplCopyWith<_$LanguageOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SidebarIconConfig {
  /// Visible icons in order
  List<String> get visibleIcons => throw _privateConstructorUsedError;

  /// Disabled icons
  List<String> get disabledIcons => throw _privateConstructorUsedError;

  /// Icon size
  double get iconSize => throw _privateConstructorUsedError;

  /// Icon spacing
  double get iconSpacing => throw _privateConstructorUsedError;

  /// Create a copy of SidebarIconConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SidebarIconConfigCopyWith<SidebarIconConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SidebarIconConfigCopyWith<$Res> {
  factory $SidebarIconConfigCopyWith(
          SidebarIconConfig value, $Res Function(SidebarIconConfig) then) =
      _$SidebarIconConfigCopyWithImpl<$Res, SidebarIconConfig>;
  @useResult
  $Res call(
      {List<String> visibleIcons,
      List<String> disabledIcons,
      double iconSize,
      double iconSpacing});
}

/// @nodoc
class _$SidebarIconConfigCopyWithImpl<$Res, $Val extends SidebarIconConfig>
    implements $SidebarIconConfigCopyWith<$Res> {
  _$SidebarIconConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SidebarIconConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? visibleIcons = null,
    Object? disabledIcons = null,
    Object? iconSize = null,
    Object? iconSpacing = null,
  }) {
    return _then(_value.copyWith(
      visibleIcons: null == visibleIcons
          ? _value.visibleIcons
          : visibleIcons // ignore: cast_nullable_to_non_nullable
              as List<String>,
      disabledIcons: null == disabledIcons
          ? _value.disabledIcons
          : disabledIcons // ignore: cast_nullable_to_non_nullable
              as List<String>,
      iconSize: null == iconSize
          ? _value.iconSize
          : iconSize // ignore: cast_nullable_to_non_nullable
              as double,
      iconSpacing: null == iconSpacing
          ? _value.iconSpacing
          : iconSpacing // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SidebarIconConfigImplCopyWith<$Res>
    implements $SidebarIconConfigCopyWith<$Res> {
  factory _$$SidebarIconConfigImplCopyWith(_$SidebarIconConfigImpl value,
          $Res Function(_$SidebarIconConfigImpl) then) =
      __$$SidebarIconConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> visibleIcons,
      List<String> disabledIcons,
      double iconSize,
      double iconSpacing});
}

/// @nodoc
class __$$SidebarIconConfigImplCopyWithImpl<$Res>
    extends _$SidebarIconConfigCopyWithImpl<$Res, _$SidebarIconConfigImpl>
    implements _$$SidebarIconConfigImplCopyWith<$Res> {
  __$$SidebarIconConfigImplCopyWithImpl(_$SidebarIconConfigImpl _value,
      $Res Function(_$SidebarIconConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of SidebarIconConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? visibleIcons = null,
    Object? disabledIcons = null,
    Object? iconSize = null,
    Object? iconSpacing = null,
  }) {
    return _then(_$SidebarIconConfigImpl(
      visibleIcons: null == visibleIcons
          ? _value._visibleIcons
          : visibleIcons // ignore: cast_nullable_to_non_nullable
              as List<String>,
      disabledIcons: null == disabledIcons
          ? _value._disabledIcons
          : disabledIcons // ignore: cast_nullable_to_non_nullable
              as List<String>,
      iconSize: null == iconSize
          ? _value.iconSize
          : iconSize // ignore: cast_nullable_to_non_nullable
              as double,
      iconSpacing: null == iconSpacing
          ? _value.iconSpacing
          : iconSpacing // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$SidebarIconConfigImpl implements _SidebarIconConfig {
  const _$SidebarIconConfigImpl(
      {final List<String> visibleIcons = const [],
      final List<String> disabledIcons = const [],
      this.iconSize = 20.0,
      this.iconSpacing = 8.0})
      : _visibleIcons = visibleIcons,
        _disabledIcons = disabledIcons;

  /// Visible icons in order
  final List<String> _visibleIcons;

  /// Visible icons in order
  @override
  @JsonKey()
  List<String> get visibleIcons {
    if (_visibleIcons is EqualUnmodifiableListView) return _visibleIcons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_visibleIcons);
  }

  /// Disabled icons
  final List<String> _disabledIcons;

  /// Disabled icons
  @override
  @JsonKey()
  List<String> get disabledIcons {
    if (_disabledIcons is EqualUnmodifiableListView) return _disabledIcons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_disabledIcons);
  }

  /// Icon size
  @override
  @JsonKey()
  final double iconSize;

  /// Icon spacing
  @override
  @JsonKey()
  final double iconSpacing;

  @override
  String toString() {
    return 'SidebarIconConfig(visibleIcons: $visibleIcons, disabledIcons: $disabledIcons, iconSize: $iconSize, iconSpacing: $iconSpacing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SidebarIconConfigImpl &&
            const DeepCollectionEquality()
                .equals(other._visibleIcons, _visibleIcons) &&
            const DeepCollectionEquality()
                .equals(other._disabledIcons, _disabledIcons) &&
            (identical(other.iconSize, iconSize) ||
                other.iconSize == iconSize) &&
            (identical(other.iconSpacing, iconSpacing) ||
                other.iconSpacing == iconSpacing));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_visibleIcons),
      const DeepCollectionEquality().hash(_disabledIcons),
      iconSize,
      iconSpacing);

  /// Create a copy of SidebarIconConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SidebarIconConfigImplCopyWith<_$SidebarIconConfigImpl> get copyWith =>
      __$$SidebarIconConfigImplCopyWithImpl<_$SidebarIconConfigImpl>(
          this, _$identity);
}

abstract class _SidebarIconConfig implements SidebarIconConfig {
  const factory _SidebarIconConfig(
      {final List<String> visibleIcons,
      final List<String> disabledIcons,
      final double iconSize,
      final double iconSpacing}) = _$SidebarIconConfigImpl;

  /// Visible icons in order
  @override
  List<String> get visibleIcons;

  /// Disabled icons
  @override
  List<String> get disabledIcons;

  /// Icon size
  @override
  double get iconSize;

  /// Icon spacing
  @override
  double get iconSpacing;

  /// Create a copy of SidebarIconConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SidebarIconConfigImplCopyWith<_$SidebarIconConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ExportMenuOptions {
  /// Enable image export
  bool get image => throw _privateConstructorUsedError;

  /// Enable markdown export
  bool get markdown => throw _privateConstructorUsedError;

  /// Enable markdown with reasoning export
  bool get markdownReason => throw _privateConstructorUsedError;

  /// Enable Notion export
  bool get notion => throw _privateConstructorUsedError;

  /// Enable Yuque export
  bool get yuque => throw _privateConstructorUsedError;

  /// Enable Joplin export
  bool get joplin => throw _privateConstructorUsedError;

  /// Enable Obsidian export
  bool get obsidian => throw _privateConstructorUsedError;

  /// Enable SiYuan export
  bool get siyuan => throw _privateConstructorUsedError;

  /// Enable DOCX export
  bool get docx => throw _privateConstructorUsedError;

  /// Enable plain text export
  bool get plainText => throw _privateConstructorUsedError;

  /// Create a copy of ExportMenuOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExportMenuOptionsCopyWith<ExportMenuOptions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExportMenuOptionsCopyWith<$Res> {
  factory $ExportMenuOptionsCopyWith(
          ExportMenuOptions value, $Res Function(ExportMenuOptions) then) =
      _$ExportMenuOptionsCopyWithImpl<$Res, ExportMenuOptions>;
  @useResult
  $Res call(
      {bool image,
      bool markdown,
      bool markdownReason,
      bool notion,
      bool yuque,
      bool joplin,
      bool obsidian,
      bool siyuan,
      bool docx,
      bool plainText});
}

/// @nodoc
class _$ExportMenuOptionsCopyWithImpl<$Res, $Val extends ExportMenuOptions>
    implements $ExportMenuOptionsCopyWith<$Res> {
  _$ExportMenuOptionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExportMenuOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? image = null,
    Object? markdown = null,
    Object? markdownReason = null,
    Object? notion = null,
    Object? yuque = null,
    Object? joplin = null,
    Object? obsidian = null,
    Object? siyuan = null,
    Object? docx = null,
    Object? plainText = null,
  }) {
    return _then(_value.copyWith(
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as bool,
      markdown: null == markdown
          ? _value.markdown
          : markdown // ignore: cast_nullable_to_non_nullable
              as bool,
      markdownReason: null == markdownReason
          ? _value.markdownReason
          : markdownReason // ignore: cast_nullable_to_non_nullable
              as bool,
      notion: null == notion
          ? _value.notion
          : notion // ignore: cast_nullable_to_non_nullable
              as bool,
      yuque: null == yuque
          ? _value.yuque
          : yuque // ignore: cast_nullable_to_non_nullable
              as bool,
      joplin: null == joplin
          ? _value.joplin
          : joplin // ignore: cast_nullable_to_non_nullable
              as bool,
      obsidian: null == obsidian
          ? _value.obsidian
          : obsidian // ignore: cast_nullable_to_non_nullable
              as bool,
      siyuan: null == siyuan
          ? _value.siyuan
          : siyuan // ignore: cast_nullable_to_non_nullable
              as bool,
      docx: null == docx
          ? _value.docx
          : docx // ignore: cast_nullable_to_non_nullable
              as bool,
      plainText: null == plainText
          ? _value.plainText
          : plainText // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExportMenuOptionsImplCopyWith<$Res>
    implements $ExportMenuOptionsCopyWith<$Res> {
  factory _$$ExportMenuOptionsImplCopyWith(_$ExportMenuOptionsImpl value,
          $Res Function(_$ExportMenuOptionsImpl) then) =
      __$$ExportMenuOptionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool image,
      bool markdown,
      bool markdownReason,
      bool notion,
      bool yuque,
      bool joplin,
      bool obsidian,
      bool siyuan,
      bool docx,
      bool plainText});
}

/// @nodoc
class __$$ExportMenuOptionsImplCopyWithImpl<$Res>
    extends _$ExportMenuOptionsCopyWithImpl<$Res, _$ExportMenuOptionsImpl>
    implements _$$ExportMenuOptionsImplCopyWith<$Res> {
  __$$ExportMenuOptionsImplCopyWithImpl(_$ExportMenuOptionsImpl _value,
      $Res Function(_$ExportMenuOptionsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ExportMenuOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? image = null,
    Object? markdown = null,
    Object? markdownReason = null,
    Object? notion = null,
    Object? yuque = null,
    Object? joplin = null,
    Object? obsidian = null,
    Object? siyuan = null,
    Object? docx = null,
    Object? plainText = null,
  }) {
    return _then(_$ExportMenuOptionsImpl(
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as bool,
      markdown: null == markdown
          ? _value.markdown
          : markdown // ignore: cast_nullable_to_non_nullable
              as bool,
      markdownReason: null == markdownReason
          ? _value.markdownReason
          : markdownReason // ignore: cast_nullable_to_non_nullable
              as bool,
      notion: null == notion
          ? _value.notion
          : notion // ignore: cast_nullable_to_non_nullable
              as bool,
      yuque: null == yuque
          ? _value.yuque
          : yuque // ignore: cast_nullable_to_non_nullable
              as bool,
      joplin: null == joplin
          ? _value.joplin
          : joplin // ignore: cast_nullable_to_non_nullable
              as bool,
      obsidian: null == obsidian
          ? _value.obsidian
          : obsidian // ignore: cast_nullable_to_non_nullable
              as bool,
      siyuan: null == siyuan
          ? _value.siyuan
          : siyuan // ignore: cast_nullable_to_non_nullable
              as bool,
      docx: null == docx
          ? _value.docx
          : docx // ignore: cast_nullable_to_non_nullable
              as bool,
      plainText: null == plainText
          ? _value.plainText
          : plainText // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ExportMenuOptionsImpl implements _ExportMenuOptions {
  const _$ExportMenuOptionsImpl(
      {this.image = true,
      this.markdown = true,
      this.markdownReason = false,
      this.notion = false,
      this.yuque = false,
      this.joplin = false,
      this.obsidian = false,
      this.siyuan = false,
      this.docx = false,
      this.plainText = true});

  /// Enable image export
  @override
  @JsonKey()
  final bool image;

  /// Enable markdown export
  @override
  @JsonKey()
  final bool markdown;

  /// Enable markdown with reasoning export
  @override
  @JsonKey()
  final bool markdownReason;

  /// Enable Notion export
  @override
  @JsonKey()
  final bool notion;

  /// Enable Yuque export
  @override
  @JsonKey()
  final bool yuque;

  /// Enable Joplin export
  @override
  @JsonKey()
  final bool joplin;

  /// Enable Obsidian export
  @override
  @JsonKey()
  final bool obsidian;

  /// Enable SiYuan export
  @override
  @JsonKey()
  final bool siyuan;

  /// Enable DOCX export
  @override
  @JsonKey()
  final bool docx;

  /// Enable plain text export
  @override
  @JsonKey()
  final bool plainText;

  @override
  String toString() {
    return 'ExportMenuOptions(image: $image, markdown: $markdown, markdownReason: $markdownReason, notion: $notion, yuque: $yuque, joplin: $joplin, obsidian: $obsidian, siyuan: $siyuan, docx: $docx, plainText: $plainText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExportMenuOptionsImpl &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.markdown, markdown) ||
                other.markdown == markdown) &&
            (identical(other.markdownReason, markdownReason) ||
                other.markdownReason == markdownReason) &&
            (identical(other.notion, notion) || other.notion == notion) &&
            (identical(other.yuque, yuque) || other.yuque == yuque) &&
            (identical(other.joplin, joplin) || other.joplin == joplin) &&
            (identical(other.obsidian, obsidian) ||
                other.obsidian == obsidian) &&
            (identical(other.siyuan, siyuan) || other.siyuan == siyuan) &&
            (identical(other.docx, docx) || other.docx == docx) &&
            (identical(other.plainText, plainText) ||
                other.plainText == plainText));
  }

  @override
  int get hashCode => Object.hash(runtimeType, image, markdown, markdownReason,
      notion, yuque, joplin, obsidian, siyuan, docx, plainText);

  /// Create a copy of ExportMenuOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExportMenuOptionsImplCopyWith<_$ExportMenuOptionsImpl> get copyWith =>
      __$$ExportMenuOptionsImplCopyWithImpl<_$ExportMenuOptionsImpl>(
          this, _$identity);
}

abstract class _ExportMenuOptions implements ExportMenuOptions {
  const factory _ExportMenuOptions(
      {final bool image,
      final bool markdown,
      final bool markdownReason,
      final bool notion,
      final bool yuque,
      final bool joplin,
      final bool obsidian,
      final bool siyuan,
      final bool docx,
      final bool plainText}) = _$ExportMenuOptionsImpl;

  /// Enable image export
  @override
  bool get image;

  /// Enable markdown export
  @override
  bool get markdown;

  /// Enable markdown with reasoning export
  @override
  bool get markdownReason;

  /// Enable Notion export
  @override
  bool get notion;

  /// Enable Yuque export
  @override
  bool get yuque;

  /// Enable Joplin export
  @override
  bool get joplin;

  /// Enable Obsidian export
  @override
  bool get obsidian;

  /// Enable SiYuan export
  @override
  bool get siyuan;

  /// Enable DOCX export
  @override
  bool get docx;

  /// Enable plain text export
  @override
  bool get plainText;

  /// Create a copy of ExportMenuOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExportMenuOptionsImplCopyWith<_$ExportMenuOptionsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$McpServerConfig {
  /// Server ID
  String get id => throw _privateConstructorUsedError;

  /// Server name
  String get name => throw _privateConstructorUsedError;

  /// Server command
  String get command => throw _privateConstructorUsedError;

  /// Server arguments
  List<String> get args => throw _privateConstructorUsedError;

  /// Environment variables
  Map<String, String> get env => throw _privateConstructorUsedError;

  /// Whether server is enabled
  bool get enabled => throw _privateConstructorUsedError;

  /// Server description
  String get description => throw _privateConstructorUsedError;

  /// Create a copy of McpServerConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $McpServerConfigCopyWith<McpServerConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $McpServerConfigCopyWith<$Res> {
  factory $McpServerConfigCopyWith(
          McpServerConfig value, $Res Function(McpServerConfig) then) =
      _$McpServerConfigCopyWithImpl<$Res, McpServerConfig>;
  @useResult
  $Res call(
      {String id,
      String name,
      String command,
      List<String> args,
      Map<String, String> env,
      bool enabled,
      String description});
}

/// @nodoc
class _$McpServerConfigCopyWithImpl<$Res, $Val extends McpServerConfig>
    implements $McpServerConfigCopyWith<$Res> {
  _$McpServerConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of McpServerConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? command = null,
    Object? args = null,
    Object? env = null,
    Object? enabled = null,
    Object? description = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      command: null == command
          ? _value.command
          : command // ignore: cast_nullable_to_non_nullable
              as String,
      args: null == args
          ? _value.args
          : args // ignore: cast_nullable_to_non_nullable
              as List<String>,
      env: null == env
          ? _value.env
          : env // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$McpServerConfigImplCopyWith<$Res>
    implements $McpServerConfigCopyWith<$Res> {
  factory _$$McpServerConfigImplCopyWith(_$McpServerConfigImpl value,
          $Res Function(_$McpServerConfigImpl) then) =
      __$$McpServerConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String command,
      List<String> args,
      Map<String, String> env,
      bool enabled,
      String description});
}

/// @nodoc
class __$$McpServerConfigImplCopyWithImpl<$Res>
    extends _$McpServerConfigCopyWithImpl<$Res, _$McpServerConfigImpl>
    implements _$$McpServerConfigImplCopyWith<$Res> {
  __$$McpServerConfigImplCopyWithImpl(
      _$McpServerConfigImpl _value, $Res Function(_$McpServerConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of McpServerConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? command = null,
    Object? args = null,
    Object? env = null,
    Object? enabled = null,
    Object? description = null,
  }) {
    return _then(_$McpServerConfigImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      command: null == command
          ? _value.command
          : command // ignore: cast_nullable_to_non_nullable
              as String,
      args: null == args
          ? _value._args
          : args // ignore: cast_nullable_to_non_nullable
              as List<String>,
      env: null == env
          ? _value._env
          : env // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$McpServerConfigImpl implements _McpServerConfig {
  const _$McpServerConfigImpl(
      {required this.id,
      required this.name,
      required this.command,
      final List<String> args = const [],
      final Map<String, String> env = const {},
      this.enabled = true,
      this.description = ''})
      : _args = args,
        _env = env;

  /// Server ID
  @override
  final String id;

  /// Server name
  @override
  final String name;

  /// Server command
  @override
  final String command;

  /// Server arguments
  final List<String> _args;

  /// Server arguments
  @override
  @JsonKey()
  List<String> get args {
    if (_args is EqualUnmodifiableListView) return _args;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_args);
  }

  /// Environment variables
  final Map<String, String> _env;

  /// Environment variables
  @override
  @JsonKey()
  Map<String, String> get env {
    if (_env is EqualUnmodifiableMapView) return _env;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_env);
  }

  /// Whether server is enabled
  @override
  @JsonKey()
  final bool enabled;

  /// Server description
  @override
  @JsonKey()
  final String description;

  @override
  String toString() {
    return 'McpServerConfig(id: $id, name: $name, command: $command, args: $args, env: $env, enabled: $enabled, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$McpServerConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.command, command) || other.command == command) &&
            const DeepCollectionEquality().equals(other._args, _args) &&
            const DeepCollectionEquality().equals(other._env, _env) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      command,
      const DeepCollectionEquality().hash(_args),
      const DeepCollectionEquality().hash(_env),
      enabled,
      description);

  /// Create a copy of McpServerConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$McpServerConfigImplCopyWith<_$McpServerConfigImpl> get copyWith =>
      __$$McpServerConfigImplCopyWithImpl<_$McpServerConfigImpl>(
          this, _$identity);
}

abstract class _McpServerConfig implements McpServerConfig {
  const factory _McpServerConfig(
      {required final String id,
      required final String name,
      required final String command,
      final List<String> args,
      final Map<String, String> env,
      final bool enabled,
      final String description}) = _$McpServerConfigImpl;

  /// Server ID
  @override
  String get id;

  /// Server name
  @override
  String get name;

  /// Server command
  @override
  String get command;

  /// Server arguments
  @override
  List<String> get args;

  /// Environment variables
  @override
  Map<String, String> get env;

  /// Whether server is enabled
  @override
  bool get enabled;

  /// Server description
  @override
  String get description;

  /// Create a copy of McpServerConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$McpServerConfigImplCopyWith<_$McpServerConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$KnowledgeBaseSettings {
  /// Whether knowledge base is enabled
  bool get enabled => throw _privateConstructorUsedError;

  /// Default knowledge base path
  String get defaultPath => throw _privateConstructorUsedError;

  /// Indexing settings
  IndexingSettings get indexingSettings => throw _privateConstructorUsedError;

  /// Search settings
  SearchSettings get searchSettings => throw _privateConstructorUsedError;

  /// Create a copy of KnowledgeBaseSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KnowledgeBaseSettingsCopyWith<KnowledgeBaseSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KnowledgeBaseSettingsCopyWith<$Res> {
  factory $KnowledgeBaseSettingsCopyWith(KnowledgeBaseSettings value,
          $Res Function(KnowledgeBaseSettings) then) =
      _$KnowledgeBaseSettingsCopyWithImpl<$Res, KnowledgeBaseSettings>;
  @useResult
  $Res call(
      {bool enabled,
      String defaultPath,
      IndexingSettings indexingSettings,
      SearchSettings searchSettings});

  $IndexingSettingsCopyWith<$Res> get indexingSettings;
  $SearchSettingsCopyWith<$Res> get searchSettings;
}

/// @nodoc
class _$KnowledgeBaseSettingsCopyWithImpl<$Res,
        $Val extends KnowledgeBaseSettings>
    implements $KnowledgeBaseSettingsCopyWith<$Res> {
  _$KnowledgeBaseSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KnowledgeBaseSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? defaultPath = null,
    Object? indexingSettings = null,
    Object? searchSettings = null,
  }) {
    return _then(_value.copyWith(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultPath: null == defaultPath
          ? _value.defaultPath
          : defaultPath // ignore: cast_nullable_to_non_nullable
              as String,
      indexingSettings: null == indexingSettings
          ? _value.indexingSettings
          : indexingSettings // ignore: cast_nullable_to_non_nullable
              as IndexingSettings,
      searchSettings: null == searchSettings
          ? _value.searchSettings
          : searchSettings // ignore: cast_nullable_to_non_nullable
              as SearchSettings,
    ) as $Val);
  }

  /// Create a copy of KnowledgeBaseSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IndexingSettingsCopyWith<$Res> get indexingSettings {
    return $IndexingSettingsCopyWith<$Res>(_value.indexingSettings, (value) {
      return _then(_value.copyWith(indexingSettings: value) as $Val);
    });
  }

  /// Create a copy of KnowledgeBaseSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SearchSettingsCopyWith<$Res> get searchSettings {
    return $SearchSettingsCopyWith<$Res>(_value.searchSettings, (value) {
      return _then(_value.copyWith(searchSettings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$KnowledgeBaseSettingsImplCopyWith<$Res>
    implements $KnowledgeBaseSettingsCopyWith<$Res> {
  factory _$$KnowledgeBaseSettingsImplCopyWith(
          _$KnowledgeBaseSettingsImpl value,
          $Res Function(_$KnowledgeBaseSettingsImpl) then) =
      __$$KnowledgeBaseSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enabled,
      String defaultPath,
      IndexingSettings indexingSettings,
      SearchSettings searchSettings});

  @override
  $IndexingSettingsCopyWith<$Res> get indexingSettings;
  @override
  $SearchSettingsCopyWith<$Res> get searchSettings;
}

/// @nodoc
class __$$KnowledgeBaseSettingsImplCopyWithImpl<$Res>
    extends _$KnowledgeBaseSettingsCopyWithImpl<$Res,
        _$KnowledgeBaseSettingsImpl>
    implements _$$KnowledgeBaseSettingsImplCopyWith<$Res> {
  __$$KnowledgeBaseSettingsImplCopyWithImpl(_$KnowledgeBaseSettingsImpl _value,
      $Res Function(_$KnowledgeBaseSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of KnowledgeBaseSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? defaultPath = null,
    Object? indexingSettings = null,
    Object? searchSettings = null,
  }) {
    return _then(_$KnowledgeBaseSettingsImpl(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultPath: null == defaultPath
          ? _value.defaultPath
          : defaultPath // ignore: cast_nullable_to_non_nullable
              as String,
      indexingSettings: null == indexingSettings
          ? _value.indexingSettings
          : indexingSettings // ignore: cast_nullable_to_non_nullable
              as IndexingSettings,
      searchSettings: null == searchSettings
          ? _value.searchSettings
          : searchSettings // ignore: cast_nullable_to_non_nullable
              as SearchSettings,
    ));
  }
}

/// @nodoc

class _$KnowledgeBaseSettingsImpl implements _KnowledgeBaseSettings {
  const _$KnowledgeBaseSettingsImpl(
      {this.enabled = true,
      this.defaultPath = '',
      this.indexingSettings = const IndexingSettings(),
      this.searchSettings = const SearchSettings()});

  /// Whether knowledge base is enabled
  @override
  @JsonKey()
  final bool enabled;

  /// Default knowledge base path
  @override
  @JsonKey()
  final String defaultPath;

  /// Indexing settings
  @override
  @JsonKey()
  final IndexingSettings indexingSettings;

  /// Search settings
  @override
  @JsonKey()
  final SearchSettings searchSettings;

  @override
  String toString() {
    return 'KnowledgeBaseSettings(enabled: $enabled, defaultPath: $defaultPath, indexingSettings: $indexingSettings, searchSettings: $searchSettings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KnowledgeBaseSettingsImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.defaultPath, defaultPath) ||
                other.defaultPath == defaultPath) &&
            (identical(other.indexingSettings, indexingSettings) ||
                other.indexingSettings == indexingSettings) &&
            (identical(other.searchSettings, searchSettings) ||
                other.searchSettings == searchSettings));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, enabled, defaultPath, indexingSettings, searchSettings);

  /// Create a copy of KnowledgeBaseSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KnowledgeBaseSettingsImplCopyWith<_$KnowledgeBaseSettingsImpl>
      get copyWith => __$$KnowledgeBaseSettingsImplCopyWithImpl<
          _$KnowledgeBaseSettingsImpl>(this, _$identity);
}

abstract class _KnowledgeBaseSettings implements KnowledgeBaseSettings {
  const factory _KnowledgeBaseSettings(
      {final bool enabled,
      final String defaultPath,
      final IndexingSettings indexingSettings,
      final SearchSettings searchSettings}) = _$KnowledgeBaseSettingsImpl;

  /// Whether knowledge base is enabled
  @override
  bool get enabled;

  /// Default knowledge base path
  @override
  String get defaultPath;

  /// Indexing settings
  @override
  IndexingSettings get indexingSettings;

  /// Search settings
  @override
  SearchSettings get searchSettings;

  /// Create a copy of KnowledgeBaseSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KnowledgeBaseSettingsImplCopyWith<_$KnowledgeBaseSettingsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$IndexingSettings {
  /// Whether to auto-index files
  bool get autoIndex => throw _privateConstructorUsedError;

  /// Supported file extensions
  List<String> get supportedExtensions => throw _privateConstructorUsedError;

  /// Maximum file size in MB
  int get maxFileSizeMB => throw _privateConstructorUsedError;

  /// Indexing interval in minutes
  int get indexingIntervalMinutes => throw _privateConstructorUsedError;

  /// Create a copy of IndexingSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IndexingSettingsCopyWith<IndexingSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IndexingSettingsCopyWith<$Res> {
  factory $IndexingSettingsCopyWith(
          IndexingSettings value, $Res Function(IndexingSettings) then) =
      _$IndexingSettingsCopyWithImpl<$Res, IndexingSettings>;
  @useResult
  $Res call(
      {bool autoIndex,
      List<String> supportedExtensions,
      int maxFileSizeMB,
      int indexingIntervalMinutes});
}

/// @nodoc
class _$IndexingSettingsCopyWithImpl<$Res, $Val extends IndexingSettings>
    implements $IndexingSettingsCopyWith<$Res> {
  _$IndexingSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IndexingSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? autoIndex = null,
    Object? supportedExtensions = null,
    Object? maxFileSizeMB = null,
    Object? indexingIntervalMinutes = null,
  }) {
    return _then(_value.copyWith(
      autoIndex: null == autoIndex
          ? _value.autoIndex
          : autoIndex // ignore: cast_nullable_to_non_nullable
              as bool,
      supportedExtensions: null == supportedExtensions
          ? _value.supportedExtensions
          : supportedExtensions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      maxFileSizeMB: null == maxFileSizeMB
          ? _value.maxFileSizeMB
          : maxFileSizeMB // ignore: cast_nullable_to_non_nullable
              as int,
      indexingIntervalMinutes: null == indexingIntervalMinutes
          ? _value.indexingIntervalMinutes
          : indexingIntervalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IndexingSettingsImplCopyWith<$Res>
    implements $IndexingSettingsCopyWith<$Res> {
  factory _$$IndexingSettingsImplCopyWith(_$IndexingSettingsImpl value,
          $Res Function(_$IndexingSettingsImpl) then) =
      __$$IndexingSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool autoIndex,
      List<String> supportedExtensions,
      int maxFileSizeMB,
      int indexingIntervalMinutes});
}

/// @nodoc
class __$$IndexingSettingsImplCopyWithImpl<$Res>
    extends _$IndexingSettingsCopyWithImpl<$Res, _$IndexingSettingsImpl>
    implements _$$IndexingSettingsImplCopyWith<$Res> {
  __$$IndexingSettingsImplCopyWithImpl(_$IndexingSettingsImpl _value,
      $Res Function(_$IndexingSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of IndexingSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? autoIndex = null,
    Object? supportedExtensions = null,
    Object? maxFileSizeMB = null,
    Object? indexingIntervalMinutes = null,
  }) {
    return _then(_$IndexingSettingsImpl(
      autoIndex: null == autoIndex
          ? _value.autoIndex
          : autoIndex // ignore: cast_nullable_to_non_nullable
              as bool,
      supportedExtensions: null == supportedExtensions
          ? _value._supportedExtensions
          : supportedExtensions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      maxFileSizeMB: null == maxFileSizeMB
          ? _value.maxFileSizeMB
          : maxFileSizeMB // ignore: cast_nullable_to_non_nullable
              as int,
      indexingIntervalMinutes: null == indexingIntervalMinutes
          ? _value.indexingIntervalMinutes
          : indexingIntervalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$IndexingSettingsImpl implements _IndexingSettings {
  const _$IndexingSettingsImpl(
      {this.autoIndex = true,
      final List<String> supportedExtensions = const ['.md', '.txt', '.pdf'],
      this.maxFileSizeMB = 10,
      this.indexingIntervalMinutes = 60})
      : _supportedExtensions = supportedExtensions;

  /// Whether to auto-index files
  @override
  @JsonKey()
  final bool autoIndex;

  /// Supported file extensions
  final List<String> _supportedExtensions;

  /// Supported file extensions
  @override
  @JsonKey()
  List<String> get supportedExtensions {
    if (_supportedExtensions is EqualUnmodifiableListView)
      return _supportedExtensions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_supportedExtensions);
  }

  /// Maximum file size in MB
  @override
  @JsonKey()
  final int maxFileSizeMB;

  /// Indexing interval in minutes
  @override
  @JsonKey()
  final int indexingIntervalMinutes;

  @override
  String toString() {
    return 'IndexingSettings(autoIndex: $autoIndex, supportedExtensions: $supportedExtensions, maxFileSizeMB: $maxFileSizeMB, indexingIntervalMinutes: $indexingIntervalMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IndexingSettingsImpl &&
            (identical(other.autoIndex, autoIndex) ||
                other.autoIndex == autoIndex) &&
            const DeepCollectionEquality()
                .equals(other._supportedExtensions, _supportedExtensions) &&
            (identical(other.maxFileSizeMB, maxFileSizeMB) ||
                other.maxFileSizeMB == maxFileSizeMB) &&
            (identical(
                    other.indexingIntervalMinutes, indexingIntervalMinutes) ||
                other.indexingIntervalMinutes == indexingIntervalMinutes));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      autoIndex,
      const DeepCollectionEquality().hash(_supportedExtensions),
      maxFileSizeMB,
      indexingIntervalMinutes);

  /// Create a copy of IndexingSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IndexingSettingsImplCopyWith<_$IndexingSettingsImpl> get copyWith =>
      __$$IndexingSettingsImplCopyWithImpl<_$IndexingSettingsImpl>(
          this, _$identity);
}

abstract class _IndexingSettings implements IndexingSettings {
  const factory _IndexingSettings(
      {final bool autoIndex,
      final List<String> supportedExtensions,
      final int maxFileSizeMB,
      final int indexingIntervalMinutes}) = _$IndexingSettingsImpl;

  /// Whether to auto-index files
  @override
  bool get autoIndex;

  /// Supported file extensions
  @override
  List<String> get supportedExtensions;

  /// Maximum file size in MB
  @override
  int get maxFileSizeMB;

  /// Indexing interval in minutes
  @override
  int get indexingIntervalMinutes;

  /// Create a copy of IndexingSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IndexingSettingsImplCopyWith<_$IndexingSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SearchSettings {
  /// Whether to enable fuzzy search
  bool get enableFuzzySearch => throw _privateConstructorUsedError;

  /// Maximum search results
  int get maxResults => throw _privateConstructorUsedError;

  /// Search timeout in seconds
  int get timeoutSeconds => throw _privateConstructorUsedError;

  /// Create a copy of SearchSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchSettingsCopyWith<SearchSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchSettingsCopyWith<$Res> {
  factory $SearchSettingsCopyWith(
          SearchSettings value, $Res Function(SearchSettings) then) =
      _$SearchSettingsCopyWithImpl<$Res, SearchSettings>;
  @useResult
  $Res call({bool enableFuzzySearch, int maxResults, int timeoutSeconds});
}

/// @nodoc
class _$SearchSettingsCopyWithImpl<$Res, $Val extends SearchSettings>
    implements $SearchSettingsCopyWith<$Res> {
  _$SearchSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableFuzzySearch = null,
    Object? maxResults = null,
    Object? timeoutSeconds = null,
  }) {
    return _then(_value.copyWith(
      enableFuzzySearch: null == enableFuzzySearch
          ? _value.enableFuzzySearch
          : enableFuzzySearch // ignore: cast_nullable_to_non_nullable
              as bool,
      maxResults: null == maxResults
          ? _value.maxResults
          : maxResults // ignore: cast_nullable_to_non_nullable
              as int,
      timeoutSeconds: null == timeoutSeconds
          ? _value.timeoutSeconds
          : timeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchSettingsImplCopyWith<$Res>
    implements $SearchSettingsCopyWith<$Res> {
  factory _$$SearchSettingsImplCopyWith(_$SearchSettingsImpl value,
          $Res Function(_$SearchSettingsImpl) then) =
      __$$SearchSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool enableFuzzySearch, int maxResults, int timeoutSeconds});
}

/// @nodoc
class __$$SearchSettingsImplCopyWithImpl<$Res>
    extends _$SearchSettingsCopyWithImpl<$Res, _$SearchSettingsImpl>
    implements _$$SearchSettingsImplCopyWith<$Res> {
  __$$SearchSettingsImplCopyWithImpl(
      _$SearchSettingsImpl _value, $Res Function(_$SearchSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableFuzzySearch = null,
    Object? maxResults = null,
    Object? timeoutSeconds = null,
  }) {
    return _then(_$SearchSettingsImpl(
      enableFuzzySearch: null == enableFuzzySearch
          ? _value.enableFuzzySearch
          : enableFuzzySearch // ignore: cast_nullable_to_non_nullable
              as bool,
      maxResults: null == maxResults
          ? _value.maxResults
          : maxResults // ignore: cast_nullable_to_non_nullable
              as int,
      timeoutSeconds: null == timeoutSeconds
          ? _value.timeoutSeconds
          : timeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$SearchSettingsImpl implements _SearchSettings {
  const _$SearchSettingsImpl(
      {this.enableFuzzySearch = true,
      this.maxResults = 50,
      this.timeoutSeconds = 10});

  /// Whether to enable fuzzy search
  @override
  @JsonKey()
  final bool enableFuzzySearch;

  /// Maximum search results
  @override
  @JsonKey()
  final int maxResults;

  /// Search timeout in seconds
  @override
  @JsonKey()
  final int timeoutSeconds;

  @override
  String toString() {
    return 'SearchSettings(enableFuzzySearch: $enableFuzzySearch, maxResults: $maxResults, timeoutSeconds: $timeoutSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchSettingsImpl &&
            (identical(other.enableFuzzySearch, enableFuzzySearch) ||
                other.enableFuzzySearch == enableFuzzySearch) &&
            (identical(other.maxResults, maxResults) ||
                other.maxResults == maxResults) &&
            (identical(other.timeoutSeconds, timeoutSeconds) ||
                other.timeoutSeconds == timeoutSeconds));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, enableFuzzySearch, maxResults, timeoutSeconds);

  /// Create a copy of SearchSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchSettingsImplCopyWith<_$SearchSettingsImpl> get copyWith =>
      __$$SearchSettingsImplCopyWithImpl<_$SearchSettingsImpl>(
          this, _$identity);
}

abstract class _SearchSettings implements SearchSettings {
  const factory _SearchSettings(
      {final bool enableFuzzySearch,
      final int maxResults,
      final int timeoutSeconds}) = _$SearchSettingsImpl;

  /// Whether to enable fuzzy search
  @override
  bool get enableFuzzySearch;

  /// Maximum search results
  @override
  int get maxResults;

  /// Search timeout in seconds
  @override
  int get timeoutSeconds;

  /// Create a copy of SearchSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchSettingsImplCopyWith<_$SearchSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
