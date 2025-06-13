import 'package:flutter/material.dart';
import '../../../../../shared/presentation/design_system/design_constants.dart';

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
      margin: DesignConstants.responsiveHorizontalPadding(context).copyWith(
        top: 0,
        bottom: DesignConstants.spaceS,
      ),
      padding: DesignConstants.paddingL,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: DesignConstants.radiusM,
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
          SizedBox(width: DesignConstants.spaceXL),
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
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: DesignConstants.radiusM,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: DesignConstants.spaceM,
          horizontal: DesignConstants.spaceL,
        ),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
          borderRadius: DesignConstants.radiusM,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: DesignConstants.iconSizeXL,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
            SizedBox(height: DesignConstants.spaceS),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
