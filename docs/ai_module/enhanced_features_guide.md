# AI模块增强功能指南

本指南介绍了AI模块的增强功能，这些功能参考了`llm_dart_example`的最佳实践，并遵循我们的Riverpod最佳实践。

## 🎯 功能概览

### 新增功能
- 🌐 **HTTP代理配置** - 支持企业代理环境
- 🔍 **Web搜索集成** - 实时网络信息搜索
- 🎨 **图像生成功能** - AI图像创作能力
- 🎵 **语音处理功能** - TTS/STT语音处理
- 🖼️ **多模态分析** - 图像理解和分析
- ⚙️ **增强配置管理** - 统一的高级配置

### 架构特点
- ✅ 遵循Clean Architecture原则
- ✅ 使用Riverpod状态管理
- ✅ 参考llm_dart最佳实践
- ✅ 支持多提供商配置
- ✅ 完善的错误处理和日志

## 🚀 快速开始

### 1. 基础设置

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lib/shared/infrastructure/services/ai/providers/enhanced_ai_features_provider.dart';

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取增强AI服务
    final imageService = ref.read(imageGenerationServiceProvider);
    final webSearchService = ref.read(webSearchServiceProvider);
    
    return MaterialApp(
      // 你的应用配置
    );
  }
}
```

### 2. HTTP代理配置

```dart
// 创建HTTP代理配置
final httpConfigParams = HttpConfigParams(
  provider: myProvider,
  proxyUrl: 'http://proxy.company.com:8080',
  connectionTimeout: Duration(seconds: 30),
  enableLogging: true,
  customHeaders: {
    'X-Client-Name': 'YumCha',
    'X-Request-ID': 'unique-id',
  },
);

// 使用Provider创建配置
final httpConfig = ref.read(createHttpConfigProvider(httpConfigParams));
```

### 3. Web搜索功能

```dart
// Web搜索参数
final searchParams = WebSearchParams(
  provider: myProvider,
  assistant: myAssistant,
  query: '最新AI发展趋势',
  maxResults: 5,
  language: 'zh',
  allowedDomains: ['wikipedia.org', 'github.com'],
);

// 执行搜索
final searchResult = await ref.read(webSearchProvider(searchParams).future);

if (searchResult.isSuccess) {
  for (final result in searchResult.results) {
    print('标题: ${result.title}');
    print('链接: ${result.url}');
    print('摘要: ${result.snippet}');
  }
}
```

### 4. 图像生成功能

```dart
// 图像生成参数
final imageParams = ImageGenerationParams(
  provider: myProvider,
  prompt: '一只可爱的猫咪在花园里玩耍',
  size: '1024x1024',
  quality: 'hd',
  style: 'vivid',
  count: 2,
);

// 生成图像
final imageResult = await ref.read(generateImageProvider(imageParams).future);

if (imageResult.isSuccess) {
  for (final image in imageResult.images) {
    if (image.url != null) {
      // 显示图像
      Image.network(image.url!);
    }
  }
}
```

### 5. 语音处理功能

```dart
// 文字转语音
final ttsParams = TextToSpeechParams(
  provider: myProvider,
  text: '你好，欢迎使用YumCha！',
  voice: 'alloy',
);

final ttsResult = await ref.read(textToSpeechProvider(ttsParams).future);

if (ttsResult.isSuccess) {
  // 播放音频
  playAudio(ttsResult.audioData);
}

// 语音转文字
final sttParams = SpeechToTextParams(
  provider: myProvider,
  audioData: audioBytes,
  language: 'zh',
);

final sttResult = await ref.read(speechToTextProvider(sttParams).future);

if (sttResult.isSuccess) {
  print('转录文本: ${sttResult.text}');
}
```

### 6. 多模态图像分析

```dart
// 图像分析参数
final analysisParams = ImageAnalysisParams(
  provider: myProvider,
  assistant: myAssistant,
  modelName: 'gpt-4o-vision',
  imageData: imageBytes,
  prompt: '请描述这张图片的内容',
  imageFormat: 'png',
);

// 分析图像
final analysisResult = await ref.read(analyzeImageProvider(analysisParams).future);

if (analysisResult.isSuccess) {
  print('分析结果: ${analysisResult.content}');
  
  if (analysisResult.thinking != null) {
    print('思考过程: ${analysisResult.thinking}');
  }
}
```

## 🔧 高级配置

### 综合增强配置

```dart
// 创建综合增强配置
final enhancedParams = EnhancedConfigParams(
  provider: myProvider,
  assistant: myAssistant,
  modelName: 'gpt-4o-mini',
  
  // HTTP配置
  proxyUrl: 'http://proxy.company.com:8080',
  connectionTimeout: Duration(seconds: 30),
  customHeaders: {'X-Client': 'YumCha'},
  enableHttpLogging: true,
  
  // 功能开关
  enableWebSearch: true,
  enableImageGeneration: true,
  enableTTS: true,
  enableSTT: true,
  
  // 功能配置
  maxSearchResults: 5,
  searchLanguage: 'zh',
  imageSize: '1024x1024',
  imageQuality: 'hd',
  ttsVoice: 'alloy',
  sttLanguage: 'zh',
);

// 创建配置
final enhancedConfig = await ref.read(createEnhancedConfigProvider(enhancedParams).future);

// 验证配置
final isValid = ref.read(validateEnhancedConfigProvider(enhancedConfig));
```

### 配置监控和统计

```dart
// 获取各种统计信息
final enhancedStats = ref.watch(enhancedConfigStatsProvider);
final httpStats = ref.watch(httpConfigStatsProvider);
final imageStats = ref.watch(imageGenerationStatsProvider);
final webSearchStats = ref.watch(webSearchStatsProvider);

print('增强配置统计: $enhancedStats');
print('HTTP配置统计: $httpStats');
print('图像生成统计: $imageStats');
print('Web搜索统计: $webSearchStats');
```

## 📋 支持的提供商

### HTTP代理支持
- ✅ 所有提供商都支持HTTP代理配置

### Web搜索支持
- ✅ **xAI Grok** - 原生搜索能力
- ✅ **Anthropic Claude** - 工具调用搜索
- ✅ **OpenAI** - 搜索增强模型
- ✅ **Perplexity** - 专业搜索AI

### 图像生成支持
- ✅ **OpenAI DALL-E** - 高质量图像生成
- ✅ **Stability AI** - 开源图像生成
- ✅ **Midjourney** - 艺术风格图像

### 语音处理支持
- ✅ **OpenAI** - TTS/STT功能
- ✅ **Azure** - 语音服务
- ✅ **Google** - 语音API

### 多模态支持
- ✅ **OpenAI GPT-4o** - 视觉理解
- ✅ **Anthropic Claude** - 图像分析
- ✅ **Google Gemini** - 多模态AI

## 🛠️ 最佳实践

### 1. 错误处理

```dart
try {
  final result = await ref.read(webSearchProvider(params).future);
  
  if (result.isSuccess) {
    // 处理成功结果
    handleSuccess(result);
  } else {
    // 处理错误
    handleError(result.error);
  }
} catch (e) {
  // 处理异常
  logger.error('Web搜索异常: $e');
}
```

### 2. 性能优化

```dart
// 使用autoDispose避免内存泄漏
final searchProvider = FutureProvider.autoDispose.family<WebSearchResponse, WebSearchParams>((ref, params) async {
  // 实现逻辑
});

// 缓存频繁使用的配置
final cachedConfig = ref.watch(createEnhancedConfigProvider(params));
```

### 3. 日志记录

```dart
// 启用HTTP日志记录
final config = HttpConfigParams(
  provider: provider,
  enableLogging: true, // 开发环境启用
);

// 监控统计信息
ref.listen(imageGenerationStatsProvider, (previous, next) {
  logger.info('图像生成统计更新: $next');
});
```

## 🔍 调试和监控

### 查看服务状态

```dart
// 检查服务支持情况
final supportsWebSearch = ref.read(webSearchSupportProvider(provider));
final supportsImageGen = ref.read(imageGenerationSupportProvider(provider));

print('Web搜索支持: $supportsWebSearch');
print('图像生成支持: $supportsImageGen');
```

### 获取详细统计

```dart
// 获取详细的使用统计
final stats = ref.read(enhancedConfigStatsProvider);

print('总配置数: ${stats['totalConfigs']}');
print('启用Web搜索的配置: ${stats['configsWithWebSearch']}');
print('启用图像生成的配置: ${stats['configsWithImageGeneration']}');
```

## 📚 参考资源

- [llm_dart示例代码](../llm_dart_example/)
- [Riverpod最佳实践](../best_practices/riverpod_best_practices.md)
- [AI服务架构文档](./ai_service_architecture.md)
- [错误处理指南](../best_practices/error_handling.md)

## 🤝 贡献指南

如需添加新功能或改进现有功能，请：

1. 参考llm_dart示例的实现方式
2. 遵循Riverpod最佳实践
3. 添加完整的错误处理和日志
4. 编写相应的测试用例
5. 更新相关文档

---

*本指南会随着功能的更新而持续完善。如有问题或建议，请提交Issue或PR。*
