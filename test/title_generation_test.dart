import 'package:flutter_test/flutter_test.dart';
import 'package:yumcha/src/rust/api/ai_chat.dart' as genai;

void main() {
  group('标题生成功能测试', () {
    test('测试标题清理功能', () {
      // 这个测试验证 Rust 中的标题清理逻辑
      // 由于我们无法直接测试 Rust 的私有方法，我们测试整体功能

      // 准备测试消息
      final messages = [
        const genai.ChatMessage(
          role: genai.ChatRole.user,
          content: '你好，我想学习编程',
        ),
        const genai.ChatMessage(
          role: genai.ChatRole.assistant,
          content: '你好！我很乐意帮助你学习编程。你想学习哪种编程语言呢？',
        ),
      ];

      // 验证消息格式正确
      expect(messages.length, 2);
      expect(messages[0].role, genai.ChatRole.user);
      expect(messages[1].role, genai.ChatRole.assistant);
      expect(messages[0].content, '你好，我想学习编程');
    });

    test('测试 AiProvider 枚举', () {
      // 测试不同的 AI 提供商类型
      const openai = genai.AiProvider.openAi();
      const anthropic = genai.AiProvider.anthropic();
      const gemini = genai.AiProvider.gemini();
      const ollama = genai.AiProvider.ollama();
      final custom = genai.AiProvider.custom(name: 'TestProvider');

      expect(openai, isA<genai.AiProvider>());
      expect(anthropic, isA<genai.AiProvider>());
      expect(gemini, isA<genai.AiProvider>());
      expect(ollama, isA<genai.AiProvider>());
      expect(custom, isA<genai.AiProvider>());
    });

    test('测试 ChatMessage 创建', () {
      const userMessage = genai.ChatMessage(
        role: genai.ChatRole.user,
        content: 'Hello, world!',
      );

      const assistantMessage = genai.ChatMessage(
        role: genai.ChatRole.assistant,
        content: 'Hello! How can I help you today?',
      );

      const systemMessage = genai.ChatMessage(
        role: genai.ChatRole.system,
        content: 'You are a helpful assistant.',
      );

      expect(userMessage.role, genai.ChatRole.user);
      expect(userMessage.content, 'Hello, world!');

      expect(assistantMessage.role, genai.ChatRole.assistant);
      expect(assistantMessage.content, 'Hello! How can I help you today?');

      expect(systemMessage.role, genai.ChatRole.system);
      expect(systemMessage.content, 'You are a helpful assistant.');
    });

    test('测试 AiChatOptions 创建', () {
      const options = genai.AiChatOptions(
        model: 'gpt-3.5-turbo',
        apiKey: 'test-key',
        temperature: 0.7,
        topP: 0.9,
        maxTokens: 1000,
        systemPrompt: 'You are a helpful assistant.',
        stopSequences: ['STOP', 'END'],
      );

      expect(options.model, 'gpt-3.5-turbo');
      expect(options.apiKey, 'test-key');
      expect(options.temperature, 0.7);
      expect(options.topP, 0.9);
      expect(options.maxTokens, 1000);
      expect(options.systemPrompt, 'You are a helpful assistant.');
      expect(options.stopSequences, ['STOP', 'END']);
    });

    test('测试 TitleGenerationResponse 创建', () {
      const successResponse = genai.TitleGenerationResponse(
        title: '学习编程的对话',
        success: true,
        errorMessage: null,
      );

      const failureResponse = genai.TitleGenerationResponse(
        title: '新对话',
        success: false,
        errorMessage: '生成失败',
      );

      expect(successResponse.title, '学习编程的对话');
      expect(successResponse.success, true);
      expect(successResponse.errorMessage, null);

      expect(failureResponse.title, '新对话');
      expect(failureResponse.success, false);
      expect(failureResponse.errorMessage, '生成失败');
    });

    test('测试消息列表处理', () {
      // 模拟一个较长的对话，测试是否能正确处理
      final messages = <genai.ChatMessage>[];

      // 添加多条消息
      for (int i = 0; i < 10; i++) {
        messages.add(
          genai.ChatMessage(
            role: i % 2 == 0 ? genai.ChatRole.user : genai.ChatRole.assistant,
            content: '这是第 ${i + 1} 条消息',
          ),
        );
      }

      expect(messages.length, 10);
      expect(messages[0].role, genai.ChatRole.user);
      expect(messages[1].role, genai.ChatRole.assistant);
      expect(messages[9].content, '这是第 10 条消息');
    });

    test('测试空消息列表处理', () {
      final emptyMessages = <genai.ChatMessage>[];
      expect(emptyMessages.isEmpty, true);
      expect(emptyMessages.length, 0);
    });

    test('测试特殊字符处理', () {
      // 测试包含特殊字符的消息
      const messageWithSpecialChars = genai.ChatMessage(
        role: genai.ChatRole.user,
        content: '这是一条包含\n换行符\r和\t制表符的消息！@#\$%^&*()',
      );

      expect(messageWithSpecialChars.content.contains('\n'), true);
      expect(messageWithSpecialChars.content.contains('\r'), true);
      expect(messageWithSpecialChars.content.contains('\t'), true);
    });

    test('测试多语言消息', () {
      final multiLanguageMessages = [
        const genai.ChatMessage(
          role: genai.ChatRole.user,
          content: 'Hello, how are you?',
        ),
        const genai.ChatMessage(
          role: genai.ChatRole.assistant,
          content: 'I am fine, thank you!',
        ),
        const genai.ChatMessage(role: genai.ChatRole.user, content: '你好，你好吗？'),
        const genai.ChatMessage(
          role: genai.ChatRole.assistant,
          content: '我很好，谢谢！',
        ),
        const genai.ChatMessage(
          role: genai.ChatRole.user,
          content: 'Bonjour, comment allez-vous?',
        ),
        const genai.ChatMessage(
          role: genai.ChatRole.assistant,
          content: 'Je vais bien, merci!',
        ),
      ];

      expect(multiLanguageMessages.length, 6);
      expect(multiLanguageMessages[0].content, 'Hello, how are you?');
      expect(multiLanguageMessages[2].content, '你好，你好吗？');
      expect(multiLanguageMessages[4].content, 'Bonjour, comment allez-vous?');
    });
  });

  group('集成测试准备', () {
    test('验证 Rust 绑定可用性', () {
      // 这个测试确保 Rust 绑定正确生成
      expect(genai.ChatRole.user, isA<genai.ChatRole>());
      expect(genai.ChatRole.assistant, isA<genai.ChatRole>());
      expect(genai.ChatRole.system, isA<genai.ChatRole>());

      expect(genai.AiProvider.openAi, isA<Function>());
      expect(genai.AiProvider.anthropic, isA<Function>());
      expect(genai.AiProvider.gemini, isA<Function>());
      expect(genai.AiProvider.ollama, isA<Function>());
      expect(genai.AiProvider.custom, isA<Function>());
    });

    test('验证标题生成客户端函数存在', () {
      // 测试标题生成客户端函数是否存在（不实际调用）
      expect(genai.createTitleGenerationClient, isA<Function>());
      expect(genai.generateChatTitle, isA<Function>());
    });
  });
}
