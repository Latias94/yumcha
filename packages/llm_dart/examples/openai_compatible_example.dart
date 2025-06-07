// ignore_for_file: avoid_print

import 'dart:io';
import 'package:llm_dart/llm_dart.dart';

/// Example showing how to use OpenAI-compatible providers
///
/// This example demonstrates the user-friendly way to use providers that
/// offer OpenAI-compatible APIs without manual configuration.
void main() async {
  print('=== OpenAI Compatible Providers Example ===\n');

  // Example 1: Using DeepSeek with OpenAI-compatible interface
  await deepSeekOpenAIExample();

  // Example 2: Using Google Gemini with OpenAI-compatible interface
  await geminiOpenAIExample();

  // Example 3: Using xAI Grok with OpenAI-compatible interface
  await xaiOpenAIExample();

  // Example 4: Comparing native vs OpenAI-compatible interfaces
  await comparisonExample();

  // Example 5: Advanced features with OpenAI-compatible providers
  await advancedFeaturesExample();
}

/// Example using DeepSeek with OpenAI-compatible interface
Future<void> deepSeekOpenAIExample() async {
  print('1. DeepSeek with OpenAI-compatible interface');

  try {
    // Easy way: Use the OpenAI-compatible interface
    final provider = await ai()
        .deepseekOpenAI() // use OpenAI compatible interface
        .apiKey(Platform.environment['DEEPSEEK_API_KEY'] ?? 'sk-test')
        .model('deepseek-chat')
        .temperature(0.7)
        .build();

    final messages = [ChatMessage.user('What is the capital of France?')];
    final response = await provider.chat(messages);

    print('  Response: ${response.text}');
    print('  ✓ DeepSeek OpenAI-compatible interface works!\n');
  } catch (e) {
    print('  ✗ Error: $e\n');
  }
}

/// Example using Google Gemini with OpenAI-compatible interface
Future<void> geminiOpenAIExample() async {
  print('2. Google Gemini with OpenAI-compatible interface');

  try {
    // Easy way: Use the OpenAI-compatible interface with reasoning
    final provider = await ai()
        .googleOpenAI() // use OpenAI compatible interface
        .apiKey(Platform.environment['GEMINI_API_KEY'] ?? 'test-key')
        .model('gemini-2.5-flash-preview-05-20')
        .reasoningEffort(ReasoningEffort.low) // support reasoning effort level
        .temperature(0.7)
        .build();

    final messages = [ChatMessage.user('Solve this math problem: 2x + 5 = 13')];
    final response = await provider.chat(messages);

    print('  Response: ${response.text}');
    if (response.thinking != null) {
      print('  Thinking: ${response.thinking}');
    }
    print('  ✓ Gemini OpenAI-compatible interface with reasoning works!\n');
  } catch (e) {
    print('  ✗ Error: $e\n');
  }
}

/// Example using xAI Grok with OpenAI-compatible interface
Future<void> xaiOpenAIExample() async {
  print('3. xAI Grok with OpenAI-compatible interface');

  try {
    // Easy way: Use the OpenAI-compatible interface
    final provider = await ai()
        .xaiOpenAI() // use OpenAI compatible interface
        .apiKey(Platform.environment['XAI_API_KEY'] ?? 'xai-test')
        .model('grok-2-latest')
        .temperature(0.8)
        .build();

    final messages = [ChatMessage.user('Tell me a joke about AI')];
    final response = await provider.chat(messages);

    print('  Response: ${response.text}');
    print('  ✓ xAI OpenAI-compatible interface works!\n');
  } catch (e) {
    print('  ✗ Error: $e\n');
  }
}

/// Compare native vs OpenAI-compatible interfaces
Future<void> comparisonExample() async {
  print('4. Comparison: Native vs OpenAI-compatible interfaces');

  try {
    // Native DeepSeek interface
    final nativeProvider = await ai()
        .deepseek() // native interface
        .apiKey(Platform.environment['DEEPSEEK_API_KEY'] ?? 'sk-test')
        .model('deepseek-chat')
        .build();

    // OpenAI-compatible DeepSeek interface
    final compatibleProvider = await ai()
        .deepseekOpenAI() // OpenAI compatible interface
        .apiKey(Platform.environment['DEEPSEEK_API_KEY'] ?? 'sk-test')
        .model('deepseek-chat')
        .build();

    final messages = [ChatMessage.user('Hello, world!')];

    final nativeResponse = await nativeProvider.chat(messages);
    final compatibleResponse = await compatibleProvider.chat(messages);

    print('  Native interface response: ${nativeResponse.text}');
    print('  Compatible interface response: ${compatibleResponse.text}');
    print('  ✓ Both interfaces work similarly!\n');
  } catch (e) {
    print('  ✗ Error: $e\n');
  }
}

/// Advanced features with OpenAI-compatible providers
Future<void> advancedFeaturesExample() async {
  print('5. Advanced features with OpenAI-compatible providers');

  try {
    // Using structured output with Gemini
    final provider = await ai()
        .googleOpenAI()
        .apiKey(Platform.environment['GEMINI_API_KEY'] ?? 'test-key')
        .model('gemini-2.0-flash')
        .jsonSchema(StructuredOutputFormat(
          name: 'person_info',
          description: 'Extract person information',
          schema: {
            'type': 'object',
            'properties': {
              'name': {'type': 'string'},
              'age': {'type': 'integer'},
              'city': {'type': 'string'},
            },
            'required': ['name'],
          },
        ))
        .build();

    final messages = [
      ChatMessage.user('Extract info: John is 25 years old and lives in Paris')
    ];

    final response = await provider.chat(messages);
    print('  Structured response: ${response.text}');
    print('  ✓ Structured output with OpenAI-compatible interface works!\n');
  } catch (e) {
    print('  ✗ Error: $e\n');
  }
}

/// Helper function to demonstrate provider capabilities
void demonstrateProviderCapabilities() {
  print('=== Available OpenAI-Compatible Providers ===\n');

  final providers = [
    'deepseek-openai',
    'google-openai',
    'xai-openai',
    'groq-openai',
    'phind-openai',
  ];

  for (final providerId in providers) {
    final factory = LLMProviderRegistry.getFactory(providerId);
    if (factory != null) {
      print('Provider: ${factory.displayName}');
      print('  ID: ${factory.providerId}');
      print('  Description: ${factory.description}');
      print('  Capabilities: ${factory.supportedCapabilities}');
      print('  Default config: ${factory.getDefaultConfig()}');
      print('');
    }
  }
}

/// Example showing how to check provider capabilities
void capabilityCheckExample() {
  print('=== Capability Check Example ===\n');

  // Check which OpenAI-compatible providers support reasoning
  final reasoningProviders = <String>[];
  final providers = ['deepseek-openai', 'google-openai', 'xai-openai'];

  for (final providerId in providers) {
    if (providerId.supports(LLMCapability.reasoning)) {
      reasoningProviders.add(providerId);
    }
  }

  print('Providers supporting reasoning: $reasoningProviders');

  // Check which providers support embedding
  final embeddingProviders = <String>[];
  for (final providerId in providers) {
    if (providerId.supports(LLMCapability.embedding)) {
      embeddingProviders.add(providerId);
    }
  }

  print('Providers supporting embedding: $embeddingProviders');
}

/// Extension to make capability checking easier (from capability_query_example.dart)
extension ProviderCapabilityExtensions on String {
  bool supports(LLMCapability capability) {
    final factory = LLMProviderRegistry.getFactory(this);
    return factory?.supportedCapabilities.contains(capability) ?? false;
  }
}
