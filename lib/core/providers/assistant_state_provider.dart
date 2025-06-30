import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../state/assistant_state.dart';
import '../services/assistant_service.dart';

/// Assistant state notifier
///
/// Manages AI assistants including selection, configuration, and CRUD operations.
/// Inspired by Cherry Studio's assistants store but adapted for Riverpod.
class AssistantStateNotifier extends StateNotifier<AssistantState> {
  final Ref _ref;
  final _uuid = const Uuid();

  AssistantStateNotifier(this._ref) : super(const AssistantState()) {
    _initialize();
  }

  // === Initialization ===

  /// Initialize assistant state
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      final service = _ref.read(assistantServiceProvider);

      // Load assistants
      final assistants = await service.loadAssistants();

      // Load models
      final models = await service.loadAvailableModels();

      // Load templates
      final templates = await service.loadAssistantTemplates();

      // Set default assistant if none exists
      AssistantConfig? defaultAssistant;
      if (assistants.isNotEmpty) {
        defaultAssistant = assistants.first;
      } else {
        // Create a default assistant
        defaultAssistant = await _createDefaultAssistant();
      }

      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        error: null,
        assistants: assistants,
        defaultAssistant: defaultAssistant,
        selectedAssistant: defaultAssistant,
        availableModels: models,
        templates: templates,
        totalAssistants: assistants.length,
        enabledAssistantCount: assistants.where((a) => a.isEnabled).length,
        customAssistants: assistants.where((a) => a.isCustom).length,
        lastUpdated: DateTime.now(),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  /// Refresh assistant state
  Future<void> refresh() async {
    await _initialize();
  }

  // === Assistant Selection ===

  /// Select an assistant
  Future<void> selectAssistant(String assistantId) async {
    final assistant = state.getAssistantById(assistantId);
    if (assistant == null) {
      throw AssistantException('Assistant not found: $assistantId');
    }

    state = state.copyWith(selectedAssistant: assistant);

    // Update recent assistants
    await _updateRecentAssistants(assistantId);

    // Update usage stats
    await _updateUsageStats(assistantId);

    // Persist selection
    final service = _ref.read(assistantServiceProvider);
    await service.setSelectedAssistant(assistantId);
  }

  /// Clear assistant selection (use default)
  void clearSelection() {
    state = state.copyWith(selectedAssistant: state.defaultAssistant);
  }

  // === Assistant CRUD Operations ===

  /// Create a new assistant
  Future<AssistantConfig> createAssistant({
    required String name,
    required String systemPrompt,
    String description = '',
    String avatar = '🤖',
    List<String> tags = const [],
    AssistantSettings? settings,
    String? modelId,
  }) async {
    final assistantId = _uuid.v4();

    state = state.copyWith(
      creatingAssistants: {...state.creatingAssistants, assistantId},
    );

    try {
      final assistant = AssistantConfig(
        id: assistantId,
        name: name,
        description: description,
        avatar: avatar,
        systemPrompt: systemPrompt,
        tags: tags,
        settings: settings ?? const AssistantSettings(),
        modelId: modelId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final service = _ref.read(assistantServiceProvider);
      await service.saveAssistant(assistant);

      final updatedAssistants = [...state.assistants, assistant];

      state = state.copyWith(
        assistants: updatedAssistants,
        totalAssistants: updatedAssistants.length,
        enabledAssistantCount:
            updatedAssistants.where((a) => a.isEnabled).length,
        customAssistants: updatedAssistants.where((a) => a.isCustom).length,
        creatingAssistants: state.creatingAssistants..remove(assistantId),
        lastUpdated: DateTime.now(),
      );

      return assistant;
    } catch (error) {
      state = state.copyWith(
        creatingAssistants: state.creatingAssistants..remove(assistantId),
        operationErrors: {
          ...state.operationErrors,
          assistantId: error.toString(),
        },
      );
      rethrow;
    }
  }

  /// Update an assistant
  Future<void> updateAssistant(AssistantConfig assistant) async {
    state = state.copyWith(
      updatingAssistants: {...state.updatingAssistants, assistant.id},
    );

    try {
      final updatedAssistant = assistant.copyWith(
        updatedAt: DateTime.now(),
      );

      final service = _ref.read(assistantServiceProvider);
      await service.saveAssistant(updatedAssistant);

      final updatedAssistants = state.assistants
          .map((a) => a.id == assistant.id ? updatedAssistant : a)
          .toList();

      state = state.copyWith(
        assistants: updatedAssistants,
        selectedAssistant: state.selectedAssistant?.id == assistant.id
            ? updatedAssistant
            : state.selectedAssistant,
        defaultAssistant: state.defaultAssistant?.id == assistant.id
            ? updatedAssistant
            : state.defaultAssistant,
        enabledAssistantCount:
            updatedAssistants.where((a) => a.isEnabled).length,
        updatingAssistants: state.updatingAssistants..remove(assistant.id),
        lastUpdated: DateTime.now(),
      );
    } catch (error) {
      state = state.copyWith(
        updatingAssistants: state.updatingAssistants..remove(assistant.id),
        operationErrors: {
          ...state.operationErrors,
          assistant.id: error.toString(),
        },
      );
      rethrow;
    }
  }

  /// Delete an assistant
  Future<void> deleteAssistant(String assistantId) async {
    state = state.copyWith(
      deletingAssistants: {...state.deletingAssistants, assistantId},
    );

    try {
      final service = _ref.read(assistantServiceProvider);
      await service.deleteAssistant(assistantId);

      final updatedAssistants =
          state.assistants.where((a) => a.id != assistantId).toList();

      // Update selection if deleted assistant was selected
      AssistantConfig? newSelection = state.selectedAssistant;
      if (state.selectedAssistant?.id == assistantId) {
        newSelection = updatedAssistants.isNotEmpty
            ? updatedAssistants.first
            : state.defaultAssistant;
      }

      // Update default if deleted assistant was default
      AssistantConfig? newDefault = state.defaultAssistant;
      if (state.defaultAssistant?.id == assistantId) {
        newDefault =
            updatedAssistants.isNotEmpty ? updatedAssistants.first : null;
      }

      state = state.copyWith(
        assistants: updatedAssistants,
        selectedAssistant: newSelection,
        defaultAssistant: newDefault,
        totalAssistants: updatedAssistants.length,
        enabledAssistantCount:
            updatedAssistants.where((a) => a.isEnabled).length,
        customAssistants: updatedAssistants.where((a) => a.isCustom).length,
        deletingAssistants: state.deletingAssistants..remove(assistantId),
        recentAssistantIds:
            state.recentAssistantIds.where((id) => id != assistantId).toList(),
        favoriteAssistantIds: state.favoriteAssistantIds..remove(assistantId),
        usageStats: Map.from(state.usageStats)..remove(assistantId),
        lastUpdated: DateTime.now(),
      );
    } catch (error) {
      state = state.copyWith(
        deletingAssistants: state.deletingAssistants..remove(assistantId),
        operationErrors: {
          ...state.operationErrors,
          assistantId: error.toString(),
        },
      );
      rethrow;
    }
  }

  /// Duplicate an assistant
  Future<AssistantConfig> duplicateAssistant(String assistantId) async {
    final original = state.getAssistantById(assistantId);
    if (original == null) {
      throw AssistantException('Assistant not found: $assistantId');
    }

    return await createAssistant(
      name: '${original.name} (Copy)',
      systemPrompt: original.systemPrompt,
      description: original.description,
      avatar: original.avatar,
      tags: original.tags,
      settings: original.settings,
      modelId: original.modelId,
    );
  }

  // === Assistant Organization ===

  /// Toggle assistant favorite status
  Future<void> toggleFavorite(String assistantId) async {
    final newFavorites = Set<String>.from(state.favoriteAssistantIds);

    if (newFavorites.contains(assistantId)) {
      newFavorites.remove(assistantId);
    } else {
      newFavorites.add(assistantId);
    }

    state = state.copyWith(favoriteAssistantIds: newFavorites);

    final service = _ref.read(assistantServiceProvider);
    await service.setFavoriteAssistants(newFavorites.toList());
  }

  /// Toggle assistant enabled status
  Future<void> toggleEnabled(String assistantId) async {
    final assistant = state.getAssistantById(assistantId);
    if (assistant == null) return;

    final updatedAssistant = assistant.copyWith(
      isEnabled: !assistant.isEnabled,
      updatedAt: DateTime.now(),
    );

    await updateAssistant(updatedAssistant);
  }

  /// Set assistant sorting
  void setSorting(AssistantSortBy sortBy, bool ascending) {
    state = state.copyWith(
      sortBy: sortBy,
      sortAscending: ascending,
    );
  }

  /// Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Toggle filter tag
  void toggleFilterTag(String tag) {
    final newTags = Set<String>.from(state.activeFilterTags);

    if (newTags.contains(tag)) {
      newTags.remove(tag);
    } else {
      newTags.add(tag);
    }

    state = state.copyWith(activeFilterTags: newTags);
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      activeFilterTags: {},
      showOnlyEnabled: false,
      showOnlyFavorites: false,
    );
  }

  /// Set show only enabled filter
  void setShowOnlyEnabled(bool enabled) {
    state = state.copyWith(showOnlyEnabled: enabled);
  }

  /// Set show only favorites filter
  void setShowOnlyFavorites(bool favorites) {
    state = state.copyWith(showOnlyFavorites: favorites);
  }

  // === Template Operations ===

  /// Create assistant from template
  Future<AssistantConfig> createFromTemplate(String templateId) async {
    final template =
        state.templates.where((t) => t.id == templateId).firstOrNull;

    if (template == null) {
      throw AssistantException('Template not found: $templateId');
    }

    return await createAssistant(
      name: template.name,
      systemPrompt: template.systemPrompt,
      description: template.description,
      avatar: template.avatar,
      tags: template.tags,
      settings: template.defaultSettings,
    );
  }

  // === Utility Methods ===

  /// Clear operation error
  void clearOperationError(String assistantId) {
    final newErrors = Map<String, String>.from(state.operationErrors);
    newErrors.remove(assistantId);
    state = state.copyWith(operationErrors: newErrors);
  }

  /// Clear all operation errors
  void clearAllOperationErrors() {
    state = state.copyWith(operationErrors: {});
  }

  // === Private Methods ===

  /// Create default assistant
  Future<AssistantConfig> _createDefaultAssistant() async {
    return await createAssistant(
      name: 'Default Assistant',
      systemPrompt: 'You are a helpful AI assistant.',
      description: 'A general-purpose AI assistant',
      avatar: '🤖',
    );
  }

  /// Update recent assistants list
  Future<void> _updateRecentAssistants(String assistantId) async {
    final recent = List<String>.from(state.recentAssistantIds);

    // Remove if already exists
    recent.remove(assistantId);

    // Add to beginning
    recent.insert(0, assistantId);

    // Keep only last 10
    if (recent.length > 10) {
      recent.removeRange(10, recent.length);
    }

    state = state.copyWith(recentAssistantIds: recent);

    final service = _ref.read(assistantServiceProvider);
    await service.setRecentAssistants(recent);
  }

  /// Update usage statistics
  Future<void> _updateUsageStats(String assistantId) async {
    final currentStats =
        state.usageStats[assistantId] ?? const AssistantUsageStats();

    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final updatedStats = currentStats.copyWith(
      totalUsage: currentStats.totalUsage + 1,
      lastUsed: now,
      usageHistory: {
        ...currentStats.usageHistory,
        today: (currentStats.usageHistory[today] ?? 0) + 1,
      },
    );

    state = state.copyWith(
      usageStats: {
        ...state.usageStats,
        assistantId: updatedStats,
      },
    );

    final service = _ref.read(assistantServiceProvider);
    await service.updateUsageStats(assistantId, updatedStats);
  }
}

/// Assistant exception
class AssistantException implements Exception {
  final String message;

  const AssistantException(this.message);

  @override
  String toString() => 'AssistantException: $message';
}

/// Assistant state provider
final assistantStateProvider =
    StateNotifierProvider<AssistantStateNotifier, AssistantState>(
  (ref) => AssistantStateNotifier(ref),
);

// === Convenience Providers ===

/// Whether assistant state is ready
final assistantStateReadyProvider = Provider<bool>((ref) {
  return ref.watch(assistantStateProvider.select((state) => state.isReady));
});

/// Current selected assistant
final selectedAssistantProvider = Provider<AssistantConfig?>((ref) {
  return ref
      .watch(assistantStateProvider.select((state) => state.selectedAssistant));
});

/// Current assistant (selected or default)
final currentAssistantProvider = Provider<AssistantConfig?>((ref) {
  return ref
      .watch(assistantStateProvider.select((state) => state.currentAssistant));
});

/// All assistants
final assistantsProvider = Provider<List<AssistantConfig>>((ref) {
  return ref.watch(assistantStateProvider.select((state) => state.assistants));
});

/// Filtered and sorted assistants
final filteredAssistantsProvider = Provider<List<AssistantConfig>>((ref) {
  return ref
      .watch(assistantStateProvider.select((state) => state.sortedAssistants));
});

/// Enabled assistants
final enabledAssistantsProvider = Provider<List<AssistantConfig>>((ref) {
  return ref
      .watch(assistantStateProvider.select((state) => state.enabledAssistants));
});

/// Favorite assistants
final favoriteAssistantsProvider = Provider<List<AssistantConfig>>((ref) {
  return ref.watch(
      assistantStateProvider.select((state) => state.favoriteAssistants));
});

/// Recent assistants
final recentAssistantsProvider = Provider<List<AssistantConfig>>((ref) {
  return ref
      .watch(assistantStateProvider.select((state) => state.recentAssistants));
});

/// Available models
final availableModelsProvider = Provider<List<ModelInfo>>((ref) {
  return ref
      .watch(assistantStateProvider.select((state) => state.availableModels));
});

/// Assistant templates
final assistantTemplatesProvider = Provider<List<AssistantTemplate>>((ref) {
  return ref.watch(assistantStateProvider.select((state) => state.templates));
});

/// Whether any operations are active
final hasActiveAssistantOperationsProvider = Provider<bool>((ref) {
  return ref.watch(
      assistantStateProvider.select((state) => state.hasActiveOperations));
});

/// Assistant statistics
final assistantStatsProvider = Provider<Map<String, int>>((ref) {
  final state = ref.watch(assistantStateProvider);
  return {
    'total': state.totalAssistants,
    'enabled': state.enabledAssistantCount,
    'custom': state.customAssistants,
    'favorites': state.favoriteAssistantIds.length,
  };
});

/// Whether an assistant is being processed
final assistantBeingProcessedProvider =
    Provider.family<bool, String>((ref, assistantId) {
  return ref.watch(assistantStateProvider
      .select((state) => state.isAssistantBeingProcessed(assistantId)));
});

/// Assistant operation error
final assistantOperationErrorProvider =
    Provider.family<String?, String>((ref, assistantId) {
  return ref.watch(assistantStateProvider
      .select((state) => state.getOperationError(assistantId)));
});

/// Whether an assistant is favorite
final isAssistantFavoriteProvider =
    Provider.family<bool, String>((ref, assistantId) {
  return ref.watch(assistantStateProvider
      .select((state) => state.isAssistantFavorite(assistantId)));
});

/// Assistant by ID
final assistantByIdProvider =
    Provider.family<AssistantConfig?, String>((ref, assistantId) {
  return ref.watch(assistantStateProvider
      .select((state) => state.getAssistantById(assistantId)));
});

/// Assistant usage stats
final assistantUsageStatsProvider =
    Provider.family<AssistantUsageStats?, String>((ref, assistantId) {
  return ref.watch(assistantStateProvider
      .select((state) => state.getUsageStats(assistantId)));
});
