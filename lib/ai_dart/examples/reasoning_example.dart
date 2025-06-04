import 'dart:io';

import '../builder/llm_builder.dart';
import '../core/chat_provider.dart';
import '../models/chat_models.dart';

/// Example demonstrating how to use reasoning models (o1, o3, o4 series) with thinking support
void main() async {
  // Get OpenAI API key from environment variable or use test key as fallback
  final apiKey = 'sk-ngt7SAfEo154u80l8Yc7T7R8xAwCQE9yd9MhnEqxKCdjZxV9';

  // Initialize and configure the LLM client for reasoning model
  final llm = await LLMBuilder()
      .backend(LLMBackend.openai) // Use OpenAI as the LLM provider
      .apiKey(apiKey) // Set the API key
      .baseUrl('https://api.mnapi.com/v1/')
      .model('deepseek-r1') // Use o1-preview reasoning model
      .reasoningEffort('high') // Set reasoning effort level
      .maxTokens(2000) // Limit response length
      .stream(true) // Enable streaming to see thinking process
      .build();

  // Create a complex reasoning task
  final messages = [
    ChatMessage.user(
      'Solve this step by step: A farmer has 17 sheep. All but 9 die. How many sheep are left? '
      'Please think through this carefully and explain your reasoning.',
    ),
  ];

  try {
    // Check if provider supports streaming
    if (llm is StreamingChatProvider) {
      print('🧠 Starting reasoning model chat with thinking support...\n');

      var thinkingContent = StringBuffer();
      var responseContent = StringBuffer();
      var isThinking = true;

      // Send streaming chat request and handle events
      await for (final event in llm.chatStream(messages)) {
        switch (event) {
          case ThinkingDeltaEvent(delta: final delta):
            // Collect thinking/reasoning content
            thinkingContent.write(delta);
            print('\x1B[90m$delta\x1B[0m'); // Gray color for thinking content
            break;
          case TextDeltaEvent(delta: final delta):
            // This is the actual response after thinking
            if (isThinking) {
              print('\n\n🎯 Response:');
              isThinking = false;
            }
            responseContent.write(delta);
            print(delta);
            break;
          case ToolCallDeltaEvent(toolCall: final toolCall):
            // Handle tool call events (if supported)
            print('\n[Tool Call: ${toolCall.function.name}]');
            break;
          case CompletionEvent(response: final response):
            // Handle completion
            print('\n\n✅ Reasoning completed!');

            // Show thinking content if available
            if (response.thinking != null && response.thinking!.isNotEmpty) {
              print('\n🧠 Thinking process:');
              print('\x1B[90m${response.thinking}\x1B[0m');
            }

            if (response.usage != null) {
              final usage = response.usage!;
              print(
                '\n📊 Usage: ${usage.promptTokens} prompt + ${usage.completionTokens} completion = ${usage.totalTokens} total tokens',
              );
            }
            break;
          case ErrorEvent(error: final error):
            // Handle errors
            print('\n❌ Stream error: $error');
            break;
        }
      }

      // Summary
      print('\n' + '=' * 50);
      print('📝 Summary:');
      print('Thinking tokens: ${thinkingContent.length} characters');
      print('Response tokens: ${responseContent.length} characters');
    } else {
      print('❌ Provider does not support streaming');

      // Fallback to regular chat
      print('Falling back to regular chat...');
      final response = await llm.chat(messages);
      print('Response: ${response.text}');

      // Show thinking content if available
      if (response.thinking != null && response.thinking!.isNotEmpty) {
        print('\n🧠 Thinking process:');
        print('\x1B[90m${response.thinking}\x1B[0m');
      }
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
