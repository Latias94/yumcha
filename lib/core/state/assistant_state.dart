import 'package:freezed_annotation/freezed_annotation.dart';

part 'assistant_state.freezed.dart';

/// Assistant state management
///
/// Manages AI assistants including selection, configuration, and CRUD operations.
/// Inspired by Cherry Studio's assistants store but adapted for Riverpod state management.
@freezed
class AssistantState with _$AssistantState {
  const factory AssistantState({
    // === Loading State ===
    /// Whether assistants are currently loading
    @Default(false) bool isLoading,

    /// Whether assistants have been initialized
    @Default(false) bool isInitialized,

    /// Assistant loading error
    @Default(null) String? error,

    // === Assistant Management ===
    /// All available assistants
    @Default([]) List<AssistantConfig> assistants,

    /// Currently selected assistant
    @Default(null) AssistantConfig? selectedAssistant,

    /// Default assistant (fallback when no assistant is selected)
    @Default(null) AssistantConfig? defaultAssistant,

    /// Recently used assistants
    @Default([]) List<String> recentAssistantIds,

    /// Favorite assistant IDs
    @Default({}) Set<String> favoriteAssistantIds,

    // === Assistant Organization ===
    /// Assistant tags/categories
    @Default([]) List<String> availableTags,

    /// Tag order for display
    @Default([]) List<String> tagOrder,

    /// Collapsed tags in UI
    @Default({}) Map<String, bool> collapsedTags,

    /// Assistant sorting preference
    @Default(AssistantSortBy.name) AssistantSortBy sortBy,

    /// Sort order (ascending/descending)
    @Default(true) bool sortAscending,

    // === Assistant Operations ===
    /// Assistants currently being created
    @Default({}) Set<String> creatingAssistants,

    /// Assistants currently being updated
    @Default({}) Set<String> updatingAssistants,

    /// Assistants currently being deleted
    @Default({}) Set<String> deletingAssistants,

    /// Assistant operation errors
    @Default({}) Map<String, String> operationErrors,

    // === Model Management ===
    /// Available models for assistants
    @Default([]) List<ModelInfo> availableModels,

    /// Model selection state
    @Default(null) String? selectedModelId,

    /// Model loading state
    @Default(false) bool isLoadingModels,

    // === Assistant Templates ===
    /// Available assistant templates
    @Default([]) List<AssistantTemplate> templates,

    /// Template categories
    @Default([]) List<String> templateCategories,

    /// Whether templates are loading
    @Default(false) bool isLoadingTemplates,

    // === Search and Filter ===
    /// Search query for assistants
    @Default('') String searchQuery,

    /// Active filter tags
    @Default({}) Set<String> activeFilterTags,

    /// Show only enabled assistants
    @Default(false) bool showOnlyEnabled,

    /// Show only favorite assistants
    @Default(false) bool showOnlyFavorites,

    // === Statistics ===
    /// Total number of assistants
    @Default(0) int totalAssistants,

    /// Number of enabled assistants
    @Default(0) int enabledAssistantCount,

    /// Number of custom assistants
    @Default(0) int customAssistants,

    /// Assistant usage statistics
    @Default({}) Map<String, AssistantUsageStats> usageStats,

    // === Import/Export ===
    /// Whether import/export is in progress
    @Default(false) bool isImportExportInProgress,

    /// Import/export progress (0.0 to 1.0)
    @Default(0.0) double importExportProgress,

    /// Import/export error
    @Default(null) String? importExportError,

    // === Performance ===
    /// Last update timestamp
    @Default(null) DateTime? lastUpdated,

    /// Cache expiry time
    @Default(null) DateTime? cacheExpiry,

    /// Whether cache is valid
    @Default(true) bool isCacheValid,
  }) = _AssistantState;

  const AssistantState._();

  // === Computed Properties ===

  /// Whether assistant state is ready
  bool get isReady => isInitialized && !isLoading && error == null;

  /// Whether any assistant is selected
  bool get hasSelectedAssistant => selectedAssistant != null;

  /// Get current assistant (selected or default)
  AssistantConfig? get currentAssistant =>
      selectedAssistant ?? defaultAssistant;

  /// Whether any operations are in progress
  bool get hasActiveOperations =>
      creatingAssistants.isNotEmpty ||
      updatingAssistants.isNotEmpty ||
      deletingAssistants.isNotEmpty;

  /// Get filtered assistants based on search and filters
  List<AssistantConfig> get filteredAssistants {
    var filtered = assistants;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered
          .where((assistant) =>
              assistant.name.toLowerCase().contains(query) ||
              assistant.description.toLowerCase().contains(query) ||
              assistant.tags.any((tag) => tag.toLowerCase().contains(query)))
          .toList();
    }

    // Apply tag filters
    if (activeFilterTags.isNotEmpty) {
      filtered = filtered
          .where((assistant) =>
              assistant.tags.any((tag) => activeFilterTags.contains(tag)))
          .toList();
    }

    // Apply enabled filter
    if (showOnlyEnabled) {
      filtered = filtered.where((assistant) => assistant.isEnabled).toList();
    }

    // Apply favorites filter
    if (showOnlyFavorites) {
      filtered = filtered
          .where((assistant) => favoriteAssistantIds.contains(assistant.id))
          .toList();
    }

    return filtered;
  }

  /// Get sorted assistants
  List<AssistantConfig> get sortedAssistants {
    final filtered = filteredAssistants;

    filtered.sort((a, b) {
      int comparison;

      switch (sortBy) {
        case AssistantSortBy.name:
          comparison = a.name.compareTo(b.name);
          break;
        case AssistantSortBy.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case AssistantSortBy.updatedAt:
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
        case AssistantSortBy.usage:
          final aUsage = usageStats[a.id]?.totalUsage ?? 0;
          final bUsage = usageStats[b.id]?.totalUsage ?? 0;
          comparison = aUsage.compareTo(bUsage);
          break;
      }

      return sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  /// Get enabled assistants
  List<AssistantConfig> get enabledAssistants =>
      assistants.where((assistant) => assistant.isEnabled).toList();

  /// Get favorite assistants
  List<AssistantConfig> get favoriteAssistants => assistants
      .where((assistant) => favoriteAssistantIds.contains(assistant.id))
      .toList();

  /// Get recent assistants
  List<AssistantConfig> get recentAssistants {
    return recentAssistantIds
        .map((id) => assistants.where((a) => a.id == id).firstOrNull)
        .where((assistant) => assistant != null)
        .cast<AssistantConfig>()
        .toList();
  }

  /// Check if an assistant is being operated on
  bool isAssistantBeingProcessed(String assistantId) {
    return creatingAssistants.contains(assistantId) ||
        updatingAssistants.contains(assistantId) ||
        deletingAssistants.contains(assistantId);
  }

  /// Get operation error for an assistant
  String? getOperationError(String assistantId) {
    return operationErrors[assistantId];
  }

  /// Check if an assistant is favorite
  bool isAssistantFavorite(String assistantId) {
    return favoriteAssistantIds.contains(assistantId);
  }

  /// Get assistant by ID
  AssistantConfig? getAssistantById(String assistantId) {
    return assistants.where((a) => a.id == assistantId).firstOrNull;
  }

  /// Get usage stats for an assistant
  AssistantUsageStats? getUsageStats(String assistantId) {
    return usageStats[assistantId];
  }
}

/// Assistant configuration model
@freezed
class AssistantConfig with _$AssistantConfig {
  const factory AssistantConfig({
    /// Unique assistant ID
    required String id,

    /// Assistant name
    required String name,

    /// Assistant description
    @Default('') String description,

    /// Assistant avatar (emoji or image path)
    @Default('🤖') String avatar,

    /// System prompt
    required String systemPrompt,

    /// Assistant tags/categories
    @Default([]) List<String> tags,

    /// Whether assistant is enabled
    @Default(true) bool isEnabled,

    /// Whether this is a custom assistant
    @Default(true) bool isCustom,

    /// Assistant settings
    @Default(AssistantSettings()) AssistantSettings settings,

    /// Associated model ID
    @Default(null) String? modelId,

    /// Creation timestamp
    required DateTime createdAt,

    /// Last update timestamp
    required DateTime updatedAt,

    /// Last used timestamp
    @Default(null) DateTime? lastUsedAt,

    /// Assistant metadata
    @Default({}) Map<String, dynamic> metadata,
  }) = _AssistantConfig;
}

/// Assistant settings
@freezed
class AssistantSettings with _$AssistantSettings {
  const factory AssistantSettings({
    /// Temperature (0.0 to 2.0)
    @Default(0.7) double temperature,

    /// Top P (0.0 to 1.0)
    @Default(1.0) double topP,

    /// Max tokens
    @Default(2048) int maxTokens,

    /// Context length
    @Default(10) int contextLength,

    /// Whether to stream output
    @Default(true) bool streamOutput,

    /// Frequency penalty
    @Default(null) double? frequencyPenalty,

    /// Presence penalty
    @Default(null) double? presencePenalty,

    /// Stop sequences
    @Default([]) List<String> stopSequences,

    /// Custom parameters
    @Default({}) Map<String, dynamic> customParameters,
  }) = _AssistantSettings;
}

/// Model information
@freezed
class ModelInfo with _$ModelInfo {
  const factory ModelInfo({
    /// Model ID
    required String id,

    /// Model name
    required String name,

    /// Provider ID
    required String providerId,

    /// Model description
    @Default('') String description,

    /// Whether model supports streaming
    @Default(true) bool supportsStreaming,

    /// Whether model supports function calling
    @Default(false) bool supportsFunctionCalling,

    /// Whether model supports vision
    @Default(false) bool supportsVision,

    /// Maximum context length
    @Default(4096) int maxContextLength,

    /// Model capabilities
    @Default([]) List<String> capabilities,

    /// Model metadata
    @Default({}) Map<String, dynamic> metadata,
  }) = _ModelInfo;
}

/// Assistant template
@freezed
class AssistantTemplate with _$AssistantTemplate {
  const factory AssistantTemplate({
    /// Template ID
    required String id,

    /// Template name
    required String name,

    /// Template description
    @Default('') String description,

    /// Template category
    @Default('General') String category,

    /// Template avatar
    @Default('🤖') String avatar,

    /// Template system prompt
    required String systemPrompt,

    /// Template tags
    @Default([]) List<String> tags,

    /// Default settings
    @Default(AssistantSettings()) AssistantSettings defaultSettings,

    /// Whether template is built-in
    @Default(true) bool isBuiltIn,

    /// Template metadata
    @Default({}) Map<String, dynamic> metadata,
  }) = _AssistantTemplate;
}

/// Assistant usage statistics
@freezed
class AssistantUsageStats with _$AssistantUsageStats {
  const factory AssistantUsageStats({
    /// Total usage count
    @Default(0) int totalUsage,

    /// Usage this week
    @Default(0) int weeklyUsage,

    /// Usage this month
    @Default(0) int monthlyUsage,

    /// Last used timestamp
    @Default(null) DateTime? lastUsed,

    /// Average session duration in minutes
    @Default(0.0) double averageSessionDuration,

    /// Total tokens used
    @Default(0) int totalTokens,

    /// Usage history (date -> count)
    @Default({}) Map<String, int> usageHistory,
  }) = _AssistantUsageStats;
}

/// Assistant sorting options
enum AssistantSortBy {
  /// Sort by name
  name,

  /// Sort by creation date
  createdAt,

  /// Sort by last update
  updatedAt,

  /// Sort by usage frequency
  usage,
}
