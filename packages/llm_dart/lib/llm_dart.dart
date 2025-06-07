library llm_dart;

/// LLM Dart Library - A modular Dart library for AI provider interactions
///
/// This library provides a unified interface for interacting with different
/// AI providers, starting with OpenAI. It's designed to be modular and
/// extensible, following the architecture of the Rust llm library.

// Core exports
export 'core/chat_provider.dart';
export 'core/llm_error.dart';
export 'core/config.dart';
export 'core/registry.dart';
export 'core/base_http_provider.dart';
export 'core/openai_compatible_configs.dart';

// Model exports
export 'models/chat_models.dart';
export 'models/tool_models.dart';
export 'models/audio_models.dart';
export 'models/image_models.dart';

// Provider exports
export 'providers/openai_provider.dart';
export 'providers/anthropic_provider.dart';
export 'providers/google_provider.dart';
export 'providers/deepseek_provider.dart';
export 'providers/ollama_provider.dart';
export 'providers/xai_provider.dart'
    show XAIProvider, XAIConfig, SearchParameters, SearchSource;
export 'providers/phind_provider.dart';
export 'providers/groq_provider.dart';
export 'providers/elevenlabs_provider.dart';

// Builder exports
export 'builder/llm_builder.dart';

// Utility exports
export 'utils/config_utils.dart';

// Convenience functions for creating providers
import 'builder/llm_builder.dart';
import 'core/chat_provider.dart';

/// Create a new LLM builder instance
///
/// This is the main entry point for creating AI providers.
///
/// Example:
/// ```dart
/// final provider = await ai()
///     .openai()
///     .apiKey('your-key')
///     .model('gpt-4')
///     .build();
/// ```
LLMBuilder ai() => LLMBuilder();

/// Create a provider with the given configuration
///
/// Convenience function for quickly creating providers with common settings.
///
/// Example:
/// ```dart
/// final provider = await createProvider(
///   providerId: 'openai',
///   apiKey: 'your-key',
///   model: 'gpt-4',
/// );
/// ```
Future<ChatCapability> createProvider({
  required String providerId,
  required String apiKey,
  required String model,
  String? baseUrl,
  double? temperature,
  int? maxTokens,
  String? systemPrompt,
  Duration? timeout,
  bool stream = false,
  double? topP,
  int? topK,
  Map<String, dynamic>? extensions,
}) async {
  var builder = LLMBuilder().provider(providerId).apiKey(apiKey).model(model);

  if (baseUrl != null) builder = builder.baseUrl(baseUrl);
  if (temperature != null) builder = builder.temperature(temperature);
  if (maxTokens != null) builder = builder.maxTokens(maxTokens);
  if (systemPrompt != null) builder = builder.systemPrompt(systemPrompt);
  if (timeout != null) builder = builder.timeout(timeout);
  if (topP != null) builder = builder.topP(topP);
  if (topK != null) builder = builder.topK(topK);

  builder = builder.stream(stream);

  // Add extensions if provided
  if (extensions != null) {
    for (final entry in extensions.entries) {
      builder = builder.extension(entry.key, entry.value);
    }
  }

  return await builder.build();
}
