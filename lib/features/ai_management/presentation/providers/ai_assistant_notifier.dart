import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ai_assistant.dart';
import '../../../../shared/infrastructure/services/database_service.dart';
import '../../data/repositories/assistant_repository.dart';

/// AI 助手状态管理器
///
/// 负责管理应用中所有 AI 助手的状态和操作。AI 助手是用户创建的个性化聊天角色，
/// 每个助手都有独特的系统提示词、温度参数等 AI 参数配置。
///
/// 核心特性：
/// - 🤖 **助手管理**: 创建、编辑、删除、启用/禁用 AI 助手
/// - 🎭 **个性化配置**: 每个助手可设置独特的系统提示词和 AI 参数
/// - 🔄 **状态同步**: 实时同步助手数据变化
/// - 📊 **异步加载**: 使用 AsyncValue 管理加载状态和错误处理
/// - 🎯 **独立性**: 助手不绑定特定的提供商或模型，可灵活切换
///
/// 业务逻辑：
/// - 用户可以创建多个 AI 助手，每个助手代表不同的聊天角色
/// - 助手配置包括名称、描述、系统提示词、温度、最大 token 等参数
/// - 助手可以被启用或禁用，只有启用的助手才能用于聊天
/// - 在聊天过程中，用户可以选择不同的助手来获得不同的对话体验
///
/// 使用场景：
/// - 助手管理界面的数据源
/// - 聊天界面的助手选择
/// - 助手配置的实时更新
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
