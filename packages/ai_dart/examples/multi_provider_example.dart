// Import required modules from the AI Dart library for multiple providers
import 'dart:io';
import '../lib/builder/llm_builder.dart';
import '../lib/models/chat_models.dart';
import '../lib/core/chat_provider.dart';

/// Example demonstrating how to use multiple AI providers with LLMBuilder
void main() async {
  // Define a common question
  const question = 'Explain the concept of machine learning in 2-3 sentences.';

  // Create different providers using LLMBuilder with environment variables
  final providers = <String, ChatProvider>{
    'OpenAI': await LLMBuilder()
        .backend(LLMBackend.openai)
        .apiKey(Platform.environment['OPENAI_API_KEY'] ?? 'sk-test')
        .model('gpt-4')
        .temperature(0.7)
        .build(),
    'Anthropic': await LLMBuilder()
        .backend(LLMBackend.anthropic)
        .apiKey(Platform.environment['ANTHROPIC_API_KEY'] ?? 'anthro-key')
        .model('claude-3-5-sonnet-20241022')
        .temperature(0.7)
        .build(),
    'Google': await LLMBuilder()
        .backend(LLMBackend.google)
        .apiKey(Platform.environment['GOOGLE_API_KEY'] ?? 'google-key')
        .model('gemini-1.5-flash')
        .temperature(0.7)
        .build(),
    'DeepSeek': await LLMBuilder()
        .backend(LLMBackend.deepseek)
        .apiKey(Platform.environment['DEEPSEEK_API_KEY'] ?? 'sk-test')
        .model('deepseek-chat')
        .temperature(0.7)
        .build(),
    'Groq': await LLMBuilder()
        .backend(LLMBackend.groq)
        .apiKey(Platform.environment['GROQ_API_KEY'] ?? 'gsk-test')
        .model('llama-3.3-70b-versatile')
        .temperature(0.7)
        .build(),
    'xAI': await LLMBuilder()
        .backend(LLMBackend.xai)
        .apiKey(Platform.environment['XAI_API_KEY'] ?? 'sk-test')
        .model('grok-2-latest')
        .temperature(0.7)
        .build(),
    'Ollama': await LLMBuilder()
        .backend(LLMBackend.ollama)
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

  // Demonstrate streaming with OpenAI
  print('\n=== Streaming Example (OpenAI) ===');
  try {
    final streamingProvider = await LLMBuilder()
        .backend(LLMBackend.openai)
        .apiKey(Platform.environment['OPENAI_API_KEY'] ?? 'sk-test')
        .model('gpt-4')
        .temperature(0.7)
        .stream(true) // Enable streaming
        .build();

    if (streamingProvider is StreamingChatProvider) {
      print('Streaming response:');

      await for (final event in streamingProvider.chatStream(messages)) {
        switch (event) {
          case TextDeltaEvent(delta: final delta):
            print(delta);
            break;
          case CompletionEvent():
            print('\n[Stream completed]');
            break;
          case ErrorEvent(error: final error):
            print('\nStream error: $error');
            break;
          default:
            break;
        }
      }
    } else {
      print('Provider does not support streaming');
    }
  } catch (e) {
    print('Streaming error: $e');
  }

  print('\n✅ Multi-provider example completed!');
}
