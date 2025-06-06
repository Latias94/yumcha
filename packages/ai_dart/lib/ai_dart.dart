/// AI Dart Library - A modular Dart library for AI provider interactions
///
/// This library provides a unified interface for interacting with different
/// AI providers, starting with OpenAI. It's designed to be modular and
/// extensible, following the architecture of the Rust llm library.
library ai_dart;

// Core exports
export 'core/chat_provider.dart';
export 'core/llm_error.dart';
export 'core/config.dart';
export 'core/registry.dart';

// Model exports
export 'models/chat_models.dart';
export 'models/tool_models.dart';

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

/// Create an OpenAI provider with the given API key
///
/// Convenience function for quickly creating OpenAI providers.
///
/// Example:
/// ```dart
/// final provider = await openai(
///   apiKey: 'your-key',
///   model: 'gpt-4',
/// );
/// ```
Future<ChatCapability> openai({
  required String apiKey,
  String model = 'gpt-3.5-turbo',
  String baseUrl = 'https://api.openai.com/v1/',
  double? temperature,
  int? maxTokens,
  String? systemPrompt,
  Duration? timeout,
  bool stream = false,
  double? topP,
  int? topK,
  String? reasoningEffort,
}) async {
  return await LLMBuilder()
      .openai()
      .apiKey(apiKey)
      .model(model)
      .baseUrl(baseUrl)
      .temperature(temperature ?? 0.7)
      .maxTokens(maxTokens ?? 1000)
      .systemPrompt(systemPrompt ?? '')
      .timeout(timeout ?? const Duration(seconds: 30))
      .stream(stream)
      .topP(topP ?? 1.0)
      .topK(topK ?? 50)
      .reasoningEffort(reasoningEffort ?? 'medium')
      .build();
}

/// Create an Anthropic provider with the given API key
///
/// Convenience function for quickly creating Anthropic providers.
///
/// Example:
/// ```dart
/// final provider = await anthropic(
///   apiKey: 'your-key',
///   model: 'claude-3-5-sonnet-20241022',
/// );
/// ```
Future<ChatCapability> anthropic({
  required String apiKey,
  String model = 'claude-3-5-sonnet-20241022',
  String baseUrl = 'https://api.anthropic.com/v1/',
  double? temperature,
  int? maxTokens,
  String? systemPrompt,
  Duration? timeout,
  bool stream = false,
  double? topP,
  int? topK,
}) async {
  return await LLMBuilder()
      .anthropic()
      .apiKey(apiKey)
      .model(model)
      .baseUrl(baseUrl)
      .temperature(temperature ?? 0.7)
      .maxTokens(maxTokens ?? 1000)
      .systemPrompt(systemPrompt ?? '')
      .timeout(timeout ?? const Duration(seconds: 30))
      .stream(stream)
      .topP(topP ?? 1.0)
      .topK(topK ?? 50)
      .build();
}
