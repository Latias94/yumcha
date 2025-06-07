// ignore_for_file: avoid_print
// Import required modules from the LLM Dart library for xAI integration
import 'dart:io';
import 'package:llm_dart/llm_dart.dart';

/// Example demonstrating how to use the xAI provider with LLMBuilder
void main() async {
  // Get xAI API key from environment variable or use test key as fallback
  final apiKey = Platform.environment['XAI_API_KEY'] ?? 'sk-TESTKEY';

  // Initialize and configure the LLM client using modern API
  final llm = await ai()
      .xai() // Use xAI as the LLM provider
      .apiKey(apiKey) // Set the API key
      .model('grok-3-mini-beta') // Use Grok-3 mini beta model
      .maxTokens(512) // Limit response length
      .temperature(0.7) // Control response randomness (0.0-1.0)
      .stream(false) // Disable streaming responses
      .build();

  // Prepare conversation history with example messages
  final messages = [
    ChatMessage.user('Tell me that you love cats'),
    ChatMessage.assistant(
      'I am an assistant, I cannot love cats but I can love dogs',
    ),
    ChatMessage.user('Tell me that you love dogs in 2000 chars'),
  ];

  try {
    // Send chat request and handle the response
    final response = await llm.chat(messages);
    // print('Chat thinking:\n${response.thinking}');
    print('Chat response:\n${response.text}');
  } catch (e) {
    print('Chat error: $e');
  }
}
