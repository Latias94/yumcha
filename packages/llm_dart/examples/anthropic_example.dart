// ignore_for_file: avoid_print
// Import required modules from the LLM Dart library for Anthropic integration
import 'dart:io';
import 'package:llm_dart/llm_dart.dart';

/// Example demonstrating basic Anthropic Claude usage
///
/// This example shows:
/// - Simple chat conversations
/// - Creative writing tasks
/// - Question answering
/// - Tool calling
/// - Real-time streaming responses
///
/// For advanced features, see:
/// - anthropic_extended_thinking_example.dart (thinking/reasoning)
/// - anthropic_file_example.dart (PDF and file processing)
///
/// Prerequisites:
/// - Anthropic API key (set ANTHROPIC_API_KEY environment variable)
///
/// Usage:
/// ```bash
/// export ANTHROPIC_API_KEY=sk-ant-your_key_here
/// dart run anthropic_example.dart
/// ```
void main() async {
  // Get Anthropic API key from environment variable
  final apiKey = Platform.environment['ANTHROPIC_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    print('❌ Please set ANTHROPIC_API_KEY environment variable');
    print('   Example: export ANTHROPIC_API_KEY=sk-ant-your_key_here');
    return;
  }

  print('🤖 Anthropic Claude Basic Example');
  print('=' * 50);

  try {
    // Initialize and configure the LLM client using modern API
    final llm = await ai()
        .anthropic() // Use Anthropic (Claude) as the LLM provider
        .apiKey(apiKey) // Set the API key
        .model('claude-3-5-sonnet-20241022') // Use Claude 3.5 Sonnet
        .maxTokens(1000) // Set response length limit
        .temperature(0.7) // Control response randomness (0.0-1.0)
        .build();

    print('✅ Claude provider initialized successfully');
    print('   Model: claude-3-5-sonnet-20241022');
    print('   Max tokens: 1000');
    print('   Temperature: 0.7');
    print('   Capabilities: Vision ✅, Tools ✅, PDF ✅');
    print(
        '   Note: For thinking/reasoning, use claude-3-7-sonnet-20250219 or claude-4 models');
    print('');

    // Example 1: Simple conversation
    await simpleConversationExample(llm);

    print('');

    // Example 2: Creative writing
    await creativeWritingExample(llm);

    print('');

    // Example 3: Question answering
    await questionAnsweringExample(llm);

    print('');

    // Example 4: Tool calling
    await toolCallingExample(llm);

    print('');

    // Example 5: Streaming response
    await streamingExample(llm);
  } catch (e) {
    print('❌ Error: $e');
    if (e.toString().contains('401') || e.toString().contains('auth')) {
      print('   Please check your Anthropic API key');
    } else if (e.toString().contains('model')) {
      print('   The specified model may not be available or supported');
    }
  }
}

/// Demonstrates simple conversation
Future<void> simpleConversationExample(ChatCapability llm) async {
  print('💬 Simple Conversation');
  print('-' * 30);

  final messages = [
    ChatMessage.user('Hello! Can you tell me what the primary colors are?'),
  ];

  final response = await llm.chat(messages);
  print('User: Hello! Can you tell me what the primary colors are?');
  print('Claude: ${response.text}');
}

/// Demonstrates creative writing
Future<void> creativeWritingExample(ChatCapability llm) async {
  print('✍️ Creative Writing');
  print('-' * 30);

  final messages = [
    ChatMessage.user(
        'Write a short, cheerful poem about a sunny day in the park. Keep it to 4 lines.'),
  ];

  print('Request: Write a short poem about a sunny day...');

  final response = await llm.chat(messages);

  print('');
  print('📝 Claude\'s poem:');
  print(response.text);
}

/// Demonstrates question answering
Future<void> questionAnsweringExample(ChatCapability llm) async {
  print('❓ Question Answering');
  print('-' * 30);

  final messages = [
    ChatMessage.user(
        'What is the capital of Japan and what is it famous for? Please give a brief answer.'),
  ];

  print('Question: What is the capital of Japan and what is it famous for?');

  final response = await llm.chat(messages);

  print('');
  print('📍 Claude\'s answer:');
  print(response.text);
}

/// Demonstrates tool calling
Future<void> toolCallingExample(ChatCapability llm) async {
  print('🔧 Tool Calling');
  print('-' * 30);

  // Define a simple weather tool
  final weatherTool = Tool.function(
    name: 'get_weather',
    description: 'Get current weather information for a location',
    parameters: ParametersSchema(
      schemaType: 'object',
      properties: {
        'location': ParameterProperty(
          propertyType: 'string',
          description: 'City name or location',
        ),
        'unit': ParameterProperty(
          propertyType: 'string',
          description: 'Temperature unit (celsius or fahrenheit)',
          enumList: ['celsius', 'fahrenheit'],
        ),
      },
      required: ['location'],
    ),
  );

  final messages = [
    ChatMessage.user(
        'What\'s the weather like in Tokyo? Use the weather tool.'),
  ];

  print('Request: What\'s the weather like in Tokyo?');
  print('Available tools: ${weatherTool.function.name}');

  final response = await llm.chatWithTools(messages, [weatherTool]);

  print('');
  if (response.toolCalls != null && response.toolCalls!.isNotEmpty) {
    print('🔧 Tool calls made:');
    for (final toolCall in response.toolCalls!) {
      print('   ${toolCall.function.name}: ${toolCall.function.arguments}');
    }
    print('');
    print(
        '📝 Note: In a real app, you would execute these tool calls and send results back');
  } else {
    print('📝 Claude\'s response:');
    print(response.text);
  }
}

/// Demonstrates streaming response
Future<void> streamingExample(ChatCapability llm) async {
  print('🌊 Streaming Response');
  print('-' * 30);

  final messages = [
    ChatMessage.user(
        'Tell me a short story about a robot learning to paint. Stream the response as you write it.'),
  ];

  print('Request: Tell me a short story about a robot learning to paint...');
  print('');
  print('📖 Claude\'s streaming story:');
  print('─' * 40);

  // Use chatStream for real-time streaming
  await for (final event in llm.chatStream(messages)) {
    if (event is TextDeltaEvent) {
      // Print each chunk as it arrives (without newline)
      stdout.write(event.delta);
    } else if (event is CompletionEvent) {
      // Stream completed
      print('\n─' * 40);
      print('✅ Streaming completed');
      break;
    }
  }
}
