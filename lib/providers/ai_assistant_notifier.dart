import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_assistant.dart';
import '../services/database_service.dart';
import '../services/assistant_repository.dart';

/// AI助手状态管理类
class AiAssistantNotifier extends StateNotifier<AsyncValue<List<AiAssistant>>> {
  AiAssistantNotifier() : super(const AsyncValue.loading()) {
    _loadAssistants();
  }

  late final AssistantRepository _repository;

  /// 初始化并加载助手列表
  Future<void> _loadAssistants() async {
    try {
      _repository = AssistantRepository(DatabaseService.instance.database);
      final assistants = await _repository.getAllAssistants();
      state = AsyncValue.data(assistants);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 刷新助手列表
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadAssistants();
  }

  /// 添加新的AI助手
  Future<void> addAssistant(AiAssistant assistant) async {
    try {
      await _repository.insertAssistant(assistant);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 更新AI助手
  Future<void> updateAssistant(AiAssistant assistant) async {
    try {
      await _repository.updateAssistant(assistant);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 删除AI助手
  Future<void> deleteAssistant(String id) async {
    try {
      await _repository.deleteAssistant(id);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 切换助手启用状态
  Future<void> toggleAssistantEnabled(String id) async {
    final currentState = state;
    if (currentState is AsyncData<List<AiAssistant>>) {
      try {
        final assistants = currentState.value;
        final assistant = assistants.firstWhere((a) => a.id == id);
        final updatedAssistant = assistant.copyWith(
          isEnabled: !assistant.isEnabled,
        );
        await updateAssistant(updatedAssistant);
      } catch (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }
}

/// AI助手列表的Provider
final aiAssistantNotifierProvider =
    StateNotifierProvider<AiAssistantNotifier, AsyncValue<List<AiAssistant>>>(
      (ref) => AiAssistantNotifier(),
    );

/// 获取特定助手的Provider
final aiAssistantProvider = Provider.family<AiAssistant?, String>((
  ref,
  assistantId,
) {
  final assistantsAsync = ref.watch(aiAssistantNotifierProvider);
  return assistantsAsync.whenOrNull(
    data: (assistants) {
      try {
        return assistants.firstWhere(
          (assistant) => assistant.id == assistantId,
        );
      } catch (e) {
        return null;
      }
    },
  );
});

/// 获取启用的助手列表
final enabledAiAssistantsProvider = Provider<List<AiAssistant>>((ref) {
  final assistantsAsync = ref.watch(aiAssistantNotifierProvider);
  return assistantsAsync.whenOrNull(
        data: (assistants) =>
            assistants.where((assistant) => assistant.isEnabled).toList(),
      ) ??
      [];
});

/// 根据提供商ID获取助手列表
final assistantsByProviderProvider = Provider.family<List<AiAssistant>, String>(
  (ref, providerId) {
    final assistantsAsync = ref.watch(aiAssistantNotifierProvider);
    return assistantsAsync.whenOrNull(
          data: (assistants) => assistants
              .where((assistant) => assistant.providerId == providerId)
              .toList(),
        ) ??
        [];
  },
);
