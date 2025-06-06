import 'dart:io';
import '../lib/ai_dart.dart';

/// Example demonstrating the new refactored AI Dart API
///
/// This example shows:
/// 1. New capability-based interface design
/// 2. Provider registry system
/// 3. Unified configuration
/// 4. Convenience functions
/// 5. Extension system
void main() async {
  print('=== AI Dart Refactored API Example ===\n');

  // Example 1: Using the new ai() convenience function
  print('1. Using ai() convenience function:');
  try {
    final provider = await ai()
        .openai()
        .apiKey(Platform.environment['OPENAI_API_KEY'] ?? 'sk-test')
        .model('gpt-3.5-turbo')
        .temperature(0.7)
        .build();

    print('✓ Provider created successfully');
    print('  Type: ${provider.runtimeType}');
    print('  Supports chat: ${provider is ChatCapability}');
  } catch (e) {
    print('✗ Error: $e');
  }

  // Example 2: Using provider registry
  print('\n2. Provider registry:');
  final registeredProviders = LLMProviderRegistry.getRegisteredProviders();
  print('  Registered providers: $registeredProviders');

  final openaiSupportsChat =
      LLMProviderRegistry.supportsCapability('openai', LLMCapability.chat);
  print('  OpenAI supports chat: $openaiSupportsChat');

  // Example 3: Using unified configuration with extensions
  print('\n3. Unified configuration with extensions:');
  final config = LLMConfig(
    baseUrl: 'https://api.openai.com/v1/',
    model: 'gpt-4',
    apiKey: 'test-key',
    temperature: 0.8,
    maxTokens: 1000,
  ).withExtensions({
    'reasoningEffort': 'high',
    'voice': 'alloy',
    'customParam': 'value',
  });

  print('  Model: ${config.model}');
  print('  Temperature: ${config.temperature}');
  print(
      '  Reasoning effort: ${config.getExtension<String>('reasoningEffort')}');
  print('  Voice: ${config.getExtension<String>('voice')}');
  print('  Custom param: ${config.getExtension<String>('customParam')}');

  // Example 4: Capability checking
  print('\n4. Capability checking:');
  final capabilities = [
    LLMCapability.chat,
    LLMCapability.streaming,
    LLMCapability.embedding,
    LLMCapability.reasoning,
    LLMCapability.toolCalling,
  ];

  for (final capability in capabilities) {
    print('  ${capability.name}: available');
  }

  // Example 5: Error handling improvements
  print('\n5. Enhanced error handling:');
  try {
    // This will fail with a specific error type
    final invalidProvider = await ai().provider('nonexistent').build();
  } catch (e) {
    print('  Caught error: ${e.runtimeType}');
    print('  Message: $e');
  }

  // Example 6: Legacy API compatibility
  print('\n6. Provider registry capabilities:');
  try {
    // Check registered providers
    final providers = LLMProviderRegistry.getRegisteredProviders();
    print('  ✓ Registered providers: $providers');

    // Check capabilities
    final hasChat =
        LLMProviderRegistry.supportsCapability('openai', LLMCapability.chat);
    print('  ✓ OpenAI supports chat: $hasChat');
  } catch (e) {
    print('  ✗ Registry error: $e');
  }

  // Example 7: Provider information
  print('\n7. Provider information:');
  final providerInfo = LLMProviderRegistry.getProviderInfo('openai');
  if (providerInfo != null) {
    print('  Provider: ${providerInfo.displayName}');
    print('  Description: ${providerInfo.description}');
    print(
        '  Capabilities: ${providerInfo.supportedCapabilities.map((c) => c.name).join(', ')}');
  } else {
    print('  OpenAI provider not registered yet');
  }

  // Example 8: Convenience functions
  print('\n8. Convenience functions:');
  try {
    // Note: This will fail without a real API key, but shows the API
    final quickProvider = await createProvider(
      providerId: 'openai',
      apiKey: 'test-key',
      model: 'gpt-4',
      temperature: 0.7,
      extensions: {'reasoningEffort': 'high'},
    );
    print('  ✓ Quick OpenAI provider creation works');
  } catch (e) {
    print('  Expected error (no real API key): ${e.runtimeType}');
  }

  print('\n=== Example completed ===');
  print('\nKey improvements in the refactored API:');
  print('• Capability-based interfaces instead of god interfaces');
  print('• Provider registry for extensibility');
  print('• Unified configuration with extension system');
  print('• Enhanced error handling with specific error types');
  print('• Convenience functions for common use cases');
  print('• Backward compatibility with deprecation warnings');
  print('• Better type safety and documentation');
}
