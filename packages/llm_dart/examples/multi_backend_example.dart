/// Example demonstrating how to use multiple LLM backends with unified interface
///
/// This example shows how to:
/// 1. Initialize multiple LLM backends (OpenAI, Anthropic, DeepSeek)
/// 2. Use the unified LLMBuilder interface similar to Rust llm crate
/// 3. Switch between providers seamlessly using the same interface
/// 4. Handle different provider capabilities consistently

import 'dart:io';
import 'package:llm_dart/llm_dart.dart';

void main() async {
  try {
    // Initialize OpenAI backend with API key and model settings
    final openaiLlm = await LLMBuilder()
        .openai()
        .apiKey(Platform.environment['OPENAI_API_KEY'] ?? 'sk-OPENAI')
        .model('gpt-4o')
        .temperature(0.7)
        .maxTokens(500)
        .build();

    // Initialize Anthropic backend with API key and model settings
    final anthropicLlm = await LLMBuilder()
        .anthropic()
        .apiKey(Platform.environment['ANTHROPIC_API_KEY'] ?? 'anthro-key')
        .model('claude-3-5-sonnet-20241022')
        .temperature(0.7)
        .maxTokens(500)
        .build();

    // Initialize DeepSeek backend with API key and model settings
    final deepseekLlm = await LLMBuilder()
        .deepseek()
        .apiKey(Platform.environment['DEEPSEEK_API_KEY'] ?? 'sk-TESTKEY')
        .model('deepseek-chat')
        .temperature(0.7)
        .maxTokens(500)
        .build();

    // Ollama backend (no API key required for local instance)
    final ollamaLlm = await LLMBuilder()
        .ollama()
        .baseUrl('http://localhost:11434')
        .model('mistral')
        .temperature(0.7)
        .maxTokens(500)
        .build();

    print('=== Multi-Backend LLM Example ===\n');

    // Test message
    final messages = [
      ChatMessage.user(
        'Explain the concept of recursion in programming in one paragraph.',
      ),
    ];

    // Test OpenAI
    print('🤖 OpenAI Response:');
    try {
      final openaiResponse = await openaiLlm.chat(messages);
      print('${openaiResponse.text}\n');
      print('Usage: ${openaiResponse.usage}\n');
    } catch (e) {
      print('OpenAI Error: $e\n');
    }

    // Test Anthropic
    print('🧠 Anthropic Response:');
    try {
      final anthropicResponse = await anthropicLlm.chat(messages);
      print('${anthropicResponse.text}\n');
      print('Usage: ${anthropicResponse.usage}\n');
    } catch (e) {
      print('Anthropic Error: $e\n');
    }

    // Test DeepSeek
    print('🔍 DeepSeek Response:');
    try {
      final deepseekResponse = await deepseekLlm.chat(messages);
      print('${deepseekResponse.text}\n');
      print('Usage: ${deepseekResponse.usage}\n');
    } catch (e) {
      print('DeepSeek Error: $e\n');
    }

    // Test Ollama (if available)
    print('🦙 Ollama Response:');
    try {
      final ollamaResponse = await ollamaLlm.chat(messages);
      print('${ollamaResponse.text}\n');
      print('Usage: ${ollamaResponse.usage}\n');
    } catch (e) {
      print('Ollama Error: $e\n');
    }

    // Note: Advanced features like streaming, embeddings, and completion
    // are available through the specific provider interfaces when needed

    print('🎉 Multi-backend example completed successfully!');
  } catch (e) {
    print('❌ Error: $e');
  }
}

/// Helper function to demonstrate provider registry pattern
class LLMRegistry {
  final Map<String, ChatCapability> _providers = {};

  /// Register a provider with a name
  void register(String name, ChatCapability provider) {
    _providers[name] = provider;
  }

  /// Get a provider by name
  ChatCapability? get(String name) => _providers[name];

  /// Get all registered provider names
  List<String> get names => _providers.keys.toList();

  /// Test all providers with the same message
  Future<Map<String, String>> testAll(List<ChatMessage> messages) async {
    final results = <String, String>{};

    for (final entry in _providers.entries) {
      try {
        final response = await entry.value.chat(messages);
        results[entry.key] = response.text ?? 'No response';
      } catch (e) {
        results[entry.key] = 'Error: $e';
      }
    }

    return results;
  }
}

/// Example of using the registry pattern
void registryExample() async {
  final registry = LLMRegistry();

  // Register multiple providers
  registry.register(
    'openai',
    await LLMBuilder().openai().apiKey('sk-test').model('gpt-4o').build(),
  );

  registry.register(
    'deepseek',
    await LLMBuilder()
        .deepseek()
        .apiKey('sk-test')
        .model('deepseek-chat')
        .build(),
  );

  // Test all providers
  final messages = [ChatMessage.user('Hello, world!')];
  final results = await registry.testAll(messages);

  print('Registry Results:');
  results.forEach((name, response) {
    print('$name: $response');
  });
}
