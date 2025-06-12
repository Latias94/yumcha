import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

/// 图片服务 - 处理跨平台的图片选择和拍照功能
///
/// 支持的平台功能：
/// - 📱 **移动端**：相机拍照、相册选择
/// - 🖥️ **桌面端**：文件选择器
/// - 🌐 **Web端**：文件上传
///
/// ## 使用示例
/// ```dart
/// final imageService = ImageService();
///
/// // 拍照
/// final cameraImage = await imageService.pickFromCamera();
///
/// // 选择照片
/// final galleryImage = await imageService.pickFromGallery();
///
/// // 多选照片
/// final multipleImages = await imageService.pickMultipleImages();
/// ```
class ImageService {
  static final Logger _logger = Logger();
  static final ImagePicker _picker = ImagePicker();

  /// 从相机拍照
  ///
  /// 在桌面端会回退到文件选择器
  static Future<ImageResult?> pickFromCamera({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      _logger.d('开始从相机选择图片');

      // 检查平台支持
      if (kIsWeb || Platform.isWindows || Platform.isLinux) {
        _logger.w('当前平台不支持相机，回退到文件选择器');
        return await pickFromGallery(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
        );
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 85,
      );

      if (image != null) {
        final result = await _processImage(image);
        _logger.i('相机拍照成功: path=${image.path}, size=${result.bytes.length}');
        return result;
      }

      _logger.d('用户取消了相机拍照');
      return null;
    } catch (e, stackTrace) {
      _logger.e('相机拍照失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 从相册选择图片
  static Future<ImageResult?> pickFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      _logger.d('开始从相册选择图片');

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 85,
      );

      if (image != null) {
        final result = await _processImage(image);
        _logger.i('相册选择成功: path=${image.path}, size=${result.bytes.length}');
        return result;
      }

      _logger.d('用户取消了相册选择');
      return null;
    } catch (e, stackTrace) {
      _logger.e('相册选择失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 选择多张图片
  static Future<List<ImageResult>> pickMultipleImages({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
  }) async {
    try {
      _logger.d('开始选择多张图片: limit=$limit');

      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 85,
        limit: limit,
      );

      if (images.isNotEmpty) {
        final List<ImageResult> results = [];
        for (final image in images) {
          final result = await _processImage(image);
          results.add(result);
        }

        final totalSize =
            results.fold<int>(0, (sum, r) => sum + r.bytes.length);
        _logger.i('多图选择成功: count=${results.length}, totalSize=$totalSize');
        return results;
      }

      _logger.d('用户取消了多图选择');
      return [];
    } catch (e, stackTrace) {
      _logger.e('多图选择失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 显示图片选择对话框
  static Future<ImageResult?> showImagePickerDialog(
    BuildContext context, {
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    return await showModalBottomSheet<ImageResult>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ImagePickerBottomSheet(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      ),
    );
  }

  /// 处理选择的图片
  static Future<ImageResult> _processImage(XFile image) async {
    final bytes = await image.readAsBytes();
    final name = image.name;
    final path = image.path;
    final mimeType = image.mimeType;

    return ImageResult(
      bytes: bytes,
      name: name,
      path: path,
      mimeType: mimeType,
    );
  }

  /// 检查是否支持相机
  static bool get isCameraSupported {
    return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  }

  /// 检查是否支持多选
  static bool get isMultipleSelectionSupported {
    return true; // image_picker 在所有平台都支持多选
  }
}

/// 图片选择结果
class ImageResult {
  const ImageResult({
    required this.bytes,
    required this.name,
    required this.path,
    this.mimeType,
  });

  /// 图片字节数据
  final Uint8List bytes;

  /// 文件名
  final String name;

  /// 文件路径
  final String path;

  /// MIME类型
  final String? mimeType;

  /// 文件大小（字节）
  int get size => bytes.length;

  /// 格式化的文件大小
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  String toString() {
    return 'ImageResult(name: $name, size: $formattedSize, mimeType: $mimeType)';
  }
}

/// 图片选择底部弹窗
class _ImagePickerBottomSheet extends StatelessWidget {
  const _ImagePickerBottomSheet({
    this.maxWidth,
    this.maxHeight,
    this.imageQuality,
  });

  final double? maxWidth;
  final double? maxHeight;
  final int? imageQuality;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          Text(
            '选择图片',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 20),

          // 选项列表
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 相机拍照
              if (ImageService.isCameraSupported)
                _buildOption(
                  context: context,
                  icon: Icons.camera_alt,
                  label: '拍照',
                  onTap: () async {
                    Navigator.of(context).pop();
                    final result = await ImageService.pickFromCamera(
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                      imageQuality: imageQuality,
                    );
                    if (context.mounted && result != null) {
                      Navigator.of(context).pop(result);
                    }
                  },
                ),

              // 相册选择
              _buildOption(
                context: context,
                icon: Icons.photo_library,
                label: '相册',
                onTap: () async {
                  Navigator.of(context).pop();
                  final result = await ImageService.pickFromGallery(
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                    imageQuality: imageQuality,
                  );
                  if (context.mounted && result != null) {
                    Navigator.of(context).pop(result);
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 取消按钮
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
