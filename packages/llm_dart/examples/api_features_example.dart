/// Example demonstrating the LLM Dart API features and capabilities
///
/// This example shows the modern API design, provider registry system,
/// and various ways to create and configure LLM providers.

import 'dart:io';
import 'package:llm_dart/llm_dart.dart';

void main() async {
  // ignore_for_file: avoid_print

  print('=== LLM Dart API Features Example ===\n');

  // Show available providers
  print('1. Available Providers:');
  final providers = LLMProviderRegistry.getRegisteredProviders();
  print('   Registered providers: $providers');

  for (final providerId in providers) {
    final info = LLMProviderRegistry.getProviderInfo(providerId);
    if (info != null) {
      print('   - ${info.displayName}: ${info.description}');
      print(
          '     Capabilities: ${info.supportedCapabilities.map((c) => c.name).join(', ')}');
    }
  }

  print('\n2. Multiple API Styles:');

  print('\n   Method 1: Provider-specific methods (Type-safe)');
  print('   ```dart');
  print('   final provider = await ai()');
  print('       .openai()                    // ✅ Type-safe, IDE support');
  print('       .apiKey("your-key")');
  print('       .model("gpt-4")');
  print('       .temperature(0.7)');
  print('       .build();');
  print('   ```');

  print('\n   Method 2: Generic provider method (Extensible)');
  print('   ```dart');
  print('   final provider = await ai()');
  print(
      '       .provider("openai")          // ✅ Extensible for custom providers');
  print('       .apiKey("your-key")');
  print('       .model("gpt-4")');
  print('       .temperature(0.7)');
  print('       .build();');
  print('   ```');

  print('\n   Method 3: Convenience functions (Concise)');
  print('   ```dart');
  print('   final provider = await createProvider(  // ✅ Quick setup');
  print('     providerId: "openai",');
  print('     apiKey: "your-key",');
  print('     model: "gpt-4",');
  print('     temperature: 0.7,');
  print('   );');
  print('   ```');

  // Capability checking demonstration
  print('\n3. Capability-Based Design:');

  print('\n   Type-safe capability checking:');
  print('   ```dart');
  print('   if (provider is ChatCapability) {');
  print('     final response = await provider.chat(messages);');
  print('   }');
  print('');
  print('   if (provider is EmbeddingCapability) {');
  print('     final embeddings = await provider.embed(["text"]);');
  print('   }');
  print('');
  print('   if (provider is StreamingCapability) {');
  print('     await for (final event in provider.chatStream(messages)) {');
  print('       // Handle streaming events');
  print('     }');
  print('   }');
  print('   ```');

  // Registry system demonstration
  print('\n4. Provider Registry System:');

  print('\n   Dynamic provider registration:');
  print('   ```dart');
  print('   // Register custom provider');
  print('   LLMProviderRegistry.register(MyCustomProviderFactory());');
  print('');
  print('   // Query available providers');
  print('   final providers = LLMProviderRegistry.getRegisteredProviders();');
  print('');
  print('   // Get provider information');
  print('   final info = LLMProviderRegistry.getProviderInfo("custom");');
  print('   ```');

  // Builder pattern features
  print('\n5. Builder Pattern Features:');

  print('\n   Fluent Configuration:');
  print('   ```dart');
  print('   final provider = await ai()');
  print('       .openai()');
  print('       .apiKey("your-key")');
  print('       .model("gpt-4")');
  print('       .temperature(0.7)');
  print('       .maxTokens(1000)');
  print('       .systemPrompt("You are a helpful assistant")');
  print('       .timeout(Duration(seconds: 30))');
  print('       .build();');
  print('   ```');

  print('\n   Extension System:');
  print('   ```dart');
  print('   final provider = await ai()');
  print('       .openai()');
  print('       .apiKey("your-key")');
  print('       .model("o1-preview")');
  print(
      '       .reasoningEffort(ReasoningEffort.high)        // OpenAI-specific');
  print('       .extension("customParam", value) // Custom extensions');
  print('       .build();');
  print('   ```');

  try {
    // Demonstrate builder creation (without actually building)
    print('\n   ✅ Builder supports all registered providers:');
    for (final providerId in providers.take(3)) {
      print('   - $providerId: ai().provider("$providerId")');
    }
  } catch (e) {
    print('   ❌ Builder demonstration failed: $e');
  }

  print('\n6. Best Practices:');
  print('\n   ✅ Use provider-specific methods for better IDE support');
  print('   ✅ Check capabilities before using advanced features');
  print('   ✅ Leverage extensions for provider-specific parameters');
  print('   ✅ Use the registry system for custom providers');
  print('   ✅ Handle specific error types for better error handling');

  print('\n7. Example Usage Patterns:');
  print('\n   Basic Chat:');
  print('   ```dart');
  print('   final provider = await ai().openai().apiKey("key").build();');
  print(
      '   final response = await provider.chat([ChatMessage.user("Hello")]);');
  print('   ```');

  print('\n   Streaming Chat:');
  print('   ```dart');
  print('   await for (final event in provider.chatStream(messages)) {');
  print('     if (event is TextDeltaEvent) print(event.delta);');
  print('   }');
  print('   ```');

  print('\n   Capability Checking:');
  print('   ```dart');
  print('   if (provider is EmbeddingCapability) {');
  print('     final embeddings = await provider.embed(["text"]);');
  print('   }');
  print('   ```');

  print('\n=== API Features Example Completed ===');
  print('\nKey Benefits of LLM Dart API:');
  print('• 🎯 Type Safety: Compile-time capability checking');
  print('• 🔧 Extensibility: Easy custom provider registration');
  print('• 🧩 Modularity: Interface segregation principle');
  print('• 📦 Consistency: Unified configuration system');
  print('• 🚀 Performance: Optimized for efficiency');
  print('• 🌐 Multi-Provider: Support for 9+ AI providers');
}
