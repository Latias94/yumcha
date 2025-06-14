import 'dart:async';
import 'package:mcp_dart/mcp_dart.dart';
import '../entities/mcp_server_config.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';
import '../../../../shared/infrastructure/services/mcp/mcp_service_manager.dart';

/// MCP (Model Context Protocol) 服务管理器
///
/// 负责管理 MCP 服务器连接和工具调用功能。MCP 是一个开放协议，
/// 允许 AI 应用连接到外部工具和数据源。
///
/// 主要功能：
/// - 🔌 **服务器管理**: 连接和管理多个 MCP 服务器
/// - 🛠️ **工具调用**: 调用 MCP 服务器提供的工具
/// - 🌐 **多协议支持**: 支持 STDIO、HTTP、SSE 连接类型
/// - 📱 **平台适配**: 根据平台能力自动适配连接方式
/// - 🔍 **状态监控**: 实时监控服务器连接状态
/// - ⚙️ **配置验证**: 验证服务器配置的有效性
///
/// 支持的连接类型：
/// - **STDIO**: 本地进程通信（桌面平台）
/// - **HTTP**: HTTP API 连接（所有平台）
/// - **SSE**: 服务器发送事件（所有平台）
///
/// 使用场景：
/// - AI 助手需要访问外部工具时
/// - 扩展 AI 应用的功能边界
/// - 集成第三方服务和数据源

/// MCP 工具调用结果
class McpToolResult {
  final String toolName;
  final Map<String, dynamic> arguments;
  final String result;
  final String? error;
  final Duration duration;

  const McpToolResult({
    required this.toolName,
    required this.arguments,
    required this.result,
    this.error,
    required this.duration,
  });

  bool get isSuccess => error == null;
}

// McpServerStatus 已在 mcp_server_config.dart 中定义

/// MCP 服务器实例
class McpServerInstance {
  final McpServerConfig config;
  final Client client;
  McpServerStatus status;
  String? errorMessage;
  List<Tool> availableTools;
  DateTime? lastConnected;

  McpServerInstance({
    required this.config,
    required this.client,
    this.status = McpServerStatus.disconnected,
    this.errorMessage,
    this.availableTools = const [],
    this.lastConnected,
  });
}

/// MCP 服务管理器
class ManageMcpServerUseCase {
  static final ManageMcpServerUseCase _instance =
      ManageMcpServerUseCase._internal();
  factory ManageMcpServerUseCase() => _instance;
  ManageMcpServerUseCase._internal();

  final LoggerService _logger = LoggerService();
  final Map<String, McpServerInstance> _servers = {};
  bool _isEnabled = false;

  /// 获取所有服务器实例
  Map<String, McpServerInstance> get servers => Map.unmodifiable(_servers);

  /// 获取 MCP 启用状态
  bool get isEnabled => _isEnabled;

  /// 设置 MCP 启用状态
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    _logger.info('MCP 服务${enabled ? '启用' : '禁用'}');

    // 同步设置 McpServiceManager 的状态
    final mcpServiceManager = McpServiceManager();
    await mcpServiceManager.setEnabled(enabled);

    if (!enabled) {
      // 禁用时断开所有连接
      await disconnectAllServers();
    }
  }

  /// 初始化 MCP 服务器
  Future<void> initializeServers(List<McpServerConfig> configs) async {
    if (!_isEnabled) {
      _logger.debug('MCP 服务未启用，跳过初始化');
      return;
    }

    _logger.info('初始化 MCP 服务器', {'count': configs.length});

    // 断开现有连接
    await disconnectAllServers();

    // 初始化新的服务器
    for (final config in configs) {
      if (config.isEnabled) {
        await _initializeServer(config);
      }
    }
  }

  /// 初始化单个服务器
  Future<void> _initializeServer(McpServerConfig config) async {
    try {
      _logger.info('初始化 MCP 服务器', {'name': config.name, 'type': config.type});

      // 检查平台兼容性
      if (!_isPlatformCompatible(config.type)) {
        throw Exception('当前平台不支持 ${config.type.displayName} 连接类型');
      }

      Transport transport;
      switch (config.type) {
        case McpServerType.stdio:
          transport = StdioClientTransport(
            StdioServerParameters(
              command: config.command,
              args: config.args,
              environment: config.env,
            ),
          );
          break;
        case McpServerType.streamableHttp:
          // 使用StreamableHttpClientTransport进行HTTP/SSE连接
          transport = StreamableHttpClientTransport(
            Uri.parse(config.command),
            opts: StreamableHttpClientTransportOptions(
              requestInit: config.headers.isNotEmpty
                  ? {'headers': config.headers}
                  : null,
            ),
          );
          break;
      }

      final client = Client(
        Implementation(name: 'YumCha', version: '1.0.0'),
        options: ClientOptions(capabilities: ClientCapabilities()),
      );

      final instance = McpServerInstance(
        config: config,
        client: client,
        status: McpServerStatus.connecting,
      );

      _servers[config.id] = instance;

      // 连接到服务器
      await _connectServer(instance, transport);
    } catch (e) {
      _logger.error('初始化 MCP 服务器失败', {
        'name': config.name,
        'error': e.toString(),
      });

      _servers[config.id] = McpServerInstance(
        config: config,
        client: Client(
          Implementation(name: 'YumCha', version: '1.0.0'),
          options: ClientOptions(),
        ),
        status: McpServerStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 连接到服务器
  Future<void> _connectServer(
    McpServerInstance instance,
    Transport transport,
  ) async {
    try {
      await instance.client.connect(transport);

      // 获取可用工具
      final toolsResult = await instance.client.listTools();
      instance.availableTools = toolsResult.tools;
      instance.status = McpServerStatus.connected;
      instance.lastConnected = DateTime.now();
      instance.errorMessage = null;

      _logger.info('MCP 服务器连接成功', {
        'name': instance.config.name,
        'tools': instance.availableTools.length,
      });

      NotificationService().showSuccess('MCP 服务器 ${instance.config.name} 连接成功');
    } catch (e) {
      instance.status = McpServerStatus.error;
      instance.errorMessage = e.toString();

      _logger.error('MCP 服务器连接失败', {
        'name': instance.config.name,
        'error': e.toString(),
      });

      NotificationService().showError(
        'MCP 服务器 ${instance.config.name} 连接失败: $e',
      );
    }
  }

  /// 断开所有服务器连接
  Future<void> disconnectAllServers() async {
    _logger.info('断开所有 MCP 服务器连接');

    for (final instance in _servers.values) {
      try {
        await instance.client.close();
        instance.status = McpServerStatus.disconnected;
      } catch (e) {
        _logger.error('断开 MCP 服务器连接失败', {
          'name': instance.config.name,
          'error': e.toString(),
        });
      }
    }

    _servers.clear();
  }

  /// 断开特定服务器连接
  Future<void> disconnectServer(String serverId) async {
    final instance = _servers[serverId];
    if (instance == null) return;

    try {
      await instance.client.close();
      instance.status = McpServerStatus.disconnected;
      _servers.remove(serverId);

      _logger.info('MCP 服务器断开连接', {'name': instance.config.name});
    } catch (e) {
      _logger.error('断开 MCP 服务器连接失败', {
        'name': instance.config.name,
        'error': e.toString(),
      });
    }
  }

  /// 获取所有可用工具
  List<Tool> getAllAvailableTools() {
    if (!_isEnabled) return [];

    final tools = <Tool>[];
    for (final instance in _servers.values) {
      if (instance.status == McpServerStatus.connected) {
        tools.addAll(instance.availableTools);
      }
    }
    return tools;
  }

  /// 调用工具
  Future<McpToolResult> callTool({
    required String toolName,
    required Map<String, dynamic> arguments,
  }) async {
    final startTime = DateTime.now();

    if (!_isEnabled) {
      return McpToolResult(
        toolName: toolName,
        arguments: arguments,
        result: '',
        error: 'MCP 服务未启用',
        duration: DateTime.now().difference(startTime),
      );
    }

    // 查找包含该工具的服务器
    McpServerInstance? targetInstance;
    for (final instance in _servers.values) {
      if (instance.status == McpServerStatus.connected) {
        final tool = instance.availableTools.firstWhere(
          (tool) => tool.name == toolName,
          orElse: () => Tool(
            name: '',
            description: '',
            inputSchema: ToolInputSchema(properties: {}),
          ),
        );
        if (tool.name.isNotEmpty) {
          targetInstance = instance;
          break;
        }
      }
    }

    if (targetInstance == null) {
      return McpToolResult(
        toolName: toolName,
        arguments: arguments,
        result: '',
        error: '找不到工具: $toolName',
        duration: DateTime.now().difference(startTime),
      );
    }

    try {
      _logger.info('调用 MCP 工具', {
        'tool': toolName,
        'server': targetInstance.config.name,
        'arguments': arguments,
      });

      final result = await targetInstance.client.callTool(
        CallToolRequestParams(name: toolName, arguments: arguments),
      );

      final duration = DateTime.now().difference(startTime);
      final resultText = result.content.map((c) {
        if (c is TextContent) {
          return c.text;
        } else if (c is ImageContent) {
          return '[图像内容: ${c.data}]';
        } else {
          return c.toString();
        }
      }).join('\n');

      _logger.info('MCP 工具调用成功', {
        'tool': toolName,
        'duration': '${duration.inMilliseconds}ms',
      });

      return McpToolResult(
        toolName: toolName,
        arguments: arguments,
        result: resultText,
        duration: duration,
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime);

      _logger.error('MCP 工具调用失败', {
        'tool': toolName,
        'server': targetInstance.config.name,
        'error': e.toString(),
      });

      return McpToolResult(
        toolName: toolName,
        arguments: arguments,
        result: '',
        error: e.toString(),
        duration: duration,
      );
    }
  }

  /// 重新连接服务器
  Future<void> reconnectServer(String serverId) async {
    final instance = _servers[serverId];
    if (instance == null) return;

    await disconnectServer(serverId);
    await _initializeServer(instance.config);
  }

  /// 获取服务器状态
  McpServerStatus getServerStatus(String serverId) {
    return _servers[serverId]?.status ?? McpServerStatus.disconnected;
  }

  /// 获取服务器错误信息
  String? getServerError(String serverId) {
    return _servers[serverId]?.errorMessage;
  }

  /// 检查平台兼容性
  bool _isPlatformCompatible(McpServerType type) {
    switch (type) {
      case McpServerType.stdio:
        return PlatformUtils.supportsLocalProcesses;
      case McpServerType.streamableHttp:
        return PlatformUtils.supportsNetworkConnections;
    }
  }

  /// 获取推荐的连接类型（基于当前平台）
  List<McpServerType> getRecommendedServerTypes() {
    final types = <McpServerType>[];

    if (PlatformUtils.supportsLocalProcesses) {
      types.add(McpServerType.stdio);
    }

    if (PlatformUtils.supportsNetworkConnections) {
      types.add(McpServerType.streamableHttp);
    }

    return types;
  }

  /// 获取平台特定的示例配置
  Map<String, String> getPlatformSpecificExamples(McpServerType type) {
    final examples = PlatformUtils.getMcpServerExamples();

    switch (type) {
      case McpServerType.stdio:
        return {
          'command': examples['stdio_command'] ?? '/usr/local/bin/mcp-server',
          'args': examples['stdio_args'] ?? '--config config.json',
          'description': PlatformUtils.isDesktop
              ? '${PlatformUtils.platformName} 可执行文件路径'
              : '本地可执行文件（当前平台不支持）',
        };
      case McpServerType.streamableHttp:
        return {
          'command': examples['http_url'] ?? 'http://localhost:8080/mcp',
          'description': '远程 StreamableHTTP MCP 服务器（支持HTTP和SSE）',
        };
    }
  }

  /// 获取平台信息
  Map<String, dynamic> getPlatformInfo() {
    return {
      'platform': PlatformUtils.platformName,
      'icon': PlatformUtils.platformIcon,
      'isDesktop': PlatformUtils.isDesktop,
      'isMobile': PlatformUtils.isMobile,
      'supportsStdio': PlatformUtils.supportsLocalProcesses,
      'supportsNetwork': PlatformUtils.supportsNetworkConnections,
      'recommendations': PlatformUtils.getPerformanceRecommendations(),
    };
  }

  /// 验证服务器配置
  Future<Map<String, dynamic>> validateServerConfig(
    McpServerConfig config,
  ) async {
    final result = <String, dynamic>{
      'isValid': true,
      'warnings': <String>[],
      'errors': <String>[],
      'suggestions': <String>[],
    };

    // 检查平台兼容性
    if (!_isPlatformCompatible(config.type)) {
      result['isValid'] = false;
      result['errors'].add(
        '当前平台 (${PlatformUtils.platformName}) 不支持 ${config.type.displayName} 连接类型',
      );
      result['suggestions'].add(
        '建议使用: ${getRecommendedServerTypes().map((t) => t.displayName).join(', ')}',
      );
    }

    // 检查命令路径
    if (config.type == McpServerType.stdio) {
      if (config.command.isEmpty) {
        result['isValid'] = false;
        result['errors'].add('STDIO 连接类型需要指定可执行文件路径');
      } else if (!PlatformUtils.isAbsolutePath(config.command)) {
        result['warnings'].add('建议使用绝对路径以避免路径解析问题');
      }
    }

    // 检查URL格式
    if (config.type == McpServerType.streamableHttp) {
      if (config.command.isEmpty) {
        result['isValid'] = false;
        result['errors'].add('${config.type.displayName} 连接类型需要指定URL');
      } else {
        try {
          final uri = Uri.parse(config.command);
          if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
            result['warnings'].add('URL应该以 http:// 或 https:// 开头');
          }
        } catch (e) {
          result['isValid'] = false;
          result['errors'].add('URL格式无效: ${e.toString()}');
        }
      }
    }

    return result;
  }
}
