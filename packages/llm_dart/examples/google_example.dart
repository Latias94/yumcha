// Import required modules from the LLM Dart library for Google Gemini integration
import 'dart:io';
import 'package:llm_dart/llm_dart.dart';

/// Example demonstrating how to use the Google provider with LLMBuilder
void main() async {
  // Get Google API key from environment variable or use test key as fallback
  final apiKey = Platform.environment['GOOGLE_API_KEY'] ?? 'google-key';

  // Initialize and configure the LLM client using LLMBuilder
  final llm = await LLMBuilder()
      .google() // Use Google as the LLM provider
      .apiKey(apiKey) // Set the API key
      .model('gemini-2.0-flash-exp') // Use Gemini Pro model
      .maxTokens(8512) // Limit response length
      .temperature(0.7) // Control response randomness (0.0-1.0)
      .stream(false) // Disable streaming responses
      // Optional: Set system prompt
      .systemPrompt(
        'You are a helpful AI assistant specialized in programming.',
      )
      .build();

  // Prepare conversation history with example messages
  final messages = [
    ChatMessage.user('Explain the concept of async/await in Rust'),
    ChatMessage.assistant(
      'Async/await in Rust is a way to write asynchronous code...',
    ),
    ChatMessage.user('Can you show me a simple example?'),
  ];

  try {
    // Send chat request and handle the response
    final response = await llm.chat(messages);
    print('Google Gemini response:\n${response.text}');
  } catch (e) {
    print('Chat error: $e');
  }
}
