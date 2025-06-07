// Import required modules from the LLM Dart library for DeepSeek integration
import 'dart:io';
import 'package:llm_dart/llm_dart.dart';

/// Example demonstrating how to use the DeepSeek provider with reasoning capabilities
///
/// Usage Instructions:
/// 1. Comment out one of the examples to test individually
/// 2. streamingReasoningExample() - Streaming output with thinking process in real-time
/// 3. nonStreamingReasoningExample() - Non-streaming output with complete thinking result
/// 4. basicChatExample() - Basic chat without reasoning
void main() async {
  print('=== DeepSeek Provider Examples ===\n');

  // Test basic chat functionality
  await basicChatExample();

  print('\n${'=' * 80}\n');

  // Test streaming reasoning with DeepSeek-R1
  await streamingReasoningExample();

  print('\n${'=' * 80}\n');

  // Test non-streaming reasoning with DeepSeek-R1
  await nonStreamingReasoningExample();

  print('\n${'=' * 80}\n');

  // Test OpenAI-compatible interface
  await openaiCompatibleExample();
}

/// Basic chat example without reasoning
Future<void> basicChatExample() async {
  print('💬 Basic DeepSeek Chat Example');
  print('=' * 50);

  // Get DeepSeek API key from environment variable or use test key as fallback
  final apiKey = Platform.environment['DEEPSEEK_API_KEY'] ?? 'sk-TESTKEY';

  try {
    // Initialize and configure the LLM client using native DeepSeek provider
    final llm = await ai()
        .deepseek() // Use native DeepSeek provider
        .apiKey(apiKey) // Set the API key
        .model('deepseek-chat') // Use DeepSeek Chat model (non-reasoning)
        .temperature(0.7) // Control response randomness (0.0-1.0)
        .timeout(const Duration(seconds: 60)) // Set timeout
        .systemPrompt('You are a helpful assistant.')
        .build();

    // Prepare conversation history with example messages
    final messages = [
      ChatMessage.user('What is the capital of France?'),
    ];

    print('🤖 Sending basic chat request...\n');

    // Send chat request and handle the response
    final response = await llm.chat(messages);
    print('💬 Response: ${response.text}');

    // Show usage information if available
    if (response.usage != null) {
      final usage = response.usage!;
      print(
          '\n📊 Usage: ${usage.promptTokens} prompt + ${usage.completionTokens} completion = ${usage.totalTokens} total tokens');
    }
  } catch (e) {
    print('❌ Basic chat error: $e');
  }
}

/// Streaming reasoning example with DeepSeek-R1 - shows thinking process in real-time
Future<void> streamingReasoningExample() async {
  print('🌊 DeepSeek Streaming Reasoning Example');
  print('=' * 50);

  // Get DeepSeek API key from environment variable or use test key as fallback
  final apiKey = Platform.environment['DEEPSEEK_API_KEY'] ?? 'sk-TESTKEY';

  try {
    // Initialize and configure the LLM client for streaming reasoning
    final llm = await ai()
        .deepseek() // Use native DeepSeek provider
        .apiKey(apiKey) // Set the API key
        .model('deepseek-reasoner') // Use DeepSeek-R1 reasoning model
        .maxTokens(2000) // Limit response length
        .timeout(const Duration(seconds: 300)) // Set timeout for reasoning
        .stream(true) // Enable streaming to see thinking process
        .build();

    // Create a simple reasoning task that demonstrates thinking
    final messages = [
      ChatMessage.user(
        'What is 25 × 4? Please show your calculation step by step.',
      ),
    ];

    print('🧠 Starting DeepSeek reasoning with thinking support...\n');

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
            print('\n\n🎯 DeepSeek Final Answer:');
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
          print('\n\n✅ DeepSeek reasoning completed!');

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
    print('\n📝 DeepSeek Streaming Summary:');
    print('Thinking content length: ${thinkingContent.length} characters');
    print('Response content length: ${responseContent.length} characters');
  } catch (e) {
    print('❌ DeepSeek streaming reasoning error: $e');
  }
}

/// Non-streaming reasoning example with DeepSeek-R1 - returns complete result at once
Future<void> nonStreamingReasoningExample() async {
  print('📄 DeepSeek Non-Streaming Reasoning Example');
  print('=' * 50);

  // Get DeepSeek API key from environment variable or use test key as fallback
  final apiKey = Platform.environment['DEEPSEEK_API_KEY'] ?? 'sk-TESTKEY';

  try {
    // Initialize and configure the LLM client for non-streaming reasoning
    final llm = await ai()
        .deepseek() // Use native DeepSeek provider
        .apiKey(apiKey) // Set the API key
        .model('deepseek-reasoner') // Use DeepSeek-R1 reasoning model
        .maxTokens(2000) // Limit response length
        .timeout(const Duration(seconds: 300)) // Set timeout for reasoning
        .stream(false) // Disable streaming for complete response
        .build();

    // Create a simple reasoning task that demonstrates thinking
    final messages = [
      ChatMessage.user(
        'If a train travels 60 km in 45 minutes, what is its speed in km/h? Show your calculation.',
      ),
    ];

    print('🧠 Starting DeepSeek reasoning, waiting for complete answer...\n');

    // Send non-streaming chat request
    final response = await llm.chat(messages);

    // Show thinking content if available
    if (response.thinking != null && response.thinking!.isNotEmpty) {
      print('🧠 DeepSeek Thinking Process:');
      print(
        '\x1B[90m${response.thinking}\x1B[0m',
      ); // Gray color for thinking content
      print('\n${'-' * 50}\n');
    }

    // Show the final response
    print('🎯 DeepSeek Final Answer:');
    print(response.text);

    // Show usage information
    if (response.usage != null) {
      final usage = response.usage!;
      print(
        '\n📊 Usage: ${usage.promptTokens} prompt + ${usage.completionTokens} completion = ${usage.totalTokens} total tokens',
      );
    }

    print('\n📝 DeepSeek Non-Streaming Summary:');
    print(
      'Thinking content length: ${response.thinking?.length ?? 0} characters',
    );
    print('Response content length: ${response.text?.length ?? 0} characters');
  } catch (e) {
    print('❌ DeepSeek non-streaming reasoning error: $e');
  }
}

/// OpenAI-compatible interface example with DeepSeek
Future<void> openaiCompatibleExample() async {
  print('🔄 DeepSeek OpenAI-Compatible Interface Example');
  print('=' * 50);

  // Get DeepSeek API key from environment variable or use test key as fallback
  final apiKey = Platform.environment['DEEPSEEK_API_KEY'] ?? 'sk-TESTKEY';

  try {
    // Initialize using OpenAI-compatible interface
    final llm = await ai()
        .deepseekOpenAI() // Use DeepSeek with OpenAI-compatible interface
        .apiKey(apiKey) // Set the API key
        .model('deepseek-reasoner') // Use DeepSeek-R1 reasoning model
        .maxTokens(1500) // Limit response length
        .timeout(const Duration(seconds: 300)) // Set timeout
        .stream(false) // Non-streaming for this example
        .build();

    // Create a simple reasoning task
    final messages = [
      ChatMessage.user(
        'What is 12 + 8 × 3? Please show the order of operations.',
      ),
    ];

    print('🤖 Using DeepSeek via OpenAI-compatible interface...\n');

    // Send chat request
    final response = await llm.chat(messages);

    // Show thinking content if available
    if (response.thinking != null && response.thinking!.isNotEmpty) {
      print('🧠 Thinking Process (via OpenAI interface):');
      print(
        '\x1B[90m${response.thinking}\x1B[0m',
      ); // Gray color for thinking content
      print('\n${'-' * 50}\n');
    }

    // Show the final response
    print('🎯 Final Answer (via OpenAI interface):');
    print(response.text);

    // Show usage information
    if (response.usage != null) {
      final usage = response.usage!;
      print(
        '\n📊 Usage: ${usage.promptTokens} prompt + ${usage.completionTokens} completion = ${usage.totalTokens} total tokens',
      );
    }

    print('\n📝 OpenAI-Compatible Interface Summary:');
    print('✅ Successfully used DeepSeek via OpenAI-compatible interface');
    print('✅ Automatic baseUrl configuration: https://api.deepseek.com/v1/');
    print('✅ Reasoning model parameters automatically optimized');
    print(
      'Thinking content length: ${response.thinking?.length ?? 0} characters',
    );
    print('Response content length: ${response.text?.length ?? 0} characters');
  } catch (e) {
    print('❌ OpenAI-compatible interface error: $e');
  }
}
