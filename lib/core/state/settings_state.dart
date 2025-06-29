import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

/// Settings state management
///
/// Manages application settings including theme, language, behavior, and preferences.
/// Inspired by Cherry Studio's settings management but adapted for Riverpod state management.
@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    // === Loading State ===
    /// Whether settings are currently loading
    @Default(false) bool isLoading,

    /// Whether settings have been initialized
    @Default(false) bool isInitialized,

    /// Settings loading error
    @Default(null) String? error,

    // === Theme Settings ===
    /// Current theme mode
    @Default(ThemeMode.system) ThemeMode themeMode,

    /// Custom theme configuration
    @Default(null) CustomThemeConfig? customTheme,

    /// Whether to use system accent color
    @Default(true) bool useSystemAccentColor,

    /// Custom accent color
    @Default(null) String? customAccentColor,

    // === Language Settings ===
    /// Current language code
    @Default('en') String languageCode,

    /// Available languages
    @Default([]) List<LanguageOption> availableLanguages,

    /// Whether to use system language
    @Default(true) bool useSystemLanguage,

    // === Display Settings ===
    /// Window style (transparent, opaque)
    @Default(WindowStyle.opaque) WindowStyle windowStyle,

    /// Zoom factor for UI scaling
    @Default(1.0) double zoomFactor,

    /// Whether to show sidebar icons
    @Default(true) bool showSidebarIcons,

    /// Sidebar icon configuration
    @Default(SidebarIconConfig()) SidebarIconConfig sidebarIconConfig,

    /// Whether to pin topics to top
    @Default(false) bool pinTopicsToTop,

    /// Topic position (left, right)
    @Default(TopicPosition.left) TopicPosition topicPosition,

    /// Whether to show topic time
    @Default(true) bool showTopicTime,

    /// Assistant icon type
    @Default(AssistantIconType.avatar) AssistantIconType assistantIconType,

    // === Behavior Settings ===
    /// Send message shortcut
    @Default(SendMessageShortcut.enter) SendMessageShortcut sendMessageShortcut,

    /// Whether to launch on system boot
    @Default(false) bool launchOnBoot,

    /// Whether to launch to system tray
    @Default(false) bool launchToTray,

    /// Whether to show in system tray
    @Default(true) bool showInTray,

    /// Whether to minimize to tray on close
    @Default(true) bool minimizeToTrayOnClose,

    // === Chat Settings ===
    /// Default chat model
    @Default(null) String? defaultChatModel,

    /// Default title generation model
    @Default(null) String? defaultTitleModel,

    /// Whether to show tokens in UI
    @Default(false) bool showTokens,

    /// Whether to enable streaming responses
    @Default(true) bool enableStreaming,

    /// Maximum conversation history length
    @Default(100) int maxConversationHistory,

    /// Whether to auto-save conversations
    @Default(true) bool autoSaveConversations,

    // === Privacy Settings ===
    /// Whether to enable data collection
    @Default(false) bool enableDataCollection,

    /// Whether to enable spell check
    @Default(true) bool enableSpellCheck,

    /// Spell check languages
    @Default(['en']) List<String> spellCheckLanguages,

    /// Whether to enable quick panel triggers
    @Default(true) bool enableQuickPanelTriggers,

    /// Whether to enable backspace delete model
    @Default(false) bool enableBackspaceDeleteModel,

    // === Export Settings ===
    /// Export menu options
    @Default(ExportMenuOptions()) ExportMenuOptions exportMenuOptions,

    // === Update Settings ===
    /// Whether to auto-check for updates
    @Default(true) bool autoCheckUpdates,

    /// Whether to enable early access updates
    @Default(false) bool enableEarlyAccess,

    /// Update channel
    @Default(UpdateChannel.stable) UpdateChannel updateChannel,

    // === Advanced Settings ===
    /// Custom CSS for theming
    @Default('') String customCss,

    /// Developer mode enabled
    @Default(false) bool developerMode,

    /// Debug logging enabled
    @Default(false) bool debugLogging,

    /// Performance monitoring enabled
    @Default(false) bool performanceMonitoring,

    // === Integration Settings ===
    /// MCP server configurations
    @Default([]) List<McpServerConfig> mcpServers,

    /// Knowledge base settings
    @Default(KnowledgeBaseSettings())
    KnowledgeBaseSettings knowledgeBaseSettings,

    /// External service integrations
    @Default({}) Map<String, dynamic> integrations,

    // === Backup Settings ===
    /// Whether to enable automatic backups
    @Default(true) bool enableAutoBackup,

    /// Backup frequency in hours
    @Default(24) int backupFrequencyHours,

    /// Maximum number of backups to keep
    @Default(7) int maxBackupCount,

    /// Backup location
    @Default(null) String? backupLocation,

    // === Experimental Features ===
    /// Enabled experimental features
    @Default({}) Set<String> enabledExperimentalFeatures,

    /// Feature flags
    @Default({}) Map<String, bool> featureFlags,
  }) = _SettingsState;

  const SettingsState._();

  // === Computed Properties ===

  /// Whether settings are ready to use
  bool get isReady => isInitialized && !isLoading && error == null;

  /// Whether dark mode is active
  bool get isDarkMode {
    switch (themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        // This would need to be determined by the system
        return false; // Default fallback
    }
  }

  /// Whether system tray is enabled
  bool get isTrayEnabled => showInTray;

  /// Whether updates are enabled
  bool get areUpdatesEnabled => autoCheckUpdates;

  /// Get setting value by key with type safety
  T? getSetting<T>(String key) {
    // This would be implemented based on the specific setting key
    // For now, return null as a placeholder
    return null;
  }

  /// Check if a feature flag is enabled
  bool isFeatureEnabled(String feature) {
    return featureFlags[feature] ?? false;
  }

  /// Check if an experimental feature is enabled
  bool isExperimentalFeatureEnabled(String feature) {
    return enabledExperimentalFeatures.contains(feature);
  }
}

/// Theme mode enumeration
enum ThemeMode {
  /// Use system theme
  system,

  /// Always use light theme
  light,

  /// Always use dark theme
  dark,
}

/// Window style enumeration
enum WindowStyle {
  /// Opaque window
  opaque,

  /// Transparent window
  transparent,
}

/// Topic position enumeration
enum TopicPosition {
  /// Topics on the left side
  left,

  /// Topics on the right side
  right,
}

/// Assistant icon type enumeration
enum AssistantIconType {
  /// Show avatar
  avatar,

  /// Show icon
  icon,

  /// Show text
  text,
}

/// Send message shortcut enumeration
enum SendMessageShortcut {
  /// Enter key
  enter,

  /// Ctrl+Enter
  ctrlEnter,

  /// Shift+Enter
  shiftEnter,
}

/// Update channel enumeration
enum UpdateChannel {
  /// Stable releases only
  stable,

  /// Beta releases
  beta,

  /// Alpha/development releases
  alpha,
}

/// Custom theme configuration
@freezed
class CustomThemeConfig with _$CustomThemeConfig {
  const factory CustomThemeConfig({
    /// Primary color
    @Default('#2196F3') String primaryColor,

    /// Secondary color
    @Default('#FF9800') String secondaryColor,

    /// Background color
    @Default('#FFFFFF') String backgroundColor,

    /// Surface color
    @Default('#F5F5F5') String surfaceColor,

    /// Text color
    @Default('#212121') String textColor,

    /// Border radius
    @Default(8.0) double borderRadius,

    /// Font family
    @Default('system') String fontFamily,

    /// Font size scale
    @Default(1.0) double fontSizeScale,
  }) = _CustomThemeConfig;
}

/// Language option
@freezed
class LanguageOption with _$LanguageOption {
  const factory LanguageOption({
    /// Language code (e.g., 'en', 'zh-CN')
    required String code,

    /// Display name
    required String name,

    /// Native name
    required String nativeName,

    /// Whether this language is supported
    @Default(true) bool isSupported,
  }) = _LanguageOption;
}

/// Sidebar icon configuration
@freezed
class SidebarIconConfig with _$SidebarIconConfig {
  const factory SidebarIconConfig({
    /// Visible icons in order
    @Default([]) List<String> visibleIcons,

    /// Disabled icons
    @Default([]) List<String> disabledIcons,

    /// Icon size
    @Default(20.0) double iconSize,

    /// Icon spacing
    @Default(8.0) double iconSpacing,
  }) = _SidebarIconConfig;
}

/// Export menu options
@freezed
class ExportMenuOptions with _$ExportMenuOptions {
  const factory ExportMenuOptions({
    /// Enable image export
    @Default(true) bool image,

    /// Enable markdown export
    @Default(true) bool markdown,

    /// Enable markdown with reasoning export
    @Default(false) bool markdownReason,

    /// Enable Notion export
    @Default(false) bool notion,

    /// Enable Yuque export
    @Default(false) bool yuque,

    /// Enable Joplin export
    @Default(false) bool joplin,

    /// Enable Obsidian export
    @Default(false) bool obsidian,

    /// Enable SiYuan export
    @Default(false) bool siyuan,

    /// Enable DOCX export
    @Default(false) bool docx,

    /// Enable plain text export
    @Default(true) bool plainText,
  }) = _ExportMenuOptions;
}

/// MCP server configuration
@freezed
class McpServerConfig with _$McpServerConfig {
  const factory McpServerConfig({
    /// Server ID
    required String id,

    /// Server name
    required String name,

    /// Server command
    required String command,

    /// Server arguments
    @Default([]) List<String> args,

    /// Environment variables
    @Default({}) Map<String, String> env,

    /// Whether server is enabled
    @Default(true) bool enabled,

    /// Server description
    @Default('') String description,
  }) = _McpServerConfig;
}

/// Knowledge base settings
@freezed
class KnowledgeBaseSettings with _$KnowledgeBaseSettings {
  const factory KnowledgeBaseSettings({
    /// Whether knowledge base is enabled
    @Default(true) bool enabled,

    /// Default knowledge base path
    @Default('') String defaultPath,

    /// Indexing settings
    @Default(IndexingSettings()) IndexingSettings indexingSettings,

    /// Search settings
    @Default(SearchSettings()) SearchSettings searchSettings,
  }) = _KnowledgeBaseSettings;
}

/// Indexing settings
@freezed
class IndexingSettings with _$IndexingSettings {
  const factory IndexingSettings({
    /// Whether to auto-index files
    @Default(true) bool autoIndex,

    /// Supported file extensions
    @Default(['.md', '.txt', '.pdf']) List<String> supportedExtensions,

    /// Maximum file size in MB
    @Default(10) int maxFileSizeMB,

    /// Indexing interval in minutes
    @Default(60) int indexingIntervalMinutes,
  }) = _IndexingSettings;
}

/// Search settings
@freezed
class SearchSettings with _$SearchSettings {
  const factory SearchSettings({
    /// Whether to enable fuzzy search
    @Default(true) bool enableFuzzySearch,

    /// Maximum search results
    @Default(50) int maxResults,

    /// Search timeout in seconds
    @Default(10) int timeoutSeconds,
  }) = _SearchSettings;
}
