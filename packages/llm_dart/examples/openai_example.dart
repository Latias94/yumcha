// ignore_for_file: avoid_print
// Import required modules from the LLM Dart library for OpenAI integration
import 'dart:io';
import 'package:llm_dart/llm_dart.dart';

/// Example demonstrating how to use the OpenAI provider with the new API
void main() async {
  // Get OpenAI API key from environment variable or use test key as fallback
  final apiKey = Platform.environment['OPENAI_API_KEY'] ?? 'sk-OPENAI';

  print('=== OpenAI Provider Example ===\n');

  // Method 1: Using the new ai() builder (recommended)
  print('1. Using ai() builder:');
  try {
    final llm = await ai()
        .openai() // Use OpenAI provider
        .apiKey(apiKey) // Set the API key
        .model('gpt-4o') // Use GPT-4o model
        .reasoning(true) // Enable reasoning
        .reasoningEffort(ReasoningEffort.high) // Set reasoning effort level
        .maxTokens(512) // Limit response length
        .temperature(0.7) // Control response randomness (0.0-1.0)
        .stream(false) // Disable streaming responses
        .build();

    print('✓ Provider created successfully');
    await demonstrateChat(llm, 'Method 1');
  } catch (e) {
    print('✗ Error: $e');
  }

  // Method 2: Using convenience function
  print('\n2. Using convenience function:');
  try {
    final llm2 = await createProvider(
      providerId: 'openai',
      apiKey: apiKey,
      model: 'gpt-4o',
      temperature: 0.7,
      maxTokens: 512,
      extensions: {'reasoningEffort': 'high'},
    );

    print('✓ Provider created successfully');
    await demonstrateChat(llm2, 'Method 2');
  } catch (e) {
    print('✗ Error: $e');
  }

  // Method 3: Using provider() method (extensible approach)
  print('\n3. Using provider() method:');
  try {
    final llm3 = await ai()
        .provider('openai') // Generic provider method
        .apiKey(apiKey)
        .model('gpt-4o')
        .reasoning(true) // Enable reasoning
        .extension('reasoningEffort', 'high') // Generic extension method
        .maxTokens(512)
        .temperature(0.7)
        .build();

    print('✓ Provider created successfully');
    await demonstrateChat(llm3, 'Method 3');
  } catch (e) {
    print('✗ Error: $e');
  }

  // Method 4: Provider method API
  print('\n4. Provider method API:');
  try {
    final llm4 = await LLMBuilder()
        .provider('openai') // Use provider method
        .apiKey(apiKey)
        .model('gpt-4o')
        .reasoning(true) // Enable reasoning
        .reasoningEffort(ReasoningEffort.high)
        .maxTokens(512)
        .temperature(0.7)
        .build();

    print('✓ Provider created successfully');
    await demonstrateChat(llm4, 'Method 4 (Provider)');
  } catch (e) {
    print('✗ Error: $e');
  }
}

/// Demonstrate chat functionality
Future<void> demonstrateChat(ChatCapability llm, String methodName) async {
  // Prepare conversation history with clear, objective messages
  final messages = [
    ChatMessage.user('What is 2 + 2?'),
    ChatMessage.assistant('2 + 2 equals 4.'),
    ChatMessage.user('What about 3 + 5?'),
  ];

  try {
    // Send chat request and handle the response
    final response = await llm.chat(messages);
    print('[$methodName] Chat response:\n${response.text}\n');

    // Demonstrate capability checking
    if (llm is EmbeddingCapability) {
      print('[$methodName] ✓ Provider supports embeddings');
    }
    if (llm is ModelListingCapability) {
      print('[$methodName] ✓ Provider supports model listing');
    }
  } catch (e) {
    print('[$methodName] Chat error: $e');
  }
}
