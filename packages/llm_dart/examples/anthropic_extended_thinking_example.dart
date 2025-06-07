// ignore_for_file: avoid_print
// Import required modules from the LLM Dart library for Anthropic extended thinking
import 'dart:io';
import 'package:llm_dart/llm_dart.dart';

/// Example demonstrating Anthropic's extended thinking capabilities
///
/// This example shows:
/// - Basic extended thinking with budget tokens
/// - Interleaved thinking with tool use (Claude 4 models)
/// - Handling redacted thinking blocks
/// - Different thinking budgets and their effects
/// - Real-time streaming with thinking process
///
/// Prerequisites:
/// - Anthropic API key (set ANTHROPIC_API_KEY environment variable)
/// - Claude 3.7+ or Claude 4 models for full extended thinking support
///
/// Usage:
/// ```bash
/// export ANTHROPIC_API_KEY=sk-ant-your_key_here
/// dart run anthropic_extended_thinking_example.dart
/// ```
void main() async {
  // Get Anthropic API key from environment variable
  final apiKey = Platform.environment['ANTHROPIC_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    print('❌ Please set ANTHROPIC_API_KEY environment variable');
    print('   Example: export ANTHROPIC_API_KEY=sk-ant-your_key_here');
    return;
  }

  print('🧠 Anthropic Extended Thinking Example');
  print('=' * 60);

  try {
    // Example 1: Basic extended thinking
    // await basicExtendedThinking(apiKey);

    // print('');

    // // Example 2: Different thinking budgets
    // await compareBudgets(apiKey);

    // print('');

    // // Example 3: Interleaved thinking with tools (Claude 4 only)
    // await interleavedThinkingExample(apiKey);

    // print('');

    // Example 4: Streaming with thinking
    await streamingThinkingExample(apiKey);
  } catch (e) {
    print('❌ Error: $e');
    if (e.toString().contains('401') || e.toString().contains('auth')) {
      print('   Please check your Anthropic API key');
    }
  }
}

/// Demonstrates basic extended thinking functionality
Future<void> basicExtendedThinking(String apiKey) async {
  print('🔍 Basic Extended Thinking');
  print('-' * 40);

  // Supported models:
  // Claude Opus 4 (claude-opus-4-20250514)
  // Claude Sonnet 4 (claude-sonnet-4-20250514)
  // Claude Sonnet 3.7 (claude-3-7-sonnet-20250219)

  // Create provider with extended thinking enabled
  final provider = await ai()
      .anthropic()
      .apiKey(apiKey)
      .model(
          'claude-sonnet-4-20250514') // Claude Sonnet 4 supports extended thinking
      .maxTokens(12000) // Must be greater than thinking budget
      .reasoning(true) // Enable extended thinking
      .thinkingBudgetTokens(8000) // Set thinking budget (must be < maxTokens)
      .build();

  print('✅ Provider configured with extended thinking');
  print('   Model: claude-sonnet-4-20250514');
  print('   Max tokens: 12000');
  print('   Thinking budget: 8000 tokens');
  print('');

  final messages = [
    ChatMessage.user(
        'I want to buy a laptop for programming. My budget is \$1000. '
        'Can you help me think through what specifications I should look for?'),
  ];

  print(
      'Question: Choosing a laptop for programming with budget constraints...');
  print('Requesting detailed thinking process...');

  final response = await provider.chat(messages);

  print('');
  print('📝 Claude\'s solution:');
  print(response.text ?? 'No text response');

  if (response.thinking != null && response.thinking!.isNotEmpty) {
    print('');
    print('🧠 Claude\'s thinking process:');
    print('─' * 60);
    // Show first 800 characters to avoid overwhelming output
    final thinking = response.thinking!;
    if (thinking.length > 800) {
      print('${thinking.substring(0, 800)}...');
      print('');
      print(
          '(Thinking process truncated - ${thinking.length} total characters)');
    } else {
      print(thinking);
    }
    print('─' * 60);
  } else {
    print('ℹ️  No thinking process captured');
  }
}

/// Compares different thinking budgets
Future<void> compareBudgets(String apiKey) async {
  print('⚖️  Thinking Budget Comparison');
  print('-' * 40);

  final budgets = [
    2000,
    6000,
    10000
  ]; // Keep budgets reasonable and < maxTokens
  const question =
      'What are the pros and cons of working from home versus working in an office? '
      'Please consider productivity, social aspects, and work-life balance.';

  print('Question: Comparing work from home vs office work...');
  print('Testing different thinking budgets...');
  print('');

  for (final budget in budgets) {
    print('🔄 Testing budget: $budget tokens');

    try {
      final provider = await ai()
          .anthropic()
          .apiKey(apiKey)
          .model('claude-sonnet-4-20250514')
          .maxTokens(budget + 4000) // Ensure maxTokens > thinkingBudgetTokens
          .reasoning(true)
          .thinkingBudgetTokens(budget)
          .build();

      final response = await provider.chat([ChatMessage.user(question)]);

      final thinkingLength = response.thinking?.length ?? 0;
      final responseLength = response.text?.length ?? 0;

      print('   Thinking length: $thinkingLength characters');
      print('   Response length: $responseLength characters');
      print(
          '   Ratio: ${thinkingLength > 0 ? (thinkingLength / responseLength).toStringAsFixed(2) : 'N/A'}:1');

      if (response.thinking != null && response.thinking!.isNotEmpty) {
        // Show just the first line of thinking for comparison
        final firstLine = response.thinking!.split('\n').first;
        print(
            '   First line: ${firstLine.length > 100 ? '${firstLine.substring(0, 100)}...' : firstLine}');
      }
    } catch (e) {
      print('   ❌ Error with budget $budget: $e');
    }

    print('');
  }
}

/// Demonstrates interleaved thinking with tool use (Claude 4 only)
Future<void> interleavedThinkingExample(String apiKey) async {
  print('🔗 Interleaved Thinking with Tools (Claude 4)');
  print('-' * 40);

  // Note: This example shows the configuration for interleaved thinking
  // Actual tool execution would require implementing the tools

  try {
    final provider = await ai()
        .anthropic()
        .apiKey(apiKey)
        .model(
            'claude-sonnet-4-20250514') // Claude 4 required for interleaved thinking
        .maxTokens(16000) // Must be greater than thinking budget
        .reasoning(true)
        .thinkingBudgetTokens(12000) // Thinking budget < maxTokens
        .interleavedThinking(true) // Enable interleaved thinking
        .build();

    print('✅ Provider configured with interleaved thinking');
    print('   Model: claude-sonnet-4-20250514');
    print('   Interleaved thinking: enabled');
    print('   Beta header: anthropic-beta: interleaved-thinking-2025-05-14');
    print('');

    // Define a simple calculator tool for demonstration
    final calculatorTool = Tool.function(
      name: 'calculator',
      description: 'Perform mathematical calculations',
      parameters: ParametersSchema(
        schemaType: 'object',
        properties: {
          'expression': ParameterProperty(
            propertyType: 'string',
            description: 'Mathematical expression to evaluate',
          ),
        },
        required: ['expression'],
      ),
    );

    final messages = [
      ChatMessage.user(
          'I want to calculate how much I need to save each month to buy a \$15,000 car in 2 years. '
          'Use the calculator tool to help with the math.'),
    ];

    print('Question: Monthly savings calculation for car purchase...');
    print('This would demonstrate thinking between tool calls...');
    print('Available tools: ${calculatorTool.function.name}');

    // Note: For a complete example, you would need to:
    // 1. Handle tool calls in the response
    // 2. Execute the calculator function
    // 3. Send tool results back with preserved thinking blocks
    // 4. Show how Claude thinks between tool calls

    final response = await provider.chatWithTools(messages, [calculatorTool]);

    print('');
    print('📝 Claude\'s response:');
    print(response.text ?? 'No text response');

    if (response.toolCalls != null && response.toolCalls!.isNotEmpty) {
      print('');
      print('🔧 Tool calls requested:');
      for (final toolCall in response.toolCalls!) {
        print('   ${toolCall.function.name}: ${toolCall.function.arguments}');
      }
    }

    if (response.thinking != null && response.thinking!.isNotEmpty) {
      print('');
      print('🧠 Initial thinking process:');
      print('─' * 60);
      final thinking = response.thinking!;
      if (thinking.length > 600) {
        print('${thinking.substring(0, 600)}...');
        print('(Truncated for display)');
      } else {
        print(thinking);
      }
      print('─' * 60);
    }
  } catch (e) {
    print('❌ Interleaved thinking example failed: $e');
    if (e.toString().contains('model')) {
      print('   Note: Interleaved thinking requires Claude 4 models');
      print('   Try using claude-sonnet-4-20250514 or claude-opus-4-20250514');
    }
  }
}

/// Demonstrates streaming with thinking process
Future<void> streamingThinkingExample(String apiKey) async {
  print('🌊 Streaming with Thinking Process');
  print('-' * 40);

  try {
    final provider = await ai()
        .anthropic()
        .apiKey(apiKey)
        .model('claude-sonnet-4-20250514')
        .maxTokens(8000)
        .reasoning(true)
        .thinkingBudgetTokens(4000)
        .build();

    final messages = [
      ChatMessage.user(
          'Explain how to make a simple budget for a college student. '
          'Think through the key categories and provide practical tips.'),
    ];

    print('Question: How to make a budget for college students...');
    print('');
    print('🧠 Claude\'s thinking and response (streaming):');
    print('─' * 50);

    var hasThinking = false;
    var hasResponse = false;

    await for (final event in provider.chatStream(messages)) {
      if (event is ThinkingDeltaEvent) {
        if (!hasThinking) {
          print('💭 Thinking process:');
          hasThinking = true;
        }
        stdout.write(event.delta);
      } else if (event is TextDeltaEvent) {
        if (!hasResponse) {
          if (hasThinking) print('\n');
          print('📝 Final response:');
          hasResponse = true;
        }
        stdout.write(event.delta);
      } else if (event is CompletionEvent) {
        print('\n─' * 50);
        print('✅ Streaming completed');

        // Show final thinking if available
        if (event.response.thinking != null &&
            event.response.thinking!.isNotEmpty) {
          print('');
          print('🧠 Complete thinking process available in response.thinking');
          print('   Length: ${event.response.thinking!.length} characters');
        }
        break;
      }
    }
  } catch (e) {
    print('❌ Streaming thinking example failed: $e');
  }
}
