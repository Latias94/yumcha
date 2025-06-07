import 'package:test/test.dart';
import '../lib/llm_dart.dart';

void main() {
  group('Refactored LLM Dart Tests', () {
    test('LLMBuilder should create instance', () {
      final builder = LLMBuilder();
      expect(builder, isNotNull);
    });

    test('ai() convenience function should work', () {
      final builder = ai();
      expect(builder, isNotNull);
      expect(builder, isA<LLMBuilder>());
    });

    test('LLMBuilder should support provider method', () {
      final builder = LLMBuilder().provider('openai');
      expect(builder, isNotNull);
    });

    test('LLMBuilder should support convenience methods', () {
      final builder = LLMBuilder()
          .openai()
          .apiKey('test-key')
          .model('gpt-4')
          .temperature(0.7);
      expect(builder, isNotNull);
    });

    test('LLMConfig should work with extensions', () {
      final config = LLMConfig(
        baseUrl: 'https://api.openai.com/v1/',
        model: 'gpt-4',
        apiKey: 'test-key',
      );

      final configWithExtension =
          config.withExtension('reasoningEffort', 'high');
      expect(configWithExtension.getExtension<String>('reasoningEffort'),
          equals('high'));
    });

    test('LLMProviderRegistry should be accessible', () {
      final providers = LLMProviderRegistry.getRegisteredProviders();
      expect(providers, isA<List<String>>());
    });

    test('Error types should be available', () {
      const authError = AuthError('test');
      const rateLimitError = RateLimitError('test');
      const quotaError = QuotaExceededError('test');

      expect(authError, isA<LLMError>());
      expect(rateLimitError, isA<LLMError>());
      expect(quotaError, isA<LLMError>());
    });

    test('Capability enums should be available', () {
      expect(LLMCapability.chat, isNotNull);
      expect(LLMCapability.streaming, isNotNull);
      expect(LLMCapability.embedding, isNotNull);
      expect(LLMCapability.reasoning, isNotNull);
    });

    test('Provider registry should work', () {
      // Test provider registry functionality
      final providers = LLMProviderRegistry.getRegisteredProviders();
      expect(providers, isA<List<String>>());
      expect(providers, contains('openai'));
    });
  });
}
