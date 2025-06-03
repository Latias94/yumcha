import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_provider.dart';
import '../services/database_service.dart';
import '../services/provider_repository.dart';

/// AI提供商状态管理类
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
