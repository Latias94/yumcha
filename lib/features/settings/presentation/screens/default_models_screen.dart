// ⭐ 默认模型设置屏幕
//
// 用于配置各种功能的默认 AI 模型，提供统一的模型选择和管理界面。
// 用户可以为不同的功能场景设置专门的默认模型。
//
// 🎯 **主要功能**:
// - 🤖 **聊天模型**: 设置新建聊天时的默认模型
// - 📝 **标题生成**: 设置自动生成对话标题的默认模型
// - 🌐 **翻译模型**: 设置文本翻译功能的默认模型
// - 📄 **摘要模型**: 设置文本摘要功能的默认模型
// - 🔄 **模型选择**: 使用统一的模型选择器界面
// - 🧹 **配置清除**: 支持清除已设置的默认模型
// - ✅ **状态显示**: 显示当前配置的模型信息
//
// 📱 **界面特点**:
// - 使用 SliverAppBar 提供大标题效果
// - 卡片式布局展示各功能的模型配置
// - 支持空状态和错误状态处理
// - 提供详细的功能说明和配置指导
//
// 🔧 **配置管理**:
// - 基于 SettingsNotifier 进行配置管理
// - 支持实时保存和加载配置
// - 提供配置验证和错误处理
// - 集成通知服务提供操作反馈
//
// 💡 **使用场景**:
// - 首次使用时配置默认模型
// - 根据使用习惯调整模型选择
// - 为不同功能优化模型配置
// - 简化日常使用的模型选择流程

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_setting.dart';
import '../../../ai_management/domain/entities/ai_provider.dart';
import '../../../chat/domain/entities/chat_configuration.dart';
import '../providers/settings_notifier.dart';

import '../../../ai_management/presentation/providers/unified_ai_management_providers.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';
import '../../../../shared/infrastructure/services/preference_service.dart';
import '../../../chat/presentation/screens/widgets/model_selector.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';

class DefaultModelsScreen extends ConsumerStatefulWidget {
  const DefaultModelsScreen({super.key});

  @override
  ConsumerState<DefaultModelsScreen> createState() =>
      _DefaultModelsScreenState();
}

class _DefaultModelsScreenState extends ConsumerState<DefaultModelsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsNotifierProvider);
    final providers = ref.watch(aiProvidersProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text("默认模型设置"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          if (settingsState.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (settingsState.error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    SizedBox(height: DesignConstants.spaceL),
                    Text(
                      '加载设置失败',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: DesignConstants.spaceS),
                    Text(
                      settingsState.error!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: DesignConstants.spaceL),
                    FilledButton(
                      onPressed: () {
                        ref.read(settingsNotifierProvider.notifier).refresh();
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            )
          else
            _buildContent(providers),
        ],
      ),
    );
  }

  Widget _buildContent(List<AiProvider> providers) {
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
    final enabledProviders = providers.where((p) => p.isEnabled).toList();

    if (enabledProviders.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(height: DesignConstants.spaceL),
              Text(
                '没有可用的提供商',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: DesignConstants.spaceS),
              Text(
                '请先在设置中配置并启用AI提供商',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        SizedBox(height: DesignConstants.spaceL),

        // 说明文本
        Padding(
          padding: EdgeInsets.symmetric(horizontal: DesignConstants.spaceL),
          child: Card(
            child: Padding(
              padding: DesignConstants.paddingL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: DesignConstants.spaceS),
                      Text(
                        '默认模型设置',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                    ],
                  ),
                  SizedBox(height: DesignConstants.spaceS),
                  Text(
                    '为不同功能设置默认使用的AI模型。如果未设置，系统将提示您选择模型。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(height: DesignConstants.spaceXXL),

        // 聊天默认模型
        _buildModelConfigItem(
          icon: Icons.chat_outlined,
          title: '聊天模型',
          subtitle: '新建聊天时使用的默认模型',
          currentConfig: settingsNotifier.getDefaultChatModel(),
          providers: enabledProviders,
          onConfigChanged: (config) async {
            if (config != null) {
              await settingsNotifier.setDefaultChatModel(config);
              NotificationService().showSuccess('聊天默认模型已设置');
            }
          },
          onClear: () async {
            await settingsNotifier.deleteSetting(SettingKeys.defaultChatModel);
            NotificationService().showSuccess('聊天默认模型已清除');
          },
        ),

        // 标题生成默认模型
        _buildModelConfigItem(
          icon: Icons.title_outlined,
          title: '标题生成模型',
          subtitle: '自动生成对话标题时使用的默认模型',
          currentConfig: settingsNotifier.getDefaultTitleModel(),
          providers: enabledProviders,
          onConfigChanged: (config) async {
            if (config != null) {
              await settingsNotifier.setDefaultTitleModel(config);
              NotificationService().showSuccess('标题生成默认模型已设置');
            }
          },
          onClear: () async {
            await settingsNotifier.deleteSetting(SettingKeys.defaultTitleModel);
            NotificationService().showSuccess('标题生成默认模型已清除');
          },
        ),

        // 翻译默认模型
        _buildModelConfigItem(
          icon: Icons.translate_outlined,
          title: '翻译模型',
          subtitle: '文本翻译功能使用的默认模型',
          currentConfig: settingsNotifier.getDefaultTranslationModel(),
          providers: enabledProviders,
          onConfigChanged: (config) async {
            if (config != null) {
              await settingsNotifier.setDefaultTranslationModel(config);
              NotificationService().showSuccess('翻译默认模型已设置');
            }
          },
          onClear: () async {
            await settingsNotifier.deleteSetting(
              SettingKeys.defaultTranslationModel,
            );
            NotificationService().showSuccess('翻译默认模型已清除');
          },
        ),

        // 摘要默认模型
        _buildModelConfigItem(
          icon: Icons.summarize_outlined,
          title: '摘要模型',
          subtitle: '文本摘要功能使用的默认模型',
          currentConfig: settingsNotifier.getDefaultSummaryModel(),
          providers: enabledProviders,
          onConfigChanged: (config) async {
            if (config != null) {
              await settingsNotifier.setDefaultSummaryModel(config);
              NotificationService().showSuccess('摘要默认模型已设置');
            }
          },
          onClear: () async {
            await settingsNotifier.deleteSetting(
              SettingKeys.defaultSummaryModel,
            );
            NotificationService().showSuccess('摘要默认模型已清除');
          },
        ),

        SizedBox(height: DesignConstants.spaceXXL),
      ]),
    );
  }

  Widget _buildModelConfigItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required DefaultModelConfig? currentConfig,
    required List<AiProvider> providers,
    required Function(DefaultModelConfig?) onConfigChanged,
    required VoidCallback onClear,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: DesignConstants.spaceL,
          vertical: DesignConstants.spaceXS),
      child: Card(
        child: Padding(
          padding: DesignConstants.paddingL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon),
                  SizedBox(width: DesignConstants.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          subtitle,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                        ),
                        if (currentConfig?.isConfigured == true) ...[
                          SizedBox(height: DesignConstants.spaceS),
                          _buildCurrentConfigInfo(currentConfig!, providers),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: DesignConstants.spaceS),
                  if (currentConfig?.isConfigured == true)
                    TextButton(onPressed: onClear, child: const Text('清除'))
                  else
                    _buildSelectModelButton(onConfigChanged),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentConfigInfo(
    DefaultModelConfig config,
    List<AiProvider> providers,
  ) {
    final provider =
        providers.where((p) => p.id == config.providerId).firstOrNull;
    final model =
        provider?.models.where((m) => m.name == config.modelName).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          provider?.name ?? '未知提供商',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        Text(
          model?.displayName ?? config.modelName ?? '未知模型',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildSelectModelButton(
    Function(DefaultModelConfig?) onConfigChanged,
  ) {
    return TextButton(
      onPressed: () => _showModelSelector(onConfigChanged),
      child: const Text('选择模型'),
    );
  }

  void _showModelSelector(Function(DefaultModelConfig?) onConfigChanged) {
    showModelSelector(
      context: context,
      preferenceService: PreferenceService(),
      selectedProviderId: null,
      selectedModelName: null,
      onModelSelected: (ModelSelection selection) {
        final config = DefaultModelConfig(
          providerId: selection.provider.id,
          modelName: selection.model.name,
        );
        onConfigChanged(config);
      },
    );
  }
}
