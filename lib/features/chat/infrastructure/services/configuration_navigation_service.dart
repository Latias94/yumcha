import 'package:flutter/material.dart';
import '../../../ai_management/domain/entities/ai_provider.dart';
import '../../domain/entities/chat_configuration.dart';
import './chat_configuration_validator.dart';
import '../../../../app/navigation/app_router.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';

/// 导航目标类型
enum NavigationTarget {
  /// 提供商管理页面
  providers,

  /// 助手管理页面
  assistants,

  /// 通用设置页面
  settings,

  /// 提供商编辑页面（带特定提供商参数）
  providerEdit,

  /// 助手编辑页面（带特定助手参数）
  assistantEdit,
}

/// 导航结果
class NavigationResult {
  final NavigationTarget target;
  final String routeName;
  final Map<String, dynamic>? arguments;
  final String description;

  const NavigationResult({
    required this.target,
    required this.routeName,
    this.arguments,
    required this.description,
  });
}

/// 配置导航服务
///
/// 提供智能导航功能，根据配置问题类型自动导航到最合适的设置页面。
///
/// 核心功能：
/// - 🧠 **智能分析**: 分析配置问题并确定最佳导航目标
/// - 🎯 **精准导航**: 直接跳转到相关的设置页面
/// - 📊 **问题分类**: 根据问题类型提供不同的导航策略
/// - 🔄 **回退机制**: 提供通用设置页面作为回退选项
class ConfigurationNavigationService {
  static final LoggerService _logger = LoggerService();

  /// 根据配置问题智能确定导航目标
  ///
  /// 分析当前配置状态和问题类型，返回最合适的导航目标。
  ///
  /// **参数**:
  /// - [config]: 当前聊天配置
  /// - [issue]: 配置问题描述
  /// - [suggestions]: 修复建议列表
  ///
  /// **返回值**:
  /// - 返回包含导航目标和参数的 NavigationResult
  static NavigationResult determineNavigationTarget({
    ChatConfiguration? config,
    String? issue,
    List<String> suggestions = const [],
  }) {
    _logger.info('分析配置问题以确定导航目标', {
      'hasConfig': config != null,
      'issue': issue,
      'suggestionsCount': suggestions.length,
    });

    // 如果没有配置，导航到通用设置页面
    if (config == null) {
      return const NavigationResult(
        target: NavigationTarget.settings,
        routeName: AppRouter.settings,
        description: '配置不存在，前往设置页面进行初始配置',
      );
    }

    // 分析具体问题类型
    if (issue != null) {
      // API密钥相关问题 - 导航到提供商页面
      if (issue.contains('API') ||
          issue.contains('密钥') ||
          issue.contains('连接')) {
        return NavigationResult(
          target: NavigationTarget.providerEdit,
          routeName: AppRouter.providerEdit,
          arguments: {'provider': config.provider},
          description: 'API配置问题，前往提供商设置页面检查API密钥',
        );
      }

      // 助手相关问题 - 导航到助手页面
      if (issue.contains('助手') && issue.contains('禁用')) {
        return NavigationResult(
          target: NavigationTarget.assistantEdit,
          routeName: AppRouter.assistantEdit,
          arguments: {
            'assistant': config.assistant,
            'providers': <AiProvider>[config.provider],
          },
          description: '助手已禁用，前往助手设置页面启用助手',
        );
      }

      // 提供商相关问题 - 导航到提供商页面
      if (issue.contains('提供商') && issue.contains('禁用')) {
        return NavigationResult(
          target: NavigationTarget.providerEdit,
          routeName: AppRouter.providerEdit,
          arguments: {'provider': config.provider},
          description: '提供商已禁用，前往提供商设置页面启用提供商',
        );
      }

      // 模型相关问题 - 导航到提供商页面选择模型
      if (issue.contains('模型') || issue.contains('不属于')) {
        return const NavigationResult(
          target: NavigationTarget.providers,
          routeName: AppRouter.providers,
          description: '模型配置问题，前往提供商管理页面重新选择模型',
        );
      }
    }

    // 分析修复建议
    for (final suggestion in suggestions) {
      // 如果建议中提到提供商管理
      if (suggestion.contains('提供商管理') || suggestion.contains('API密钥')) {
        return NavigationResult(
          target: NavigationTarget.providerEdit,
          routeName: AppRouter.providerEdit,
          arguments: {'provider': config.provider},
          description: '根据修复建议，前往提供商设置页面',
        );
      }

      // 如果建议中提到助手管理
      if (suggestion.contains('助手管理')) {
        return NavigationResult(
          target: NavigationTarget.assistantEdit,
          routeName: AppRouter.assistantEdit,
          arguments: {
            'assistant': config.assistant,
            'providers': <AiProvider>[config.provider],
          },
          description: '根据修复建议，前往助手设置页面',
        );
      }
    }

    // 根据配置健康状态决定
    final health =
        ChatConfigurationValidator.evaluateConfigurationHealth(config);

    if (health.score < 50) {
      // 健康状态较差，可能需要重新配置
      // 检查是否是API配置问题（通过检查API密钥是否为空）
      if (config.provider.apiKey.trim().isEmpty) {
        return NavigationResult(
          target: NavigationTarget.providerEdit,
          routeName: AppRouter.providerEdit,
          arguments: {'provider': config.provider},
          description: '配置健康状态较差，主要是API配置问题，前往提供商设置页面',
        );
      }
    }

    // 默认情况：导航到通用设置页面
    return const NavigationResult(
      target: NavigationTarget.settings,
      routeName: AppRouter.settings,
      description: '前往设置页面检查和修复配置问题',
    );
  }

  /// 执行智能导航
  ///
  /// 根据配置问题执行智能导航到最合适的设置页面。
  ///
  /// **参数**:
  /// - [context]: 当前构建上下文
  /// - [config]: 当前聊天配置
  /// - [issue]: 配置问题描述
  /// - [suggestions]: 修复建议列表
  ///
  /// **返回值**:
  /// - 返回导航操作的 Future
  static Future<void> navigateToFix(
    BuildContext context, {
    ChatConfiguration? config,
    String? issue,
    List<String> suggestions = const [],
  }) async {
    final result = determineNavigationTarget(
      config: config,
      issue: issue,
      suggestions: suggestions,
    );

    _logger.info('执行智能导航', {
      'target': result.target.name,
      'routeName': result.routeName,
      'hasArguments': result.arguments != null,
      'description': result.description,
    });

    try {
      await AppRouter.pushNamed(
        context,
        result.routeName,
        arguments: result.arguments,
      );
    } catch (e) {
      _logger.error('导航失败', {
        'error': e.toString(),
        'routeName': result.routeName,
      });

      // 导航失败时回退到通用设置页面
      if (result.routeName != AppRouter.settings && context.mounted) {
        _logger.info('回退到通用设置页面');
        await AppRouter.pushNamed(context, AppRouter.settings);
      }
    }
  }

  /// 获取导航按钮文本
  ///
  /// 根据配置问题返回更具体的按钮文本。
  ///
  /// **参数**:
  /// - [config]: 当前聊天配置
  /// - [issue]: 配置问题描述
  /// - [suggestions]: 修复建议列表
  ///
  /// **返回值**:
  /// - 返回按钮显示的文本
  static String getNavigationButtonText({
    ChatConfiguration? config,
    String? issue,
    List<String> suggestions = const [],
  }) {
    final result = determineNavigationTarget(
      config: config,
      issue: issue,
      suggestions: suggestions,
    );

    switch (result.target) {
      case NavigationTarget.providers:
        return '前往提供商设置';
      case NavigationTarget.assistants:
        return '前往助手设置';
      case NavigationTarget.providerEdit:
        return '检查API配置';
      case NavigationTarget.assistantEdit:
        return '配置助手';
      case NavigationTarget.settings:
        return '前往设置';
    }
  }
}
