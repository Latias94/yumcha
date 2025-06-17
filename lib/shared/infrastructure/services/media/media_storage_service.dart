import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import '../logger_service.dart';

/// 多媒体文件存储策略
enum MediaStorageStrategy {
  /// 数据库存储（适用于小文件 <1MB）
  database,

  /// 本地文件存储（适用于大文件 >=1MB）
  localFile,

  /// 网络URL引用（适用于远程资源）
  networkUrl,

  /// 缓存存储（临时文件）
  cache,
}

/// 多媒体文件元数据
class MediaMetadata {
  final String id;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final MediaStorageStrategy strategy;
  final String? localPath;
  final String? networkUrl;
  final String? base64Data;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? customProperties;

  const MediaMetadata({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.strategy,
    this.localPath,
    this.networkUrl,
    this.base64Data,
    required this.createdAt,
    this.expiresAt,
    this.customProperties,
  });

  /// 是否是图片类型
  bool get isImage => mimeType.startsWith('image/');

  /// 是否是音频类型
  bool get isAudio => mimeType.startsWith('audio/');

  /// 是否是视频类型
  bool get isVideo => mimeType.startsWith('video/');

  /// 格式化文件大小
  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024)
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// 是否已过期
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      'strategy': strategy.name,
      'localPath': localPath,
      'networkUrl': networkUrl,
      'base64Data': base64Data,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'customProperties': customProperties,
    };
  }

  factory MediaMetadata.fromJson(Map<String, dynamic> json) {
    return MediaMetadata(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      mimeType: json['mimeType'] as String,
      sizeBytes: json['sizeBytes'] as int,
      strategy: MediaStorageStrategy.values.firstWhere(
        (s) => s.name == json['strategy'],
        orElse: () => MediaStorageStrategy.localFile,
      ),
      localPath: json['localPath'] as String?,
      networkUrl: json['networkUrl'] as String?,
      base64Data: json['base64Data'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      customProperties: json['customProperties'] as Map<String, dynamic>?,
    );
  }
}

/// 多媒体存储服务
///
/// 负责管理AI聊天中的图片、音频等多媒体文件的存储和检索
///
/// 存储策略：
/// - 小文件（<1MB）：Base64编码存储在数据库中
/// - 大文件（>=1MB）：存储在本地文件系统
/// - 网络资源：缓存到本地，保留原始URL
/// - 支持数据导入导出
class MediaStorageService {
  static const int _smallFileSizeThreshold = 1024 * 1024; // 1MB
  static const String _mediaFolderName = 'media';
  static const String _cacheFolderName = 'cache';

  final LoggerService _logger = LoggerService();

  Directory? _mediaDirectory;
  Directory? _cacheDirectory;
  bool _isInitialized = false;

  /// 初始化服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();

      // 创建媒体文件目录
      _mediaDirectory = Directory(path.join(appDir.path, _mediaFolderName));
      if (!await _mediaDirectory!.exists()) {
        await _mediaDirectory!.create(recursive: true);
      }

      // 创建缓存目录
      _cacheDirectory = Directory(path.join(appDir.path, _cacheFolderName));
      if (!await _cacheDirectory!.exists()) {
        await _cacheDirectory!.create(recursive: true);
      }

      _isInitialized = true;
      _logger.info('多媒体存储服务初始化完成');
    } catch (e) {
      _logger.error('多媒体存储服务初始化失败: $e');
      rethrow;
    }
  }

  /// 存储多媒体文件
  Future<MediaMetadata> storeMedia({
    required Uint8List data,
    required String fileName,
    required String mimeType,
    String? networkUrl,
    Duration? cacheExpiry,
    Map<String, dynamic>? customProperties,
  }) async {
    await initialize();

    final id = _generateMediaId(data);
    final strategy = _determineStorageStrategy(data.length, networkUrl);
    final now = DateTime.now();

    MediaMetadata metadata;

    switch (strategy) {
      case MediaStorageStrategy.database:
        // 小文件直接存储为Base64
        final base64Data = base64Encode(data);
        metadata = MediaMetadata(
          id: id,
          fileName: fileName,
          mimeType: mimeType,
          sizeBytes: data.length,
          strategy: strategy,
          base64Data: base64Data,
          networkUrl: networkUrl,
          createdAt: now,
          customProperties: customProperties,
        );
        break;

      case MediaStorageStrategy.localFile:
        // 大文件存储到本地文件系统
        final localPath = await _saveToLocalFile(id, fileName, data);
        metadata = MediaMetadata(
          id: id,
          fileName: fileName,
          mimeType: mimeType,
          sizeBytes: data.length,
          strategy: strategy,
          localPath: localPath,
          networkUrl: networkUrl,
          createdAt: now,
          customProperties: customProperties,
        );
        break;

      case MediaStorageStrategy.cache:
        // 缓存文件（有过期时间）
        final localPath = await _saveToCacheFile(id, fileName, data);
        metadata = MediaMetadata(
          id: id,
          fileName: fileName,
          mimeType: mimeType,
          sizeBytes: data.length,
          strategy: strategy,
          localPath: localPath,
          networkUrl: networkUrl,
          createdAt: now,
          expiresAt: cacheExpiry != null ? now.add(cacheExpiry) : null,
          customProperties: customProperties,
        );
        break;

      case MediaStorageStrategy.networkUrl:
        // 仅保存URL引用
        metadata = MediaMetadata(
          id: id,
          fileName: fileName,
          mimeType: mimeType,
          sizeBytes: data.length,
          strategy: strategy,
          networkUrl: networkUrl,
          createdAt: now,
          customProperties: customProperties,
        );
        break;
    }

    _logger.info('存储多媒体文件', {
      'id': id,
      'fileName': fileName,
      'size': metadata.formattedSize,
      'strategy': strategy.name,
    });

    return metadata;
  }

  /// 检索多媒体文件数据
  Future<Uint8List?> retrieveMedia(MediaMetadata metadata) async {
    await initialize();

    try {
      switch (metadata.strategy) {
        case MediaStorageStrategy.database:
          if (metadata.base64Data != null) {
            return base64Decode(metadata.base64Data!);
          }
          break;

        case MediaStorageStrategy.localFile:
        case MediaStorageStrategy.cache:
          if (metadata.localPath != null) {
            final file = File(metadata.localPath!);
            if (await file.exists()) {
              // 检查缓存文件是否过期
              if (metadata.strategy == MediaStorageStrategy.cache &&
                  metadata.isExpired) {
                await file.delete();
                _logger.debug('删除过期缓存文件: ${metadata.localPath}');
                return null;
              }
              return await file.readAsBytes();
            }
          }
          break;

        case MediaStorageStrategy.networkUrl:
          // 网络URL需要外部处理下载
          _logger.debug('网络URL需要外部下载: ${metadata.networkUrl}');
          return null;
      }
    } catch (e) {
      _logger.error('检索多媒体文件失败', {
        'id': metadata.id,
        'error': e.toString(),
      });
    }

    return null;
  }

  /// 删除多媒体文件
  Future<bool> deleteMedia(MediaMetadata metadata) async {
    await initialize();

    try {
      switch (metadata.strategy) {
        case MediaStorageStrategy.database:
          // 数据库存储的文件无需额外删除
          break;

        case MediaStorageStrategy.localFile:
        case MediaStorageStrategy.cache:
          if (metadata.localPath != null) {
            final file = File(metadata.localPath!);
            if (await file.exists()) {
              await file.delete();
              _logger.debug('删除本地文件: ${metadata.localPath}');
            }
          }
          break;

        case MediaStorageStrategy.networkUrl:
          // 网络URL无需删除
          break;
      }

      _logger.info('删除多媒体文件', {
        'id': metadata.id,
        'fileName': metadata.fileName,
        'strategy': metadata.strategy.name,
      });

      return true;
    } catch (e) {
      _logger.error('删除多媒体文件失败', {
        'id': metadata.id,
        'error': e.toString(),
      });
      return false;
    }
  }

  /// 清理过期的缓存文件
  Future<int> cleanupExpiredCache() async {
    await initialize();

    int cleanedCount = 0;
    try {
      final cacheFiles = await _cacheDirectory!.list().toList();

      for (final entity in cacheFiles) {
        if (entity is File) {
          final stat = await entity.stat();
          final age = DateTime.now().difference(stat.modified);

          // 清理超过7天的缓存文件
          if (age.inDays > 7) {
            await entity.delete();
            cleanedCount++;
            _logger.debug('清理过期缓存文件: ${entity.path}');
          }
        }
      }

      if (cleanedCount > 0) {
        _logger.info('清理过期缓存文件完成', {'count': cleanedCount});
      }
    } catch (e) {
      _logger.error('清理缓存文件失败: $e');
    }

    return cleanedCount;
  }

  /// 获取存储统计信息
  Future<Map<String, dynamic>> getStorageStats() async {
    await initialize();

    try {
      final mediaFiles = await _mediaDirectory!.list(recursive: true).toList();
      final cacheFiles = await _cacheDirectory!.list(recursive: true).toList();

      int mediaSize = 0;
      int cacheSize = 0;

      for (final entity in mediaFiles) {
        if (entity is File) {
          final stat = await entity.stat();
          mediaSize += stat.size;
        }
      }

      for (final entity in cacheFiles) {
        if (entity is File) {
          final stat = await entity.stat();
          cacheSize += stat.size;
        }
      }

      return {
        'mediaFiles': mediaFiles.length,
        'cacheFiles': cacheFiles.length,
        'mediaSizeBytes': mediaSize,
        'cacheSizeBytes': cacheSize,
        'mediaSizeFormatted': _formatBytes(mediaSize),
        'cacheSizeFormatted': _formatBytes(cacheSize),
        'totalSizeFormatted': _formatBytes(mediaSize + cacheSize),
      };
    } catch (e) {
      _logger.error('获取存储统计失败: $e');
      return {};
    }
  }

  /// 导出多媒体文件到指定目录（用于数据导出）
  Future<List<String>> exportMediaFiles(
    List<MediaMetadata> mediaList,
    String exportPath,
  ) async {
    await initialize();

    final exportedFiles = <String>[];
    final exportDir = Directory(exportPath);

    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    for (final metadata in mediaList) {
      try {
        final data = await retrieveMedia(metadata);
        if (data != null) {
          final exportFile = File(path.join(exportPath, metadata.fileName));
          await exportFile.writeAsBytes(data);
          exportedFiles.add(exportFile.path);

          _logger.debug('导出多媒体文件', {
            'id': metadata.id,
            'fileName': metadata.fileName,
            'exportPath': exportFile.path,
          });
        }
      } catch (e) {
        _logger.error('导出多媒体文件失败', {
          'id': metadata.id,
          'fileName': metadata.fileName,
          'error': e.toString(),
        });
      }
    }

    _logger.info('多媒体文件导出完成', {
      'total': mediaList.length,
      'exported': exportedFiles.length,
    });

    return exportedFiles;
  }

  /// 从导入目录批量导入多媒体文件
  Future<List<MediaMetadata>> importMediaFiles(String importPath) async {
    await initialize();

    final importedMedia = <MediaMetadata>[];
    final importDir = Directory(importPath);

    if (!await importDir.exists()) {
      _logger.warning('导入目录不存在: $importPath');
      return importedMedia;
    }

    final files =
        await importDir.list().where((entity) => entity is File).toList();

    for (final entity in files) {
      try {
        final file = entity as File;
        final data = await file.readAsBytes();
        final fileName = path.basename(file.path);
        final mimeType = _getMimeType(fileName);

        final metadata = await storeMedia(
          data: data,
          fileName: fileName,
          mimeType: mimeType,
          customProperties: {'imported': true},
        );

        importedMedia.add(metadata);

        _logger.debug('导入多媒体文件', {
          'fileName': fileName,
          'size': metadata.formattedSize,
        });
      } catch (e) {
        _logger.error('导入多媒体文件失败', {
          'filePath': entity.path,
          'error': e.toString(),
        });
      }
    }

    _logger.info('多媒体文件导入完成', {
      'total': files.length,
      'imported': importedMedia.length,
    });

    return importedMedia;
  }

  // 私有方法

  /// 生成媒体文件ID
  String _generateMediaId(Uint8List data) {
    final hash = sha256.convert(data);
    return hash.toString().substring(0, 16);
  }

  /// 确定存储策略
  MediaStorageStrategy _determineStorageStrategy(
      int sizeBytes, String? networkUrl) {
    if (networkUrl != null && networkUrl.startsWith('http')) {
      return MediaStorageStrategy.networkUrl;
    }

    if (sizeBytes < _smallFileSizeThreshold) {
      return MediaStorageStrategy.database;
    } else {
      return MediaStorageStrategy.localFile;
    }
  }

  /// 保存到本地文件
  Future<String> _saveToLocalFile(
      String id, String fileName, Uint8List data) async {
    final extension = path.extension(fileName);
    final localFileName = '$id$extension';
    final localFile = File(path.join(_mediaDirectory!.path, localFileName));

    await localFile.writeAsBytes(data);
    return localFile.path;
  }

  /// 保存到缓存文件
  Future<String> _saveToCacheFile(
      String id, String fileName, Uint8List data) async {
    final extension = path.extension(fileName);
    final cacheFileName = '$id$extension';
    final cacheFile = File(path.join(_cacheDirectory!.path, cacheFileName));

    await cacheFile.writeAsBytes(data);
    return cacheFile.path;
  }

  /// 格式化字节大小
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 根据文件名获取MIME类型
  String _getMimeType(String fileName) {
    final extension = path.extension(fileName).toLowerCase();

    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.mp3':
        return 'audio/mpeg';
      case '.wav':
        return 'audio/wav';
      case '.ogg':
        return 'audio/ogg';
      case '.m4a':
        return 'audio/mp4';
      case '.mp4':
        return 'video/mp4';
      case '.webm':
        return 'video/webm';
      default:
        return 'application/octet-stream';
    }
  }
}
