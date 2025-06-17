// 🔄 配置管理主界面
//
// 提供完整的AI配置管理功能，整合导入导出、备份恢复、高级管理等功能。
// 为用户提供一站式的配置管理体验。
//
// 🎯 **核心功能**:
// - 📤 **导入导出**: 配置的导入导出管理
// - 💾 **备份恢复**: 配置备份和恢复功能
// - 📊 **配置分析**: 配置使用情况分析
// - 🔧 **高级管理**: 配置模板和批量操作
// - ⚙️ **系统设置**: 配置管理相关设置

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/widgets/common/loading_overlay.dart';
import '../../../../shared/presentation/widgets/common/error_display.dart';
import '../providers/configuration_management_providers.dart';
import 'configuration_import_export_screen.dart';
import 'configuration_backup_screen.dart';

/// 配置管理主界面
class ConfigurationManagementScreen extends ConsumerStatefulWidget {
  const ConfigurationManagementScreen({super.key});

  @override
  ConsumerState<ConfigurationManagementScreen> createState() =>
      _ConfigurationManagementScreenState();
}

class _ConfigurationManagementScreenState
    extends ConsumerState<ConfigurationManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('配置管理'),
        actions: [
          IconButton(
            onPressed: _refreshAll,
            icon: const Icon(Icons.refresh),
            tooltip: '刷新所有数据',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'analysis',
                child: ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('配置分析'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'validation',
                child: ListTile(
                  leading: Icon(Icons.verified),
                  title: Text('配置验证'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'templates',
                child: ListTile(
                  leading: Icon(Icons.dashboard_outlined),
                  title: Text('配置模板'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.import_export), text: '导入导出'),
            Tab(icon: Icon(Icons.backup), text: '备份恢复'),
            Tab(icon: Icon(Icons.analytics), text: '配置分析'),
            Tab(icon: Icon(Icons.settings), text: '高级设置'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const ConfigurationImportExportScreen(),
          const ConfigurationBackupScreen(),
          _buildAnalysisTab(),
          _buildAdvancedTab(),
        ],
      ),
    );
  }

  /// 构建配置分析标签页
  Widget _buildAnalysisTab() {
    final analysisAsync = ref.watch(configurationAnalysisProvider);
    final validationAsync = ref.watch(configurationValidationProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 配置分析卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '配置分析',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  analysisAsync.when(
                    data: (analysis) => _buildAnalysisContent(analysis),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => ErrorDisplay(
                      error: error,
                      onRetry: () =>
                          ref.invalidate(configurationAnalysisProvider),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 配置验证卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '配置验证',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  validationAsync.when(
                    data: (validation) => _buildValidationContent(validation),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => ErrorDisplay(
                      error: error,
                      onRetry: () =>
                          ref.invalidate(configurationValidationProvider),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建高级设置标签页
  Widget _buildAdvancedTab() {
    final templates = ref.watch(configurationTemplatesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 配置模板卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '配置模板',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      ElevatedButton.icon(
                        onPressed: _showCreateTemplateDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('创建模板'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (templates.isEmpty)
                    const Center(
                      child: Text('暂无配置模板'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: templates.length,
                      itemBuilder: (context, index) {
                        final template = templates[index];
                        return _buildTemplateItem(template);
                      },
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 批量操作卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '批量操作',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.file_upload),
                    title: const Text('批量导入配置'),
                    subtitle: const Text('从多个文件批量导入配置'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _showBatchImportDialog,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.sync),
                    title: const Text('配置同步'),
                    subtitle: const Text('同步配置到其他设备'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _showSyncDialog,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.cleaning_services),
                    title: const Text('清理无效配置'),
                    subtitle: const Text('清理无效或过期的配置项'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _showCleanupDialog,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建分析内容
  Widget _buildAnalysisContent(analysis) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard('总提供商', analysis.totalProviders.toString()),
            ),
            const SizedBox(width: 8),
            Expanded(
              child:
                  _buildStatCard('启用提供商', analysis.enabledProviders.toString()),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard('总助手', analysis.totalAssistants.toString()),
            ),
            const SizedBox(width: 8),
            Expanded(
              child:
                  _buildStatCard('启用助手', analysis.enabledAssistants.toString()),
            ),
          ],
        ),
        if (analysis.recommendations.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '优化建议',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...analysis.recommendations.map((rec) => Text(
                      '• $rec',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    )),
              ],
            ),
          ),
        ],
        if (analysis.warnings.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '警告信息',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...analysis.warnings.map((warning) => Text(
                      '• $warning',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 构建验证内容
  Widget _buildValidationContent(validation) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: validation.isValid
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                validation.isValid ? Icons.check_circle : Icons.error,
                color: validation.isValid
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Text(
                validation.isValid ? '配置验证通过' : '配置验证失败',
                style: TextStyle(
                  color: validation.isValid
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (validation.errors.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...validation.errors.map((error) => ListTile(
                leading: const Icon(Icons.error, color: Colors.red),
                title: Text(error),
                dense: true,
              )),
        ],
        if (validation.warnings.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...validation.warnings.map((warning) => ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: Text(warning),
                dense: true,
              )),
        ],
      ],
    );
  }

  /// 构建统计卡片
  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  /// 构建模板项
  Widget _buildTemplateItem(template) {
    return ListTile(
      leading: CircleAvatar(
        child: Icon(_getTemplateIcon(template.type)),
      ),
      title: Text(template.name),
      subtitle: Text(template.description),
      trailing: PopupMenuButton<String>(
        onSelected: (action) => _handleTemplateAction(action, template),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'apply',
            child: ListTile(
              leading: Icon(Icons.play_arrow),
              title: Text('应用模板'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (!template.isBuiltIn) ...[
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('编辑'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('删除', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 获取模板图标
  IconData _getTemplateIcon(templateType) {
    // 根据模板类型返回相应图标
    return Icons.settings;
  }

  /// 刷新所有数据
  Future<void> _refreshAll() async {
    final notifier = ref.read(configurationManagementProvider.notifier);
    await notifier.refreshAll();
  }

  /// 处理菜单操作
  void _handleMenuAction(String action) {
    switch (action) {
      case 'analysis':
        _tabController.animateTo(2);
        break;
      case 'validation':
        _showValidationDialog();
        break;
      case 'templates':
        _tabController.animateTo(3);
        break;
    }
  }

  /// 处理模板操作
  void _handleTemplateAction(String action, template) {
    switch (action) {
      case 'apply':
        _applyTemplate(template);
        break;
      case 'edit':
        _editTemplate(template);
        break;
      case 'delete':
        _deleteTemplate(template);
        break;
    }
  }

  /// 显示验证对话框
  void _showValidationDialog() {
    // TODO: 实现验证对话框
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('配置验证功能开发中')),
    );
  }

  /// 显示创建模板对话框
  void _showCreateTemplateDialog() {
    // TODO: 实现创建模板对话框
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('创建模板功能开发中')),
    );
  }

  /// 显示批量导入对话框
  void _showBatchImportDialog() {
    // TODO: 实现批量导入对话框
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('批量导入功能开发中')),
    );
  }

  /// 显示同步对话框
  void _showSyncDialog() {
    // TODO: 实现同步对话框
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('配置同步功能开发中')),
    );
  }

  /// 显示清理对话框
  void _showCleanupDialog() {
    // TODO: 实现清理对话框
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('配置清理功能开发中')),
    );
  }

  /// 应用模板
  void _applyTemplate(template) {
    // TODO: 实现应用模板
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('应用模板: ${template.name}')),
    );
  }

  /// 编辑模板
  void _editTemplate(template) {
    // TODO: 实现编辑模板
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑模板: ${template.name}')),
    );
  }

  /// 删除模板
  void _deleteTemplate(template) {
    // TODO: 实现删除模板
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('删除模板: ${template.name}')),
    );
  }
}
