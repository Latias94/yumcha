/// Example comparing old API vs new API
///
/// This example demonstrates the differences between the deprecated API
/// and the new refactored API, showing the improvements in design.

import 'dart:io';
import 'package:llm_dart/llm_dart.dart';

void main() async {
  // ignore_for_file: avoid_print

  print('=== LLM Dart API Comparison Example ===\n');

  // Show available providers
  print('1. Available providers:');
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

  print('\n2. API Comparison:');

  // Old API (deprecated but still works)
  print('\n   OLD API (Deprecated):');
  print('   ```dart');
  print('   final provider = await LLMBuilder()');
  print('       .backend(LLMBackend.openai)  // ❌ Deprecated');
  print('       .apiKey("key")');
  print('       .model("gpt-4")');
  print('       .build();');
  print('   ```');

  // New API options
  print('\n   NEW API (Recommended):');
  print('   ```dart');
  print('   // Method 1: Provider-specific methods');
  print('   final provider1 = await ai()');
  print('       .openai()                    // ✅ Type-safe');
  print('       .apiKey("key")');
  print('       .model("gpt-4")');
  print('       .build();');
  print('');
  print('   // Method 2: Generic provider method');
  print('   final provider2 = await ai()');
  print('       .provider("openai")          // ✅ Extensible');
  print('       .apiKey("key")');
  print('       .model("gpt-4")');
  print('       .build();');
  print('');
  print('   // Method 3: Convenience functions');
  print('   final provider3 = await openai( // ✅ Concise');
  print('     apiKey: "key",');
  print('     model: "gpt-4",');
  print('   );');
  print('   ```');

  print('\n3. New Features:');

  // Capability checking
  print('\n   Capability Checking:');
  for (final providerId in providers) {
    final supportsChat =
        LLMProviderRegistry.supportsCapability(providerId, LLMCapability.chat);
    final supportsStreaming = LLMProviderRegistry.supportsCapability(
        providerId, LLMCapability.streaming);
    final supportsEmbedding = LLMProviderRegistry.supportsCapability(
        providerId, LLMCapability.embedding);

    print('   - $providerId:');
    print('     Chat: ${supportsChat ? "✅" : "❌"}');
    print('     Streaming: ${supportsStreaming ? "✅" : "❌"}');
    print('     Embedding: ${supportsEmbedding ? "✅" : "❌"}');
  }

  // Configuration with extensions
  print('\n   Configuration with Extensions:');
  final config = LLMConfig(
    baseUrl: 'https://api.openai.com/v1/',
    model: 'gpt-4',
    apiKey: 'test-key',
    temperature: 0.7,
    maxTokens: 1000,
  ).withExtensions({
    'reasoningEffort': 'high',
    'voice': 'alloy',
    'customParam': 'value',
  });

  print('   Base config:');
  print('     Model: ${config.model}');
  print('     Temperature: ${config.temperature}');
  print('   Extensions:');
  print(
      '     Reasoning effort: ${config.getExtension<String>('reasoningEffort')}');
  print('     Voice: ${config.getExtension<String>('voice')}');
  print('     Custom param: ${config.getExtension<String>('customParam')}');

  // Error handling improvements
  print('\n   Enhanced Error Handling:');
  print('   - AuthError: Authentication failures');
  print('   - RateLimitError: Rate limiting with retry info');
  print('   - QuotaExceededError: Quota exhaustion');
  print('   - ModelNotAvailableError: Model availability');
  print('   - ProviderError: Provider-specific errors');
  print('   - NetworkError: Network connectivity issues');

  // Builder pattern improvements
  print('\n4. Builder Pattern Improvements:');

  try {
    // Demonstrate the new builder API (will fail without real API key)
    print('\n   Creating provider with new builder...');
    final builder = ai()
        .provider('simple_mock') // Use our mock provider
        .model('test-model')
        .temperature(0.8)
        .maxTokens(500);

    print('   ✅ Builder created successfully');
    print('   Provider ID: simple_mock');
    print('   Model: test-model');
    print('   Temperature: 0.8');
    print('   Max tokens: 500');

    // Try to build (will work if simple_mock is registered)
    try {
      final provider = await builder.build();
      print('   ✅ Provider built successfully: ${provider.runtimeType}');

      // Test capability checking
      if (provider is ChatCapability) {
        print('   ✅ Provider supports chat capability');
      }
    } catch (e) {
      print('   ℹ️  Provider build failed (expected): ${e.runtimeType}');
    }
  } catch (e) {
    print('   ❌ Builder creation failed: $e');
  }

  print('\n5. Migration Guide:');
  print('\n   Step 1: Replace deprecated enums');
  print('   OLD: LLMBackend.openai');
  print('   NEW: "openai" or ai().openai()');

  print('\n   Step 2: Update return types');
  print('   OLD: ChatProvider');
  print('   NEW: ChatCapability');

  print('\n   Step 3: Use capability checking');
  print('   OLD: provider.chat() // May throw if not supported');
  print('   NEW: if (provider is ChatCapability) provider.chat()');

  print('\n   Step 4: Leverage extensions');
  print('   OLD: Provider-specific config classes');
  print('   NEW: Unified config with extensions');

  print('\n=== API Comparison Completed ===');
  print('\nKey Benefits of New API:');
  print('• 🎯 Type Safety: Compile-time capability checking');
  print('• 🔧 Extensibility: Easy custom provider registration');
  print('• 🧩 Modularity: Interface segregation principle');
  print('• 📦 Consistency: Unified configuration system');
  print('• 🚀 Performance: Reduced memory footprint');
  print('• 🔄 Compatibility: Backward compatible with deprecation warnings');
}
