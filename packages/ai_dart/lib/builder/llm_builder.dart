import '../core/chat_provider.dart';
import '../core/config.dart';
import '../core/registry.dart';
import '../core/llm_error.dart';
import '../models/tool_models.dart';

/// Supported LLM backend providers
///
/// @Deprecated - Use string provider IDs with LLMProviderRegistry instead
@Deprecated('Use string provider IDs with LLMProviderRegistry instead')
enum LLMBackend {
  /// OpenAI API provider (GPT-3, GPT-4, etc.)
  openai,

  /// Anthropic API provider (Claude models)
  anthropic,

  /// Ollama local LLM provider for self-hosted models
  ollama,

  /// DeepSeek API provider for their LLM models
  deepseek,

  /// X.AI (formerly Twitter) API provider
  xai,

  /// Phind API provider for code-specialized models
  phind,

  /// Google Gemini API provider
  google,

  /// Groq API provider
  groq,

  /// ElevenLabs API provider
  elevenlabs,
}

/// Extension to convert enum to string
extension LLMBackendExtension on LLMBackend {
  String get providerId {
    switch (this) {
      case LLMBackend.openai:
        return 'openai';
      case LLMBackend.anthropic:
        return 'anthropic';
      case LLMBackend.ollama:
        return 'ollama';
      case LLMBackend.deepseek:
        return 'deepseek';
      case LLMBackend.xai:
        return 'xai';
      case LLMBackend.phind:
        return 'phind';
      case LLMBackend.google:
        return 'google';
      case LLMBackend.groq:
        return 'groq';
      case LLMBackend.elevenlabs:
        return 'elevenlabs';
    }
  }
}

/// Builder for configuring and instantiating LLM providers
///
/// Provides a fluent interface similar to the Rust llm crate for setting
/// various configuration options like model selection, API keys, generation parameters, etc.
///
/// The new version uses the provider registry system for extensibility.
class LLMBuilder {
  /// Selected provider ID (replaces backend enum)
  String? _providerId;

  /// Unified configuration being built
  LLMConfig _config = LLMConfig(
    baseUrl: '',
    model: '',
  );

  /// Creates a new empty builder instance with default values
  LLMBuilder();

  /// Sets the provider to use (new registry-based approach)
  LLMBuilder provider(String providerId) {
    _providerId = providerId;

    // Get default config for this provider if it's registered
    final factory = LLMProviderRegistry.getFactory(providerId);
    if (factory != null) {
      _config = factory.getDefaultConfig();
    }

    return this;
  }

  /// Legacy method for backward compatibility
  @Deprecated('Use provider(String) instead')
  LLMBuilder backend(LLMBackend backend) {
    return provider(backend.providerId);
  }

  /// Convenience methods for built-in providers
  LLMBuilder openai() => provider('openai');
  LLMBuilder anthropic() => provider('anthropic');
  LLMBuilder google() => provider('google');
  LLMBuilder deepseek() => provider('deepseek');
  LLMBuilder ollama() => provider('ollama');
  LLMBuilder xai() => provider('xai');
  LLMBuilder phind() => provider('phind');
  LLMBuilder groq() => provider('groq');
  LLMBuilder elevenlabs() => provider('elevenlabs');

  /// Sets the API key for authentication
  LLMBuilder apiKey(String key) {
    _config = _config.copyWith(apiKey: key);
    return this;
  }

  /// Sets the base URL for API requests
  LLMBuilder baseUrl(String url) {
    // Ensure the URL ends with a slash
    final normalizedUrl = url.endsWith('/') ? url : '$url/';
    _config = _config.copyWith(baseUrl: normalizedUrl);
    return this;
  }

  /// Sets the model identifier to use
  LLMBuilder model(String model) {
    _config = _config.copyWith(model: model);
    return this;
  }

  /// Sets the maximum number of tokens to generate
  LLMBuilder maxTokens(int tokens) {
    _config = _config.copyWith(maxTokens: tokens);
    return this;
  }

  /// Sets the temperature for controlling response randomness (0.0-1.0)
  LLMBuilder temperature(double temp) {
    _config = _config.copyWith(temperature: temp);
    return this;
  }

  /// Sets the system prompt/context
  LLMBuilder systemPrompt(String prompt) {
    _config = _config.copyWith(systemPrompt: prompt);
    return this;
  }

  /// Sets the request timeout
  LLMBuilder timeout(Duration timeout) {
    _config = _config.copyWith(timeout: timeout);
    return this;
  }

  /// Enables or disables streaming responses
  LLMBuilder stream(bool enable) {
    _config = _config.copyWith(stream: enable);
    return this;
  }

  /// Sets the top-p (nucleus) sampling parameter
  LLMBuilder topP(double topP) {
    _config = _config.copyWith(topP: topP);
    return this;
  }

  /// Sets the top-k sampling parameter
  LLMBuilder topK(int topK) {
    _config = _config.copyWith(topK: topK);
    return this;
  }

  /// Sets the function tools
  LLMBuilder tools(List<Tool> tools) {
    _config = _config.copyWith(tools: tools);
    return this;
  }

  /// Sets the tool choice
  LLMBuilder toolChoice(ToolChoice choice) {
    _config = _config.copyWith(toolChoice: choice);
    return this;
  }

  /// Sets provider-specific extension
  LLMBuilder extension(String key, dynamic value) {
    _config = _config.withExtension(key, value);
    return this;
  }

  /// Convenience methods for common extensions
  LLMBuilder reasoningEffort(String effort) =>
      extension('reasoningEffort', effort);
  LLMBuilder jsonSchema(StructuredOutputFormat schema) =>
      extension('jsonSchema', schema);
  LLMBuilder voice(String voice) => extension('voice', voice);
  LLMBuilder embeddingEncodingFormat(String format) =>
      extension('embeddingEncodingFormat', format);
  LLMBuilder embeddingDimensions(int dimensions) =>
      extension('embeddingDimensions', dimensions);

  /// Builds and returns a configured LLM provider instance
  ///
  /// Returns a unified ChatCapability interface that can be used consistently
  /// across different LLM providers. The actual implementation will vary based
  /// on the selected provider.
  ///
  /// Note: Some providers may implement additional interfaces like EmbeddingCapability,
  /// ModelListingCapability, etc. Use dynamic casting to access these features.
  ///
  /// Throws [LLMError] if:
  /// - No provider is specified
  /// - Provider is not registered
  /// - Required configuration like API keys are missing
  Future<ChatCapability> build() async {
    if (_providerId == null) {
      throw const GenericError('No provider specified');
    }

    // Use the registry to create the provider
    return LLMProviderRegistry.createProvider(_providerId!, _config);
  }
}
