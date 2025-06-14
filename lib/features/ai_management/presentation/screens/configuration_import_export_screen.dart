// 🔄 配置导入导出界面
//
// 提供完整的配置导入导出功能界面，支持多种格式、预览、冲突解决等。
// 为用户提供直观易用的配置管理体验。
//
// 🎯 **核心功能**:
// - 📤 **配置导出**: 选择性导出、格式选择、加密选项
// - 📥 **配置导入**: 文件选择、预览、冲突解决
// - 👀 **导入预览**: 详细的导入内容预览
// - ⚔️ **冲突解决**: 智能的冲突处理界面
// - 📊 **操作统计**: 导入导出的详细统计信息

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/configuration_export_models.dart';
import '../providers/configuration_management_providers.dart';

/// 配置导入导出界面
class ConfigurationImportExportScreen extends ConsumerStatefulWidget {
  const ConfigurationImportExportScreen({super.key});

  @override
  ConsumerState<ConfigurationImportExportScreen> createState() =>
      _ConfigurationImportExportScreenState();
}

class _ConfigurationImportExportScreenState
    extends ConsumerState<ConfigurationImportExportScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // 导出选项
  bool _includeProviders = true;
  bool _includeAssistants = true;
  bool _includePreferences = true;
  bool _includeSettings = true;
  ExportFormat _exportFormat = ExportFormat.json;
  bool _enableEncryption = false;
  String _encryptionKey = '';

  // 导入选项
  String? _selectedFilePath;
  ImportPreview? _importPreview;
  ConflictResolutionStrategy _conflictStrategy = ConflictResolutionStrategy.ask;
  bool _validateBeforeImport = true;
  bool _createBackupBeforeImport = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('配置导入导出'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.upload), text: '导出配置'),
            Tab(icon: Icon(Icons.download), text: '导入配置'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExportTab(),
          _buildImportTab(),
        ],
      ),
    );
  }

  /// 构建导出标签页
  Widget _buildExportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 导出内容选择
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '选择导出内容',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('AI提供商'),
                    subtitle: const Text('包括API密钥和配置信息'),
                    value: _includeProviders,
                    onChanged: (value) => setState(() => _includeProviders = value!),
                  ),
                  CheckboxListTile(
                    title: const Text('AI助手'),
                    subtitle: const Text('包括提示词和参数设置'),
                    value: _includeAssistants,
                    onChanged: (value) => setState(() => _includeAssistants = value!),
                  ),
                  CheckboxListTile(
                    title: const Text('用户偏好'),
                    subtitle: const Text('主题、语言等个人设置'),
                    value: _includePreferences,
                    onChanged: (value) => setState(() => _includePreferences = value!),
                  ),
                  CheckboxListTile(
                    title: const Text('应用设置'),
                    subtitle: const Text('高级设置和功能开关'),
                    value: _includeSettings,
                    onChanged: (value) => setState(() => _includeSettings = value!),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 导出格式选择
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '导出格式',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ...ExportFormat.values.map((format) => RadioListTile<ExportFormat>(
                    title: Text(format.displayName),
                    subtitle: Text('文件扩展名: ${format.extension}'),
                    value: format,
                    groupValue: _exportFormat,
                    onChanged: (value) => setState(() => _exportFormat = value!),
                  )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 安全选项
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '安全选项',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('启用加密'),
                    subtitle: const Text('使用密码保护导出文件'),
                    value: _enableEncryption,
                    onChanged: (value) => setState(() => _enableEncryption = value),
                  ),
                  if (_enableEncryption) ...[
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: '加密密码',
                        hintText: '请输入用于加密的密码',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      onChanged: (value) => _encryptionKey = value,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 导出按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _canExport() ? _performExport : null,
              icon: const Icon(Icons.upload),
              label: const Text('导出配置'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建导入标签页
  Widget _buildImportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 文件选择
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '选择配置文件',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedFilePath ?? '未选择文件',
                          style: TextStyle(
                            color: _selectedFilePath != null
                                ? Theme.of(context).textTheme.bodyMedium?.color
                                : Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _selectImportFile,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('选择文件'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (_importPreview != null) ...[
            const SizedBox(height: 16),
            _buildImportPreview(),
          ],

          if (_selectedFilePath != null) ...[
            const SizedBox(height: 16),

            // 导入选项
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '导入选项',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ConflictResolutionStrategy>(
                      decoration: const InputDecoration(
                        labelText: '冲突解决策略',
                        border: OutlineInputBorder(),
                      ),
                      value: _conflictStrategy,
                      items: ConflictResolutionStrategy.values.map((strategy) {
                        return DropdownMenuItem(
                          value: strategy,
                          child: Text(strategy.displayName),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _conflictStrategy = value!),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('导入前验证'),
                      subtitle: const Text('验证配置文件的完整性和兼容性'),
                      value: _validateBeforeImport,
                      onChanged: (value) => setState(() => _validateBeforeImport = value!),
                    ),
                    CheckboxListTile(
                      title: const Text('导入前备份'),
                      subtitle: const Text('在导入前自动创建当前配置的备份'),
                      value: _createBackupBeforeImport,
                      onChanged: (value) => setState(() => _createBackupBeforeImport = value!),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 导入按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _canImport() ? _performImport : null,
                icon: const Icon(Icons.download),
                label: const Text('导入配置'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建导入预览
  Widget _buildImportPreview() {
    final preview = _importPreview!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '导入预览',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // 统计信息
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('提供商', preview.statistics.providerCount),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('助手', preview.statistics.assistantCount),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('设置', preview.hasSettings ? 1 : 0),
                ),
              ],
            ),

            if (preview.hasConflicts) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '检测到 ${preview.conflicts.length} 个冲突项',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (!preview.isValid) ...[
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
                          Icons.error,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '验证失败',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...preview.validation.errors.map((error) => Text(
                      '• $error',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatCard(String label, int count) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
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

  /// 检查是否可以导出
  bool _canExport() {
    if (!_includeProviders && !_includeAssistants && 
        !_includePreferences && !_includeSettings) {
      return false;
    }
    
    if (_enableEncryption && _encryptionKey.isEmpty) {
      return false;
    }
    
    return true;
  }

  /// 检查是否可以导入
  bool _canImport() {
    return _selectedFilePath != null && 
           (_importPreview?.isValid ?? false);
  }

  /// 选择导入文件
  Future<void> _selectImportFile() async {
    try {
      // 暂时使用简单的文件路径输入，后续可以集成文件选择器
      final filePath = await _showFilePathDialog();

      if (filePath != null && filePath.isNotEmpty) {
        setState(() {
          _selectedFilePath = filePath;
          _importPreview = null;
        });

        // 预览导入内容
        await _previewImport(filePath);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择文件失败: $error')),
        );
      }
    }
  }

  /// 显示文件路径输入对话框
  Future<String?> _showFilePathDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('输入文件路径'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '请输入配置文件的完整路径',
            helperText: '支持 .json, .yaml, .yml, .enc 格式',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 预览导入内容
  Future<void> _previewImport(String filePath) async {
    try {
      final preview = await ref.read(configurationImportServiceProvider)
          .previewImport(filePath, null);
      
      setState(() {
        _importPreview = preview;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('预览失败: $error')),
        );
      }
    }
  }

  /// 执行导出
  Future<void> _performExport() async {
    try {
      final result = await ref.read(configurationExportServiceProvider)
          .exportConfiguration(
        includeProviders: _includeProviders,
        includeAssistants: _includeAssistants,
        includePreferences: _includePreferences,
        includeSettings: _includeSettings,
        encryptionKey: _enableEncryption ? _encryptionKey : null,
        format: _exportFormat,
      );

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('导出成功: ${result.statistics.formattedFileSize}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('导出失败: ${result.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 执行导入
  Future<void> _performImport() async {
    try {
      final result = await ref.read(configurationImportServiceProvider)
          .importConfiguration(
        _selectedFilePath!,
        strategy: _conflictStrategy,
        validateBeforeImport: _validateBeforeImport,
        createBackupBeforeImport: _createBackupBeforeImport,
      );

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('导入成功: ${result.statistics.totalImported} 项'),
              backgroundColor: Colors.green,
            ),
          );
          
          // 清除选择的文件
          setState(() {
            _selectedFilePath = null;
            _importPreview = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('导入失败: ${result.errors.join(', ')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导入失败: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
