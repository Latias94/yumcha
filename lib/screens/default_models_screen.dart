import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_setting.dart';
import '../models/ai_provider.dart';
import '../models/chat_configuration.dart';
import '../providers/settings_notifier.dart';
import '../providers/ai_provider_notifier.dart';
import '../services/notification_service.dart';
import '../services/preference_service.dart';
import '../ui/chat/widgets/model_selector.dart';

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
    final providersAsync = ref.watch(aiProviderNotifierProvider);

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
                    const SizedBox(height: 16),
                    Text(
                      '加载设置失败',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      settingsState.error!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
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
            providersAsync.when(
              data: (providers) => _buildContent(providers),
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '加载提供商失败',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
              const SizedBox(height: 16),
              Text(
                '没有可用的提供商',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
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
        const SizedBox(height: 16),

        // 说明文本
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '默认模型设置',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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

        const SizedBox(height: 24),

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

        const SizedBox(height: 32),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon),
                  const SizedBox(width: 12),
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
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        if (currentConfig?.isConfigured == true) ...[
                          const SizedBox(height: 8),
                          _buildCurrentConfigInfo(currentConfig!, providers),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
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
    final provider = providers
        .where((p) => p.id == config.providerId)
        .firstOrNull;
    final model = provider?.models
        .where((m) => m.name == config.modelName)
        .firstOrNull;

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
