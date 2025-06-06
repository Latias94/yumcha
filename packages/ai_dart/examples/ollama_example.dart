// Import required modules from the AI Dart library for Ollama integration
import 'dart:io';
import '../lib/builder/llm_builder.dart';
import '../lib/models/chat_models.dart';

/// Example demonstrating how to use the Ollama provider with LLMBuilder
void main() async {
  // Get Ollama server URL from environment variable or use default localhost
  final baseUrl =
      Platform.environment['OLLAMA_URL'] ?? 'http://127.0.0.1:11434';

  // Initialize and configure the LLM client using LLMBuilder
  final llm = await LLMBuilder()
      .backend(LLMBackend.ollama) // Use Ollama as the LLM backend
      .baseUrl(baseUrl) // Set the Ollama server URL
      .model('llama3.2:latest')
      .maxTokens(1000) // Set maximum response length
      .temperature(0.7) // Control response randomness (0.0-1.0)
      .stream(false) // Disable streaming responses
      .build();

  // Prepare conversation history with example messages
  final messages = [
    ChatMessage.user('Hello, how do I run a local LLM in Rust?'),
    ChatMessage.assistant('One way is to use Ollama with a local model!'),
    ChatMessage.user('Tell me more about that'),
  ];

  try {
    // Send chat request and handle the response
    final response = await llm.chat(messages);
    print('Ollama chat response:\n${response.text}');
  } catch (e) {
    print('Chat error: $e');
  }
}
