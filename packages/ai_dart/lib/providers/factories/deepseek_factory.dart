import '../../core/chat_provider.dart';
import '../../core/config.dart';
import '../../core/registry.dart';
import '../deepseek_provider.dart';

/// Factory for creating DeepSeek provider instances
class DeepSeekProviderFactory implements LLMProviderFactory<ChatCapability> {
  @override
  String get providerId => 'deepseek';

  @override
  String get displayName => 'DeepSeek';

  @override
  String get description =>
      'DeepSeek AI models including DeepSeek Chat and reasoning models';

  @override
  Set<LLMCapability> get supportedCapabilities => {
        LLMCapability.chat,
        LLMCapability.streaming,
        LLMCapability.toolCalling,
        LLMCapability.reasoning,
      };

  @override
  ChatCapability create(LLMConfig config) {
    final deepseekConfig = _transformConfig(config);
    return DeepSeekProvider(deepseekConfig);
  }

  @override
  bool validateConfig(LLMConfig config) {
    // DeepSeek requires an API key
    return config.apiKey != null && config.apiKey!.isNotEmpty;
  }

  @override
  LLMConfig getDefaultConfig() {
    return LLMConfig(
      baseUrl: 'https://api.deepseek.com/v1/',
      model: 'deepseek-chat',
    );
  }

  /// Transform unified config to DeepSeek-specific config
  DeepSeekConfig _transformConfig(LLMConfig config) {
    return DeepSeekConfig(
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
    );
  }
}
