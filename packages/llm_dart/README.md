# LLM Dart Library

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Dart](https://img.shields.io/badge/Dart-3.5.0+-blue.svg)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.8.0+-blue.svg)](https://flutter.dev)

A modular Dart library for AI provider interactions, inspired by the Rust [graniet/llm](https://github.com/graniet/llm) library. This library provides a unified interface for interacting with different AI providers using Dio for HTTP requests.

**🧠 Full access to model thinking processes** - llm_dart provides direct access to the internal reasoning and thought processes of supported AI models (Claude, OpenAI o1, DeepSeek, Gemini), giving you unprecedented insight into how AI models arrive at their conclusions.

> **Part of yumcha project**: This library is extracted from the [yumcha](https://github.com/Latias94/yumcha) AI chat client to provide reusable LLM functionality under MIT license, while the main Flutter app uses AGPL v3.

## Features

- **Multi-provider support**: OpenAI, Anthropic (Claude), Google (Gemini), DeepSeek, Ollama, xAI (Grok), Phind, Groq, ElevenLabs
- **🧠 Thinking process support**: Access to model reasoning and thought processes (Claude, OpenAI o1, DeepSeek)
- **Unified API**: Consistent interface across all providers
- **Builder pattern**: Fluent API for easy configuration
- **Streaming support**: Real-time response streaming with thinking
- **Tool calling**: Function calling capabilities
- **Structured output**: JSON schema support
- **Error handling**: Comprehensive error types
- **Type safety**: Full Dart type safety

## Supported Providers

| Provider | Chat | Streaming | Tools | Thinking | TTS/STT | Notes |
|----------|------|-----------|-------|----------|---------|-------|
| OpenAI | ✅ | ✅ | ✅ | 🧠 | ❌ | GPT models, o1 reasoning |
| Anthropic | ✅ | ✅ | ✅ | 🧠 | ❌ | Claude models with thinking |
| Google | ✅ | ✅ | ✅ | 🧠 | ❌ | Gemini models with reasoning |
| DeepSeek | ✅ | ✅ | ✅ | 🧠 | ❌ | DeepSeek reasoning models |
| Ollama | ✅ | ✅ | ✅ | ❌ | ❌ | Local models |
| xAI | ✅ | ✅ | ✅ | ❌ | ❌ | Grok models |
| Phind | ✅ | ✅ | ✅ | ❌ | ❌ | Phind models |
| Groq | ✅ | ✅ | ✅ | ❌ | ❌ | Fast inference |
| ElevenLabs | ❌ | ❌ | ❌ | ❌ | ✅ | Voice synthesis |

**🧠 Thinking Process Support**: Access to model's internal reasoning and thought processes

## Installation

### As part of yumcha project

This library is part of the [yumcha](https://github.com/Latias94/yumcha) monorepo. If you're working with the full project:

```bash
git clone https://github.com/Latias94/yumcha.git
cd yumcha
melos bootstrap
```

### Standalone usage

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  llm_dart: ^0.1.0
  dio: ^5.8.0  # Required HTTP client
```

Then run:
```bash
dart pub get
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

  // Access thinking process (for supported models)
  if (response.thinking != null) {
    print('Model thinking: ${response.thinking}');
  }
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

### 🧠 Thinking Process Access

Access the model's internal reasoning and thought processes:

```dart
// Claude with thinking
final claudeProvider = await ai()
    .anthropic()
    .apiKey('your-anthropic-key')
    .model('claude-3-5-sonnet-20241022')
    .build();

final messages = [
  ChatMessage.user('Solve this step by step: What is 15% of 240?')
];

final response = await claudeProvider.chat(messages);

// Access the final answer
print('Answer: ${response.text}');

// Access the thinking process
if (response.thinking != null) {
  print('Claude\'s thinking process:');
  print(response.thinking);
}

// OpenAI o1 reasoning
final openaiProvider = await ai()
    .openai()
    .apiKey('your-openai-key')
    .model('o1-preview')
    .reasoningEffort(ReasoningEffort.high)
    .build();

final reasoningResponse = await openaiProvider.chat(messages);
print('O1 reasoning: ${reasoningResponse.thinking}');
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

### Anthropic (with Thinking Process)

```dart
final provider = await ai()
    .anthropic()
    .apiKey('sk-ant-...')
    .model('claude-3-5-sonnet-20241022')
    .build();

final response = await provider.chat([
  ChatMessage.user('Explain quantum computing step by step')
]);

// Access Claude's thinking process
print('Final answer: ${response.text}');
if (response.thinking != null) {
  print('Claude\'s reasoning: ${response.thinking}');
}
```

### DeepSeek (with Reasoning)

```dart
final provider = await ai()
    .deepseek()
    .apiKey('your-deepseek-key')
    .model('deepseek-reasoner')
    .build();

final response = await provider.chat([
  ChatMessage.user('Solve this logic puzzle step by step')
]);

// Access DeepSeek's reasoning process
print('Solution: ${response.text}');
if (response.thinking != null) {
  print('DeepSeek\'s reasoning: ${response.thinking}');
}
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

See the **[examples directory](https://github.com/Latias94/yumcha/tree/main/packages/llm_dart/examples)** for comprehensive usage examples and detailed documentation:

### 🟢 Beginner Examples

- **[simple_llm_builder_example.dart](https://github.com/Latias94/yumcha/blob/main/packages/llm_dart/examples/simple_llm_builder_example.dart)** - Basic usage with multiple providers
- **[openai_example.dart](https://github.com/Latias94/yumcha/blob/main/packages/llm_dart/examples/openai_example.dart)** - OpenAI provider with all creation methods
- **[anthropic_example.dart](https://github.com/Latias94/yumcha/blob/main/packages/llm_dart/examples/anthropic_example.dart)** - Basic Anthropic Claude usage
- **[anthropic_extended_thinking_example.dart](https://github.com/Latias94/yumcha/blob/main/packages/llm_dart/examples/anthropic_extended_thinking_example.dart)** - Advanced extended thinking features

### 🟡 Intermediate Examples

- **[streaming_example.dart](https://github.com/Latias94/yumcha/blob/main/packages/llm_dart/examples/streaming_example.dart)** - Real-time streaming responses
- **[reasoning_example.dart](https://github.com/Latias94/yumcha/blob/main/packages/llm_dart/examples/reasoning_example.dart)** - Reasoning models with thinking
- **[multi_provider_example.dart](https://github.com/Latias94/yumcha/blob/main/packages/llm_dart/examples/multi_provider_example.dart)** - Using multiple providers together

### 🎯 Specialized Provider Examples

- **[elevenlabs_example.dart](https://github.com/Latias94/yumcha/blob/main/packages/llm_dart/examples/elevenlabs_example.dart)** - ElevenLabs TTS/STT (Text-to-Speech & Speech-to-Text)
- **[groq_example.dart](https://github.com/Latias94/yumcha/blob/main/packages/llm_dart/examples/groq_example.dart)** - Groq fast inference
- **[ollama_example.dart](https://github.com/Latias94/yumcha/blob/main/packages/llm_dart/examples/ollama_example.dart)** - Local Ollama models
- **[deepseek_example.dart](https://github.com/Latias94/yumcha/blob/main/packages/llm_dart/examples/deepseek_example.dart)** - DeepSeek reasoning models

### 🔴 Advanced Examples

- **[custom_provider_example.dart](https://github.com/Latias94/yumcha/blob/main/packages/llm_dart/examples/custom_provider_example.dart)** - Full custom provider implementation
- **[api_features_example.dart](https://github.com/Latias94/yumcha/blob/main/packages/llm_dart/examples/api_features_example.dart)** - API features and usage patterns showcase

📖 **[Complete Examples Guide](https://github.com/Latias94/yumcha/tree/main/packages/llm_dart/examples)** - Detailed documentation, setup instructions, and best practices.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

This library is inspired by the Rust [graniet/llm](https://github.com/graniet/llm) library and follows similar patterns adapted for Dart.
