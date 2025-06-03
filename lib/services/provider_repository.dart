import '../data/database.dart';
import '../data/converters.dart';
import '../models/ai_provider.dart';
import '../services/validation_service.dart';
import '../services/logger_service.dart';
import '../utils/error_handler.dart';
import 'package:drift/drift.dart';

class ProviderRepository {
  final AppDatabase _database;
  final ValidationService _validationService = ValidationService.instance;
  final LoggerService _logger = LoggerService();

  ProviderRepository(this._database);

  // 获取所有提供商
  Future<List<AiProvider>> getAllProviders() async {
    final providerDataList = await _database.getAllProviders();
    return providerDataList.map(_dataToModel).toList();
  }

  // 根据ID获取提供商
  Future<AiProvider?> getProvider(String id) async {
    final providerData = await _database.getProvider(id);
    if (providerData == null) return null;
    return _dataToModel(providerData);
  }

  // 添加新提供商
  Future<String> insertProvider(AiProvider provider) async {
    _logger.info('开始添加新提供商: ${provider.name}');

    // 验证提供商数据
    _validationService.validateAiProvider(provider);

    try {
      final companion = _modelToCompanion(provider);
      await _database.insertProvider(companion);

      _logger.info('提供商添加成功: ${provider.name}');
      return provider.id;
    } catch (e, stackTrace) {
      _logger.error('提供商添加失败: ${provider.name}, 错误: $e', e, stackTrace);

      throw DatabaseError(
        message: '添加提供商失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // 更新提供商
  Future<bool> updateProvider(AiProvider provider) async {
    _logger.info('开始更新提供商: ${provider.name}');

    // 验证提供商数据
    _validationService.validateAiProvider(provider);

    try {
      final companion = _modelToCompanion(provider);
      final result = await _database.updateProvider(provider.id, companion);

      _logger.info('提供商更新完成: ${provider.name}, 成功: $result');
      return result;
    } catch (e, stackTrace) {
      _logger.error('提供商更新失败: ${provider.name}, 错误: $e', e, stackTrace);

      throw DatabaseError(
        message: '更新提供商失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // 删除提供商
  Future<int> deleteProvider(String id) async {
    return await _database.deleteProvider(id);
  }

  // 获取启用的提供商
  Future<List<AiProvider>> getEnabledProviders() async {
    final allProviders = await getAllProviders();
    return allProviders.where((p) => p.isEnabled).toList();
  }

  // 切换提供商启用状态
  Future<bool> toggleProviderEnabled(String id) async {
    final provider = await getProvider(id);
    if (provider == null) return false;

    final updatedProvider = provider.copyWith(
      isEnabled: !provider.isEnabled,
      updatedAt: DateTime.now(),
    );

    return await updateProvider(updatedProvider);
  }

  // 将数据库模型转换为业务模型
  AiProvider _dataToModel(ProviderData data) {
    return AiProvider(
      id: data.id,
      name: data.name,
      type: dbToModelProviderType(data.type),
      apiKey: data.apiKey,
      baseUrl: data.baseUrl,
      models: data.models,
      customHeaders: data.customHeaders,
      isEnabled: data.isEnabled,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  // 将业务模型转换为数据库Companion
  ProvidersCompanion _modelToCompanion(AiProvider provider) {
    return ProvidersCompanion(
      id: Value(provider.id),
      name: Value(provider.name),
      type: Value(modelToDbProviderType(provider.type)),
      apiKey: Value(provider.apiKey),
      baseUrl: Value(provider.baseUrl),
      models: Value(provider.models),
      customHeaders: Value(provider.customHeaders),
      isEnabled: Value(provider.isEnabled),
      createdAt: Value(provider.createdAt),
      updatedAt: Value(provider.updatedAt),
    );
  }
}
