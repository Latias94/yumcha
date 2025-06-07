import '../core/chat_provider.dart';
import '../core/config.dart';
import '../core/registry.dart';
import '../core/llm_error.dart';
import '../models/tool_models.dart';
import '../models/chat_models.dart';

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

  /// Convenience methods for OpenAI-compatible providers
  /// These use the OpenAI interface but with provider-specific configurations
  LLMBuilder deepseekOpenAI() => provider('deepseek-openai');
  LLMBuilder googleOpenAI() => provider('google-openai');
  LLMBuilder xaiOpenAI() => provider('xai-openai');
  LLMBuilder groqOpenAI() => provider('groq-openai');
  LLMBuilder phindOpenAI() => provider('phind-openai');

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

  /// Sets the reasoning effort for models that support it (e.g., OpenAI o1, Gemini)
  /// Valid values: ReasoningEffort.low, ReasoningEffort.medium, ReasoningEffort.high, or null to disable
  LLMBuilder reasoningEffort(ReasoningEffort? effort) {
    _config = _config.withExtension('reasoningEffort', effort?.value);
    return this;
  }

  /// Sets structured output schema for JSON responses
  LLMBuilder jsonSchema(StructuredOutputFormat schema) {
    _config = _config.withExtension('jsonSchema', schema);
    return this;
  }

  /// Sets voice for text-to-speech (OpenAI providers) or voice ID (ElevenLabs)
  LLMBuilder voice(String voiceName) {
    _config = _config.withExtension('voice', voiceName);
    return this;
  }

  /// Sets voice ID for ElevenLabs TTS (alias for voice method)
  LLMBuilder voiceId(String voiceId) {
    _config = _config.withExtension('voiceId', voiceId);
    return this;
  }

  /// Sets stability parameter for ElevenLabs TTS (0.0-1.0)
  LLMBuilder stability(double stability) {
    _config = _config.withExtension('stability', stability);
    return this;
  }

  /// Sets similarity boost parameter for ElevenLabs TTS (0.0-1.0)
  LLMBuilder similarityBoost(double similarityBoost) {
    _config = _config.withExtension('similarityBoost', similarityBoost);
    return this;
  }

  /// Sets style parameter for ElevenLabs TTS (0.0-1.0)
  LLMBuilder style(double style) {
    _config = _config.withExtension('style', style);
    return this;
  }

  /// Enables or disables speaker boost for ElevenLabs TTS
  LLMBuilder useSpeakerBoost(bool enable) {
    _config = _config.withExtension('useSpeakerBoost', enable);
    return this;
  }

  /// Enables reasoning/thinking for supported providers (Anthropic, OpenAI o1)
  LLMBuilder reasoning(bool enable) {
    _config = _config.withExtension('reasoning', enable);
    return this;
  }

  /// Sets thinking budget tokens for Anthropic extended thinking
  LLMBuilder thinkingBudgetTokens(int tokens) {
    _config = _config.withExtension('thinkingBudgetTokens', tokens);
    return this;
  }

  /// Enables interleaved thinking for Anthropic (Claude 4 models only)
  LLMBuilder interleavedThinking(bool enable) {
    _config = _config.withExtension('interleavedThinking', enable);
    return this;
  }

  /// Sets provider-specific extension
  LLMBuilder extension(String key, dynamic value) {
    _config = _config.withExtension(key, value);
    return this;
  }

  /// Convenience methods for common extensions
  LLMBuilder embeddingEncodingFormat(String format) =>
      extension('embeddingEncodingFormat', format);
  LLMBuilder embeddingDimensions(int dimensions) =>
      extension('embeddingDimensions', dimensions);

  /// Image generation configuration methods
  LLMBuilder imageSize(String size) => extension('imageSize', size);
  LLMBuilder batchSize(int size) => extension('batchSize', size);
  LLMBuilder imageSeed(String seed) => extension('imageSeed', seed);
  LLMBuilder numInferenceSteps(int steps) =>
      extension('numInferenceSteps', steps);
  LLMBuilder guidanceScale(double scale) => extension('guidanceScale', scale);
  LLMBuilder promptEnhancement(bool enabled) =>
      extension('promptEnhancement', enabled);

  /// Audio configuration methods
  LLMBuilder audioFormat(String format) => extension('audioFormat', format);
  LLMBuilder audioQuality(String quality) => extension('audioQuality', quality);
  LLMBuilder sampleRate(int rate) => extension('sampleRate', rate);
  LLMBuilder languageCode(String code) => extension('languageCode', code);

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
