import '../data/database.dart';
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

  FavoriteModelRepository(this._database);

  // 获取所有收藏的模型
  Future<List<FavoriteModel>> getAllFavoriteModels() async {
    final favoriteDataList = await _database
        .select(_database.favoriteModels)
        .get();
    return favoriteDataList.map(_dataToModel).toList();
  }

  // 检查模型是否被收藏
  Future<bool> isModelFavorite(String providerId, String modelName) async {
    final result =
        await (_database.select(_database.favoriteModels)..where(
              (f) =>
                  f.providerId.equals(providerId) &
                  f.modelName.equals(modelName),
            ))
            .getSingleOrNull();
    return result != null;
  }

  // 添加收藏模型
  Future<String> addFavoriteModel(String providerId, String modelName) async {
    // 检查是否已经存在
    final existing = await isModelFavorite(providerId, modelName);
    if (existing) {
      throw Exception('模型已经被收藏');
    }

    final id = _uuid.v4();
    final companion = FavoriteModelsCompanion(
      id: Value(id),
      providerId: Value(providerId),
      modelName: Value(modelName),
      createdAt: Value(DateTime.now()),
    );

    await _database.into(_database.favoriteModels).insert(companion);
    return id;
  }

  // 移除收藏模型
  Future<int> removeFavoriteModel(String providerId, String modelName) async {
    return await (_database.delete(_database.favoriteModels)..where(
          (f) =>
              f.providerId.equals(providerId) & f.modelName.equals(modelName),
        ))
        .go();
  }

  // 切换收藏状态
  Future<bool> toggleFavoriteModel(String providerId, String modelName) async {
    final isFavorite = await isModelFavorite(providerId, modelName);
    if (isFavorite) {
      await removeFavoriteModel(providerId, modelName);
      return false;
    } else {
      await addFavoriteModel(providerId, modelName);
      return true;
    }
  }

  // 获取特定提供商的收藏模型
  Future<List<FavoriteModel>> getFavoriteModelsByProvider(
    String providerId,
  ) async {
    final favoriteDataList = await (_database.select(
      _database.favoriteModels,
    )..where((f) => f.providerId.equals(providerId))).get();
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
