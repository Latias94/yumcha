// 🐛 AI 调试屏幕
//
// 用于查看和管理 AI 服务的调试日志，帮助开发者诊断 AI 请求问题。
// 提供详细的请求响应信息、错误日志和性能统计。
//
// 🎯 **主要功能**:
// - 📊 **调试日志**: 显示所有 AI 请求的详细日志
// - 🔄 **调试模式**: 开启/关闭调试模式的开关
// - 🧹 **日志清理**: 清空所有调试日志
// - 📋 **详细信息**: 展示请求体、响应内容、错误信息
// - ⏱️ **性能统计**: 显示请求耗时和状态码
// - 📄 **复制功能**: 支持复制日志内容到剪贴板
// - 🎨 **状态标识**: 用不同颜色标识成功和失败的请求
//
// 📱 **界面特点**:
// - 使用可展开的卡片显示日志详情
// - 支持 JSON 格式化显示
// - 提供空状态提示和快速开启调试模式
// - 使用等宽字体显示技术信息
//
// 🛠️ **调试信息包含**:
// - 基本信息：助手ID、提供商ID、模型名称、时间戳、耗时
// - 请求体：完整的 API 请求参数
// - 响应内容：AI 返回的响应数据
// - 错误信息：详细的错误堆栈和描述
//
// 💡 **使用场景**:
// - 开发调试 AI 功能
// - 诊断 API 调用问题
// - 性能分析和优化
// - 错误排查和修复

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/infrastructure/services/ai/ai_service_manager.dart'
    as manager;
import '../../../../shared/infrastructure/services/ai/providers/ai_service_provider.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';

class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(manager.aiServiceStatsProvider);
    final healthAsync = ref.watch(manager.aiServiceHealthProvider);
    final cacheStats = ref.watch(modelCacheStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI服务监控'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(manager.aiServiceStatsProvider);
              ref.invalidate(manager.aiServiceHealthProvider);
              ref.invalidate(modelCacheStatsProvider);
              NotificationService().showSuccess('数据已刷新');
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              // 清空所有提供商的缓存
              ref.read(clearModelCacheProvider(null));
              // 刷新缓存统计
              ref.invalidate(modelCacheStatsProvider);
              NotificationService().showSuccess('缓存已清空');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 服务健康状态
            _buildHealthSection(healthAsync),
            const SizedBox(height: 16),

            // 服务统计信息
            _buildStatsSection(stats),
            const SizedBox(height: 16),

            // 缓存统计信息
            _buildCacheSection(AsyncValue.data(cacheStats)),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthSection(AsyncValue<Map<String, bool>> healthAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.health_and_safety,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '服务健康状态',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            healthAsync.when(
              data: (health) => Column(
                children: health.entries.map((entry) {
                  final isHealthy = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          isHealthy ? Icons.check_circle : Icons.error,
                          color: isHealthy
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          isHealthy ? '正常' : '异常',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isHealthy
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text(
                '加载失败: $error',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '服务统计信息',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...stats.entries.map((entry) {
              final serviceName = entry.key;
              final serviceStats = entry.value as Map<String, dynamic>;

              return ExpansionTile(
                title: Text(serviceName),
                subtitle: Text(
                  '状态: ${serviceStats['initialized'] ? '已初始化' : '未初始化'}',
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: serviceStats.entries.map((statEntry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  statEntry.key,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                statEntry.value.toString(),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheSection(AsyncValue<Map<String, dynamic>> cacheStatsAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '缓存统计信息',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            cacheStatsAsync.when(
              data: (cacheStats) => Column(
                children: cacheStats.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          entry.value.toString(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text(
                '加载失败: $error',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
