/// Example demonstrating how to create and register a custom AI provider
///
/// This example shows:
/// 1. How to implement a custom provider
/// 2. How to create a provider factory
/// 3. How to register the provider
/// 4. How to use the custom provider
/// 5. How to handle provider-specific configurations

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:llm_dart/llm_dart.dart';

/// Mock implementation of ChatResponse for demonstration
class MockChatResponse implements ChatResponse {
  final String _text;
  final int _promptTokens;
  final int _completionTokens;
  final String _model;

  MockChatResponse(
      this._text, this._promptTokens, this._completionTokens, this._model);

  @override
  String? get text => _text;

  @override
  List<ToolCall>? get toolCalls => null;

  @override
  UsageInfo? get usage => createMockUsage(_promptTokens, _completionTokens);

  @override
  String? get thinking => null;

  String get model => _model;
}

/// Mock implementation using the actual UsageInfo class
UsageInfo createMockUsage(int promptTokens, int completionTokens) {
  return UsageInfo(
    promptTokens: promptTokens,
    completionTokens: completionTokens,
    totalTokens: promptTokens + completionTokens,
  );
}

/// Custom AI provider that simulates responses (for demonstration)
class MockAIProvider implements ChatCapability, ProviderCapabilities {
  final MockAIConfig config;
  final Random _random = Random();

  @override
  Future<List<ChatMessage>?> memoryContents() async => null;

  @override
  Future<String> summarizeHistory(List<ChatMessage> messages) async {
    return 'Mock summary of ${messages.length} messages';
  }

  MockAIProvider(this.config);

  @override
  Set<LLMCapability> get supportedCapabilities => {
        LLMCapability.chat,
        LLMCapability.streaming,
      };

  @override
  bool supports(LLMCapability capability) =>
      supportedCapabilities.contains(capability);

  @override
  Future<ChatResponse> chat(List<ChatMessage> messages) async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: config.responseDelay));

    final lastMessage = messages.isNotEmpty ? messages.last.content : 'Hello';
    final responseText = _generateMockResponse(lastMessage);

    return MockChatResponse(
      responseText,
      _countTokens(messages.map((m) => m.content).join(' ')),
      _countTokens(responseText),
      config.model,
    );
  }

  @override
  Future<ChatResponse> chatWithTools(
    List<ChatMessage> messages,
    List<Tool>? tools,
  ) async {
    // For simplicity, ignore tools in this mock implementation
    return await chat(messages);
  }

  @override
  Stream<ChatStreamEvent> chatStream(
    List<ChatMessage> messages, {
    List<Tool>? tools,
  }) async* {
    final response = await chat(messages);
    final text = response.text ?? '';

    // Simulate streaming by yielding chunks
    final words = text.split(' ');
    for (int i = 0; i < words.length; i++) {
      await Future.delayed(Duration(milliseconds: config.streamDelay));

      final chunk = i == 0 ? words[i] : ' ${words[i]}';
      yield TextDeltaEvent(chunk);
    }

    yield CompletionEvent(response);
  }

  String _generateMockResponse(String input) {
    final responses = [
      'This is a mock response to: "$input"',
      'I understand you said: "$input". Here\'s my simulated response.',
      'Mock AI processing: "$input" -> Generated response with ${config.creativity} creativity.',
      'Simulated ${config.model} response: I received your message about "$input".',
    ];

    return responses[_random.nextInt(responses.length)];
  }

  int _countTokens(String text) {
    // Simple token counting (roughly 4 characters per token)
    return (text.length / 4).ceil();
  }
}

/// Configuration class for the mock AI provider
class MockAIConfig {
  final String model;
  final int responseDelay;
  final int streamDelay;
  final String creativity;
  final String? customEndpoint;

  const MockAIConfig({
    required this.model,
    this.responseDelay = 500,
    this.streamDelay = 100,
    this.creativity = 'medium',
    this.customEndpoint,
  });

  /// Create MockAIConfig from unified LLMConfig
  factory MockAIConfig.fromLLMConfig(LLMConfig config) {
    return MockAIConfig(
      model: config.model,
      responseDelay: config.getExtension<int>('responseDelay') ?? 500,
      streamDelay: config.getExtension<int>('streamDelay') ?? 100,
      creativity: config.getExtension<String>('creativity') ?? 'medium',
      customEndpoint: config.getExtension<String>('customEndpoint'),
    );
  }
}

/// Factory for creating MockAI provider instances
class MockAIProviderFactory implements LLMProviderFactory<MockAIProvider> {
  @override
  String get providerId => 'mock_ai';

  @override
  String get displayName => 'Mock AI';

  @override
  String get description =>
      'A mock AI provider for testing and demonstration purposes';

  @override
  Set<LLMCapability> get supportedCapabilities => {
        LLMCapability.chat,
        LLMCapability.streaming,
      };

  @override
  MockAIProvider create(LLMConfig config) {
    final mockConfig = MockAIConfig.fromLLMConfig(config);
    return MockAIProvider(mockConfig);
  }

  @override
  bool validateConfig(LLMConfig config) {
    // Mock AI doesn't require an API key, but needs a model
    return config.model.isNotEmpty;
  }

  @override
  LLMConfig getDefaultConfig() {
    return LLMConfig(
      baseUrl: 'https://mock-ai.example.com/v1/',
      model: 'mock-gpt-3.5',
    );
  }
}

/// Example demonstrating custom provider usage
void main() async {
  print('=== Custom Provider Example ===\n');

  // Step 1: Register the custom provider
  print('1. Registering custom provider...');
  LLMProviderRegistry.register(MockAIProviderFactory());
  print('✓ MockAI provider registered');

  // Step 2: Verify registration
  print('\n2. Checking registered providers:');
  final providers = LLMProviderRegistry.getRegisteredProviders();
  print('Available providers: $providers');

  // Step 3: Get provider information
  print('\n3. Provider information:');
  final providerInfo = LLMProviderRegistry.getProviderInfo('mock_ai');
  if (providerInfo != null) {
    print('Name: ${providerInfo.displayName}');
    print('Description: ${providerInfo.description}');
    print(
        'Capabilities: ${providerInfo.supportedCapabilities.map((c) => c.name).join(', ')}');
  }

  // Step 4: Create provider using the new API
  print('\n4. Creating custom provider:');
  try {
    final provider = await ai()
        .provider('mock_ai')
        .model('mock-gpt-4')
        .extension('responseDelay', 300)
        .extension('streamDelay', 50)
        .extension('creativity', 'high')
        .extension('customEndpoint', 'https://my-custom-ai.com')
        .build();

    print('✓ Custom provider created successfully');

    // Step 5: Test basic chat
    print('\n5. Testing basic chat:');
    final messages = [
      ChatMessage.user('Hello, custom AI! How are you?'),
    ];

    final response = await provider.chat(messages);
    print('Response: ${response.text}');
    if (response is MockChatResponse) {
      print('Model: ${response.model}');
    }
    print('Tokens used: ${response.usage?.totalTokens}');

    // Step 6: Test streaming
    print('\n6. Testing streaming:');
    final streamMessages = [
      ChatMessage.user('Tell me a short story about AI'),
    ];

    print('Streaming response: ');
    await for (final event in provider.chatStream(streamMessages)) {
      switch (event) {
        case TextDeltaEvent(delta: final delta):
          stdout.write(delta);
          break;
        case CompletionEvent():
          print('\n[Stream completed]');
          break;
        case ErrorEvent(error: final error):
          print('\nError: $error');
          break;
        case ToolCallDeltaEvent():
          // Handle tool call events if needed
          break;
        default:
          // Handle any other event types
          break;
      }
    }

    // Step 7: Test capability checking
    print('\n7. Capability checking:');
    print('Supports chat: ${provider is ChatCapability}');
    print('Supports embedding: ${provider is EmbeddingCapability}');

    if (provider is ProviderCapabilities) {
      final capabilities = (provider as ProviderCapabilities);
      print(
          'Declared capabilities: ${capabilities.supportedCapabilities.map((c) => c.name).join(', ')}');
      print(
          'Supports streaming: ${capabilities.supports(LLMCapability.streaming)}');
    }
  } catch (e) {
    print('✗ Error: $e');
  }

  // Step 8: Demonstrate multiple providers
  print('\n8. Using multiple providers:');
  try {
    // Create another instance with different config
    final provider2 = await ai()
        .provider('mock_ai')
        .model('mock-claude-3')
        .extension('creativity', 'low')
        .extension('responseDelay', 100)
        .build();

    final quickResponse = await provider2.chat([
      ChatMessage.user('Quick test message'),
    ]);
    print('Quick response: ${quickResponse.text}');
  } catch (e) {
    print('✗ Error: $e');
  }

  print('\n=== Custom Provider Example Completed ===');
  print('\nKey takeaways:');
  print(
      '• Custom providers can be easily created by implementing ChatCapability');
  print('• Provider factories enable registration and dynamic creation');
  print('• Extension system allows provider-specific configuration');
  print('• Multiple instances of the same provider can have different configs');
  print('• Capability checking ensures type safety');
}
