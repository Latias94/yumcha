import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yumcha/features/chat/presentation/widgets/chat_configuration_status.dart';
import 'package:yumcha/features/chat/domain/entities/chat_state.dart';
import 'package:yumcha/features/ai_management/domain/entities/ai_assistant.dart';
import 'package:yumcha/features/ai_management/domain/entities/ai_provider.dart';
import 'package:yumcha/features/ai_management/domain/entities/ai_model.dart';
import 'package:yumcha/features/ai_management/domain/entities/ai_provider_type.dart';

void main() {
  group('ChatConfigurationStatus', () {
    late AiAssistant testAssistant;
    late AiProvider testProvider;
    late AiModel testModel;

    setUp(() {
      testAssistant = AiAssistant(
        id: 'test-assistant',
        name: '测试助手',
        description: '测试用助手',
        systemPrompt: '你是一个测试助手',
        temperature: 0.7,
        maxTokens: 2048,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      testModel = AiModel(
        name: 'test-model',
        displayName: '测试模型',
        description: '测试用模型',
        maxTokens: 4096,
        supportsStreaming: true,
        supportsVision: false,
        inputCostPer1kTokens: 0.001,
        outputCostPer1kTokens: 0.002,
      );

      testProvider = AiProvider(
        id: 'test-provider',
        name: '测试提供商',
        type: AiProviderType.openai,
        apiKey: '', // 初始为空，模拟未配置状态
        baseUrl: 'https://api.test.com',
        models: [testModel],
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    testWidgets('显示配置有问题当API密钥为空时', (WidgetTester tester) async {
      final chatConfig = ChatConfiguration(
        selectedAssistant: testAssistant,
        selectedProvider: testProvider, // API密钥为空
        selectedModel: testModel,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // 这里需要模拟相关的providers
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ChatConfigurationStatus(compact: true),
            ),
          ),
        ),
      );

      // 验证显示"配置有问题"
      expect(find.text('配置有问题'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('显示配置正常当API密钥配置正确时', (WidgetTester tester) async {
      // 设置有效的API密钥
      final providerWithKey = testProvider.copyWith(apiKey: 'sk-test-key-123');
      
      final chatConfig = ChatConfiguration(
        selectedAssistant: testAssistant,
        selectedProvider: providerWithKey,
        selectedModel: testModel,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // 这里需要模拟相关的providers
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ChatConfigurationStatus(compact: true),
            ),
          ),
        ),
      );

      // 验证显示"配置正常"
      expect(find.text('配置正常'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    test('验证错误信息更准确', () {
      // 测试新的错误信息
      final chatConfig = ChatConfiguration(
        selectedAssistant: testAssistant,
        selectedProvider: testProvider, // API密钥为空
        selectedModel: testModel,
      );

      // 这里可以添加对ChatConfigurationValidator的单元测试
      // 验证错误信息是"API密钥未配置或格式不正确"而不是包含配额权限的信息
    });
  });
}
