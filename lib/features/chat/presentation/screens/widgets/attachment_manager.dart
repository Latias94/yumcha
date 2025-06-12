import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// 附件项数据模型
@immutable
class AttachmentItem {
  /// 唯一标识符
  final String id;

  /// 附件类型
  final AttachmentType type;

  /// 文件名
  final String fileName;

  /// 文件大小（字节）
  final int size;

  /// MIME类型
  final String? mimeType;

  /// 文件数据
  final Uint8List data;

  /// 缩略图数据（用于图片预览）
  final Uint8List? thumbnail;

  /// 创建时间
  final DateTime createdAt;

  AttachmentItem({
    required this.id,
    required this.type,
    required this.fileName,
    required this.size,
    required this.data,
    this.mimeType,
    this.thumbnail,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 从ImageResult创建附件项
  factory AttachmentItem.fromImageResult(dynamic imageResult) {
    return AttachmentItem(
      id: const Uuid().v4(),
      type: AttachmentType.image,
      fileName: imageResult.name,
      size: imageResult.size,
      data: imageResult.bytes,
      mimeType: imageResult.mimeType,
      thumbnail: imageResult.bytes, // 图片本身作为缩略图
    );
  }

  /// 从文件创建附件项
  factory AttachmentItem.fromFile(
    Uint8List data, {
    required String fileName,
    required String mimeType,
  }) {
    return AttachmentItem(
      id: const Uuid().v4(),
      type: _getTypeFromMimeType(mimeType),
      fileName: fileName,
      size: data.length,
      data: data,
      mimeType: mimeType,
    );
  }

  /// 格式化的文件大小
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// 文件扩展名
  String get extension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// 是否是图片
  bool get isImage => type == AttachmentType.image;

  /// 是否是文档
  bool get isDocument => type == AttachmentType.document;

  /// 是否是音频
  bool get isAudio => type == AttachmentType.audio;

  /// 是否是视频
  bool get isVideo => type == AttachmentType.video;

  /// 复制附件项（移除描述功能）
  AttachmentItem copyWith({
    String? fileName,
    Uint8List? thumbnail,
  }) {
    return AttachmentItem(
      id: id,
      type: type,
      fileName: fileName ?? this.fileName,
      size: size,
      data: data,
      mimeType: mimeType,
      thumbnail: thumbnail ?? this.thumbnail,
      createdAt: createdAt,
    );
  }

  /// 根据MIME类型确定附件类型
  static AttachmentType _getTypeFromMimeType(String mimeType) {
    if (mimeType.startsWith('image/')) return AttachmentType.image;
    if (mimeType.startsWith('audio/')) return AttachmentType.audio;
    if (mimeType.startsWith('video/')) return AttachmentType.video;
    if (mimeType.contains('pdf') ||
        mimeType.contains('word') ||
        mimeType.contains('excel') ||
        mimeType.contains('powerpoint') ||
        mimeType.startsWith('text/')) {
      return AttachmentType.document;
    }
    return AttachmentType.other;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachmentItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AttachmentItem(id: $id, fileName: $fileName, size: $formattedSize)';
}

/// 附件类型枚举
enum AttachmentType {
  image,
  document,
  audio,
  video,
  other,
}

/// 附件类型扩展
extension AttachmentTypeExtension on AttachmentType {
  /// 获取图标
  String get icon {
    switch (this) {
      case AttachmentType.image:
        return '🖼️';
      case AttachmentType.document:
        return '📄';
      case AttachmentType.audio:
        return '🎵';
      case AttachmentType.video:
        return '🎬';
      case AttachmentType.other:
        return '📎';
    }
  }

  /// 获取颜色（Material Design）
  int get colorValue {
    switch (this) {
      case AttachmentType.image:
        return 0xFF4CAF50; // Green
      case AttachmentType.document:
        return 0xFF2196F3; // Blue
      case AttachmentType.audio:
        return 0xFF9C27B0; // Purple
      case AttachmentType.video:
        return 0xFFFF5722; // Deep Orange
      case AttachmentType.other:
        return 0xFF607D8B; // Blue Grey
    }
  }

  /// 获取类型名称
  String get displayName {
    switch (this) {
      case AttachmentType.image:
        return '图片';
      case AttachmentType.document:
        return '文档';
      case AttachmentType.audio:
        return '音频';
      case AttachmentType.video:
        return '视频';
      case AttachmentType.other:
        return '文件';
    }
  }
}

/// 附件管理器状态
class AttachmentManagerState {
  /// 附件列表
  final List<AttachmentItem> attachments;

  /// 是否展开附件面板
  final bool isExpanded;

  /// 是否正在添加附件
  final bool isAdding;

  const AttachmentManagerState({
    this.attachments = const [],
    this.isExpanded = false,
    this.isAdding = false,
  });

  /// 附件总数
  int get count => attachments.length;

  /// 是否有附件
  bool get hasAttachments => attachments.isNotEmpty;

  /// 附件总大小
  int get totalSize => attachments.fold(0, (sum, item) => sum + item.size);

  /// 格式化的总大小
  String get formattedTotalSize {
    if (totalSize < 1024) return '$totalSize B';
    if (totalSize < 1024 * 1024) {
      return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// 按类型分组的附件
  Map<AttachmentType, List<AttachmentItem>> get groupedByType {
    final Map<AttachmentType, List<AttachmentItem>> grouped = {};
    for (final attachment in attachments) {
      grouped.putIfAbsent(attachment.type, () => []).add(attachment);
    }
    return grouped;
  }

  /// 复制状态
  AttachmentManagerState copyWith({
    List<AttachmentItem>? attachments,
    bool? isExpanded,
    bool? isAdding,
  }) {
    return AttachmentManagerState(
      attachments: attachments ?? this.attachments,
      isExpanded: isExpanded ?? this.isExpanded,
      isAdding: isAdding ?? this.isAdding,
    );
  }

  /// 添加附件
  AttachmentManagerState addAttachment(AttachmentItem attachment) {
    return copyWith(
      attachments: [...attachments, attachment],
    );
  }

  /// 移除附件
  AttachmentManagerState removeAttachment(String attachmentId) {
    return copyWith(
      attachments:
          attachments.where((item) => item.id != attachmentId).toList(),
    );
  }

  /// 切换展开状态
  AttachmentManagerState toggleExpanded() {
    return copyWith(isExpanded: !isExpanded);
  }

  /// 清空所有附件
  AttachmentManagerState clear() {
    return copyWith(
      attachments: [],
      isExpanded: false,
    );
  }

  @override
  String toString() =>
      'AttachmentManagerState(count: $count, expanded: $isExpanded)';
}
