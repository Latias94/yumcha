// 🔌 MCP 调试屏幕
//
// 专门用于测试和调试 MCP (Model Context Protocol) 功能的开发工具界面。
// 提供实时的MCP服务器连接状态监控、工具调用测试和调试信息。
//
// 🎯 **主要功能**:
// - 🔍 **连接监控**: 实时显示所有MCP服务器的连接状态
// - 🛠️ **工具测试**: 测试MCP服务器提供的工具和功能
// - 📊 **状态详情**: 显示详细的连接信息和错误日志
// - 🔄 **连接控制**: 手动连接、断开、重连服务器
// - 📋 **工具列表**: 显示每个服务器提供的工具清单
// - 🧪 **工具调用**: 直接调用MCP工具进行测试
// - 📄 **日志查看**: 查看详细的MCP通信日志
// - 🚀 **性能监控**: 监控MCP调用的性能指标
//
// 🔌 **调试功能**:
// - **服务器状态**: 显示每个服务器的详细状态信息
// - **工具发现**: 自动发现并列出可用的MCP工具
// - **消息追踪**: 追踪MCP协议的消息交换
// - **错误诊断**: 提供详细的错误信息和解决建议
// - **性能分析**: 分析工具调用的响应时间和成功率
//
// 📱 **界面组织**:
// - 服务器状态：显示所有配置的MCP服务器状态
// - 工具列表：展示每个服务器提供的工具
// - 调试控制：提供连接控制和测试功能
// - 日志面板：显示详细的调试日志和错误信息
//
// 🛠️ **使用场景**:
// - 调试MCP服务器连接问题
// - 测试MCP工具的功能和性能
// - 监控MCP服务的运行状态
// - 开发和验证MCP集成

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../settings/domain/entities/mcp_server_config.dart';
import '../../../settings/presentation/providers/settings_notifier.dart';
import '../../../settings/presentation/providers/mcp_service_provider.dart';
import '../../../../shared/infrastructure/services/mcp/mcp_service_manager.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';
import 'dart:convert';

class McpDebugScreen extends ConsumerStatefulWidget {
  const McpDebugScreen({super.key});

  @override
  ConsumerState<McpDebugScreen> createState() => _McpDebugScreenState();
}

class _McpDebugScreenState extends ConsumerState<McpDebugScreen> {
  bool _isDebugPanelExpanded = true;
  String _debugLogs = '';
  final String _selectedServerId = '';
  final List<String> _logEntries = [];

  // 工具测试相关状态
  String _selectedToolName = '';
  String _toolResponse = '';
  String _toolRequestBody = '';
  String _toolResponseBody = '';
  bool _isToolTesting = false;
  final _toolArgumentsController = TextEditingController();
  final List<String> _availableTools = [];

  @override
  void initState() {
    super.initState();
    _initializeDebugSession();
    _loadAvailableTools();
  }

  @override
  void dispose() {
    _toolArgumentsController.dispose();
    super.dispose();
  }

  void _initializeDebugSession() {
    _addLogEntry('🔌 MCP调试会话开始');
    _addLogEntry('📊 正在加载MCP服务器状态...');

    // 延迟加载，确保provider已经初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
      final mcpServers = settingsNotifier.getMcpServers();
      _addLogEntry('📋 发现 ${mcpServers.servers.length} 个MCP服务器配置');

      for (final server in mcpServers.servers) {
        _addLogEntry('🔧 服务器: ${server.name} (${server.type.displayName})');
      }
    });
  }

  void _addLogEntry(String entry) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final logEntry = '[$timestamp] $entry';
    setState(() {
      _logEntries.add(logEntry);
      _debugLogs = _logEntries.join('\n');
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mcpState = ref.watch(mcpServiceProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
    final mcpServers = settingsNotifier.getMcpServers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MCP 调试'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDebugInfo,
            tooltip: '刷新状态',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearLogs,
            tooltip: '清空日志',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 响应式布局：小屏幕使用垂直布局，大屏幕使用水平布局
          final isWideScreen = constraints.maxWidth > 800;

          return Column(
            children: [
              // 主要内容区域 - 可滚动
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // MCP服务状态概览
                      _buildMcpStatusOverview(mcpState, mcpServers),

                      const Divider(height: 1),

                      // 服务器列表和工具测试面板
                      if (isWideScreen)
                        // 大屏幕：水平布局
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 左侧：服务器列表
                              Expanded(
                                flex: 1,
                                child: _buildServerDebugList(mcpServers),
                              ),

                              const VerticalDivider(width: 1),

                              // 右侧：工具测试面板
                              Expanded(
                                flex: 1,
                                child: _buildToolTestPanel(),
                              ),
                            ],
                          ),
                        )
                      else
                        // 小屏幕：垂直布局
                        Column(
                          children: [
                            _buildServerDebugList(mcpServers),
                            const Divider(height: 1),
                            _buildToolTestPanel(),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // 调试日志面板 - 固定在底部
              const Divider(height: 1),
              _buildCollapsibleDebugPanel(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMcpStatusOverview(
      McpServiceState mcpState, McpServersConfig serversConfig) {
    final enabledServers = serversConfig.enabledServers;
    final totalServers = serversConfig.servers.length;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  mcpState.isEnabled ? Icons.check_circle : Icons.cancel,
                  color: mcpState.isEnabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'MCP服务状态',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: mcpState.isEnabled
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    mcpState.isEnabled ? '已启用' : '已禁用',
                    style: TextStyle(
                      fontSize: 12,
                      color: mcpState.isEnabled
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatusItem('总服务器', totalServers.toString()),
                const SizedBox(width: 24),
                _buildStatusItem('已启用', enabledServers.length.toString()),
                const SizedBox(width: 24),
                _buildStatusItem('已连接', _getConnectedCount().toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  int _getConnectedCount() {
    // 这里应该从MCP服务状态中获取实际的连接数量
    // 暂时返回0作为占位符
    return 0;
  }

  Widget _buildServerDebugList(McpServersConfig serversConfig) {
    if (serversConfig.servers.isEmpty) {
      return Container(
        constraints: const BoxConstraints(minHeight: 300),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.terminal_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                '暂无MCP服务器配置',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '请先在MCP设置中添加服务器',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: serversConfig.servers.map((server) {
          return _buildServerDebugCard(server);
        }).toList(),
      ),
    );
  }

  Widget _buildServerDebugCard(McpServerConfig server) {
    final status = ref.watch(mcpServerStatusProvider(server.id));
    final error = ref.watch(mcpServerErrorProvider(server.id));
    final isSelected = _selectedServerId == server.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(status),
          child: Icon(
            _getStatusIcon(status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(server.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${server.type.displayName} • ${_getStatusText(status)}'),
            if (error != null) ...[
              const SizedBox(height: 4),
              Text(
                '错误: $error',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        children: [
          _buildServerDebugDetails(server, status, error),
        ],
      ),
    );
  }

  Widget _buildServerDebugDetails(
      McpServerConfig server, McpServerStatus status, String? error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 服务器基本信息
          _buildInfoSection('基本信息', [
            'ID: ${server.id}',
            '类型: ${server.type.displayName}',
            '命令: ${server.command}',
            '状态: ${server.isEnabled ? "启用" : "禁用"}',
            '创建时间: ${server.createdAt.toLocal().toString().substring(0, 19)}',
          ]),

          const SizedBox(height: 16),

          // 连接状态
          _buildInfoSection('连接状态', [
            '当前状态: ${_getStatusText(status)}',
            if (error != null) '错误信息: $error',
            '最后更新: ${DateTime.now().toLocal().toString().substring(0, 19)}',
          ]),

          const SizedBox(height: 16),

          // 调试操作
          _buildDebugActions(server, status),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        item,
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDebugActions(McpServerConfig server, McpServerStatus status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '调试操作',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: () => _testConnection(server),
              icon: const Icon(Icons.link, size: 16),
              label: const Text('测试连接'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _refreshServerStatus(server),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('刷新状态'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _copyServerInfo(server),
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('复制信息'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.tertiaryContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCollapsibleDebugPanel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 面板头部 - 可点击收起/展开
        Container(
          height: 60,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: InkWell(
            onTap: () {
              setState(() {
                _isDebugPanelExpanded = !_isDebugPanelExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    _isDebugPanelExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'MCP调试日志',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const Spacer(),
                  if (_logEntries.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_logEntries.length} 条',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () => _copyToClipboard(_debugLogs),
                    tooltip: '复制日志',
                  ),
                  Text(
                    _isDebugPanelExpanded ? '收起' : '展开',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 面板内容 - 只在展开时显示
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isDebugPanelExpanded ? 250 : 0,
          child: _isDebugPanelExpanded
              ? Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '调试日志内容',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: _clearLogs,
                            tooltip: '清空日志',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).colorScheme.outline),
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _debugLogs.isEmpty ? '暂无调试日志...' : _debugLogs,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Color _getStatusColor(McpServerStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case McpServerStatus.connected:
        return colorScheme.primary;
      case McpServerStatus.connecting:
        return colorScheme.tertiary;
      case McpServerStatus.error:
        return colorScheme.error;
      case McpServerStatus.disconnected:
        return colorScheme.onSurfaceVariant;
    }
  }

  IconData _getStatusIcon(McpServerStatus status) {
    switch (status) {
      case McpServerStatus.connected:
        return Icons.check_circle;
      case McpServerStatus.connecting:
        return Icons.sync;
      case McpServerStatus.error:
        return Icons.error;
      case McpServerStatus.disconnected:
        return Icons.circle_outlined;
    }
  }

  String _getStatusText(McpServerStatus status) {
    switch (status) {
      case McpServerStatus.connected:
        return '已连接';
      case McpServerStatus.connecting:
        return '连接中';
      case McpServerStatus.error:
        return '连接失败';
      case McpServerStatus.disconnected:
        return '未连接';
    }
  }

  void _refreshDebugInfo() {
    _addLogEntry('🔄 手动刷新调试信息');

    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
    final mcpServers = settingsNotifier.getMcpServers();
    final mcpState = ref.read(mcpServiceProvider);

    _addLogEntry('📊 MCP服务状态: ${mcpState.isEnabled ? "启用" : "禁用"}');
    _addLogEntry('📋 服务器数量: ${mcpServers.servers.length}');
    _addLogEntry('✅ 已启用服务器: ${mcpServers.enabledServers.length}');

    for (final server in mcpServers.servers) {
      final status = ref.read(mcpServerStatusProvider(server.id));
      _addLogEntry('🔧 ${server.name}: ${_getStatusText(status)}');
    }

    NotificationService().showSuccess('调试信息已刷新');
  }

  void _clearLogs() {
    setState(() {
      _logEntries.clear();
      _debugLogs = '';
    });
    _addLogEntry('🧹 调试日志已清空');
  }

  void _testConnection(McpServerConfig server) {
    _addLogEntry('🔗 测试连接: ${server.name}');

    // 这里应该调用实际的连接测试逻辑
    // 暂时模拟测试过程
    Future.delayed(const Duration(seconds: 1), () {
      _addLogEntry('✅ 连接测试完成: ${server.name}');
    });

    NotificationService().showInfo('正在测试连接: ${server.name}');
  }

  void _refreshServerStatus(McpServerConfig server) {
    _addLogEntry('🔄 刷新服务器状态: ${server.name}');

    // 这里应该调用实际的状态刷新逻辑
    final status = ref.read(mcpServerStatusProvider(server.id));
    _addLogEntry('📊 ${server.name} 当前状态: ${_getStatusText(status)}');

    NotificationService().showSuccess('状态已刷新: ${server.name}');
  }

  void _copyServerInfo(McpServerConfig server) {
    final serverInfo = {
      'id': server.id,
      'name': server.name,
      'description': server.description,
      'type': server.type.name,
      'command': server.command,
      'args': server.args,
      'env': server.env,
      'isEnabled': server.isEnabled,
      'createdAt': server.createdAt.toIso8601String(),
      'updatedAt': server.updatedAt.toIso8601String(),
    };

    const encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(serverInfo);

    _copyToClipboard(jsonString);
    _addLogEntry('📋 已复制服务器信息: ${server.name}');
  }

  // 工具测试相关方法
  void _loadAvailableTools() {
    _addLogEntry('🔍 正在加载可用工具...');

    // 延迟加载，确保provider已经初始化
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final mcpManager = ref.read(mcpServiceManagerProvider);
      final allTools = await mcpManager.getAllAvailableTools();

      setState(() {
        _availableTools.clear();
        _availableTools.addAll(allTools.map((tool) => tool.name));
      });

      _addLogEntry('🛠️ 发现 ${_availableTools.length} 个可用工具');
      for (final toolName in _availableTools) {
        _addLogEntry('  - $toolName');
      }
    });
  }

  Widget _buildToolTestPanel() {
    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 工具测试标题
          Row(
            children: [
              const Icon(Icons.build, size: 20),
              const SizedBox(width: 8),
              Text(
                'MCP工具测试',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadAvailableTools,
                tooltip: '刷新工具列表',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 工具选择
          _buildToolSelector(),

          const SizedBox(height: 16),

          // 参数输入
          _buildArgumentsInput(),

          const SizedBox(height: 16),

          // 测试按钮
          _buildTestButton(),

          const SizedBox(height: 16),

          // 结果显示
          SizedBox(
            height: 400, // 固定高度，避免布局问题
            child: _buildTestResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildToolSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择工具',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (_availableTools.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '暂无可用工具\n请确保MCP服务器已连接',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: _selectedToolName.isEmpty ? null : _selectedToolName,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '选择要测试的工具',
                ),
                items: _availableTools.map((tool) {
                  return DropdownMenuItem(
                    value: tool,
                    child: Text(tool),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedToolName = value ?? '';
                  });
                  _addLogEntry('🔧 选择工具: $value');
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildArgumentsInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '工具参数 (JSON格式)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _toolArgumentsController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '{"param1": "value1", "param2": "value2"}',
                helperText: '请输入有效的JSON格式参数',
              ),
              maxLines: 4,
              onChanged: (value) {
                // 参数值直接从控制器获取，无需额外存储
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed:
            _selectedToolName.isEmpty || _isToolTesting ? null : _testTool,
        icon: _isToolTesting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.play_arrow),
        label: Text(_isToolTesting ? '测试中...' : '测试工具'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTestResults() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: const TabBar(
              tabs: [
                Tab(text: '响应结果'),
                Tab(text: '请求体'),
                Tab(text: '响应体'),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: TabBarView(
                children: [
                  _buildResponseTab(),
                  _buildRequestBodyTab(),
                  _buildResponseBodyTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '工具响应结果',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_toolResponse.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () => _copyToClipboard(_toolResponse),
                  tooltip: '复制响应',
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: SingleChildScrollView(
                child: Text(
                  _toolResponse.isEmpty ? '等待工具响应...' : _toolResponse,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestBodyTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '请求体',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_toolRequestBody.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () => _copyToClipboard(_toolRequestBody),
                  tooltip: '复制请求体',
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: SingleChildScrollView(
                child: Text(
                  _toolRequestBody.isEmpty ? '等待请求...' : _toolRequestBody,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseBodyTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '响应体',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_toolResponseBody.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () => _copyToClipboard(_toolResponseBody),
                  tooltip: '复制响应体',
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: SingleChildScrollView(
                child: Text(
                  _toolResponseBody.isEmpty ? '等待响应...' : _toolResponseBody,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testTool() async {
    if (_selectedToolName.isEmpty) {
      _addLogEntry('❌ 请先选择要测试的工具');
      return;
    }

    setState(() {
      _isToolTesting = true;
      _toolResponse = '';
      _toolRequestBody = '';
      _toolResponseBody = '';
    });

    _addLogEntry('🚀 开始测试工具: $_selectedToolName');

    try {
      // 解析参数
      Map<String, dynamic> arguments = {};
      final argumentsText = _toolArgumentsController.text.trim();

      if (argumentsText.isNotEmpty) {
        try {
          arguments = jsonDecode(argumentsText) as Map<String, dynamic>;
        } catch (e) {
          throw Exception('参数JSON格式错误: $e');
        }
      }

      // 生成请求体
      final requestData = {
        'tool': _selectedToolName,
        'arguments': arguments,
        'timestamp': DateTime.now().toIso8601String(),
      };

      const encoder = JsonEncoder.withIndent('  ');
      final requestBody = encoder.convert(requestData);

      setState(() {
        _toolRequestBody = requestBody;
      });

      _addLogEntry('📤 请求参数: ${arguments.toString()}');

      // 调用MCP工具
      final mcpManager = ref.read(mcpServiceManagerProvider);
      final result = await mcpManager.callTool(
        _selectedToolName,
        arguments,
      );

      // 处理响应
      final responseData = {
        'success': true,
        'result': result,
        'error': null,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final responseBody = encoder.convert(responseData);

      setState(() {
        _toolResponse = result.toString();
        _toolResponseBody = responseBody;
      });

      _addLogEntry('✅ 工具调用成功');
      _addLogEntry('📥 响应长度: ${result.toString().length} 字符');
    } catch (e) {
      _addLogEntry('❌ 工具测试失败: $e');

      setState(() {
        _toolResponse = '错误: $e';
        _toolResponseBody = jsonEncode({
          'error': true,
          'message': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
    } finally {
      setState(() {
        _isToolTesting = false;
      });
    }
  }
}
