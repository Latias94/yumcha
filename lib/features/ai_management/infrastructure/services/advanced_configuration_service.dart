// 🔄 高级配置管理服务
//
// 提供高级配置管理功能，包括配置模板、验证、历史追踪、批量操作等。
// 为用户提供专业级的配置管理体验。
//
// 🎯 **核心功能**:
// - 📋 **配置模板**: 预定义的配置模板和自定义模板
// - ✅ **配置验证**: 深度配置验证和兼容性检查
// - 📊 **配置分析**: 配置使用情况分析和优化建议
// - 🔄 **批量操作**: 批量导入导出和配置同步
// - 📈 **历史追踪**: 配置变更历史和版本管理
//
// 🛡️ **企业级特性**:
// - 配置模板管理
// - 高级验证规则
// - 性能优化建议
// - 安全性检查

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/services/logger_service.dart';
import '../../../../shared/presentation/providers/dependency_providers.dart';
import '../../domain/entities/configuration_export_models.dart';
import '../../domain/entities/ai_provider.dart';
import '../../domain/entities/ai_assistant.dart';
import '../../data/repositories/provider_repository.dart';
import '../../data/repositories/assistant_repository.dart';
import 'configuration_import_service.dart';

/// 配置模板类型
enum ConfigurationTemplateType {
  provider('提供商模板'),
  assistant('助手模板'),
  complete('完整配置模板'),
  custom('自定义模板');

  const ConfigurationTemplateType(this.displayName);
  final String displayName;
}

/// 配置模板
class ConfigurationTemplate {
  final String id;
  final String name;
  final String description;
  final ConfigurationTemplateType type;
  final Map<String, dynamic> templateData;
  final List<String> tags;
  final DateTime createdAt;
  final bool isBuiltIn;

  const ConfigurationTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.templateData,
    this.tags = const [],
    required this.createdAt,
    this.isBuiltIn = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.name,
    'templateData': templateData,
    'tags': tags,
    'createdAt': createdAt.toIso8601String(),
    'isBuiltIn': isBuiltIn,
  };

  factory ConfigurationTemplate.fromJson(Map<String, dynamic> json) {
    return ConfigurationTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: ConfigurationTemplateType.values.firstWhere(
        (t) => t.name == json['type'],
      ),
      templateData: Map<String, dynamic>.from(json['templateData'] as Map),
      tags: List<String>.from(json['tags'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
    );
  }
}

/// 配置分析结果
class ConfigurationAnalysis {
  final int totalProviders;
  final int enabledProviders;
  final int totalAssistants;
  final int enabledAssistants;
  final List<String> recommendations;
  final List<String> warnings;
  final Map<String, dynamic> statistics;

  const ConfigurationAnalysis({
    required this.totalProviders,
    required this.enabledProviders,
    required this.totalAssistants,
    required this.enabledAssistants,
    this.recommendations = const [],
    this.warnings = const [],
    this.statistics = const {},
  });
}

/// 批量操作结果
class BatchOperationResult {
  final int totalItems;
  final int successCount;
  final int failureCount;
  final List<String> errors;
  final Duration duration;

  const BatchOperationResult({
    required this.totalItems,
    required this.successCount,
    required this.failureCount,
    this.errors = const [],
    required this.duration,
  });

  bool get isSuccess => failureCount == 0;
  double get successRate => totalItems > 0 ? successCount / totalItems : 0.0;
}

/// 高级配置管理服务
class AdvancedConfigurationService {
  AdvancedConfigurationService(this._ref);

  final Ref _ref;
  final LoggerService _logger = LoggerService();

  /// 获取服务实例
  ProviderRepository get _providerRepository => _ref.read(providerRepositoryProvider);
  AssistantRepository get _assistantRepository => _ref.read(assistantRepositoryProvider);
  ConfigurationImportService get _importService => _ref.read(configurationImportServiceProvider);

  /// 获取内置配置模板
  List<ConfigurationTemplate> getBuiltInTemplates() {
    return [
      // OpenAI 提供商模板
      ConfigurationTemplate(
        id: 'template_openai_provider',
        name: 'OpenAI 提供商',
        description: '标准的 OpenAI API 提供商配置',
        type: ConfigurationTemplateType.provider,
        templateData: {
          'type': 'openai',
          'name': 'OpenAI',
          'baseUrl': 'https://api.openai.com/v1',
          'models': [
            {'name': 'gpt-4o', 'displayName': 'GPT-4o'},
            {'name': 'gpt-4o-mini', 'displayName': 'GPT-4o Mini'},
            {'name': 'gpt-3.5-turbo', 'displayName': 'GPT-3.5 Turbo'},
          ],
        },
        tags: ['openai', 'provider', 'builtin'],
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),

      // Claude 提供商模板
      ConfigurationTemplate(
        id: 'template_claude_provider',
        name: 'Anthropic Claude 提供商',
        description: '标准的 Anthropic Claude API 提供商配置',
        type: ConfigurationTemplateType.provider,
        templateData: {
          'type': 'anthropic',
          'name': 'Anthropic',
          'baseUrl': 'https://api.anthropic.com',
          'models': [
            {'name': 'claude-3-5-sonnet-20241022', 'displayName': 'Claude 3.5 Sonnet'},
            {'name': 'claude-3-5-haiku-20241022', 'displayName': 'Claude 3.5 Haiku'},
            {'name': 'claude-3-opus-20240229', 'displayName': 'Claude 3 Opus'},
          ],
        },
        tags: ['anthropic', 'claude', 'provider', 'builtin'],
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),

      // 通用助手模板
      ConfigurationTemplate(
        id: 'template_general_assistant',
        name: '通用AI助手',
        description: '适用于日常对话的通用助手配置',
        type: ConfigurationTemplateType.assistant,
        templateData: {
          'name': '通用助手',
          'description': '适用于日常对话和问答的AI助手',
          'systemPrompt': '你是一个有用、无害、诚实的AI助手。请用中文回答用户的问题。',
          'temperature': 0.7,
          'maxTokens': 4000,
          'streamOutput': true,
        },
        tags: ['assistant', 'general', 'builtin'],
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),

      // 编程助手模板
      ConfigurationTemplate(
        id: 'template_coding_assistant',
        name: '编程助手',
        description: '专门用于编程和代码相关任务的助手配置',
        type: ConfigurationTemplateType.assistant,
        templateData: {
          'name': '编程助手',
          'description': '专业的编程和代码助手',
          'systemPrompt': '你是一个专业的编程助手。请帮助用户解决编程问题，提供清晰的代码示例和解释。',
          'temperature': 0.3,
          'maxTokens': 8000,
          'streamOutput': true,
          'enableCodeExecution': true,
          'enableTools': true,
        },
        tags: ['assistant', 'coding', 'programming', 'builtin'],
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ];
  }

  /// 分析当前配置
  Future<ConfigurationAnalysis> analyzeConfiguration() async {
    try {
      _logger.info('开始分析配置');

      final providers = await _providerRepository.getAllProviders();
      final assistants = await _assistantRepository.getAllAssistants();

      final enabledProviders = providers.where((p) => p.isEnabled).length;
      final enabledAssistants = assistants.where((a) => a.isEnabled).length;

      final recommendations = <String>[];
      final warnings = <String>[];

      // 生成建议
      if (enabledProviders == 0) {
        warnings.add('没有启用的AI提供商，无法进行对话');
      } else if (enabledProviders == 1) {
        recommendations.add('建议配置多个AI提供商以提供备选方案');
      }

      if (enabledAssistants == 0) {
        warnings.add('没有启用的AI助手，无法进行对话');
      } else if (enabledAssistants > 10) {
        recommendations.add('助手数量较多，建议整理和分类管理');
      }

      // 检查API密钥
      final providersWithoutKey = providers.where((p) => 
        p.isEnabled && (p.apiKey.isEmpty || p.apiKey == 'your-api-key-here')
      ).length;
      
      if (providersWithoutKey > 0) {
        warnings.add('有 $providersWithoutKey 个启用的提供商缺少有效的API密钥');
      }

      // 统计信息
      final statistics = {
        'providersByType': _groupProvidersByType(providers),
        'assistantsByType': _groupAssistantsByType(assistants),
        'averageTemperature': _calculateAverageTemperature(assistants),
        'totalModels': providers.fold<int>(0, (sum, p) => sum + p.models.length),
      };

      final analysis = ConfigurationAnalysis(
        totalProviders: providers.length,
        enabledProviders: enabledProviders,
        totalAssistants: assistants.length,
        enabledAssistants: enabledAssistants,
        recommendations: recommendations,
        warnings: warnings,
        statistics: statistics,
      );

      _logger.info('配置分析完成', {
        'totalProviders': analysis.totalProviders,
        'enabledProviders': analysis.enabledProviders,
        'totalAssistants': analysis.totalAssistants,
        'enabledAssistants': analysis.enabledAssistants,
        'recommendationCount': recommendations.length,
        'warningCount': warnings.length,
      });

      return analysis;

    } catch (error, stackTrace) {
      _logger.error('配置分析失败', {
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
      });
      rethrow;
    }
  }

  /// 批量导入配置
  Future<BatchOperationResult> batchImportConfigurations(
    List<String> filePaths, {
    ConflictResolutionStrategy strategy = ConflictResolutionStrategy.ask,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      _logger.info('开始批量导入配置', {
        'fileCount': filePaths.length,
        'strategy': strategy.name,
      });

      int successCount = 0;
      final errors = <String>[];

      for (final filePath in filePaths) {
        try {
          final result = await _importService.importConfiguration(
            filePath,
            strategy: strategy,
            validateBeforeImport: true,
            createBackupBeforeImport: false, // 批量操作时不创建单独备份
          );

          if (result.success) {
            successCount++;
          } else {
            errors.addAll(result.errors);
          }
        } catch (error) {
          errors.add('导入 $filePath 失败: $error');
        }
      }

      stopwatch.stop();

      final result = BatchOperationResult(
        totalItems: filePaths.length,
        successCount: successCount,
        failureCount: filePaths.length - successCount,
        errors: errors,
        duration: stopwatch.elapsed,
      );

      _logger.info('批量导入完成', {
        'totalItems': result.totalItems,
        'successCount': result.successCount,
        'failureCount': result.failureCount,
        'successRate': '${(result.successRate * 100).toStringAsFixed(1)}%',
        'duration': '${stopwatch.elapsedMilliseconds}ms',
      });

      return result;

    } catch (error, stackTrace) {
      stopwatch.stop();
      _logger.error('批量导入失败', {
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
      });
      
      return BatchOperationResult(
        totalItems: filePaths.length,
        successCount: 0,
        failureCount: filePaths.length,
        errors: ['批量导入失败: $error'],
        duration: stopwatch.elapsed,
      );
    }
  }

  /// 验证配置完整性
  Future<ValidationResult> validateConfigurationIntegrity() async {
    try {
      _logger.info('开始验证配置完整性');

      final errors = <String>[];
      final warnings = <String>[];

      // 验证提供商
      final providers = await _providerRepository.getAllProviders();
      for (final provider in providers) {
        final providerErrors = _validateProviderIntegrity(provider);
        errors.addAll(providerErrors);
      }

      // 验证助手
      final assistants = await _assistantRepository.getAllAssistants();
      for (final assistant in assistants) {
        final assistantErrors = _validateAssistantIntegrity(assistant);
        errors.addAll(assistantErrors);
      }

      // 验证关联关系
      final relationshipWarnings = _validateRelationships(providers, assistants);
      warnings.addAll(relationshipWarnings);

      final result = ValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
      );

      _logger.info('配置完整性验证完成', {
        'isValid': result.isValid,
        'errorCount': errors.length,
        'warningCount': warnings.length,
      });

      return result;

    } catch (error) {
      _logger.error('配置完整性验证失败', {
        'error': error.toString(),
      });
      
      return ValidationResult(
        isValid: false,
        errors: ['验证失败: $error'],
      );
    }
  }

  /// 按类型分组提供商
  Map<String, int> _groupProvidersByType(List<AiProvider> providers) {
    final groups = <String, int>{};
    for (final provider in providers) {
      final type = provider.type.toString();
      groups[type] = (groups[type] ?? 0) + 1;
    }
    return groups;
  }

  /// 按类型分组助手
  Map<String, int> _groupAssistantsByType(List<AiAssistant> assistants) {
    // 这里可以根据助手的特性进行分类
    final groups = <String, int>{
      'general': 0,
      'coding': 0,
      'creative': 0,
      'other': 0,
    };

    for (final assistant in assistants) {
      if (assistant.enableCodeExecution || assistant.enableTools) {
        groups['coding'] = groups['coding']! + 1;
      } else if (assistant.enableImageGeneration) {
        groups['creative'] = groups['creative']! + 1;
      } else {
        groups['general'] = groups['general']! + 1;
      }
    }

    return groups;
  }

  /// 计算平均温度
  double _calculateAverageTemperature(List<AiAssistant> assistants) {
    if (assistants.isEmpty) return 0.0;
    
    final totalTemp = assistants.fold<double>(
      0.0, 
      (sum, assistant) => sum + assistant.temperature,
    );
    
    return totalTemp / assistants.length;
  }

  /// 验证提供商完整性
  List<String> _validateProviderIntegrity(AiProvider provider) {
    final errors = <String>[];

    if (provider.name.isEmpty) {
      errors.add('提供商 ${provider.id} 缺少名称');
    }

    if (provider.isEnabled && provider.apiKey.isEmpty) {
      errors.add('启用的提供商 ${provider.name} 缺少API密钥');
    }

    if (provider.models.isEmpty) {
      errors.add('提供商 ${provider.name} 没有配置模型');
    }

    return errors;
  }

  /// 验证助手完整性
  List<String> _validateAssistantIntegrity(AiAssistant assistant) {
    final errors = <String>[];

    if (assistant.name.isEmpty) {
      errors.add('助手 ${assistant.id} 缺少名称');
    }

    if (assistant.systemPrompt.isEmpty) {
      errors.add('助手 ${assistant.name} 缺少系统提示');
    }

    if (assistant.temperature < 0 || assistant.temperature > 2) {
      errors.add('助手 ${assistant.name} 的温度参数超出有效范围 (0-2)');
    }

    if (assistant.maxTokens <= 0) {
      errors.add('助手 ${assistant.name} 的最大令牌数必须大于0');
    }

    return errors;
  }

  /// 验证关联关系
  List<String> _validateRelationships(
    List<AiProvider> providers,
    List<AiAssistant> assistants,
  ) {
    final warnings = <String>[];

    final enabledProviders = providers.where((p) => p.isEnabled).toList();
    final enabledAssistants = assistants.where((a) => a.isEnabled).toList();

    if (enabledProviders.isEmpty && enabledAssistants.isNotEmpty) {
      warnings.add('有启用的助手但没有启用的提供商');
    }

    if (enabledProviders.isNotEmpty && enabledAssistants.isEmpty) {
      warnings.add('有启用的提供商但没有启用的助手');
    }

    return warnings;
  }
}

/// 高级配置管理服务Provider
final advancedConfigurationServiceProvider = Provider<AdvancedConfigurationService>(
  (ref) => AdvancedConfigurationService(ref),
);
