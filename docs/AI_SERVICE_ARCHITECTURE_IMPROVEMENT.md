# AI Service 架构改进

## 概述

根据你的建议，我们对 AI Service 的架构进行了重要改进，使其遵循 Riverpod 的最佳实践，使用 `ai_provider_notifier.dart` 来管理 AI 提供商状态，而不是直接访问数据库。

## 改进内容

### 1. 修改了 `ai_service.dart`

#### 添加了详细的日志记录
在 `buildChatOptions` 方法中添加了详细的参数打印：

```dart
/// 构建 AI 聊天选项
genai.AiChatOptions buildChatOptions(
  models.AiProvider provider,
  AiAssistant assistant,
  String modelName,
) {
  // 打印输入参数
  _logger.info('🔧 buildChatOptions 输入参数', {
    'provider': {
      'id': provider.id,
      'name': provider.name,
      'type': provider.type.name,
      'baseUrl': provider.baseUrl,
      'apiKeyPrefix': provider.apiKey.isNotEmpty
          ? provider.apiKey.length > 8
              ? '${provider.apiKey.substring(0, 8)}...'
              : '${provider.apiKey}...'
          : '未设置',
    },
    'assistant': {
      'id': assistant.id,
      'name': assistant.name,
      'temperature': assistant.temperature,
      'topP': assistant.topP,
      'maxTokens': assistant.maxTokens,
      'contextLength': assistant.contextLength,
      'systemPromptLength': assistant.systemPrompt.length,
      'stopSequencesCount': assistant.stopSequences.length,
    },
    'modelName': modelName,
  });

  // ... 构建选项 ...

  // 打印构建的选项
  _logger.info('✅ buildChatOptions 构建结果', {
    'options': {
      'model': options.model,
      'baseUrl': options.baseUrl,
      'apiKeyPrefix': options.apiKey.isNotEmpty
          ? options.apiKey.length > 8
              ? '${options.apiKey.substring(0, 8)}...'
              : '${options.apiKey}...'
          : '未设置',
      'temperature': options.temperature,
      'topP': options.topP,
      'maxTokens': options.maxTokens,
      'systemPrompt': options.systemPrompt != null
          ? '${options.systemPrompt!.length} 字符'
          : null,
      'stopSequences': options.stopSequences?.length,
    },
  });

  return options;
}
```

#### 修改了标题生成方法
将 `generateChatTitle` 方法从接受 `providerId` 改为接受 `AiProvider` 对象：

```dart
/// 生成聊天标题
Future<String?> generateChatTitle({
  required AiProvider provider,  // 改为接受提供商对象
  required String modelName,
  required List<Message> messages,
  String? customPrompt,
}) async {
  // ... 实现 ...
}
```

### 2. 修改了 `conversation_notifier.dart`

#### 添加了 Ref 参数
修改 `CurrentConversationNotifier` 构造函数来接受 `Ref` 参数：

```dart
class CurrentConversationNotifier extends StateNotifier<CurrentConversationState> {
  CurrentConversationNotifier(this.ref) : super(const CurrentConversationState()) {
    _initialize();
  }

  final Ref ref;
  // ...
}
```

#### 使用 AI Provider Notifier
在 `_generateTitleAsync` 方法中使用 `ai_provider_notifier.dart` 获取提供商：

```dart
// 通过 provider notifier 获取提供商对象
final provider = ref.read(aiProviderProvider(providerId));
if (provider == null) {
  _logger.warning('无法获取提供商信息，无法生成标题', {'providerId': providerId});
  return;
}

// 调用 AI 服务生成标题
final generatedTitle = await _aiService.generateChatTitle(
  provider: provider,  // 传递提供商对象
  modelName: modelId,
  messages: conversation.messages,
);
```

#### 更新了 Provider 创建
```dart
final currentConversationProvider =
    StateNotifierProvider<
      CurrentConversationNotifier,
      CurrentConversationState
    >((ref) => CurrentConversationNotifier(ref));  // 传递 ref
```

## 架构优势

### 1. 遵循 Riverpod 最佳实践
- 使用 `ai_provider_notifier.dart` 作为单一数据源
- 避免直接访问数据库，减少耦合
- 利用 Riverpod 的响应式特性

### 2. 更好的状态管理
- 提供商状态变化会自动反映到所有依赖的组件
- 统一的错误处理和加载状态
- 更好的缓存和性能优化

### 3. 增强的调试能力
- 详细的参数日志记录
- 更好的错误追踪
- 清晰的数据流向

### 4. 更好的可测试性
- 依赖注入使得单元测试更容易
- 模拟 provider 状态更简单
- 更清晰的组件边界

## 使用示例

### 在 Widget 中使用
```dart
class ChatWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取提供商
    final provider = ref.watch(aiProviderProvider('openai-default'));
    
    if (provider != null) {
      // 使用提供商进行标题生成
      final aiService = AiService();
      final title = await aiService.generateChatTitle(
        provider: provider,
        modelName: 'gpt-3.5-turbo',
        messages: messages,
      );
    }
    
    return Container();
  }
}
```

### 在 Notifier 中使用
```dart
class MyNotifier extends StateNotifier<MyState> {
  MyNotifier(this.ref) : super(MyState());
  
  final Ref ref;
  
  Future<void> generateTitle() async {
    final provider = ref.read(aiProviderProvider('openai-default'));
    if (provider != null) {
      final aiService = AiService();
      final title = await aiService.generateChatTitle(
        provider: provider,
        modelName: 'gpt-3.5-turbo',
        messages: messages,
      );
    }
  }
}
```

## 迁移指南

### 对于现有代码
如果你有现有的代码直接调用 `generateChatTitle` 方法，需要进行以下修改：

#### 之前：
```dart
final title = await aiService.generateChatTitle(
  providerId: 'openai-default',
  modelName: 'gpt-3.5-turbo',
  messages: messages,
);
```

#### 现在：
```dart
// 在 ConsumerWidget 或 Notifier 中
final provider = ref.read(aiProviderProvider('openai-default'));
if (provider != null) {
  final title = await aiService.generateChatTitle(
    provider: provider,
    modelName: 'gpt-3.5-turbo',
    messages: messages,
  );
}
```

## 总结

这次架构改进使得 AI Service 更好地集成到 Riverpod 生态系统中，提供了：

- ✅ 更好的状态管理
- ✅ 详细的调试日志
- ✅ 遵循最佳实践
- ✅ 更好的可测试性
- ✅ 减少了直接数据库访问
- ✅ 统一的错误处理

这些改进为后续的功能开发和维护奠定了坚实的基础。
