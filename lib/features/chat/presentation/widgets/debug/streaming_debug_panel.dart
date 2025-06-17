/// 流式消息调试面板
///
/// 用于在开发环境中显示流式消息的详细调试信息
library;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../infrastructure/debug/streaming_debug_helper.dart';

/// 流式消息调试面板Widget
class StreamingDebugPanel extends StatefulWidget {
  const StreamingDebugPanel({super.key});

  @override
  State<StreamingDebugPanel> createState() => _StreamingDebugPanelState();
}

class _StreamingDebugPanelState extends State<StreamingDebugPanel> {
  List<String> _trackedMessages = [];
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _refreshTrackedMessages();
  }

  void _refreshTrackedMessages() {
    setState(() {
      _trackedMessages = StreamingDebugHelper.getTrackedMessages();
    });
  }

  void _clearAll() {
    StreamingDebugHelper.clearAll();
    _refreshTrackedMessages();
  }

  @override
  Widget build(BuildContext context) {
    // 只在调试模式下显示
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 100,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 切换按钮
          FloatingActionButton.small(
            onPressed: () {
              setState(() {
                _isVisible = !_isVisible;
              });
              _refreshTrackedMessages();
            },
            backgroundColor: Colors.orange,
            child: Icon(_isVisible ? Icons.close : Icons.bug_report),
          ),

          if (_isVisible) ...[
            const SizedBox(height: 8),

            // 调试面板
            Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                children: [
                  // 标题栏
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bug_report,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          '流式消息调试',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _clearAll,
                          icon: const Icon(Icons.clear_all,
                              color: Colors.white, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // 内容区域
                  Expanded(
                    child: _trackedMessages.isEmpty
                        ? const Center(
                            child: Text(
                              '暂无跟踪的流式消息',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _trackedMessages.length,
                            itemBuilder: (context, index) {
                              final messageId = _trackedMessages[index];
                              return _buildMessageItem(messageId);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageItem(String messageId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 消息ID
          Text(
            'ID: ${messageId.length > 20 ? '...${messageId.substring(messageId.length - 20)}' : messageId}',
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),

          const SizedBox(height: 4),

          // 操作按钮
          Row(
            children: [
              _buildActionButton(
                '生成报告',
                Icons.assessment,
                () => _generateReport(messageId),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                '刷新',
                Icons.refresh,
                _refreshTrackedMessages,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.orange, size: 12),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateReport(String messageId) {
    final report = StreamingDebugHelper.finishTracking(messageId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('流式消息调试报告'),
        content: SingleChildScrollView(
          child: Text(
            _formatReport(report),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
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

    _refreshTrackedMessages();
  }

  String _formatReport(Map<String, dynamic> report) {
    final buffer = StringBuffer();

    buffer.writeln('消息ID: ${report['messageId']}');
    buffer.writeln('总更新次数: ${report['totalUpdates']}');
    buffer.writeln('最终内容长度: ${report['finalContentLength']}');
    buffer.writeln('');

    if (report['contentGrowth'] != null) {
      buffer.writeln('内容增长分析:');
      final growth = report['contentGrowth'] as List;
      for (final item in growth.take(10)) {
        // 只显示前10次更新
        buffer.writeln(
            '  ${item['index']}: ${item['length']} (+${item['lengthDiff']}) ${item['ending']}');
      }
      if (growth.length > 10) {
        buffer.writeln('  ... 还有 ${growth.length - 10} 次更新');
      }
      buffer.writeln('');
    }

    if (report['timingAnalysis'] != null) {
      final timing = report['timingAnalysis'] as Map<String, dynamic>;
      buffer.writeln('时序分析:');
      buffer.writeln('  总持续时间: ${timing['totalDuration']}ms');
      buffer.writeln('  平均间隔: ${timing['averageInterval']}ms');
      buffer.writeln('  中位间隔: ${timing['medianInterval']}ms');
      buffer.writeln('');
    }

    if (report['potentialIssues'] != null) {
      final issues = report['potentialIssues'] as List;
      if (issues.isNotEmpty) {
        buffer.writeln('潜在问题:');
        for (final issue in issues) {
          buffer.writeln('  ⚠️ $issue');
        }
        buffer.writeln('');
      }
    }

    if (report['finalContent'] != null) {
      final content = report['finalContent'] as String;
      buffer.writeln('最终内容预览:');
      buffer.writeln(
          content.length > 200 ? '${content.substring(0, 200)}...' : content);
    }

    return buffer.toString();
  }
}
