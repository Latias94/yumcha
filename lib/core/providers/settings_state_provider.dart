import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/settings_state.dart';
import '../services/settings_service.dart';

/// Settings state notifier
///
/// Manages application settings including theme, language, behavior, and preferences.
/// Inspired by Cherry Studio's settings management but adapted for Riverpod.
class SettingsStateNotifier extends StateNotifier<SettingsState> {
  final Ref _ref;

  SettingsStateNotifier(this._ref) : super(const SettingsState()) {
    _initialize();
  }

  // === Initialization ===

  /// Initialize settings
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      final service = _ref.read(settingsServiceProvider);
      await service.loadSettings();

      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  /// Refresh settings from storage
  Future<void> refresh() async {
    await _initialize();
  }

  // === Theme Settings ===

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _persistSetting('themeMode', themeMode.name);
  }

  /// Set custom theme
  Future<void> setCustomTheme(CustomThemeConfig? customTheme) async {
    state = state.copyWith(customTheme: customTheme);
    await _persistSetting('customTheme', customTheme?.toJson());
  }

  /// Set use system accent color
  Future<void> setUseSystemAccentColor(bool useSystemAccentColor) async {
    state = state.copyWith(useSystemAccentColor: useSystemAccentColor);
    await _persistSetting('useSystemAccentColor', useSystemAccentColor);
  }

  /// Set custom accent color
  Future<void> setCustomAccentColor(String? customAccentColor) async {
    state = state.copyWith(customAccentColor: customAccentColor);
    await _persistSetting('customAccentColor', customAccentColor);
  }

  // === Language Settings ===

  /// Set language code
  Future<void> setLanguageCode(String languageCode) async {
    state = state.copyWith(languageCode: languageCode);
    await _persistSetting('languageCode', languageCode);
  }

  /// Set use system language
  Future<void> setUseSystemLanguage(bool useSystemLanguage) async {
    state = state.copyWith(useSystemLanguage: useSystemLanguage);
    await _persistSetting('useSystemLanguage', useSystemLanguage);
  }

  /// Set available languages
  void setAvailableLanguages(List<LanguageOption> languages) {
    state = state.copyWith(availableLanguages: languages);
  }

  // === Display Settings ===

  /// Set window style
  Future<void> setWindowStyle(WindowStyle windowStyle) async {
    state = state.copyWith(windowStyle: windowStyle);
    await _persistSetting('windowStyle', windowStyle.name);
  }

  /// Set zoom factor
  Future<void> setZoomFactor(double zoomFactor) async {
    state = state.copyWith(zoomFactor: zoomFactor);
    await _persistSetting('zoomFactor', zoomFactor);
  }

  /// Set show sidebar icons
  Future<void> setShowSidebarIcons(bool showSidebarIcons) async {
    state = state.copyWith(showSidebarIcons: showSidebarIcons);
    await _persistSetting('showSidebarIcons', showSidebarIcons);
  }

  /// Set sidebar icon configuration
  Future<void> setSidebarIconConfig(SidebarIconConfig config) async {
    state = state.copyWith(sidebarIconConfig: config);
    await _persistSetting('sidebarIconConfig', config.toJson());
  }

  /// Set pin topics to top
  Future<void> setPinTopicsToTop(bool pinTopicsToTop) async {
    state = state.copyWith(pinTopicsToTop: pinTopicsToTop);
    await _persistSetting('pinTopicsToTop', pinTopicsToTop);
  }

  /// Set topic position
  Future<void> setTopicPosition(TopicPosition topicPosition) async {
    state = state.copyWith(topicPosition: topicPosition);
    await _persistSetting('topicPosition', topicPosition.name);
  }

  /// Set show topic time
  Future<void> setShowTopicTime(bool showTopicTime) async {
    state = state.copyWith(showTopicTime: showTopicTime);
    await _persistSetting('showTopicTime', showTopicTime);
  }

  /// Set assistant icon type
  Future<void> setAssistantIconType(AssistantIconType assistantIconType) async {
    state = state.copyWith(assistantIconType: assistantIconType);
    await _persistSetting('assistantIconType', assistantIconType.name);
  }

  // === Behavior Settings ===

  /// Set send message shortcut
  Future<void> setSendMessageShortcut(SendMessageShortcut shortcut) async {
    state = state.copyWith(sendMessageShortcut: shortcut);
    await _persistSetting('sendMessageShortcut', shortcut.name);
  }

  /// Set launch on boot
  Future<void> setLaunchOnBoot(bool launchOnBoot) async {
    state = state.copyWith(launchOnBoot: launchOnBoot);
    await _persistSetting('launchOnBoot', launchOnBoot);
  }

  /// Set launch to tray
  Future<void> setLaunchToTray(bool launchToTray) async {
    state = state.copyWith(launchToTray: launchToTray);
    await _persistSetting('launchToTray', launchToTray);
  }

  /// Set show in tray
  Future<void> setShowInTray(bool showInTray) async {
    state = state.copyWith(showInTray: showInTray);
    await _persistSetting('showInTray', showInTray);
  }

  /// Set minimize to tray on close
  Future<void> setMinimizeToTrayOnClose(bool minimizeToTrayOnClose) async {
    state = state.copyWith(minimizeToTrayOnClose: minimizeToTrayOnClose);
    await _persistSetting('minimizeToTrayOnClose', minimizeToTrayOnClose);
  }

  // === Chat Settings ===

  /// Set default chat model
  Future<void> setDefaultChatModel(String? defaultChatModel) async {
    state = state.copyWith(defaultChatModel: defaultChatModel);
    await _persistSetting('defaultChatModel', defaultChatModel);
  }

  /// Set default title model
  Future<void> setDefaultTitleModel(String? defaultTitleModel) async {
    state = state.copyWith(defaultTitleModel: defaultTitleModel);
    await _persistSetting('defaultTitleModel', defaultTitleModel);
  }

  /// Set show tokens
  Future<void> setShowTokens(bool showTokens) async {
    state = state.copyWith(showTokens: showTokens);
    await _persistSetting('showTokens', showTokens);
  }

  /// Set enable streaming
  Future<void> setEnableStreaming(bool enableStreaming) async {
    state = state.copyWith(enableStreaming: enableStreaming);
    await _persistSetting('enableStreaming', enableStreaming);
  }

  /// Set max conversation history
  Future<void> setMaxConversationHistory(int maxConversationHistory) async {
    state = state.copyWith(maxConversationHistory: maxConversationHistory);
    await _persistSetting('maxConversationHistory', maxConversationHistory);
  }

  /// Set auto save conversations
  Future<void> setAutoSaveConversations(bool autoSaveConversations) async {
    state = state.copyWith(autoSaveConversations: autoSaveConversations);
    await _persistSetting('autoSaveConversations', autoSaveConversations);
  }

  // === Privacy Settings ===

  /// Set enable data collection
  Future<void> setEnableDataCollection(bool enableDataCollection) async {
    state = state.copyWith(enableDataCollection: enableDataCollection);
    await _persistSetting('enableDataCollection', enableDataCollection);
  }

  /// Set enable spell check
  Future<void> setEnableSpellCheck(bool enableSpellCheck) async {
    state = state.copyWith(enableSpellCheck: enableSpellCheck);
    await _persistSetting('enableSpellCheck', enableSpellCheck);
  }

  /// Set spell check languages
  Future<void> setSpellCheckLanguages(List<String> spellCheckLanguages) async {
    state = state.copyWith(spellCheckLanguages: spellCheckLanguages);
    await _persistSetting('spellCheckLanguages', spellCheckLanguages);
  }

  /// Set enable quick panel triggers
  Future<void> setEnableQuickPanelTriggers(
      bool enableQuickPanelTriggers) async {
    state = state.copyWith(enableQuickPanelTriggers: enableQuickPanelTriggers);
    await _persistSetting('enableQuickPanelTriggers', enableQuickPanelTriggers);
  }

  /// Set enable backspace delete model
  Future<void> setEnableBackspaceDeleteModel(
      bool enableBackspaceDeleteModel) async {
    state =
        state.copyWith(enableBackspaceDeleteModel: enableBackspaceDeleteModel);
    await _persistSetting(
        'enableBackspaceDeleteModel', enableBackspaceDeleteModel);
  }

  // === Export Settings ===

  /// Set export menu options
  Future<void> setExportMenuOptions(ExportMenuOptions exportMenuOptions) async {
    state = state.copyWith(exportMenuOptions: exportMenuOptions);
    await _persistSetting('exportMenuOptions', exportMenuOptions.toJson());
  }

  // === Update Settings ===

  /// Set auto check updates
  Future<void> setAutoCheckUpdates(bool autoCheckUpdates) async {
    state = state.copyWith(autoCheckUpdates: autoCheckUpdates);
    await _persistSetting('autoCheckUpdates', autoCheckUpdates);
  }

  /// Set enable early access
  Future<void> setEnableEarlyAccess(bool enableEarlyAccess) async {
    state = state.copyWith(enableEarlyAccess: enableEarlyAccess);
    await _persistSetting('enableEarlyAccess', enableEarlyAccess);
  }

  /// Set update channel
  Future<void> setUpdateChannel(UpdateChannel updateChannel) async {
    state = state.copyWith(updateChannel: updateChannel);
    await _persistSetting('updateChannel', updateChannel.name);
  }

  // === Advanced Settings ===

  /// Set custom CSS
  Future<void> setCustomCss(String customCss) async {
    state = state.copyWith(customCss: customCss);
    await _persistSetting('customCss', customCss);
  }

  /// Set developer mode
  Future<void> setDeveloperMode(bool developerMode) async {
    state = state.copyWith(developerMode: developerMode);
    await _persistSetting('developerMode', developerMode);
  }

  /// Set debug logging
  Future<void> setDebugLogging(bool debugLogging) async {
    state = state.copyWith(debugLogging: debugLogging);
    await _persistSetting('debugLogging', debugLogging);
  }

  /// Set performance monitoring
  Future<void> setPerformanceMonitoring(bool performanceMonitoring) async {
    state = state.copyWith(performanceMonitoring: performanceMonitoring);
    await _persistSetting('performanceMonitoring', performanceMonitoring);
  }

  // === Integration Settings ===

  /// Set MCP servers
  Future<void> setMcpServers(List<McpServerConfig> mcpServers) async {
    state = state.copyWith(mcpServers: mcpServers);
    await _persistSetting(
        'mcpServers', mcpServers.map((s) => s.toJson()).toList());
  }

  /// Set knowledge base settings
  Future<void> setKnowledgeBaseSettings(KnowledgeBaseSettings settings) async {
    state = state.copyWith(knowledgeBaseSettings: settings);
    await _persistSetting('knowledgeBaseSettings', settings.toJson());
  }

  /// Set integrations
  Future<void> setIntegrations(Map<String, dynamic> integrations) async {
    state = state.copyWith(integrations: integrations);
    await _persistSetting('integrations', integrations);
  }

  // === Feature Flags ===

  /// Set feature flag
  Future<void> setFeatureFlag(String feature, bool enabled) async {
    final newFlags = Map<String, bool>.from(state.featureFlags);
    newFlags[feature] = enabled;
    state = state.copyWith(featureFlags: newFlags);
    await _persistSetting('featureFlags', newFlags);
  }

  /// Enable experimental feature
  Future<void> enableExperimentalFeature(String feature) async {
    final newFeatures = Set<String>.from(state.enabledExperimentalFeatures);
    newFeatures.add(feature);
    state = state.copyWith(enabledExperimentalFeatures: newFeatures);
    await _persistSetting('enabledExperimentalFeatures', newFeatures.toList());
  }

  /// Disable experimental feature
  Future<void> disableExperimentalFeature(String feature) async {
    final newFeatures = Set<String>.from(state.enabledExperimentalFeatures);
    newFeatures.remove(feature);
    state = state.copyWith(enabledExperimentalFeatures: newFeatures);
    await _persistSetting('enabledExperimentalFeatures', newFeatures.toList());
  }

  // === Utility Methods ===

  /// Reset settings to defaults
  Future<void> resetToDefaults() async {
    state = const SettingsState(isInitialized: true);
    final service = _ref.read(settingsServiceProvider);
    await service.clearAllSettings();
  }

  /// Import settings from JSON
  Future<void> importSettings(Map<String, dynamic> settings) async {
    // TODO: Implement settings import
    throw UnimplementedError('Settings import not yet implemented');
  }

  /// Export settings to JSON
  Map<String, dynamic> exportSettings() {
    // TODO: Implement settings export
    throw UnimplementedError('Settings export not yet implemented');
  }

  // === Private Methods ===

  /// Persist a setting to storage
  Future<void> _persistSetting(String key, dynamic value) async {
    try {
      final service = _ref.read(settingsServiceProvider);
      await service.setSetting(key, value);
    } catch (error) {
      // Handle persistence error but don't revert state
      // The UI should show the new value even if persistence fails
      // TODO: Add error handling/retry logic
    }
  }
}

/// Settings state provider
final settingsStateProvider =
    StateNotifierProvider<SettingsStateNotifier, SettingsState>(
  (ref) => SettingsStateNotifier(ref),
);

// === Convenience Providers ===

/// Whether settings are ready
final settingsReadyProvider = Provider<bool>((ref) {
  return ref.watch(settingsStateProvider.select((state) => state.isReady));
});

/// Current theme mode
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsStateProvider.select((state) => state.themeMode));
});

/// Whether dark mode is active
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(settingsStateProvider.select((state) => state.isDarkMode));
});

/// Current language code
final languageCodeProvider = Provider<String>((ref) {
  return ref.watch(settingsStateProvider.select((state) => state.languageCode));
});

/// Whether system tray is enabled
final isTrayEnabledProvider = Provider<bool>((ref) {
  return ref
      .watch(settingsStateProvider.select((state) => state.isTrayEnabled));
});

/// Current zoom factor
final zoomFactorProvider = Provider<double>((ref) {
  return ref.watch(settingsStateProvider.select((state) => state.zoomFactor));
});

/// Whether developer mode is enabled
final isDeveloperModeProvider = Provider<bool>((ref) {
  return ref
      .watch(settingsStateProvider.select((state) => state.developerMode));
});

/// Default chat model
final defaultChatModelProvider = Provider<String?>((ref) {
  return ref
      .watch(settingsStateProvider.select((state) => state.defaultChatModel));
});

/// Whether streaming is enabled
final isStreamingEnabledProvider = Provider<bool>((ref) {
  return ref
      .watch(settingsStateProvider.select((state) => state.enableStreaming));
});

/// MCP servers configuration
final mcpServersProvider = Provider<List<McpServerConfig>>((ref) {
  return ref.watch(settingsStateProvider.select((state) => state.mcpServers));
});

/// Feature flag provider
final featureFlagProvider = Provider.family<bool, String>((ref, feature) {
  return ref.watch(
      settingsStateProvider.select((state) => state.isFeatureEnabled(feature)));
});

/// Experimental feature provider
final experimentalFeatureProvider =
    Provider.family<bool, String>((ref, feature) {
  return ref.watch(settingsStateProvider
      .select((state) => state.isExperimentalFeatureEnabled(feature)));
});
