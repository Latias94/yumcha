import '../../core/chat_provider.dart';
import '../../core/config.dart';
import '../../core/registry.dart';
import '../../core/openai_compatible_configs.dart';
import '../../models/tool_models.dart';
import '../openai_provider.dart';

/// Generic factory for creating OpenAI-compatible provider instances
/// 
/// This factory can create providers for any service that offers an OpenAI-compatible API,
/// using pre-configured settings for popular providers like DeepSeek, Gemini, xAI, etc.
class OpenAICompatibleProviderFactory implements LLMProviderFactory<ChatCapability> {
  final OpenAICompatibleProviderConfig _config;

  OpenAICompatibleProviderFactory(this._config);

  @override
  String get providerId => _config.providerId;

  @override
  String get displayName => _config.displayName;

  @override
  String get description => _config.description;

  @override
  Set<LLMCapability> get supportedCapabilities => _config.supportedCapabilities;

  @override
  ChatCapability create(LLMConfig config) {
    final openaiConfig = _transformConfig(config);
    return OpenAIProvider(openaiConfig);
  }

  @override
  bool validateConfig(LLMConfig config) {
    // Most OpenAI-compatible providers require an API key
    return config.apiKey != null && config.apiKey!.isNotEmpty;
  }

  @override
  LLMConfig getDefaultConfig() {
    return LLMConfig(
      baseUrl: _config.defaultBaseUrl,
      model: _config.defaultModel,
    );
  }

  /// Transform unified config to OpenAI-compatible config
  OpenAIConfig _transformConfig(LLMConfig config) {
    // Get model-specific capabilities
    final modelConfig = _config.modelConfigs[config.model];
    
    // Build the OpenAI config with provider-specific optimizations
    return OpenAIConfig(
      apiKey: config.apiKey!,
      baseUrl: config.baseUrl,
      model: config.model,
      maxTokens: _getOptimizedMaxTokens(config, modelConfig),
      temperature: _getOptimizedTemperature(config, modelConfig),
      systemPrompt: config.systemPrompt,
      timeout: config.timeout,
      stream: config.stream,
      topP: _getOptimizedTopP(config, modelConfig),
      topK: config.topK,
      tools: config.tools,
      toolChoice: config.toolChoice,
      // OpenAI-specific extensions
      reasoningEffort: _getReasoningEffort(config),
      jsonSchema: config.getExtension<StructuredOutputFormat>('jsonSchema'),
      voice: config.getExtension<String>('voice'),
      embeddingEncodingFormat: config.getExtension<String>('embeddingEncodingFormat'),
      embeddingDimensions: config.getExtension<int>('embeddingDimensions'),
    );
  }

  /// Get optimized max tokens based on model capabilities
  int? _getOptimizedMaxTokens(LLMConfig config, ModelCapabilityConfig? modelConfig) {
    if (config.maxTokens != null) {
      return config.maxTokens;
    }
    
    // Use model's max context length as a reasonable default
    if (modelConfig?.maxContextLength != null) {
      // Reserve some tokens for the prompt
      return (modelConfig!.maxContextLength! * 0.8).round();
    }
    
    return null;
  }

  /// Get optimized temperature based on model capabilities
  double? _getOptimizedTemperature(LLMConfig config, ModelCapabilityConfig? modelConfig) {
    // Some reasoning models should have temperature disabled
    if (modelConfig?.disableTemperature == true) {
      return null;
    }
    
    return config.temperature;
  }

  /// Get optimized top_p based on model capabilities
  double? _getOptimizedTopP(LLMConfig config, ModelCapabilityConfig? modelConfig) {
    // Some reasoning models should have top_p disabled
    if (modelConfig?.disableTopP == true) {
      return null;
    }
    
    return config.topP;
  }

  /// Get reasoning effort parameter if supported
  String? _getReasoningEffort(LLMConfig config) {
    if (!_config.supportsReasoningEffort) {
      return null;
    }
    
    return config.getExtension<String>('reasoningEffort');
  }

  /// Create factory instances for all pre-configured providers
  static List<OpenAICompatibleProviderFactory> createAllFactories() {
    return OpenAICompatibleConfigs.getAllConfigs()
        .map((config) => OpenAICompatibleProviderFactory(config))
        .toList();
  }

  /// Create a specific factory by provider ID
  static OpenAICompatibleProviderFactory? createFactory(String providerId) {
    final config = OpenAICompatibleConfigs.getConfig(providerId);
    if (config == null) return null;
    
    return OpenAICompatibleProviderFactory(config);
  }
}

/// Helper class for registering OpenAI-compatible providers
class OpenAICompatibleProviderRegistrar {
  /// Register all pre-configured OpenAI-compatible providers
  static void registerAll() {
    final factories = OpenAICompatibleProviderFactory.createAllFactories();
    
    for (final factory in factories) {
      LLMProviderRegistry.registerOrReplace(factory);
    }
  }

  /// Register a specific OpenAI-compatible provider
  static bool registerProvider(String providerId) {
    final factory = OpenAICompatibleProviderFactory.createFactory(providerId);
    if (factory == null) return false;
    
    LLMProviderRegistry.registerOrReplace(factory);
    return true;
  }

  /// Get list of available OpenAI-compatible provider IDs
  static List<String> getAvailableProviders() {
    return OpenAICompatibleConfigs.getAllConfigs()
        .map((config) => config.providerId)
        .toList();
  }
}
