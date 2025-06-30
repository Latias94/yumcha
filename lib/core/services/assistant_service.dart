import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../state/assistant_state.dart';

/// Assistant service
///
/// Handles persistence and management of AI assistants.
/// Inspired by Cherry Studio's AssistantService but adapted for Flutter.
class AssistantService {
  final Ref _ref;
  SharedPreferences? _prefs;

  AssistantService(this._ref);

  /// Initialize the service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Load all assistants from storage
  Future<List<AssistantConfig>> loadAssistants() async {
    await initialize();

    try {
      final assistantsJson = _prefs!.getString('assistants');
      if (assistantsJson == null) {
        return _getDefaultAssistants();
      }

      // TODO: Implement proper JSON deserialization after freezed generation
      return <AssistantConfig>[];
    } catch (error) {
      throw AssistantServiceException('Failed to load assistants: $error');
    }
  }

  /// Save an assistant
  Future<void> saveAssistant(AssistantConfig assistant) async {
    await initialize();

    try {
      final assistants = await loadAssistants();
      final index = assistants.indexWhere((a) => a.id == assistant.id);

      if (index >= 0) {
        assistants[index] = assistant;
      } else {
        assistants.add(assistant);
      }

      await _saveAssistants(assistants);
    } catch (error) {
      throw AssistantServiceException('Failed to save assistant: $error');
    }
  }

  /// Delete an assistant
  Future<void> deleteAssistant(String assistantId) async {
    await initialize();

    try {
      final assistants = await loadAssistants();
      assistants.removeWhere((a) => a.id == assistantId);
      await _saveAssistants(assistants);
    } catch (error) {
      throw AssistantServiceException('Failed to delete assistant: $error');
    }
  }

  /// Load available models
  Future<List<ModelInfo>> loadAvailableModels() async {
    // TODO: Implement model loading from providers
    // For now, return some default models
    return [
      const ModelInfo(
        id: 'gpt-4',
        name: 'GPT-4',
        providerId: 'openai',
        description: 'Most capable GPT-4 model',
        maxContextLength: 8192,
        supportsFunctionCalling: true,
      ),
      const ModelInfo(
        id: 'gpt-3.5-turbo',
        name: 'GPT-3.5 Turbo',
        providerId: 'openai',
        description: 'Fast and efficient model',
        maxContextLength: 4096,
        supportsFunctionCalling: true,
      ),
      const ModelInfo(
        id: 'claude-3-sonnet',
        name: 'Claude 3 Sonnet',
        providerId: 'anthropic',
        description: 'Balanced performance and speed',
        maxContextLength: 200000,
        supportsVision: true,
      ),
    ];
  }

  /// Load assistant templates
  Future<List<AssistantTemplate>> loadAssistantTemplates() async {
    return [
      const AssistantTemplate(
        id: 'general',
        name: 'General Assistant',
        description: 'A helpful general-purpose assistant',
        category: 'General',
        avatar: '🤖',
        systemPrompt: 'You are a helpful AI assistant.',
      ),
      const AssistantTemplate(
        id: 'coding',
        name: 'Coding Assistant',
        description: 'Specialized in programming and development',
        category: 'Development',
        avatar: '💻',
        systemPrompt:
            'You are an expert programming assistant. Help with coding, debugging, and software development.',
        tags: ['coding', 'development', 'programming'],
      ),
      const AssistantTemplate(
        id: 'writing',
        name: 'Writing Assistant',
        description: 'Helps with writing and editing',
        category: 'Writing',
        avatar: '✍️',
        systemPrompt:
            'You are a professional writing assistant. Help with writing, editing, and improving text.',
        tags: ['writing', 'editing', 'content'],
      ),
      const AssistantTemplate(
        id: 'translator',
        name: 'Translator',
        description: 'Translates between languages',
        category: 'Language',
        avatar: '🌐',
        systemPrompt:
            'You are a professional translator. Provide accurate translations between languages.',
        tags: ['translation', 'language'],
      ),
    ];
  }

  /// Set selected assistant
  Future<void> setSelectedAssistant(String assistantId) async {
    await initialize();
    await _prefs!.setString('selectedAssistantId', assistantId);
  }

  /// Get selected assistant ID
  Future<String?> getSelectedAssistantId() async {
    await initialize();
    return _prefs!.getString('selectedAssistantId');
  }

  /// Set favorite assistants
  Future<void> setFavoriteAssistants(List<String> favoriteIds) async {
    await initialize();
    await _prefs!.setStringList('favoriteAssistantIds', favoriteIds);
  }

  /// Get favorite assistant IDs
  Future<List<String>> getFavoriteAssistantIds() async {
    await initialize();
    return _prefs!.getStringList('favoriteAssistantIds') ?? [];
  }

  /// Set recent assistants
  Future<void> setRecentAssistants(List<String> recentIds) async {
    await initialize();
    await _prefs!.setStringList('recentAssistantIds', recentIds);
  }

  /// Get recent assistant IDs
  Future<List<String>> getRecentAssistantIds() async {
    await initialize();
    return _prefs!.getStringList('recentAssistantIds') ?? [];
  }

  /// Update usage statistics
  Future<void> updateUsageStats(
      String assistantId, AssistantUsageStats stats) async {
    await initialize();

    try {
      final allStatsJson = _prefs!.getString('assistantUsageStats');
      Map<String, dynamic> allStats = {};

      if (allStatsJson != null) {
        allStats = jsonDecode(allStatsJson) as Map<String, dynamic>;
      }

      // TODO: Implement proper JSON serialization
      allStats[assistantId] = stats.toString();

      await _prefs!.setString('assistantUsageStats', jsonEncode(allStats));
    } catch (error) {
      throw AssistantServiceException('Failed to update usage stats: $error');
    }
  }

  /// Get usage statistics
  Future<Map<String, AssistantUsageStats>> getUsageStats() async {
    await initialize();

    try {
      final allStatsJson = _prefs!.getString('assistantUsageStats');
      if (allStatsJson == null) return {};

      final allStats = jsonDecode(allStatsJson) as Map<String, dynamic>;

      // TODO: Implement proper JSON deserialization
      return <String, AssistantUsageStats>{};
    } catch (error) {
      return {};
    }
  }

  /// Export assistants to JSON
  Future<Map<String, dynamic>> exportAssistants() async {
    final favoriteIds = await getFavoriteAssistantIds();

    // TODO: Implement proper export after JSON serialization is available
    return {
      'assistants': [],
      'usageStats': <String, dynamic>{},
      'favoriteIds': favoriteIds,
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }

  /// Import assistants from JSON
  Future<void> importAssistants(Map<String, dynamic> data) async {
    try {
      // TODO: Implement proper import after JSON deserialization is available
      // For now, just skip the import

      // TODO: Import usage stats after JSON deserialization is available

      // Import favorites if available
      if (data['favoriteIds'] != null) {
        final favoriteIds =
            (data['favoriteIds'] as List<dynamic>).cast<String>();
        await setFavoriteAssistants(favoriteIds);
      }
    } catch (error) {
      throw AssistantServiceException('Failed to import assistants: $error');
    }
  }

  /// Clear all assistant data
  Future<void> clearAllData() async {
    await initialize();

    await _prefs!.remove('assistants');
    await _prefs!.remove('selectedAssistantId');
    await _prefs!.remove('favoriteAssistantIds');
    await _prefs!.remove('recentAssistantIds');
    await _prefs!.remove('assistantUsageStats');
  }

  // === Private Methods ===

  /// Save assistants list to storage
  Future<void> _saveAssistants(List<AssistantConfig> assistants) async {
    // TODO: Implement proper JSON serialization
    await _prefs!.setString('assistants', '[]');
  }

  /// Get default assistants for first-time users
  List<AssistantConfig> _getDefaultAssistants() {
    final now = DateTime.now();

    return [
      AssistantConfig(
        id: 'default-general',
        name: 'General Assistant',
        description: 'A helpful general-purpose AI assistant',
        avatar: '🤖',
        systemPrompt:
            'You are a helpful AI assistant. Provide accurate, helpful, and friendly responses.',
        tags: ['general', 'default'],
        isCustom: false,
        createdAt: now,
        updatedAt: now,
      ),
      AssistantConfig(
        id: 'default-coding',
        name: 'Coding Assistant',
        description: 'Specialized in programming and development',
        avatar: '💻',
        systemPrompt:
            'You are an expert programming assistant. Help with coding, debugging, code review, and software development best practices.',
        tags: ['coding', 'development', 'programming', 'default'],
        isCustom: false,
        settings: const AssistantSettings(
          temperature: 0.3, // Lower temperature for more precise code
          maxTokens: 4096,
        ),
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}

/// Assistant service exception
class AssistantServiceException implements Exception {
  final String message;

  const AssistantServiceException(this.message);

  @override
  String toString() => 'AssistantServiceException: $message';
}

/// Assistant service provider
final assistantServiceProvider = Provider<AssistantService>((ref) {
  return AssistantService(ref);
});
