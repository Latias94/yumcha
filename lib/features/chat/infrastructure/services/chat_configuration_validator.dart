import '../../domain/entities/chat_configuration.dart';
import '../../../ai_management/domain/entities/ai_provider.dart';

/// 聊天配置验证服务
///
/// 负责验证聊天配置的完整性和有效性，提供配置问题诊断和修复建议。
///
/// 核心功能：
/// - ✅ **配置验证**: 检查配置的完整性和有效性
/// - 🔍 **问题诊断**: 识别具体的配置问题
/// - 💡 **修复建议**: 提供配置修复的具体建议
/// - 📊 **状态评估**: 评估配置的健康状态
/// - 🛠️ **自动修复**: 提供自动修复配置的方法
///
/// 验证规则：
/// - 助手必须存在且已启用
/// - 提供商必须存在且已启用
/// - 模型必须存在且属于选定的提供商
/// - 提供商必须有有效的API配置
class ChatConfigurationValidator {
  /// 验证聊天配置是否完整且有效
  ///
  /// 检查配置的所有必要组件是否存在且处于有效状态。
  ///
  /// **参数**:
  /// - [config]: 要验证的聊天配置
  ///
  /// **返回值**:
  /// - 返回配置是否有效的布尔值
  static bool isConfigurationValid(ChatConfiguration? config) {
    if (config == null) return false;

    // 检查助手是否启用
    if (!config.assistant.isEnabled) {
      return false;
    }

    // 检查提供商是否启用
    if (!config.provider.isEnabled) {
      return false;
    }

    // 检查模型是否属于选定的提供商
    final modelExists = config.provider.models.any(
      (model) => model.name == config.model.name,
    );
    if (!modelExists) {
      return false;
    }

    // 检查提供商是否有有效的API配置
    if (!_hasValidApiConfiguration(config.provider)) {
      return false;
    }

    return true;
  }

  /// 获取配置问题的详细描述
  ///
  /// 分析配置并返回具体的问题描述，用于向用户展示。
  ///
  /// **参数**:
  /// - [config]: 要分析的聊天配置
  ///
  /// **返回值**:
  /// - 返回问题描述字符串，如果没有问题则返回null
  static String? getConfigurationIssue(ChatConfiguration? config) {
    if (config == null) {
      return '聊天配置不存在，请重新配置';
    }

    // 检查助手是否启用
    if (!config.assistant.isEnabled) {
      return '当前助手已被禁用，请选择其他助手';
    }

    // 检查提供商是否启用
    if (!config.provider.isEnabled) {
      return '当前提供商已被禁用，请选择其他提供商';
    }

    // 检查模型是否属于提供商
    final modelExists = config.provider.models.any(
      (model) => model.name == config.model.name,
    );
    if (!modelExists) {
      return '选定的模型不属于当前提供商，请重新选择模型';
    }

    // 检查API配置
    if (!_hasValidApiConfiguration(config.provider)) {
      return '提供商API配置无效，请检查API密钥和连接设置';
    }

    return null; // 没有问题
  }

  /// 获取配置修复建议
  ///
  /// 基于配置问题提供具体的修复建议和操作指导。
  ///
  /// **参数**:
  /// - [config]: 要分析的聊天配置
  ///
  /// **返回值**:
  /// - 返回修复建议列表
  static List<String> getFixSuggestions(ChatConfiguration? config) {
    final suggestions = <String>[];

    if (config == null) {
      suggestions.add('前往设置页面配置AI助手和提供商');
      suggestions.add('确保至少有一个助手和提供商处于启用状态');
      return suggestions;
    }

    // 助手相关建议
    if (!config.assistant.isEnabled) {
      suggestions.add('在助手管理页面启用当前助手');
      suggestions.add('或者选择其他已启用的助手');
    }

    // 提供商相关建议
    if (!config.provider.isEnabled) {
      suggestions.add('在提供商管理页面启用当前提供商');
      suggestions.add('或者选择其他已启用的提供商');
    }

    // 模型相关建议
    final modelExists = config.provider.models.any(
      (model) => model.name == config.model.name,
    );
    if (!modelExists) {
      suggestions.add('选择属于当前提供商的模型');
      suggestions.add('或者切换到包含此模型的提供商');
    }

    // API配置建议
    if (!_hasValidApiConfiguration(config.provider)) {
      suggestions.add('检查提供商的API密钥是否正确');
      suggestions.add('验证网络连接和API服务可用性');
      suggestions.add('确认API配额和权限设置');
    }

    return suggestions;
  }

  /// 评估配置健康状态
  ///
  /// 返回配置的健康评分和状态描述。
  ///
  /// **参数**:
  /// - [config]: 要评估的聊天配置
  ///
  /// **返回值**:
  /// - 返回包含评分(0-100)和状态描述的记录
  static ({int score, String status, String description})
      evaluateConfigurationHealth(
    ChatConfiguration? config,
  ) {
    if (config == null) {
      return (score: 0, status: '严重', description: '配置不存在，无法进行聊天');
    }

    int score = 0;
    final issues = <String>[];

    // 助手检查 (25分)
    if (config.assistant.isEnabled) {
      score += 25;
    } else {
      score += 10;
      issues.add('助手已禁用');
    }

    // 提供商检查 (35分)
    if (config.provider.isEnabled) {
      score += 25;
      if (_hasValidApiConfiguration(config.provider)) {
        score += 10;
      } else {
        issues.add('API配置无效');
      }
    } else {
      score += 10;
      issues.add('提供商已禁用');
    }

    // 模型检查 (25分)
    final modelExists = config.provider.models.any(
      (model) => model.name == config.model.name,
    );
    if (modelExists) {
      score += 25;
    } else {
      score += 10;
      issues.add('模型不匹配');
    }

    // 完整性奖励 (15分)
    if (isConfigurationValid(config)) {
      score += 15;
    }

    // 确保分数在0-100范围内
    score = score.clamp(0, 100);

    // 确定状态和描述
    String status;
    String description;

    if (score >= 90) {
      status = '优秀';
      description = '配置完整且健康，可以正常使用';
    } else if (score >= 70) {
      status = '良好';
      description = '配置基本正常，有轻微问题：${issues.join('、')}';
    } else if (score >= 50) {
      status = '一般';
      description = '配置存在问题，需要修复：${issues.join('、')}';
    } else if (score >= 30) {
      status = '较差';
      description = '配置问题较多，建议重新配置：${issues.join('、')}';
    } else {
      status = '严重';
      description = '配置严重不完整，无法正常使用：${issues.join('、')}';
    }

    return (score: score, status: status, description: description);
  }

  /// 检查提供商是否有有效的API配置
  ///
  /// 验证提供商的API密钥、Base URL等配置是否有效。
  ///
  /// **参数**:
  /// - [provider]: 要检查的AI提供商
  ///
  /// **返回值**:
  /// - 返回API配置是否有效的布尔值
  static bool _hasValidApiConfiguration(AiProvider provider) {
    // 检查API密钥
    if (provider.apiKey.trim().isEmpty) {
      return false;
    }

    // 检查Base URL（如果需要）
    if (provider.baseUrl != null && provider.baseUrl!.trim().isEmpty) {
      return false;
    }

    // 可以添加更多的API配置验证逻辑
    // 例如：检查API密钥格式、测试连接等

    return true;
  }
}
