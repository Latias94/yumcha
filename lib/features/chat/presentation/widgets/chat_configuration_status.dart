import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_configuration_monitor.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';

/// 聊天配置状态显示组件
///
/// 显示当前聊天配置的健康状态、问题诊断和修复建议。
/// 提供用户友好的配置状态反馈和操作指导。
///
/// 核心功能：
/// - 📊 **状态显示**: 显示配置健康分数和状态
/// - 🚨 **问题提示**: 突出显示配置问题
/// - 💡 **修复建议**: 提供具体的修复操作建议
/// - 🎨 **视觉反馈**: 使用颜色和图标表示状态
/// - 🔄 **实时更新**: 实时反映配置变化
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
    final monitor = ref.watch(chatConfigurationMonitorProvider);
    final theme = Theme.of(context);

    if (compact) {
      return _buildCompactStatus(context, theme, monitor);
    } else {
      return _buildDetailedStatus(context, theme, monitor);
    }
  }

  /// 构建紧凑状态显示
  Widget _buildCompactStatus(
    BuildContext context,
    ThemeData theme,
    ChatConfigurationMonitorState monitor,
  ) {
    final statusColor = _getStatusColor(theme, monitor);
    final statusIcon = _getStatusIcon(monitor);

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
            '${monitor.healthScore}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (monitor.needsAttention) ...[
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
    ChatConfigurationMonitorState monitor,
  ) {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和健康分数
            _buildStatusHeader(theme, monitor),

            if (showDetails) ...[
              SizedBox(height: DesignConstants.spaceM),

              // 配置详情
              _buildConfigurationDetails(theme, monitor),

              // 问题和建议
              if (monitor.issue != null ||
                  monitor.fixSuggestions.isNotEmpty) ...[
                SizedBox(height: DesignConstants.spaceM),
                _buildIssuesAndSuggestions(theme, monitor),
              ],
            ],
          ],
        ),
      ),
    );
  }

  /// 构建状态标题
  Widget _buildStatusHeader(
      ThemeData theme, ChatConfigurationMonitorState monitor) {
    final statusColor = _getStatusColor(theme, monitor);
    final statusIcon = _getStatusIcon(monitor);

    return Row(
      children: [
        Icon(
          statusIcon,
          color: statusColor,
          size: DesignConstants.iconSizeM,
        ),
        SizedBox(width: DesignConstants.spaceS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '配置状态: ${monitor.healthStatus}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '健康分数: ${monitor.healthScore}/100',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        // 健康分数圆形指示器
        _buildHealthScoreIndicator(theme, monitor),
      ],
    );
  }

  /// 构建健康分数指示器
  Widget _buildHealthScoreIndicator(
      ThemeData theme, ChatConfigurationMonitorState monitor) {
    final statusColor = _getStatusColor(theme, monitor);
    final progress = monitor.healthScore / 100.0;

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          // 背景圆环
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 4,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          // 进度圆环
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation(statusColor),
          ),
          // 分数文本
          Center(
            child: Text(
              '${monitor.healthScore}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建配置详情
  Widget _buildConfigurationDetails(
      ThemeData theme, ChatConfigurationMonitorState monitor) {
    final config = monitor.configuration;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '配置详情',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: DesignConstants.spaceS),

        // 助手信息
        _buildConfigItem(
          theme,
          '助手',
          config?.assistant.name ?? '未选择',
          config?.assistant.isEnabled == true,
        ),

        // 提供商信息
        _buildConfigItem(
          theme,
          '提供商',
          config?.provider.name ?? '未选择',
          config?.provider.isEnabled == true,
        ),

        // 模型信息
        _buildConfigItem(
          theme,
          '模型',
          config?.model.name ?? '未选择',
          config != null,
        ),
      ],
    );
  }

  /// 构建配置项
  Widget _buildConfigItem(
      ThemeData theme, String label, String value, bool isValid) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignConstants.spaceXS),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.error,
            size: DesignConstants.iconSizeS,
            color:
                isValid ? theme.colorScheme.primary : theme.colorScheme.error,
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
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isValid
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建问题和建议
  Widget _buildIssuesAndSuggestions(
      ThemeData theme, ChatConfigurationMonitorState monitor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 问题显示
        if (monitor.issue != null) ...[
          Container(
            padding: DesignConstants.paddingS,
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: DesignConstants.radiusS,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: theme.colorScheme.onErrorContainer,
                  size: DesignConstants.iconSizeS,
                ),
                SizedBox(width: DesignConstants.spaceS),
                Expanded(
                  child: Text(
                    monitor.issue!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: DesignConstants.spaceS),
        ],

        // 修复建议
        if (monitor.fixSuggestions.isNotEmpty) ...[
          Text(
            '修复建议',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: DesignConstants.spaceS),
          ...monitor.fixSuggestions.map((suggestion) => Padding(
                padding: EdgeInsets.only(bottom: DesignConstants.spaceXS),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: DesignConstants.iconSizeS,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: DesignConstants.spaceS),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),

          // 修复按钮
          if (onFixRequested != null) ...[
            SizedBox(height: DesignConstants.spaceS),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onFixRequested,
                icon: const Icon(Icons.build),
                label: const Text('前往修复'),
              ),
            ),
          ],
        ],
      ],
    );
  }

  /// 获取状态颜色
  Color _getStatusColor(
      ThemeData theme, ChatConfigurationMonitorState monitor) {
    if (monitor.healthScore >= 90) {
      return theme.colorScheme.primary;
    } else if (monitor.healthScore >= 70) {
      return Colors.blue;
    } else if (monitor.healthScore >= 50) {
      return Colors.orange;
    } else {
      return theme.colorScheme.error;
    }
  }

  /// 获取状态图标
  IconData _getStatusIcon(ChatConfigurationMonitorState monitor) {
    if (monitor.healthScore >= 90) {
      return Icons.check_circle;
    } else if (monitor.healthScore >= 70) {
      return Icons.info;
    } else if (monitor.healthScore >= 50) {
      return Icons.warning;
    } else {
      return Icons.error;
    }
  }
}
