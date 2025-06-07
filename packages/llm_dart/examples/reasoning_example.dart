import 'dart:io';

import 'package:llm_dart/llm_dart.dart';

/// Example demonstrating how to use reasoning models (o1, o3, o4 series) with thinking support
///
/// Usage Instructions:
/// 1. Comment out one of the examples to test individually
/// 2. streamingExample() - Streaming output example, shows thinking process in real-time
/// 3. nonStreamingExample() - Non-streaming output example, returns complete result at once
void main() async {
  // Test streaming output - comment out the line below to disable streaming test
  await streamingExample();

  print('\n${'=' * 80}\n');

  // Test non-streaming output - comment out the line below to disable non-streaming test
  await nonStreamingExample();
}

/// Streaming output example - shows AI thinking process in real-time
Future<void> streamingExample() async {
  print('🌊 Streaming Example');
  print('=' * 50);

  // Get OpenAI API key from environment variable or use test key as fallback
  final apiKey = Platform.environment['OPENAI_API_KEY'] ?? 'sk-OPENAI';

  // Initialize and configure the LLM client for streaming
  final llm = await LLMBuilder()
      .openai() // Use OpenAI as the LLM provider
      .apiKey(apiKey) // Set the API key
      .model('deepseek-r1') // Use reasoning model
      .reasoningEffort('high') // Set reasoning effort level
      .maxTokens(2000) // Limit response length
      .stream(true) // Enable streaming to see thinking process
      .build();

  // Create a simple reasoning task that demonstrates thinking without being too long
  final messages = [
    ChatMessage.user(
      'What is 15 + 27? Please show your calculation step by step.',
    ),
  ];

  try {
    // All providers support streaming through ChatCapability
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
            print('\n\n🎯 Final Answer:');
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
    print('\n📝 Streaming Summary:');
    print('Thinking content length: ${thinkingContent.length} characters');
    print('Response content length: ${responseContent.length} characters');
  } catch (e) {
    print('❌ Streaming example error: $e');
  }
}

/// Non-streaming output example - returns complete result at once
Future<void> nonStreamingExample() async {
  print('📄 Non-Streaming Example');
  print('=' * 50);

  // Get OpenAI API key from environment variable or use test key as fallback
  final apiKey = Platform.environment['OPENAI_API_KEY'] ?? 'sk-OPENAI';

  // Initialize and configure the LLM client for non-streaming
  final llm = await LLMBuilder()
      .openai() // Use OpenAI as the LLM provider
      .apiKey(apiKey) // Set the API key
      .model('deepseek-r1') // Use reasoning model
      .reasoningEffort('high') // Set reasoning effort level
      .maxTokens(2000) // Limit response length
      .stream(false) // Disable streaming for complete response
      .build();

  // Create a simple reasoning task that demonstrates thinking
  final messages = [
    ChatMessage.user(
        'If I have 3 apples and buy 5 more, then give away 2, how many apples do I have left?'),
  ];

  try {
    print('🧠 Starting reasoning model chat, waiting for complete answer...\n');

    // Send non-streaming chat request
    final response = await llm.chat(messages);

    // Show thinking content if available
    if (response.thinking != null && response.thinking!.isNotEmpty) {
      print('🧠 Thinking Process:');
      print(
        '\x1B[90m${response.thinking}\x1B[0m',
      ); // Gray color for thinking content
      print('\n${'-' * 50}\n');
    }

    // Show the final response
    print('🎯 Final Answer:');
    print(response.text);

    // Show usage information
    if (response.usage != null) {
      final usage = response.usage!;
      print(
        '\n📊 Usage: ${usage.promptTokens} prompt + ${usage.completionTokens} completion = ${usage.totalTokens} total tokens',
      );
    }

    print('\n📝 Non-Streaming Summary:');
    print(
      'Thinking content length: ${response.thinking?.length ?? 0} characters',
    );
    print('Response content length: ${response.text?.length ?? 0} characters');
  } catch (e) {
    print('❌ Non-streaming example error: $e');
  }
}
