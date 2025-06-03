import '../utils/validation.dart';
import '../utils/error_handler.dart';
import '../models/ai_provider.dart';
import '../models/ai_assistant.dart';
import '../models/message.dart';
import 'logger_service.dart';

/// 验证服务
class ValidationService {
  static final ValidationService _instance = ValidationService._();
  static ValidationService get instance => _instance;
  ValidationService._();

  final LoggerService _logger = LoggerService();

  /// 验证AI提供商
  void validateAiProvider(AiProvider provider) {
    _logger.debug('开始验证AI提供商: ${provider.name}');

    final result = AiProviderValidator.validateProvider(
      name: provider.name,
      apiKey: provider.apiKey,
      baseUrl: provider.baseUrl,
    );

    if (!result.isValid) {
      _logger.warning('AI提供商验证失败: ${provider.name}, 错误: ${result.errors}');

      throw ValidationError(
        message: 'AI提供商数据验证失败',
        fieldErrors: _groupErrorsByField(result.errors),
      );
    }

    _logger.debug('AI提供商验证成功: ${provider.name}');
  }

  /// 验证AI助手
  void validateAiAssistant(AiAssistant assistant) {
    _logger.debug('开始验证AI助手: ${assistant.name}');

    final result = AiAssistantValidator.validateAssistant(
      name: assistant.name,
      systemPrompt: assistant.systemPrompt,
      temperature: assistant.temperature,
      maxTokens: assistant.maxTokens,
    );

    if (!result.isValid) {
      _logger.warning('AI助手验证失败: ${assistant.name}, 错误: ${result.errors}');

      throw ValidationError(
        message: 'AI助手数据验证失败',
        fieldErrors: _groupErrorsByField(result.errors),
      );
    }

    _logger.debug('AI助手验证成功: ${assistant.name}');
  }

  /// 验证消息
  void validateMessage(Message message) {
    _logger.debug('开始验证消息，长度: ${message.content.length}');

    final errors = <String>[];

    final contentResult = MessageValidator.validateContent(message.content);
    if (!contentResult.isValid) errors.addAll(contentResult.errors);

    final authorResult = MessageValidator.validateAuthor(message.author);
    if (!authorResult.isValid) errors.addAll(authorResult.errors);

    if (errors.isNotEmpty) {
      _logger.warning('消息验证失败: $errors');

      throw ValidationError(
        message: '消息数据验证失败',
        fieldErrors: _groupErrorsByField(errors),
      );
    }

    _logger.debug('消息验证成功');
  }

  /// 验证API密钥格式
  bool isValidApiKey(String apiKey, String providerType) {
    _logger.debug('验证API密钥格式: $providerType, 长度: ${apiKey.length}');

    switch (providerType.toLowerCase()) {
      case 'openai':
        // OpenAI API密钥通常以sk-开头
        return apiKey.startsWith('sk-') && apiKey.length >= 20;

      case 'anthropic':
        // Anthropic API密钥通常以sk-ant-开头
        return apiKey.startsWith('sk-ant-') && apiKey.length >= 20;

      case 'google':
        // Google API密钥格式较为灵活
        return apiKey.length >= 20;

      case 'ollama':
        // Ollama通常不需要API密钥或使用简单格式
        return true;

      default:
        // 自定义提供商，基本长度检查
        return apiKey.length >= 10;
    }
  }

  /// 验证URL格式
  bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  /// 验证模型名称
  bool isValidModelName(String modelName) {
    // 模型名称不能为空，且不能包含特殊字符
    if (modelName.trim().isEmpty) return false;

    // 允许字母、数字、连字符、下划线和点号
    final regex = RegExp(r'^[a-zA-Z0-9\-_.]+$');
    return regex.hasMatch(modelName) && modelName.length <= 100;
  }

  /// 验证温度参数
  bool isValidTemperature(double temperature) {
    return temperature >= 0.0 && temperature <= 2.0;
  }

  /// 验证最大令牌数
  bool isValidMaxTokens(int maxTokens) {
    return maxTokens > 0 && maxTokens <= 100000;
  }

  /// 验证上下文长度
  bool isValidContextLength(int contextLength) {
    return contextLength > 0 && contextLength <= 1000000;
  }

  /// 批量验证
  ValidationResult validateBatch(List<Function()> validations) {
    final errors = <String>[];

    for (final validation in validations) {
      try {
        validation();
      } on ValidationError catch (e) {
        errors.add(e.message);
        if (e.fieldErrors != null) {
          for (final fieldError in e.fieldErrors!.entries) {
            errors.addAll(fieldError.value);
          }
        }
      } catch (e) {
        errors.add(e.toString());
      }
    }

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }

  /// 将错误按字段分组
  Map<String, List<String>> _groupErrorsByField(List<String> errors) {
    final grouped = <String, List<String>>{};

    for (final error in errors) {
      final parts = error.split(': ');
      if (parts.length >= 2) {
        final field = parts[0];
        final message = parts.sublist(1).join(': ');
        grouped.putIfAbsent(field, () => []).add(message);
      } else {
        grouped.putIfAbsent('general', () => []).add(error);
      }
    }

    return grouped;
  }

  /// 验证配置完整性
  ValidationResult validateConfiguration({
    required List<AiProvider> providers,
    required List<AiAssistant> assistants,
  }) {
    _logger.info(
      '开始验证配置完整性，提供商: ${providers.length}, 助手: ${assistants.length}',
    );

    final errors = <String>[];

    // 检查是否有启用的提供商
    final enabledProviders = providers.where((p) => p.isEnabled).toList();
    if (enabledProviders.isEmpty) {
      errors.add('至少需要一个启用的AI提供商');
    }

    // 检查是否有启用的助手
    final enabledAssistants = assistants.where((a) => a.isEnabled).toList();
    if (enabledAssistants.isEmpty) {
      errors.add('至少需要一个启用的AI助手');
    }

    // 不检查提供商API密钥
    // for (final provider in enabledProviders) {
    //   if (!isValidApiKey(provider.apiKey, provider.type.toString())) {
    //     errors.add('提供商 ${provider.name} 的API密钥格式不正确');
    //   }
    // }

    // 检查助手配置
    for (final assistant in enabledAssistants) {
      if (!isValidTemperature(assistant.temperature)) {
        errors.add('助手 ${assistant.name} 的温度参数不在有效范围内');
      }
      if (!isValidMaxTokens(assistant.maxTokens)) {
        errors.add('助手 ${assistant.name} 的最大令牌数不在有效范围内');
      }
    }

    final result = errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);

    _logger.info(
      '配置完整性验证完成，有效: ${result.isValid}, 错误数: ${result.errors.length}',
    );

    return result;
  }
}
