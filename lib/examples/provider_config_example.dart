/// 提供商配置系统使用示例
/// 展示如何使用标准配置来增强用户的模型配置

import '../models/ai_model.dart';
import '../models/ai_provider.dart';
import '../models/provider_model_config.dart';
import '../services/provider_config_service.dart';
import '../utils/model_config_utils.dart';

void main() {
  // 示例：用户配置了一个 OpenAI 提供商
  final userProvider = AiProvider(
    id: 'user-openai',
    name: '我的 OpenAI',
    type: ProviderType.openai,
    apiKey: 'sk-xxx',
    baseUrl: 'https://api.openai.com/v1', // 官方 URL
    models: [
      AiModel(
        id: 'gpt-4o',
        name: 'gpt-4o',
        displayName: 'GPT-4o', // 用户自定义的显示名称
        capabilities: [ModelCapability.tools], // 用户只配置了工具调用能力
        metadata: {
          'userNote': '我最喜欢的模型', // 用户自定义的备注
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isEnabled: true,
  );

  // 示例：用户配置了一个第三方 OpenAI 兼容提供商
  final thirdPartyProvider = AiProvider(
    id: 'user-deepseek',
    name: '我的 DeepSeek',
    type: ProviderType.openai, // 使用 OpenAI 兼容接口
    apiKey: 'sk-xxx',
    baseUrl: 'https://api.deepseek.com/v1', // 第三方 URL
    models: [
      AiModel(
        id: 'gpt-4o', // 第三方提供商也提供了名为 gpt-4o 的模型
        name: 'gpt-4o',
        displayName: 'DeepSeek GPT-4o',
        capabilities: [ModelCapability.tools],
        metadata: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isEnabled: true,
  );

  print('=== 提供商配置系统示例 ===\n');

  // 1. 获取标准配置信息
  demonstrateStandardConfig();

  // 2. 应用标准配置到用户模型
  demonstrateConfigApplication(userProvider, thirdPartyProvider);

  // 3. 获取模型推荐参数
  demonstrateParameterRecommendation(userProvider);

  // 4. 检查模型能力
  demonstrateCapabilityCheck(userProvider);
}

/// 演示获取标准配置信息
void demonstrateStandardConfig() {
  print('1. 获取 OpenAI 标准配置信息：');
  
  final configService = ProviderConfigService();
  
  // 获取 OpenAI 的标准配置
  final openaiConfig = configService.getProviderConfig('openai');
  if (openaiConfig != null) {
    print('   提供商：${openaiConfig.name}');
    print('   描述：${openaiConfig.description}');
    print('   默认URL：${openaiConfig.defaultBaseUrl}');
    print('   支持的模型数量：${openaiConfig.models.length}');
  }

  // 获取特定模型的标准配置
  final gpt4oConfig = configService.getModelConfig('openai', 'gpt-4o');
  if (gpt4oConfig != null) {
    print('\n   GPT-4o 标准配置：');
    print('   - 显示名称：${gpt4oConfig.displayName}');
    print('   - 描述：${gpt4oConfig.description}');
    print('   - 能力：${gpt4oConfig.abilities.map((a) => a.displayName).join(', ')}');
    print('   - 上下文窗口：${gpt4oConfig.contextWindowTokens} tokens');
    if (gpt4oConfig.pricing != null) {
      print('   - 输入价格：\$${gpt4oConfig.pricing!.input}/M tokens');
      print('   - 输出价格：\$${gpt4oConfig.pricing!.output}/M tokens');
    }
  }
  print('');
}

/// 演示配置应用
void demonstrateConfigApplication(AiProvider officialProvider, AiProvider thirdPartyProvider) {
  print('2. 应用标准配置到用户模型：');
  
  // 对官方提供商应用标准配置
  final officialModel = officialProvider.models.first;
  final enhancedOfficialModel = ModelConfigUtils.applyProviderConfig(officialModel, officialProvider);
  
  print('   官方 OpenAI 模型（会应用标准配置）：');
  print('   - 原始能力：${officialModel.capabilities.map((c) => c.name).join(', ')}');
  print('   - 增强后能力：${enhancedOfficialModel.capabilities.map((c) => c.name).join(', ')}');
  print('   - 是否应用了标准配置：${enhancedOfficialModel.metadata.containsKey('standardConfig')}');
  
  // 对第三方提供商不应用标准配置
  final thirdPartyModel = thirdPartyProvider.models.first;
  final enhancedThirdPartyModel = ModelConfigUtils.applyProviderConfig(thirdPartyModel, thirdPartyProvider);
  
  print('\n   第三方提供商模型（不会应用标准配置）：');
  print('   - 原始能力：${thirdPartyModel.capabilities.map((c) => c.name).join(', ')}');
  print('   - 处理后能力：${enhancedThirdPartyModel.capabilities.map((c) => c.name).join(', ')}');
  print('   - 是否应用了标准配置：${enhancedThirdPartyModel.metadata.containsKey('standardConfig')}');
  print('');
}

/// 演示参数推荐
void demonstrateParameterRecommendation(AiProvider provider) {
  print('3. 获取模型推荐参数：');
  
  final modelName = 'gpt-4o';
  final parameters = ModelConfigUtils.getRecommendedParameters(modelName, provider);
  
  print('   $modelName 推荐参数：');
  parameters.forEach((key, value) {
    print('   - $key: $value');
  });
  print('');
}

/// 演示能力检查
void demonstrateCapabilityCheck(AiProvider provider) {
  print('4. 检查模型能力：');
  
  final modelName = 'gpt-4o';
  
  final supportsVision = ModelConfigUtils.modelSupportsCapability(
    modelName, 
    provider, 
    ModelCapability.vision
  );
  
  final supportsReasoning = ModelConfigUtils.modelSupportsCapability(
    modelName, 
    provider, 
    ModelCapability.reasoning
  );
  
  final supportsTools = ModelConfigUtils.modelSupportsCapability(
    modelName, 
    provider, 
    ModelCapability.tools
  );
  
  print('   $modelName 能力检查：');
  print('   - 支持视觉：$supportsVision');
  print('   - 支持推理：$supportsReasoning');
  print('   - 支持工具调用：$supportsTools');
  
  // 检查是否为推荐模型
  final isRecommended = ModelConfigUtils.isRecommendedModel(modelName, provider);
  final isLegacy = ModelConfigUtils.isLegacyModel(modelName, provider);
  
  print('   - 是否为推荐模型：$isRecommended');
  print('   - 是否为遗留模型：$isLegacy');
  print('');
}
