import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/mcp_server_state.dart';

/// MCP服务器状态Provider
/// 
/// 统一管理MCP服务器的所有状态信息，包括连接状态、工具列表、错误信息等。
/// 这是一个聚合Provider，将分散的MCP服务器状态统一管理。
/// 
/// 支持family参数，可以为不同的服务器创建独立的状态管理。
final mcpServerStateProvider = Provider.family<McpServerState, String>((ref, serverId) {
  // 这里应该从实际的MCP服务管理器获取状态
  // 目前返回模拟数据
  return _createMockServerState(serverId);
});

/// 创建模拟的服务器状态（用于演示）
McpServerState _createMockServerState(String serverId) {
  return McpServerState(
    serverId: serverId,
    serverName: 'MCP Server $serverId',
    status: McpConnectionStatus.connected,
    lastUpdated: DateTime.now(),
    tools: _createMockTools(),
    errors: [],
    warnings: [],
    capabilities: const McpServerCapabilities(
      supportsTools: true,
      supportsResources: true,
      supportsPrompts: false,
      supportedProtocols: ['mcp/1.0'],
    ),
    metrics: McpServerMetrics(
      averageResponseTime: 800.0,
      lastResponseTime: 650.0,
      totalRequests: 25,
      successfulRequests: 23,
      failedRequests: 2,
      lastMeasurement: DateTime.now(),
      activeConnections: 1,
    ),
  );
}

/// 创建模拟的工具列表
List<McpTool> _createMockTools() {
  return [
    const McpTool(
      name: 'file_reader',
      description: '读取文件内容',
      schema: {'type': 'object', 'properties': {'path': {'type': 'string'}}},
      tags: ['file', 'io'],
      usageCount: 15,
    ),
    const McpTool(
      name: 'web_search',
      description: '网络搜索工具',
      schema: {'type': 'object', 'properties': {'query': {'type': 'string'}}},
      tags: ['search', 'web'],
      usageCount: 8,
    ),
    const McpTool(
      name: 'calculator',
      description: '数学计算器',
      schema: {'type': 'object', 'properties': {'expression': {'type': 'string'}}},
      tags: ['math', 'calculation'],
      usageCount: 3,
    ),
  ];
}

// ============================================================================
// 向后兼容的访问器Provider
// ============================================================================

/// MCP服务器状态Provider（向后兼容）
final mcpServerStatusProvider = Provider.family<McpConnectionStatus, String>((ref, serverId) => 
  ref.watch(mcpServerStateProvider(serverId)).status);

/// MCP服务器错误Provider（向后兼容）
final mcpServerErrorProvider = Provider.family<String?, String>((ref, serverId) => 
  ref.watch(mcpServerStateProvider(serverId)).primaryError);

/// MCP服务器工具Provider（向后兼容）
final mcpServerToolsProvider = Provider.family<List<McpTool>, String>((ref, serverId) => 
  ref.watch(mcpServerStateProvider(serverId)).tools);

// ============================================================================
// 新增的便捷访问Provider
// ============================================================================

/// MCP服务器连接状态Provider（新增）
final mcpServerConnectionProvider = Provider.family<bool, String>((ref, serverId) => 
  ref.watch(mcpServerStateProvider(serverId)).isConnected);

/// MCP服务器可用性Provider（新增）
final mcpServerUsabilityProvider = Provider.family<bool, String>((ref, serverId) => 
  ref.watch(mcpServerStateProvider(serverId)).isUsable);

/// MCP服务器健康状态Provider（新增）
final mcpServerHealthProvider = Provider.family<HealthStatus, String>((ref, serverId) => 
  ref.watch(mcpServerStateProvider(serverId)).healthStatus);

/// MCP服务器需要注意Provider（新增）
final mcpServerNeedsAttentionProvider = Provider.family<bool, String>((ref, serverId) => 
  ref.watch(mcpServerStateProvider(serverId)).needsAttention);

/// MCP服务器工具数量Provider（新增）
final mcpServerToolCountProvider = Provider.family<int, String>((ref, serverId) => 
  ref.watch(mcpServerStateProvider(serverId)).toolCount);

/// MCP服务器错误列表Provider（新增）
final mcpServerErrorsProvider = Provider.family<List<McpError>, String>((ref, serverId) => 
  ref.watch(mcpServerStateProvider(serverId)).errors);

/// MCP服务器警告Provider（新增）
final mcpServerWarningsProvider = Provider.family<List<String>, String>((ref, serverId) => 
  ref.watch(mcpServerStateProvider(serverId)).warnings);

/// MCP服务器能力Provider（新增）
final mcpServerCapabilitiesProvider = Provider.family<McpServerCapabilities?, String>((ref, serverId) => 
  ref.watch(mcpServerStateProvider(serverId)).capabilities);

/// MCP服务器性能指标Provider（新增）
final mcpServerMetricsProvider = Provider.family<McpServerMetrics?, String>((ref, serverId) => 
  ref.watch(mcpServerStateProvider(serverId)).metrics);

/// MCP服务器重连能力Provider（新增）
final mcpServerCanReconnectProvider = Provider.family<bool, String>((ref, serverId) => 
  ref.watch(mcpServerStateProvider(serverId)).canReconnect);

// ============================================================================
// 聚合Provider - 管理多个服务器
// ============================================================================

/// 所有MCP服务器列表Provider
/// 
/// 这个Provider应该从实际的MCP管理器获取服务器列表
/// 目前返回模拟数据
final allMcpServersProvider = Provider<List<String>>((ref) {
  // 模拟的服务器ID列表
  return ['server1', 'server2', 'server3'];
});

/// 所有MCP服务器状态Provider
final allMcpServerStatesProvider = Provider<List<McpServerState>>((ref) {
  final serverIds = ref.watch(allMcpServersProvider);
  return serverIds.map((id) => ref.watch(mcpServerStateProvider(id))).toList();
});

/// 已连接的MCP服务器Provider
final connectedMcpServersProvider = Provider<List<McpServerState>>((ref) {
  final allStates = ref.watch(allMcpServerStatesProvider);
  return allStates.where((state) => state.isConnected).toList();
});

/// 有错误的MCP服务器Provider
final errorMcpServersProvider = Provider<List<McpServerState>>((ref) {
  final allStates = ref.watch(allMcpServerStatesProvider);
  return allStates.where((state) => state.hasErrors).toList();
});

/// MCP服务器总体健康状态Provider
final mcpOverallHealthProvider = Provider<HealthStatus>((ref) {
  final allStates = ref.watch(allMcpServerStatesProvider);
  
  if (allStates.isEmpty) return HealthStatus.warning;
  
  // 如果有任何服务器处于严重状态，整体状态为严重
  if (allStates.any((state) => state.healthStatus == HealthStatus.critical)) {
    return HealthStatus.critical;
  }
  
  // 如果有任何服务器有警告，整体状态为警告
  if (allStates.any((state) => state.healthStatus == HealthStatus.warning)) {
    return HealthStatus.warning;
  }
  
  // 如果有任何服务器需要注意，整体状态为注意
  if (allStates.any((state) => state.healthStatus == HealthStatus.caution)) {
    return HealthStatus.caution;
  }
  
  // 所有服务器都健康
  return HealthStatus.healthy;
});

/// 可用工具总数Provider
final totalAvailableToolsProvider = Provider<int>((ref) {
  final connectedServers = ref.watch(connectedMcpServersProvider);
  return connectedServers.fold(0, (total, server) => total + server.toolCount);
});

/// MCP服务器摘要Provider
final mcpServersSummaryProvider = Provider<String>((ref) {
  final allStates = ref.watch(allMcpServerStatesProvider);
  final connectedCount = allStates.where((state) => state.isConnected).length;
  final totalTools = ref.watch(totalAvailableToolsProvider);
  
  return '服务器: $connectedCount/${allStates.length} 已连接, 工具: $totalTools 个可用';
});
