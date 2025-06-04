// Import required modules from the AI Dart library for OpenAI integration
import 'dart:io';
import '../builder/llm_builder.dart';
import '../models/chat_models.dart';

/// Example demonstrating how to use the OpenAI provider with LLMBuilder
void main() async {
  // Get OpenAI API key from environment variable or use test key as fallback
  final apiKey =
      Platform.environment['OPENAI_API_KEY'] ??
      'sk-ngt7SAfEo154u80l8Yc7T7R8xAwCQE9yd9MhnEqxKCdjZxV9';

  // Initialize and configure the LLM client using LLMBuilder
  final llm = await LLMBuilder()
      .backend(LLMBackend.openai) // Use OpenAI as the LLM provider
      .apiKey(apiKey) // Set the API key
      .baseUrl('https://api.mnapi.com/v1/') // Custom base URL
      .model('deepseek-r1') // Use GPT-3.5 Turbo model
      .reasoningEffort('high') // Set reasoning effort level
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
    print('Chat response:\n${response.text}');
  } catch (e) {
    print('Chat error: $e');
  }
}
