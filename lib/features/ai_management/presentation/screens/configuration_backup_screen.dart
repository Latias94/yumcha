// 🔄 配置备份管理界面
//
// 提供完整的配置备份管理功能界面，支持创建备份、恢复配置、管理备份等。
// 为用户提供可靠的配置保护和恢复体验。
//
// 🎯 **核心功能**:
// - 💾 **备份管理**: 查看、创建、删除备份
// - 🔄 **配置恢复**: 从备份恢复配置
// - 🧹 **备份清理**: 清理过期和无用备份
// - 📊 **备份统计**: 备份使用情况统计
// - ⚙️ **备份设置**: 自动备份和保留策略

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/widgets/common/loading_overlay.dart';
import '../../../../shared/presentation/widgets/common/error_display.dart';
import '../../domain/entities/configuration_backup_models.dart';
import '../providers/configuration_management_providers.dart';

/// 配置备份管理界面
class ConfigurationBackupScreen extends ConsumerStatefulWidget {
  const ConfigurationBackupScreen({super.key});

  @override
  ConsumerState<ConfigurationBackupScreen> createState() =>
      _ConfigurationBackupScreenState();
}

class _ConfigurationBackupScreenState
    extends ConsumerState<ConfigurationBackupScreen> {
  
  BackupType _selectedBackupType = BackupType.full;
  String _backupDescription = '';
  final List<String> _backupTags = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('配置备份管理'),
        actions: [
          IconButton(
            onPressed: _showCreateBackupDialog,
            icon: const Icon(Icons.add),
            tooltip: '创建备份',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'cleanup',
                child: ListTile(
                  leading: Icon(Icons.cleaning_services),
                  title: Text('清理过期备份'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('备份设置'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 备份统计卡片
          _buildBackupStatsCard(),
          
          // 备份列表
          Expanded(
            child: _buildBackupList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateBackupDialog,
        child: const Icon(Icons.backup),
        tooltip: '创建备份',
      ),
    );
  }

  /// 构建备份统计卡片
  Widget _buildBackupStatsCard() {
    final backupListAsync = ref.watch(backupListProvider);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: backupListAsync.when(
          data: (backups) {
            final manualBackups = backups.where((b) => !b.isAutomatic).length;
            final autoBackups = backups.where((b) => b.isAutomatic).length;
            final totalSize = backups.fold<int>(0, (sum, b) => sum + b.size);
            
            return Row(
              children: [
                Expanded(
                  child: _buildStatItem('总备份', backups.length.toString()),
                ),
                Expanded(
                  child: _buildStatItem('手动备份', manualBackups.toString()),
                ),
                Expanded(
                  child: _buildStatItem('自动备份', autoBackups.toString()),
                ),
                Expanded(
                  child: _buildStatItem('总大小', _formatSize(totalSize)),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('加载失败: $error'),
        ),
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  /// 构建备份列表
  Widget _buildBackupList() {
    final backupListAsync = ref.watch(backupListProvider);
    
    return backupListAsync.when(
      data: (backups) {
        if (backups.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.backup, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('暂无备份'),
                SizedBox(height: 8),
                Text('点击右下角按钮创建第一个备份'),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: backups.length,
          itemBuilder: (context, index) {
            final backup = backups[index];
            return _buildBackupItem(backup);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorDisplay(
        error: error,
        onRetry: () => ref.invalidate(backupListProvider),
      ),
    );
  }

  /// 构建备份项
  Widget _buildBackupItem(BackupInfo backup) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: backup.isAutomatic 
              ? Colors.blue.withOpacity(0.2)
              : Colors.green.withOpacity(0.2),
          child: Icon(
            backup.isAutomatic ? Icons.schedule : Icons.backup,
            color: backup.isAutomatic ? Colors.blue : Colors.green,
          ),
        ),
        title: Text(backup.description),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${backup.formattedTimestamp} • ${backup.formattedSize}'),
            if (backup.tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: backup.tags.map((tag) => Chip(
                  label: Text(tag),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleBackupAction(action, backup),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'restore',
              child: ListTile(
                leading: Icon(Icons.restore),
                title: Text('恢复'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'validate',
              child: ListTile(
                leading: Icon(Icons.verified),
                title: Text('验证'),
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
        ),
        onTap: () => _showBackupDetails(backup),
      ),
    );
  }

  /// 显示创建备份对话框
  Future<void> _showCreateBackupDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建备份'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<BackupType>(
                decoration: const InputDecoration(
                  labelText: '备份类型',
                  border: OutlineInputBorder(),
                ),
                value: _selectedBackupType,
                items: BackupType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(type.displayName),
                        Text(
                          type.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedBackupType = value!),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: '备份描述',
                  hintText: '请输入备份描述（可选）',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _backupDescription = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _createBackup();
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  /// 创建备份
  Future<void> _createBackup() async {
    final notifier = ref.read(backupOperationProvider.notifier);
    
    await notifier.createManualBackup(
      description: _backupDescription.isEmpty ? null : _backupDescription,
      tags: _backupTags,
      type: _selectedBackupType,
    );

    final result = ref.read(backupOperationProvider);
    result.whenOrNull(
      data: (backup) {
        if (backup != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('备份创建成功: ${backup.formattedSize}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('备份创建失败: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );

    // 清除结果
    notifier.clearResult();
  }

  /// 处理菜单操作
  void _handleMenuAction(String action) {
    switch (action) {
      case 'cleanup':
        _cleanupExpiredBackups();
        break;
      case 'settings':
        _showBackupSettings();
        break;
    }
  }

  /// 处理备份操作
  void _handleBackupAction(String action, BackupInfo backup) {
    switch (action) {
      case 'restore':
        _showRestoreDialog(backup);
        break;
      case 'validate':
        _validateBackup(backup);
        break;
      case 'delete':
        _showDeleteConfirmDialog(backup);
        break;
    }
  }

  /// 显示恢复对话框
  Future<void> _showRestoreDialog(BackupInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('恢复配置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('确定要从以下备份恢复配置吗？'),
            const SizedBox(height: 16),
            Text('备份: ${backup.description}'),
            Text('时间: ${backup.formattedTimestamp}'),
            Text('大小: ${backup.formattedSize}'),
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
                      '恢复操作将覆盖当前配置，建议先创建备份',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('恢复'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _restoreFromBackup(backup);
    }
  }

  /// 从备份恢复
  Future<void> _restoreFromBackup(BackupInfo backup) async {
    final notifier = ref.read(restoreOperationProvider.notifier);
    
    await notifier.restoreFromBackup(backup.id);

    final result = ref.read(restoreOperationProvider);
    result.whenOrNull(
      data: (restoreResult) {
        if (restoreResult != null && restoreResult.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('配置恢复成功'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (restoreResult != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('配置恢复失败: ${restoreResult.errors.join(', ')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('配置恢复失败: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );

    // 清除结果
    notifier.clearResult();
  }

  /// 验证备份
  Future<void> _validateBackup(BackupInfo backup) async {
    // TODO: 实现备份验证
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('备份验证功能开发中')),
    );
  }

  /// 显示删除确认对话框
  Future<void> _showDeleteConfirmDialog(BackupInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除备份'),
        content: Text('确定要删除备份"${backup.description}"吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteBackup(backup);
    }
  }

  /// 删除备份
  Future<void> _deleteBackup(BackupInfo backup) async {
    final notifier = ref.read(backupCleanupProvider.notifier);
    await notifier.deleteBackup(backup.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('备份已删除'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// 清理过期备份
  Future<void> _cleanupExpiredBackups() async {
    final notifier = ref.read(backupCleanupProvider.notifier);
    await notifier.cleanupExpiredBackups();

    final result = ref.read(backupCleanupProvider);
    result.whenOrNull(
      data: (cleanupResult) {
        if (cleanupResult != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '清理完成: 删除 ${cleanupResult.deletedCount} 个备份，释放 ${cleanupResult.formattedFreedSpace}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('清理失败: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );

    // 清除结果
    notifier.clearResult();
  }

  /// 显示备份详情
  void _showBackupDetails(BackupInfo backup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(backup.description),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', backup.id),
              _buildDetailRow('类型', backup.type.displayName),
              _buildDetailRow('大小', backup.formattedSize),
              _buildDetailRow('时间', backup.formattedTimestamp),
              _buildDetailRow('自动备份', backup.isAutomatic ? '是' : '否'),
              if (backup.trigger != null)
                _buildDetailRow('触发器', backup.trigger!.displayName),
              if (backup.tags.isNotEmpty)
                _buildDetailRow('标签', backup.tags.join(', ')),
              _buildDetailRow('提供商数量', backup.metadata.providerCount.toString()),
              _buildDetailRow('助手数量', backup.metadata.assistantCount.toString()),
              _buildDetailRow('包含偏好', backup.metadata.hasPreferences ? '是' : '否'),
              _buildDetailRow('包含设置', backup.metadata.hasSettings ? '是' : '否'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 构建详情行
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// 显示备份设置
  void _showBackupSettings() {
    // TODO: 实现备份设置界面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('备份设置功能开发中')),
    );
  }

  /// 格式化文件大小
  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
