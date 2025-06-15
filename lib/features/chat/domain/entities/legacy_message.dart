import 'package:flutter/foundation.dart';
import 'message_metadata.dart';

/// 旧版消息状态枚举（用于兼容性）
enum LegacyMessageStatus {
  /// 正常消息（默认状态）
  normal,

  /// 发送中
  sending,

  /// 流式传输中
  streaming,

  /// 发送失败
  failed,

  /// 错误消息（显示错误信息，不持久化）
  error,

  /// 系统消息（如欢迎消息）
  system,

  /// 临时消息（如加载指示器，不持久化）
  temporary,

  /// 重新生成中
  regenerating,
}

/// 旧版消息状态扩展方法
extension LegacyMessageStatusExtension on LegacyMessageStatus {
  /// 是否应该持久化到数据库
  bool get shouldPersist {
    switch (this) {
      case LegacyMessageStatus.normal:
      case LegacyMessageStatus.system:
        return true;
      case LegacyMessageStatus.sending:
      case LegacyMessageStatus.streaming:
      case LegacyMessageStatus.failed:
      case LegacyMessageStatus.error:
      case LegacyMessageStatus.temporary:
      case LegacyMessageStatus.regenerating:
        return false;
    }
  }

  /// 是否是错误状态
  bool get isError {
    return this == LegacyMessageStatus.error || this == LegacyMessageStatus.failed;
  }

  /// 是否是临时状态
  bool get isTemporary {
    return this == LegacyMessageStatus.temporary ||
        this == LegacyMessageStatus.sending ||
        this == LegacyMessageStatus.streaming ||
        this == LegacyMessageStatus.regenerating;
  }
}

/// 旧版消息数据模型（用于兼容性）
/// 
/// 这个类用于与现有的ChatService兼容，
/// 在完全迁移到新的块化架构之前提供过渡支持
@immutable
class LegacyMessage {
  /// 数据库 ID（可选，新创建的消息可能还没有 ID）
  final String? id;

  /// 消息作者（用户名或 AI 助手名）
  final String author;

  /// 消息内容（文本内容）
  final String content;

  /// 消息时间戳
  final DateTime timestamp;

  /// 图像 URL（可选，用于图像消息）
  final String? imageUrl;

  /// 头像 URL（可选，用于显示作者头像）
  final String? avatarUrl;

  /// 是否为用户发送的消息（true: 用户消息，false: AI 回复）
  final bool isFromUser;

  /// AI 响应耗时（仅对 AI 消息有效）
  final Duration? duration;

  /// 消息元数据（AI响应的详细信息）
  final MessageMetadata? metadata;

  /// 父消息ID（用于重新生成的消息）
  final String? parentMessageId;

  /// 消息版本号
  final int version;

  /// 是否为当前活跃版本
  final bool isActive;

  /// 消息状态
  final LegacyMessageStatus status;

  /// 错误信息（仅当状态为error或failed时有值）
  final String? errorInfo;

  const LegacyMessage({
    this.id,
    required this.author,
    required this.content,
    required this.timestamp,
    this.imageUrl,
    this.avatarUrl,
    required this.isFromUser,
    this.duration,
    this.metadata,
    this.parentMessageId,
    this.version = 1,
    this.isActive = true,
    this.status = LegacyMessageStatus.normal,
    this.errorInfo,
  });

  /// 复制并修改部分属性
  LegacyMessage copyWith({
    String? id,
    String? author,
    String? content,
    DateTime? timestamp,
    String? imageUrl,
    String? avatarUrl,
    bool? isFromUser,
    Duration? duration,
    MessageMetadata? metadata,
    String? parentMessageId,
    int? version,
    bool? isActive,
    LegacyMessageStatus? status,
    String? errorInfo,
  }) {
    return LegacyMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isFromUser: isFromUser ?? this.isFromUser,
      duration: duration ?? this.duration,
      metadata: metadata ?? this.metadata,
      parentMessageId: parentMessageId ?? this.parentMessageId,
      version: version ?? this.version,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      errorInfo: errorInfo ?? this.errorInfo,
    );
  }

  /// 创建错误消息
  factory LegacyMessage.error({
    required String author,
    required String errorMessage,
    String? originalContent,
    DateTime? timestamp,
    String? errorInfo,
  }) {
    return LegacyMessage(
      author: author,
      content: originalContent ?? '',
      timestamp: timestamp ?? DateTime.now(),
      isFromUser: false,
      status: LegacyMessageStatus.error,
      errorInfo: errorInfo ?? errorMessage,
    );
  }

  /// 创建临时消息（如加载指示器）
  factory LegacyMessage.temporary({
    required String author,
    required String content,
    DateTime? timestamp,
  }) {
    return LegacyMessage(
      author: author,
      content: content,
      timestamp: timestamp ?? DateTime.now(),
      isFromUser: false,
      status: LegacyMessageStatus.temporary,
    );
  }

  /// 创建系统消息
  factory LegacyMessage.system({
    required String content,
    DateTime? timestamp,
  }) {
    return LegacyMessage(
      author: 'System',
      content: content,
      timestamp: timestamp ?? DateTime.now(),
      isFromUser: false,
      status: LegacyMessageStatus.system,
    );
  }

  /// 是否应该持久化到数据库
  bool get shouldPersist => status.shouldPersist;

  /// 是否是错误状态
  bool get isError => status.isError;

  /// 是否是临时状态
  bool get isTemporary => status.isTemporary;

  /// 获取思考过程耗时
  Duration? get thinkingDuration {
    if (metadata?.thinkingDurationMs != null) {
      return Duration(milliseconds: metadata!.thinkingDurationMs!);
    }
    return null;
  }

  /// 获取总响应耗时（优先使用元数据）
  Duration? get totalDuration {
    if (metadata?.totalDurationMs != null) {
      return Duration(milliseconds: metadata!.totalDurationMs!);
    }
    return duration; // 向后兼容
  }

  /// 获取内容生成耗时
  Duration? get contentDuration {
    if (metadata?.contentDurationMs != null) {
      return Duration(milliseconds: metadata!.contentDurationMs!);
    }
    return null;
  }

  /// 是否包含思考过程
  bool get hasThinking {
    return metadata?.hasThinking ?? false;
  }

  /// 是否使用了工具调用
  bool get hasToolCalls {
    return metadata?.hasToolCalls ?? false;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LegacyMessage &&
        other.id == id &&
        other.author == author &&
        other.content == content &&
        other.timestamp == timestamp &&
        other.imageUrl == imageUrl &&
        other.avatarUrl == avatarUrl &&
        other.isFromUser == isFromUser;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      author,
      content,
      timestamp,
      imageUrl,
      avatarUrl,
      isFromUser,
    );
  }

  @override
  String toString() {
    return 'LegacyMessage(id: $id, author: $author, content: $content, timestamp: $timestamp, isFromUser: $isFromUser)';
  }
}
