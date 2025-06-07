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
        LLMCapability.vision,
      };

  @override
  ChatCapability create(LLMConfig config) {
    final anthropicConfig = AnthropicConfig.fromLLMConfig(config);
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
      model:
          'claude-3-5-sonnet-20241022', // Keep current default for compatibility
    );
  }
}
