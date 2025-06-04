// Import required modules from the AI Dart library for DeepSeek integration
import 'dart:io';
import '../builder/llm_builder.dart';
import '../models/chat_models.dart';

/// Example demonstrating how to use the DeepSeek provider with LLMBuilder
void main() async {
  // Get DeepSeek API key from environment variable or use test key as fallback
  final apiKey = Platform.environment['DEEPSEEK_API_KEY'] ?? 'sk-TESTKEY';

  // Initialize and configure the LLM client using LLMBuilder
  final llm = await LLMBuilder()
      .backend(LLMBackend.deepseek) // Use DeepSeek as the LLM provider
      .apiKey(apiKey) // Set the API key
      .model('deepseek-reasoner') // Use DeepSeek Chat model
      .temperature(0.7) // Control response randomness (0.0-1.0)
      .timeout(const Duration(seconds: 1200)) // Set timeout
      .stream(false) // Disable streaming responses
      .systemPrompt(
        'You are a helpful assistant and you response only with words begin with deepseek_',
      )
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
    print('Chat response:\n${response.text}');
  } catch (e) {
    print('Chat error: $e');
  }
}
