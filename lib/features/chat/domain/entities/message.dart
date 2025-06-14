import 'package:flutter/foundation.dart';
import 'message_metadata.dart';

/// 消息状态枚举
enum MessageStatus {
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

/// 消息状态扩展方法
extension MessageStatusExtension on MessageStatus {
  /// 是否应该持久化到数据库
  bool get shouldPersist {
    switch (this) {
      case MessageStatus.normal:
      case MessageStatus.system:
        return true;
      case MessageStatus.sending:
      case MessageStatus.streaming:
      case MessageStatus.failed:
      case MessageStatus.error:
      case MessageStatus.temporary:
      case MessageStatus.regenerating:
        return false;
    }
  }

  /// 是否是错误状态
  bool get isError {
    return this == MessageStatus.error || this == MessageStatus.failed;
  }

  /// 是否是临时状态
  bool get isTemporary {
    return this == MessageStatus.temporary ||
        this == MessageStatus.sending ||
        this == MessageStatus.streaming ||
        this == MessageStatus.regenerating;
  }

  /// 获取状态显示文本
  String get displayText {
    switch (this) {
      case MessageStatus.normal:
        return '';
      case MessageStatus.sending:
        return '发送中...';
      case MessageStatus.streaming:
        return '正在回复...';
      case MessageStatus.failed:
        return '发送失败';
      case MessageStatus.error:
        return '错误';
      case MessageStatus.system:
        return '系统消息';
      case MessageStatus.temporary:
        return '临时消息';
      case MessageStatus.regenerating:
        return '重新生成中...';
    }
  }
}

/// 聊天消息数据模型
///
/// 表示聊天对话中的单条消息，包含消息内容、作者、时间戳等信息。
/// 支持文本消息、图像消息和多媒体内容，区分用户消息和 AI 回复。
///
/// 核心特性：
/// - 💬 **消息内容**: 支持文本、图像和多媒体内容
/// - 👤 **作者标识**: 区分用户和 AI 助手
/// - ⏰ **时间戳**: 记录消息的创建时间
/// - 🖼️ **多媒体支持**: 支持图像 URL、音频 URL 和头像 URL
/// - 🔄 **不可变性**: 使用 @immutable 确保数据不可变
/// - 💾 **数据库兼容**: 支持数据库 ID 的可选字段
/// - 📊 **状态管理**: 支持消息状态和错误处理
/// - 🔒 **持久化控制**: 支持临时消息和持久化消息
/// - 📁 **文件管理**: 支持本地文件存储和云端URL引用
///
/// 多媒体存储策略：
/// - 小文件（<1MB）：直接存储在数据库中（Base64编码）
/// - 大文件（>=1MB）：存储在本地文件系统，数据库保存文件路径
/// - 网络资源：保存URL，支持缓存到本地
/// - 导出兼容：支持将所有多媒体内容打包导出
///
/// 业务逻辑：
/// - 用户发送的消息 isFromUser 为 true
/// - AI 回复的消息 isFromUser 为 false
/// - 新创建的消息可能没有数据库 ID（id 为 null）
/// - 保存到数据库后会分配唯一的 ID
/// - 错误消息不会被持久化到数据库
/// - 临时消息（如加载状态）不会被保存
/// - 多媒体文件自动管理生命周期
///
/// 使用场景：
/// - 聊天界面的消息显示
/// - 消息历史的存储和加载
/// - AI 服务的上下文传递
/// - 错误状态展示
/// - 多媒体内容的展示和播放
@immutable
class Message {
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

  /// AI 响应耗时（仅对 AI 消息有效）- 保留向后兼容
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
  final MessageStatus status;

  /// 错误信息（仅当状态为error或failed时有值）
  final String? errorInfo;

  const Message({
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
    this.status = MessageStatus.normal,
    this.errorInfo,
  });

  Message copyWith({
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
    MessageStatus? status,
    String? errorInfo,
  }) {
    return Message(
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
  factory Message.error({
    required String author,
    required String errorMessage,
    String? originalContent,
    DateTime? timestamp,
    String? errorInfo,
  }) {
    return Message(
      author: author,
      content: originalContent ?? '',
      timestamp: timestamp ?? DateTime.now(),
      isFromUser: false,
      status: MessageStatus.error,
      errorInfo: errorInfo ?? errorMessage,
    );
  }

  /// 创建临时消息（如加载指示器）
  factory Message.temporary({
    required String author,
    required String content,
    DateTime? timestamp,
  }) {
    return Message(
      author: author,
      content: content,
      timestamp: timestamp ?? DateTime.now(),
      isFromUser: false,
      status: MessageStatus.temporary,
    );
  }

  /// 创建系统消息
  factory Message.system({
    required String content,
    DateTime? timestamp,
  }) {
    return Message(
      author: 'System',
      content: content,
      timestamp: timestamp ?? DateTime.now(),
      isFromUser: false,
      status: MessageStatus.system,
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
    return other is Message &&
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
    return 'Message(id: $id, author: $author, content: $content, timestamp: $timestamp, isFromUser: $isFromUser)';
  }
}
