import 'chat_provider.dart';
import 'config.dart';

/// Pre-configured OpenAI-compatible provider configurations
/// 
/// This file contains configurations for popular AI providers that offer
/// OpenAI-compatible APIs, making it easy for users to switch between
/// providers without manual configuration.
class OpenAICompatibleConfigs {
  /// DeepSeek configuration using OpenAI-compatible interface
  static const OpenAICompatibleProviderConfig deepseek = OpenAICompatibleProviderConfig(
    providerId: 'deepseek-openai',
    displayName: 'DeepSeek (OpenAI兼容)',
    description: 'DeepSeek AI models using OpenAI-compatible interface',
    defaultBaseUrl: 'https://api.deepseek.com/v1/',
    defaultModel: 'deepseek-chat',
    supportedCapabilities: {
      LLMCapability.chat,
      LLMCapability.streaming,
      LLMCapability.toolCalling,
      LLMCapability.reasoning,
    },
    supportsReasoningEffort: false,
    supportsStructuredOutput: true,
    modelConfigs: {
      'deepseek-chat': ModelCapabilityConfig(
        supportsReasoning: false,
        supportsVision: false,
        supportsToolCalling: true,
        maxContextLength: 32768,
      ),
      'deepseek-reasoner': ModelCapabilityConfig(
        supportsReasoning: true,
        supportsVision: false,
        supportsToolCalling: true,
        maxContextLength: 32768,
        disableTemperature: true,
        disableTopP: true,
      ),
    },
  );

  /// Google Gemini configuration using OpenAI-compatible interface
  static const OpenAICompatibleProviderConfig gemini = OpenAICompatibleProviderConfig(
    providerId: 'gemini-openai',
    displayName: 'Google Gemini (OpenAI兼容)',
    description: 'Google Gemini models using OpenAI-compatible interface',
    defaultBaseUrl: 'https://generativelanguage.googleapis.com/v1beta/openai/',
    defaultModel: 'gemini-2.0-flash',
    supportedCapabilities: {
      LLMCapability.chat,
      LLMCapability.streaming,
      LLMCapability.toolCalling,
      LLMCapability.reasoning,
      LLMCapability.embedding,
    },
    supportsReasoningEffort: true,
    supportsStructuredOutput: true,
    parameterMappings: {
      'reasoning_effort': 'reasoning_effort', // low, medium, high
    },
    modelConfigs: {
      'gemini-2.0-flash': ModelCapabilityConfig(
        supportsReasoning: false,
        supportsVision: true,
        supportsToolCalling: true,
        maxContextLength: 1000000,
      ),
      'gemini-2.5-flash-preview-05-20': ModelCapabilityConfig(
        supportsReasoning: true,
        supportsVision: true,
        supportsToolCalling: true,
        maxContextLength: 1000000,
      ),
      'text-embedding-004': ModelCapabilityConfig(
        supportsReasoning: false,
        supportsVision: false,
        supportsToolCalling: false,
        maxContextLength: 2048,
      ),
    },
  );

  /// xAI Grok configuration using OpenAI-compatible interface
  static const OpenAICompatibleProviderConfig xai = OpenAICompatibleProviderConfig(
    providerId: 'xai-openai',
    displayName: 'xAI Grok (OpenAI兼容)',
    description: 'xAI Grok models using OpenAI-compatible interface',
    defaultBaseUrl: 'https://api.x.ai/v1/',
    defaultModel: 'grok-2-latest',
    supportedCapabilities: {
      LLMCapability.chat,
      LLMCapability.streaming,
      LLMCapability.toolCalling,
      LLMCapability.reasoning,
    },
    supportsReasoningEffort: false,
    supportsStructuredOutput: true,
    modelConfigs: {
      'grok-2-latest': ModelCapabilityConfig(
        supportsReasoning: false,
        supportsVision: true,
        supportsToolCalling: true,
        maxContextLength: 131072,
      ),
      'grok-3-latest': ModelCapabilityConfig(
        supportsReasoning: false,
        supportsVision: true,
        supportsToolCalling: true,
        maxContextLength: 131072,
      ),
    },
  );

  /// Groq configuration using OpenAI-compatible interface
  static const OpenAICompatibleProviderConfig groq = OpenAICompatibleProviderConfig(
    providerId: 'groq-openai',
    displayName: 'Groq (OpenAI兼容)',
    description: 'Groq AI models using OpenAI-compatible interface for ultra-fast inference',
    defaultBaseUrl: 'https://api.groq.com/openai/v1/',
    defaultModel: 'llama-3.3-70b-versatile',
    supportedCapabilities: {
      LLMCapability.chat,
      LLMCapability.streaming,
      LLMCapability.toolCalling,
    },
    supportsReasoningEffort: false,
    supportsStructuredOutput: true,
    modelConfigs: {
      'llama-3.3-70b-versatile': ModelCapabilityConfig(
        supportsReasoning: false,
        supportsVision: false,
        supportsToolCalling: true,
        maxContextLength: 32768,
      ),
      'mixtral-8x7b-32768': ModelCapabilityConfig(
        supportsReasoning: false,
        supportsVision: false,
        supportsToolCalling: true,
        maxContextLength: 32768,
      ),
    },
  );

  /// Phind configuration using OpenAI-compatible interface
  static const OpenAICompatibleProviderConfig phind = OpenAICompatibleProviderConfig(
    providerId: 'phind-openai',
    displayName: 'Phind (OpenAI兼容)',
    description: 'Phind AI models using OpenAI-compatible interface',
    defaultBaseUrl: 'https://https://api.phind.com/v1/',
    defaultModel: 'Phind-70B',
    supportedCapabilities: {
      LLMCapability.chat,
      LLMCapability.streaming,
      LLMCapability.toolCalling,
    },
    supportsReasoningEffort: false,
    supportsStructuredOutput: false,
    modelConfigs: {
      'Phind-70B': ModelCapabilityConfig(
        supportsReasoning: false,
        supportsVision: false,
        supportsToolCalling: true,
        maxContextLength: 32768,
      ),
    },
  );

  /// Get all available OpenAI-compatible configurations
  static List<OpenAICompatibleProviderConfig> getAllConfigs() {
    return [
      deepseek,
      gemini,
      xai,
      groq,
      phind,
    ];
  }

  /// Get configuration by provider ID
  static OpenAICompatibleProviderConfig? getConfig(String providerId) {
    switch (providerId) {
      case 'deepseek-openai':
        return deepseek;
      case 'gemini-openai':
        return gemini;
      case 'xai-openai':
        return xai;
      case 'groq-openai':
        return groq;
      case 'phind-openai':
        return phind;
      default:
        return null;
    }
  }

  /// Check if a provider ID is OpenAI-compatible
  static bool isOpenAICompatible(String providerId) {
    return getConfig(providerId) != null;
  }

  /// Get model capabilities for a specific provider and model
  static ModelCapabilityConfig? getModelCapabilities(String providerId, String model) {
    final config = getConfig(providerId);
    return config?.modelConfigs[model];
  }
}
