import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/favorite_model_repository.dart';
import '../services/database_service.dart';

/// 收藏模型状态管理类
class FavoriteModelNotifier extends StateNotifier<AsyncValue<List<FavoriteModel>>> {
  FavoriteModelNotifier() : super(const AsyncValue.loading()) {
    _loadFavoriteModels();
  }

  late final FavoriteModelRepository _repository;

  /// 初始化并加载收藏模型列表
  Future<void> _loadFavoriteModels() async {
    try {
      _repository = FavoriteModelRepository(DatabaseService.instance.database);
      final favoriteModels = await _repository.getAllFavoriteModels();
      state = AsyncValue.data(favoriteModels);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 刷新收藏模型列表
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadFavoriteModels();
  }

  /// 添加收藏模型
  Future<void> addFavoriteModel(String providerId, String modelName) async {
    try {
      await _repository.addFavoriteModel(providerId, modelName);
      await refresh(); // 刷新列表
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 移除收藏模型
  Future<void> removeFavoriteModel(String providerId, String modelName) async {
    try {
      await _repository.removeFavoriteModel(providerId, modelName);
      await refresh(); // 刷新列表
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 切换收藏状态
  Future<bool> toggleFavoriteModel(String providerId, String modelName) async {
    try {
      final newState = await _repository.toggleFavoriteModel(providerId, modelName);
      await refresh(); // 刷新列表
      return newState;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  /// 检查模型是否被收藏
  Future<bool> isModelFavorite(String providerId, String modelName) async {
    try {
      return await _repository.isModelFavorite(providerId, modelName);
    } catch (error) {
      return false;
    }
  }

  /// 获取特定提供商的收藏模型
  Future<List<FavoriteModel>> getFavoriteModelsByProvider(String providerId) async {
    try {
      return await _repository.getFavoriteModelsByProvider(providerId);
    } catch (error) {
      return [];
    }
  }
}

/// 收藏模型Provider
final favoriteModelNotifierProvider = StateNotifierProvider<FavoriteModelNotifier, AsyncValue<List<FavoriteModel>>>(
  (ref) => FavoriteModelNotifier(),
);
