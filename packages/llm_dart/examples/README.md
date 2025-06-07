# LLM Dart Examples

This directory contains comprehensive examples demonstrating how to use the LLM Dart library with its new refactored API.

## 📚 Examples by Difficulty Level

### 🟢 Beginner Examples (Start Here)

- **[simple_llm_builder_example.dart](simple_llm_builder_example.dart)** - Basic usage with multiple providers
- **[openai_example.dart](openai_example.dart)** - OpenAI provider with all creation methods
- **[anthropic_example.dart](anthropic_example.dart)** - Basic Anthropic Claude usage (simple conversations)
- **[anthropic_extended_thinking_example.dart](anthropic_extended_thinking_example.dart)** - Advanced extended thinking and reasoning features
- **[google_example.dart](google_example.dart)** - Google Gemini models

### 🟡 Intermediate Examples

- **[streaming_example.dart](streaming_example.dart)** - Real-time streaming responses
- **[reasoning_example.dart](reasoning_example.dart)** - Reasoning models with thinking process access
- **[deepseek_example.dart](deepseek_example.dart)** - DeepSeek reasoning models with step-by-step thinking
- **[multi_provider_example.dart](multi_provider_example.dart)** - Using multiple providers together
- **[list_models_example.dart](list_models_example.dart)** - Listing available models

### 🔴 Advanced Examples

- **[custom_provider_example.dart](custom_provider_example.dart)** - Full custom provider implementation
- **[capability_query_example.dart](capability_query_example.dart)** - Provider capability discovery
- **[api_features_example.dart](api_features_example.dart)** - API features and usage patterns showcase

### 🎯 Specialized Provider Examples

- **[groq_example.dart](groq_example.dart)** - Groq fast inference
- **[ollama_example.dart](ollama_example.dart)** - Local Ollama models
- **[xai_example.dart](xai_example.dart)** - xAI Grok models
- **[elevenlabs_example.dart](elevenlabs_example.dart)** - ElevenLabs TTS/STT (Text-to-Speech & Speech-to-Text)
- **[openai_compatible_example.dart](openai_compatible_example.dart)** - OpenAI-compatible providers

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

## 📚 API Usage Guide

### Multiple Ways to Create Providers

```dart
// ✅ Method 1: Provider-specific methods (Type-safe)
final provider = await ai()
    .openai()
    .apiKey('your-key')
    .model('gpt-4')
    .build();

// ✅ Method 2: Generic provider method (Extensible)
final provider = await ai()
    .provider('openai')
    .apiKey('your-key')
    .model('gpt-4')
    .build();

// ✅ Method 3: Convenience functions (Concise)
final provider = await createProvider(
  providerId: 'openai',
  apiKey: 'your-key',
  model: 'gpt-4',
  temperature: 0.7,
);
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

## 🎙️ ElevenLabs TTS/STT Guide

The **[elevenlabs_example.dart](elevenlabs_example.dart)** demonstrates comprehensive Text-to-Speech and Speech-to-Text functionality.

### Prerequisites

1. **ElevenLabs API Key**: Get your API key from [ElevenLabs](https://elevenlabs.io/)
2. **Environment Setup**:
   ```bash
   export ELEVENLABS_API_KEY=your_api_key_here
   ```

### Features Demonstrated

#### Text-to-Speech (TTS)
- High-quality speech synthesis
- Configurable voice settings (stability, similarity boost, style)
- Multiple voice options and models
- Audio file output (MP3 format)

#### Speech-to-Text (STT)
- Audio transcription with multiple models (`scribe_v1`, `scribe_v1_experimental`)
- Language detection with confidence scores
- Word-level timing information
- Support for file-based and byte-based transcription

#### Advanced Features
- List available models and voices
- Test different voice configurations
- Comprehensive error handling

### Configuration Example

```dart
final provider = await ai()
    .elevenlabs()                    // Use ElevenLabs provider
    .apiKey(apiKey)                  // Set API key
    .model('eleven_multilingual_v2') // TTS model
    .voiceId('JBFqnCBsd6RMkjVDRZzb') // Voice ID (George)
    .stability(0.5)                  // Voice stability (0.0-1.0)
    .similarityBoost(0.8)            // Similarity boost (0.0-1.0)
    .style(0.0)                      // Style exaggeration (0.0-1.0)
    .useSpeakerBoost(true)           // Enable speaker boost
    .build();

// Cast to access TTS/STT methods
final elevenLabsProvider = provider as ElevenLabsProvider;

// Text-to-Speech
final ttsResponse = await elevenLabsProvider.textToSpeech('Hello world!');
await File('output.mp3').writeAsBytes(ttsResponse.audioData);

// Speech-to-Text
final sttResponse = await elevenLabsProvider.speechToTextFromFile(
  'audio.mp3',
  model: 'scribe_v1',
);
print('Transcribed: ${sttResponse.text}');
```

### Voice Settings Guide

- **Stability** (0.0-1.0): Controls voice consistency
  - Higher = more stable, consistent voice
  - Lower = more expressive, variable voice

- **Similarity Boost** (0.0-1.0): Enhances voice similarity to original
  - Higher = closer to original voice
  - Lower = more creative interpretation

- **Style** (0.0-1.0): Controls style exaggeration
  - Higher = more exaggerated style
  - Lower = more natural style

- **Speaker Boost**: Enhances speaker characteristics

### Available Models

**TTS Models:**
- `eleven_monolingual_v1` - English only, fast
- `eleven_multilingual_v2` - Multiple languages, high quality
- `eleven_turbo_v2` - Fast generation

**STT Models:**
- `scribe_v1` - Standard transcription model
- `scribe_v1_experimental` - Experimental features

### Running the Example

```bash
cd packages/llm_dart/examples
export ELEVENLABS_API_KEY=your_api_key_here
dart run elevenlabs_example.dart
```

The example will generate several audio files demonstrating different voice settings and transcribe them back to text.

## 📖 Quick Start Guide

### 🟢 New to LLM Dart? Start Here:

1. **[simple_llm_builder_example.dart](simple_llm_builder_example.dart)** - Basic usage patterns
2. **[openai_example.dart](openai_example.dart)** - Learn different ways to create providers
3. **[streaming_example.dart](streaming_example.dart)** - See real-time responses

### 🟡 Ready for More? Try These:

4. **[reasoning_example.dart](reasoning_example.dart)** - Explore thinking processes and reasoning
5. **[multi_provider_example.dart](multi_provider_example.dart)** - Use multiple providers together
6. **[deepseek_example.dart](deepseek_example.dart)** - Advanced reasoning with step-by-step thinking

### 🔴 Advanced Usage:

7. **[custom_provider_example.dart](custom_provider_example.dart)** - Build your own provider
8. **[api_features_example.dart](api_features_example.dart)** - Complete API features showcase


## 💡 Best Practices

1. **Use provider-specific methods** - Prefer `ai().openai()` for better IDE support and type safety
2. **Check capabilities** - Use `provider is ChatCapability` for type safety
3. **Handle errors properly** - Catch specific error types like `AuthError`, `RateLimitError`
4. **Use extensions** - Leverage the extension system for provider-specific features
5. **Register custom providers** - Use the registry system for extensibility
6. **Choose appropriate questions** - For reasoning models, use moderately complex questions that demonstrate thinking

## 🧠 Thinking Process & Reasoning Features

The LLM Dart library provides access to AI model thinking processes and reasoning capabilities, giving you unprecedented insight into how models arrive at their conclusions.

### What is Thinking Process?

The thinking process feature allows you to access the internal reasoning and thought processes of AI models. This is valuable for:

- **Debugging AI responses**: Understanding why a model gave a specific answer
- **Educational purposes**: Learning how AI models approach problems
- **Quality assurance**: Verifying the reasoning behind AI decisions
- **Research**: Analyzing AI reasoning patterns

### Supported Models

| Provider | Models | Thinking Support |
|----------|--------|------------------|
| **Anthropic** | Claude 3.7+, Claude 4 | ✅ Extended thinking with budget control |
| **OpenAI** | o1-preview, o1-mini | ✅ Reasoning traces |
| **DeepSeek** | deepseek-reasoner | ✅ Step-by-step reasoning |
| **Google** | Gemini models | ✅ Reasoning steps |

### Extended Thinking (Anthropic)

Anthropic's extended thinking provides enhanced reasoning capabilities:

- **Claude 3.7**: Full thinking output
- **Claude 4**: Summarized thinking (full intelligence, condensed output)
- **Interleaved thinking**: Think between tool calls (Claude 4 only)
- **Budget control**: Set thinking token limits (1,024 - 32,000+ tokens)
- **Token constraints**: `max_tokens` must be greater than `thinking_budget_tokens`
- **Redacted thinking**: Automatic encryption of sensitive reasoning

### Basic Usage

```dart
// Basic extended thinking
final provider = await ai()
    .anthropic()
    .apiKey('your-api-key')
    .model('claude-3-7-sonnet-20250219') // Claude 3.7+ for extended thinking
    .maxTokens(12000) // Must be > thinkingBudgetTokens
    .reasoning(true) // Enable extended thinking
    .thinkingBudgetTokens(8000) // Set thinking budget (< maxTokens)
    .build();

final response = await provider.chat([
  ChatMessage.user('Explain how to make a budget for college students')
]);

// Access the final answer
print('Answer: ${response.text}');

// Access the thinking process
if (response.thinking != null) {
  print('Thinking process: ${response.thinking}');
}
```

### Streaming with Thinking

You can access thinking processes in real-time during streaming:

```dart
await for (final event in provider.chatStream(messages)) {
  if (event is ThinkingDeltaEvent) {
    print('Thinking: ${event.delta}');
  } else if (event is TextDeltaEvent) {
    print('Response: ${event.delta}');
  }
}
```

### Important Constraints

**Critical**: `max_tokens` must always be greater than `thinking_budget_tokens`

```dart
// ❌ Wrong - will cause 400 error
.maxTokens(4000)
.thinkingBudgetTokens(8000)  // Error: 8000 > 4000

// ✅ Correct
.maxTokens(12000)
.thinkingBudgetTokens(8000)  // OK: 8000 < 12000
```

**Recommended Ratios:**
- **Conservative**: `maxTokens = thinkingBudgetTokens + 4000`
- **Balanced**: `maxTokens = thinkingBudgetTokens * 1.5`
- **Generous**: `maxTokens = thinkingBudgetTokens * 2`

### Best Practices for Thinking

1. **Always check for null**: Not all responses include thinking processes
2. **Handle long content**: Thinking processes can be very long, consider truncation
3. **Use appropriate models**: Only certain models support thinking processes
4. **Respect rate limits**: Thinking processes may use more tokens
5. **Privacy considerations**: Thinking processes may contain sensitive reasoning
6. **Token planning**: Always ensure `maxTokens > thinkingBudgetTokens`

### Troubleshooting

**No Thinking Process Available:**
- The model doesn't support thinking processes
- The query was too simple to trigger detailed reasoning
- The API response didn't include thinking data

**Empty Thinking Process:**
```dart
if (response.thinking != null && response.thinking!.isNotEmpty) {
  // Process thinking
} else {
  print('No detailed thinking process for this response');
}
```

## 🔗 Related Documentation

- [Main README](../README.md) - Library overview and installation

---

**Note**: All examples use the modern LLM Dart API with provider registry system and capability-based design.
