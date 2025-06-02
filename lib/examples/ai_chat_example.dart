import '../src/rust/api/ai_chat.dart';

/// AI聊天功能使用示例
class AiChatExample {
  /// 基本聊天示例
  static Future<void> basicChatExample() async {
    // 创建AI聊天客户端配置
    final options = AiChatOptions(
      model: "gpt-4",
      apiKey: "your-api-key-here",
      temperature: 0.7,
      topP: 0.9,
      maxTokens: 1000,
      systemPrompt: "你是一个乐于助人的AI助手。",
    );

    // 创建客户端
    final client = AiChatClient(
      provider: const AiProvider.openAi(),
      options: options,
    );

    // 准备消息
    final messages = [
      const ChatMessage(role: ChatRole.user, content: "你好，请介绍一下你自己。"),
    ];

    try {
      // 发送聊天请求
      final response = await client.chat(messages: messages);
      print("AI回复: ${response.content}");
      print("使用的模型: ${response.model}");

      if (response.usage != null) {
        print("Token使用情况:");
        print("  提示词tokens: ${response.usage!.promptTokens}");
        print("  回复tokens: ${response.usage!.completionTokens}");
        print("  总tokens: ${response.usage!.totalTokens}");
      }
    } catch (e) {
      print("聊天错误: $e");
    }
  }

  /// 流式聊天示例
  static Future<void> streamChatExample() async {
    final options = AiChatOptions(
      model: "gpt-4",
      apiKey: "your-api-key-here",
      temperature: 0.7,
    );

    final client = AiChatClient(
      provider: const AiProvider.openAi(),
      options: options,
    );

    final messages = [
      const ChatMessage(role: ChatRole.user, content: "请详细解释什么是人工智能。"),
    ];

    try {
      print("开始流式聊天...");

      final stream = client.chatStream(messages: messages);
      await for (final event in stream) {
        switch (event) {
          case ChatStreamEvent_Start():
            print("🟢 开始接收响应");
            break;
          case ChatStreamEvent_Content(:final content):
            print("📝 $content");
            break;
          case ChatStreamEvent_Done(:final totalContent, :final usage):
            print("\n✅ 完成！");
            print("完整回复: $totalContent");
            if (usage != null) {
              print("Token使用: ${usage.totalTokens}");
            }
            break;
          case ChatStreamEvent_Error(:final message):
            print("❌ 错误: $message");
            break;
        }
      }
    } catch (e) {
      print("流式聊天错误: $e");
    }
  }

  /// 多轮对话示例
  static Future<void> multiTurnChatExample() async {
    final options = AiChatOptions(
      model: "gpt-4",
      apiKey: "your-api-key-here",
      temperature: 0.7,
      systemPrompt: "你是一个专业的编程助手，擅长Flutter和Dart开发。",
    );

    final client = AiChatClient(
      provider: const AiProvider.openAi(),
      options: options,
    );

    // 模拟多轮对话
    final conversations = [
      "什么是Flutter？",
      "Flutter的主要优势是什么？",
      "如何在Flutter中实现网络请求？",
    ];

    final chatHistory = <ChatMessage>[];

    for (final userInput in conversations) {
      print("\n👤 用户: $userInput");

      // 添加用户消息到历史记录
      chatHistory.add(ChatMessage(role: ChatRole.user, content: userInput));

      try {
        // 发送聊天请求
        final response = await client.chat(messages: chatHistory);
        print("🤖 AI: ${response.content}");

        // 添加AI回复到历史记录
        chatHistory.add(
          ChatMessage(role: ChatRole.assistant, content: response.content),
        );
      } catch (e) {
        print("❌ 错误: $e");
        break;
      }
    }
  }

  /// 不同AI提供商示例
  static Future<void> differentProvidersExample() async {
    final providers = [
      (const AiProvider.openAi(), "gpt-4", "OPENAI_API_KEY"),
      (
        const AiProvider.anthropic(),
        "claude-3-haiku-20240307",
        "ANTHROPIC_API_KEY",
      ),
      (const AiProvider.gemini(), "gemini-2.0-flash", "GEMINI_API_KEY"),
      (const AiProvider.groq(), "llama-3.1-8b-instant", "GROQ_API_KEY"),
    ];

    const question = "请用一句话解释什么是递归。";

    for (final (provider, model, envKey) in providers) {
      print("\n🔄 测试提供商: $provider, 模型: $model");

      final options = AiChatOptions(
        model: model,
        apiKey: "your-$envKey-here", // 实际使用时从环境变量获取
        temperature: 0.7,
      );

      final client = AiChatClient(provider: provider, options: options);

      try {
        final response = await client.chat(
          messages: [const ChatMessage(role: ChatRole.user, content: question)],
        );
        print("✅ 回复: ${response.content}");
      } catch (e) {
        print("❌ 错误: $e");
      }
    }
  }

  /// 自定义服务器示例（例如本地部署的模型）
  static Future<void> customServerExample() async {
    final options = AiChatOptions(
      model: "llama-3.1-8b",
      baseUrl: "http://localhost:11434/v1", // Ollama本地服务器
      apiKey: "not-needed-for-ollama", // Ollama通常不需要API密钥
      temperature: 0.8,
      maxTokens: 500,
    );

    final client = AiChatClient(
      provider: const AiProvider.ollama(),
      options: options,
    );

    try {
      final response = await client.chat(
        messages: [
          const ChatMessage(
            role: ChatRole.user,
            content: "Hello, how are you today?",
          ),
        ],
      );
      print("本地AI回复: ${response.content}");
    } catch (e) {
      print("本地AI聊天错误: $e");
    }
  }

  /// 测试流式聊天功能
  static Future<void> testStreamExample() async {
    print("🧪 测试流式功能...");

    try {
      final stream = testStream();
      await for (final event in stream) {
        switch (event) {
          case ChatStreamEvent_Start():
            print("🟢 测试开始");
            break;
          case ChatStreamEvent_Content(:final content):
            print("📝 $content");
            break;
          case ChatStreamEvent_Done(:final totalContent, :final usage):
            print("✅ 测试完成");
            print("完整内容: $totalContent");
            if (usage != null) {
              print("模拟Token使用: ${usage.totalTokens}");
            }
            break;
          case ChatStreamEvent_Error(:final message):
            print("❌ 测试错误: $message");
            break;
        }
      }
    } catch (e) {
      print("测试流式功能错误: $e");
    }
  }
}

/// AI聊天配置工具类
class AiChatConfigHelper {
  /// 为OpenAI创建配置
  static AiChatOptions openAiConfig({
    required String apiKey,
    String model = "gpt-4",
    double temperature = 0.7,
    String? systemPrompt,
  }) {
    return AiChatOptions(
      model: model,
      apiKey: apiKey,
      temperature: temperature,
      systemPrompt: systemPrompt,
    );
  }

  /// 为Anthropic创建配置
  static AiChatOptions anthropicConfig({
    required String apiKey,
    String model = "claude-3-haiku-20240307",
    double temperature = 0.7,
    String? systemPrompt,
  }) {
    return AiChatOptions(
      model: model,
      apiKey: apiKey,
      temperature: temperature,
      systemPrompt: systemPrompt,
    );
  }

  /// 为本地Ollama创建配置
  static AiChatOptions ollamaConfig({
    required String model,
    String baseUrl = "http://localhost:11434/v1",
    double temperature = 0.8,
    String? systemPrompt,
  }) {
    return AiChatOptions(
      model: model,
      baseUrl: baseUrl,
      apiKey: "ollama-not-needed",
      temperature: temperature,
      systemPrompt: systemPrompt,
    );
  }
}
