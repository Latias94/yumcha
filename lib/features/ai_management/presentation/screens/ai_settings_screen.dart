// 🎛️ AI设置主界面
//
// 基于新的统一AI管理架构重构的AI设置界面。
// 提供完整的AI管理功能，包括提供商、助手和配置管理。
//
// 🎯 **主要功能**:
// - 📊 **统计概览**: 显示AI管理的关键统计信息
// - 🔌 **提供商管理**: 管理AI服务提供商
// - 🤖 **助手管理**: 管理AI助手配置
// - ⚙️ **配置管理**: 配置备份、导入导出等
// - 📱 **响应式设计**: 适配不同屏幕尺寸
//
// 🎨 **设计特点**:
// - 模块化布局，清晰分区
// - 统一的视觉风格
// - 直观的操作流程
// - 完整的状态反馈
//
// 🔧 **架构特点**:
// - 基于统一AI管理Provider
// - 组件化设计，易于维护
// - 响应式状态管理
// - 完整的错误处理

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';
import '../providers/unified_ai_management_providers.dart';
import '../widgets/ai_management_stats_card.dart';
import '../widgets/providers_management_section.dart';
import '../widgets/assistants_management_section.dart';
import '../widgets/configuration_management_section.dart';

class AiSettingsScreen extends ConsumerWidget {
  const AiSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final deviceType = DesignConstants.getDeviceType(context);

    // 监听AI管理状态
    final isLoading = ref.watch(isAiManagementLoadingProvider);
    final hasError = ref.watch(hasAiManagementErrorProvider);
    final state = ref.watch(unifiedAiManagementProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 应用栏
          SliverAppBar.large(
            title: const Text('AI设置'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              // 刷新按钮
              IconButton(
                onPressed: () {
                  ref.invalidate(unifiedAiManagementProvider);
                },
                icon: const Icon(Icons.refresh),
                tooltip: '刷新',
              ),
              // 帮助按钮
              IconButton(
                onPressed: () => _showHelpDialog(context),
                icon: const Icon(Icons.help_outline),
                tooltip: '帮助',
              ),
            ],
          ),

          // 内容区域
          if (hasError)
            _buildErrorState(context, theme, ref)
          else if (isLoading)
            _buildLoadingState(context, theme)
          else
            _buildContentState(context, theme, deviceType, state),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, ThemeData theme, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: DesignConstants.iconSizeXXL * 1.5,
                color: theme.colorScheme.error,
              ),
              SizedBox(height: DesignConstants.spaceL),
              Text(
                '加载AI设置失败',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              SizedBox(height: DesignConstants.spaceM),
              Text(
                '请检查网络连接或稍后重试',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: DesignConstants.spaceL),
              FilledButton.icon(
                onPressed: () {
                  ref.invalidate(unifiedAiManagementProvider);
                },
                icon: Icon(Icons.refresh, size: DesignConstants.iconSizeS),
                label: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: DesignConstants.spaceL),
              Text(
                '加载AI设置...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentState(
    BuildContext context,
    ThemeData theme,
    DeviceType deviceType,
    dynamic state,
  ) {
    return SliverList(
      delegate: SliverChildListDelegate([
        // 统计信息卡片
        const AiManagementStatsCard(),

        // 提供商管理区域
        const ProvidersManagementSection(),

        // 助手管理区域
        const AssistantsManagementSection(),

        // 配置管理区域
        const ConfigurationManagementSection(),

        // 底部间距
        SizedBox(height: DesignConstants.spaceXL),

        // 版本信息
        _buildVersionInfo(context, theme),

        // 底部安全间距
        SizedBox(
            height:
                MediaQuery.of(context).padding.bottom + DesignConstants.spaceL),
      ]),
    );
  }

  Widget _buildVersionInfo(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DesignConstants.spaceL),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        child: Padding(
          padding: DesignConstants.paddingM,
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: DesignConstants.iconSizeM,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: DesignConstants.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI管理模块',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: DesignConstants.spaceXS),
                    Text(
                      '基于统一架构 v2.0 • 支持多提供商管理',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI设置帮助'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🔌 提供商管理',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('添加和配置AI服务提供商，如OpenAI、Anthropic等。每个提供商需要配置API密钥和模型列表。'),
              SizedBox(height: 16),
              Text(
                '🤖 助手管理',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('创建个性化AI助手，设置系统提示词和参数。助手可以用于不同的聊天场景。'),
              SizedBox(height: 16),
              Text(
                '⚙️ 配置管理',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('备份和恢复配置，导入导出设置。确保您的配置安全可靠。'),
              SizedBox(height: 16),
              Text(
                '💡 提示',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('建议先添加提供商，然后创建助手。完成配置后记得备份设置。'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}
