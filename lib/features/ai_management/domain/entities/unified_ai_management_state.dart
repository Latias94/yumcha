import 'package:flutter/foundation.dart';
import 'ai_provider.dart';
import 'ai_assistant.dart';

/// AI管理事件系统
abstract class AiManagementEvent {
  const AiManagementEvent();
}

class ProviderAddedEvent extends AiManagementEvent {
  final AiProvider provider;
  const ProviderAddedEvent(this.provider);
}

class ProviderUpdatedEvent extends AiManagementEvent {
  final AiProvider provider;
  const ProviderUpdatedEvent(this.provider);
}

class ProviderRemovedEvent extends AiManagementEvent {
  final String providerId;
  const ProviderRemovedEvent(this.providerId);
}

class AssistantCreatedEvent extends AiManagementEvent {
  final AiAssistant assistant;
  const AssistantCreatedEvent(this.assistant);
}

class AssistantUpdatedEvent extends AiManagementEvent {
  final AiAssistant assistant;
  const AssistantUpdatedEvent(this.assistant);
}

class AssistantRemovedEvent extends AiManagementEvent {
  final String assistantId;
  const AssistantRemovedEvent(this.assistantId);
}

class ConfigurationImportedEvent extends AiManagementEvent {
  final int providersCount;
  final int assistantsCount;
  const ConfigurationImportedEvent(this.providersCount, this.assistantsCount);
}

/// 提供商连接状态
enum ProviderConnectionStatus {
  connected, // 已连接
  disconnected, // 未连接
  testing, // 测试中
  error, // 连接错误
  keyInvalid, // API Key无效
  quotaExceeded, // 配额超限
}

/// 模型能力定义 - 可扩展的能力系统
@immutable
class ModelCapabilities {
  // 核心对话能力
  final bool supportsChat; // 基础聊天对话
  final bool supportsStreaming; // 流式输出
  final bool supportsSystemPrompt; // 系统提示

  // 多模态能力
  final bool supportsVision; // 视觉理解（图像输入）
  final bool supportsImageGeneration; // 图像生成
  final bool supportsAudioInput; // 音频输入
  final bool supportsAudioOutput; // 音频输出

  // 高级功能
  final bool supportsTools; // 工具调用/函数调用
  final bool supportsCodeExecution; // 代码执行
  final bool supportsWebSearch; // 网络搜索
  final bool supportsFileUpload; // 文件上传

  // 语音能力
  final bool supportsTTS; // 文字转语音
  final bool supportsSTT; // 语音转文字
  final bool supportsVoiceCloning; // 声音克隆

  // 推理能力
  final bool supportsReasoning; // 推理思考（如o1模型）
  final bool supportsChainOfThought; // 思维链
  final bool supportsMathSolving; // 数学求解
  final bool supportsCodeGeneration; // 代码生成

  // 嵌入和检索
  final bool supportsEmbedding; // 文本嵌入
  final bool supportsSemanticSearch; // 语义搜索
  final bool supportsRAG; // 检索增强生成

  // 内容处理
  final bool supportsTextSummary; // 文本摘要
  final bool supportsTranslation; // 翻译
  final bool supportsContentModeration; // 内容审核

  // 技术特性
  final int maxTokens; // 最大token数
  final int maxContextLength; // 最大上下文长度
  final List<String> supportedLanguages; // 支持的语言
  final List<String> supportedFormats; // 支持的文件格式

  const ModelCapabilities({
    // 核心能力默认值
    this.supportsChat = true,
    this.supportsStreaming = false,
    this.supportsSystemPrompt = true,

    // 多模态能力默认值
    this.supportsVision = false,
    this.supportsImageGeneration = false,
    this.supportsAudioInput = false,
    this.supportsAudioOutput = false,

    // 高级功能默认值
    this.supportsTools = false,
    this.supportsCodeExecution = false,
    this.supportsWebSearch = false,
    this.supportsFileUpload = false,

    // 语音能力默认值
    this.supportsTTS = false,
    this.supportsSTT = false,
    this.supportsVoiceCloning = false,

    // 推理能力默认值
    this.supportsReasoning = false,
    this.supportsChainOfThought = false,
    this.supportsMathSolving = false,
    this.supportsCodeGeneration = false,

    // 嵌入和检索默认值
    this.supportsEmbedding = false,
    this.supportsSemanticSearch = false,
    this.supportsRAG = false,

    // 内容处理默认值
    this.supportsTextSummary = false,
    this.supportsTranslation = false,
    this.supportsContentModeration = false,

    // 技术特性默认值
    this.maxTokens = 4096,
    this.maxContextLength = 4096,
    this.supportedLanguages = const ['en', 'zh'],
    this.supportedFormats = const ['text'],
  });

  /// 检查是否支持多模态
  bool get isMultimodal =>
      supportsVision ||
      supportsImageGeneration ||
      supportsAudioInput ||
      supportsAudioOutput;

  /// 检查是否支持语音功能
  bool get hasVoiceCapabilities =>
      supportsTTS || supportsSTT || supportsVoiceCloning;

  /// 检查是否支持高级推理
  bool get hasAdvancedReasoning =>
      supportsReasoning || supportsChainOfThought || supportsMathSolving;

  /// 获取能力评分（用于排序和比较）
  int get capabilityScore {
    int score = 0;
    if (supportsChat) score += 10;
    if (supportsStreaming) score += 5;
    if (supportsVision) score += 15;
    if (supportsTools) score += 20;
    if (supportsReasoning) score += 25;
    if (supportsTTS) score += 10;
    if (supportsImageGeneration) score += 15;
    // 可以根据需要调整评分权重
    return score;
  }

  ModelCapabilities copyWith({
    bool? supportsChat,
    bool? supportsStreaming,
    bool? supportsSystemPrompt,
    bool? supportsVision,
    bool? supportsImageGeneration,
    bool? supportsAudioInput,
    bool? supportsAudioOutput,
    bool? supportsTools,
    bool? supportsCodeExecution,
    bool? supportsWebSearch,
    bool? supportsFileUpload,
    bool? supportsTTS,
    bool? supportsSTT,
    bool? supportsVoiceCloning,
    bool? supportsReasoning,
    bool? supportsChainOfThought,
    bool? supportsMathSolving,
    bool? supportsCodeGeneration,
    bool? supportsEmbedding,
    bool? supportsSemanticSearch,
    bool? supportsRAG,
    bool? supportsTextSummary,
    bool? supportsTranslation,
    bool? supportsContentModeration,
    int? maxTokens,
    int? maxContextLength,
    List<String>? supportedLanguages,
    List<String>? supportedFormats,
  }) {
    return ModelCapabilities(
      supportsChat: supportsChat ?? this.supportsChat,
      supportsStreaming: supportsStreaming ?? this.supportsStreaming,
      supportsSystemPrompt: supportsSystemPrompt ?? this.supportsSystemPrompt,
      supportsVision: supportsVision ?? this.supportsVision,
      supportsImageGeneration:
          supportsImageGeneration ?? this.supportsImageGeneration,
      supportsAudioInput: supportsAudioInput ?? this.supportsAudioInput,
      supportsAudioOutput: supportsAudioOutput ?? this.supportsAudioOutput,
      supportsTools: supportsTools ?? this.supportsTools,
      supportsCodeExecution:
          supportsCodeExecution ?? this.supportsCodeExecution,
      supportsWebSearch: supportsWebSearch ?? this.supportsWebSearch,
      supportsFileUpload: supportsFileUpload ?? this.supportsFileUpload,
      supportsTTS: supportsTTS ?? this.supportsTTS,
      supportsSTT: supportsSTT ?? this.supportsSTT,
      supportsVoiceCloning: supportsVoiceCloning ?? this.supportsVoiceCloning,
      supportsReasoning: supportsReasoning ?? this.supportsReasoning,
      supportsChainOfThought:
          supportsChainOfThought ?? this.supportsChainOfThought,
      supportsMathSolving: supportsMathSolving ?? this.supportsMathSolving,
      supportsCodeGeneration:
          supportsCodeGeneration ?? this.supportsCodeGeneration,
      supportsEmbedding: supportsEmbedding ?? this.supportsEmbedding,
      supportsSemanticSearch:
          supportsSemanticSearch ?? this.supportsSemanticSearch,
      supportsRAG: supportsRAG ?? this.supportsRAG,
      supportsTextSummary: supportsTextSummary ?? this.supportsTextSummary,
      supportsTranslation: supportsTranslation ?? this.supportsTranslation,
      supportsContentModeration:
          supportsContentModeration ?? this.supportsContentModeration,
      maxTokens: maxTokens ?? this.maxTokens,
      maxContextLength: maxContextLength ?? this.maxContextLength,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
      supportedFormats: supportedFormats ?? this.supportedFormats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supportsChat': supportsChat,
      'supportsStreaming': supportsStreaming,
      'supportsSystemPrompt': supportsSystemPrompt,
      'supportsVision': supportsVision,
      'supportsImageGeneration': supportsImageGeneration,
      'supportsAudioInput': supportsAudioInput,
      'supportsAudioOutput': supportsAudioOutput,
      'supportsTools': supportsTools,
      'supportsCodeExecution': supportsCodeExecution,
      'supportsWebSearch': supportsWebSearch,
      'supportsFileUpload': supportsFileUpload,
      'supportsTTS': supportsTTS,
      'supportsSTT': supportsSTT,
      'supportsVoiceCloning': supportsVoiceCloning,
      'supportsReasoning': supportsReasoning,
      'supportsChainOfThought': supportsChainOfThought,
      'supportsMathSolving': supportsMathSolving,
      'supportsCodeGeneration': supportsCodeGeneration,
      'supportsEmbedding': supportsEmbedding,
      'supportsSemanticSearch': supportsSemanticSearch,
      'supportsRAG': supportsRAG,
      'supportsTextSummary': supportsTextSummary,
      'supportsTranslation': supportsTranslation,
      'supportsContentModeration': supportsContentModeration,
      'maxTokens': maxTokens,
      'maxContextLength': maxContextLength,
      'supportedLanguages': supportedLanguages,
      'supportedFormats': supportedFormats,
    };
  }

  factory ModelCapabilities.fromJson(Map<String, dynamic> json) {
    return ModelCapabilities(
      supportsChat: json['supportsChat'] ?? true,
      supportsStreaming: json['supportsStreaming'] ?? false,
      supportsSystemPrompt: json['supportsSystemPrompt'] ?? true,
      supportsVision: json['supportsVision'] ?? false,
      supportsImageGeneration: json['supportsImageGeneration'] ?? false,
      supportsAudioInput: json['supportsAudioInput'] ?? false,
      supportsAudioOutput: json['supportsAudioOutput'] ?? false,
      supportsTools: json['supportsTools'] ?? false,
      supportsCodeExecution: json['supportsCodeExecution'] ?? false,
      supportsWebSearch: json['supportsWebSearch'] ?? false,
      supportsFileUpload: json['supportsFileUpload'] ?? false,
      supportsTTS: json['supportsTTS'] ?? false,
      supportsSTT: json['supportsSTT'] ?? false,
      supportsVoiceCloning: json['supportsVoiceCloning'] ?? false,
      supportsReasoning: json['supportsReasoning'] ?? false,
      supportsChainOfThought: json['supportsChainOfThought'] ?? false,
      supportsMathSolving: json['supportsMathSolving'] ?? false,
      supportsCodeGeneration: json['supportsCodeGeneration'] ?? false,
      supportsEmbedding: json['supportsEmbedding'] ?? false,
      supportsSemanticSearch: json['supportsSemanticSearch'] ?? false,
      supportsRAG: json['supportsRAG'] ?? false,
      supportsTextSummary: json['supportsTextSummary'] ?? false,
      supportsTranslation: json['supportsTranslation'] ?? false,
      supportsContentModeration: json['supportsContentModeration'] ?? false,
      maxTokens: json['maxTokens'] ?? 4096,
      maxContextLength: json['maxContextLength'] ?? 4096,
      supportedLanguages:
          List<String>.from(json['supportedLanguages'] ?? ['en', 'zh']),
      supportedFormats: List<String>.from(json['supportedFormats'] ?? ['text']),
    );
  }
}

/// 配置模板类型
enum ConfigTemplate {
  openai, // OpenAI标准配置
  anthropic, // Anthropic配置
  google, // Google AI配置
  deepseek, // DeepSeek配置
  groq, // Groq配置
}

/// 用户配置偏好
@immutable
class UserConfigPreferences {
  final bool autoTestConnection; // 自动测试连接
  final bool saveApiKeysSecurely; // 安全保存API Key
  final bool enableConfigBackup; // 启用配置备份
  final bool showAdvancedOptions; // 显示高级选项
  final String defaultProvider; // 默认提供商

  const UserConfigPreferences({
    this.autoTestConnection = true,
    this.saveApiKeysSecurely = true,
    this.enableConfigBackup = true,
    this.showAdvancedOptions = false,
    this.defaultProvider = '',
  });

  UserConfigPreferences copyWith({
    bool? autoTestConnection,
    bool? saveApiKeysSecurely,
    bool? enableConfigBackup,
    bool? showAdvancedOptions,
    String? defaultProvider,
  }) {
    return UserConfigPreferences(
      autoTestConnection: autoTestConnection ?? this.autoTestConnection,
      saveApiKeysSecurely: saveApiKeysSecurely ?? this.saveApiKeysSecurely,
      enableConfigBackup: enableConfigBackup ?? this.enableConfigBackup,
      showAdvancedOptions: showAdvancedOptions ?? this.showAdvancedOptions,
      defaultProvider: defaultProvider ?? this.defaultProvider,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoTestConnection': autoTestConnection,
      'saveApiKeysSecurely': saveApiKeysSecurely,
      'enableConfigBackup': enableConfigBackup,
      'showAdvancedOptions': showAdvancedOptions,
      'defaultProvider': defaultProvider,
    };
  }

  factory UserConfigPreferences.fromJson(Map<String, dynamic> json) {
    return UserConfigPreferences(
      autoTestConnection: json['autoTestConnection'] ?? true,
      saveApiKeysSecurely: json['saveApiKeysSecurely'] ?? true,
      enableConfigBackup: json['enableConfigBackup'] ?? true,
      showAdvancedOptions: json['showAdvancedOptions'] ?? false,
      defaultProvider: json['defaultProvider'] ?? '',
    );
  }
}
