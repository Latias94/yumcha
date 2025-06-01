import 'dart:convert';
import '../data/database.dart';
import '../data/converters.dart';
import '../models/ai_provider.dart';
import 'package:drift/drift.dart';

class ProviderRepository {
  final AppDatabase _database;

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
    final companion = _modelToCompanion(provider);
    await _database.insertProvider(companion);
    return provider.id;
  }

  // 更新提供商
  Future<bool> updateProvider(AiProvider provider) async {
    final companion = _modelToCompanion(provider);
    return await _database.updateProvider(provider.id, companion);
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
      supportedModels: data.supportedModels,
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
      supportedModels: Value(provider.supportedModels),
      customHeaders: Value(provider.customHeaders),
      isEnabled: Value(provider.isEnabled),
      createdAt: Value(provider.createdAt),
      updatedAt: Value(provider.updatedAt),
    );
  }
}
