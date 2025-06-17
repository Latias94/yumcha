import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ai_configuration_state.dart';
import '../../domain/entities/user_ai_configuration.dart';
import '../../domain/entities/ai_provider.dart';
import '../../domain/entities/ai_assistant.dart';
import 'unified_ai_management_providers.dart';

/// AI配置状态Provider
///
/// 统一管理AI配置的所有状态信息，包括验证、错误、警告等。
/// 这是一个聚合Provider，将分散的配置相关状态统一管理。
final aiConfigurationStateProvider = Provider<AiConfigurationState>((ref) {
  final management = ref.watch(unifiedAiManagementProvider);
  final config = management.configuration;

  return AiConfigurationState(
    configuration: config,
    isValid: _validateConfiguration(config),
    status: _getConfigurationStatus(config, management),
    lastUpdated:
        DateTime.now(), // 使用当前时间，因为UnifiedAiManagementState没有lastUpdated字段
    validationErrors: _getValidationErrors(config, management.providers),
    warnings: _getWarnings(config, management.assistants),
    isLoading: management.isLoading,
  );
});

/// 配置验证逻辑
bool _validateConfiguration(UserAiConfiguration config) {
  // 检查必要的配置项
  if (config.selectedAssistant == null) return false;
  if (config.selectedProvider == null) return false;
  if (config.selectedModel == null) return false;

  // 检查配置的有效性
  return config.isValid;
}

/// 获取配置状态
ConfigurationStatus _getConfigurationStatus(
  UserAiConfiguration config,
  dynamic management, // UnifiedAiManagementState
) {
  if (management.isLoading) return ConfigurationStatus.configuring;
  if (!management.isInitialized) return ConfigurationStatus.notConfigured;

  final errors = _getValidationErrors(config, management.providers);
  if (errors.isNotEmpty) return ConfigurationStatus.error;

  if (_validateConfiguration(config)) {
    return ConfigurationStatus.ready;
  }

  return ConfigurationStatus.notConfigured;
}

/// 获取验证错误
List<ValidationError> _getValidationErrors(
    UserAiConfiguration config, List<AiProvider> providers) {
  final errors = <ValidationError>[];

  if (config.selectedAssistant == null) {
    errors.add(const ValidationError(
      field: 'assistant',
      message: '请选择AI助手',
      type: ValidationErrorType.required,
      code: 'ASSISTANT_REQUIRED',
    ));
  }

  if (config.selectedProvider == null) {
    errors.add(const ValidationError(
      field: 'provider',
      message: '请选择AI提供商',
      type: ValidationErrorType.required,
      code: 'PROVIDER_REQUIRED',
    ));
  }

  if (config.selectedModel == null) {
    errors.add(const ValidationError(
      field: 'model',
      message: '请选择AI模型',
      type: ValidationErrorType.required,
      code: 'MODEL_REQUIRED',
    ));
  }

  // 检查API密钥
  if (config.selectedProvider != null) {
    final provider = providers.firstWhere(
      (p) => p.id == config.selectedProvider!.id,
      orElse: () => config.selectedProvider!,
    );

    if (provider.apiKey.isEmpty) {
      errors.add(ValidationError(
        field: 'apiKey',
        message: '请配置${provider.name}的API密钥',
        type: ValidationErrorType.required,
        code: 'API_KEY_REQUIRED',
        details: {'providerId': provider.id, 'providerName': provider.name},
      ));
    }
  }

  return errors;
}

/// 获取警告信息
List<String> _getWarnings(
    UserAiConfiguration config, List<AiAssistant> assistants) {
  final warnings = <String>[];

  // 添加配置相关的警告
  if (config.selectedModel != null &&
      config.selectedModel!.name.contains('gpt-4')) {
    warnings.add('GPT-4模型消耗较多tokens，请注意使用成本');
  }

  if (config.selectedModel != null &&
      config.selectedModel!.name.contains('claude-3')) {
    warnings.add('Claude-3模型具有较高的推理能力，适合复杂任务');
  }

  // 检查模型兼容性警告
  if (config.selectedAssistant != null && config.selectedModel != null) {
    final assistant = assistants.firstWhere(
      (a) => a.id == config.selectedAssistant!.id,
      orElse: () => config.selectedAssistant!,
    );

    if (assistant.enableVision &&
        !config.selectedModel!.name.contains('vision') &&
        !config.selectedModel!.name.contains('gpt-4')) {
      warnings.add('当前助手需要视觉能力，建议选择支持视觉的模型');
    }
  }

  return warnings;
}

// ============================================================================
// 向后兼容的访问器Provider
// ============================================================================

/// 配置有效性Provider（向后兼容）
final configurationValidityProvider =
    Provider<bool>((ref) => ref.watch(aiConfigurationStateProvider).isValid);

/// 配置状态Provider（向后兼容）
final configurationStatusProvider = Provider<ConfigurationStatus>(
    (ref) => ref.watch(aiConfigurationStateProvider).status);

/// 配置错误Provider（新增）
final configurationErrorsProvider = Provider<List<ValidationError>>(
    (ref) => ref.watch(aiConfigurationStateProvider).validationErrors);

/// 配置警告Provider（新增）
final configurationWarningsProvider = Provider<List<String>>(
    (ref) => ref.watch(aiConfigurationStateProvider).warnings);

/// 配置是否可用Provider（新增）
final configurationUsabilityProvider =
    Provider<bool>((ref) => ref.watch(aiConfigurationStateProvider).isUsable);

/// 配置需要注意Provider（新增）
final configurationNeedsAttentionProvider = Provider<bool>(
    (ref) => ref.watch(aiConfigurationStateProvider).needsAttention);
