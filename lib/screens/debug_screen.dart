import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../services/ai_service.dart';
import '../services/notification_service.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final AiService _aiService = AiService();

  @override
  Widget build(BuildContext context) {
    final debugLogs = _aiService.debugLogs.reversed.toList(); // 最新的在前面

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI调试日志'),
        actions: [
          Switch(
            value: _aiService.debugMode,
            onChanged: (value) {
              setState(() {
                _aiService.setDebugMode(value);
              });
              NotificationService().showInfo(value ? '调试模式已开启' : '调试模式已关闭');
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              _aiService.clearDebugLogs();
              setState(() {});
              NotificationService().showSuccess('调试日志已清空');
            },
          ),
        ],
      ),
      body: debugLogs.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: debugLogs.length,
              itemBuilder: (context, index) {
                final log = debugLogs[index];
                return _buildLogCard(log);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bug_report_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无调试日志',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _aiService.debugMode ? '发送AI消息后，调试信息将显示在这里' : '请先开启调试模式',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (!_aiService.debugMode) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _aiService.setDebugMode(true);
                });
                NotificationService().showSuccess('调试模式已开启');
              },
              icon: const Icon(Icons.bug_report),
              label: const Text('开启调试模式'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogCard(DebugInfo log) {
    final hasError = log.error != null;
    final duration = log.duration?.inMilliseconds ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: hasError
              ? Theme.of(context).colorScheme.errorContainer
              : Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            hasError ? Icons.error_outline : Icons.check_circle_outline,
            color: hasError
                ? Theme.of(context).colorScheme.onErrorContainer
                : Theme.of(context).colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          '${log.assistantId} • ${log.modelName}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: hasError ? Theme.of(context).colorScheme.error : null,
          ),
        ),
        subtitle: Text(
          '${_formatTime(log.timestamp)} • ${duration}ms${hasError ? ' • 失败' : ' • 成功'}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 基本信息
                _buildInfoSection('基本信息', {
                  '助手ID': log.assistantId,
                  '提供商ID': log.providerId,
                  '模型名称': log.modelName,
                  '时间戳': log.timestamp.toString(),
                  '耗时': '${duration}ms',
                  if (log.statusCode != null) '状态码': log.statusCode.toString(),
                }),

                const SizedBox(height: 16),

                // 请求体
                _buildJsonSection('请求体', log.requestBody),

                if (log.response != null) ...[
                  const SizedBox(height: 16),
                  _buildTextSection('响应内容', log.response!),
                ],

                if (log.error != null) ...[
                  const SizedBox(height: 16),
                  _buildTextSection('错误信息', log.error!, isError: true),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, Map<String, String> info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () => _copyToClipboard(info.toString()),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...info.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJsonSection(String title, Map<String, dynamic> data) {
    final jsonString = _prettyPrintJson(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () => _copyToClipboard(jsonString),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            jsonString,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextSection(
    String title,
    String content, {
    bool isError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isError ? Theme.of(context).colorScheme.error : null,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () => _copyToClipboard(content),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isError
                ? Theme.of(
                    context,
                  ).colorScheme.errorContainer.withValues(alpha: 0.3)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isError
                  ? Theme.of(context).colorScheme.error.withValues(alpha: 0.3)
                  : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: isError
                  ? Theme.of(context).colorScheme.onErrorContainer
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  String _prettyPrintJson(Map<String, dynamic> json) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (e) {
      return json.toString();
    }
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    NotificationService().showSuccess('已复制到剪贴板');
  }
}
