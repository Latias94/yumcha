import '../data/database.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

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
