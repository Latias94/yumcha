import '../../core/chat_provider.dart';
import '../../core/config.dart';
import '../../core/registry.dart';
import '../anthropic_provider.dart';

/// Factory for creating Anthropic provider instances
class AnthropicProviderFactory implements LLMProviderFactory<ChatCapability> {
  @override
  String get providerId => 'anthropic';

  @override
  String get displayName => 'Anthropic';

  @override
  String get description =>
      'Anthropic Claude models including Claude 3.5 Sonnet and reasoning models';

  @override
  Set<LLMCapability> get supportedCapabilities => {
        LLMCapability.chat,
        LLMCapability.streaming,
        LLMCapability.toolCalling,
        LLMCapability.reasoning,
      };

  @override
  ChatCapability create(LLMConfig config) {
    final anthropicConfig = _transformConfig(config);
    return AnthropicProvider(anthropicConfig);
  }

  @override
  bool validateConfig(LLMConfig config) {
    // Anthropic requires an API key
    return config.apiKey != null && config.apiKey!.isNotEmpty;
  }

  @override
  LLMConfig getDefaultConfig() {
    return LLMConfig(
      baseUrl: 'https://api.anthropic.com/v1/',
      model: 'claude-3-5-sonnet-20241022',
    );
  }

  /// Transform unified config to Anthropic-specific config
  AnthropicConfig _transformConfig(LLMConfig config) {
    return AnthropicConfig(
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
      // Anthropic-specific extensions
      reasoning: config.getExtension<bool>('reasoning') ?? false,
      thinkingBudgetTokens: config.getExtension<int>('thinkingBudgetTokens'),
    );
  }
}
