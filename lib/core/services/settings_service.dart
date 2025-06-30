import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../state/settings_state.dart';

/// Settings service
///
/// Handles persistence and loading of application settings.
/// Inspired by Cherry Studio's ConfigManager but adapted for Flutter with SharedPreferences.
class SettingsService {
  final Ref _ref;
  SharedPreferences? _prefs;

  SettingsService(this._ref);

  /// Initialize the service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Load all settings from storage
  Future<SettingsState> loadSettings() async {
    await initialize();

    try {
      return SettingsState(
        // Theme settings
        themeMode: _getEnum<ThemeMode>(
          'themeMode',
          ThemeMode.values,
          ThemeMode.system,
        ),
        useSystemAccentColor: _getBool('useSystemAccentColor', true),
        customAccentColor: _getString('customAccentColor'),

        // Language settings
        languageCode: _getString('languageCode', 'en'),
        useSystemLanguage: _getBool('useSystemLanguage', true),

        // Display settings
        windowStyle: _getEnum<WindowStyle>(
          'windowStyle',
          WindowStyle.values,
          WindowStyle.opaque,
        ),
        zoomFactor: _getDouble('zoomFactor', 1.0),
        showSidebarIcons: _getBool('showSidebarIcons', true),
        pinTopicsToTop: _getBool('pinTopicsToTop', false),
        topicPosition: _getEnum<TopicPosition>(
          'topicPosition',
          TopicPosition.values,
          TopicPosition.left,
        ),
        showTopicTime: _getBool('showTopicTime', true),
        assistantIconType: _getEnum<AssistantIconType>(
          'assistantIconType',
          AssistantIconType.values,
          AssistantIconType.avatar,
        ),

        // Behavior settings
        sendMessageShortcut: _getEnum<SendMessageShortcut>(
          'sendMessageShortcut',
          SendMessageShortcut.values,
          SendMessageShortcut.enter,
        ),
        launchOnBoot: _getBool('launchOnBoot', false),
        launchToTray: _getBool('launchToTray', false),
        showInTray: _getBool('showInTray', true),
        minimizeToTrayOnClose: _getBool('minimizeToTrayOnClose', true),

        // Chat settings
        defaultChatModel: _getString('defaultChatModel'),
        defaultTitleModel: _getString('defaultTitleModel'),
        showTokens: _getBool('showTokens', false),
        enableStreaming: _getBool('enableStreaming', true),
        maxConversationHistory: _getInt('maxConversationHistory', 100),
        autoSaveConversations: _getBool('autoSaveConversations', true),

        // Privacy settings
        enableDataCollection: _getBool('enableDataCollection', false),
        enableSpellCheck: _getBool('enableSpellCheck', true),
        spellCheckLanguages: _getStringList('spellCheckLanguages', ['en']),
        enableQuickPanelTriggers: _getBool('enableQuickPanelTriggers', true),
        enableBackspaceDeleteModel:
            _getBool('enableBackspaceDeleteModel', false),

        // Update settings
        autoCheckUpdates: _getBool('autoCheckUpdates', true),
        enableEarlyAccess: _getBool('enableEarlyAccess', false),
        updateChannel: _getEnum<UpdateChannel>(
          'updateChannel',
          UpdateChannel.values,
          UpdateChannel.stable,
        ),

        // Advanced settings
        customCss: _getString('customCss', ''),
        developerMode: _getBool('developerMode', false),
        debugLogging: _getBool('debugLogging', false),
        performanceMonitoring: _getBool('performanceMonitoring', false),

        // Backup settings
        enableAutoBackup: _getBool('enableAutoBackup', true),
        backupFrequencyHours: _getInt('backupFrequencyHours', 24),
        maxBackupCount: _getInt('maxBackupCount', 7),
        backupLocation: _getString('backupLocation'),

        // Feature flags and experimental features
        featureFlags: _getBoolMap('featureFlags', {}),
        enabledExperimentalFeatures:
            _getStringSet('enabledExperimentalFeatures', {}),

        // Complex objects (TODO: Implement after freezed generation)
        customTheme: null, // _getCustomTheme('customTheme'),
        sidebarIconConfig:
            const SidebarIconConfig(), // _getSidebarIconConfig('sidebarIconConfig'),
        exportMenuOptions:
            const ExportMenuOptions(), // _getExportMenuOptions('exportMenuOptions'),
        mcpServers: [], // _getMcpServers('mcpServers'),
        knowledgeBaseSettings:
            const KnowledgeBaseSettings(), // _getKnowledgeBaseSettings('knowledgeBaseSettings'),
        integrations: _getMap('integrations', {}),

        // State flags
        isInitialized: true,
        isLoading: false,
      );
    } catch (error) {
      throw SettingsException('Failed to load settings: $error');
    }
  }

  /// Set a setting value
  Future<void> setSetting(String key, dynamic value) async {
    await initialize();

    try {
      if (value == null) {
        await _prefs!.remove(key);
      } else if (value is bool) {
        await _prefs!.setBool(key, value);
      } else if (value is int) {
        await _prefs!.setInt(key, value);
      } else if (value is double) {
        await _prefs!.setDouble(key, value);
      } else if (value is String) {
        await _prefs!.setString(key, value);
      } else if (value is List<String>) {
        await _prefs!.setStringList(key, value);
      } else {
        // For complex objects, serialize to JSON
        await _prefs!.setString(key, jsonEncode(value));
      }
    } catch (error) {
      throw SettingsException('Failed to set setting $key: $error');
    }
  }

  /// Get a setting value
  dynamic getSetting(String key, [dynamic defaultValue]) {
    if (_prefs == null) return defaultValue;

    try {
      final value = _prefs!.get(key);
      return value ?? defaultValue;
    } catch (error) {
      return defaultValue;
    }
  }

  /// Clear all settings
  Future<void> clearAllSettings() async {
    await initialize();
    await _prefs!.clear();
  }

  /// Check if a setting exists
  bool hasSetting(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  /// Get all setting keys
  Set<String> getAllKeys() {
    return _prefs?.getKeys() ?? {};
  }

  // === Private Helper Methods ===

  bool _getBool(String key, bool defaultValue) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  int _getInt(String key, int defaultValue) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  double _getDouble(String key, double defaultValue) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  String _getString(String key, [String? defaultValue]) {
    return _prefs?.getString(key) ?? defaultValue ?? '';
  }

  List<String> _getStringList(String key, List<String> defaultValue) {
    return _prefs?.getStringList(key) ?? defaultValue;
  }

  Set<String> _getStringSet(String key, Set<String> defaultValue) {
    final list = _prefs?.getStringList(key);
    return list?.toSet() ?? defaultValue;
  }

  Map<String, dynamic> _getMap(String key, Map<String, dynamic> defaultValue) {
    final jsonString = _prefs?.getString(key);
    if (jsonString == null) return defaultValue;

    try {
      final decoded = jsonDecode(jsonString);
      return decoded is Map<String, dynamic> ? decoded : defaultValue;
    } catch (error) {
      return defaultValue;
    }
  }

  Map<String, bool> _getBoolMap(String key, Map<String, bool> defaultValue) {
    final jsonString = _prefs?.getString(key);
    if (jsonString == null) return defaultValue;

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        final result = <String, bool>{};
        decoded.forEach((k, v) {
          if (v is bool) {
            result[k] = v;
          }
        });
        return result;
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  T _getEnum<T>(String key, List<T> values, T defaultValue) {
    final stringValue = _prefs?.getString(key);
    if (stringValue == null) return defaultValue;

    try {
      return values.firstWhere(
        (e) => e.toString().split('.').last == stringValue,
        orElse: () => defaultValue,
      );
    } catch (error) {
      return defaultValue;
    }
  }

  // TODO: Implement complex object serialization after freezed generation
  // These methods will be added back once the freezed classes are generated
}

/// Settings exception
class SettingsException implements Exception {
  final String message;

  const SettingsException(this.message);

  @override
  String toString() => 'SettingsException: $message';
}

/// Settings service provider
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(ref);
});
