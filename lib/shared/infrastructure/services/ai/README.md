# AI服务模块化架构

## 概述

这是一个完全重构的AI服务架构，提供模块化、可扩展和类型安全的AI功能。新架构完全集成了Riverpod状态管理，避免直接访问repositories，并为未来的AI功能扩展做好了准备。

## 核心特性

- 🏗️ **模块化架构**: 每个AI能力都有独立的服务模块
- 🔄 **Riverpod集成**: 完全集成Riverpod状态管理
- 🚀 **类型安全**: 强类型API和错误处理
- 📊 **统计监控**: 内置性能统计和健康检查
- 💾 **智能缓存**: 多层缓存策略提升性能
- 🔧 **能力检测**: 自动检测AI提供商支持的功能
- 🎯 **未来扩展**: 为图像生成、TTS、STT等功能预留接口

## 架构组件

### 核心层 (core/)
- **ai_service_base.dart**: 所有AI服务的基类和通用接口
- **ai_response_models.dart**: 统一的响应模型和数据结构

### 聊天服务 (chat/)
- **chat_service.dart**: 核心聊天功能，支持单次和流式对话

### 能力服务 (capabilities/)
- **model_service.dart**: 模型管理和列表获取
- **embedding_service.dart**: 文本向量化和相似度计算
- **speech_service.dart**: 语音转文字(STT)和文字转语音(TTS)

### Riverpod集成 (providers/)
- **ai_service_provider.dart**: 所有AI服务的Riverpod Providers

### 服务管理
- **ai_service_manager.dart**: 统一的AI服务管理器

## 支持的AI能力

| 能力 | 状态 | 支持的提供商 |
|------|------|-------------|
| 聊天对话 | ✅ 已实现 | OpenAI, Anthropic, Google, DeepSeek, Ollama, XAI, Groq |
| 流式聊天 | ✅ 已实现 | 同上 |
| 模型列表 | ✅ 已实现 | OpenAI, Ollama |
| 向量嵌入 | ✅ 已实现 | OpenAI, Ollama |
| 文字转语音 | ✅ 已实现 | OpenAI, ElevenLabs |
| 语音转文字 | ✅ 已实现 | OpenAI |
| 推理思考 | ✅ 已实现 | OpenAI (o1), Anthropic (Claude) |
| 视觉理解 | ✅ 已实现 | OpenAI (GPT-4V), Anthropic (Claude-3), Google (Gemini) |
| 工具调用 | ✅ 已实现 | 大部分提供商 |
| 图像生成 | 🚧 计划中 | - |

## 快速开始

### 1. 初始化服务
```dart
// 在应用启动时初始化
await ref.read(initializeAiServicesProvider.future);
```

### 2. 发送聊天消息
```dart
// 使用智能聊天（自动使用默认配置）
final response = await ref.read(smartChatProvider(
  SmartChatParams(
    chatHistory: messages,
    userMessage: 'Hello!',
  ),
).future);

if (response.isSuccess) {
  print('AI回复: ${response.content}');
}
```

### 3. 流式聊天
```dart
ref.listen(smartChatStreamProvider(params), (previous, next) {
  next.when(
    data: (event) {
      if (event.isContent) {
        // 处理内容增量
        print(event.contentDelta);
      }
    },
    loading: () => {/* 加载状态 */},
    error: (error, stack) => {/* 错误处理 */},
  );
});
```

### 4. 获取模型列表
```dart
final models = await ref.read(providerModelsProvider(providerId).future);
```

### 5. 使用嵌入服务
```dart
final serviceManager = ref.read(aiServiceManagerProvider);
final embeddings = await serviceManager.embeddingService.generateEmbeddings(
  provider: provider,
  texts: ['Hello', 'World'],
);
```

## API参考

### 主要Providers

| Provider | 用途 | 返回类型 |
|----------|------|----------|
| `smartChatProvider` | 智能聊天 | `Future<AiResponse>` |
| `smartChatStreamProvider` | 智能流式聊天 | `Stream<AiStreamEvent>` |
| `sendChatMessageProvider` | 发送聊天消息 | `Future<AiResponse>` |
| `providerModelsProvider` | 获取模型列表 | `Future<List<AiModel>>` |
| `testAiProviderProvider` | 测试提供商 | `Future<bool>` |
| `aiServiceStatsProvider` | 服务统计 | `AiServiceStats` |
| `aiServiceHealthProvider` | 服务健康检查 | `Future<Map<String, bool>>` |

### 响应模型

#### AiResponse
```dart
class AiResponse {
  final String content;           // AI回复内容
  final String? thinking;        // 思考过程（如果支持）
  final UsageInfo? usage;        // Token使用信息
  final Duration? duration;      // 请求耗时
  final String? error;           // 错误信息
  final List<ToolCall>? toolCalls; // 工具调用
  final bool wasCancelled;       // 是否被取消
}
```

#### AiStreamEvent
```dart
class AiStreamEvent {
  final String? contentDelta;    // 内容增量
  final String? thinkingDelta;   // 思考增量
  final bool isDone;             // 是否完成
  final String? error;           // 错误信息
  final UsageInfo? usage;        // 使用信息
  final ToolCall? toolCall;      // 工具调用
}
```

## 配置和设置

### 默认配置
系统会自动使用用户在设置中配置的默认聊天模型：
```dart
final config = ref.read(defaultChatConfigProvider);
```

### 能力检测
```dart
final capabilities = ref.read(modelCapabilitiesProvider(
  ModelCapabilityParams(provider: provider, modelName: modelName),
));

if (capabilities.contains('vision')) {
  // 支持视觉功能
}
```

## 缓存策略

### 模型列表缓存
- 缓存时间: 1小时
- 自动失效和刷新
- 支持手动清除

### 嵌入向量缓存
- 缓存时间: 24小时
- 基于文本内容的智能缓存键

### 语音缓存
- TTS缓存: 1小时
- STT缓存: 1小时
- 基于内容哈希的缓存键

## 错误处理

### 统一错误类型
```dart
// 业务错误
if (!response.isSuccess) {
  print('业务错误: ${response.error}');
}

// 异常处理
try {
  final response = await ref.read(provider.future);
} catch (e) {
  print('系统异常: $e');
}
```

### Riverpod错误处理
```dart
ref.listen(provider, (previous, next) {
  next.when(
    data: (data) => {/* 处理数据 */},
    loading: () => {/* 显示加载 */},
    error: (error, stack) => {/* 处理错误 */},
  );
});
```

## 性能优化

### 1. 智能缓存
- 多层缓存策略
- 自动缓存失效
- 内存使用优化

### 2. 连接复用
- 提供商实例复用
- 连接池管理

### 3. 异步处理
- 非阻塞API设计
- 流式处理支持

## 监控和调试

### 服务统计
```dart
final stats = ref.read(aiServiceStatsProvider);
print('成功率: ${stats.successRate}');
print('平均耗时: ${stats.averageDuration}');
```

### 健康检查
```dart
final health = await ref.read(aiServiceHealthProvider.future);
health.forEach((service, isHealthy) {
  print('$service: ${isHealthy ? '健康' : '异常'}');
});
```

### 缓存统计
```dart
final cacheStats = ref.read(modelCacheStatsProvider);
print('缓存命中率: ${cacheStats['hitRate']}');
```

## 迁移指南

详细的迁移指南请参考 [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md)

## 示例代码

完整的使用示例请参考 [examples/usage_examples.dart](./examples/usage_examples.dart)

## 未来计划

- 🖼️ 图像生成服务
- 🎥 视频处理服务
- 💻 代码执行服务
- 🔧 自定义工具集成
- 📱 多模态AI支持
- 🌐 分布式AI服务
