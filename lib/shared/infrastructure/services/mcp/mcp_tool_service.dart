import 'dart:async';
import '../../../../features/settings/domain/entities/mcp_server_config.dart';
import '../logger_service.dart';
import 'mcp_client_service.dart';

/// MCP 工具服务
///
/// 负责管理和调用MCP工具，提供：
/// - 🛠️ **工具管理**: 统一管理所有MCP服务器提供的工具
/// - 🔍 **工具发现**: 自动发现和同步服务器工具
/// - 📋 **工具筛选**: 根据助手配置筛选可用工具
/// - ⚡ **工具调用**: 统一的工具调用接口
/// - 📊 **调用统计**: 工具调用次数和性能统计
/// - 🔄 **缓存管理**: 工具列表缓存和更新策略
///
/// ## 工具管理策略
/// - 自动发现服务器提供的工具
/// - 根据助手配置筛选可用工具
/// - 缓存工具列表以提升性能
/// - 支持工具的启用/禁用控制
class McpToolService {
  final LoggerService _logger = LoggerService();
  
  // 工具缓存
  final Map<String, List<McpTool>> _serverTools = {};
  final Map<String, DateTime> _toolCacheTime = {};
  
  // 调用统计
  final Map<String, int> _toolCallCounts = {};
  final Map<String, Duration> _toolCallDurations = {};
  
  bool _isInitialized = false;
  
  // 缓存有效期（5分钟）
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 初始化工具服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    _logger.info('🛠️ 初始化MCP工具服务');
    _isInitialized = true;
    _logger.info('✅ MCP工具服务初始化完成');
  }

  /// 获取可用的工具列表
  ///
  /// @param assistantMcpServerIds 助手配置的MCP服务器ID列表，如果为null则返回所有工具
  /// @returns 可用的工具列表
  Future<List<McpTool>> getAvailableTools([List<String>? assistantMcpServerIds]) async {
    if (!_isInitialized) {
      throw StateError('MCP工具服务未初始化');
    }

    final allTools = <McpTool>[];
    
    // 如果指定了助手的MCP服务器ID列表，只返回这些服务器的工具
    if (assistantMcpServerIds != null) {
      for (final serverId in assistantMcpServerIds) {
        final tools = await _getServerTools(serverId);
        allTools.addAll(tools.where((tool) => tool.isEnabled));
      }
    } else {
      // 返回所有服务器的工具
      for (final serverId in _serverTools.keys) {
        final tools = await _getServerTools(serverId);
        allTools.addAll(tools.where((tool) => tool.isEnabled));
      }
    }

    // 去重（按工具名称）
    final uniqueTools = <String, McpTool>{};
    for (final tool in allTools) {
      uniqueTools[tool.name] = tool;
    }

    _logger.info('获取可用工具', {
      'totalTools': uniqueTools.length,
      'assistantServerIds': assistantMcpServerIds,
    });

    return uniqueTools.values.toList();
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
    if (!_isInitialized) {
      throw StateError('MCP工具服务未初始化');
    }

    final startTime = DateTime.now();
    
    _logger.info('调用MCP工具', {
      'toolName': toolName,
      'arguments': arguments,
    });

    try {
      // 查找工具所在的服务器
      final serverId = await _findToolServer(toolName);
      if (serverId == null) {
        throw StateError('未找到工具: $toolName');
      }

      // 通过客户端服务调用工具
      final clientService = McpClientService();
      final result = await clientService.callTool(serverId, toolName, arguments);

      // 记录调用统计
      final duration = DateTime.now().difference(startTime);
      _recordToolCall(toolName, duration);

      _logger.info('MCP工具调用成功', {
        'toolName': toolName,
        'duration': duration.inMilliseconds,
      });

      return result;
    } catch (e) {
      _logger.error('MCP工具调用失败', {
        'toolName': toolName,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// 刷新服务器工具列表
  ///
  /// @param serverId 服务器ID
  Future<void> refreshServerTools(String serverId) async {
    _logger.info('刷新服务器工具列表', {'serverId': serverId});
    
    // 清除缓存
    _serverTools.remove(serverId);
    _toolCacheTime.remove(serverId);
    
    // 重新获取工具列表
    await _getServerTools(serverId);
  }

  /// 更新服务器工具配置
  ///
  /// @param serverId 服务器ID
  /// @param tools 工具列表
  Future<void> updateServerTools(String serverId, List<McpTool> tools) async {
    _logger.info('更新服务器工具配置', {
      'serverId': serverId,
      'toolCount': tools.length,
    });
    
    _serverTools[serverId] = tools;
    _toolCacheTime[serverId] = DateTime.now();
  }

  /// 获取工具调用统计
  Map<String, dynamic> getToolCallStats() {
    return {
      'callCounts': Map.from(_toolCallCounts),
      'averageDurations': _toolCallDurations.map(
        (tool, duration) => MapEntry(tool, duration.inMilliseconds),
      ),
      'totalCalls': _toolCallCounts.values.fold(0, (sum, count) => sum + count),
    };
  }

  /// 清除工具调用统计
  void clearToolCallStats() {
    _toolCallCounts.clear();
    _toolCallDurations.clear();
    _logger.info('已清除工具调用统计');
  }

  /// 获取服务统计信息
  Map<String, dynamic> getStats() {
    return {
      'initialized': _isInitialized,
      'cachedServerCount': _serverTools.length,
      'totalToolCount': _serverTools.values
          .expand((tools) => tools)
          .length,
      'enabledToolCount': _serverTools.values
          .expand((tools) => tools)
          .where((tool) => tool.isEnabled)
          .length,
      'callStats': getToolCallStats(),
    };
  }

  /// 检查服务健康状态
  Future<bool> checkHealth() async {
    return _isInitialized;
  }

  /// 清理服务资源
  Future<void> dispose() async {
    _logger.info('清理MCP工具服务资源');
    
    _serverTools.clear();
    _toolCacheTime.clear();
    _toolCallCounts.clear();
    _toolCallDurations.clear();
    _isInitialized = false;
    
    _logger.info('MCP工具服务资源清理完成');
  }

  /// 获取服务器工具列表（带缓存）
  Future<List<McpTool>> _getServerTools(String serverId) async {
    // 检查缓存是否有效
    final cacheTime = _toolCacheTime[serverId];
    final now = DateTime.now();
    
    if (cacheTime != null && 
        now.difference(cacheTime) < _cacheValidDuration &&
        _serverTools.containsKey(serverId)) {
      return _serverTools[serverId]!;
    }

    // 缓存无效，重新获取
    try {
      final clientService = McpClientService();
      final tools = await clientService.callTool(serverId, 'list_tools', {});
      
      // 解析工具列表
      final toolList = <McpTool>[];
      if (tools['tools'] is List) {
        for (final toolData in tools['tools']) {
          if (toolData is Map<String, dynamic>) {
            toolList.add(McpTool.fromJson(toolData));
          }
        }
      }
      
      // 更新缓存
      _serverTools[serverId] = toolList;
      _toolCacheTime[serverId] = now;
      
      return toolList;
    } catch (e) {
      _logger.warning('获取服务器工具列表失败', {
        'serverId': serverId,
        'error': e.toString(),
      });
      
      // 返回缓存的工具列表（如果有）
      return _serverTools[serverId] ?? [];
    }
  }

  /// 查找工具所在的服务器
  Future<String?> _findToolServer(String toolName) async {
    for (final serverId in _serverTools.keys) {
      final tools = await _getServerTools(serverId);
      if (tools.any((tool) => tool.name == toolName && tool.isEnabled)) {
        return serverId;
      }
    }
    return null;
  }

  /// 记录工具调用统计
  void _recordToolCall(String toolName, Duration duration) {
    // 更新调用次数
    _toolCallCounts[toolName] = (_toolCallCounts[toolName] ?? 0) + 1;
    
    // 更新平均耗时
    final currentDuration = _toolCallDurations[toolName] ?? Duration.zero;
    final callCount = _toolCallCounts[toolName]!;
    final totalMs = currentDuration.inMilliseconds * (callCount - 1) + duration.inMilliseconds;
    _toolCallDurations[toolName] = Duration(milliseconds: totalMs ~/ callCount);
  }
}
