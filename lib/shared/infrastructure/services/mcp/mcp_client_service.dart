import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
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

      // 连接成功
      _setServerStatus(config.id, McpServerStatus.connected);
      
      _logger.info('MCP服务器连接成功', {
        'serverId': config.id,
        'serverName': config.name,
      });

      // 发现工具
      await _discoverTools(config);

    } catch (e) {
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
        .where((conn) => getServerStatus(conn.config.id) == McpServerStatus.connected)
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

  /// 获取服务统计信息
  Map<String, dynamic> getStats() {
    return {
      'initialized': _isInitialized,
      'connectionCount': _connections.length,
      'connectedCount': _connections.values
          .where((conn) => getServerStatus(conn.config.id) == McpServerStatus.connected)
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
      case McpServerType.http:
        return _HttpConnection(config, _logger);
      case McpServerType.sse:
        return _SseConnection(config, _logger);
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
  Future<Map<String, dynamic>> callTool(String toolName, Map<String, dynamic> arguments);

  /// 断开连接
  Future<void> disconnect();
}

/// STDIO连接实现（桌面平台）
class _StdioConnection extends _McpConnection {
  Process? _process;

  _StdioConnection(super.config, super.logger);

  @override
  Future<List<McpTool>> listTools() async {
    // TODO: 实现STDIO工具列表获取
    return [];
  }

  @override
  Future<Map<String, dynamic>> callTool(String toolName, Map<String, dynamic> arguments) async {
    // TODO: 实现STDIO工具调用
    return {'result': 'STDIO tool call not implemented yet'};
  }

  @override
  Future<void> disconnect() async {
    _process?.kill();
    _process = null;
  }
}

/// HTTP连接实现
class _HttpConnection extends _McpConnection {
  final http.Client _client = http.Client();

  _HttpConnection(super.config, super.logger);

  @override
  Future<List<McpTool>> listTools() async {
    // TODO: 实现HTTP工具列表获取
    return [];
  }

  @override
  Future<Map<String, dynamic>> callTool(String toolName, Map<String, dynamic> arguments) async {
    // TODO: 实现HTTP工具调用
    return {'result': 'HTTP tool call not implemented yet'};
  }

  @override
  Future<void> disconnect() async {
    _client.close();
  }
}

/// SSE连接实现
class _SseConnection extends _McpConnection {
  StreamSubscription? _subscription;

  _SseConnection(super.config, super.logger);

  @override
  Future<List<McpTool>> listTools() async {
    // TODO: 实现SSE工具列表获取
    return [];
  }

  @override
  Future<Map<String, dynamic>> callTool(String toolName, Map<String, dynamic> arguments) async {
    // TODO: 实现SSE工具调用
    return {'result': 'SSE tool call not implemented yet'};
  }

  @override
  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
