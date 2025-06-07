import '../../core/chat_provider.dart';
import '../../core/config.dart';
import '../../core/registry.dart';
import '../../models/tool_models.dart';
import '../../models/chat_models.dart';
import '../openai_provider.dart';

/// Factory for creating XAI provider instances using OpenAI-compatible interface
class XAIProviderFactory implements LLMProviderFactory<ChatCapability> {
  @override
  String get providerId => 'xai';

  @override
  String get displayName => 'xAI (Grok)';

  @override
  String get description => 'xAI Grok models using OpenAI-compatible interface';

  @override
  Set<LLMCapability> get supportedCapabilities => {
        LLMCapability.chat,
        LLMCapability.streaming,
        LLMCapability.toolCalling,
        LLMCapability.reasoning,
      };

  @override
  ChatCapability create(LLMConfig config) {
    final xaiConfig = _transformConfig(config);
    return OpenAIProvider(xaiConfig);
  }

  @override
  bool validateConfig(LLMConfig config) {
    // XAI requires an API key
    return config.apiKey != null && config.apiKey!.isNotEmpty;
  }

  @override
  LLMConfig getDefaultConfig() {
    return LLMConfig(
      baseUrl: 'https://api.x.ai/v1/',
      model: 'grok-2-latest',
    );
  }

  /// Transform unified config to XAI-specific OpenAI config
  OpenAIConfig _transformConfig(LLMConfig config) {
    return OpenAIConfig(
      apiKey: config.apiKey!,
      baseUrl: config.baseUrl,
      model: config.model,
      maxTokens: config.maxTokens,
      temperature: config.temperature,
      systemPrompt: config.systemPrompt,
      timeout: config.timeout,
      stream: config.stream,
      topP: config.topP,
      topK: config.topK,
      tools: config.tools,
      toolChoice: config.toolChoice,
      // XAI-specific extensions (using OpenAI format)
      reasoningEffort: ReasoningEffort.fromString(
          config.getExtension<String>('reasoningEffort')),
      jsonSchema: config.getExtension<StructuredOutputFormat>('jsonSchema'),
      voice: config.getExtension<String>('voice'),
      embeddingEncodingFormat:
          config.getExtension<String>('embeddingEncodingFormat'),
      embeddingDimensions: config.getExtension<int>('embeddingDimensions'),
    );
  }
}
