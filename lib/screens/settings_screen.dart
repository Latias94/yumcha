import 'package:flutter/material.dart';
import 'debug_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dynamicColor = true;
  String _colorMode = "跟随系统";

  @override
  Widget build(BuildContext context) {
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
              // API配置提醒卡片
              _buildApiConfigCard(),

              const SizedBox(height: 16),

              // 通用设置
              _buildSectionHeader("通用设置"),
              _buildColorModeItem(),
              _buildDynamicColorItem(),
              _buildDisplaySettingsItem(),

              const SizedBox(height: 24),

              // 模型与服务
              _buildSectionHeader("模型与服务"),
              _buildAssistantItem(),
              _buildDefaultModelItem(),
              _buildProviderItem(),
              _buildSearchServiceItem(),
              _buildMCPItem(),

              const SizedBox(height: 24),

              // 开发者选项
              _buildSectionHeader("开发者选项"),
              _buildDebugItem(),

              const SizedBox(height: 24),

              // 关于
              _buildSectionHeader("关于"),
              _buildAboutAppItem(),
              _buildChatStorageItem(),
              _buildShareItem(),

              const SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildApiConfigCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.warning,
                color: Theme.of(context).colorScheme.onErrorContainer,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "请配置API和模型",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "你还没有配置API和模型，请先配置",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  // TODO: 跳转到API配置页面
                },
                child: Text(
                  "配置",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildColorModeItem() {
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text("颜色模式"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _colorMode,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
      onTap: () {
        _showColorModeDialog();
      },
    );
  }

  Widget _buildDynamicColorItem() {
    return ListTile(
      leading: const Icon(Icons.color_lens_outlined),
      title: const Text("动态颜色"),
      subtitle: const Text("是否使用动态颜色"),
      trailing: Switch(
        value: _dynamicColor,
        onChanged: (value) {
          setState(() {
            _dynamicColor = value;
          });
        },
      ),
    );
  }

  Widget _buildDisplaySettingsItem() {
    return ListTile(
      leading: const Icon(Icons.display_settings_outlined),
      title: const Text("显示设置"),
      subtitle: const Text("管理显示设置"),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () {
        // TODO: 跳转到显示设置页面
      },
    );
  }

  Widget _buildAssistantItem() {
    return ListTile(
      leading: const Icon(Icons.smart_toy_outlined),
      title: const Text("助手"),
      subtitle: const Text("设置个性化助手（智能体）"),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () {
        // TODO: 跳转到助手设置页面
      },
    );
  }

  Widget _buildDefaultModelItem() {
    return ListTile(
      leading: const Icon(Icons.favorite_outline),
      title: const Text("默认模型"),
      subtitle: const Text("设置各个功能的默认模型"),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () {
        // TODO: 跳转到默认模型设置页面
      },
    );
  }

  Widget _buildProviderItem() {
    return ListTile(
      leading: const Icon(Icons.hub_outlined),
      title: const Text("提供商"),
      subtitle: const Text("配置AI提供商"),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () {
        // TODO: 跳转到提供商配置页面
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
        // TODO: 跳转到MCP配置页面
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

  void _showColorModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("颜色模式"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text("跟随系统"),
              value: "跟随系统",
              groupValue: _colorMode,
              onChanged: (value) {
                setState(() {
                  _colorMode = value!;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text("浅色模式"),
              value: "浅色模式",
              groupValue: _colorMode,
              onChanged: (value) {
                setState(() {
                  _colorMode = value!;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text("深色模式"),
              value: "深色模式",
              groupValue: _colorMode,
              onChanged: (value) {
                setState(() {
                  _colorMode = value!;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("取消"),
          ),
        ],
      ),
    );
  }
}
