/// Simple example demonstrating the unified LLMBuilder interface
///
/// This example shows how to use the LLMBuilder similar to the Rust llm crate:
/// - Create providers using the unified builder pattern
/// - Switch between different backends easily
/// - Use the same interface regardless of provider

import 'dart:io';
import 'package:llm_dart/llm_dart.dart';

void main() async {
  // ignore_for_file: avoid_print

  try {
    print('=== LLM Builder Example (Updated for New API) ===\n');

    // Example 1: Create OpenAI provider using new API
    print('1. Creating OpenAI provider with new API...');
    final openaiProvider = await ai()
        .openai()
        .apiKey(Platform.environment['OPENAI_API_KEY'] ?? 'sk-test')
        .model('gpt-4o')
        .temperature(0.7)
        .maxTokens(100)
        .build();

    // Example 2: Create DeepSeek provider using new API
    print('2. Creating DeepSeek provider with new API...');
    final deepseekProvider = await ai()
        .provider('deepseek')
        .apiKey(Platform.environment['DEEPSEEK_API_KEY'] ?? 'sk-test')
        .model('deepseek-chat')
        .temperature(0.7)
        .maxTokens(100)
        .build();

    // Example 3: Create Ollama provider using new API (no API key needed)
    print('3. Creating Ollama provider with new API...');
    final ollamaProvider = await ai()
        .provider('ollama')
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

    // Run configuration example
    configurationExample();
  } catch (e) {
    print('❌ Error: $e');
  }
}

/// Example showing how to create a factory function (Updated for new API)
Future<ChatCapability> createProvider(String backend, String apiKey) async {
  switch (backend.toLowerCase()) {
    case 'openai':
      // New API - recommended
      return ai().provider('openai').apiKey(apiKey).model('gpt-4o').build();

    case 'deepseek':
      // New API - recommended
      return ai()
          .provider('deepseek')
          .apiKey(apiKey)
          .model('deepseek-chat')
          .build();

    case 'anthropic':
      // New API - recommended
      return ai()
          .provider('anthropic')
          .apiKey(apiKey)
          .model('claude-3-5-sonnet-20241022')
          .build();

    default:
      throw ArgumentError('Unsupported backend: $backend');
  }
}

/// Example showing configuration reuse with new API
void configurationExample() async {
  print('\n=== Configuration Reuse Example ===');

  try {
    // Create different providers with same base config using new API
    final openaiProvider = await ai()
        .provider('openai')
        .apiKey('sk-openai-key')
        .model('gpt-4o')
        .temperature(0.7)
        .maxTokens(500)
        .systemPrompt('You are a helpful assistant.')
        .build();

    final deepseekProvider = await ai()
        .provider('deepseek')
        .apiKey('sk-deepseek-key')
        .model('deepseek-chat')
        .temperature(0.7)
        .maxTokens(500)
        .systemPrompt('You are a helpful assistant.')
        .build();

    print('✓ Providers created with shared configuration');
    print('  OpenAI provider: ${openaiProvider.runtimeType}');
    print('  DeepSeek provider: ${deepseekProvider.runtimeType}');
  } catch (e) {
    print('✗ Configuration example error: $e');
  }
}
