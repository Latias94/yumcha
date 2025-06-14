import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'message.dart';
import 'message_metadata.dart';
import '../../../../shared/infrastructure/services/media/media_storage_service.dart';

/// 增强的消息类，支持多媒体内容
/// 
/// 扩展基础Message类，添加多媒体文件支持
/// 保持向后兼容性，同时提供新的多媒体功能
@immutable
class EnhancedMessage extends Message {
  /// 多媒体文件元数据列表
  final List<MediaMetadata> mediaFiles;

  const EnhancedMessage({
    super.id,
    required super.author,
    required super.content,
    required super.timestamp,
    super.imageUrl,
    super.avatarUrl,
    required super.isFromUser,
    super.duration,
    super.metadata,
    super.parentMessageId,
    super.version = 1,
    super.isActive = true,
    super.status = MessageStatus.normal,
    super.errorInfo,
    this.mediaFiles = const [],
  });

  /// 从基础Message创建EnhancedMessage
  factory EnhancedMessage.fromMessage(
    Message message, {
    List<MediaMetadata>? mediaFiles,
  }) {
    return EnhancedMessage(
      id: message.id,
      author: message.author,
      content: message.content,
      timestamp: message.timestamp,
      imageUrl: message.imageUrl,
      avatarUrl: message.avatarUrl,
      isFromUser: message.isFromUser,
      duration: message.duration,
      metadata: message.metadata,
      parentMessageId: message.parentMessageId,
      version: message.version,
      isActive: message.isActive,
      status: message.status,
      errorInfo: message.errorInfo,
      mediaFiles: mediaFiles ?? [],
    );
  }

  /// 创建包含多媒体内容的消息
  factory EnhancedMessage.withMedia({
    String? id,
    required String author,
    required String content,
    required DateTime timestamp,
    String? imageUrl,
    String? avatarUrl,
    required bool isFromUser,
    Duration? duration,
    MessageMetadata? metadata,
    String? parentMessageId,
    int version = 1,
    bool isActive = true,
    MessageStatus status = MessageStatus.normal,
    String? errorInfo,
    required List<MediaMetadata> mediaFiles,
  }) {
    return EnhancedMessage(
      id: id,
      author: author,
      content: content,
      timestamp: timestamp,
      imageUrl: imageUrl,
      avatarUrl: avatarUrl,
      isFromUser: isFromUser,
      duration: duration,
      metadata: metadata,
      parentMessageId: parentMessageId,
      version: version,
      isActive: isActive,
      status: status,
      errorInfo: errorInfo,
      mediaFiles: mediaFiles,
    );
  }

  @override
  EnhancedMessage copyWith({
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
    List<MediaMetadata>? mediaFiles,
  }) {
    return EnhancedMessage(
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
      mediaFiles: mediaFiles ?? this.mediaFiles,
    );
  }

  /// 是否包含多媒体文件
  bool get hasMediaFiles => mediaFiles.isNotEmpty;

  /// 获取所有图片文件
  List<MediaMetadata> get imageFiles => 
      mediaFiles.where((media) => media.isImage).toList();

  /// 获取所有音频文件
  List<MediaMetadata> get audioFiles => 
      mediaFiles.where((media) => media.isAudio).toList();

  /// 获取所有视频文件
  List<MediaMetadata> get videoFiles => 
      mediaFiles.where((media) => media.isVideo).toList();

  /// 是否包含图片
  bool get hasImages => imageFiles.isNotEmpty;

  /// 是否包含音频
  bool get hasAudio => audioFiles.isNotEmpty;

  /// 是否包含视频
  bool get hasVideo => videoFiles.isNotEmpty;

  /// 获取多媒体文件总大小
  int get totalMediaSize => 
      mediaFiles.fold(0, (sum, media) => sum + media.sizeBytes);

  /// 格式化的多媒体文件总大小
  String get formattedTotalMediaSize {
    final size = totalMediaSize;
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// 将多媒体元数据序列化为JSON字符串（用于数据库存储）
  String? get mediaMetadataJson {
    if (mediaFiles.isEmpty) return null;
    return jsonEncode(mediaFiles.map((media) => media.toJson()).toList());
  }

  /// 从JSON字符串反序列化多媒体元数据
  static List<MediaMetadata> parseMediaMetadata(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => MediaMetadata.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // 如果解析失败，返回空列表
      return [];
    }
  }

  /// 创建包含AI生成图片的消息
  factory EnhancedMessage.withAiGeneratedImage({
    required String author,
    required String content,
    required String imageUrl,
    String? imageDescription,
    DateTime? timestamp,
    MessageMetadata? metadata,
  }) {
    // 创建网络图片的媒体元数据
    final imageMetadata = MediaMetadata(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: 'ai_generated_image.png',
      mimeType: 'image/png',
      sizeBytes: 0, // 网络图片大小未知
      strategy: MediaStorageStrategy.networkUrl,
      networkUrl: imageUrl,
      createdAt: timestamp ?? DateTime.now(),
      customProperties: {
        'type': 'ai_generated',
        'description': imageDescription,
      },
    );

    return EnhancedMessage(
      author: author,
      content: content,
      timestamp: timestamp ?? DateTime.now(),
      imageUrl: imageUrl, // 保持向后兼容
      isFromUser: false,
      metadata: metadata,
      mediaFiles: [imageMetadata],
    );
  }

  /// 创建包含TTS音频的消息
  factory EnhancedMessage.withTtsAudio({
    required String author,
    required String content,
    required String audioUrl,
    Duration? audioDuration,
    DateTime? timestamp,
    MessageMetadata? metadata,
  }) {
    // 创建音频的媒体元数据
    final audioMetadata = MediaMetadata(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: 'tts_audio.mp3',
      mimeType: 'audio/mpeg',
      sizeBytes: 0, // 网络音频大小未知
      strategy: MediaStorageStrategy.networkUrl,
      networkUrl: audioUrl,
      createdAt: timestamp ?? DateTime.now(),
      customProperties: {
        'type': 'tts_generated',
        'duration': audioDuration?.inMilliseconds,
      },
    );

    return EnhancedMessage(
      author: author,
      content: content,
      timestamp: timestamp ?? DateTime.now(),
      isFromUser: false,
      metadata: metadata,
      mediaFiles: [audioMetadata],
    );
  }

  /// 转换为基础Message（用于向后兼容）
  Message toBaseMessage() {
    return Message(
      id: id,
      author: author,
      content: content,
      timestamp: timestamp,
      imageUrl: imageUrl,
      avatarUrl: avatarUrl,
      isFromUser: isFromUser,
      duration: duration,
      metadata: metadata,
      parentMessageId: parentMessageId,
      version: version,
      isActive: isActive,
      status: status,
      errorInfo: errorInfo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EnhancedMessage &&
        super == other &&
        listEquals(mediaFiles, other.mediaFiles);
  }

  @override
  int get hashCode {
    return Object.hash(super.hashCode, mediaFiles);
  }

  @override
  String toString() {
    return 'EnhancedMessage('
        'id: $id, '
        'author: $author, '
        'content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content}, '
        'timestamp: $timestamp, '
        'isFromUser: $isFromUser, '
        'mediaFiles: ${mediaFiles.length}, '
        'status: $status'
        ')';
  }
}
