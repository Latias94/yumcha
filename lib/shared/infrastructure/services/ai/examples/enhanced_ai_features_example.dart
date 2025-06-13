import 'dart:typed_data';
import '../../../../../features/ai_management/domain/entities/ai_provider.dart'
    as models;
import '../../../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../capabilities/enhanced_chat_configuration_service.dart';
import '../capabilities/image_generation_service.dart';
import '../capabilities/web_search_service.dart';
import '../capabilities/multimodal_service.dart';
import '../ai_service_manager.dart';

/// 增强AI功能使用示例
///
/// 这个文件展示了如何使用新集成的AI功能，参考llm_dart示例：
/// - 🌐 HTTP代理配置
/// - 🔍 Web搜索功能
/// - 🎨 图像生成功能
/// - 🎵 语音处理功能
/// - 🖼️ 多模态分析功能
///
/// ## 参考llm_dart示例的最佳实践
/// 
/// 这些示例直接参考了llm_dart_example中的实现方式，
/// 确保与llm_dart库的最佳实践保持一致。
class EnhancedAiFeaturesExample {
  final AiServiceManager _serviceManager = AiServiceManager();
  final EnhancedChatConfigurationService _configService = EnhancedChatConfigurationService();

  /// 初始化示例
  Future<void> initialize() async {
    await _serviceManager.initialize();
    await _configService.initialize();
  }

  /// 示例1：HTTP代理配置聊天
  /// 
  /// 参考：llm_dart_example/03_advanced_features/http_configuration.dart
  Future<void> demonstrateProxyChat({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    required String proxyUrl,
    required String userMessage,
  }) async {
    print('🌐 HTTP代理配置聊天示例');
    print('代理URL: $proxyUrl');

    try {
      // 创建带代理的增强配置
      final enhancedConfig = await _configService.createEnhancedConfig(
        provider: provider,
        assistant: assistant,
        modelName: modelName,
        proxyUrl: proxyUrl,
        connectionTimeout: Duration(seconds: 30),
        enableHttpLogging: true,
        customHeaders: {
          'X-Client-Name': 'YumCha-Enhanced',
          'X-Request-ID': 'proxy-demo-${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      print('✅ 增强配置创建成功');
      print('配置ID: ${enhancedConfig.id}');

      // 发送聊天消息
      final response = await _serviceManager.sendMessage(
        provider: provider,
        assistant: assistant,
        modelName: modelName,
        chatHistory: [],
        userMessage: userMessage,
      );

      if (response.isSuccess) {
        print('🤖 AI回复: ${response.content}');
        print('⏱️ 耗时: ${response.duration?.inMilliseconds}ms');
      } else {
        print('❌ 聊天失败: ${response.error}');
      }
    } catch (e) {
      print('❌ 代理聊天示例失败: $e');
    }
  }

  /// 示例2：Web搜索增强聊天
  /// 
  /// 参考：llm_dart_example/02_core_features/web_search.dart
  Future<void> demonstrateWebSearchChat({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    required String searchQuery,
  }) async {
    print('🔍 Web搜索增强聊天示例');
    print('搜索查询: $searchQuery');

    try {
      // 创建带Web搜索的增强配置
      final enhancedConfig = await _configService.createEnhancedConfig(
        provider: provider,
        assistant: assistant,
        modelName: modelName,
        enableWebSearch: true,
        maxSearchResults: 5,
        searchLanguage: 'zh',
        allowedDomains: ['wikipedia.org', 'github.com', 'arxiv.org'],
      );

      print('✅ Web搜索配置创建成功');

      // 使用Web搜索服务
      final webSearchService = _serviceManager.webSearchService;
      final searchResponse = await webSearchService.searchWeb(
        provider: provider,
        assistant: assistant,
        query: searchQuery,
        maxResults: 5,
        language: 'zh',
      );

      if (searchResponse.isSuccess) {
        print('🔍 搜索结果:');
        for (final result in searchResponse.results) {
          print('  📄 ${result.title}');
          print('  🔗 ${result.url}');
          print('  📝 ${result.snippet}');
          print('');
        }

        // 基于搜索结果进行聊天
        final chatPrompt = '基于以下搜索结果回答问题：$searchQuery\n\n搜索结果：\n${searchResponse.results.map((r) => '${r.title}: ${r.snippet}').join('\n')}';
        
        final chatResponse = await _serviceManager.sendMessage(
          provider: provider,
          assistant: assistant,
          modelName: modelName,
          chatHistory: [],
          userMessage: chatPrompt,
        );

        if (chatResponse.isSuccess) {
          print('🤖 基于搜索的AI回复: ${chatResponse.content}');
        }
      } else {
        print('❌ Web搜索失败: ${searchResponse.error}');
      }
    } catch (e) {
      print('❌ Web搜索聊天示例失败: $e');
    }
  }

  /// 示例3：图像生成功能
  /// 
  /// 参考：llm_dart_example/02_core_features/image_generation.dart
  Future<void> demonstrateImageGeneration({
    required models.AiProvider provider,
    required String prompt,
  }) async {
    print('🎨 图像生成示例');
    print('提示词: $prompt');

    try {
      final imageService = _serviceManager.imageGenerationService;

      // 检查提供商是否支持图像生成
      if (!imageService.supportsImageGeneration(provider)) {
        print('❌ 提供商 ${provider.name} 不支持图像生成');
        return;
      }

      // 生成图像
      final response = await imageService.generateImage(
        provider: provider,
        prompt: prompt,
        size: '1024x1024',
        quality: 'hd',
        style: 'vivid',
        count: 2,
      );

      if (response.isSuccess) {
        print('✅ 图像生成成功');
        print('生成数量: ${response.images.length}');
        print('⏱️ 耗时: ${response.duration.inMilliseconds}ms');

        for (int i = 0; i < response.images.length; i++) {
          final image = response.images[i];
          print('🖼️ 图像 ${i + 1}:');
          if (image.url != null) {
            print('  🔗 URL: ${image.url}');
          }
          if (image.revisedPrompt != null) {
            print('  📝 修订提示词: ${image.revisedPrompt}');
          }
        }
      } else {
        print('❌ 图像生成失败: ${response.error}');
      }
    } catch (e) {
      print('❌ 图像生成示例失败: $e');
    }
  }

  /// 示例4：语音处理功能
  /// 
  /// 参考：llm_dart_example/02_core_features/audio_processing.dart
  Future<void> demonstrateSpeechProcessing({
    required models.AiProvider provider,
    required String text,
  }) async {
    print('🎵 语音处理示例');
    print('文本: $text');

    try {
      final multimodalService = _serviceManager.multimodalService;

      // 文字转语音
      print('🗣️ 执行文字转语音...');
      final ttsResponse = await multimodalService.textToSpeech(
        provider: provider,
        text: text,
        voice: 'alloy',
      );

      if (ttsResponse.isSuccess) {
        print('✅ TTS成功');
        print('音频大小: ${ttsResponse.audioData.length} bytes');
        print('⏱️ 耗时: ${ttsResponse.duration.inMilliseconds}ms');

        // 模拟语音转文字（使用生成的音频）
        print('🎤 执行语音转文字...');
        final sttResponse = await multimodalService.speechToText(
          provider: provider,
          audioData: ttsResponse.audioData,
          language: 'zh',
        );

        if (sttResponse.isSuccess) {
          print('✅ STT成功');
          print('转录文本: ${sttResponse.text}');
          print('⏱️ 耗时: ${sttResponse.duration.inMilliseconds}ms');
        } else {
          print('❌ STT失败: ${sttResponse.error}');
        }
      } else {
        print('❌ TTS失败: ${ttsResponse.error}');
      }
    } catch (e) {
      print('❌ 语音处理示例失败: $e');
    }
  }

  /// 示例5：多模态图像分析
  /// 
  /// 参考：llm_dart_example/03_advanced_features/multi_modal.dart
  Future<void> demonstrateImageAnalysis({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    required Uint8List imageData,
    required String prompt,
  }) async {
    print('🖼️ 多模态图像分析示例');
    print('提示词: $prompt');
    print('图像大小: ${imageData.length} bytes');

    try {
      final multimodalService = _serviceManager.multimodalService;

      // 分析图像
      final response = await multimodalService.analyzeImage(
        provider: provider,
        assistant: assistant,
        modelName: modelName,
        imageData: imageData,
        prompt: prompt,
        imageFormat: 'png',
      );

      if (response.isSuccess) {
        print('✅ 图像分析成功');
        print('🤖 分析结果: ${response.content}');
        print('⏱️ 耗时: ${response.duration?.inMilliseconds}ms');

        if (response.thinking != null) {
          print('🧠 思考过程: ${response.thinking}');
        }

        if (response.usage != null) {
          print('📊 Token使用: ${response.usage}');
        }
      } else {
        print('❌ 图像分析失败: ${response.error}');
      }
    } catch (e) {
      print('❌ 图像分析示例失败: $e');
    }
  }

  /// 示例6：综合功能演示
  /// 
  /// 结合多种功能的综合示例
  Future<void> demonstrateComprehensiveFeatures({
    required models.AiProvider provider,
    required AiAssistant assistant,
    required String modelName,
    String? proxyUrl,
  }) async {
    print('🎯 综合功能演示');

    try {
      // 创建综合增强配置
      final enhancedConfig = await _configService.createEnhancedConfig(
        provider: provider,
        assistant: assistant,
        modelName: modelName,
        
        // HTTP配置
        proxyUrl: proxyUrl,
        connectionTimeout: Duration(seconds: 30),
        enableHttpLogging: true,
        customHeaders: {
          'X-Client-Name': 'YumCha-Comprehensive',
          'X-Feature-Set': 'full',
        },
        
        // 功能开关
        enableWebSearch: true,
        enableImageGeneration: true,
        enableTTS: true,
        enableSTT: true,
        
        // 功能配置
        maxSearchResults: 3,
        searchLanguage: 'zh',
        imageSize: '1024x1024',
        imageQuality: 'hd',
        ttsVoice: 'alloy',
        sttLanguage: 'zh',
      );

      print('✅ 综合配置创建成功');
      print('配置功能:');
      print('  🌐 HTTP代理: ${enhancedConfig.httpConfig.proxyUrl != null}');
      print('  🔍 Web搜索: ${enhancedConfig.enableWebSearch}');
      print('  🎨 图像生成: ${enhancedConfig.enableImageGeneration}');
      print('  🗣️ TTS: ${enhancedConfig.enableTTS}');
      print('  🎤 STT: ${enhancedConfig.enableSTT}');

      // 验证配置
      final isValid = _configService.validateEnhancedConfig(enhancedConfig);
      print('✅ 配置验证: ${isValid ? '通过' : '失败'}');

      if (isValid) {
        print('🚀 配置已就绪，可以开始使用增强功能！');
      }
    } catch (e) {
      print('❌ 综合功能演示失败: $e');
    }
  }

  /// 清理资源
  Future<void> dispose() async {
    await _serviceManager.dispose();
    await _configService.dispose();
  }
}
