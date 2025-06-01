import 'package:dio/dio.dart';
import '../models/ai_provider.dart';
import '../models/ai_model.dart';

class ModelFetchService {
  static final ModelFetchService _instance = ModelFetchService._internal();
  factory ModelFetchService() => _instance;
  ModelFetchService._internal();

  final Dio _dio = Dio();

  /// 从提供商API获取模型列表
  Future<List<AiModel>> fetchModelsFromProvider(AiProvider provider) async {
    if (provider.type != ProviderType.openai) {
      throw UnsupportedError('只支持 OpenAI 类型的提供商获取模型列表');
    }

    if (provider.apiKey.isEmpty) {
      throw ArgumentError('API Key 不能为空');
    }

    final baseUrl = provider.effectiveBaseUrl;
    final url = '$baseUrl/models';

    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${provider.apiKey}',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: '获取模型列表失败: HTTP ${response.statusCode}',
        );
      }

      final data = response.data;
      if (data is! Map<String, dynamic> || !data.containsKey('data')) {
        throw FormatException('API 响应格式不正确');
      }

      final models = <AiModel>[];
      final now = DateTime.now();

      for (final modelData in data['data']) {
        if (modelData is Map<String, dynamic> && modelData.containsKey('id')) {
          final modelId = modelData['id'] as String;
          
          // 过滤掉一些不是聊天模型的模型
          if (_shouldIncludeModel(modelId)) {
            models.add(AiModel(
              id: modelId,
              name: modelId,
              displayName: _getDisplayName(modelId),
              capabilities: _getCapabilities(modelId),
              metadata: _getMetadata(modelData),
              createdAt: now,
              updatedAt: now,
            ));
          }
        }
      }

      // 按模型名称排序
      models.sort((a, b) => a.name.compareTo(b.name));
      
      return models;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('API Key 无效或已过期');
      } else if (e.response?.statusCode == 403) {
        throw Exception('API Key 权限不足');
      } else if (e.response?.statusCode == 404) {
        throw Exception('API 端点不存在，请检查 Base URL 是否正确');
      } else {
        throw Exception('网络请求失败: ${e.message}');
      }
    } catch (e) {
      throw Exception('获取模型列表失败: $e');
    }
  }

  /// 判断是否应该包含该模型
  bool _shouldIncludeModel(String modelId) {
    // 排除一些非聊天模型
    final excludePatterns = [
      'whisper',
      'tts',
      'dall-e',
      'embedding',
      'moderation',
      'babbage',
      'ada',
      'curie',
      'davinci',
    ];

    final lowerModelId = modelId.toLowerCase();
    for (final pattern in excludePatterns) {
      if (lowerModelId.contains(pattern)) {
        return false;
      }
    }

    return true;
  }

  /// 获取模型显示名称
  String _getDisplayName(String modelId) {
    final displayNames = {
      'gpt-4o': 'GPT-4o',
      'gpt-4o-mini': 'GPT-4o Mini',
      'gpt-4-turbo': 'GPT-4 Turbo',
      'gpt-4': 'GPT-4',
      'gpt-3.5-turbo': 'GPT-3.5 Turbo',
      'gpt-3.5-turbo-16k': 'GPT-3.5 Turbo 16K',
    };

    return displayNames[modelId] ?? modelId;
  }

  /// 获取模型能力
  List<ModelCapability> _getCapabilities(String modelId) {
    final lowerModelId = modelId.toLowerCase();
    
    if (lowerModelId.contains('vision') || 
        lowerModelId.contains('gpt-4o') ||
        lowerModelId.contains('gpt-4-turbo')) {
      return [ModelCapability.chat, ModelCapability.imageAnalysis];
    }
    
    return [ModelCapability.chat];
  }

  /// 获取模型元数据
  Map<String, dynamic> _getMetadata(Map<String, dynamic> modelData) {
    final metadata = <String, dynamic>{};
    
    // 从API响应中提取有用信息
    if (modelData.containsKey('created')) {
      metadata['created'] = modelData['created'];
    }
    
    if (modelData.containsKey('owned_by')) {
      metadata['ownedBy'] = modelData['owned_by'];
    }

    // 根据模型名称设置上下文长度
    final modelId = modelData['id'] as String;
    metadata['contextLength'] = _getContextLength(modelId);
    
    return metadata;
  }

  /// 获取模型上下文长度
  int _getContextLength(String modelId) {
    final contextLengths = {
      'gpt-4o': 128000,
      'gpt-4o-mini': 128000,
      'gpt-4-turbo': 128000,
      'gpt-4': 8192,
      'gpt-3.5-turbo': 16385,
      'gpt-3.5-turbo-16k': 16385,
    };

    return contextLengths[modelId] ?? 4096;
  }
}
