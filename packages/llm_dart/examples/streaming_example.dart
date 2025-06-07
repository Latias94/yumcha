import 'dart:io';
import 'package:llm_dart/llm_dart.dart';

/// Example demonstrating how to use streaming chat with LLMBuilder
void main() async {
  // Get OpenAI API key from environment variable or use test key as fallback
  final apiKey = Platform.environment['OPENAI_API_KEY'] ?? 'sk-test';

  // Initialize and configure the LLM client with streaming enabled
  final llm = await LLMBuilder()
      .openai() // Use OpenAI as the LLM provider
      .apiKey(apiKey) // Set the API key
      .model('gpt-4') // Use GPT-4 model
      .maxTokens(512) // Limit response length
      .temperature(0.7) // Control response randomness (0.0-1.0)
      .stream(true) // Enable streaming responses
      .systemPrompt(
        'You are a helpful assistant that explains concepts clearly.',
      )
      .build();

  // Prepare conversation history with a simple question for streaming demo
  final messages = [
    ChatMessage.user('Count from 1 to 10 and explain each number briefly'),
  ];

  try {
    // All providers support streaming through ChatCapability
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
  } catch (e) {
    print('❌ Error: $e');
  }
}
