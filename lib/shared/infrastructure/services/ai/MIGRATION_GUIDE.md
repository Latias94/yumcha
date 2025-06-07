# AI服务重构迁移指南

## 概述

AI服务已经重构为模块化架构，提供更好的可维护性、可扩展性和Riverpod集成。

## 新的架构

### 文件结构
```
services/ai/
├── core/
│   ├── ai_service_base.dart          # AI服务基类和通用接口
│   ├── ai_response_models.dart       # 统一的响应模型
│   └── ai_capability_detector.dart   # 能力检测器（未来）
├── chat/
│   ├── chat_service.dart             # 聊天服务核心
│   └── chat_stream_service.dart      # 流式聊天服务（未来）
├── capabilities/
│   ├── model_service.dart            # 模型管理服务
│   ├── embedding_service.dart        # 嵌入服务
│   ├── speech_service.dart           # 语音服务（TTS/STT）
│   └── image_service.dart            # 图像服务（未来扩展）
├── providers/
│   ├── ai_service_provider.dart      # Riverpod AI服务提供者
│   └── ai_capability_provider.dart   # AI能力提供者（未来）
└── ai_service_manager.dart           # AI服务管理器
```

### 核心概念

1. **AiServiceManager**: 统一管理所有AI服务的中央管理器
2. **模块化服务**: 每个AI能力（聊天、模型、嵌入、语音等）都有独立的服务
3. **Riverpod集成**: 完全集成Riverpod状态管理，避免直接访问repositories
4. **概念分离**: 助手（AI参数）和提供商（服务配置）完全分离
5. **能力检测**: 从AiModel获取能力信息，而不是硬编码推断

## 迁移步骤

### 1. 更新导入

**旧代码:**
```dart
import '../../../../services/services/ai_service.dart';
import '../../../../services/services/ai_request_service.dart';
import '../../../../services/services/llm_dart_service.dart';
```

**新代码:**
```dart
import '../../../../services/services/ai/ai_service_manager.dart';
import '../../../../services/services/ai/providers/ai_service_provider.dart';
import '../../../../services/services/ai/core/ai_response_models.dart';
```

### 2. 使用新的Riverpod Providers

**旧代码:**
```dart
final aiService = AiService();
final response = await aiService.sendMessage(
  assistantId: assistantId,
  chatHistory: chatHistory,
  userMessage: userMessage,
  selectedProviderId: providerId,
  selectedModelName: modelName,
);
```

**新代码:**
```dart
// 方式1: 使用Provider
final response = await ref.read(sendChatMessageProvider(
  SendChatMessageParams(
    provider: provider,
    assistant: assistant,
    modelName: modelName,
    chatHistory: chatHistory,
    userMessage: userMessage,
  ),
).future);

// 方式2: 使用智能聊天（自动使用默认配置）
final response = await ref.read(smartChatProvider(
  SmartChatParams(
    chatHistory: chatHistory,
    userMessage: userMessage,
  ),
).future);

// 方式3: 直接使用服务管理器
final serviceManager = ref.read(aiServiceManagerProvider);
final response = await serviceManager.sendMessage(
  provider: provider,
  assistant: assistant,
  modelName: modelName,
  chatHistory: chatHistory,
  userMessage: userMessage,
);
```

### 3. 流式聊天迁移

**旧代码:**
```dart
await for (final event in aiService.sendMessageStream(...)) {
  if (event.isContent) {
    // 处理内容
  }
}
```

**新代码:**
```dart
// 使用Provider
ref.listen(sendChatMessageStreamProvider(params), (previous, next) {
  next.when(
    data: (event) {
      if (event.isContent) {
        // 处理内容
      }
    },
    loading: () => {/* 加载状态 */},
    error: (error, stack) => {/* 错误处理 */},
  );
});

// 或者使用智能流式聊天
ref.listen(smartChatStreamProvider(params), (previous, next) {
  // 处理事件
});
```

### 4. 模型列表获取

**旧代码:**
```dart
final models = await aiService.getModelsFromProvider(providerId);
```

**新代码:**
```dart
final models = await ref.read(providerModelsProvider(providerId).future);
```

### 5. 提供商测试

**旧代码:**
```dart
final isWorking = await aiService.testProvider(providerId: providerId);
```

**新代码:**
```dart
final isWorking = await ref.read(testAiProviderProvider(
  TestProviderParams(provider: provider, modelName: modelName),
).future);
```

## 新功能

### 1. 嵌入服务
```dart
final embeddingService = ref.read(aiServiceManagerProvider).embeddingService;
final embeddings = await embeddingService.generateEmbeddings(
  provider: provider,
  texts: ['Hello', 'World'],
);
```

### 2. 语音服务
```dart
final speechService = ref.read(aiServiceManagerProvider).speechService;

// TTS
final audioData = await speechService.textToSpeech(
  provider: provider,
  text: 'Hello, world!',
  voice: 'alloy',
);

// STT
final transcription = await speechService.speechToText(
  provider: provider,
  audioData: audioData,
);
```

### 3. 能力检测
```dart
final capabilities = ref.read(modelCapabilitiesProvider(
  ModelCapabilityParams(provider: provider, modelName: modelName),
));

if (capabilities.contains('vision')) {
  // 支持视觉功能
}
```

### 4. 服务统计
```dart
final stats = ref.read(aiServiceStatsProvider);
final health = await ref.read(aiServiceHealthProvider.future);
```

## 最佳实践

### 1. 使用Riverpod Providers
- 优先使用预定义的Providers而不是直接调用服务
- 利用Riverpod的缓存和状态管理功能

### 2. 错误处理
```dart
ref.listen(sendChatMessageProvider(params), (previous, next) {
  next.when(
    data: (response) {
      if (response.isSuccess) {
        // 处理成功响应
      } else {
        // 处理业务错误
      }
    },
    loading: () => {/* 显示加载状态 */},
    error: (error, stack) => {/* 处理异常 */},
  );
});
```

### 3. 缓存管理
```dart
// 清除特定提供商的缓存
ref.read(clearModelCacheProvider(providerId));

// 获取缓存统计
final cacheStats = ref.read(modelCacheStatsProvider);
```

### 4. 智能默认配置
```dart
// 使用智能聊天，自动使用用户设置的默认配置
final response = await ref.read(smartChatProvider(
  SmartChatParams(
    chatHistory: chatHistory,
    userMessage: userMessage,
  ),
).future);
```

## 向后兼容性

为了平滑迁移，保留了 `AiService` 类，但它现在会抛出 `UnimplementedError` 并提示使用新的API。

建议逐步迁移：
1. 首先更新新的功能使用新API
2. 然后逐步迁移现有功能
3. 最后移除旧的服务文件

## 注意事项

1. **Riverpod依赖**: 新架构完全依赖Riverpod，确保在使用前正确设置ProviderScope
2. **初始化**: 使用 `initializeAiServicesProvider` 确保服务正确初始化
3. **错误处理**: 新API提供更详细的错误信息和类型安全的错误处理
4. **性能**: 新架构提供更好的缓存和资源管理

## 未来扩展

新架构为以下功能预留了扩展空间：
- 图像生成服务
- 视频处理服务
- 代码执行服务
- 多模态AI服务
- 自定义工具集成
