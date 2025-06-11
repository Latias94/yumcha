// ⚙️ 应用设置屏幕
//
// YumCha 应用的主要设置界面，提供所有配置选项的统一入口。
// 用户可以在此配置主题、提供商、助手、默认模型等各种设置。
//
// 🎯 **主要功能**:
// - 🎨 **主题设置**: 颜色模式、动态颜色、主题样式选择
// - 🔌 **提供商管理**: 跳转到 AI 提供商配置界面
// - 🤖 **助手管理**: 跳转到 AI 助手管理界面
// - ⭐ **默认模型**: 设置各功能的默认模型
// - 🔌 **MCP 配置**: 配置 MCP 服务器
// - 🔍 **搜索服务**: 配置搜索服务设置
// - ℹ️ **关于信息**: 应用信息和存储管理
// - 🛠️ **开发者选项**: 调试工具和演示功能
//
// 📱 **界面组织**:
// - 使用分组的方式组织设置项
// - 通用设置、模型与服务、关于、开发者选项
// - 支持主题实时预览和切换
// - 提供清晰的导航和操作反馈
//
// 🎨 **主题功能**:
// - 支持跟随系统、浅色、深色三种颜色模式
// - 支持动态颜色（Android 12+）
// - 提供多种主题样式选择（粉色、绿色、蓝色、黑白）
// - 实时预览主题效果

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../debug/presentation/screens/ai_debug_logs_screen.dart';
import '../../../ai_management/presentation/screens/providers_screen.dart';
import '../../../ai_management/presentation/screens/assistants_screen.dart';
import '../../../debug/presentation/screens/ai_debug_test_screen.dart';
import 'default_models_screen.dart';
import 'mcp_settings_screen.dart';
import 'theme_settings_screen.dart';
import '../../../../app/theme/theme_provider.dart';
import '../../../debug/presentation/screens/thinking_process_demo.dart';
import '../../../chat/presentation/screens/chat_display_settings_screen.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeSettings = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text("设置"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              // 通用设置
              _buildSectionHeader("通用设置"),
              _buildThemeSettingsItem(themeSettings),
              _buildDynamicColorItem(themeSettings, themeNotifier),
              _buildChatDisplaySettingsItem(),

              SizedBox(height: DesignConstants.spaceXXL),

              // 模型与服务
              _buildSectionHeader("模型与服务"),
              _buildProvidersItem(),
              _buildAssistantsItem(),
              _buildDefaultModelItem(),
              _buildSearchServiceItem(),
              _buildMCPItem(),

              SizedBox(height: DesignConstants.spaceXXL),

              // 关于
              _buildSectionHeader("关于"),
              _buildAboutAppItem(),
              _buildChatStorageItem(),
              _buildShareItem(),

              SizedBox(height: DesignConstants.spaceXXL),

              // 开发者选项
              _buildSectionHeader("开发者选项"),
              _buildDebugItem(),
              _buildAiDebugItem(),
              _buildThinkingProcessDemoItem(),

              SizedBox(height: DesignConstants.spaceXXXL),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        DesignConstants.spaceL,
        DesignConstants.spaceS,
        DesignConstants.spaceL,
        DesignConstants.spaceS,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildThemeSettingsItem(ThemeSettings themeSettings) {
    final isDynamicColorEnabled = themeSettings.dynamicColorEnabled &&
        themeSettings.isDynamicColorAvailable;

    return ListTile(
      leading: Icon(
        Icons.palette_outlined,
        color: isDynamicColorEnabled
            ? Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: 0.5)
            : null,
      ),
      title: Text(
        "主题设置",
        style: isDynamicColorEnabled
            ? TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.5))
            : null,
      ),
      subtitle: Text(
        isDynamicColorEnabled
            ? "动态颜色已启用"
            : "${themeSettings.colorModeDisplayName} · ${themeSettings.themeSchemeDisplayName} · ${themeSettings.contrastLevelDisplayName}",
        style: TextStyle(
          color: isDynamicColorEnabled
              ? Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.5)
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.keyboard_arrow_right,
        color: isDynamicColorEnabled
            ? Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: 0.5)
            : null,
      ),
      onTap: isDynamicColorEnabled
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ThemeSettingsScreen()),
              );
            },
    );
  }

  Widget _buildDynamicColorItem(
    ThemeSettings themeSettings,
    ThemeNotifier themeNotifier,
  ) {
    final isAvailable = themeSettings.isDynamicColorAvailable;
    final isEnabled = themeSettings.dynamicColorEnabled;

    String subtitle;
    if (!isAvailable) {
      subtitle = "此设备不支持动态颜色";
    } else if (isEnabled) {
      subtitle = "跟随系统壁纸颜色";
    } else {
      subtitle = "使用应用默认颜色";
    }

    return ListTile(
      leading: Icon(
        Icons.color_lens_outlined,
        color: isAvailable
            ? null
            : Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
      title: Text(
        "动态颜色",
        style: isAvailable
            ? null
            : TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isAvailable
              ? Theme.of(context).colorScheme.onSurfaceVariant
              : Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
      trailing: Switch(
        value: isEnabled,
        onChanged: isAvailable
            ? (value) async {
                final success = await themeNotifier.setDynamicColor(value);
                if (!success && value && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("此设备不支持动态颜色功能"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            : null,
      ),
    );
  }

  Widget _buildThemeSelectionItem(
    ThemeSettings themeSettings,
    ThemeNotifier themeNotifier,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceL,
        vertical: DesignConstants.spaceS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "主题样式",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: DesignConstants.spaceM),
          _buildThemeToggleButtons(themeSettings, themeNotifier),
        ],
      ),
    );
  }

  Widget _buildThemeToggleButtons(
    ThemeSettings themeSettings,
    ThemeNotifier themeNotifier,
  ) {
    const TextStyle style = TextStyle(fontSize: 12);
    final List<bool> isSelected = <bool>[
      themeSettings.themeScheme == AppThemeScheme.ocean,
      themeSettings.themeScheme == AppThemeScheme.monochrome,
      themeSettings.themeScheme == AppThemeScheme.forest,
      themeSettings.themeScheme == AppThemeScheme.warmOrange,
    ];

    return ToggleButtons(
      isSelected: isSelected,
      onPressed: (int newIndex) async {
        AppThemeScheme newScheme;
        switch (newIndex) {
          case 0:
            newScheme = AppThemeScheme.ocean;
            break;
          case 1:
            newScheme = AppThemeScheme.monochrome;
            break;
          case 2:
            newScheme = AppThemeScheme.forest;
            break;
          case 3:
            newScheme = AppThemeScheme.warmOrange;
            break;
          default:
            return;
        }
        await themeNotifier.setThemeScheme(newScheme);
      },
      borderRadius: DesignConstants.radiusS,
      constraints: BoxConstraints(
        minHeight: DesignConstants.buttonHeightL,
        minWidth: 80,
      ),
      children: <Widget>[
        _buildThemeButton('深邃\n海洋', AppThemeScheme.ocean, themeNotifier, style),
        _buildThemeButton(
            '简约\n黑白', AppThemeScheme.monochrome, themeNotifier, style),
        _buildThemeButton(
            '专注\n森林', AppThemeScheme.forest, themeNotifier, style),
        _buildThemeButton(
          '温暖\n橙色',
          AppThemeScheme.warmOrange,
          themeNotifier,
          style,
        ),
      ],
    );
  }

  Widget _buildThemeButton(
    String label,
    AppThemeScheme scheme,
    ThemeNotifier themeNotifier,
    TextStyle style,
  ) {
    final colorScheme = themeNotifier.getPreviewColorScheme(
      scheme,
      Theme.of(context).brightness,
    );

    return Padding(
      padding: EdgeInsets.all(DesignConstants.spaceXS + 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 颜色预览圆圈
          Container(
            width: DesignConstants.iconSizeM,
            height: DesignConstants.iconSizeM,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
                width: DesignConstants.borderWidthThin,
              ),
            ),
          ),
          SizedBox(height: DesignConstants.spaceXS),
          Text(label, textAlign: TextAlign.center, style: style),
        ],
      ),
    );
  }

  Widget _buildProvidersItem() {
    return ListTile(
      leading: const Icon(Icons.cloud_outlined),
      title: const Text("提供商"),
      subtitle: const Text("配置AI服务提供商和API密钥"),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProvidersScreen()),
        );
      },
    );
  }

  Widget _buildChatDisplaySettingsItem() {
    return ListTile(
      leading: const Icon(Icons.chat_bubble_outline),
      title: const Text("聊天显示"),
      subtitle: const Text("设置聊天消息的显示样式"),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const DisplaySettingsScreen()),
        );
      },
    );
  }

  Widget _buildAssistantsItem() {
    return ListTile(
      leading: const Icon(Icons.smart_toy_outlined),
      title: const Text("助手"),
      subtitle: const Text("创建和管理AI助手（智能体）"),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AssistantsScreen()),
        );
      },
    );
  }

  Widget _buildDebugItem() {
    return ListTile(
      leading: const Icon(Icons.bug_report_outlined),
      title: const Text("调试"),
      subtitle: const Text("进入调试页面"),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DebugScreen()),
        );
      },
    );
  }

  Widget _buildAiDebugItem() {
    return ListTile(
      leading: const Icon(Icons.smart_toy_outlined),
      title: const Text("AI聊天调试"),
      subtitle: const Text("测试AI聊天API功能"),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AiDebugScreen()),
        );
      },
    );
  }

  Widget _buildThinkingProcessDemoItem() {
    return ListTile(
      leading: const Icon(Icons.psychology_outlined),
      title: const Text("思考过程演示"),
      subtitle: const Text("演示AI推理模型的思考过程显示功能"),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ThinkingProcessDemo()),
        );
      },
    );
  }

  void _showColorModeDialog(
    ThemeSettings themeSettings,
    ThemeNotifier themeNotifier,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("颜色模式"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AppColorMode>(
              title: const Text("跟随系统"),
              value: AppColorMode.system,
              groupValue: themeSettings.colorMode,
              onChanged: (value) async {
                if (value != null) {
                  await themeNotifier.setColorMode(value);
                  if (mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                }
              },
            ),
            RadioListTile<AppColorMode>(
              title: const Text("浅色模式"),
              value: AppColorMode.light,
              groupValue: themeSettings.colorMode,
              onChanged: (value) async {
                if (value != null) {
                  await themeNotifier.setColorMode(value);
                  if (mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                }
              },
            ),
            RadioListTile<AppColorMode>(
              title: const Text("深色模式"),
              value: AppColorMode.dark,
              groupValue: themeSettings.colorMode,
              onChanged: (value) async {
                if (value != null) {
                  await themeNotifier.setColorMode(value);
                  if (mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("取消"),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultModelItem() {
    return ListTile(
      leading: const Icon(Icons.favorite_outline),
      title: const Text("默认模型"),
      subtitle: const Text("设置各个功能的默认模型"),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DefaultModelsScreen()),
        );
      },
    );
  }

  Widget _buildSearchServiceItem() {
    return ListTile(
      leading: const Icon(Icons.search_outlined),
      title: const Text("搜索服务"),
      subtitle: const Text("设置搜索服务"),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () {
        // TODO: 跳转到搜索服务设置页面
      },
    );
  }

  Widget _buildMCPItem() {
    return ListTile(
      leading: const Icon(Icons.terminal_outlined),
      title: const Text("MCP"),
      subtitle: const Text("配置MCP Servers"),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const McpSettingsScreen()),
        );
      },
    );
  }

  Widget _buildAboutAppItem() {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: const Text("关于"),
      subtitle: const Text("关于本APP"),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () {
        // TODO: 跳转到关于页面
      },
    );
  }

  Widget _buildChatStorageItem() {
    return ListTile(
      leading: const Icon(Icons.storage_outlined),
      title: const Text("聊天记录存储"),
      subtitle: const Text("0 个文件，0.00 MB"),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () {
        // TODO: 跳转到聊天记录管理页面
      },
    );
  }

  Widget _buildShareItem() {
    return ListTile(
      leading: const Icon(Icons.share_outlined),
      title: const Text("分享"),
      subtitle: const Text("分享本APP给朋友"),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () {
        // TODO: 实现分享功能
      },
    );
  }

  Widget _buildContrastLevelItem(
    ThemeSettings themeSettings,
    ThemeNotifier themeNotifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "对比度",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            themeSettings.contrastLevelDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          _buildContrastToggleButtons(themeSettings, themeNotifier),
        ],
      ),
    );
  }

  Widget _buildContrastToggleButtons(
    ThemeSettings themeSettings,
    ThemeNotifier themeNotifier,
  ) {
    const TextStyle style = TextStyle(fontSize: 12);
    final List<bool> isSelected = <bool>[
      themeSettings.contrastLevel == AppContrastLevel.standard,
      themeSettings.contrastLevel == AppContrastLevel.medium,
      themeSettings.contrastLevel == AppContrastLevel.high,
    ];

    return ToggleButtons(
      isSelected: isSelected,
      onPressed: (int newIndex) async {
        AppContrastLevel newLevel;
        switch (newIndex) {
          case 0:
            newLevel = AppContrastLevel.standard;
            break;
          case 1:
            newLevel = AppContrastLevel.medium;
            break;
          case 2:
            newLevel = AppContrastLevel.high;
            break;
          default:
            return;
        }
        await themeNotifier.setContrastLevel(newLevel);
      },
      borderRadius: BorderRadius.circular(8),
      constraints: const BoxConstraints(minHeight: 48, minWidth: 80),
      children: <Widget>[
        _buildContrastButton('标准', AppContrastLevel.standard, style),
        _buildContrastButton('中对比', AppContrastLevel.medium, style),
        _buildContrastButton('高对比', AppContrastLevel.high, style),
      ],
    );
  }

  Widget _buildContrastButton(
    String label,
    AppContrastLevel level,
    TextStyle style,
  ) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: style,
      ),
    );
  }
}
