import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/ai_management/data/repositories/favorite_model_repository.dart';
import '../../infrastructure/services/logger_service.dart';
import 'dependency_providers.dart';

/// 收藏模型状态管理器
///
/// 负责管理用户收藏的 AI 模型状态和操作。用户可以收藏常用的模型，
/// 以便在模型选择时快速访问。
///
/// 核心功能：
/// - ⭐ **收藏管理**: 添加、移除、切换模型收藏状态
/// - 📋 **列表管理**: 获取所有收藏模型或按提供商筛选
/// - 🔍 **状态查询**: 检查特定模型是否已被收藏
/// - 🔄 **实时同步**: 实时同步收藏状态变化
/// - 📊 **异步加载**: 使用 AsyncValue 管理加载状态和错误处理
/// - 🏷️ **分类查询**: 按提供商查询收藏的模型
///
/// 业务逻辑：
/// - 收藏基于 providerId + modelName 的组合唯一性
/// - 用户可以在模型选择界面快速收藏/取消收藏模型
/// - 收藏的模型会在模型选择界面优先显示
/// - 支持按提供商分类查看收藏的模型
///
/// 使用场景：
/// - 模型选择界面的收藏功能
/// - 快速访问常用模型
/// - 个性化模型管理
/// - 收藏模型的统计和展示
class FavoriteModelNotifier
    extends StateNotifier<AsyncValue<List<FavoriteModel>>> {
  FavoriteModelNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadFavoriteModels();
  }

  final Ref _ref;
  final LoggerService _logger = LoggerService();

  /// 获取Repository实例
  FavoriteModelRepository get _repository =>
      _ref.read(favoriteModelRepositoryProvider);

  /// 初始化并加载收藏模型列表
  Future<void> _loadFavoriteModels() async {
    try {
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
final favoriteModelNotifierProvider = StateNotifierProvider<
    FavoriteModelNotifier,
    AsyncValue<List<FavoriteModel>>>((ref) => FavoriteModelNotifier(ref));
