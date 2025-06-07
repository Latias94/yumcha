// Import required modules from the LLM Dart library for Groq integration
import 'dart:io';
import 'package:llm_dart/llm_dart.dart';

/// Example demonstrating how to use the Groq provider with LLMBuilder
void main() async {
  // Get Groq API key from environment variable or use test key as fallback
  final apiKey = Platform.environment['GROQ_API_KEY'] ?? 'gsk-TESTKEY';

  // Initialize and configure the LLM client using LLMBuilder
  final llm = await LLMBuilder()
      .groq() // Use Groq as the LLM provider
      .apiKey(apiKey) // Set the API key
      .model(
        'deepseek-r1-distill-llama-70b',
      ) // Use deepseek-r1-distill-llama-70b model
      .maxTokens(512) // Limit response length
      .temperature(0.7) // Control response randomness (0.0-1.0)
      .stream(false) // Disable streaming responses
      .build();

  // Prepare conversation history with example messages
  final messages = [
    ChatMessage.user('Tell me about quantum computing'),
    ChatMessage.assistant(
      'Quantum computing is a type of computing that uses quantum phenomena...',
    ),
    ChatMessage.user('What are qubits?'),
  ];

  try {
    // Send chat request and handle the response
    final response = await llm.chat(messages);
    print('Chat response:\n${response.text}');
  } catch (e) {
    print('Chat error: $e');
  }
}
