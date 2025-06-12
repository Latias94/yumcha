import 'package:flutter/material.dart';

/// 附件面板组件
class AttachmentPanel extends StatelessWidget {
  const AttachmentPanel({
    super.key,
    required this.onCameraPressed,
    required this.onPhotoPressed,
  });

  final VoidCallback onCameraPressed;
  final VoidCallback onPhotoPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAttachmentButton(
            context: context,
            icon: Icons.camera_alt,
            label: "拍照",
            onTap: onCameraPressed,
          ),
          const SizedBox(width: 20),
          _buildAttachmentButton(
            context: context,
            icon: Icons.photo_library,
            label: "照片",
            onTap: onPhotoPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
