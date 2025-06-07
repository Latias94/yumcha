import 'dart:io';
import 'package:llm_dart/llm_dart.dart';

/// Example demonstrating how to list available models from different providers
void main() async {
  await modelsExample();
}

/// Demonstrates listing models from OpenAI and Ollama providers
Future<void> modelsExample() async {
  // Get API keys from environment variables with fallback test values
  final openaiApiKey = Platform.environment['OPENAI_API_KEY'] ?? 'test_key';
  final ollamaBaseUrl =
      Platform.environment['OLLAMA_BASE_URL'] ?? 'http://localhost:11434';

  print('=== AI Models Listing Example ===\n');

  // Test OpenAI models
  await testOpenAIModels(openaiApiKey);

  print('\n' + '=' * 50 + '\n');

  // Test Ollama models
  await testOllamaModels(ollamaBaseUrl);
}

/// Test listing OpenAI models
Future<void> testOpenAIModels(String apiKey) async {
  print('🤖 OpenAI Models:');

  try {
    // Create OpenAI provider
    final llm = await LLMBuilder()
        .openai()
        .apiKey(apiKey)
        .model('gpt-3.5-turbo') // Default model
        .build();

    // Check if provider supports model listing
    if (llm is ModelListingCapability) {
      final modelProvider = llm as ModelListingCapability;
      final models = await modelProvider.models();

      if (models.isEmpty) {
        print('No models found. This could be due to:');
        print('  • Invalid API key');
        print('  • Network connectivity issues');
        print('  • API service unavailable');
        return;
      }

      print('Found ${models.length} models:\n');

      // Display models in a formatted way
      for (final model in models) {
        print('  • ${model.id}');
        if (model.description != null && model.description!.isNotEmpty) {
          print('    Description: ${model.description}');
        }
        if (model.ownedBy != null && model.ownedBy!.isNotEmpty) {
          print('    Owner: ${model.ownedBy}');
        }
        print('');
      }

      // Show some interesting statistics
      final gptModels = models.where((m) => m.id.contains('gpt')).length;
      final o1Models = models.where((m) => m.id.contains('o1')).length;
      final dalleModels = models.where((m) => m.id.contains('dall-e')).length;

      print('Model Statistics:');
      print('  • GPT models: $gptModels');
      print('  • O1 reasoning models: $o1Models');
      print('  • DALL-E image models: $dalleModels');
    } else {
      print('Provider does not support model listing');
    }
  } catch (e) {
    print('Error listing OpenAI models: $e');
  }
}

/// Test listing Ollama models
Future<void> testOllamaModels(String baseUrl) async {
  print('🦙 Ollama Models:');

  try {
    // Create Ollama provider
    final llm = await LLMBuilder()
        .ollama()
        .baseUrl(baseUrl)
        .model('llama2') // Default model
        .build();

    // Check if provider supports model listing
    if (llm is ModelListingCapability) {
      final modelProvider = llm as ModelListingCapability;
      final models = await modelProvider.models();

      if (models.isEmpty) {
        print(
          'No models found. Make sure Ollama is running and has models installed.',
        );
        print('Install models with: ollama pull llama2');
        return;
      }

      print('Found ${models.length} models:\n');

      // Display models in a formatted way
      for (final model in models) {
        print('  • ${model.id}');
        if (model.description != null && model.description!.isNotEmpty) {
          print('    Family: ${model.description}');
        }
        print('');
      }

      // Show model families
      final families = models
          .where((m) => m.description != null)
          .map((m) => m.description!)
          .toSet()
          .toList();

      if (families.isNotEmpty) {
        print('Model Families:');
        for (final family in families) {
          final count = models.where((m) => m.description == family).length;
          print('  • $family: $count models');
        }
      }
    } else {
      print('Provider does not support model listing');
    }
  } catch (e) {
    print('Error listing Ollama models: $e');
    print('Make sure Ollama is running at $baseUrl');
  }
}
