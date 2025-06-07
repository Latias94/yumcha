// ignore_for_file: avoid_print
import 'dart:io';
import 'package:llm_dart/llm_dart.dart';

/// Example demonstrating Google Provider with enhanced features
///
/// To run this example with your own API key:
/// 1. Set environment variable: export GOOGLE_API_KEY=your_actual_api_key
/// 2. Run: dart run examples/google_example.dart
///
/// Or modify the fallback key in the code below.
void main() async {
  // Get Google API key from environment variable or use test key as fallback
  final apiKey =
      Platform.environment['GOOGLE_API_KEY'] ?? 'your-google-api-key';

  if (apiKey == 'your-google-api-key') {
    print(
        '⚠️  Using placeholder API key. Set GOOGLE_API_KEY environment variable for actual testing.');
  }

  print('=== Google Provider Example ===\n');

  // Example 1: Basic Google Provider usage
  await basicGoogleExample(apiKey);

  // Example 2: Google Provider with thinking/reasoning
  await googleThinkingExample(apiKey);

  // Example 3: Enhanced streaming example with better print experience
  await enhancedStreamingExample(apiKey);

  // Example 4: OpenAI-compatible interface with reasoning
  await googleOpenAIExample(apiKey);

  // Example 5: Google Provider with safety settings
  // await googleSafetyExample(apiKey);

  // Example 6: Google Provider with file upload
  // await googleFileExample(apiKey);

  // Example 7: Image generation example
  // await googleImageGenerationExample(apiKey);
}

/// Basic Google Provider example
Future<void> basicGoogleExample(String apiKey) async {
  print('1. Basic Google Provider Example:');

  try {
    final provider = await ai()
        .google()
        .apiKey(apiKey)
        .model('gemini-1.5-flash')
        .temperature(0.7)
        .maxTokens(1000)
        .build();

    final response = await provider.chat([
      ChatMessage.user('Hello! Can you tell me about quantum computing?'),
    ]);

    print('✓ Provider created successfully');
    print('Response: ${response.text}');
    print('Usage: ${response.usage}');
  } catch (e) {
    print('✗ Error: $e');
  }
}

/// Google Provider with thinking/reasoning example
Future<void> googleThinkingExample(String apiKey) async {
  print('\n2. Google Thinking Example:');

  try {
    final provider = await ai()
        .google()
        .apiKey(apiKey)
        .model('gemini-2.0-flash-thinking-exp')
        .reasoning(true)
        .extension('thinkingBudgetTokens', 1000)
        .extension('includeThoughts', true)
        .build();

    final response = await provider.chat([
      ChatMessage.user('Solve this step by step: What is 15 * 23 + 7 * 11?'),
    ]);

    print('✓ Provider created successfully');
    print('Response: ${response.text}');
    if (response.thinking != null) {
      print('Thinking process: ${response.thinking}');
    }
    print('Usage: ${response.usage}');
  } catch (e) {
    print('✗ Error: $e');
  }
}

/// Enhanced streaming example with better print experience (like reasoning_example.dart)
Future<void> enhancedStreamingExample(String apiKey) async {
  print('\n3. 🌊 Enhanced Streaming Example');
  print('=' * 50);

  try {
    final provider = await ai()
        .google()
        .apiKey(apiKey)
        .model('gemini-2.5-flash-preview-05-20')
        .reasoning(true)
        .extension('thinkingBudgetTokens', 1000)
        .extension('includeThoughts', true)
        .stream(true)
        .build();

    print('🧠 Starting Google reasoning model chat with thinking support...\n');

    var thinkingContent = StringBuffer();
    var responseContent = StringBuffer();
    var isThinking = true;

    final stream = provider.chatStream([
      ChatMessage.user(
          'What is 25 * 17? Please show your calculation step by step.'),
    ]);

    await for (final event in stream) {
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
          stdout.write(delta); // Print without newline for smooth streaming
          break;
        case ToolCallDeltaEvent(toolCall: final toolCall):
          print('\n[Tool Call: ${toolCall.function.name}]');
          break;
        case CompletionEvent(response: final response):
          print('\n\n✅ Google reasoning completed!');

          if (response.usage != null) {
            final usage = response.usage!;
            print(
              '\n📊 Usage: ${usage.promptTokens} prompt + ${usage.completionTokens} completion = ${usage.totalTokens} total tokens',
            );
          }
          break;
        case ErrorEvent(error: final error):
          print('\n❌ Stream error: $error');
          break;
      }
    }

    // Summary
    print('\n📝 Streaming Summary:');
    print('Thinking content length: ${thinkingContent.length} characters');
    print('Response content length: ${responseContent.length} characters');
    print('✓ Enhanced streaming completed successfully');
  } catch (e) {
    print('✗ Enhanced streaming error: $e');
  }
}

/// OpenAI-compatible interface with Google models and reasoning
Future<void> googleOpenAIExample(String apiKey) async {
  print('\n4. 🔄 Google OpenAI-Compatible Interface Example');
  print('=' * 50);

  try {
    // Using OpenAI-compatible interface for Google models
    final provider = await ai()
        .googleOpenAI() // Use OpenAI-compatible interface
        .apiKey(apiKey)
        .model(
            'models/gemini-2.5-flash-preview-05-20') // Use the model you specified
        .reasoning(true) // Enable reasoning
        .reasoningEffort(ReasoningEffort.medium) // Set reasoning effort
        .temperature(0.7)
        .maxTokens(1500)
        .build();

    print('🧠 Testing OpenAI-compatible Google interface with reasoning...\n');

    // Test non-streaming first
    print('📄 Non-streaming example:');
    final response = await provider.chat([
      ChatMessage.user('Solve this math problem step by step: 2x + 5 = 13'),
    ]);

    print('✓ Provider created successfully');
    print('🎯 Response: ${response.text}');
    if (response.thinking != null && response.thinking!.isNotEmpty) {
      print('🧠 Thinking process: ${response.thinking}');
    }
    if (response.usage != null) {
      final usage = response.usage!;
      print(
        '📊 Usage: ${usage.promptTokens} prompt + ${usage.completionTokens} completion = ${usage.totalTokens} total tokens',
      );
    }

    print('\n${'=' * 30}\n');

    // Test streaming
    print('🌊 Streaming example:');
    final streamProvider = await ai()
        .googleOpenAI()
        .apiKey(apiKey)
        .model('gemini-2.5-flash-preview-05-20')
        .reasoning(true)
        .reasoningEffort(ReasoningEffort.high)
        .extension('includeThoughts', true) // Include thinking summaries
        .extension('thinkingBudgetTokens', 1000) // Set thinking budget
        .stream(true)
        .build();

    var thinkingContent = StringBuffer();
    var responseContent = StringBuffer();
    var isThinking = true;

    final stream = streamProvider.chatStream([
      ChatMessage.user('What is 144 ÷ 12? Show your work.'),
    ]);

    await for (final event in stream) {
      switch (event) {
        case ThinkingDeltaEvent(delta: final delta):
          thinkingContent.write(delta);
          print('\x1B[90m$delta\x1B[0m'); // Gray color for thinking
          break;
        case TextDeltaEvent(delta: final delta):
          if (isThinking) {
            print('\n\n🎯 Final Answer:');
            isThinking = false;
          }
          responseContent.write(delta);
          stdout.write(delta);
          break;
        case ToolCallDeltaEvent(toolCall: final toolCall):
          print('\n[Tool Call: ${toolCall.function.name}]');
          break;
        case CompletionEvent(response: final response):
          print('\n\n✅ OpenAI-compatible streaming completed!');
          if (response.usage != null) {
            final usage = response.usage!;
            print(
              '\n📊 Usage: ${usage.promptTokens} prompt + ${usage.completionTokens} completion = ${usage.totalTokens} total tokens',
            );
          }
          break;
        case ErrorEvent(error: final error):
          print('\n❌ Stream error: $error');
          break;
      }
    }

    print('\n📝 OpenAI-Compatible Summary:');
    print('Thinking content length: ${thinkingContent.length} characters');
    print('Response content length: ${responseContent.length} characters');
    print('✓ OpenAI-compatible interface works perfectly!');
  } catch (e) {
    print('✗ OpenAI-compatible interface error: $e');
  }
}

/// Google Provider with custom safety settings
Future<void> googleSafetyExample(String apiKey) async {
  print('\n5. Google Safety Settings Example:');

  try {
    // Create custom safety settings
    final customSafetySettings = [
      const SafetySetting(
        category: HarmCategory.harmCategoryHateSpeech,
        threshold: HarmBlockThreshold.off,
      ),
      const SafetySetting(
        category: HarmCategory.harmCategoryDangerousContent,
        threshold: HarmBlockThreshold.blockOnlyHigh,
      ),
    ];

    final provider = await ai()
        .google()
        .apiKey(apiKey)
        .model('gemini-1.5-pro')
        .extension('safetySettings', customSafetySettings)
        .build();

    final response = await provider.chat([
      ChatMessage.user('Tell me about the history of artificial intelligence.'),
    ]);

    print('✓ Provider created successfully');
    print('Response: ${response.text}');
    print('Usage: ${response.usage}');
  } catch (e) {
    print('✗ Error: $e');
  }
}

/// Google Provider with file upload example
Future<void> googleFileExample(String apiKey) async {
  print('\n6. Google File Upload Example:');

  try {
    final provider = await ai()
        .google()
        .apiKey(apiKey)
        .model('gemini-1.5-pro')
        .extension('maxInlineDataSize', 10 * 1024 * 1024) // 10MB threshold
        .build();

    // Example with a small text file (will use inline data)
    final smallFileData = 'This is a small text file content.'.codeUnits;

    final response = await provider.chat([
      ChatMessage.user('Please analyze this file:'),
      ChatMessage.file(
        role: ChatRole.user,
        mime: FileMime.txt,
        data: smallFileData,
        content: 'Text file content',
      ),
    ]);

    print('✓ Provider created successfully');
    print('Response: ${response.text}');
    print('Usage: ${response.usage}');
  } catch (e) {
    print('✗ Error: $e');
  }
}

/// Image generation example with Google Provider
Future<void> googleImageGenerationExample(String apiKey) async {
  print('\n7. Google Image Generation Example:');

  try {
    final provider = await ai()
        .google()
        .apiKey(apiKey)
        .model('gemini-2.0-flash-exp')
        .extension('enableImageGeneration', true)
        .extension('responseModalities', ['TEXT', 'IMAGE']).build();

    final response = await provider.chat([
      ChatMessage.user(
          'Generate an image of a sunset over mountains and describe it.'),
    ]);

    print('✓ Provider created successfully');
    print('Response: ${response.text}');
    print('Usage: ${response.usage}');
  } catch (e) {
    print('✗ Error: $e');
  }
}
