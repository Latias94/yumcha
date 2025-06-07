import 'package:test/test.dart';
import 'package:llm_dart/llm_dart.dart';
import 'package:llm_dart/providers/factories/google_factory.dart';

void main() {
  group('Google GenerationConfig Tests', () {
    test('should support all official GenerationConfig fields', () {
      final config = GoogleConfig(
        apiKey: 'test-key',
        model: 'gemini-1.5-flash',
        // Standard GenerationConfig fields (matching official library)
        candidateCount: 2,
        stopSequences: ['STOP', 'END'],
        maxTokens: 1000, // maps to maxOutputTokens
        temperature: 0.7,
        topP: 0.9,
        topK: 40,
        // JSON schema support
        jsonSchema: StructuredOutputFormat(
          name: 'test_schema',
          schema: {
            'type': 'object',
            'properties': {
              'name': {'type': 'string'},
            },
          },
        ),
        // Extended features
        reasoningEffort: ReasoningEffort.medium,
        thinkingBudgetTokens: 500,
        includeThoughts: true,
        enableImageGeneration: true,
        responseModalities: ['TEXT', 'IMAGE'],
      );

      expect(config.candidateCount, equals(2));
      expect(config.stopSequences, equals(['STOP', 'END']));
      expect(config.maxTokens, equals(1000));
      expect(config.temperature, equals(0.7));
      expect(config.topP, equals(0.9));
      expect(config.topK, equals(40));
      expect(config.jsonSchema, isNotNull);
      expect(config.reasoningEffort, equals(ReasoningEffort.medium));
      expect(config.thinkingBudgetTokens, equals(500));
      expect(config.includeThoughts, isTrue);
      expect(config.enableImageGeneration, isTrue);
      expect(config.responseModalities, equals(['TEXT', 'IMAGE']));
    });

    test('should build correct request body with GenerationConfig', () {
      final provider = GoogleProvider(GoogleConfig(
        apiKey: 'test-key',
        model: 'gemini-1.5-flash',
        candidateCount: 3,
        stopSequences: ['STOP'],
        maxTokens: 500,
        temperature: 0.5,
        topP: 0.8,
        topK: 20,
      ));

      final messages = [ChatMessage.user('Hello')];
      final body = provider.buildRequestBody(messages, null, false);

      expect(body, containsPair('contents', isA<List>()));
      expect(body, containsPair('generationConfig', isA<Map>()));

      final generationConfig = body['generationConfig'] as Map<String, dynamic>;
      expect(generationConfig['candidateCount'], equals(3));
      expect(generationConfig['stopSequences'], equals(['STOP']));
      expect(generationConfig['maxOutputTokens'], equals(500));
      expect(generationConfig['temperature'], equals(0.5));
      expect(generationConfig['topP'], equals(0.8));
      expect(generationConfig['topK'], equals(20));
    });

    test('should handle JSON schema correctly', () {
      final provider = GoogleProvider(GoogleConfig(
        apiKey: 'test-key',
        model: 'gemini-1.5-flash',
        jsonSchema: StructuredOutputFormat(
          name: 'result_schema',
          schema: {
            'type': 'object',
            'properties': {
              'result': {'type': 'string'},
            },
            'additionalProperties': false, // Should be removed
          },
        ),
      ));

      final messages = [ChatMessage.user('Hello')];
      final body = provider.buildRequestBody(messages, null, false);

      final generationConfig = body['generationConfig'] as Map<String, dynamic>;
      expect(generationConfig['responseMimeType'], equals('application/json'));
      expect(generationConfig['responseSchema'], isA<Map>());

      final schema = generationConfig['responseSchema'] as Map<String, dynamic>;
      expect(schema, isNot(contains('additionalProperties')));
      expect(schema['type'], equals('object'));
      expect(schema['properties'], isA<Map>());
    });

    test('should handle thinking configuration', () {
      final provider = GoogleProvider(GoogleConfig(
        apiKey: 'test-key',
        model: 'gemini-2.0-flash-thinking-exp',
        reasoningEffort: ReasoningEffort.high,
        thinkingBudgetTokens: 1000,
        includeThoughts: true,
      ));

      final messages = [ChatMessage.user('Think about this')];
      final body = provider.buildRequestBody(messages, null, false);

      final generationConfig = body['generationConfig'] as Map<String, dynamic>;
      expect(generationConfig['thinkingConfig'], isA<Map>());

      final thinkingConfig =
          generationConfig['thinkingConfig'] as Map<String, dynamic>;
      expect(thinkingConfig['includeThoughts'], isTrue);
      expect(thinkingConfig['thinkingBudget'], equals(1000));
    });

    test('should handle image generation configuration', () {
      final provider = GoogleProvider(GoogleConfig(
        apiKey: 'test-key',
        model: 'gemini-2.0-flash-exp',
        enableImageGeneration: true,
        responseModalities: ['TEXT', 'IMAGE'],
      ));

      final messages = [ChatMessage.user('Generate an image')];
      final body = provider.buildRequestBody(messages, null, false);

      final generationConfig = body['generationConfig'] as Map<String, dynamic>;
      expect(generationConfig['responseModalities'], equals(['TEXT', 'IMAGE']));
      expect(generationConfig['responseMimeType'], equals('text/plain'));
    });

    test('should use factory with extensions', () {
      final config = LLMConfig(
        apiKey: 'test-key',
        baseUrl: 'https://generativelanguage.googleapis.com/v1beta/',
        model: 'gemini-1.5-flash',
        maxTokens: 800,
        temperature: 0.6,
        extensions: {
          'candidateCount': 2,
          'stopSequences': ['END'],
          'reasoning': true,
          'thinkingBudgetTokens': 600,
        },
      );

      final factory = GoogleProviderFactory();
      final provider = factory.create(config) as GoogleProvider;

      expect(provider.config.candidateCount, equals(2));
      expect(provider.config.stopSequences, equals(['END']));
      expect(provider.config.includeThoughts, isTrue); // Set by reasoning: true
      expect(provider.config.thinkingBudgetTokens, equals(600));
    });

    test('copyWith should work with new fields', () {
      final original = GoogleConfig(
        apiKey: 'test-key',
        model: 'gemini-1.5-flash',
        candidateCount: 1,
        stopSequences: ['STOP'],
      );

      final updated = original.copyWith(
        candidateCount: 3,
        stopSequences: ['END', 'FINISH'],
        temperature: 0.8,
      );

      expect(updated.candidateCount, equals(3));
      expect(updated.stopSequences, equals(['END', 'FINISH']));
      expect(updated.temperature, equals(0.8));
      expect(updated.apiKey, equals('test-key')); // Unchanged
      expect(updated.model, equals('gemini-1.5-flash')); // Unchanged
    });
  });
}
