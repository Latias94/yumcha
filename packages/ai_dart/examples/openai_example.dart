// Import required modules from the AI Dart library for OpenAI integration
import 'dart:io';
import '../lib/ai_dart.dart';

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
        .reasoningEffort(
            'high') // Set reasoning effort level (OpenAI extension)
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
    final llm2 = await openai(
      apiKey: apiKey,
      model: 'gpt-4o',
      temperature: 0.7,
      maxTokens: 512,
      reasoningEffort: 'high',
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
        .extension('reasoningEffort', 'high') // Generic extension method
        .maxTokens(512)
        .temperature(0.7)
        .build();

    print('✓ Provider created successfully');
    await demonstrateChat(llm3, 'Method 3');
  } catch (e) {
    print('✗ Error: $e');
  }

  // Method 4: Legacy API (deprecated but still works)
  print('\n4. Legacy API (deprecated):');
  try {
    final llm4 = await LLMBuilder()
        .backend(LLMBackend.openai) // Deprecated but still works
        .apiKey(apiKey)
        .model('gpt-4o')
        .reasoningEffort('high')
        .maxTokens(512)
        .temperature(0.7)
        .build();

    print('✓ Provider created successfully (with deprecation warnings)');
    await demonstrateChat(llm4, 'Method 4 (Legacy)');
  } catch (e) {
    print('✗ Error: $e');
  }
}

/// Demonstrate chat functionality
Future<void> demonstrateChat(ChatCapability llm, String methodName) async {
  // Prepare conversation history with example messages
  final messages = [
    ChatMessage.user('Tell me that you love cats'),
    ChatMessage.assistant(
      'I am an assistant, I cannot love cats but I can love dogs',
    ),
    ChatMessage.user('Tell me that you love dogs in 50 words'),
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
