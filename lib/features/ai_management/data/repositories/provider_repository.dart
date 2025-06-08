import 'package:yumcha/shared/exports.dart';
import 'package:yumcha/core/exports.dart';
import '../../domain/entities/ai_provider.dart';
import 'package:drift/drift.dart';

/// AI提供商数据仓库 - 管理AI提供商的数据持久化操作
///
/// ProviderRepository实现了Repository模式，负责AI提供商数据的CRUD操作：
/// - 📊 **数据管理**：提供商的增删改查操作
/// - 🔄 **模型转换**：数据库模型与业务模型的转换
/// - ✅ **数据验证**：确保提供商数据的完整性和有效性
/// - 📝 **操作日志**：记录所有数据操作的详细日志
/// - 🛡️ **错误处理**：统一的异常处理和错误包装
/// - 🎛️ **状态管理**：提供商启用/禁用状态管理
///
/// ## 🏗️ 架构设计
///
/// ### Repository模式
/// 提供统一的数据访问接口，隔离业务逻辑和数据存储：
/// ```
/// UI Layer → ProviderRepository → Database Layer
/// ```
///
/// ### 依赖注入
/// 通过构造函数注入数据库实例，支持测试和解耦：
/// ```dart
/// final repository = ProviderRepository(database);
/// ```
///
/// ### 模型转换
/// 自动处理数据库模型和业务模型之间的转换：
/// - `ProviderData` (数据库) ↔ `AiProvider` (业务)
/// - 类型安全的枚举转换
/// - 自动时间戳管理
///
/// ## 📊 支持的提供商类型
/// - **OpenAI**: GPT系列模型
/// - **Anthropic**: Claude系列模型
/// - **Google**: Gemini系列模型
/// - **Ollama**: 本地部署模型
/// - **Custom**: 自定义OpenAI兼容API
///
/// ## 🚀 使用示例
///
/// ### 基础CRUD操作
/// ```dart
/// final repository = ProviderRepository(database);
///
/// // 添加新提供商
/// final provider = AiProvider(
///   id: 'openai-1',
///   name: 'OpenAI',
///   type: AiProviderType.openai,
///   apiKey: 'sk-...',
/// );
/// await repository.insertProvider(provider);
///
/// // 查询提供商
/// final providers = await repository.getAllProviders();
/// final openai = await repository.getProvider('openai-1');
///
/// // 更新提供商
/// final updated = provider.copyWith(name: 'OpenAI Updated');
/// await repository.updateProvider(updated);
///
/// // 删除提供商
/// await repository.deleteProvider('openai-1');
/// ```
///
/// ### 状态管理
/// ```dart
/// // 获取启用的提供商
/// final enabled = await repository.getEnabledProviders();
///
/// // 切换启用状态
/// await repository.toggleProviderEnabled('openai-1');
/// ```
///
/// ## ⚙️ 特性
/// - **自动验证**: 使用ValidationService验证数据完整性
/// - **详细日志**: 记录所有操作的成功/失败信息
/// - **错误包装**: 将底层异常包装为业务友好的错误
/// - **类型安全**: 强类型的模型转换和验证
/// - **事务支持**: 支持数据库事务操作
class ProviderRepository {
  /// 数据库实例
  ///
  /// 通过依赖注入获取，支持测试时使用Mock数据库
  final AppDatabase _database;

  /// 数据验证服务
  ///
  /// 用于验证AI提供商数据的完整性和有效性
  final ValidationService _validationService = ValidationService.instance;

  /// 日志记录服务
  ///
  /// 记录所有数据操作的详细日志，便于调试和监控
  final LoggerService _logger = LoggerService();

  /// 构造函数
  ///
  /// @param _database 数据库实例，通过依赖注入提供
  ProviderRepository(this._database);

  /// 获取所有AI提供商
  ///
  /// 从数据库中检索所有已配置的AI提供商，包括启用和禁用的。
  ///
  /// ## 🔄 数据流程
  /// 1. 从数据库查询所有ProviderData
  /// 2. 将数据库模型转换为业务模型
  /// 3. 返回AiProvider列表
  ///
  /// ## 📊 返回数据
  /// 返回的列表包含所有提供商的完整信息：
  /// - 基本信息（ID、名称、类型）
  /// - 认证信息（API密钥、基础URL）
  /// - 配置信息（自定义头部、模型列表）
  /// - 状态信息（启用状态、时间戳）
  ///
  /// @returns 所有AI提供商的列表
  ///
  /// ## 使用示例
  /// ```dart
  /// final providers = await repository.getAllProviders();
  /// for (final provider in providers) {
  ///   print('提供商: ${provider.name}, 类型: ${provider.type}');
  /// }
  /// ```
  Future<List<AiProvider>> getAllProviders() async {
    final providerDataList = await _database.getAllProviders();
    return providerDataList.map(_dataToModel).toList();
  }

  /// 根据ID获取特定的AI提供商
  ///
  /// 通过提供商ID查询单个提供商的详细信息。
  ///
  /// ## 🎯 查询逻辑
  /// - 如果找到匹配的提供商，返回完整的AiProvider对象
  /// - 如果未找到，返回null
  /// - 自动进行数据库模型到业务模型的转换
  ///
  /// @param id 提供商的唯一标识符
  /// @returns 匹配的AI提供商，如果不存在则返回null
  ///
  /// ## 使用示例
  /// ```dart
  /// final provider = await repository.getProvider('openai-1');
  /// if (provider != null) {
  ///   print('找到提供商: ${provider.name}');
  /// } else {
  ///   print('提供商不存在');
  /// }
  /// ```
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
