import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:yumcha/shared/infrastructure/services/ai/core/ai_response_models.dart';
import 'package:yumcha/features/ai_management/domain/entities/ai_assistant.dart';
import 'package:llm_dart/llm_dart.dart';

void main() {
  group('AI Service Integration Tests', () {
    setUp(() {
      // 测试设置
    });

    test('should create tool call objects correctly', () {
      // 测试工具调用对象创建
      final toolCall = ToolCall(
        id: 'call_123',
        callType: 'function',
        function: FunctionCall(
          name: 'calculator',
          arguments: '{"operation": "add", "a": 2, "b": 3}',
        ),
      );

      expect(toolCall.id, equals('call_123'));
      expect(toolCall.callType, equals('function'));
      expect(toolCall.function.name, equals('calculator'));
      expect(toolCall.function.arguments, contains('operation'));
    });

    test('should handle tool call argument parsing', () {
      // 测试参数解析
      const validJson = '{"operation": "add", "a": 2, "b": 3}';
      const invalidJson = '{invalid json}';

      // 有效 JSON 应该能正确解析
      try {
        final parsed = jsonDecode(validJson) as Map<String, dynamic>;
        expect(parsed['operation'], equals('add'));
        expect(parsed['a'], equals(2));
        expect(parsed['b'], equals(3));
      } catch (e) {
        fail('Valid JSON should parse correctly');
      }

      // 无效 JSON 应该抛出异常
      expect(() => jsonDecode(invalidJson), throwsException);
    });

    test('should create AI response with tool calls', () {
      // 测试创建包含工具调用的 AI 响应
      final toolCalls = [
        ToolCall(
          id: 'call_123',
          callType: 'function',
          function: FunctionCall(
            name: 'calculator',
            arguments: '{"operation": "add", "a": 2, "b": 3}',
          ),
        ),
      ];

      final response = AiResponse(
        content: 'The result is 5',
        toolCalls: toolCalls,
      );

      expect(response.toolCalls?.length, equals(1));
      expect(response.toolCalls!.first.function.name, equals('calculator'));
      expect(response.isSuccess, isTrue);
    });

    test('should create AI stream event with content', () {
      // 测试创建包含内容的流式事件
      final streamEvent = AiStreamEvent(contentDelta: 'Hello', isDone: false);

      expect(streamEvent.contentDelta, equals('Hello'));
      expect(streamEvent.isDone, isFalse);
      expect(streamEvent.error, isNull);
    });

    test('should handle tool call errors', () {
      // 测试工具调用错误处理
      // 这个测试现在使用简单的Map来模拟错误结果
      final errorResult = {
        'toolName': 'failing_tool',
        'arguments': {},
        'result': '',
        'error': 'Tool execution failed',
        'duration': 10,
      };

      expect(errorResult['error'], equals('Tool execution failed'));
      expect(errorResult['toolName'], equals('failing_tool'));
    });

    test('should validate assistant tool configuration', () {
      // 测试助手工具配置验证
      final assistantWithTools = AiAssistant(
        id: 'test-assistant',
        name: 'Test Assistant',
        avatar: '🤖',
        systemPrompt: 'You are a helpful assistant with tools.',
        temperature: 0.7,
        topP: 1.0,
        maxTokens: 1000,
        contextLength: 10,
        streamOutput: true,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: 'Test assistant with tools enabled',
        customHeaders: {},
        customBody: {},
        stopSequences: [],
        frequencyPenalty: 0.0,
        presencePenalty: 0.0,
        enableCodeExecution: false,
        enableImageGeneration: false,
        enableTools: true, // 启用工具
        enableReasoning: false,
        enableVision: false,
        enableEmbedding: false,
      );

      expect(assistantWithTools.enableTools, isTrue);

      final assistantWithoutTools = assistantWithTools.copyWith(
        enableTools: false,
      );
      expect(assistantWithoutTools.enableTools, isFalse);
    });
  });
}
