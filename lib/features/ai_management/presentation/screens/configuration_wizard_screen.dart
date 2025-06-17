// 🧙‍♂️ AI配置向导界面
//
// 为新用户提供引导式的AI配置体验，帮助用户快速完成AI管理的初始设置。
// 基于新的统一AI管理架构，提供步骤化的配置流程。
//
// 🎯 **主要功能**:
// - 📋 **步骤引导**: 分步骤引导用户完成配置
// - 🔌 **提供商配置**: 帮助用户添加第一个AI提供商
// - 🤖 **助手创建**: 引导用户创建第一个AI助手
// - ✅ **配置验证**: 验证配置的完整性和有效性
// - 📱 **响应式设计**: 适配不同屏幕尺寸
//
// 🎨 **设计特点**:
// - 清晰的步骤指示器
// - 友好的引导文案
// - 直观的操作流程
// - 完整的状态反馈
//
// 🔧 **向导流程**:
// 1. 欢迎页面 - 介绍AI管理功能
// 2. 提供商选择 - 选择或添加AI提供商
// 3. API Key配置 - 安全输入API密钥
// 4. 连接测试 - 验证配置有效性
// 5. 助手选择 - 选择或创建AI助手
// 6. 完成配置 - 确认并保存设置

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';
import '../providers/unified_ai_management_providers.dart';

class ConfigurationWizardScreen extends ConsumerStatefulWidget {
  const ConfigurationWizardScreen({super.key});

  @override
  ConsumerState<ConfigurationWizardScreen> createState() =>
      _ConfigurationWizardScreenState();
}

class _ConfigurationWizardScreenState
    extends ConsumerState<ConfigurationWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final List<WizardStep> _steps = [
    WizardStep(
      title: '欢迎使用AI管理',
      subtitle: '让我们开始配置您的AI助手',
      icon: Icons.waving_hand,
    ),
    WizardStep(
      title: '选择AI提供商',
      subtitle: '添加您的第一个AI服务提供商',
      icon: Icons.cloud_outlined,
    ),
    WizardStep(
      title: '配置API密钥',
      subtitle: '安全地输入您的API密钥',
      icon: Icons.key_outlined,
    ),
    WizardStep(
      title: '测试连接',
      subtitle: '验证配置是否正确',
      icon: Icons.wifi_outlined,
    ),
    WizardStep(
      title: '创建AI助手',
      subtitle: '设置您的第一个AI助手',
      icon: Icons.smart_toy_outlined,
    ),
    WizardStep(
      title: '配置完成',
      subtitle: '开始享受AI聊天体验',
      icon: Icons.check_circle_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceType = DesignConstants.getDeviceType(context);

    return Scaffold(
      body: Column(
        children: [
          // 应用栏
          _buildAppBar(context, theme),

          // 步骤指示器
          _buildStepIndicator(context, theme),

          // 内容区域
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                return _buildStepContent(context, theme, deviceType, index);
              },
            ),
          ),

          // 导航按钮
          _buildNavigationButtons(context, theme),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
            Expanded(
              child: Text(
                'AI配置向导',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 48), // 平衡布局
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context, ThemeData theme) {
    return Container(
      padding: DesignConstants.paddingL,
      child: Row(
        children: List.generate(_steps.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.symmetric(horizontal: DesignConstants.spaceXS),
              decoration: BoxDecoration(
                color: isCompleted || isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, ThemeData theme,
      DeviceType deviceType, int stepIndex) {
    final step = _steps[stepIndex];

    return Padding(
      padding: DesignConstants.paddingL,
      child: Column(
        children: [
          SizedBox(height: DesignConstants.spaceXL),

          // 步骤图标
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              step.icon,
              size: DesignConstants.iconSizeXL,
              color: theme.colorScheme.primary,
            ),
          ),

          SizedBox(height: DesignConstants.spaceXL),

          // 步骤标题
          Text(
            step.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: DesignConstants.spaceM),

          // 步骤描述
          Text(
            step.subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: DesignConstants.spaceXL),

          // 步骤内容
          Expanded(
            child: _buildStepSpecificContent(context, theme, stepIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildStepSpecificContent(
      BuildContext context, ThemeData theme, int stepIndex) {
    switch (stepIndex) {
      case 0:
        return _buildWelcomeContent(context, theme);
      case 1:
        return _buildProviderSelectionContent(context, theme);
      case 2:
        return _buildApiKeyConfigContent(context, theme);
      case 3:
        return _buildConnectionTestContent(context, theme);
      case 4:
        return _buildAssistantCreationContent(context, theme);
      case 5:
        return _buildCompletionContent(context, theme);
      default:
        return Container();
    }
  }

  Widget _buildWelcomeContent(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Text(
          '欢迎使用AI管理功能！',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DesignConstants.spaceL),
        Text(
          '通过这个向导，您将：\n\n• 添加AI服务提供商\n• 配置API密钥\n• 创建个性化AI助手\n• 开始AI聊天体验',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProviderSelectionContent(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Text(
          '选择您要使用的AI提供商',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DesignConstants.spaceL),
        Text(
          '我们支持多种主流AI服务商，您可以选择其中一个或多个进行配置。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DesignConstants.spaceL),
        // TODO: 添加提供商选择列表
        Expanded(
          child: Center(
            child: Text(
              '提供商选择功能即将推出',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApiKeyConfigContent(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Text(
          'API密钥配置',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DesignConstants.spaceL),
        Text(
          '请输入您的API密钥。我们会安全地存储这些信息，仅用于AI服务调用。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DesignConstants.spaceL),
        // TODO: 添加API密钥输入表单
        Expanded(
          child: Center(
            child: Text(
              'API密钥配置功能即将推出',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionTestContent(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Text(
          '测试连接',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DesignConstants.spaceL),
        Text(
          '正在验证您的配置是否正确...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DesignConstants.spaceL),
        // TODO: 添加连接测试逻辑
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: DesignConstants.spaceL),
                Text(
                  '连接测试功能即将推出',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssistantCreationContent(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Text(
          '创建您的第一个AI助手',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DesignConstants.spaceL),
        Text(
          'AI助手可以帮助您获得个性化的聊天体验。您可以设置不同的角色和参数。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DesignConstants.spaceL),
        // TODO: 添加助手创建表单
        Expanded(
          child: Center(
            child: Text(
              '助手创建功能即将推出',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionContent(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Text(
          '配置完成！',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DesignConstants.spaceL),
        Text(
          '恭喜！您已经成功完成了AI管理的配置。现在可以开始享受AI聊天体验了。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DesignConstants.spaceXL),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            // TODO: 跳转到聊天界面
          },
          icon: Icon(Icons.chat, size: DesignConstants.iconSizeS),
          label: const Text('开始聊天'),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(BuildContext context, ThemeData theme) {
    return Container(
      padding: DesignConstants.paddingL,
      child: Row(
        children: [
          // 上一步按钮
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text('上一步'),
              ),
            )
          else
            const Expanded(child: SizedBox()),

          SizedBox(width: DesignConstants.spaceM),

          // 下一步/完成按钮
          Expanded(
            child: FilledButton(
              onPressed: () {
                if (_currentStep < _steps.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text(_currentStep < _steps.length - 1 ? '下一步' : '完成'),
            ),
          ),
        ],
      ),
    );
  }
}

class WizardStep {
  final String title;
  final String subtitle;
  final IconData icon;

  const WizardStep({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
