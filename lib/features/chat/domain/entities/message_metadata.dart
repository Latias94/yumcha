import 'dart:convert';
import 'package:flutter/foundation.dart';

/// AI消息元数据
///
/// 存储AI响应的详细信息，包括耗时、token使用、模型信息等
@immutable
class MessageMetadata {
  /// 总响应耗时（毫秒）
  final int? totalDurationMs;

  /// 思考过程耗时（毫秒）
  final int? thinkingDurationMs;

  /// 内容生成耗时（毫秒）
  final int? contentDurationMs;

  /// Token使用信息
  final TokenUsage? tokenUsage;

  /// 使用的AI模型
  final String? modelName;

  /// 使用的AI提供商
  final String? providerId;

  /// 请求ID（用于调试）
  final String? requestId;

  /// 是否包含思考过程
  final bool hasThinking;

  /// 是否使用了工具调用
  final bool hasToolCalls;

  /// 工具调用信息
  final List<ToolCallInfo>? toolCalls;

  /// 推理强度（如果支持）
  final String? reasoningEffort;

  /// 其他自定义属性
  final Map<String, dynamic>? customProperties;

  const MessageMetadata({
    this.totalDurationMs,
    this.thinkingDurationMs,
    this.contentDurationMs,
    this.tokenUsage,
    this.modelName,
    this.providerId,
    this.requestId,
    this.hasThinking = false,
    this.hasToolCalls = false,
    this.toolCalls,
    this.reasoningEffort,
    this.customProperties,
  });

  /// 从JSON创建
  factory MessageMetadata.fromJson(Map<String, dynamic> json) {
    return MessageMetadata(
      totalDurationMs: json['totalDurationMs'] as int?,
      thinkingDurationMs: json['thinkingDurationMs'] as int?,
      contentDurationMs: json['contentDurationMs'] as int?,
      tokenUsage: json['tokenUsage'] != null
          ? TokenUsage.fromJson(json['tokenUsage'] as Map<String, dynamic>)
          : null,
      modelName: json['modelName'] as String?,
      providerId: json['providerId'] as String?,
      requestId: json['requestId'] as String?,
      hasThinking: json['hasThinking'] as bool? ?? false,
      hasToolCalls: json['hasToolCalls'] as bool? ?? false,
      toolCalls: json['toolCalls'] != null
          ? (json['toolCalls'] as List)
              .map((e) => ToolCallInfo.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      reasoningEffort: json['reasoningEffort'] as String?,
      customProperties: json['customProperties'] as Map<String, dynamic>?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'totalDurationMs': totalDurationMs,
      'thinkingDurationMs': thinkingDurationMs,
      'contentDurationMs': contentDurationMs,
      'tokenUsage': tokenUsage?.toJson(),
      'modelName': modelName,
      'providerId': providerId,
      'requestId': requestId,
      'hasThinking': hasThinking,
      'hasToolCalls': hasToolCalls,
      'toolCalls': toolCalls?.map((e) => e.toJson()).toList(),
      'reasoningEffort': reasoningEffort,
      'customProperties': customProperties,
    };
  }

  /// 从JSON字符串创建
  factory MessageMetadata.fromJsonString(String jsonString) {
    return MessageMetadata.fromJson(
        json.decode(jsonString) as Map<String, dynamic>);
  }

  /// 转换为JSON字符串
  String toJsonString() {
    return json.encode(toJson());
  }

  /// 复制并修改
  MessageMetadata copyWith({
    int? totalDurationMs,
    int? thinkingDurationMs,
    int? contentDurationMs,
    TokenUsage? tokenUsage,
    String? modelName,
    String? providerId,
    String? requestId,
    bool? hasThinking,
    bool? hasToolCalls,
    List<ToolCallInfo>? toolCalls,
    String? reasoningEffort,
    Map<String, dynamic>? customProperties,
  }) {
    return MessageMetadata(
      totalDurationMs: totalDurationMs ?? this.totalDurationMs,
      thinkingDurationMs: thinkingDurationMs ?? this.thinkingDurationMs,
      contentDurationMs: contentDurationMs ?? this.contentDurationMs,
      tokenUsage: tokenUsage ?? this.tokenUsage,
      modelName: modelName ?? this.modelName,
      providerId: providerId ?? this.providerId,
      requestId: requestId ?? this.requestId,
      hasThinking: hasThinking ?? this.hasThinking,
      hasToolCalls: hasToolCalls ?? this.hasToolCalls,
      toolCalls: toolCalls ?? this.toolCalls,
      reasoningEffort: reasoningEffort ?? this.reasoningEffort,
      customProperties: customProperties ?? this.customProperties,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageMetadata &&
        other.totalDurationMs == totalDurationMs &&
        other.thinkingDurationMs == thinkingDurationMs &&
        other.contentDurationMs == contentDurationMs &&
        other.tokenUsage == tokenUsage &&
        other.modelName == modelName &&
        other.providerId == providerId &&
        other.requestId == requestId &&
        other.hasThinking == hasThinking &&
        other.hasToolCalls == hasToolCalls &&
        listEquals(other.toolCalls, toolCalls) &&
        other.reasoningEffort == reasoningEffort &&
        mapEquals(other.customProperties, customProperties);
  }

  @override
  int get hashCode {
    return Object.hash(
      totalDurationMs,
      thinkingDurationMs,
      contentDurationMs,
      tokenUsage,
      modelName,
      providerId,
      requestId,
      hasThinking,
      hasToolCalls,
      toolCalls,
      reasoningEffort,
      customProperties,
    );
  }

  @override
  String toString() {
    return 'MessageMetadata('
        'totalDurationMs: $totalDurationMs, '
        'thinkingDurationMs: $thinkingDurationMs, '
        'contentDurationMs: $contentDurationMs, '
        'modelName: $modelName, '
        'providerId: $providerId, '
        'hasThinking: $hasThinking, '
        'hasToolCalls: $hasToolCalls'
        ')';
  }
}

/// Token使用信息
@immutable
class TokenUsage {
  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;
  final int? reasoningTokens; // 推理token（如OpenAI o1系列）

  const TokenUsage({
    this.promptTokens,
    this.completionTokens,
    this.totalTokens,
    this.reasoningTokens,
  });

  factory TokenUsage.fromJson(Map<String, dynamic> json) {
    return TokenUsage(
      promptTokens: json['promptTokens'] as int?,
      completionTokens: json['completionTokens'] as int?,
      totalTokens: json['totalTokens'] as int?,
      reasoningTokens: json['reasoningTokens'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'promptTokens': promptTokens,
      'completionTokens': completionTokens,
      'totalTokens': totalTokens,
      'reasoningTokens': reasoningTokens,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TokenUsage &&
        other.promptTokens == promptTokens &&
        other.completionTokens == completionTokens &&
        other.totalTokens == totalTokens &&
        other.reasoningTokens == reasoningTokens;
  }

  @override
  int get hashCode {
    return Object.hash(
        promptTokens, completionTokens, totalTokens, reasoningTokens);
  }
}

/// 工具调用信息
@immutable
class ToolCallInfo {
  final String name;
  final Map<String, dynamic> arguments;
  final String? result;
  final int? durationMs;

  const ToolCallInfo({
    required this.name,
    required this.arguments,
    this.result,
    this.durationMs,
  });

  factory ToolCallInfo.fromJson(Map<String, dynamic> json) {
    return ToolCallInfo(
      name: json['name'] as String,
      arguments: json['arguments'] as Map<String, dynamic>,
      result: json['result'] as String?,
      durationMs: json['durationMs'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'arguments': arguments,
      'result': result,
      'durationMs': durationMs,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ToolCallInfo &&
        other.name == name &&
        mapEquals(other.arguments, arguments) &&
        other.result == result &&
        other.durationMs == durationMs;
  }

  @override
  int get hashCode {
    return Object.hash(name, arguments, result, durationMs);
  }
}
