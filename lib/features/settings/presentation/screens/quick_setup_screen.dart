// ⚙️ 配置管理屏幕
//
// YumCha 应用的配置管理中心，提供统一的配置入口和快速操作。
// 帮助用户快速完成初始配置和日常管理任务。
//
// 🎯 **主要功能**:
// - 🔌 **提供商管理**: 快速跳转到 AI 提供商配置界面
// - 🤖 **助手管理**: 快速跳转到 AI 助手管理界面
// - ⚡ **快速操作**: 提供添加提供商和创建助手的快捷入口
// - 📖 **使用指南**: 显示配置步骤和使用说明
// - 🎨 **直观界面**: 使用卡片式布局和图标指示
//
// 📱 **界面组织**:
// - 主要配置卡片：提供商管理、助手管理
// - 快速操作区域：添加提供商、创建助手
// - 使用说明：配置步骤和操作指导
// - 统一的导航和视觉设计
//
// 🚀 **配置流程**:
// 1. 添加 AI 服务提供商，配置 API 密钥
// 2. 创建 AI 助手，选择提供商和模型
// 3. 配置助手的角色、参数和功能
// 4. 在聊天中选择助手开始对话
//
// 💡 **设计理念**:
// - 简化配置流程，降低使用门槛
// - 提供清晰的操作指导
// - 统一的配置管理入口
// - 直观的视觉反馈和导航

import 'package:flutter/material.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';
import '../../../ai_management/presentation/screens/providers_screen.dart';
import '../../../ai_management/presentation/screens/assistants_screen.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('配置管理'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: DesignConstants.spaceS),

              // 主要配置卡片
              _buildMainConfigCards(context),

              SizedBox(height: DesignConstants.spaceXXL),

              // 快速操作部分
              _buildQuickActions(context),

              SizedBox(height: DesignConstants.spaceXXL),

              // 使用说明
              _buildUsageGuide(context),

              SizedBox(height: DesignConstants.spaceXXXL),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildMainConfigCards(BuildContext context) {
    return Padding(
      padding: DesignConstants.responsiveHorizontalPadding(context),
      child: Column(
        children: [
          // 提供商管理
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProvidersScreen(),
                  ),
                );
              },
              child: Padding(
                padding: DesignConstants.paddingL,
                child: Row(
                  children: [
                    Container(
                      padding: DesignConstants.paddingM,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: DesignConstants.radiusM,
                      ),
                      child: Icon(
                        Icons.cloud_outlined,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: DesignConstants.iconSizeM,
                      ),
                    ),
                    SizedBox(width: DesignConstants.spaceL),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '提供商管理',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: DesignConstants.spaceXS),
                          Text(
                            '管理AI服务提供商，配置API密钥和模型',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: DesignConstants.spaceM),

          // 助手管理
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AssistantsScreen(),
                  ),
                );
              },
              child: Padding(
                padding: DesignConstants.paddingL,
                child: Row(
                  children: [
                    Container(
                      padding: DesignConstants.paddingM,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: DesignConstants.radiusM,
                      ),
                      child: Icon(
                        Icons.smart_toy_outlined,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                        size: DesignConstants.iconSizeM,
                      ),
                    ),
                    SizedBox(width: DesignConstants.spaceL),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '助手管理',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: DesignConstants.spaceXS),
                          Text(
                            '创建和管理AI助手，配置角色和参数',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: DesignConstants.responsiveHorizontalPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '快速操作',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: DesignConstants.spaceL),
          Row(
            children: [
              Expanded(
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProvidersScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: DesignConstants.paddingL,
                      child: Column(
                        children: [
                          Container(
                            padding: DesignConstants.paddingM,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: DesignConstants.radiusM,
                            ),
                            child: Icon(
                              Icons.add,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              size: DesignConstants.iconSizeM,
                            ),
                          ),
                          SizedBox(height: DesignConstants.spaceM),
                          Text(
                            '添加提供商',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: DesignConstants.spaceM),
              Expanded(
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AssistantsScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: DesignConstants.paddingL,
                      child: Column(
                        children: [
                          Container(
                            padding: DesignConstants.paddingM,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                              borderRadius: DesignConstants.radiusM,
                            ),
                            child: Icon(
                              Icons.add,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                              size: DesignConstants.iconSizeM,
                            ),
                          ),
                          SizedBox(height: DesignConstants.spaceM),
                          Text(
                            '创建助手',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageGuide(BuildContext context) {
    return Padding(
      padding: DesignConstants.responsiveHorizontalPadding(context),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: double.infinity,
          padding: DesignConstants.paddingL,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.tertiaryContainer.withValues(alpha: 0.3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                    size: DesignConstants.iconSizeS,
                  ),
                  SizedBox(width: DesignConstants.spaceS),
                  Text(
                    '使用说明',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                        ),
                  ),
                ],
              ),
              SizedBox(height: DesignConstants.spaceM),
              ...const [
                '1. 首先添加AI服务提供商，配置API密钥',
                '2. 然后创建助手，选择提供商和模型',
                '3. 配置助手的角色、参数和功能',
                '4. 在聊天中选择助手开始对话',
              ].map(
                (step) => Padding(
                  padding: EdgeInsets.only(bottom: DesignConstants.spaceXS),
                  child: Text(
                    step,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
