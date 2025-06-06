// Import required modules from the AI Dart library for streaming functionality
import 'dart:io';
import '../lib/builder/llm_builder.dart';
import '../lib/models/chat_models.dart';
import '../lib/core/chat_provider.dart';

/// Example demonstrating how to use streaming chat with LLMBuilder
void main() async {
  // Get OpenAI API key from environment variable or use test key as fallback
  final apiKey = Platform.environment['OPENAI_API_KEY'] ?? 'sk-test';

  // Initialize and configure the LLM client with streaming enabled
  final llm = await LLMBuilder()
      .backend(LLMBackend.openai) // Use OpenAI as the LLM provider
      .apiKey(apiKey) // Set the API key
      .model('gpt-4') // Use GPT-4 model
      .maxTokens(512) // Limit response length
      .temperature(0.7) // Control response randomness (0.0-1.0)
      .stream(true) // Enable streaming responses
      .systemPrompt(
        'You are a helpful assistant that explains concepts clearly.',
      )
      .build();

  // Prepare conversation history with example messages
  final messages = [
    ChatMessage.user('Explain how streaming works in AI chat applications'),
  ];

  try {
    // Check if provider supports streaming
    if (llm is ChatCapability) {
      print('🚀 Starting streaming chat...\n');
      print('Response: ');

      // Send streaming chat request and handle events
      await for (final event in llm.chatStream(messages)) {
        switch (event) {
          case TextDeltaEvent(delta: final delta):
            // Print each text chunk as it arrives
            print(delta);
            break;
          case ThinkingDeltaEvent(delta: final delta):
            // Print thinking/reasoning content with special formatting
            print('\x1B[90m$delta\x1B[0m'); // Gray color for thinking content
            break;
          case ToolCallDeltaEvent(toolCall: final toolCall):
            // Handle tool call events (if supported)
            print('\n[Tool Call: ${toolCall.function.name}]');
            break;
          case CompletionEvent(response: final response):
            // Handle completion
            print('\n\n✅ Stream completed!');
            if (response.usage != null) {
              final usage = response.usage!;
              print(
                'Usage: ${usage.promptTokens} prompt + ${usage.completionTokens} completion = ${usage.totalTokens} total tokens',
              );
            }
            break;
          case ErrorEvent(error: final error):
            // Handle errors
            print('\n❌ Stream error: $error');
            break;
        }
      }
    } else {
      print('❌ Provider does not support streaming');

      // Fallback to regular chat
      print('Falling back to regular chat...');
      final response = await llm.chat(messages);
      print('Response: ${response.text}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
