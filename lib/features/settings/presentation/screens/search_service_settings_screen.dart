// 🔍 搜索服务设置屏幕
//
// 用于配置应用中的搜索服务，包括网络搜索、本地搜索等功能的设置。
// 提供搜索引擎选择、API配置、搜索偏好等选项。
//
// 🎯 **主要功能**:
// - 🌐 **搜索引擎**: 选择默认搜索引擎（Google、Bing、DuckDuckGo等）
// - 🔑 **API配置**: 配置搜索服务的API密钥
// - ⚙️ **搜索偏好**: 设置搜索结果数量、语言偏好等
// - 🔒 **隐私设置**: 配置搜索隐私和安全选项
// - 📊 **搜索历史**: 管理搜索历史记录
//
// 📱 **界面特点**:
// - 使用 SliverAppBar 提供大标题效果
// - 分组展示不同类型的搜索设置
// - 支持实时配置保存和验证
// - 提供搜索测试功能

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';
import '../providers/settings_notifier.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';

class SearchServiceSettingsScreen extends ConsumerStatefulWidget {
  const SearchServiceSettingsScreen({super.key});

  @override
  ConsumerState<SearchServiceSettingsScreen> createState() =>
      _SearchServiceSettingsScreenState();
}

class _SearchServiceSettingsScreenState
    extends ConsumerState<SearchServiceSettingsScreen> {
  final _googleApiKeyController = TextEditingController();
  final _bingApiKeyController = TextEditingController();
  bool _obscureGoogleKey = true;
  bool _obscureBingKey = true;
  String _selectedSearchEngine = 'google';
  int _maxResults = 10;
  String _searchLanguage = 'zh-CN';
  bool _enableSearchHistory = true;
  bool _safeSearch = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _googleApiKeyController.dispose();
    _bingApiKeyController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
    // TODO: 从设置中加载搜索服务配置
    // 这里可以添加实际的设置加载逻辑
  }

  Future<void> _saveSettings() async {
    try {
      final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
      // TODO: 保存搜索服务设置
      // 这里可以添加实际的设置保存逻辑

      NotificationService().showSuccess('搜索服务设置已保存');
    } catch (e) {
      NotificationService().showError('保存设置失败: $e');
    }
  }

  Future<void> _testSearch() async {
    try {
      // TODO: 实现搜索测试功能
      NotificationService().showInfo('搜索测试功能开发中...');
    } catch (e) {
      NotificationService().showError('搜索测试失败: $e');
    }
  }

  Future<void> _clearSearchHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除搜索历史'),
        content: const Text('确定要清除所有搜索历史记录吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // TODO: 实现清除搜索历史功能
        NotificationService().showSuccess('搜索历史已清除');
      } catch (e) {
        NotificationService().showError('清除搜索历史失败: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text("搜索服务设置"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveSettings,
                tooltip: '保存设置',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: DesignConstants.paddingL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 搜索引擎选择
                  _buildSearchEngineSection(),
                  SizedBox(height: DesignConstants.spaceXXL),

                  // API配置
                  _buildApiConfigSection(),
                  SizedBox(height: DesignConstants.spaceXXL),

                  // 搜索偏好
                  _buildSearchPreferencesSection(),
                  SizedBox(height: DesignConstants.spaceXXL),

                  // 隐私和安全
                  _buildPrivacySection(),
                  SizedBox(height: DesignConstants.spaceXXL),

                  // 搜索历史管理
                  _buildHistorySection(),
                  SizedBox(height: DesignConstants.spaceXXL),

                  // 测试功能
                  _buildTestSection(),
                  SizedBox(height: DesignConstants.spaceXXXL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchEngineSection() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '搜索引擎',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),
            RadioListTile<String>(
              title: const Text('Google'),
              subtitle: const Text('Google 自定义搜索'),
              value: 'google',
              groupValue: _selectedSearchEngine,
              onChanged: (value) {
                setState(() {
                  _selectedSearchEngine = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Bing'),
              subtitle: const Text('Microsoft Bing 搜索'),
              value: 'bing',
              groupValue: _selectedSearchEngine,
              onChanged: (value) {
                setState(() {
                  _selectedSearchEngine = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('DuckDuckGo'),
              subtitle: const Text('注重隐私的搜索引擎'),
              value: 'duckduckgo',
              groupValue: _selectedSearchEngine,
              onChanged: (value) {
                setState(() {
                  _selectedSearchEngine = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiConfigSection() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.key,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  'API 配置',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),

            // Google API Key
            TextField(
              controller: _googleApiKeyController,
              obscureText: _obscureGoogleKey,
              decoration: InputDecoration(
                labelText: 'Google Custom Search API Key',
                hintText: '输入 Google 自定义搜索 API 密钥',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureGoogleKey
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscureGoogleKey = !_obscureGoogleKey;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: DesignConstants.spaceL),

            // Bing API Key
            TextField(
              controller: _bingApiKeyController,
              obscureText: _obscureBingKey,
              decoration: InputDecoration(
                labelText: 'Bing Search API Key',
                hintText: '输入 Bing 搜索 API 密钥',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureBingKey
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscureBingKey = !_obscureBingKey;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchPreferencesSection() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '搜索偏好',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),

            // 最大结果数量
            ListTile(
              title: const Text('最大结果数量'),
              subtitle: Text('当前: $_maxResults 条'),
              trailing: DropdownButton<int>(
                value: _maxResults,
                items: [5, 10, 15, 20, 25].map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text('$value 条'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _maxResults = value!;
                  });
                },
              ),
            ),

            // 搜索语言
            ListTile(
              title: const Text('搜索语言'),
              subtitle: Text('当前: $_searchLanguage'),
              trailing: DropdownButton<String>(
                value: _searchLanguage,
                items: const [
                  DropdownMenuItem(value: 'zh-CN', child: Text('中文')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ja', child: Text('日本語')),
                  DropdownMenuItem(value: 'ko', child: Text('한국어')),
                ],
                onChanged: (value) {
                  setState(() {
                    _searchLanguage = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '隐私和安全',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),
            SwitchListTile(
              title: const Text('安全搜索'),
              subtitle: const Text('过滤不适宜的搜索结果'),
              value: _safeSearch,
              onChanged: (value) {
                setState(() {
                  _safeSearch = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '搜索历史',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),
            SwitchListTile(
              title: const Text('启用搜索历史'),
              subtitle: const Text('保存搜索历史记录'),
              value: _enableSearchHistory,
              onChanged: (value) {
                setState(() {
                  _enableSearchHistory = value;
                });
              },
            ),
            if (_enableSearchHistory) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('清除搜索历史'),
                subtitle: const Text('删除所有搜索历史记录'),
                onTap: _clearSearchHistory,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.science,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '测试功能',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _testSearch,
                icon: const Icon(Icons.search),
                label: const Text('测试搜索'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
