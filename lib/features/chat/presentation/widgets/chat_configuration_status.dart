import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/unified_chat_notifier.dart';
import '../../domain/entities/chat_state.dart';
import '../../domain/entities/chat_configuration.dart' as config_entity;
import '../../infrastructure/services/chat_configuration_validator.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';
import '../../../ai_management/presentation/providers/unified_ai_management_providers.dart';

/// 聊天配置状态显示组件 - 简化版
///
/// 显示当前聊天配置的状态。
///
/// 核心功能：
/// - 📊 **状态显示**: 显示配置是否完整
/// - 🚨 **问题提示**: 突出显示配置问题
/// - 🎨 **视觉反馈**: 使用颜色和图标表示状态
class ChatConfigurationStatus extends ConsumerWidget {
  const ChatConfigurationStatus({
    super.key,
    this.compact = false,
    this.showDetails = true,
    this.onFixRequested,
  });

  /// 是否使用紧凑模式
  final bool compact;

  /// 是否显示详细信息
  final bool showDetails;

  /// 修复请求回调
  final VoidCallback? onFixRequested;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatConfig = ref.watch(currentChatConfigurationProvider);
    final theme = Theme.of(context);

    // 同时监听提供商数据变化，确保配置状态能实时更新
    ref.watch(aiProvidersProvider);
    ref.watch(aiAssistantsProvider);

    // 转换为验证器期望的配置类型
    final validatorConfig = _convertToValidatorConfig(chatConfig, ref);

    // 检查配置是否有问题
    final configurationIssue =
        ChatConfigurationValidator.getConfigurationIssue(validatorConfig);
    final hasIssue = configurationIssue != null;

    // 如果没有问题且是紧凑模式，不显示任何内容
    if (!hasIssue && compact) {
      return const SizedBox.shrink();
    }

    if (compact) {
      return _buildCompactStatus(
          context, theme, chatConfig, configurationIssue);
    } else {
      return _buildDetailedStatus(
          context, theme, chatConfig, configurationIssue, validatorConfig);
    }
  }

  /// 转换为验证器期望的配置类型
  config_entity.ChatConfiguration? _convertToValidatorConfig(
    ChatConfiguration chatConfig,
    WidgetRef ref,
  ) {
    if (!chatConfig.isComplete) {
      return null;
    }

    // 获取最新的提供商数据，确保API密钥等信息是最新的
    final providers = ref.read(aiProvidersProvider);
    final latestProvider = providers
        .where((p) => p.id == chatConfig.selectedProvider!.id)
        .firstOrNull;

    // 如果找不到最新的提供商数据，使用原始数据
    final providerToUse = latestProvider ?? chatConfig.selectedProvider!;

    return config_entity.ChatConfiguration(
      assistant: chatConfig.selectedAssistant!,
      provider: providerToUse,
      model: chatConfig.selectedModel!,
    );
  }

  /// 构建紧凑状态显示
  Widget _buildCompactStatus(
    BuildContext context,
    ThemeData theme,
    ChatConfiguration chatConfig,
    String? configurationIssue,
  ) {
    final hasIssue = configurationIssue != null;
    final statusColor = hasIssue ? Colors.red : Colors.green;
    final statusIcon = hasIssue ? Icons.error : Icons.check_circle;
    final statusText = hasIssue ? '配置有问题' : '配置正常';

    return Container(
      padding: DesignConstants.paddingS,
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: DesignConstants.radiusS,
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: DesignConstants.iconSizeS,
            color: statusColor,
          ),
          SizedBox(width: DesignConstants.spaceXS),
          Text(
            statusText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (hasIssue && onFixRequested != null) ...[
            SizedBox(width: DesignConstants.spaceXS),
            GestureDetector(
              onTap: onFixRequested,
              child: Icon(
                Icons.settings,
                size: DesignConstants.iconSizeS,
                color: statusColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建详细状态显示
  Widget _buildDetailedStatus(
    BuildContext context,
    ThemeData theme,
    ChatConfiguration chatConfig,
    String? configurationIssue,
    config_entity.ChatConfiguration? validatorConfig,
  ) {
    final hasIssue = configurationIssue != null;
    final statusColor = hasIssue ? Colors.red : Colors.green;
    final statusIcon = hasIssue ? Icons.error : Icons.check_circle;
    final statusText = hasIssue ? '配置有问题' : '配置正常';

    return Card(
      child: Padding(
        padding: DesignConstants.paddingM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                ),
                SizedBox(width: DesignConstants.spaceS),
                Expanded(
                  child: Text(
                    statusText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (hasIssue) ...[
              SizedBox(height: DesignConstants.spaceS),
              Container(
                padding: DesignConstants.paddingS,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: DesignConstants.radiusS,
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: DesignConstants.iconSizeS,
                      color: statusColor,
                    ),
                    SizedBox(width: DesignConstants.spaceS),
                    Expanded(
                      child: Text(
                        configurationIssue,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (showDetails) ...[
              SizedBox(height: DesignConstants.spaceM),
              _buildConfigurationSummary(theme, chatConfig),
            ],
            if (hasIssue) ...[
              SizedBox(height: DesignConstants.spaceM),
              _buildFixSuggestions(theme, validatorConfig),
            ],
            if (onFixRequested != null && hasIssue) ...[
              SizedBox(height: DesignConstants.spaceM),
              ElevatedButton(
                onPressed: onFixRequested,
                child: const Text('去设置'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建配置摘要
  Widget _buildConfigurationSummary(
      ThemeData theme, ChatConfiguration chatConfig) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (chatConfig.selectedAssistant != null) ...[
          _buildConfigItem(
            theme,
            '助手',
            chatConfig.selectedAssistant!.name,
            Icons.smart_toy,
          ),
          SizedBox(height: DesignConstants.spaceS),
        ],
        if (chatConfig.selectedProvider != null) ...[
          _buildConfigItem(
            theme,
            '提供商',
            chatConfig.selectedProvider!.name,
            Icons.cloud,
          ),
          SizedBox(height: DesignConstants.spaceS),
        ],
        if (chatConfig.selectedModel != null) ...[
          _buildConfigItem(
            theme,
            '模型',
            chatConfig.selectedModel!.name,
            Icons.psychology,
          ),
        ],
      ],
    );
  }

  /// 构建配置项
  Widget _buildConfigItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: DesignConstants.iconSizeS,
          color: theme.colorScheme.primary,
        ),
        SizedBox(width: DesignConstants.spaceS),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  /// 构建修复建议
  Widget _buildFixSuggestions(
      ThemeData theme, config_entity.ChatConfiguration? chatConfig) {
    final suggestions =
        ChatConfigurationValidator.getFixSuggestions(chatConfig);

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: DesignConstants.iconSizeS,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: DesignConstants.spaceS),
            Text(
              '修复建议',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: DesignConstants.spaceS),
        ...suggestions.map((suggestion) => Padding(
              padding: EdgeInsets.only(bottom: DesignConstants.spaceXS),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 6),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: DesignConstants.spaceS),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
