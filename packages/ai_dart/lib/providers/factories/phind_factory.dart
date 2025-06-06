import '../../core/chat_provider.dart';
import '../../core/config.dart';
import '../../core/registry.dart';
import '../../models/tool_models.dart';
import '../openai_provider.dart';

/// Factory for creating Phind provider instances using OpenAI-compatible interface
class PhindProviderFactory implements LLMProviderFactory<ChatCapability> {
  @override
  String get providerId => 'phind';

  @override
  String get displayName => 'Phind';

  @override
  String get description =>
      'Phind AI models using OpenAI-compatible interface for fast coding assistance';

  @override
  Set<LLMCapability> get supportedCapabilities => {
        LLMCapability.chat,
        LLMCapability.streaming,
        LLMCapability.toolCalling,
      };

  @override
  ChatCapability create(LLMConfig config) {
    final phindConfig = _transformConfig(config);
    return OpenAIProvider(phindConfig);
  }

  @override
  bool validateConfig(LLMConfig config) {
    // Phind requires an API key
    return config.apiKey != null && config.apiKey!.isNotEmpty;
  }

  @override
  LLMConfig getDefaultConfig() {
    return LLMConfig(
      baseUrl: 'https://https.extension.phind.com/agent/',
      model: 'Phind-70B',
    );
  }

  /// Transform unified config to Phind-specific OpenAI config
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
      // Phind-specific extensions (using OpenAI format)
      reasoningEffort: config.getExtension<String>('reasoningEffort'),
      jsonSchema: config.getExtension<StructuredOutputFormat>('jsonSchema'),
    );
  }
}
