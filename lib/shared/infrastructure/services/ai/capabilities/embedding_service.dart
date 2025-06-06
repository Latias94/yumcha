import 'dart:async';
import '../../../../../features/ai_management/domain/entities/ai_provider.dart' as models;
import '../../../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../../../../../features/ai_management/domain/entities/ai_model.dart';
import '../core/ai_service_base.dart';
import 'package:ai_dart/ai_dart.dart';

/// 嵌入向量服务，负责处理文本向量化
class EmbeddingService extends AiServiceBase {
  static final EmbeddingService _instance = EmbeddingService._internal();
  factory EmbeddingService() => _instance;
  EmbeddingService._internal();

  final Map<String, List<List<double>>> _embeddingCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(hours: 24);
  bool _isInitialized = false;

  @override
  String get serviceName => 'EmbeddingService';

  @override
  Set<AiCapability> get supportedCapabilities => {AiCapability.embedding};

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    logger.info('初始化嵌入服务');
    _isInitialized = true;
    logger.info('嵌入服务初始化完成');
  }

  @override
  Future<void> dispose() async {
    logger.info('清理嵌入服务资源');
    _embeddingCache.clear();
    _cacheTimestamps.clear();
    _isInitialized = false;
  }

  /// 生成文本嵌入向量
  Future<List<List<double>>> generateEmbeddings({
    required models.AiProvider provider,
    required List<String> texts,
    bool useCache = true,
  }) async {
    await initialize();

    final cacheKey = _generateCacheKey(provider.id, texts);

    // 检查缓存
    if (useCache && _isCacheValid(cacheKey)) {
      logger.debug('从缓存获取嵌入向量', {
        'provider': provider.name,
        'textCount': texts.length,
      });
      return _embeddingCache[cacheKey]!;
    }

    logger.info('生成嵌入向量', {
      'provider': provider.name,
      'textCount': texts.length,
    });

    try {
      // 创建临时助手
      final tempAssistant = _createTempAssistant();

      // 创建适配器
      final adapter = DefaultAiProviderAdapter(
        provider: provider,
        assistant: tempAssistant,
        modelName: _getEmbeddingModel(provider),
      );

      // 创建提供商实例
      final chatProvider = await adapter.createProvider();

      // 检查是否支持嵌入功能
      if (chatProvider is! EmbeddingCapability) {
        throw Exception('提供商不支持嵌入功能: ${provider.name}');
      }

      final embeddingProvider = chatProvider as EmbeddingCapability;
      final embeddings = await embeddingProvider.embed(texts);

      // 更新缓存
      _embeddingCache[cacheKey] = embeddings;
      _cacheTimestamps[cacheKey] = DateTime.now();

      logger.info('嵌入向量生成完成', {
        'provider': provider.name,
        'textCount': texts.length,
        'vectorDimensions': embeddings.isNotEmpty ? embeddings.first.length : 0,
      });

      return embeddings;
    } catch (e) {
      logger.error('嵌入向量生成失败', {
        'provider': provider.name,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// 计算文本相似度
  double calculateSimilarity(List<double> vector1, List<double> vector2) {
    if (vector1.length != vector2.length) {
      throw ArgumentError('向量维度不匹配');
    }

    // 计算余弦相似度
    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;

    for (int i = 0; i < vector1.length; i++) {
      dotProduct += vector1[i] * vector2[i];
      norm1 += vector1[i] * vector1[i];
      norm2 += vector2[i] * vector2[i];
    }

    if (norm1 == 0.0 || norm2 == 0.0) {
      return 0.0;
    }

    return dotProduct / (Math.sqrt(norm1) * Math.sqrt(norm2));
  }

  /// 查找最相似的文本
  List<SimilarityResult> findMostSimilar({
    required List<double> queryVector,
    required List<List<double>> candidateVectors,
    required List<String> candidateTexts,
    int topK = 5,
    double threshold = 0.0,
  }) {
    if (candidateVectors.length != candidateTexts.length) {
      throw ArgumentError('候选向量和文本数量不匹配');
    }

    final results = <SimilarityResult>[];

    for (int i = 0; i < candidateVectors.length; i++) {
      final similarity = calculateSimilarity(queryVector, candidateVectors[i]);

      if (similarity >= threshold) {
        results.add(
          SimilarityResult(
            text: candidateTexts[i],
            vector: candidateVectors[i],
            similarity: similarity,
            index: i,
          ),
        );
      }
    }

    // 按相似度降序排序
    results.sort((a, b) => b.similarity.compareTo(a.similarity));

    // 返回前topK个结果
    return results.take(topK).toList();
  }

  /// 清除嵌入缓存
  void clearCache([String? providerId]) {
    if (providerId != null) {
      final keysToRemove = _embeddingCache.keys
          .where((key) => key.startsWith('${providerId}_'))
          .toList();

      for (final key in keysToRemove) {
        _embeddingCache.remove(key);
        _cacheTimestamps.remove(key);
      }

      logger.debug('清除提供商嵌入缓存', {'provider': providerId});
    } else {
      _embeddingCache.clear();
      _cacheTimestamps.clear();
      logger.debug('清除所有嵌入缓存');
    }
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    return {
      'cachedEmbeddings': _embeddingCache.length,
      'totalVectors': _embeddingCache.values.fold<int>(
        0,
        (sum, embeddings) => sum + embeddings.length,
      ),
      'cacheTimestamps': _cacheTimestamps.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
    };
  }

  /// 检查缓存是否有效
  bool _isCacheValid(String cacheKey) {
    if (!_embeddingCache.containsKey(cacheKey) ||
        !_cacheTimestamps.containsKey(cacheKey)) {
      return false;
    }

    final timestamp = _cacheTimestamps[cacheKey]!;
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  /// 生成缓存键
  String _generateCacheKey(String providerId, List<String> texts) {
    final textHash = texts.join('|').hashCode.toString();
    return '${providerId}_$textHash';
  }

  /// 创建临时助手
  AiAssistant _createTempAssistant() {
    return AiAssistant(
      id: 'temp-embedding-assistant',
      name: 'Embedding Assistant',
      avatar: '🔍',
      systemPrompt: '',
      temperature: 0.0,
      topP: 1.0,
      maxTokens: 1,
      contextLength: 1,
      streamOutput: false,
      isEnabled: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: '临时嵌入助手',
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
      enableEmbedding: true,
    );
  }

  /// 获取嵌入模型
  String _getEmbeddingModel(models.AiProvider provider) {
    // 如果提供商有配置的嵌入模型，使用第一个
    final embeddingModels = provider.models
        .where(
          (model) => model.capabilities.contains(ModelCapability.embedding),
        )
        .toList();
    if (embeddingModels.isNotEmpty) {
      return embeddingModels.first.name;
    }

    // 否则根据提供商类型返回常见的嵌入模型
    switch (provider.type.name.toLowerCase()) {
      case 'openai':
        return 'text-embedding-3-small';
      case 'ollama':
        return 'nomic-embed-text';
      default:
        return 'default-embedding-model';
    }
  }
}

/// 相似度结果
class SimilarityResult {
  final String text;
  final List<double> vector;
  final double similarity;
  final int index;

  const SimilarityResult({
    required this.text,
    required this.vector,
    required this.similarity,
    required this.index,
  });

  @override
  String toString() {
    final displayText = text.length > 50 ? '${text.substring(0, 50)}...' : text;
    return 'SimilarityResult(similarity: ${similarity.toStringAsFixed(4)}, text: $displayText)';
  }
}

/// 数学工具类
class Math {
  static double sqrt(double x) => x < 0
      ? double.nan
      : x == 0
      ? 0
      : _sqrt(x);

  static double _sqrt(double x) {
    if (x == 0) return 0;
    double guess = x / 2;
    double prev;
    do {
      prev = guess;
      guess = (guess + x / guess) / 2;
    } while ((guess - prev).abs() > 1e-10);
    return guess;
  }
}
