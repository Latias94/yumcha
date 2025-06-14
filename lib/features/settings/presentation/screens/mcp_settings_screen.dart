// 🔌 MCP 设置屏幕
//
// 用于配置和管理 MCP (Model Context Protocol) 服务器的界面。
// MCP 是一个开放协议，允许 AI 应用连接到外部工具和数据源。
//
// 🎯 **主要功能**:
// - 🔄 **MCP 启用**: 全局启用或禁用 MCP 功能
// - 📋 **服务器管理**: 添加、编辑、删除 MCP 服务器配置
// - 🔗 **连接管理**: 连接、断开、重连服务器
// - 📊 **状态监控**: 实时显示服务器连接状态
// - 🛠️ **配置编辑**: 详细的服务器配置编辑界面
// - 🌐 **平台适配**: 根据平台推荐合适的连接类型
// - ⚠️ **错误处理**: 显示连接错误和状态信息
//
// 🔌 **支持的连接类型**:
// - **STDIO**: 标准输入输出，适用于本地进程通信（仅桌面平台）
// - **StreamableHTTP**: HTTP/SSE 连接，适用于远程服务调用（所有平台）
//
// 📱 **界面特点**:
// - 使用卡片式布局展示服务器信息
// - 支持空状态提示和平台信息显示
// - 提供服务器状态的可视化指示
// - 集成服务器编辑和配置管理
//
// 🛠️ **服务器管理**:
// - 支持多种服务器类型的配置
// - 提供示例配置和平台特定建议
// - 实时状态监控和错误报告
// - 支持服务器的启用/禁用控制
//
// 💡 **使用场景**:
// - 配置外部工具和服务集成
// - 扩展 AI 功能和能力
// - 连接本地或远程的数据源
// - 实现自定义的 AI 工具链

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/mcp_server_config.dart';
import '../providers/settings_notifier.dart';
import '../providers/mcp_service_provider.dart';
import '../../domain/usecases/manage_mcp_server_usecase.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';
import '../../../debug/presentation/screens/mcp_debug_screen.dart';

class McpSettingsScreen extends ConsumerStatefulWidget {
  const McpSettingsScreen({super.key});

  @override
  ConsumerState<McpSettingsScreen> createState() => _McpSettingsScreenState();
}

class _McpSettingsScreenState extends ConsumerState<McpSettingsScreen> {
  McpServersConfig? _serversConfig;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // 延迟加载，确保provider已经初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
        final mcpEnabled = settingsNotifier.getMcpEnabled();
        final serversConfig = settingsNotifier.getMcpServers();

        setState(() {
          _serversConfig = serversConfig;
        });

        // 同步MCP服务状态
        ref.read(mcpServiceProvider.notifier).setEnabled(mcpEnabled);
        if (mcpEnabled) {
          ref
              .read(mcpServiceProvider.notifier)
              .initializeServers(serversConfig.enabledServers);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mcpState = ref.watch(mcpServiceProvider);

    // 监听设置变化，更新本地服务器配置
    ref.listen(settingsNotifierProvider, (previous, next) {
      if (!next.isLoading && next.error == null) {
        final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
        final newServersConfig = settingsNotifier.getMcpServers();
        if (newServersConfig != _serversConfig) {
          setState(() {
            _serversConfig = newServersConfig;
          });
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('MCP 设置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _openMcpDebug,
            tooltip: 'MCP调试',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addServer,
            tooltip: '添加服务器',
          ),
        ],
      ),
      body: Column(
        children: [
          // MCP 启用开关
          Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('启用 MCP'),
                  subtitle: const Text('启用 Model Context Protocol 支持'),
                  value: mcpState.isEnabled,
                  onChanged: _toggleMcp,
                ),
                if (mcpState.isEnabled) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildPlatformInfo(),
                  ),
                ],
              ],
            ),
          ),

          // 服务器列表
          Expanded(
            child: mcpState.isEnabled
                ? _buildServersList()
                : Center(
                    child: Text(
                      'MCP 服务未启用',
                      style: TextStyle(
                          fontSize: 16,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildServersList() {
    // 如果配置还没有加载，显示加载指示器
    if (_serversConfig == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_serversConfig!.servers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.terminal_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              '暂无 MCP 服务器',
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              '点击右上角 + 按钮添加服务器',
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _serversConfig!.servers.length,
      itemBuilder: (context, index) {
        final server = _serversConfig!.servers[index];
        return _buildServerCard(server);
      },
    );
  }

  Widget _buildServerCard(McpServerConfig server) {
    final status = ref.watch(mcpServerStatusProvider(server.id));
    final error = ref.watch(mcpServerErrorProvider(server.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(status, context),
          child: Icon(_getStatusIcon(status),
              color: Theme.of(context).colorScheme.onPrimary, size: 20),
        ),
        title: Text(server.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(server.description.isNotEmpty ? server.description : '无描述'),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(
                    server.type.displayName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(status),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(status, context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 4),
              Text(
                '错误: $error',
                style: TextStyle(
                    fontSize: 12, color: Theme.of(context).colorScheme.error),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleServerAction(value, server),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('编辑'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (status == McpServerStatus.connected)
              const PopupMenuItem(
                value: 'disconnect',
                child: ListTile(
                  leading: Icon(Icons.link_off),
                  title: Text('断开连接'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            if (status != McpServerStatus.connected)
              const PopupMenuItem(
                value: 'connect',
                child: ListTile(
                  leading: Icon(Icons.link),
                  title: Text('重新连接'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete,
                    color: Theme.of(context).colorScheme.error),
                title: Text('删除',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () => _editServer(server),
      ),
    );
  }

  Color _getStatusColor(McpServerStatus status, BuildContext context) {
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

  Future<void> _toggleMcp(bool enabled) async {
    final mcpNotifier = ref.read(mcpServiceProvider.notifier);

    try {
      // 更新MCP服务状态（会自动保存到设置）
      await mcpNotifier.setEnabled(enabled);

      if (enabled && _serversConfig != null) {
        await mcpNotifier.initializeServers(_serversConfig!.enabledServers);
      }

      NotificationService().showSuccess(enabled ? 'MCP 服务已启用' : 'MCP 服务已禁用');
    } catch (e) {
      NotificationService().showError('MCP 设置失败: $e');
    }
  }

  void _openMcpDebug() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const McpDebugScreen(),
      ),
    );
  }

  void _addServer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => McpServerEditScreen(onSave: _saveServer),
      ),
    );
  }

  void _editServer(McpServerConfig server) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            McpServerEditScreen(server: server, onSave: _saveServer),
      ),
    );
  }

  Future<void> _saveServer(McpServerConfig server) async {
    if (_serversConfig == null) return;

    setState(() {
      if (_serversConfig!.findById(server.id) != null) {
        _serversConfig = _serversConfig!.updateServer(server);
      } else {
        _serversConfig = _serversConfig!.addServer(server);
      }
    });

    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
    await settingsNotifier.setMcpServers(_serversConfig!);

    final mcpState = ref.read(mcpServiceProvider);
    if (mcpState.isEnabled && server.isEnabled) {
      await ref
          .read(mcpServiceProvider.notifier)
          .initializeServers(_serversConfig!.enabledServers);
    }

    NotificationService().showSuccess('服务器配置已保存');
  }

  Future<void> _handleServerAction(
    String action,
    McpServerConfig server,
  ) async {
    switch (action) {
      case 'edit':
        _editServer(server);
        break;
      case 'connect':
        await ref.read(mcpServiceProvider.notifier).reconnectServer(server.id);
        break;
      case 'disconnect':
        await ref.read(mcpServiceProvider.notifier).disconnectServer(server.id);
        break;
      case 'delete':
        _deleteServer(server);
        break;
    }
  }

  void _deleteServer(McpServerConfig server) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除服务器'),
        content: Text('确定要删除服务器 "${server.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              if (_serversConfig != null) {
                setState(() {
                  _serversConfig = _serversConfig!.removeServer(server.id);
                });

                final settingsNotifier = ref.read(
                  settingsNotifierProvider.notifier,
                );
                await settingsNotifier.setMcpServers(_serversConfig!);

                await ref
                    .read(mcpServiceProvider.notifier)
                    .disconnectServer(server.id);

                NotificationService().showSuccess('服务器已删除');
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 构建平台信息显示
  Widget _buildPlatformInfo() {
    final isDesktop =
        Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    final platformName = Platform.isWindows
        ? 'Windows'
        : Platform.isMacOS
            ? 'macOS'
            : Platform.isLinux
                ? 'Linux'
                : Platform.isAndroid
                    ? 'Android'
                    : Platform.isIOS
                        ? 'iOS'
                        : '未知平台';

    final recommendedTypes = _getRecommendedServerTypes();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isDesktop ? Icons.desktop_windows : Icons.phone_android,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '当前平台: $platformName',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '推荐连接类型: ${recommendedTypes.map((t) => t.displayName).join(', ')}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        if (!isDesktop) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '移动端建议使用 StreamableHTTP 连接远程服务器',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12,
                      ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// 获取推荐的服务器类型
  List<McpServerType> _getRecommendedServerTypes() {
    final isDesktop =
        Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    if (isDesktop) {
      return [McpServerType.stdio, McpServerType.streamableHttp];
    } else {
      return [McpServerType.streamableHttp];
    }
  }
}

// MCP 服务器编辑页面
class McpServerEditScreen extends StatefulWidget {
  final McpServerConfig? server;
  final Function(McpServerConfig) onSave;

  const McpServerEditScreen({super.key, this.server, required this.onSave});

  @override
  State<McpServerEditScreen> createState() => _McpServerEditScreenState();
}

class _McpServerEditScreenState extends State<McpServerEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _commandController = TextEditingController();
  final _argsController = TextEditingController();
  final _envController = TextEditingController();

  McpServerType _selectedType = McpServerType.stdio;
  bool _isEnabled = true;

  @override
  void initState() {
    super.initState();
    if (widget.server != null) {
      final server = widget.server!;
      _nameController.text = server.name;
      _descriptionController.text = server.description;
      _commandController.text = server.command;
      _argsController.text = server.args.join(' ');
      _envController.text =
          server.env.entries.map((e) => '${e.key}=${e.value}').join('\n');
      _selectedType = server.type;
      _isEnabled = server.isEnabled;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _commandController.dispose();
    _argsController.dispose();
    _envController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.server == null ? '添加服务器' : '编辑服务器'),
        actions: [TextButton(onPressed: _saveServer, child: const Text('保存'))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 基本信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '基本信息',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '服务器名称',
                        hintText: '例如：文件系统工具',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入服务器名称';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: '描述（可选）',
                        hintText: '描述服务器的功能',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('启用服务器'),
                      subtitle: const Text('是否在启动时自动连接此服务器'),
                      value: _isEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 连接配置
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '连接配置',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<McpServerType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: '连接类型',
                        border: OutlineInputBorder(),
                      ),
                      items: _getAvailableServerTypes().map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(
                                _getServerTypeIcon(type),
                                size: 16,
                                color: _isTypeRecommended(type)
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(type.displayName),
                              if (_isTypeRecommended(type)) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _commandController,
                      decoration: InputDecoration(
                        labelText: _selectedType == McpServerType.stdio
                            ? '命令路径'
                            : 'URL',
                        hintText: _selectedType == McpServerType.stdio
                            ? '例如：/usr/local/bin/mcp-server'
                            : '例如：http://localhost:8080/mcp',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return _selectedType == McpServerType.stdio
                              ? '请输入命令路径'
                              : '请输入URL';
                        }
                        return null;
                      },
                    ),
                    if (_selectedType == McpServerType.stdio) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _argsController,
                        decoration: const InputDecoration(
                          labelText: '命令参数（可选）',
                          hintText: '例如：--config /path/to/config.json',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _envController,
                        decoration: const InputDecoration(
                          labelText: '环境变量（可选）',
                          hintText: '每行一个，格式：KEY=VALUE',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 示例配置
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '示例配置',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getExampleText(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getExampleText() {
    final mcpService = ManageMcpServerUseCase();
    final examples = mcpService.getPlatformSpecificExamples(_selectedType);

    if (examples.isNotEmpty) {
      switch (_selectedType) {
        case McpServerType.stdio:
          return '''名称：${examples['description'] ?? '文件系统工具'}
命令：${examples['command'] ?? '/usr/local/bin/filesystem-mcp'}
参数：${examples['args'] ?? '--root /home/user/documents'}
环境变量：
LOG_LEVEL=info
MAX_FILE_SIZE=10MB''';
        case McpServerType.streamableHttp:
          return '''名称：远程API工具
URL：${examples['command'] ?? 'http://localhost:8080/mcp'}
描述：${examples['description'] ?? '远程 StreamableHTTP MCP 服务器（支持HTTP和SSE）'}''';
      }
    }

    // 默认示例
    switch (_selectedType) {
      case McpServerType.stdio:
        return '''名称：文件系统工具
命令：/usr/local/bin/filesystem-mcp
参数：--root /home/user/documents
环境变量：
LOG_LEVEL=info
MAX_FILE_SIZE=10MB''';
      case McpServerType.streamableHttp:
        return '''名称：远程API工具
URL：http://localhost:8080/mcp
描述：远程 StreamableHTTP MCP 服务器（支持HTTP和SSE）''';
    }
  }

  /// 获取可用的服务器类型（基于平台）
  List<McpServerType> _getAvailableServerTypes() {
    return ManageMcpServerUseCase().getRecommendedServerTypes();
  }

  /// 检查类型是否推荐
  bool _isTypeRecommended(McpServerType type) {
    final recommended = ManageMcpServerUseCase().getRecommendedServerTypes();
    return recommended.contains(type);
  }

  /// 获取服务器类型图标
  IconData _getServerTypeIcon(McpServerType type) {
    switch (type) {
      case McpServerType.stdio:
        return Icons.terminal;
      case McpServerType.streamableHttp:
        return Icons.cloud;
    }
  }

  Future<void> _saveServer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 解析参数
    final args = _argsController.text.trim().isEmpty
        ? <String>[]
        : _argsController.text.trim().split(' ');

    // 解析环境变量
    final env = <String, String>{};
    if (_envController.text.trim().isNotEmpty) {
      for (final line in _envController.text.trim().split('\n')) {
        final parts = line.split('=');
        if (parts.length == 2) {
          env[parts[0].trim()] = parts[1].trim();
        }
      }
    }

    final server = widget.server?.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          type: _selectedType,
          command: _commandController.text.trim(),
          args: args,
          env: env,
          isEnabled: _isEnabled,
          updatedAt: DateTime.now(),
        ) ??
        McpServerConfig.create(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          type: _selectedType,
          command: _commandController.text.trim(),
          args: args,
          env: env,
          isEnabled: _isEnabled,
        );

    // 验证配置
    final mcpService = ManageMcpServerUseCase();
    final validation = await mcpService.validateServerConfig(server);

    if (!validation['isValid']) {
      // 显示错误对话框
      _showValidationDialog(validation);
      return;
    }

    // 如果有警告，询问用户是否继续
    if ((validation['warnings'] as List).isNotEmpty) {
      final shouldContinue = await _showWarningDialog(validation);
      if (!shouldContinue) return;
    }

    widget.onSave(server);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  /// 显示验证错误对话框
  void _showValidationDialog(Map<String, dynamic> validation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('配置验证失败'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((validation['errors'] as List).isNotEmpty) ...[
              const Text('错误:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...(validation['errors'] as List<String>).map(
                (error) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error,
                          color: Theme.of(context).colorScheme.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(error)),
                    ],
                  ),
                ),
              ),
            ],
            if ((validation['suggestions'] as List).isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('建议:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...(validation['suggestions'] as List<String>).map(
                (suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Theme.of(context).colorScheme.tertiary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(suggestion)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示警告对话框
  Future<bool> _showWarningDialog(Map<String, dynamic> validation) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('配置警告'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('发现以下警告，是否继续保存？'),
                const SizedBox(height: 16),
                ...(validation['warnings'] as List<String>).map(
                  (warning) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning,
                          color: Theme.of(context).colorScheme.tertiary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(warning)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('继续保存'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
