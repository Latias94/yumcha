// Import required modules from the LLM Dart library for multiple providers
import 'dart:io';
import 'package:llm_dart/llm_dart.dart';

/// Example demonstrating how to use multiple AI providers with LLMBuilder
void main() async {
  // Define a simple, objective question that won't generate overly long responses
  const question = 'What is the capital of Japan?';

  // Create different providers using new API with environment variables
  final providers = <String, ChatCapability>{
    'OpenAI': await ai()
        .provider('openai')
        .apiKey(Platform.environment['OPENAI_API_KEY'] ?? 'sk-test')
        .model('gpt-4')
        .temperature(0.7)
        .build(),
    'Anthropic': await ai()
        .provider('anthropic')
        .apiKey(Platform.environment['ANTHROPIC_API_KEY'] ?? 'anthro-key')
        .model('claude-3-5-sonnet-20241022')
        .temperature(0.7)
        .build(),
    'Google': await ai()
        .provider('google')
        .apiKey(Platform.environment['GOOGLE_API_KEY'] ?? 'google-key')
        .model('gemini-1.5-flash')
        .temperature(0.7)
        .build(),
    'DeepSeek': await ai()
        .provider('deepseek')
        .apiKey(Platform.environment['DEEPSEEK_API_KEY'] ?? 'sk-test')
        .model('deepseek-chat')
        .temperature(0.7)
        .build(),
    'Groq': await ai()
        .provider('groq')
        .apiKey(Platform.environment['GROQ_API_KEY'] ?? 'gsk-test')
        .model('llama-3.3-70b-versatile')
        .temperature(0.7)
        .build(),
    'xAI': await ai()
        .provider('xai')
        .apiKey(Platform.environment['XAI_API_KEY'] ?? 'sk-test')
        .model('grok-2-latest')
        .temperature(0.7)
        .build(),
    'Ollama': await ai()
        .provider('ollama')
        .baseUrl(Platform.environment['OLLAMA_URL'] ?? 'http://localhost:11434')
        .model('llama3.1')
        .temperature(0.7)
        .build(),
  };

  final messages = [ChatMessage.user(question)];

  print('Asking all providers: "$question"\n');

  // Test each provider
  for (final entry in providers.entries) {
    final providerName = entry.key;
    final provider = entry.value;

    try {
      print('=== $providerName ===');

      // Regular chat
      final response = await provider.chat(messages);
      print('Response: ${response.text}');

      if (response.usage != null) {
        final usage = response.usage!;
        print(
          'Usage: ${usage.promptTokens} prompt + ${usage.completionTokens} completion = ${usage.totalTokens} total tokens',
        );
      }

      print('');
    } catch (e) {
      print('$providerName Error: $e\n');
    }
  }

  // Demonstrate streaming with OpenAI using new API
  print('\n=== Streaming Example (OpenAI) ===');
  try {
    final streamingProvider = await ai()
        .provider('openai')
        .apiKey(Platform.environment['OPENAI_API_KEY'] ?? 'sk-test')
        .model('gpt-4')
        .temperature(0.7)
        .stream(true) // Enable streaming
        .build();

    // All ChatCapability providers support streaming
    print('Streaming response:');

    await for (final event in streamingProvider.chatStream(messages)) {
      switch (event) {
        case TextDeltaEvent(delta: final delta):
          stdout.write(delta);
          break;
        case CompletionEvent():
          print('\n[Stream completed]');
          break;
        case ErrorEvent(error: final error):
          print('\nStream error: $error');
          break;
        case ToolCallDeltaEvent():
          // Handle tool call events if needed
          break;
        default:
          break;
      }
    }
  } catch (e) {
    print('Streaming error: $e');
  }

  print('\n✅ Multi-provider example completed!');
}
