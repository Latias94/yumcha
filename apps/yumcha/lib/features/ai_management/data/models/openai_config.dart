import '../../domain/entities/provider_model_config.dart';

/// OpenAI 提供商配置
class OpenAIConfig {
  static const ProviderConfig config = ProviderConfig(
    name: 'OpenAI',
    id: 'openai',
    description: 'OpenAI 官方 API 服务',
    defaultBaseUrl: 'https://api.openai.com/v1',
    models: openaiModels,
  );

  /// OpenAI 聊天模型配置列表
  static const List<ProviderModelConfig> openaiModels = [
    // o3 系列
    ProviderModelConfig(
      id: 'o3',
      displayName: 'o3',
      description: 'o3 是一款全能强大的模型，在多个领域表现出色。它为数学、科学、编程和视觉推理任务树立了新标杆。',
      type: ModelType.chat,
      abilities: {
        ModelAbility.functionCall,
        ModelAbility.reasoning,
        ModelAbility.vision,
      },
      contextWindowTokens: 200000,
      maxOutput: 100000,
      pricing: ModelPricing(input: 10, output: 40, cachedInput: 2.5),
      releasedAt: '2025-04-17',
      settings: ModelSettings(extendParams: ['reasoningEffort']),
    ),

    ProviderModelConfig(
      id: 'o4-mini',
      displayName: 'o4-mini',
      description:
          'o4-mini 是我们最新的小型 o 系列模型。它专为快速有效的推理而优化，在编码和视觉任务中表现出极高的效率和性能。',
      type: ModelType.chat,
      abilities: {
        ModelAbility.functionCall,
        ModelAbility.reasoning,
        ModelAbility.vision,
      },
      contextWindowTokens: 200000,
      maxOutput: 100000,
      pricing: ModelPricing(input: 1.1, output: 4.4, cachedInput: 0.275),
      releasedAt: '2025-04-17',
      settings: ModelSettings(extendParams: ['reasoningEffort']),
    ),

    // o1 系列
    ProviderModelConfig(
      id: 'o1',
      displayName: 'o1',
      description: 'o1是OpenAI新的推理模型，支持图文输入并输出文本，适用于需要广泛通用知识的复杂任务。',
      type: ModelType.chat,
      abilities: {ModelAbility.reasoning, ModelAbility.vision},
      contextWindowTokens: 200000,
      maxOutput: 100000,
      pricing: ModelPricing(input: 15, output: 60, cachedInput: 7.5),
      releasedAt: '2024-12-17',
      settings: ModelSettings(extendParams: ['reasoningEffort']),
    ),

    ProviderModelConfig(
      id: 'o1-mini',
      displayName: 'o1-mini',
      description: 'o1-mini是一款针对编程、数学和科学应用场景而设计的快速、经济高效的推理模型。',
      type: ModelType.chat,
      abilities: {ModelAbility.reasoning},
      contextWindowTokens: 128000,
      maxOutput: 65536,
      pricing: ModelPricing(input: 1.1, output: 4.4, cachedInput: 0.55),
      releasedAt: '2024-09-12',
      settings: ModelSettings(extendParams: ['reasoningEffort']),
    ),

    // GPT-4o 系列
    ProviderModelConfig(
      id: 'gpt-4o',
      displayName: 'GPT-4o',
      description: 'ChatGPT-4o 是一款动态模型，实时更新以保持当前最新版本。它结合了强大的语言理解与生成能力。',
      type: ModelType.chat,
      abilities: {ModelAbility.functionCall, ModelAbility.vision},
      contextWindowTokens: 128000,
      pricing: ModelPricing(input: 2.5, output: 10, cachedInput: 1.25),
      releasedAt: '2024-05-13',
    ),

    ProviderModelConfig(
      id: 'gpt-4o-mini',
      displayName: 'GPT-4o mini',
      description: 'GPT-4o mini是OpenAI推出的最新小型模型，支持图文输入并输出文本。性价比极高。',
      type: ModelType.chat,
      abilities: {ModelAbility.functionCall, ModelAbility.vision},
      contextWindowTokens: 128000,
      maxOutput: 16384,
      pricing: ModelPricing(input: 0.15, output: 0.6, cachedInput: 0.075),
      releasedAt: '2024-07-18',
    ),

    // GPT-4 Turbo 系列
    ProviderModelConfig(
      id: 'gpt-4-turbo',
      displayName: 'GPT-4 Turbo',
      description: '最新的 GPT-4 Turbo 模型具备视觉功能。为多模态任务提供成本效益高的支持。',
      type: ModelType.chat,
      abilities: {ModelAbility.functionCall, ModelAbility.vision},
      contextWindowTokens: 128000,
      pricing: ModelPricing(input: 10, output: 30),
    ),

    // GPT-4 系列
    ProviderModelConfig(
      id: 'gpt-4',
      displayName: 'GPT-4',
      description: 'GPT-4 提供了一个更大的上下文窗口，能够处理更长的文本输入，适用于需要广泛信息整合和数据分析的场景。',
      type: ModelType.chat,
      abilities: {ModelAbility.functionCall},
      contextWindowTokens: 8192,
      pricing: ModelPricing(input: 30, output: 60),
    ),

    // GPT-3.5 系列
    ProviderModelConfig(
      id: 'gpt-3.5-turbo',
      displayName: 'GPT-3.5 Turbo',
      description: 'GPT 3.5 Turbo，适用于各种文本生成和理解任务',
      type: ModelType.chat,
      abilities: {ModelAbility.functionCall},
      contextWindowTokens: 16384,
      pricing: ModelPricing(input: 0.5, output: 1.5),
    ),

    // 嵌入模型
    ProviderModelConfig(
      id: 'text-embedding-3-large',
      displayName: 'Text Embedding 3 Large',
      description: '最强大的向量化模型，适用于英文和非英文任务',
      type: ModelType.embedding,
      abilities: {ModelAbility.embedding},
      contextWindowTokens: 8192,
      pricing: ModelPricing(input: 0.13),
      releasedAt: '2024-01-25',
      settings: ModelSettings(maxDimension: 3072),
    ),

    ProviderModelConfig(
      id: 'text-embedding-3-small',
      displayName: 'Text Embedding 3 Small',
      description: '高效且经济的新一代 Embedding 模型，适用于知识检索、RAG 应用等场景',
      type: ModelType.embedding,
      abilities: {ModelAbility.embedding},
      contextWindowTokens: 8192,
      pricing: ModelPricing(input: 0.02),
      releasedAt: '2024-01-25',
      settings: ModelSettings(maxDimension: 1536),
    ),

    // TTS 模型
    ProviderModelConfig(
      id: 'tts-1',
      displayName: 'TTS-1',
      description: '最新的文本转语音模型，针对实时场景优化速度',
      type: ModelType.tts,
      pricing: ModelPricing(input: 15),
    ),

    ProviderModelConfig(
      id: 'tts-1-hd',
      displayName: 'TTS-1 HD',
      description: '最新的文本转语音模型，针对质量进行优化',
      type: ModelType.tts,
      pricing: ModelPricing(input: 30),
    ),

    // STT 模型
    ProviderModelConfig(
      id: 'whisper-1',
      displayName: 'Whisper',
      description: '通用语音识别模型，支持多语言语音识别、语音翻译和语言识别',
      type: ModelType.stt,
      pricing: ModelPricing(input: 0.006), // per minute
    ),

    // 图像生成模型
    ProviderModelConfig(
      id: 'dall-e-3',
      displayName: 'DALL·E 3',
      description: '最新的 DALL·E 模型，支持更真实、准确的图像生成，具有更强的细节表现力',
      type: ModelType.image,
      pricing: ModelPricing(standard: 0.04, hd: 0.08),
      settings: ModelSettings(
        resolutions: ['1024x1024', '1024x1792', '1792x1024'],
      ),
    ),

    ProviderModelConfig(
      id: 'dall-e-2',
      displayName: 'DALL·E 2',
      description: '第二代 DALL·E 模型，支持更真实、准确的图像生成',
      type: ModelType.image,
      pricing: ModelPricing(input: 0.02), // $0.020 per image (1024×1024)
      settings: ModelSettings(resolutions: ['256x256', '512x512', '1024x1024']),
    ),
  ];
}
