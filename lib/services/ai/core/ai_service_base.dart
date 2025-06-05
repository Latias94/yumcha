import '../../../models/ai_provider.dart' as models;
import '../../../models/ai_assistant.dart';
import '../../../models/ai_model.dart';
import '../../../models/message.dart';
import '../../logger_service.dart';
import '../../../ai_dart/ai_dart.dart';

/// AI服务能力枚举
enum AiCapability {
  /// 聊天对话
  chat,

  /// 流式聊天
  streaming,

  /// 模型列表
  models,

  /// 向量嵌入
  embedding,

  /// 语音转文字
  speechToText,

  /// 文字转语音
  textToSpeech,

  /// 图像生成
  imageGeneration,

  /// 工具调用
  toolCalling,

  /// 推理思考
  reasoning,

  /// 视觉理解
  vision,
}

/// AI服务基类，定义所有AI服务的通用接口
abstract class AiServiceBase {
  final LoggerService logger = LoggerService();

  /// 服务名称
  String get serviceName;

  /// 支持的能力列表
  Set<AiCapability> get supportedCapabilities;

  /// 检查是否支持指定能力
  bool supportsCapability(AiCapability capability) {
    return supportedCapabilities.contains(capability);
  }

  /// 初始化服务
  Future<void> initialize();

  /// 清理资源
  Future<void> dispose();
}

/// AI提供商适配器基类
abstract class AiProviderAdapter {
  final models.AiProvider provider;
  final AiAssistant assistant;
  final String modelName;
  final LoggerService _logger = LoggerService();

  AiProviderAdapter({
    required this.provider,
    required this.assistant,
    required this.modelName,
  });

  /// 创建AI Dart提供商实例
  Future<ChatProvider> createProvider({bool enableStreaming = false});

  /// 检测提供商支持的能力
  Set<AiCapability> detectCapabilities(ChatProvider chatProvider) {
    final capabilities = <AiCapability>{};

    // 基础聊天能力
    capabilities.add(AiCapability.chat);

    // 检测流式能力
    if (chatProvider is StreamingChatProvider) {
      capabilities.add(AiCapability.streaming);
    }

    // 检测模型列表能力
    if (chatProvider is ModelProvider) {
      capabilities.add(AiCapability.models);
    }

    // 检测嵌入能力
    if (chatProvider is EmbeddingProvider) {
      capabilities.add(AiCapability.embedding);
    }

    // 检测语音能力
    if (chatProvider is SpeechToTextProvider) {
      capabilities.add(AiCapability.speechToText);
    }

    if (chatProvider is TextToSpeechProvider) {
      capabilities.add(AiCapability.textToSpeech);
    }

    // 根据提供商类型和模型推断其他能力
    _inferAdditionalCapabilities(capabilities);

    return capabilities;
  }

  /// 根据模型配置推断额外能力
  void _inferAdditionalCapabilities(Set<AiCapability> capabilities) {
    // 查找当前模型的配置
    final model = provider.models.where((m) => m.name == modelName).firstOrNull;

    if (model != null) {
      // 根据模型的能力配置添加对应的AI能力
      for (final capability in model.capabilities) {
        switch (capability) {
          case ModelCapability.reasoning:
            capabilities.add(AiCapability.reasoning);
            break;
          case ModelCapability.vision:
            capabilities.add(AiCapability.vision);
            break;
          case ModelCapability.tools:
            capabilities.add(AiCapability.toolCalling);
            break;
          case ModelCapability.embedding:
            capabilities.add(AiCapability.embedding);
            break;
        }
      }
    }
    // 如果没有找到模型配置，不添加任何额外能力
  }

  /// 将应用消息转换为AI Dart消息
  List<ChatMessage> convertMessages(List<Message> messages) {
    return messages.map((msg) {
      if (msg.isFromUser) {
        return ChatMessage.user(msg.content);
      } else {
        return ChatMessage.assistant(msg.content);
      }
    }).toList();
  }

  /// 构建系统提示消息
  List<ChatMessage> buildSystemMessages() {
    final messages = <ChatMessage>[];

    if (assistant.systemPrompt.isNotEmpty) {
      messages.add(ChatMessage.system(assistant.systemPrompt));
    }

    return messages;
  }
}

/// 默认AI提供商适配器实现
class DefaultAiProviderAdapter extends AiProviderAdapter {
  DefaultAiProviderAdapter({
    required super.provider,
    required super.assistant,
    required super.modelName,
  });

  @override
  Future<ChatProvider> createProvider({bool enableStreaming = false}) async {
    try {
      final backend = _mapProviderType(provider.type.name);

      final builder = LLMBuilder()
          .backend(backend)
          .model(modelName)
          .temperature(assistant.temperature)
          .topP(assistant.topP)
          .maxTokens(assistant.maxTokens)
          .systemPrompt(assistant.systemPrompt)
          .stream(enableStreaming);

      // 设置API密钥
      if (provider.apiKey.isNotEmpty) {
        builder.apiKey(provider.apiKey);
      }

      // 设置基础URL
      if (provider.baseUrl?.isNotEmpty == true) {
        builder.baseUrl(provider.baseUrl!);
      }

      // 设置推理参数（针对支持的模型）
      if (assistant.enableReasoning && _supportsReasoning()) {
        builder.reasoningEffort('medium');
      }

      return await builder.build();
    } catch (e) {
      _logger.error('创建AI提供商失败', {
        'provider': provider.name,
        'model': modelName,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// 映射提供商类型到AI Dart后端
  LLMBackend _mapProviderType(String type) {
    switch (type.toLowerCase()) {
      case 'openai':
        return LLMBackend.openai;
      case 'anthropic':
        return LLMBackend.anthropic;
      case 'google':
        return LLMBackend.google;
      case 'deepseek':
        return LLMBackend.deepseek;
      case 'ollama':
        return LLMBackend.ollama;
      case 'xai':
        return LLMBackend.xai;
      case 'phind':
        return LLMBackend.phind;
      case 'groq':
        return LLMBackend.groq;
      case 'elevenlabs':
        return LLMBackend.elevenlabs;
      default:
        throw ArgumentError('不支持的提供商类型: $type');
    }
  }

  /// 检查是否支持推理功能
  /// 现在基于模型能力而不是提供商类型来判断
  bool _supportsReasoning() {
    // 检查当前模型是否支持推理功能
    final model = provider.models.where((m) => m.name == modelName).firstOrNull;

    if (model != null) {
      return model.capabilities.contains(ModelCapability.reasoning);
    }

    // 如果找不到模型配置，默认不支持推理
    return false;
  }
}
