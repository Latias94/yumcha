import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mcp_dart/mcp_dart.dart';
import '../../../../features/settings/domain/entities/mcp_server_config.dart';
import '../logger_service.dart';

/// MCP 客户端服务
///
/// 负责管理与MCP服务器的连接和通信，支持：
/// - 🔌 **多协议支持**: STDIO、HTTP、SSE连接
/// - 📱 **平台适配**: 根据平台能力自动选择连接方式
/// - 🔄 **连接管理**: 自动重连、状态监控、错误处理
/// - 📊 **状态跟踪**: 实时跟踪服务器连接状态
/// - 🛠️ **工具发现**: 自动发现和同步服务器工具
///
/// ## 连接类型支持
/// - **STDIO**: 本地进程通信（桌面平台）
/// - **HTTP**: HTTP API 连接（所有平台）
/// - **SSE**: 服务器发送事件（所有平台）
class McpClientService {
  final LoggerService _logger = LoggerService();

  // 连接管理
  final Map<String, _McpConnection> _connections = {};
  final Map<String, McpServerStatus> _serverStatuses = {};
  final Map<String, String> _serverErrors = {};

  bool _isInitialized = false;

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 初始化客户端服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    _logger.info('🔌 初始化MCP客户端服务');
    _isInitialized = true;
    _logger.info('✅ MCP客户端服务初始化完成');
  }

  /// 连接到MCP服务器
  ///
  /// @param config 服务器配置
  Future<void> connectServer(McpServerConfig config) async {
    if (!_isInitialized) {
      throw StateError('MCP客户端服务未初始化');
    }

    _logger.info('连接MCP服务器', {
      'serverId': config.id,
      'serverName': config.name,
      'type': config.type.toString(),
    });

    try {
      // 如果已存在连接，先断开
      await _disconnectServer(config.id);

      // 设置连接状态
      _setServerStatus(config.id, McpServerStatus.connecting);
      _clearServerError(config.id);

      // 根据类型创建连接
      final connection = await _createConnection(config);
      _connections[config.id] = connection;

      // 测试连接是否真正可用 - 尝试获取工具列表
      await connection.listTools();

      // 连接测试成功，设置为已连接状态
      _setServerStatus(config.id, McpServerStatus.connected);

      _logger.info('MCP服务器连接成功', {
        'serverId': config.id,
        'serverName': config.name,
      });

      // 发现工具（此时连接已确认可用）
      await _discoverTools(config);
    } catch (e) {
      // 连接失败，清理连接对象
      _connections.remove(config.id);
      _setServerStatus(config.id, McpServerStatus.error);
      _setServerError(config.id, e.toString());

      _logger.error('MCP服务器连接失败', {
        'serverId': config.id,
        'serverName': config.name,
        'error': e.toString(),
      });

      rethrow;
    }
  }

  /// 断开服务器连接
  ///
  /// @param serverId 服务器ID
  Future<void> disconnectServer(String serverId) async {
    await _disconnectServer(serverId);
    _setServerStatus(serverId, McpServerStatus.disconnected);
    _clearServerError(serverId);
  }

  /// 重新连接服务器
  ///
  /// @param serverId 服务器ID
  Future<void> reconnectServer(String serverId) async {
    final connection = _connections[serverId];
    if (connection != null) {
      await connectServer(connection.config);
    }
  }

  /// 断开所有服务器连接
  Future<void> disconnectAllServers() async {
    final serverIds = _connections.keys.toList();
    for (final serverId in serverIds) {
      await disconnectServer(serverId);
    }
  }

  /// 获取服务器状态
  ///
  /// @param serverId 服务器ID
  /// @returns 服务器状态
  McpServerStatus getServerStatus(String serverId) {
    return _serverStatuses[serverId] ?? McpServerStatus.disconnected;
  }

  /// 检查服务器连接健康状态
  ///
  /// @param serverId 服务器ID
  /// @returns 连接是否健康
  Future<bool> checkServerHealth(String serverId) async {
    final connection = _connections[serverId];
    if (connection == null) {
      _setServerStatus(serverId, McpServerStatus.disconnected);
      return false;
    }

    final currentStatus = getServerStatus(serverId);
    if (currentStatus != McpServerStatus.connected) {
      return false;
    }

    try {
      // 尝试获取工具列表来验证连接
      await connection.listTools();
      return true;
    } catch (e) {
      // 连接已断开，更新状态
      _setServerStatus(serverId, McpServerStatus.error);
      _setServerError(serverId, '连接健康检查失败: ${e.toString()}');

      _logger.warning('MCP服务器健康检查失败', {
        'serverId': serverId,
        'error': e.toString(),
      });

      return false;
    }
  }

  /// 获取服务器错误信息
  ///
  /// @param serverId 服务器ID
  /// @returns 错误信息，如果没有错误则返回null
  String? getServerError(String serverId) {
    return _serverErrors[serverId];
  }

  /// 获取连接的服务器配置列表
  List<McpServerConfig> getConnectedServers() {
    return _connections.values
        .where((conn) =>
            getServerStatus(conn.config.id) == McpServerStatus.connected)
        .map((conn) => conn.config)
        .toList();
  }

  /// 调用MCP工具
  ///
  /// @param serverId 服务器ID
  /// @param toolName 工具名称
  /// @param arguments 工具参数
  /// @returns 工具执行结果
  Future<Map<String, dynamic>> callTool(
    String serverId,
    String toolName,
    Map<String, dynamic> arguments,
  ) async {
    final connection = _connections[serverId];
    if (connection == null) {
      throw StateError('服务器未连接: $serverId');
    }

    if (getServerStatus(serverId) != McpServerStatus.connected) {
      throw StateError('服务器未处于连接状态: $serverId');
    }

    return await connection.callTool(toolName, arguments);
  }

  /// 获取服务器工具列表
  ///
  /// @param serverId 服务器ID
  /// @returns 工具列表
  Future<List<McpTool>> getServerTools(String serverId) async {
    final connection = _connections[serverId];
    if (connection == null) {
      throw StateError('服务器未连接: $serverId');
    }

    if (getServerStatus(serverId) != McpServerStatus.connected) {
      throw StateError('服务器未处于连接状态: $serverId');
    }

    return await connection.listTools();
  }

  /// 获取服务统计信息
  Map<String, dynamic> getStats() {
    return {
      'initialized': _isInitialized,
      'connectionCount': _connections.length,
      'connectedCount': _connections.values
          .where((conn) =>
              getServerStatus(conn.config.id) == McpServerStatus.connected)
          .length,
      'serverStatuses': Map.fromEntries(
        _serverStatuses.entries.map((e) => MapEntry(e.key, e.value.name)),
      ),
    };
  }

  /// 检查服务健康状态
  Future<bool> checkHealth() async {
    return _isInitialized;
  }

  /// 清理服务资源
  Future<void> dispose() async {
    _logger.info('清理MCP客户端服务资源');

    await disconnectAllServers();

    _connections.clear();
    _serverStatuses.clear();
    _serverErrors.clear();
    _isInitialized = false;

    _logger.info('MCP客户端服务资源清理完成');
  }

  /// 创建连接
  Future<_McpConnection> _createConnection(McpServerConfig config) async {
    switch (config.type) {
      case McpServerType.stdio:
        return _StdioConnection(config, _logger);
      case McpServerType.streamableHttp:
        return _StreamableHttpConnection(config, _logger);
    }
  }

  /// 断开服务器连接（内部方法）
  Future<void> _disconnectServer(String serverId) async {
    final connection = _connections[serverId];
    if (connection != null) {
      try {
        await connection.disconnect();
      } catch (e) {
        _logger.error('断开连接失败', {
          'serverId': serverId,
          'error': e.toString(),
        });
      }
      _connections.remove(serverId);
    }
  }

  /// 发现工具
  Future<void> _discoverTools(McpServerConfig config) async {
    try {
      final connection = _connections[config.id];
      if (connection != null) {
        final tools = await connection.listTools();
        _logger.info('发现MCP工具', {
          'serverId': config.id,
          'toolCount': tools.length,
          'tools': tools.map((t) => t.name).toList(),
        });
      }
    } catch (e) {
      // 工具发现失败不应该影响连接状态，因为连接已经在connectServer中验证过了
      // 只记录警告，不更改服务器状态
      _logger.warning('工具发现失败', {
        'serverId': config.id,
        'error': e.toString(),
      });
    }
  }

  /// 设置服务器状态
  void _setServerStatus(String serverId, McpServerStatus status) {
    _serverStatuses[serverId] = status;
  }

  /// 设置服务器错误
  void _setServerError(String serverId, String error) {
    _serverErrors[serverId] = error;
  }

  /// 清除服务器错误
  void _clearServerError(String serverId) {
    _serverErrors.remove(serverId);
  }
}

/// MCP连接抽象基类
abstract class _McpConnection {
  final McpServerConfig config;
  final LoggerService logger;

  _McpConnection(this.config, this.logger);

  /// 列出可用工具
  Future<List<McpTool>> listTools();

  /// 调用工具
  Future<Map<String, dynamic>> callTool(
      String toolName, Map<String, dynamic> arguments);

  /// 断开连接
  Future<void> disconnect();
}

/// STDIO连接实现（桌面平台）
class _StdioConnection extends _McpConnection {
  Client? _mcpClient;
  StreamSubscription? _stderrSubscription;

  _StdioConnection(super.config, super.logger);

  /// 确保STDIO进程已启动并连接
  Future<Client> _ensureConnected() async {
    if (_mcpClient != null) {
      return _mcpClient!;
    }

    try {
      // 解析命令和参数
      final commandParts = config.command.split(' ');
      final executable = commandParts.first;
      final arguments =
          commandParts.length > 1 ? commandParts.sublist(1) : <String>[];

      logger.info('启动STDIO MCP进程', {
        'serverId': config.id,
        'executable': executable,
        'arguments': arguments,
      });

      // 创建MCP客户端
      _mcpClient = Client(
        Implementation(
          name: 'yumcha-mcp-client',
          version: '1.0.0',
        ),
      );

      // 创建STDIO传输（会自动管理进程）
      final transport = StdioClientTransport(
        StdioServerParameters(
          command: executable,
          args: arguments,
          environment: config.headers,
          stderrMode: ProcessStartMode.normal, // 捕获stderr用于调试
        ),
      );

      // 监听stderr输出用于调试
      transport.stderr?.listen((data) {
        final line = utf8.decode(data);
        logger.warning('STDIO MCP进程stderr', {
          'serverId': config.id,
          'line': line.trim(),
        });
      });

      // 连接到服务器
      await _mcpClient!.connect(transport);

      logger.info('STDIO MCP客户端连接成功', {
        'serverId': config.id,
        'command': config.command,
      });

      return _mcpClient!;
    } catch (e) {
      logger.error('STDIO MCP客户端连接失败', {
        'serverId': config.id,
        'error': e.toString(),
      });
      await _cleanup();
      rethrow;
    }
  }

  /// 清理资源
  Future<void> _cleanup() async {
    await _stderrSubscription?.cancel();
    _stderrSubscription = null;

    if (_mcpClient != null) {
      try {
        await _mcpClient!.close();
      } catch (e) {
        logger.warning('关闭MCP客户端时出错', {
          'serverId': config.id,
          'error': e.toString(),
        });
      }
      _mcpClient = null;
    }
  }

  @override
  Future<List<McpTool>> listTools() async {
    try {
      final client = await _ensureConnected();
      final response = await client.listTools();

      if (response.tools.isEmpty) {
        return [];
      }

      // 转换为应用内的McpTool格式
      final tools = response.tools.map((tool) {
        return McpTool(
          name: tool.name,
          description: tool.description,
          isEnabled: true,
          inputSchema: tool.inputSchema.toJson(),
        );
      }).toList();

      logger.info('STDIO获取工具列表成功', {
        'serverId': config.id,
        'toolCount': tools.length,
        'tools': tools.map((t) => t.name).toList(),
      });

      return tools;
    } catch (e) {
      logger.error('STDIO获取工具列表失败', {
        'serverId': config.id,
        'error': e.toString(),
      });
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> callTool(
      String toolName, Map<String, dynamic> arguments) async {
    try {
      final client = await _ensureConnected();

      // 调用工具
      final response = await client.callTool(
        CallToolRequestParams(
          name: toolName,
          arguments: arguments,
        ),
      );

      // 处理响应内容
      final result = <String, dynamic>{};
      if (response.content.isNotEmpty) {
        final content = response.content.first;
        if (content is TextContent) {
          result['text'] = content.text;
        } else if (content is ImageContent) {
          result['image'] = content.data;
          result['mimeType'] = content.mimeType;
        }
      }

      // 如果有错误信息
      if (response.isError == true) {
        result['error'] = 'Tool execution failed';
      }

      logger.info('STDIO工具调用成功', {
        'serverId': config.id,
        'toolName': toolName,
        'hasResult': result.isNotEmpty,
      });

      return result;
    } catch (e) {
      logger.error('STDIO工具调用失败', {
        'serverId': config.id,
        'toolName': toolName,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _cleanup();
      logger.info('STDIO连接已断开', {'serverId': config.id});
    } catch (e) {
      logger.warning('STDIO断开连接时出错', {
        'serverId': config.id,
        'error': e.toString(),
      });
    }
  }
}

/// StreamableHTTP连接实现（支持HTTP和SSE）
class _StreamableHttpConnection extends _McpConnection {
  StreamSubscription? _subscription;
  Client? _mcpClient;

  _StreamableHttpConnection(super.config, super.logger);

  /// 确保MCP客户端已连接
  Future<Client> _ensureConnected() async {
    if (_mcpClient != null) {
      return _mcpClient!;
    }

    try {
      // 创建MCP客户端
      _mcpClient = Client(
        Implementation(
          name: 'yumcha-mcp-client',
          version: '1.0.0',
        ),
      );

      // 解析和验证URL
      final uri = Uri.parse(config.command);
      logger.info('解析MCP服务器URL', {
        'serverId': config.id,
        'originalUrl': config.command,
        'scheme': uri.scheme,
        'host': uri.host,
        'port': uri.port,
        'path': uri.path,
        'fullUri': uri.toString(),
      });

      // 创建StreamableHTTP传输
      final transport = StreamableHttpClientTransport(
        uri, // 使用解析后的URI
        opts: StreamableHttpClientTransportOptions(
          requestInit:
              config.headers.isNotEmpty ? {'headers': config.headers} : null,
        ),
      );

      // 连接到服务器
      logger.info('开始连接MCP服务器', {
        'serverId': config.id,
        'url': config.command,
        'transport': 'StreamableHTTP',
      });

      await _mcpClient!.connect(transport);

      logger.info('StreamableHTTP MCP客户端连接成功', {
        'serverId': config.id,
        'url': config.command,
        'sessionId': transport.sessionId,
      });

      return _mcpClient!;
    } catch (e) {
      logger.error('StreamableHTTP MCP客户端连接失败', {
        'serverId': config.id,
        'url': config.command,
        'error': e.toString(),
      });
      _mcpClient = null;
      rethrow;
    }
  }

  @override
  Future<List<McpTool>> listTools() async {
    try {
      final client = await _ensureConnected();
      final response = await client.listTools();

      if (response.tools.isEmpty) {
        return [];
      }

      // 转换为应用内的McpTool格式
      final tools = response.tools.map((tool) {
        return McpTool(
          name: tool.name,
          description: tool.description,
          isEnabled: true,
          inputSchema: tool.inputSchema.toJson(),
        );
      }).toList();

      // logger.info('StreamableHTTP获取工具列表成功', {
      //   'serverId': config.id,
      //   'toolCount': tools.length,
      //   'tools': tools.map((t) => t.name).toList(),
      // });

      return tools;
    } catch (e) {
      logger.error('StreamableHTTP获取工具列表失败', {
        'serverId': config.id,
        'error': e.toString(),
      });
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> callTool(
      String toolName, Map<String, dynamic> arguments) async {
    try {
      final client = await _ensureConnected();

      // 调用工具
      final response = await client.callTool(
        CallToolRequestParams(
          name: toolName,
          arguments: arguments,
        ),
      );

      // 调试：记录原始响应
      logger.debug('StreamableHTTP工具原始响应', {
        'serverId': config.id,
        'toolName': toolName,
        'contentCount': response.content.length,
        'isError': response.isError,
        'contentTypes': response.content.map((c) => c.runtimeType.toString()).toList(),
      });

      // 处理响应内容
      final result = <String, dynamic>{};
      if (response.content.isNotEmpty) {
        final content = response.content.first;
        if (content is TextContent) {
          result['text'] = content.text;
          logger.debug('StreamableHTTP工具文本内容', {
            'serverId': config.id,
            'toolName': toolName,
            'textLength': content.text.length,
            'textPreview': content.text.length > 100
                ? '${content.text.substring(0, 100)}...'
                : content.text,
          });
        } else if (content is ImageContent) {
          result['image'] = content.data;
          result['mimeType'] = content.mimeType;
        }
      }

      // 如果有错误信息
      if (response.isError == true) {
        result['error'] = 'Tool execution failed';
      }

      logger.info('StreamableHTTP工具调用成功', {
        'serverId': config.id,
        'toolName': toolName,
        'hasResult': result.isNotEmpty,
      });

      return result;
    } catch (e) {
      logger.error('StreamableHTTP工具调用失败', {
        'serverId': config.id,
        'toolName': toolName,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _subscription?.cancel();
      _subscription = null;

      if (_mcpClient != null) {
        await _mcpClient!.close();
        _mcpClient = null;
      }

      logger.info('StreamableHTTP连接已断开', {'serverId': config.id});
    } catch (e) {
      logger.warning('StreamableHTTP断开连接时出错', {
        'serverId': config.id,
        'error': e.toString(),
      });
    }
  }
}
