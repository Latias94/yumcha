import 'package:llm_dart/llm_dart.dart';

/// 统一的AI响应结果
class AiResponse {
  final String content;
  final String? thinking;
  final UsageInfo? usage;
  final Duration? duration;
  final String? error;
  final List<ToolCall>? toolCalls;
  final bool wasCancelled;

  const AiResponse({
    required this.content,
    this.thinking,
    this.usage,
    this.duration,
    this.error,
    this.toolCalls,
    this.wasCancelled = false,
  });

  bool get isSuccess => error == null && !wasCancelled;
  bool get hasThinking => thinking?.isNotEmpty == true;
  bool get hasToolCalls => toolCalls?.isNotEmpty == true;
  bool get hasUsage => usage != null;

  /// 创建成功响应
  factory AiResponse.success({
    required String content,
    String? thinking,
    UsageInfo? usage,
    Duration? duration,
    List<ToolCall>? toolCalls,
  }) {
    return AiResponse(
      content: content,
      thinking: thinking,
      usage: usage,
      duration: duration,
      toolCalls: toolCalls,
    );
  }

  /// 创建错误响应
  factory AiResponse.error({required String error, Duration? duration}) {
    return AiResponse(content: '', error: error, duration: duration);
  }

  /// 创建取消响应
  factory AiResponse.cancelled({String content = '', Duration? duration}) {
    return AiResponse(content: content, duration: duration, wasCancelled: true);
  }

  @override
  String toString() {
    if (error != null) return 'AiResponse.error($error)';
    if (wasCancelled) return 'AiResponse.cancelled';
    return 'AiResponse.success(${content.length} chars)';
  }
}

/// 统一的AI流式响应事件
class AiStreamEvent {
  final String? contentDelta;
  final String? thinkingDelta;
  final String? finalThinking;
  final bool isDone;
  final String? error;
  final UsageInfo? usage;
  final Duration? duration;
  final ToolCall? toolCall;
  final List<ToolCall>? allToolCalls;
  final bool wasCancelled;

  const AiStreamEvent({
    this.contentDelta,
    this.thinkingDelta,
    this.finalThinking,
    this.isDone = false,
    this.error,
    this.usage,
    this.duration,
    this.toolCall,
    this.allToolCalls,
    this.wasCancelled = false,
  });

  bool get isContent => contentDelta != null && !isDone;
  bool get isThinking => thinkingDelta != null;
  bool get isError => error != null;
  bool get isSuccess => error == null && !wasCancelled;
  bool get isToolCall => toolCall != null;
  bool get isCompleted => isDone && !wasCancelled;

  /// 创建内容增量事件
  factory AiStreamEvent.contentDelta(String delta) {
    return AiStreamEvent(contentDelta: delta);
  }

  /// 创建思考增量事件
  factory AiStreamEvent.thinkingDelta(String delta) {
    return AiStreamEvent(thinkingDelta: delta);
  }

  /// 创建工具调用事件
  factory AiStreamEvent.toolCall(ToolCall toolCall) {
    return AiStreamEvent(toolCall: toolCall);
  }

  /// 创建完成事件
  factory AiStreamEvent.completed({
    String? finalThinking,
    UsageInfo? usage,
    Duration? duration,
    List<ToolCall>? allToolCalls,
  }) {
    return AiStreamEvent(
      isDone: true,
      finalThinking: finalThinking,
      usage: usage,
      duration: duration,
      allToolCalls: allToolCalls,
    );
  }

  /// 创建错误事件
  factory AiStreamEvent.error(String error) {
    return AiStreamEvent(error: error);
  }

  /// 创建取消事件
  factory AiStreamEvent.cancelled() {
    return const AiStreamEvent(wasCancelled: true);
  }

  @override
  String toString() {
    if (error != null) return 'AiStreamEvent.error($error)';
    if (wasCancelled) return 'AiStreamEvent.cancelled';
    if (isDone) return 'AiStreamEvent.completed';
    if (isContent) {
      return 'AiStreamEvent.content(${contentDelta?.length} chars)';
    }
    if (isThinking) {
      return 'AiStreamEvent.thinking(${thinkingDelta?.length} chars)';
    }
    if (isToolCall) return 'AiStreamEvent.toolCall(${toolCall?.function.name})';
    return 'AiStreamEvent.unknown';
  }
}

/// AI能力检测结果
class AiCapabilityInfo {
  final String providerId;
  final String modelName;
  final Set<String> capabilities;
  final Map<String, dynamic> metadata;

  const AiCapabilityInfo({
    required this.providerId,
    required this.modelName,
    required this.capabilities,
    this.metadata = const {},
  });

  bool hasCapability(String capability) {
    return capabilities.contains(capability);
  }

  @override
  String toString() {
    return 'AiCapabilityInfo($providerId/$modelName: ${capabilities.join(', ')})';
  }
}

/// AI服务配置
class AiServiceConfig {
  final String providerId;
  final String modelName;
  final bool enableStreaming;
  final bool enableThinking;
  final bool enableToolCalls;
  final Duration timeout;

  const AiServiceConfig({
    required this.providerId,
    required this.modelName,
    this.enableStreaming = true,
    this.enableThinking = true,
    this.enableToolCalls = false,
    this.timeout = const Duration(minutes: 5),
  });

  @override
  String toString() {
    return 'AiServiceConfig($providerId/$modelName)';
  }
}

/// AI请求上下文
class AiRequestContext {
  final String requestId;
  final DateTime startTime;
  final AiServiceConfig config;
  final Map<String, dynamic> metadata;

  AiRequestContext({
    required this.requestId,
    required this.config,
    DateTime? startTime,
    this.metadata = const {},
  }) : startTime = startTime ?? DateTime.now();

  Duration get elapsed => DateTime.now().difference(startTime);

  @override
  String toString() {
    return 'AiRequestContext($requestId, ${elapsed.inMilliseconds}ms)';
  }
}

/// AI服务统计信息
class AiServiceStats {
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final int cancelledRequests;
  final Duration totalDuration;
  final DateTime lastRequestTime;

  AiServiceStats({
    this.totalRequests = 0,
    this.successfulRequests = 0,
    this.failedRequests = 0,
    this.cancelledRequests = 0,
    this.totalDuration = Duration.zero,
    DateTime? lastRequestTime,
  }) : lastRequestTime =
           lastRequestTime ?? DateTime.fromMicrosecondsSinceEpoch(0);

  double get successRate {
    if (totalRequests == 0) return 0.0;
    return successfulRequests / totalRequests;
  }

  Duration get averageDuration {
    if (successfulRequests == 0) return Duration.zero;
    return Duration(
      microseconds: totalDuration.inMicroseconds ~/ successfulRequests,
    );
  }

  AiServiceStats copyWith({
    int? totalRequests,
    int? successfulRequests,
    int? failedRequests,
    int? cancelledRequests,
    Duration? totalDuration,
    DateTime? lastRequestTime,
  }) {
    return AiServiceStats(
      totalRequests: totalRequests ?? this.totalRequests,
      successfulRequests: successfulRequests ?? this.successfulRequests,
      failedRequests: failedRequests ?? this.failedRequests,
      cancelledRequests: cancelledRequests ?? this.cancelledRequests,
      totalDuration: totalDuration ?? this.totalDuration,
      lastRequestTime: lastRequestTime ?? this.lastRequestTime,
    );
  }

  @override
  String toString() {
    return 'AiServiceStats(total: $totalRequests, success: $successfulRequests, '
        'rate: ${(successRate * 100).toStringAsFixed(1)}%)';
  }
}
