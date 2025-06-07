# LLM Dart Library

A modular Dart library for AI provider interactions, inspired by the Rust [graniet/llm](https://github.com/graniet/llm) library. This library provides a unified interface for interacting with different AI providers using Dio for HTTP requests.

## Features

- **Multi-provider support**: OpenAI, Anthropic (Claude), Google (Gemini), DeepSeek, Ollama, xAI (Grok), Phind, Groq, ElevenLabs
- **Unified API**: Consistent interface across all providers
- **Builder pattern**: Fluent API for easy configuration
- **Streaming support**: Real-time response streaming
- **Tool calling**: Function calling capabilities
- **Structured output**: JSON schema support
- **Error handling**: Comprehensive error types
- **Type safety**: Full Dart type safety

## Supported Providers

| Provider | Chat | Streaming | Tools | TTS/STT | Notes |
|----------|------|-----------|-------|---------|-------|
| OpenAI | ✅ | ✅ | ✅ | ❌ | GPT models, reasoning |
| Anthropic | ✅ | ✅ | ✅ | ❌ | Claude models, thinking |
| Google | ✅ | ✅ | ✅ | ❌ | Gemini models |
| DeepSeek | ✅ | ✅ | ✅ | ❌ | DeepSeek models |
| Ollama | ✅ | ✅ | ✅ | ❌ | Local models |
| xAI | ✅ | ✅ | ✅ | ❌ | Grok models |
| Phind | ✅ | ✅ | ✅ | ❌ | Phind models |
| Groq | ✅ | ✅ | ✅ | ❌ | Fast inference |
| ElevenLabs | ❌ | ❌ | ❌ | ✅ | Voice synthesis |

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.0.0
```

## Quick Start

### Basic Usage

```dart
import 'package:llm_dart/llm_dart.dart';

void main() async {
  // Method 1: Using the new ai() builder with provider methods
  final provider = await ai()
      .openai()
      .apiKey('your-api-key')
      .model('gpt-4')
      .temperature(0.7)
      .build();

  // Method 2: Using provider() with string ID (extensible)
  final provider2 = await ai()
      .provider('openai')
      .apiKey('your-api-key')
      .model('gpt-4')
      .temperature(0.7)
      .build();

  // Method 3: Using convenience function
  final directProvider = await createProvider(
    providerId: 'openai',
    apiKey: 'your-api-key',
    model: 'gpt-4',
    temperature: 0.7,
  );

  // Simple chat
  final messages = [ChatMessage.user('Hello, world!')];
  final response = await provider.chat(messages);
  print(response.text);
}
```

### Streaming

```dart
await for (final event in provider.chatStream(messages)) {
  switch (event) {
    case TextDeltaEvent(delta: final delta):
      print(delta);
      break;
    case CompletionEvent():
      print('\n[Completed]');
      break;
    case ErrorEvent(error: final error):
      print('Error: $error');
      break;
  }
}
```

### Tool Calling

```dart
final tools = [
  Tool.function(
    name: 'get_weather',
    description: 'Get weather for a location',
    parameters: ParametersSchema(
      schemaType: 'object',
      properties: {
        'location': ParameterProperty(
          propertyType: 'string',
          description: 'City name',
        ),
      },
      required: ['location'],
    ),
  ),
];

final response = await provider.chatWithTools(messages, tools);
if (response.toolCalls != null) {
  for (final call in response.toolCalls!) {
    print('Tool: ${call.function.name}');
    print('Args: ${call.function.arguments}');
  }
}
```

## Provider Examples

### OpenAI

```dart
final provider = await createProvider(
  providerId: 'openai',
  apiKey: 'sk-...',
  model: 'gpt-4',
  temperature: 0.7,
  extensions: {'reasoningEffort': 'medium'}, // For o1 models
);
```

### Anthropic

```dart
final provider = anthropic(
  apiKey: 'sk-ant-...',
  model: 'claude-3-5-sonnet-20241022',
  reasoning: true, // Enable thinking
);
```

### Ollama

```dart
final provider = ollama(
  baseUrl: 'http://localhost:11434',
  model: 'llama3.1',
  // No API key needed for local Ollama
);
```

### ElevenLabs

```dart
final provider = elevenlabs(
  apiKey: 'your-elevenlabs-key',
  voiceId: 'pNInz6obpgDQGcFmaJgB',
);

// Text to speech
final ttsResponse = await provider.textToSpeech('Hello world!');
await File('output.mp3').writeAsBytes(ttsResponse.audioData);

// Speech to text
final audioData = await File('input.mp3').readAsBytes();
final sttResponse = await provider.speechToText(audioData);
print(sttResponse.text);
```

## Error Handling

```dart
try {
  final response = await provider.chatWithTools(messages, null);
  print(response.text);
} on AuthError catch (e) {
  print('Authentication failed: $e');
} on ProviderError catch (e) {
  print('Provider error: $e');
} on HttpError catch (e) {
  print('Network error: $e');
} catch (e) {
  print('Unexpected error: $e');
}
```

## Architecture

### Capability-Based Design

The library uses a capability-based interface design instead of monolithic "god interfaces":

```dart
// Core capabilities
abstract class ChatCapability {
  Future<ChatResponse> chat(List<ChatMessage> messages);
  Stream<ChatStreamEvent> chatStream(List<ChatMessage> messages);
}

abstract class EmbeddingCapability {
  Future<List<List<double>>> embed(List<String> input);
}

// Providers implement only the capabilities they support
class OpenAIProvider implements ChatCapability, EmbeddingCapability {
  // Implementation
}
```

### Provider Registry

The library includes an extensible provider registry system:

```dart
// Check available providers
final providers = LLMProviderRegistry.getRegisteredProviders();
print('Available: $providers'); // ['openai', 'anthropic', ...]

// Check capabilities
final supportsChat = LLMProviderRegistry.supportsCapability('openai', LLMCapability.chat);
print('OpenAI supports chat: $supportsChat'); // true

// Create providers dynamically
final provider = LLMProviderRegistry.createProvider('openai', config);
```

### Custom Providers

You can register custom providers:

```dart
// Create a custom provider factory
class MyCustomProviderFactory implements LLMProviderFactory<ChatCapability> {
  @override
  String get providerId => 'my_custom';

  @override
  Set<LLMCapability> get supportedCapabilities => {LLMCapability.chat};

  @override
  ChatCapability create(LLMConfig config) => MyCustomProvider(config);

  // ... other methods
}

// Register it
LLMProviderRegistry.register(MyCustomProviderFactory());

// Use it
final provider = await ai().provider('my_custom').build();
```

## Configuration

All providers support common configuration options:

- `apiKey`: API key for authentication
- `baseUrl`: Custom API endpoint
- `model`: Model name to use
- `temperature`: Sampling temperature (0.0-1.0)
- `maxTokens`: Maximum tokens to generate
- `systemPrompt`: System message
- `timeout`: Request timeout
- `stream`: Enable streaming
- `topP`, `topK`: Sampling parameters

### Provider-Specific Extensions

Use the extension system for provider-specific features:

```dart
final provider = await ai()
    .openai()
    .apiKey('your-key')
    .model('gpt-4')
    .reasoningEffort(ReasoningEffort.high)  // OpenAI-specific
    .extension('voice', 'alloy')           // OpenAI TTS voice
    .build();
```

## Examples

See the `examples/` directory for comprehensive usage examples:

- `deepseek_example.dart` - DeepSeek provider usage
- `ollama_example.dart` - Local Ollama usage
- `groq_example.dart` - Groq fast inference
- `elevenlabs_example.dart` - Text-to-speech and speech-to-text
- `multi_provider_example.dart` - Using multiple providers

## License

This library is inspired by the Rust llm crate and follows similar patterns adapted for Dart.
