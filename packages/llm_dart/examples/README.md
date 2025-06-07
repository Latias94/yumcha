# LLM Dart Examples

This directory contains comprehensive examples demonstrating how to use the LLM Dart library with its new refactored API.

## 🆕 New API Examples (Recommended)

### Basic Usage Examples

- **[new_api_example.dart](new_api_example.dart)** - Comprehensive overview of the new refactored API
- **[openai_example.dart](openai_example.dart)** - Updated OpenAI provider example showing all 4 ways to create providers
- **[simple_custom_provider_example.dart](simple_custom_provider_example.dart)** - Simple custom provider implementation

### Provider-Specific Examples

- **[anthropic_example.dart](anthropic_example.dart)** - Anthropic Claude models
- **[deepseek_example.dart](deepseek_example.dart)** - DeepSeek reasoning models  
- **[google_example.dart](google_example.dart)** - Google Gemini models
- **[groq_example.dart](groq_example.dart)** - Groq fast inference
- **[ollama_example.dart](ollama_example.dart)** - Local Ollama models
- **[xai_example.dart](xai_example.dart)** - xAI Grok models
- **[elevenlabs_example.dart](elevenlabs_example.dart)** - ElevenLabs TTS/STT

### Advanced Examples

- **[streaming_example.dart](streaming_example.dart)** - Streaming chat responses
- **[reasoning_example.dart](reasoning_example.dart)** - Reasoning models with thinking content
- **[multi_provider_example.dart](multi_provider_example.dart)** - Using multiple providers
- **[list_models_example.dart](list_models_example.dart)** - Listing available models

## 🔧 Custom Provider Development

### Creating Custom Providers

The new architecture makes it easy to create custom providers:

```dart
// 1. Implement the ChatCapability interface
class MyCustomProvider implements ChatCapability {
  @override
  Future<ChatResponse> chat(List<ChatMessage> messages) async {
    // Your implementation
  }
  
  @override
  Stream<ChatStreamEvent> chatStream(List<ChatMessage> messages) async* {
    // Your streaming implementation
  }
  
  // ... other required methods
}

// 2. Create a provider factory
class MyCustomProviderFactory implements LLMProviderFactory<MyCustomProvider> {
  @override
  String get providerId => 'my_custom';
  
  @override
  MyCustomProvider create(LLMConfig config) => MyCustomProvider(config);
  
  // ... other required methods
}

// 3. Register and use
LLMProviderRegistry.register(MyCustomProviderFactory());
final provider = await ai().provider('my_custom').build();
```

## 📚 API Migration Guide

### Old API (Deprecated)
```dart
// ❌ Old way - still works but deprecated
final provider = await LLMBuilder()
    .backend(LLMBackend.openai)  // Deprecated
    .apiKey('key')
    .build();
```

### New API (Recommended)
```dart
// ✅ Method 1: Provider-specific methods
final provider = await ai()
    .openai()
    .apiKey('key')
    .build();

// ✅ Method 2: Generic provider method (extensible)
final provider = await ai()
    .provider('openai')
    .apiKey('key')
    .build();

// ✅ Method 3: Convenience functions
final provider = await openai(apiKey: 'key', model: 'gpt-4');
```

## 🎯 Key Features Demonstrated

### 1. Capability-Based Design
- Providers implement only the capabilities they support
- Type-safe capability checking at compile time
- No more "god interfaces" forcing unnecessary implementations

### 2. Provider Registry System
- Dynamic provider registration
- Extensible architecture for third-party providers
- Runtime capability discovery

### 3. Unified Configuration
- Single `LLMConfig` class for all providers
- Provider-specific extensions through the extension system
- Reduced code duplication

### 4. Enhanced Error Handling
- Specific error types for different scenarios
- HTTP status code mapping
- Detailed error information

### 5. Multiple API Styles
- Builder pattern for complex configurations
- Convenience functions for quick setup
- Generic provider method for extensibility

## 🚀 Running Examples

To run any example:

```bash
cd packages/llm_dart
dart run examples/example_name.dart
```

For examples requiring API keys, set environment variables:

```bash
export OPENAI_API_KEY="your-openai-key"
export ANTHROPIC_API_KEY="your-anthropic-key"
export DEEPSEEK_API_KEY="your-deepseek-key"
# ... etc

dart run examples/openai_example.dart
```

## 📖 Example Categories

### 🟢 Beginner Examples
- `new_api_example.dart` - Start here for API overview
- `simple_custom_provider_example.dart` - Basic custom provider
- `openai_example.dart` - Multiple ways to create providers

### 🟡 Intermediate Examples  
- `streaming_example.dart` - Real-time responses
- `multi_provider_example.dart` - Working with multiple providers
- `reasoning_example.dart` - Advanced reasoning models

### 🔴 Advanced Examples
- `custom_provider_example.dart` - Full custom provider implementation
- `multi_backend_example.dart` - Complex multi-provider scenarios
- Provider-specific examples for specialized features

## 💡 Best Practices

1. **Use the new API** - Prefer `ai().openai()` over deprecated `LLMBuilder().backend()`
2. **Check capabilities** - Use `provider is ChatCapability` for type safety
3. **Handle errors properly** - Catch specific error types like `AuthError`, `RateLimitError`
4. **Use extensions** - Leverage the extension system for provider-specific features
5. **Register custom providers** - Use the registry system for extensibility

## 🔗 Related Documentation

- [Main README](../README.md) - Library overview and installation
- [REFACTOR_SUMMARY.md](../REFACTOR_SUMMARY.md) - Detailed refactoring information
- [API Documentation](../lib/) - Source code and inline documentation

---

**Note**: Examples marked with 🆕 use the new refactored API. Legacy examples still work but show deprecation warnings.
