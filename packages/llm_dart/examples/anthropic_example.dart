// Import required modules from the LLM Dart library for Anthropic integration
import 'dart:io';
import 'package:llm_dart/llm_dart.dart';

/// Example demonstrating how to use the Anthropic provider with LLMBuilder
void main() async {
  // Get Anthropic API key from environment variable or use test key as fallback
  final apiKey = Platform.environment['ANTHROPIC_API_KEY'] ?? 'anthro-key';

  // Initialize and configure the LLM client using LLMBuilder
  final llm = await LLMBuilder()
      .anthropic() // Use Anthropic (Claude) as the LLM provider
      .apiKey(apiKey) // Set the API key
      .model('claude-3-7-sonnet-20250219') // Use Claude Instant model
      .maxTokens(512) // Limit response length
      .temperature(0.7) // Control response randomness (0.0-1.0)
      // Uncomment to set system prompt:
      // .systemPrompt('You are a helpful assistant specialized in concurrency.')
      .build();

  // Prepare conversation history with a simple, clear question
  final messages = [
    ChatMessage.user('What are the primary colors?'),
  ];

  try {
    // Send chat request and handle the response
    final response = await llm.chat(messages);
    print('Anthropic chat response:\n${response.text}');
  } catch (e) {
    print('Chat error: $e');
  }
}
