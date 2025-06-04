import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/favorite_model_repository.dart';
import '../services/database_service.dart';
import '../services/logger_service.dart';

/// 收藏模型状态管理类
class FavoriteModelNotifier
    extends StateNotifier<AsyncValue<List<FavoriteModel>>> {
  FavoriteModelNotifier() : super(const AsyncValue.loading()) {
    _loadFavoriteModels();
  }

  late final FavoriteModelRepository _repository;
  final LoggerService _logger = LoggerService();

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

  /// 重新加载收藏模型（不显示loading状态）
  Future<void> _reloadFavoriteModels() async {
    try {
      final favoriteModels = await _repository.getAllFavoriteModels();
      _logger.debug('重新加载收藏模型', {
        'count': favoriteModels.length,
        'models': favoriteModels
            .map((m) => '${m.providerId}:${m.modelName}')
            .toList(),
      });
      state = AsyncValue.data(favoriteModels);
    } catch (error, stackTrace) {
      _logger.error('重新加载收藏模型失败', {'error': error.toString()});
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 添加收藏模型
  Future<void> addFavoriteModel(String providerId, String modelName) async {
    try {
      _logger.debug('添加收藏模型', {
        'providerId': providerId,
        'modelName': modelName,
      });

      // 检查是否已经收藏
      final isAlreadyFavorite = await _repository.isModelFavorite(
        providerId,
        modelName,
      );
      if (isAlreadyFavorite) {
        _logger.warning('模型已经被收藏', {
          'providerId': providerId,
          'modelName': modelName,
        });
        return;
      }

      await _repository.addFavoriteModel(providerId, modelName);

      // 直接更新状态而不是重新加载
      await _reloadFavoriteModels();

      _logger.info('收藏模型添加成功', {
        'providerId': providerId,
        'modelName': modelName,
      });
    } catch (error, stackTrace) {
      _logger.error('添加收藏模型失败', {
        'providerId': providerId,
        'modelName': modelName,
        'error': error.toString(),
      });
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 移除收藏模型
  Future<void> removeFavoriteModel(String providerId, String modelName) async {
    try {
      _logger.debug('移除收藏模型', {
        'providerId': providerId,
        'modelName': modelName,
      });

      await _repository.removeFavoriteModel(providerId, modelName);

      // 直接更新状态而不是重新加载
      await _reloadFavoriteModels();

      _logger.info('收藏模型移除成功', {
        'providerId': providerId,
        'modelName': modelName,
      });
    } catch (error, stackTrace) {
      _logger.error('移除收藏模型失败', {
        'providerId': providerId,
        'modelName': modelName,
        'error': error.toString(),
      });
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 切换收藏状态
  Future<bool> toggleFavoriteModel(String providerId, String modelName) async {
    try {
      final newState = await _repository.toggleFavoriteModel(
        providerId,
        modelName,
      );
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
  Future<List<FavoriteModel>> getFavoriteModelsByProvider(
    String providerId,
  ) async {
    try {
      return await _repository.getFavoriteModelsByProvider(providerId);
    } catch (error) {
      return [];
    }
  }
}

/// 收藏模型Provider
final favoriteModelNotifierProvider =
    StateNotifierProvider<
      FavoriteModelNotifier,
      AsyncValue<List<FavoriteModel>>
    >((ref) => FavoriteModelNotifier());
