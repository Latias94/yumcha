import 'dart:async';
import '../../../../../features/ai_management/domain/entities/ai_provider.dart' as models;
import '../../../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../../../../../features/ai_management/domain/entities/ai_model.dart';
import '../../../../../features/ai_management/domain/entities/provider_model_config.dart';
import '../../../../../features/ai_management/domain/usecases/configure_provider_usecase.dart';
import '../core/ai_service_base.dart';
import 'package:ai_dart/ai_dart.dart';

/// 模型管理服务，负责获取和管理AI模型
class ModelService extends AiServiceBase {
  static final ModelService _instance = ModelService._internal();
  factory ModelService() => _instance;
  ModelService._internal();

  final Map<String, List<AiModel>> _modelCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(hours: 1);
  bool _isInitialized = false;

  @override
  String get serviceName => 'ModelService';

  @override
  Set<AiCapability> get supportedCapabilities => {AiCapability.models};

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    logger.info('初始化模型服务');
    _isInitialized = true;
    logger.info('模型服务初始化完成');
  }

  @override
  Future<void> dispose() async {
    logger.info('清理模型服务资源');
    _modelCache.clear();
    _cacheTimestamps.clear();
    _isInitialized = false;
  }

  /// 获取提供商的模型列表
  Future<List<AiModel>> getModelsFromProvider(
    models.AiProvider provider, {
    bool useCache = true,
  }) async {
    await initialize();

    final cacheKey = provider.id;

    // 检查缓存
    if (useCache && _isCacheValid(cacheKey)) {
      logger.debug('从缓存获取模型列表', {'provider': provider.name});
      return _modelCache[cacheKey]!;
    }

    logger.info('从API获取模型列表', {
      'provider': provider.name,
      'baseUrl': provider.baseUrl ?? '默认端点',
    });

    try {
      // 创建临时助手用于获取模型
      final tempAssistant = _createTempAssistant();

      // 创建适配器
      final adapter = DefaultAiProviderAdapter(
        provider: provider,
        assistant: tempAssistant,
        modelName: _getDefaultModel(provider),
      );

      // 创建提供商实例
      final chatProvider = await adapter.createProvider();

      // 检查是否支持模型列表功能
      if (chatProvider is! ModelListingCapability) {
        logger.warning('提供商不支持ModelListingCapability接口', {
          'provider': provider.name,
        });
        return [];
      }

      final modelProvider = chatProvider as ModelListingCapability;
      final aiModels = await modelProvider.models();

      // 转换AI Dart模型到应用模型格式
      final appModels = aiModels.map((aiModel) {
        return AiModel(
          id: aiModel.id,
          name: aiModel.id,
          displayName: aiModel.description?.isNotEmpty == true
              ? aiModel.description!
              : aiModel.id,
          capabilities: _inferModelCapabilities(aiModel.id)
              .map(
                (cap) => ModelCapability.values
                    .where((mc) => mc.id == cap)
                    .firstOrNull,
              )
              .where((cap) => cap != null)
              .cast<ModelCapability>()
              .toList(),
          metadata: {
            'source': 'api',
            'ownedBy': aiModel.ownedBy ?? 'unknown',
            'object': aiModel.object,
          },
          isEnabled: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();

      // 过滤和排序模型
      final filteredModels = _filterAndSortModels(appModels);

      // 更新缓存
      _modelCache[cacheKey] = filteredModels;
      _cacheTimestamps[cacheKey] = DateTime.now();

      logger.info('模型列表获取完成', {
        'provider': provider.name,
        'count': filteredModels.length,
      });

      return filteredModels;
    } catch (e) {
      logger.error('获取模型列表失败', {
        'provider': provider.name,
        'error': e.toString(),
      });

      // 返回缓存的模型（如果有）
      if (_modelCache.containsKey(cacheKey)) {
        logger.info('返回缓存的模型列表', {'provider': provider.name});
        return _modelCache[cacheKey]!;
      }

      return [];
    }
  }

  /// 检测模型能力
  Set<String> detectModelCapabilities({
    required models.AiProvider provider,
    required String modelName,
  }) {
    final capabilities = <String>{};

    // 基础聊天能力
    capabilities.add('chat');

    // 使用提供商配置推断能力，如果没有配置则使用通用推断
    capabilities.addAll(_inferModelCapabilities(modelName, provider));

    return capabilities;
  }

  /// 清除模型缓存
  void clearCache([String? providerId]) {
    if (providerId != null) {
      _modelCache.remove(providerId);
      _cacheTimestamps.remove(providerId);
      logger.debug('清除提供商模型缓存', {'provider': providerId});
    } else {
      _modelCache.clear();
      _cacheTimestamps.clear();
      logger.debug('清除所有模型缓存');
    }
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    return {
      'cachedProviders': _modelCache.length,
      'totalModels': _modelCache.values.fold<int>(
        0,
        (sum, models) => sum + models.length,
      ),
      'cacheTimestamps': _cacheTimestamps.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
    };
  }

  /// 检查缓存是否有效
  bool _isCacheValid(String cacheKey) {
    if (!_modelCache.containsKey(cacheKey) ||
        !_cacheTimestamps.containsKey(cacheKey)) {
      return false;
    }

    final timestamp = _cacheTimestamps[cacheKey]!;
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  /// 创建临时助手
  AiAssistant _createTempAssistant() {
    return AiAssistant(
      id: 'temp-model-fetcher',
      name: 'Model Fetcher',
      avatar: '📋',
      systemPrompt: '',
      temperature: 0.7,
      topP: 1.0,
      maxTokens: 100,
      contextLength: 1,
      streamOutput: false,
      isEnabled: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: '临时模型获取助手',
      customHeaders: {},
      customBody: {},
      stopSequences: [],
      frequencyPenalty: 0.0,
      presencePenalty: 0.0,
      enableCodeExecution: false,
      enableImageGeneration: false,
      enableTools: false,
      enableReasoning: false,
      enableVision: false,
      enableEmbedding: false,
    );
  }

  /// 获取默认模型
  String _getDefaultModel(models.AiProvider provider) {
    // 如果提供商有配置的模型，使用第一个
    if (provider.models.isNotEmpty) {
      return provider.models.first.name;
    }

    // 如果没有配置模型，返回一个通用的模型名
    // 这个模型名可能不存在，但会在API调用时被发现
    return 'default-model';
  }

  /// 推断模型能力
  Set<String> _inferModelCapabilities(
    String modelName, [
    models.AiProvider? provider,
  ]) {
    final capabilities = <String>{'chat'};

    // 如果有提供商配置，优先使用配置的能力
    if (provider != null) {
      final configCapabilities = _getCapabilitiesFromConfig(
        modelName,
        provider,
      );
      if (configCapabilities.isNotEmpty) {
        capabilities.addAll(configCapabilities);
        return capabilities;
      }
    }

    // 如果没有配置，使用通用推断
    final lowerName = modelName.toLowerCase();

    // 视觉能力
    if (lowerName.contains('vision') ||
        lowerName.contains('gpt-4') ||
        lowerName.contains('claude-3') ||
        lowerName.contains('gemini')) {
      capabilities.add('vision');
    }

    // 推理能力
    if (lowerName.contains('o1') ||
        lowerName.contains('claude') ||
        lowerName.contains('reasoning')) {
      capabilities.add('reasoning');
    }

    // 工具调用
    if (!lowerName.contains('base') &&
        !lowerName.contains('instruct') &&
        !lowerName.contains('embedding')) {
      capabilities.add('tools');
    }

    // 嵌入能力
    if (lowerName.contains('embedding') || lowerName.contains('embed')) {
      capabilities.add('embedding');
    }

    return capabilities;
  }

  /// 从提供商配置获取模型能力
  Set<String> _getCapabilitiesFromConfig(
    String modelName,
    models.AiProvider provider,
  ) {
    // 这里需要导入并使用 ProviderConfigService
    // 暂时返回空集合，后续会完善
    return <String>{};
  }

  /// 过滤和排序模型
  List<AiModel> _filterAndSortModels(List<AiModel> models) {
    // 过滤掉不需要的模型
    final filtered = models.where((model) {
      final name = model.name.toLowerCase();
      return !name.contains('whisper') &&
          !name.contains('tts') &&
          !name.contains('dall-e') &&
          !name.contains('babbage') &&
          !name.contains('ada') &&
          !name.contains('curie') &&
          !name.contains('davinci') &&
          !name.contains('moderation');
    }).toList();

    // 按名称排序
    filtered.sort((a, b) => a.name.compareTo(b.name));

    return filtered;
  }
}
