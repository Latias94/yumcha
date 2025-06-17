import '../../../../shared/data/database/database.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';
import '../../../../core/utils/error_handler.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// 收藏模型数据模型
///
/// 表示用户收藏的 AI 模型信息
class FavoriteModel {
  final String id;
  final String providerId;
  final String modelName;
  final DateTime createdAt;

  const FavoriteModel({
    required this.id,
    required this.providerId,
    required this.modelName,
    required this.createdAt,
  });
}

/// 收藏模型数据仓库
///
/// 负责管理用户收藏的 AI 模型数据的 CRUD 操作。
///
/// 主要功能：
/// - 📋 **收藏管理**: 添加、移除、查询收藏的模型
/// - 🔍 **状态检查**: 检查模型是否已被收藏
/// - 🔄 **切换操作**: 一键切换模型收藏状态
/// - 🏷️ **分类查询**: 按提供商查询收藏模型
///
/// 使用场景：
/// - 模型选择界面的收藏功能
/// - 快速访问常用模型
/// - 个性化模型管理
///
/// 注意：
/// - 应该通过 FavoriteModelNotifier 访问，而不是直接使用
/// - 收藏基于 providerId + modelName 的组合唯一性
class FavoriteModelRepository {
  final AppDatabase _database;
  final _uuid = Uuid();
  final LoggerService _logger = LoggerService();

  FavoriteModelRepository(this._database);

  /// 获取所有收藏的模型
  ///
  /// @returns 所有收藏模型的列表
  Future<List<FavoriteModel>> getAllFavoriteModels() async {
    try {
      _logger.debug('开始获取所有收藏模型');
      final favoriteDataList =
          await _database.select(_database.favoriteModels).get();
      final favoriteModels = favoriteDataList.map(_dataToModel).toList();

      _logger.info('收藏模型获取成功', {'count': favoriteModels.length});
      return favoriteModels;
    } catch (e, stackTrace) {
      _logger.error('获取收藏模型失败', {'error': e.toString()});
      throw DatabaseError(
        message: '获取收藏模型失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 检查模型是否被收藏
  ///
  /// @param providerId 提供商ID
  /// @param modelName 模型名称
  /// @returns 是否已收藏
  Future<bool> isModelFavorite(String providerId, String modelName) async {
    try {
      _logger.debug('检查模型收藏状态', {
        'providerId': providerId,
        'modelName': modelName,
      });

      final result = await (_database.select(_database.favoriteModels)
            ..where(
              (f) =>
                  f.providerId.equals(providerId) &
                  f.modelName.equals(modelName),
            ))
          .getSingleOrNull();

      final isFavorite = result != null;
      _logger.debug('模型收藏状态检查完成', {
        'providerId': providerId,
        'modelName': modelName,
        'isFavorite': isFavorite,
      });

      return isFavorite;
    } catch (e, stackTrace) {
      _logger.error('检查模型收藏状态失败', {
        'providerId': providerId,
        'modelName': modelName,
        'error': e.toString(),
      });
      throw DatabaseError(
        message: '检查模型收藏状态失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 添加收藏模型
  ///
  /// @param providerId 提供商ID
  /// @param modelName 模型名称
  /// @returns 收藏记录的ID
  Future<String> addFavoriteModel(String providerId, String modelName) async {
    try {
      _logger.info('开始添加收藏模型', {
        'providerId': providerId,
        'modelName': modelName,
      });

      // 检查是否已经存在
      final existing = await isModelFavorite(providerId, modelName);
      if (existing) {
        throw ValidationError(
          message: '模型已经被收藏',
          code: 'ALREADY_FAVORITED',
        );
      }

      final id = _uuid.v4();
      final companion = FavoriteModelsCompanion(
        id: Value(id),
        providerId: Value(providerId),
        modelName: Value(modelName),
        createdAt: Value(DateTime.now()),
      );

      await _database.into(_database.favoriteModels).insert(companion);

      _logger.info('收藏模型添加成功', {
        'id': id,
        'providerId': providerId,
        'modelName': modelName,
      });

      return id;
    } catch (e, stackTrace) {
      if (e is ValidationError) {
        rethrow;
      }

      _logger.error('添加收藏模型失败', {
        'providerId': providerId,
        'modelName': modelName,
        'error': e.toString(),
      });

      throw DatabaseError(
        message: '添加收藏模型失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 移除收藏模型
  ///
  /// @param providerId 提供商ID
  /// @param modelName 模型名称
  /// @returns 删除的记录数
  Future<int> removeFavoriteModel(String providerId, String modelName) async {
    try {
      _logger.info('开始移除收藏模型', {
        'providerId': providerId,
        'modelName': modelName,
      });

      final result = await (_database.delete(_database.favoriteModels)
            ..where(
              (f) =>
                  f.providerId.equals(providerId) &
                  f.modelName.equals(modelName),
            ))
          .go();

      _logger.info('收藏模型移除完成', {
        'providerId': providerId,
        'modelName': modelName,
        'deletedCount': result,
      });

      return result;
    } catch (e, stackTrace) {
      _logger.error('移除收藏模型失败', {
        'providerId': providerId,
        'modelName': modelName,
        'error': e.toString(),
      });

      throw DatabaseError(
        message: '移除收藏模型失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 切换收藏状态
  ///
  /// @param providerId 提供商ID
  /// @param modelName 模型名称
  /// @returns 切换后的收藏状态（true=已收藏，false=已取消收藏）
  Future<bool> toggleFavoriteModel(String providerId, String modelName) async {
    try {
      _logger.info('开始切换模型收藏状态', {
        'providerId': providerId,
        'modelName': modelName,
      });

      final isFavorite = await isModelFavorite(providerId, modelName);
      if (isFavorite) {
        await removeFavoriteModel(providerId, modelName);
        _logger.info('模型收藏状态切换完成：已取消收藏', {
          'providerId': providerId,
          'modelName': modelName,
        });
        return false;
      } else {
        await addFavoriteModel(providerId, modelName);
        _logger.info('模型收藏状态切换完成：已添加收藏', {
          'providerId': providerId,
          'modelName': modelName,
        });
        return true;
      }
    } catch (e, stackTrace) {
      _logger.error('切换模型收藏状态失败', {
        'providerId': providerId,
        'modelName': modelName,
        'error': e.toString(),
      });

      throw DatabaseError(
        message: '切换模型收藏状态失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // 获取特定提供商的收藏模型
  Future<List<FavoriteModel>> getFavoriteModelsByProvider(
    String providerId,
  ) async {
    final favoriteDataList = await (_database.select(
      _database.favoriteModels,
    )..where((f) => f.providerId.equals(providerId)))
        .get();
    return favoriteDataList.map(_dataToModel).toList();
  }

  // 将数据库模型转换为业务模型
  FavoriteModel _dataToModel(FavoriteModelData data) {
    return FavoriteModel(
      id: data.id,
      providerId: data.providerId,
      modelName: data.modelName,
      createdAt: data.createdAt,
    );
  }
}
