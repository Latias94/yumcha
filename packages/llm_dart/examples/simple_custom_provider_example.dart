// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:llm_dart/llm_dart.dart';

/// Simple example demonstrating how to create a custom AI provider
///
/// This example shows the minimal implementation needed to create
/// a custom provider that can be registered and used with the LLM Dart library.
class SimpleMockResponse implements ChatResponse {
  final String _text;

  SimpleMockResponse(this._text);

  @override
  String? get text => _text;

  @override
  List<ToolCall>? get toolCalls => null;

  @override
  UsageInfo? get usage => null;

  @override
  String? get thinking => null;
}

/// Simple custom AI provider
class SimpleMockProvider implements ChatCapability {
  final String model;
  final Random _random = Random();

  SimpleMockProvider({required this.model});

  @override
  Future<ChatResponse> chat(List<ChatMessage> messages) async {
    // Simulate processing delay
    await Future.delayed(Duration(milliseconds: 200));

    final lastMessage = messages.isNotEmpty ? messages.last.content : 'Hello';
    final responses = [
      'Hello! I\'m a mock AI using model $model. You said: "$lastMessage"',
      'Mock response from $model: I understand your message about "$lastMessage"',
      'Simulated AI ($model) says: Thanks for your message "$lastMessage"',
    ];

    final responseText = responses[_random.nextInt(responses.length)];
    return SimpleMockResponse(responseText);
  }

  @override
  Future<ChatResponse> chatWithTools(
    List<ChatMessage> messages,
    List<Tool>? tools,
  ) async {
    // For simplicity, ignore tools
    return await chat(messages);
  }

  @override
  Stream<ChatStreamEvent> chatStream(
    List<ChatMessage> messages, {
    List<Tool>? tools,
  }) async* {
    final response = await chat(messages);
    final text = response.text ?? '';

    // Simulate streaming by yielding word by word
    final words = text.split(' ');
    for (int i = 0; i < words.length; i++) {
      await Future.delayed(Duration(milliseconds: 100));
      final chunk = i == 0 ? words[i] : ' ${words[i]}';
      yield TextDeltaEvent(chunk);
    }

    yield CompletionEvent(response);
  }

  @override
  Future<List<ChatMessage>?> memoryContents() async => null;

  @override
  Future<String> summarizeHistory(List<ChatMessage> messages) async {
    return 'Mock summary of ${messages.length} messages';
  }
}

/// Factory for creating the simple mock provider
class SimpleMockProviderFactory
    implements LLMProviderFactory<SimpleMockProvider> {
  @override
  String get providerId => 'simple_mock';

  @override
  String get displayName => 'Simple Mock AI';

  @override
  String get description => 'A simple mock AI provider for demonstration';

  @override
  Set<LLMCapability> get supportedCapabilities => {
        LLMCapability.chat,
        LLMCapability.streaming,
      };

  @override
  SimpleMockProvider create(LLMConfig config) {
    return SimpleMockProvider(model: config.model);
  }

  @override
  bool validateConfig(LLMConfig config) {
    return config.model.isNotEmpty;
  }

  @override
  LLMConfig getDefaultConfig() {
    return LLMConfig(
      baseUrl: 'https://simple-mock.example.com',
      model: 'simple-mock-v1',
    );
  }
}

/// Example usage
void main() async {
  print('=== Simple Custom Provider Example ===\n');

  // Step 1: Register the custom provider
  print('1. Registering custom provider...');
  LLMProviderRegistry.register(SimpleMockProviderFactory());
  print('✓ Simple Mock provider registered');

  // Step 2: Check registration
  final providers = LLMProviderRegistry.getRegisteredProviders();
  print('Available providers: $providers');

  // Step 3: Create and use the provider
  print('\n2. Creating and using custom provider:');
  try {
    final provider =
        await ai().provider('simple_mock').model('simple-mock-v2').build();

    print('✓ Provider created successfully');

    // Test basic chat
    final messages = [
      ChatMessage.user('Hello, simple mock AI!'),
    ];

    final response = await provider.chat(messages);
    print('Response: ${response.text}');

    // Test streaming
    print('\n3. Testing streaming:');
    print('Streaming response: ');
    await for (final event in provider.chatStream([
      ChatMessage.user('Tell me about yourself'),
    ])) {
      switch (event) {
        case TextDeltaEvent(delta: final delta):
          stdout.write(delta);
          break;
        case CompletionEvent():
          print('\n[Completed]');
          break;
        case ErrorEvent(error: final error):
          print('\nError: $error');
          break;
        default:
          // Handle other event types
          break;
      }
    }
  } catch (e) {
    print('✗ Error: $e');
  }

  print('\n=== Example completed ===');
  print('\nThis example shows:');
  print('• How to implement ChatCapability interface');
  print('• How to create a provider factory');
  print('• How to register and use custom providers');
  print('• Basic chat and streaming functionality');
}
