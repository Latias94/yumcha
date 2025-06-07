import 'package:test/test.dart';
import 'package:llm_dart/llm_dart.dart';

void main() {
  group('OpenAI Compatible Providers', () {
    test('should register OpenAI-compatible providers', () {
      // Get all registered providers
      final providers = LLMProviderRegistry.getRegisteredProviders();

      // Check that OpenAI-compatible providers are registered
      expect(providers, contains('deepseek-openai'));
      expect(providers, contains('gemini-openai'));
      expect(providers, contains('xai-openai'));
      expect(providers, contains('groq-openai'));
      expect(providers, contains('phind-openai'));
    });

    test('should have correct provider information', () {
      final factory = LLMProviderRegistry.getFactory('deepseek-openai');
      expect(factory, isNotNull);
      expect(factory!.displayName, equals('DeepSeek (OpenAI兼容)'));
      expect(factory.supportedCapabilities, contains(LLMCapability.chat));
      expect(factory.supportedCapabilities, contains(LLMCapability.reasoning));
    });

    test('should have correct default configurations', () {
      final factory = LLMProviderRegistry.getFactory('gemini-openai');
      expect(factory, isNotNull);

      final config = factory!.getDefaultConfig();
      expect(config.baseUrl,
          equals('https://generativelanguage.googleapis.com/v1beta/openai/'));
      expect(config.model, equals('gemini-2.0-flash'));
    });

    test('should support capability checking', () {
      // Test capability checking extension
      expect('deepseek-openai'.supports(LLMCapability.chat), isTrue);
      expect('deepseek-openai'.supports(LLMCapability.reasoning), isTrue);
      expect('deepseek-openai'.supports(LLMCapability.textToSpeech), isFalse);

      expect('gemini-openai'.supports(LLMCapability.embedding), isTrue);
      expect('groq-openai'.supports(LLMCapability.embedding), isFalse);
    });

    test('should create providers with builder methods', () async {
      // Test that builder methods exist and return correct types
      final builder1 = ai().deepseekOpenAI();
      expect(builder1, isA<LLMBuilder>());

      final builder2 = ai().geminiOpenAI();
      expect(builder2, isA<LLMBuilder>());

      final builder3 = ai().xaiOpenAI();
      expect(builder3, isA<LLMBuilder>());
    });

    test('should validate configurations correctly', () {
      final factory = LLMProviderRegistry.getFactory('deepseek-openai');
      expect(factory, isNotNull);

      // Valid config
      final validConfig = LLMConfig(
        apiKey: 'test-key',
        baseUrl: 'https://api.deepseek.com/v1/',
        model: 'deepseek-chat',
      );
      expect(factory!.validateConfig(validConfig), isTrue);

      // Invalid config (no API key)
      final invalidConfig = LLMConfig(
        baseUrl: 'https://api.deepseek.com/v1/',
        model: 'deepseek-chat',
      );
      expect(factory.validateConfig(invalidConfig), isFalse);
    });

    test('should support reasoning effort configuration', () async {
      final builder = ai()
          .geminiOpenAI()
          .apiKey('test-key')
          .model('gemini-2.5-flash-preview-05-20')
          .reasoningEffort(ReasoningEffort.low);

      // This should not throw an error
      expect(() => builder, returnsNormally);
    });

    test('should support structured output configuration', () async {
      final schema = StructuredOutputFormat(
        name: 'test_schema',
        description: 'Test schema',
        schema: {
          'type': 'object',
          'properties': {
            'name': {'type': 'string'},
          },
        },
      );

      final builder = ai()
          .geminiOpenAI()
          .apiKey('test-key')
          .model('gemini-2.0-flash')
          .jsonSchema(schema);

      // This should not throw an error
      expect(() => builder, returnsNormally);
    });

    test('should get OpenAI-compatible configurations', () {
      final configs = OpenAICompatibleConfigs.getAllConfigs();
      expect(configs, isNotEmpty);
      expect(configs.length, equals(5)); // deepseek, gemini, xai, groq, phind

      final deepseekConfig =
          OpenAICompatibleConfigs.getConfig('deepseek-openai');
      expect(deepseekConfig, isNotNull);
      expect(deepseekConfig!.defaultBaseUrl,
          equals('https://api.deepseek.com/v1/'));

      expect(OpenAICompatibleConfigs.isOpenAICompatible('deepseek-openai'),
          isTrue);
      expect(OpenAICompatibleConfigs.isOpenAICompatible('unknown-provider'),
          isFalse);
    });

    test('should get model capabilities', () {
      final capabilities = OpenAICompatibleConfigs.getModelCapabilities(
          'deepseek-openai', 'deepseek-reasoner');

      expect(capabilities, isNotNull);
      expect(capabilities!.supportsReasoning, isTrue);
      expect(capabilities.disableTemperature, isTrue);
      expect(capabilities.disableTopP, isTrue);
    });
  });
}

/// Extension to make capability checking easier (copied from example)
extension ProviderCapabilityExtensions on String {
  bool supports(LLMCapability capability) {
    final factory = LLMProviderRegistry.getFactory(this);
    return factory?.supportedCapabilities.contains(capability) ?? false;
  }
}
