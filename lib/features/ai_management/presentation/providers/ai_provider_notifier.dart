import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ai_provider.dart';
import '../../../../shared/infrastructure/services/database_service.dart';
import '../../data/repositories/provider_repository.dart';

/// AI 提供商状态管理器
///
/// 负责管理应用中所有 AI 提供商的配置和状态。提供商是 AI 服务的来源，
/// 如 OpenAI、DeepSeek、Anthropic、Google、Ollama 等。
///
/// 核心特性：
/// - 🔌 **多提供商支持**: 支持 OpenAI、DeepSeek、Anthropic、Google、Ollama 等
/// - 🔑 **密钥管理**: 为每个提供商配置独立的 API 密钥和 Base URL
/// - 🧠 **模型管理**: 每个提供商可配置多个 AI 模型
/// - 🔄 **状态同步**: 实时同步提供商配置变化
/// - 📊 **异步加载**: 使用 AsyncValue 管理加载状态和错误处理
/// - ⚙️ **启用控制**: 可以启用或禁用特定提供商
///
/// 业务逻辑：
/// - 用户可以配置多个 AI 提供商，每个提供商有独立的配置
/// - 每个提供商可以配置多个模型，模型包含名称、能力、参数等信息
/// - 提供商可以被启用或禁用，只有启用的提供商才能用于聊天
/// - 在聊天过程中，用户可以切换不同提供商的不同模型
///
/// 配置结构：
/// - 提供商基本信息：名称、类型、描述
/// - 连接配置：API 密钥、Base URL、超时设置
/// - 模型列表：每个模型的详细配置和能力
///
/// 使用场景：
/// - 提供商管理界面的数据源
/// - 模型选择界面的提供商列表
/// - 聊天功能的提供商配置获取
class AiProviderNotifier extends StateNotifier<AsyncValue<List<AiProvider>>> {
  AiProviderNotifier() : super(const AsyncValue.loading()) {
    _loadProviders();
  }

  late final ProviderRepository _repository;

  /// 初始化并加载提供商列表
  Future<void> _loadProviders() async {
    try {
      _repository = ProviderRepository(DatabaseService.instance.database);
      final providers = await _repository.getAllProviders();
      state = AsyncValue.data(providers);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 刷新提供商列表
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadProviders();
  }

  /// 添加新的AI提供商
  Future<void> addProvider(AiProvider provider) async {
    try {
      await _repository.insertProvider(provider);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 更新AI提供商
  Future<void> updateProvider(AiProvider provider) async {
    try {
      await _repository.updateProvider(provider);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 删除AI提供商
  Future<void> deleteProvider(String id) async {
    try {
      await _repository.deleteProvider(id);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 切换提供商启用状态
  Future<void> toggleProviderEnabled(String id) async {
    final currentState = state;
    if (currentState is AsyncData<List<AiProvider>>) {
      try {
        final providers = currentState.value;
        final provider = providers.firstWhere((p) => p.id == id);
        final updatedProvider = provider.copyWith(
          isEnabled: !provider.isEnabled,
        );
        await updateProvider(updatedProvider);
        // 更新成功后刷新状态
        await refresh();
      } catch (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }
}

/// AI提供商列表的Provider
final aiProviderNotifierProvider =
    StateNotifierProvider<AiProviderNotifier, AsyncValue<List<AiProvider>>>(
      (ref) => AiProviderNotifier(),
    );

/// 获取特定提供商的Provider
final aiProviderProvider = Provider.family<AiProvider?, String>((
  ref,
  providerId,
) {
  final providersAsync = ref.watch(aiProviderNotifierProvider);
  return providersAsync.whenOrNull(
    data: (providers) {
      try {
        return providers.firstWhere((provider) => provider.id == providerId);
      } catch (e) {
        return null;
      }
    },
  );
});

/// 获取启用的提供商列表
final enabledAiProvidersProvider = Provider<List<AiProvider>>((ref) {
  final providersAsync = ref.watch(aiProviderNotifierProvider);
  return providersAsync.whenOrNull(
        data: (providers) =>
            providers.where((provider) => provider.isEnabled).toList(),
      ) ??
      [];
});
