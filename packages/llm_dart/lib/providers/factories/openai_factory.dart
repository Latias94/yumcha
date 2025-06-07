import '../../core/chat_provider.dart';
import '../../core/config.dart';
import '../../core/registry.dart';
import '../../models/tool_models.dart';
import '../openai_provider.dart';

/// Factory for creating OpenAI provider instances
class OpenAIProviderFactory implements LLMProviderFactory<ChatCapability> {
  @override
  String get providerId => 'openai';

  @override
  String get displayName => 'OpenAI';

  @override
  String get description =>
      'OpenAI GPT models including GPT-4, GPT-3.5, and reasoning models';

  @override
  Set<LLMCapability> get supportedCapabilities => {
        LLMCapability.chat,
        LLMCapability.streaming,
        LLMCapability.embedding,
        LLMCapability.modelListing,
        LLMCapability.toolCalling,
        LLMCapability.reasoning,
        LLMCapability.textToSpeech,
        LLMCapability.speechToText,
      };

  @override
  ChatCapability create(LLMConfig config) {
    final openaiConfig = _transformConfig(config);
    return OpenAIProvider(openaiConfig);
  }

  @override
  bool validateConfig(LLMConfig config) {
    // OpenAI requires an API key
    return config.apiKey != null && config.apiKey!.isNotEmpty;
  }

  @override
  LLMConfig getDefaultConfig() {
    return LLMConfig(
      baseUrl: 'https://api.openai.com/v1/',
      model: 'gpt-3.5-turbo',
    );
  }

  /// Transform unified config to OpenAI-specific config
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
      // OpenAI-specific extensions
      reasoningEffort: config.getExtension<String>('reasoningEffort'),
      jsonSchema: config.getExtension<StructuredOutputFormat>('jsonSchema'),
      voice: config.getExtension<String>('voice'),
      embeddingEncodingFormat:
          config.getExtension<String>('embeddingEncodingFormat'),
      embeddingDimensions: config.getExtension<int>('embeddingDimensions'),
    );
  }
}
