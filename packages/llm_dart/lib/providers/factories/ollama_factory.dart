import '../../core/chat_provider.dart';
import '../../core/config.dart';
import '../../core/registry.dart';
import '../ollama_provider.dart';

/// Factory for creating Ollama provider instances
class OllamaProviderFactory implements LLMProviderFactory<ChatCapability> {
  @override
  String get providerId => 'ollama';

  @override
  String get displayName => 'Ollama';

  @override
  String get description =>
      'Ollama local LLM provider for self-hosted open source models';

  @override
  Set<LLMCapability> get supportedCapabilities => {
        LLMCapability.chat,
        LLMCapability.streaming,
        LLMCapability.embedding,
        LLMCapability.modelListing,
      };

  @override
  ChatCapability create(LLMConfig config) {
    final ollamaConfig = _transformConfig(config);
    return OllamaProvider(ollamaConfig);
  }

  @override
  bool validateConfig(LLMConfig config) {
    // Ollama doesn't require an API key, but needs a model
    return config.model.isNotEmpty;
  }

  @override
  LLMConfig getDefaultConfig() {
    return LLMConfig(
      baseUrl: 'http://localhost:11434',
      model: 'llama3.1',
    );
  }

  /// Transform unified config to Ollama-specific config
  OllamaConfig _transformConfig(LLMConfig config) {
    return OllamaConfig(
      baseUrl: config.baseUrl,
      apiKey: config.apiKey, // Optional for Ollama
      model: config.model,
      maxTokens: config.maxTokens,
      temperature: config.temperature,
      systemPrompt: config.systemPrompt,
      timeout: config.timeout,
      stream: config.stream,
      topP: config.topP,
      topK: config.topK,
      tools: config.tools,
      // Ollama-specific extensions
      jsonSchema: config.getExtension('jsonSchema'),
    );
  }
}
