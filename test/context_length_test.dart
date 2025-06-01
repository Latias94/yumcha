import 'package:flutter_test/flutter_test.dart';
import 'package:yumcha/models/ai_assistant.dart';

void main() {
  group('Context Length Tests', () {
    test('should handle context length 0 (unlimited)', () {
      final now = DateTime.now();
      final assistant = AiAssistant(
        id: 'test',
        name: 'Test Assistant',
        description: 'Test',
        systemPrompt: 'Test prompt',
        providerId: 'test-provider',
        modelName: 'test-model',
        contextLength: 0, // 无限制
        createdAt: now,
        updatedAt: now,
      );

      expect(assistant.isContextLengthValid, true);
      expect(assistant.contextLength, 0);
    });

    test('should handle context length 1-256', () {
      final now = DateTime.now();
      
      // 测试最小值
      final assistant1 = AiAssistant(
        id: 'test1',
        name: 'Test Assistant 1',
        description: 'Test',
        systemPrompt: 'Test prompt',
        providerId: 'test-provider',
        modelName: 'test-model',
        contextLength: 1,
        createdAt: now,
        updatedAt: now,
      );

      expect(assistant1.isContextLengthValid, true);

      // 测试最大值
      final assistant256 = AiAssistant(
        id: 'test256',
        name: 'Test Assistant 256',
        description: 'Test',
        systemPrompt: 'Test prompt',
        providerId: 'test-provider',
        modelName: 'test-model',
        contextLength: 256,
        createdAt: now,
        updatedAt: now,
      );

      expect(assistant256.isContextLengthValid, true);

      // 测试中间值
      final assistant32 = AiAssistant(
        id: 'test32',
        name: 'Test Assistant 32',
        description: 'Test',
        systemPrompt: 'Test prompt',
        providerId: 'test-provider',
        modelName: 'test-model',
        contextLength: 32,
        createdAt: now,
        updatedAt: now,
      );

      expect(assistant32.isContextLengthValid, true);
    });

    test('should reject invalid context lengths', () {
      final now = DateTime.now();
      
      // 测试负值
      final assistantNegative = AiAssistant(
        id: 'test-neg',
        name: 'Test Assistant Negative',
        description: 'Test',
        systemPrompt: 'Test prompt',
        providerId: 'test-provider',
        modelName: 'test-model',
        contextLength: -1,
        createdAt: now,
        updatedAt: now,
      );

      expect(assistantNegative.isContextLengthValid, false);

      // 测试超过最大值
      final assistantTooLarge = AiAssistant(
        id: 'test-large',
        name: 'Test Assistant Large',
        description: 'Test',
        systemPrompt: 'Test prompt',
        providerId: 'test-provider',
        modelName: 'test-model',
        contextLength: 257,
        createdAt: now,
        updatedAt: now,
      );

      expect(assistantTooLarge.isContextLengthValid, false);
    });
  });
}
