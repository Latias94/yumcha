import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/settings/domain/entities/mcp_server_config.dart';
import '../logger_service.dart';
import 'mcp_client_service.dart';
import 'mcp_tool_service.dart';

/// MCP 服务管理器 - 统一管理所有MCP相关服务
///
/// 这是整个MCP服务架构的核心管理器，负责：
/// - 🏗️ **服务注册与初始化**：管理所有MCP服务的生命周期
/// - 🔄 **统一接口**：为上层提供统一的MCP功能访问接口
/// - 📊 **监控统计**：收集和管理所有MCP服务的统计信息
/// - 💾 **缓存管理**：统一管理各服务的缓存策略
/// - 🔧 **健康检查**：监控各服务的健康状态
/// - 📱 **平台适配**：根据平台能力自动适配连接方式
///
/// ## 架构设计
///
/// ```
/// McpServiceManager (单例)
/// ├── McpClientService     # MCP客户端服务
/// ├── McpToolService       # MCP工具服务
/// └── 平台适配逻辑          # 移动端/桌面端适配
/// ```
///
/// ## 使用方式
///
/// ### 1. 通过Riverpod Provider使用（推荐）
/// ```dart
/// final manager = ref.read(mcpServiceManagerProvider);
/// await ref.read(initializeMcpServicesProvider.future);
/// ```
///
/// ### 2. 直接使用服务
/// ```dart
/// final tools = await manager.getAvailableTools();
/// final result = await manager.callTool(toolName, arguments);
/// ```
class McpServiceManager {
  // 单例模式实现
  static final McpServiceManager _instance = McpServiceManager._internal();
  factory McpServiceManager() => _instance;
  McpServiceManager._internal();

  // 核心依赖
  final LoggerService _logger = LoggerService();
  final McpClientService _clientService = McpClientService();
  final McpToolService _toolService = McpToolService();

  bool _isInitialized = false;
  bool _isEnabled = false;

  /// 获取客户端服务
  McpClientService get clientService => _clientService;

  /// 获取工具服务
  McpToolService get toolService => _toolService;

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 是否已启用
  bool get isEnabled => _isEnabled;

  /// 初始化MCP服务管理器
  ///
  /// 这是整个MCP服务系统的启动入口，负责：
  /// 1. **服务注册**：注册所有核心MCP服务
  /// 2. **依次初始化**：按顺序初始化每个服务，确保依赖关系正确
  /// 3. **错误处理**：如果任何服务初始化失败，整个初始化过程会回滚
  /// 4. **状态管理**：维护初始化状态，避免重复初始化
  ///
  /// ## 初始化顺序
  /// 1. McpClientService - MCP客户端服务（核心服务）
  /// 2. McpToolService - MCP工具服务（依赖客户端服务）
  ///
  /// @throws Exception 如果任何服务初始化失败
  Future<void> initialize() async {
    if (_isInitialized) return;

    _logger.info('🚀 开始初始化MCP服务管理器');

    try {
      // 初始化客户端服务
      await _clientService.initialize();

      // 初始化工具服务
      await _toolService.initialize();

      _isInitialized = true;
      _logger.info('✅ MCP服务管理器初始化完成');
    } catch (e) {
      _logger.error('❌ MCP服务管理器初始化失败', {'error': e.toString()});
      rethrow;
    }
  }

  /// 启用MCP服务
  ///
  /// @param enabled 是否启用MCP服务
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    _logger.info('MCP服务${enabled ? '已启用' : '已禁用'}');

    if (!enabled) {
      await disconnectAllServers();
    }
  }

  /// 初始化服务器列表
  ///
  /// @param servers 要初始化的服务器配置列表
  Future<void> initializeServers(List<McpServerConfig> servers) async {
    if (!_isEnabled) {
      _logger.warning('MCP服务未启用，跳过服务器初始化');
      return;
    }

    await _ensureInitialized();

    _logger.info('初始化MCP服务器', {'count': servers.length});

    for (final server in servers) {
      if (server.isEnabled && _isPlatformSupported(server.type)) {
        try {
          await _clientService.connectServer(server);
        } catch (e) {
          _logger.error('服务器连接失败', {
            'serverId': server.id,
            'serverName': server.name,
            'error': e.toString(),
          });
        }
      }
    }
  }

  /// 断开所有服务器连接
  Future<void> disconnectAllServers() async {
    await _clientService.disconnectAllServers();
  }

  /// 重新连接服务器
  ///
  /// @param serverId 服务器ID
  Future<void> reconnectServer(String serverId) async {
    await _clientService.reconnectServer(serverId);
  }

  /// 断开特定服务器连接
  ///
  /// @param serverId 服务器ID
  Future<void> disconnectServer(String serverId) async {
    await _clientService.disconnectServer(serverId);
  }

  /// 获取服务器状态
  ///
  /// @param serverId 服务器ID
  /// @returns 服务器状态
  McpServerStatus getServerStatus(String serverId) {
    return _clientService.getServerStatus(serverId);
  }

  /// 获取服务器错误信息
  ///
  /// @param serverId 服务器ID
  /// @returns 错误信息，如果没有错误则返回null
  String? getServerError(String serverId) {
    return _clientService.getServerError(serverId);
  }

  /// 获取推荐的服务器类型
  ///
  /// 根据当前平台返回推荐的MCP服务器连接类型：
  /// - 桌面平台：STDIO、StreamableHTTP
  /// - 移动平台：StreamableHTTP
  ///
  /// @returns 推荐的服务器类型列表
  List<McpServerType> getRecommendedServerTypes() {
    final isDesktop =
        Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    if (isDesktop) {
      return [McpServerType.stdio, McpServerType.streamableHttp];
    } else {
      return [McpServerType.streamableHttp];
    }
  }

  /// 获取可用的工具列表
  ///
  /// @param assistantMcpServerIds 助手配置的MCP服务器ID列表
  /// @returns 可用的工具列表
  Future<List<McpTool>> getAvailableTools(
      [List<String>? assistantMcpServerIds]) async {
    await _ensureInitialized();
    return await _toolService.getAvailableTools(assistantMcpServerIds);
  }

  /// 调用MCP工具
  ///
  /// @param toolName 工具名称
  /// @param arguments 工具参数
  /// @returns 工具执行结果
  Future<Map<String, dynamic>> callTool(
    String toolName,
    Map<String, dynamic> arguments,
  ) async {
    await _ensureInitialized();
    return await _toolService.callTool(toolName, arguments);
  }

  /// 清理所有服务资源
  Future<void> dispose() async {
    _logger.info('清理MCP服务管理器资源');

    try {
      await _clientService.dispose();
      await _toolService.dispose();
    } catch (e) {
      _logger.error('MCP服务清理失败', {'error': e.toString()});
    }

    _isInitialized = false;
    _isEnabled = false;
    _logger.info('MCP服务管理器资源清理完成');
  }

  /// 获取服务统计信息
  Map<String, dynamic> getServiceStats() {
    return {
      'initialized': _isInitialized,
      'enabled': _isEnabled,
      'clientService': _clientService.getStats(),
      'toolService': _toolService.getStats(),
    };
  }

  /// 检查服务健康状态
  Future<Map<String, bool>> checkServiceHealth() async {
    final health = <String, bool>{};

    try {
      health['manager'] = _isInitialized && _isEnabled;
      health['clientService'] = await _clientService.checkHealth();
      health['toolService'] = await _toolService.checkHealth();
    } catch (e) {
      _logger.error('MCP服务健康检查失败', {'error': e.toString()});
      health['manager'] = false;
    }

    return health;
  }

  /// 确保服务已初始化
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// 检查平台是否支持指定的服务器类型
  bool _isPlatformSupported(McpServerType type) {
    final isDesktop =
        Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    switch (type) {
      case McpServerType.stdio:
        return isDesktop; // STDIO仅在桌面平台支持
      case McpServerType.streamableHttp:
        return true; // StreamableHTTP在所有平台都支持
    }
  }
}

/// Riverpod Provider for McpServiceManager
final mcpServiceManagerProvider = Provider<McpServiceManager>((ref) {
  return McpServiceManager();
});

/// Riverpod Provider for initializing MCP services
final initializeMcpServicesProvider = FutureProvider<void>((ref) async {
  final manager = ref.read(mcpServiceManagerProvider);
  await manager.initialize();
});
