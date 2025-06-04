/// Simple example demonstrating the unified LLMBuilder interface
///
/// This example shows how to use the LLMBuilder similar to the Rust llm crate:
/// - Create providers using the unified builder pattern
/// - Switch between different backends easily
/// - Use the same interface regardless of provider

import 'dart:io';
import '../builder/llm_builder.dart';
import '../models/chat_models.dart';
import '../core/chat_provider.dart';

void main() async {
  try {
    // Example 1: Create OpenAI provider using LLMBuilder
    final openaiProvider = await LLMBuilder()
        .backend(LLMBackend.openai)
        .apiKey(Platform.environment['OPENAI_API_KEY'] ?? 'sk-test')
        .model('gpt-4o')
        .temperature(0.7)
        .maxTokens(100)
        .build();

    // Example 2: Create DeepSeek provider using LLMBuilder
    final deepseekProvider = await LLMBuilder()
        .backend(LLMBackend.deepseek)
        .apiKey(Platform.environment['DEEPSEEK_API_KEY'] ?? 'sk-test')
        .model('deepseek-chat')
        .temperature(0.7)
        .maxTokens(100)
        .build();

    // Example 3: Create Ollama provider (no API key needed)
    final ollamaProvider = await LLMBuilder()
        .backend(LLMBackend.ollama)
        .baseUrl('http://localhost:11434')
        .model('llama3.1')
        .temperature(0.7)
        .maxTokens(100)
        .build();

    // Test message
    final messages = [ChatMessage.user('What is the capital of France?')];

    // All providers use the same interface!
    final providers = {
      'OpenAI': openaiProvider,
      'DeepSeek': deepseekProvider,
      'Ollama': ollamaProvider,
    };

    for (final entry in providers.entries) {
      final name = entry.key;
      final provider = entry.value;

      try {
        final response = await provider.chat(messages);
        print('$name: ${response.text}');
      } catch (e) {
        print('$name Error: $e');
      }
    }

    print('\n✅ LLMBuilder example completed!');
  } catch (e) {
    print('❌ Error: $e');
  }
}

/// Example showing how to create a factory function
Future<ChatProvider> createProvider(String backend, String apiKey) async {
  switch (backend.toLowerCase()) {
    case 'openai':
      return LLMBuilder()
          .backend(LLMBackend.openai)
          .apiKey(apiKey)
          .model('gpt-4o')
          .build();

    case 'deepseek':
      return LLMBuilder()
          .backend(LLMBackend.deepseek)
          .apiKey(apiKey)
          .model('deepseek-chat')
          .build();

    case 'anthropic':
      return LLMBuilder()
          .backend(LLMBackend.anthropic)
          .apiKey(apiKey)
          .model('claude-3-5-sonnet-20241022')
          .build();

    default:
      throw ArgumentError('Unsupported backend: $backend');
  }
}

/// Example showing configuration reuse
void configurationExample() async {
  // Base configuration
  final baseBuilder = LLMBuilder()
      .temperature(0.7)
      .maxTokens(500)
      .systemPrompt('You are a helpful assistant.');

  // Create different providers with same base config
  final openaiProvider = await baseBuilder
      .backend(LLMBackend.openai)
      .apiKey('sk-openai-key')
      .model('gpt-4o')
      .build();

  final deepseekProvider = await baseBuilder
      .backend(LLMBackend.deepseek)
      .apiKey('sk-deepseek-key')
      .model('deepseek-chat')
      .build();

  // Both providers now have the same temperature, maxTokens, and systemPrompt
  print('Providers created with shared configuration');
}
