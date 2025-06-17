import 'package:flutter_riverpod/flutter_riverpod.dart';

// 导出MCP服务器状态Provider
export 'mcp_server_state_provider.dart';

/// MCP功能相关的Provider导出文件
///
/// 这个文件统一导出所有MCP相关的Provider，
/// 包括服务器状态管理、工具管理等功能。
///
/// 使用方式：
/// ```dart
/// import 'package:yumcha/features/mcp/presentation/providers/mcp_providers.dart';
///
/// // 使用MCP服务器状态Provider
/// final serverState = ref.watch(mcpServerStateProvider('server_id'));
///
/// // 使用聚合Provider
/// final allServers = ref.watch(allMcpServerStatesProvider);
/// final overallHealth = ref.watch(mcpOverallHealthProvider);
/// ```
///
/// 主要Provider包括：
/// - mcpServerStateProvider: 单个服务器状态管理
/// - allMcpServerStatesProvider: 所有服务器状态聚合
/// - mcpOverallHealthProvider: 整体健康状态
/// - connectedMcpServersProvider: 已连接服务器列表
/// - totalAvailableToolsProvider: 可用工具总数
///
/// 向后兼容Provider：
/// - mcpServerStatusProvider: 服务器连接状态
/// - mcpServerErrorProvider: 服务器错误信息
/// - mcpServerToolsProvider: 服务器工具列表
