import 'package:freezed_annotation/freezed_annotation.dart';

part 'mcp_server_state.freezed.dart';

/// MCP服务器状态聚合模型
///
/// 统一管理MCP服务器的所有相关状态信息，包括：
/// - 连接状态和错误信息
/// - 工具列表和能力信息
/// - 性能指标和时间戳
/// - 配置信息和元数据
@freezed
class McpServerState with _$McpServerState {
  const factory McpServerState({
    required String serverId,
    required String serverName,
    required McpConnectionStatus status,
    required DateTime lastUpdated,
    required List<McpTool> tools,
    required List<McpError> errors,
    @Default([]) List<String> warnings,
    @Default(false) bool isConnecting,
    @Default(false) bool isReconnecting,
    @Default(0) int reconnectAttempts,
    @Default(5) int maxReconnectAttempts,
    McpServerCapabilities? capabilities,
    McpServerMetrics? metrics,
    Map<String, dynamic>? configuration,
  }) = _McpServerState;

  const McpServerState._();

  /// 是否已连接
  bool get isConnected => status == McpConnectionStatus.connected;

  /// 是否断开连接
  bool get isDisconnected => status == McpConnectionStatus.disconnected;

  /// 是否有错误
  bool get hasErrors => errors.isNotEmpty;

  /// 是否有警告
  bool get hasWarnings => warnings.isNotEmpty;

  /// 是否可以使用
  bool get isUsable => isConnected && !hasErrors && tools.isNotEmpty;

  /// 获取主要错误信息
  String? get primaryError => errors.isNotEmpty ? errors.first.message : null;

  /// 获取错误数量
  int get errorCount => errors.length;

  /// 获取警告数量
  int get warningCount => warnings.length;

  /// 获取工具数量
  int get toolCount => tools.length;

  /// 是否需要用户注意
  bool get needsAttention => hasErrors || hasWarnings || isDisconnected;

  /// 获取状态描述
  String get statusDescription {
    switch (status) {
      case McpConnectionStatus.disconnected:
        return '未连接';
      case McpConnectionStatus.connecting:
        return '连接中';
      case McpConnectionStatus.connected:
        return '已连接';
      case McpConnectionStatus.error:
        return '连接错误';
      case McpConnectionStatus.reconnecting:
        return '重连中';
    }
  }

  /// 获取健康状态
  HealthStatus get healthStatus {
    if (status == McpConnectionStatus.error) return HealthStatus.critical;
    if (hasErrors) return HealthStatus.warning;
    if (hasWarnings) return HealthStatus.caution;
    if (isConnected) return HealthStatus.healthy;
    return HealthStatus.warning;
  }

  /// 是否可以重连
  bool get canReconnect =>
      (status == McpConnectionStatus.disconnected ||
          status == McpConnectionStatus.error) &&
      reconnectAttempts < maxReconnectAttempts;

  /// 获取工具摘要
  String get toolsSummary => '可用工具: $toolCount 个';

  /// 是否处于活跃状态
  bool get isActive => isConnecting || isReconnecting || isConnected;
}

/// MCP连接状态
enum McpConnectionStatus {
  disconnected, // 未连接
  connecting, // 连接中
  connected, // 已连接
  error, // 连接错误
  reconnecting, // 重连中
}

/// MCP工具模型
@freezed
class McpTool with _$McpTool {
  const factory McpTool({
    required String name,
    required String description,
    required Map<String, dynamic> schema,
    @Default([]) List<String> tags,
    @Default(true) bool isEnabled,
    DateTime? lastUsed,
    int? usageCount,
  }) = _McpTool;

  const McpTool._();

  /// 是否最近使用过
  bool get isRecentlyUsed {
    if (lastUsed == null) return false;
    return DateTime.now().difference(lastUsed!).inDays < 7;
  }

  /// 使用频率等级
  UsageLevel get usageLevel {
    if (usageCount == null || usageCount! == 0) return UsageLevel.unused;
    if (usageCount! < 5) return UsageLevel.low;
    if (usageCount! < 20) return UsageLevel.medium;
    return UsageLevel.high;
  }
}

/// 使用频率等级
enum UsageLevel {
  unused, // 未使用
  low, // 低频
  medium, // 中频
  high, // 高频
}

/// MCP错误模型
@freezed
class McpError with _$McpError {
  const factory McpError({
    required String id,
    required String message,
    required McpErrorType type,
    required DateTime timestamp,
    String? code,
    String? serverId,
    String? toolName,
    Map<String, dynamic>? details,
  }) = _McpError;

  const McpError._();

  /// 是否为严重错误
  bool get isCritical =>
      type == McpErrorType.connection || type == McpErrorType.authentication;

  /// 获取错误级别
  ErrorLevel get level {
    switch (type) {
      case McpErrorType.connection:
        return ErrorLevel.critical;
      case McpErrorType.authentication:
        return ErrorLevel.high;
      case McpErrorType.toolExecution:
        return ErrorLevel.medium;
      case McpErrorType.configuration:
        return ErrorLevel.low;
      case McpErrorType.timeout:
        return ErrorLevel.medium;
      case McpErrorType.unknown:
        return ErrorLevel.low;
    }
  }

  /// 是否可以重试
  bool get canRetry {
    switch (type) {
      case McpErrorType.connection:
      case McpErrorType.timeout:
      case McpErrorType.toolExecution:
        return true;
      case McpErrorType.authentication:
      case McpErrorType.configuration:
      case McpErrorType.unknown:
        return false;
    }
  }
}

/// MCP错误类型
enum McpErrorType {
  connection, // 连接错误
  authentication, // 认证错误
  toolExecution, // 工具执行错误
  configuration, // 配置错误
  timeout, // 超时错误
  unknown, // 未知错误
}

/// 错误级别
enum ErrorLevel {
  critical, // 严重错误
  high, // 高级错误
  medium, // 中级错误
  low, // 低级错误
}

/// 健康状态
enum HealthStatus {
  healthy, // 健康
  caution, // 注意
  warning, // 警告
  critical, // 严重
}

/// MCP服务器能力
@freezed
class McpServerCapabilities with _$McpServerCapabilities {
  const factory McpServerCapabilities({
    required bool supportsTools,
    required bool supportsResources,
    required bool supportsPrompts,
    required List<String> supportedProtocols,
    @Default('1.0') String version,
  }) = _McpServerCapabilities;

  const McpServerCapabilities._();

  /// 获取能力摘要
  String get summary {
    final capabilities = <String>[];
    if (supportsTools) capabilities.add('工具');
    if (supportsResources) capabilities.add('资源');
    if (supportsPrompts) capabilities.add('提示');
    return '支持: ${capabilities.join(', ')}';
  }
}

/// MCP服务器性能指标
@freezed
class McpServerMetrics with _$McpServerMetrics {
  const factory McpServerMetrics({
    required double averageResponseTime,
    required double lastResponseTime,
    required int totalRequests,
    required int successfulRequests,
    required int failedRequests,
    required DateTime lastMeasurement,
    @Default(0) int activeConnections,
  }) = _McpServerMetrics;

  const McpServerMetrics._();

  /// 成功率
  double get successRate =>
      totalRequests > 0 ? successfulRequests / totalRequests : 0.0;

  /// 失败率
  double get failureRate =>
      totalRequests > 0 ? failedRequests / totalRequests : 0.0;

  /// 性能等级
  PerformanceLevel get performanceLevel {
    if (averageResponseTime < 500) return PerformanceLevel.excellent;
    if (averageResponseTime < 1000) return PerformanceLevel.good;
    if (averageResponseTime < 2000) return PerformanceLevel.fair;
    return PerformanceLevel.poor;
  }
}

/// 性能等级
enum PerformanceLevel {
  excellent, // 优秀
  good, // 良好
  fair, // 一般
  poor, // 较差
}
