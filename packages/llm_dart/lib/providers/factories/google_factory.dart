import '../../core/chat_provider.dart';
import '../../core/config.dart';
import '../../core/registry.dart';
import '../../models/tool_models.dart';
import '../../models/chat_models.dart';
import '../google_provider.dart';

/// Factory for creating Google (Gemini) provider instances
class GoogleProviderFactory implements LLMProviderFactory<ChatCapability> {
  @override
  String get providerId => 'google';

  @override
  String get displayName => 'Google';

  @override
  String get description =>
      'Google Gemini models including Gemini 1.5 Flash and Pro';

  @override
  Set<LLMCapability> get supportedCapabilities => {
        LLMCapability.chat,
        LLMCapability.streaming,
        LLMCapability.toolCalling,
        LLMCapability.embedding,
        LLMCapability.reasoning,
        LLMCapability.vision,
      };

  @override
  ChatCapability create(LLMConfig config) {
    final googleConfig = _transformConfig(config);
    return GoogleProvider(googleConfig);
  }

  @override
  bool validateConfig(LLMConfig config) {
    // Google requires an API key
    return config.apiKey != null && config.apiKey!.isNotEmpty;
  }

  @override
  LLMConfig getDefaultConfig() {
    return LLMConfig(
      baseUrl: 'https://generativelanguage.googleapis.com/v1beta/',
      model: 'gemini-1.5-flash',
    );
  }

  /// Transform unified config to Google-specific config
  GoogleConfig _transformConfig(LLMConfig config) {
    return GoogleConfig(
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
      // Google-specific extensions
      jsonSchema: config.getExtension<StructuredOutputFormat>('jsonSchema'),
      reasoningEffort: config.getExtension<ReasoningEffort>('reasoningEffort'),
      thinkingBudgetTokens: config.getExtension<int>('thinkingBudgetTokens'),
      includeThoughts: config.getExtension<bool>('reasoning') ??
          config.getExtension<bool>('includeThoughts'),
      enableImageGeneration: config.getExtension<bool>('enableImageGeneration'),
      responseModalities:
          config.getExtension<List<String>>('responseModalities'),
    );
  }
}
