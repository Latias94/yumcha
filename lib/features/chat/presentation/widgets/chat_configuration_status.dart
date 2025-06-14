import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/unified_chat_notifier.dart';
import '../../domain/entities/chat_state.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';

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
    final chatConfig = ref.watch(chatConfigurationProvider);
    final theme = Theme.of(context);

    if (compact) {
      return _buildCompactStatus(context, theme, chatConfig);
    } else {
      return _buildDetailedStatus(context, theme, chatConfig);
    }
  }

  /// 构建紧凑状态显示
  Widget _buildCompactStatus(
    BuildContext context,
    ThemeData theme,
    ChatConfiguration chatConfig,
  ) {
    final isComplete = chatConfig.isComplete;
    final statusColor = isComplete ? Colors.green : Colors.orange;
    final statusIcon = isComplete ? Icons.check_circle : Icons.warning;
    final statusText = isComplete ? '配置完整' : '配置不完整';

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
          if (!isComplete && onFixRequested != null) ...[
            SizedBox(width: DesignConstants.spaceXS),
            GestureDetector(
              onTap: onFixRequested,
              child: Icon(
                Icons.warning_amber_rounded,
                size: DesignConstants.iconSizeS,
                color: Colors.orange,
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
  ) {
    final isComplete = chatConfig.isComplete;
    
    return Card(
      child: Padding(
        padding: DesignConstants.paddingM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isComplete ? Icons.check_circle : Icons.warning,
                  color: isComplete ? Colors.green : Colors.orange,
                ),
                SizedBox(width: DesignConstants.spaceS),
                Text(
                  isComplete ? '配置完整' : '配置不完整',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isComplete ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (showDetails) ...[
              SizedBox(height: DesignConstants.spaceM),
              _buildConfigurationSummary(theme, chatConfig),
            ],
            if (onFixRequested != null && !isComplete) ...[
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
  Widget _buildConfigurationSummary(ThemeData theme, ChatConfiguration chatConfig) {
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
}
