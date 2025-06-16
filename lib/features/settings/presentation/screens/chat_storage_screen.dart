// 💾 聊天存储管理屏幕
//
// 用于管理聊天数据的存储，包括存储空间查看、数据清理、导入导出等功能。
// 提供用户管理聊天历史记录和存储空间的工具。
//
// 🎯 **主要功能**:
// - 📊 **存储统计**: 显示聊天数据占用的存储空间
// - 🗑️ **数据清理**: 清理过期或不需要的聊天记录
// - 📤 **数据导出**: 导出聊天记录到文件
// - 📥 **数据导入**: 从文件导入聊天记录
// - 🔄 **数据备份**: 创建和恢复数据备份
// - ⚙️ **存储设置**: 配置自动清理和存储限制
//
// 📱 **界面特点**:
// - 使用 SliverAppBar 提供大标题效果
// - 卡片式布局展示存储信息和操作
// - 支持进度显示和操作确认
// - 提供详细的存储使用情况

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';

class ChatStorageScreen extends ConsumerStatefulWidget {
  const ChatStorageScreen({super.key});

  @override
  ConsumerState<ChatStorageScreen> createState() => _ChatStorageScreenState();
}

class _ChatStorageScreenState extends ConsumerState<ChatStorageScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _storageInfo = {};
  bool _autoCleanEnabled = true;
  int _autoCleanDays = 30;
  int _maxStorageSize = 100; // MB

  @override
  void initState() {
    super.initState();
    _loadStorageInfo();
  }

  Future<void> _loadStorageInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 实现实际的存储信息获取逻辑
      await Future.delayed(const Duration(seconds: 1)); // 模拟加载
      
      setState(() {
        _storageInfo = {
          'totalChats': 156,
          'totalMessages': 3420,
          'storageUsed': 45.6, // MB
          'lastCleanup': DateTime.now().subtract(const Duration(days: 7)),
          'oldestChat': DateTime.now().subtract(const Duration(days: 90)),
        };
      });
    } catch (e) {
      NotificationService().showError('加载存储信息失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearOldChats() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清理旧聊天记录'),
        content: Text('确定要清理 $_autoCleanDays 天前的聊天记录吗？此操作无法撤销。'),
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
        setState(() {
          _isLoading = true;
        });
        
        // 实际的清理逻辑 - 需要实现具体的数据库清理功能
        await Future.delayed(const Duration(seconds: 2)); // 模拟清理过程
        
        NotificationService().showSuccess('旧聊天记录已清理');
        await _loadStorageInfo(); // 重新加载存储信息
      } catch (e) {
        NotificationService().showError('清理失败: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _clearAllChats() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空所有聊天记录'),
        content: const Text('确定要清空所有聊天记录吗？此操作无法撤销，建议先导出备份。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('确定清空'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() {
          _isLoading = true;
        });
        
        // TODO: 实现实际的清空逻辑
        await Future.delayed(const Duration(seconds: 2)); // 模拟清空过程
        
        NotificationService().showSuccess('所有聊天记录已清空');
        await _loadStorageInfo(); // 重新加载存储信息
      } catch (e) {
        NotificationService().showError('清空失败: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _exportChats() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // TODO: 实现实际的导出逻辑
      await Future.delayed(const Duration(seconds: 3)); // 模拟导出过程
      
      // 模拟创建导出文件
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/yumcha_chats_export.json');
      await file.writeAsString('{"chats": [], "exported_at": "${DateTime.now().toIso8601String()}"}');
      
      // 分享文件
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'YumCha 聊天记录导出',
      );
      
      NotificationService().showSuccess('聊天记录已导出');
    } catch (e) {
      NotificationService().showError('导出失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _importChats() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isLoading = true;
        });
        
        // TODO: 实现实际的导入逻辑
        await Future.delayed(const Duration(seconds: 2)); // 模拟导入过程
        
        NotificationService().showSuccess('聊天记录已导入');
        await _loadStorageInfo(); // 重新加载存储信息
      }
    } catch (e) {
      NotificationService().showError('导入失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text("聊天存储管理"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: DesignConstants.paddingL,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 存储统计卡片
                    _buildStorageStatsCard(),
                    SizedBox(height: DesignConstants.spaceXL),

                    // 数据管理卡片
                    _buildDataManagementCard(),
                    SizedBox(height: DesignConstants.spaceXL),

                    // 导入导出卡片
                    _buildImportExportCard(),
                    SizedBox(height: DesignConstants.spaceXL),

                    // 自动清理设置卡片
                    _buildAutoCleanupCard(),
                    SizedBox(height: DesignConstants.spaceXXXL),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStorageStatsCard() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '存储统计',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),
            
            // 存储使用情况
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '已使用存储',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: DesignConstants.spaceXS),
                      Text(
                        '${_storageInfo['storageUsed']?.toStringAsFixed(1) ?? '0.0'} MB',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: (_storageInfo['storageUsed'] ?? 0) / _maxStorageSize,
                    strokeWidth: 6,
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: DesignConstants.spaceL),
            
            // 详细统计
            _buildStatRow('聊天数量', '${_storageInfo['totalChats'] ?? 0}'),
            _buildStatRow('消息数量', '${_storageInfo['totalMessages'] ?? 0}'),
            _buildStatRow('最后清理', _formatDate(_storageInfo['lastCleanup'])),
            _buildStatRow('最早聊天', _formatDate(_storageInfo['oldestChat'])),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementCard() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cleaning_services,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '数据清理',
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
                onPressed: _clearOldChats,
                icon: const Icon(Icons.auto_delete),
                label: Text('清理 $_autoCleanDays 天前的聊天'),
              ),
            ),
            SizedBox(height: DesignConstants.spaceM),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _clearAllChats,
                icon: const Icon(Icons.delete_forever),
                label: const Text('清空所有聊天记录'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportExportCard() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.import_export,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '导入导出',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportChats,
                    icon: const Icon(Icons.file_upload),
                    label: const Text('导出'),
                  ),
                ),
                SizedBox(width: DesignConstants.spaceM),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _importChats,
                    icon: const Icon(Icons.file_download),
                    label: const Text('导入'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoCleanupCard() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: DesignConstants.spaceM),
                Text(
                  '自动清理设置',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceL),
            
            SwitchListTile(
              title: const Text('启用自动清理'),
              subtitle: const Text('定期清理旧的聊天记录'),
              value: _autoCleanEnabled,
              onChanged: (value) {
                setState(() {
                  _autoCleanEnabled = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            
            if (_autoCleanEnabled) ...[
              SizedBox(height: DesignConstants.spaceM),
              ListTile(
                title: const Text('清理周期'),
                subtitle: Text('清理 $_autoCleanDays 天前的记录'),
                trailing: DropdownButton<int>(
                  value: _autoCleanDays,
                  items: [7, 14, 30, 60, 90].map((days) {
                    return DropdownMenuItem(
                      value: days,
                      child: Text('$days 天'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _autoCleanDays = value!;
                    });
                  },
                ),
                contentPadding: EdgeInsets.zero,
              ),
              
              ListTile(
                title: const Text('存储限制'),
                subtitle: Text('最大存储 $_maxStorageSize MB'),
                trailing: DropdownButton<int>(
                  value: _maxStorageSize,
                  items: [50, 100, 200, 500, 1000].map((size) {
                    return DropdownMenuItem(
                      value: size,
                      child: Text('$size MB'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _maxStorageSize = value!;
                    });
                  },
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignConstants.spaceS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '未知';
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    if (difference == 0) return '今天';
    if (difference == 1) return '昨天';
    return '$difference 天前';
  }
}
