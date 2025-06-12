import 'package:flutter/material.dart';
import 'attachment_manager.dart';
import '../../../../../shared/presentation/design_system/design_constants.dart';

/// 附件标签栏组件
class AttachmentChips extends StatelessWidget {
  const AttachmentChips({
    super.key,
    required this.state,
    required this.onToggleExpanded,
    required this.onRemoveAttachment,
    required this.onPreviewAttachment,
    this.maxVisibleChips = 3,
  });

  final AttachmentManagerState state;
  final VoidCallback onToggleExpanded;
  final void Function(String attachmentId) onRemoveAttachment;
  final void Function(AttachmentItem attachment) onPreviewAttachment;
  final int maxVisibleChips;

  @override
  Widget build(BuildContext context) {
    if (!state.hasAttachments) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDesktop = DesignConstants.isDesktop(context);

    return Container(
      padding: DesignConstants.responsiveHorizontalPadding(context).copyWith(
        top: DesignConstants.spaceS,
        bottom: DesignConstants.spaceS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 附件标签行
          _buildChipsRow(theme, isDesktop),

          // 展开的附件面板
          if (state.isExpanded) ...[
            SizedBox(height: DesignConstants.spaceS),
            _buildExpandedPanel(theme, isDesktop),
          ],
        ],
      ),
    );
  }

  Widget _buildChipsRow(ThemeData theme, bool isDesktop) {
    final visibleAttachments = state.attachments.take(maxVisibleChips).toList();
    final hasMore = state.attachments.length > maxVisibleChips;

    return Wrap(
      spacing: DesignConstants.spaceS,
      runSpacing: DesignConstants.spaceXS,
      children: [
        // 显示前几个附件的标签
        ...visibleAttachments.map((attachment) => _buildAttachmentChip(
              attachment,
              theme,
              isDesktop,
            )),

        // 更多按钮或总数标签
        if (hasMore || state.attachments.length > 1)
          _buildMoreChip(theme, isDesktop, hasMore),
      ],
    );
  }

  Widget _buildAttachmentChip(
    AttachmentItem attachment,
    ThemeData theme,
    bool isDesktop,
  ) {
    final color = Color(attachment.type.colorValue);

    return Material(
      color: color.withValues(alpha: DesignConstants.opacityMedium * 0.15),
      borderRadius: DesignConstants.radiusM,
      elevation: 0,
      child: InkWell(
        borderRadius: DesignConstants.radiusM,
        onTap: () => onPreviewAttachment(attachment),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignConstants.spaceS,
            vertical: DesignConstants.spaceXS,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 文件类型图标
              Container(
                width: isDesktop ? 20 : 18,
                height: isDesktop ? 20 : 18,
                decoration: BoxDecoration(
                  color: color.withValues(
                      alpha: DesignConstants.opacityMedium * 0.25),
                  borderRadius: DesignConstants.radiusS,
                ),
                child: Center(
                  child: Text(
                    attachment.type.icon,
                    style: TextStyle(fontSize: isDesktop ? 12 : 10),
                  ),
                ),
              ),

              SizedBox(width: DesignConstants.spaceXS),

              // 文件名
              Flexible(
                child: Text(
                  _truncateFileName(attachment.fileName, isDesktop ? 20 : 15),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              SizedBox(width: DesignConstants.spaceXS),

              // 删除按钮
              GestureDetector(
                onTap: () => onRemoveAttachment(attachment.id),
                child: Container(
                  width: isDesktop ? 16 : 14,
                  height: isDesktop ? 16 : 14,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: DesignConstants.opacityHigh),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: isDesktop ? 12 : 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreChip(ThemeData theme, bool isDesktop, bool hasMore) {
    final totalCount = state.attachments.length;
    final text =
        hasMore ? '+${totalCount - maxVisibleChips} 更多' : '$totalCount 个附件';

    return Material(
      color: theme.colorScheme.surfaceContainerHighest
          .withValues(alpha: DesignConstants.opacityHigh),
      borderRadius: DesignConstants.radiusM,
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        borderRadius: DesignConstants.radiusM,
        onTap: onToggleExpanded,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignConstants.spaceS,
            vertical: DesignConstants.spaceXS,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                state.isExpanded ? Icons.expand_less : Icons.expand_more,
                size: isDesktop ? 18 : 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: DesignConstants.spaceXS),
              Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedPanel(ThemeData theme, bool isDesktop) {
    return Container(
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: DesignConstants.opacityMedium * 0.8),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.outline
              .withValues(alpha: DesignConstants.opacityMedium * 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Text(
                '附件列表',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${state.count} 个文件 • ${state.formattedTotalSize}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          SizedBox(height: DesignConstants.spaceS),

          // 附件列表
          ...state.attachments.map((attachment) => _buildAttachmentListItem(
                attachment,
                theme,
                isDesktop,
              )),
        ],
      ),
    );
  }

  Widget _buildAttachmentListItem(
    AttachmentItem attachment,
    ThemeData theme,
    bool isDesktop,
  ) {
    final color = Color(attachment.type.colorValue);

    return Container(
      margin: EdgeInsets.only(bottom: DesignConstants.spaceXS),
      child: Material(
        color: Colors.transparent,
        borderRadius: DesignConstants.radiusS,
        child: InkWell(
          borderRadius: DesignConstants.radiusS,
          onTap: () => onPreviewAttachment(attachment),
          child: Padding(
            padding: DesignConstants.paddingS,
            child: Row(
              children: [
                // 文件图标
                Container(
                  width: isDesktop ? 32 : 28,
                  height: isDesktop ? 32 : 28,
                  decoration: BoxDecoration(
                    color: color.withValues(
                        alpha: DesignConstants.opacityMedium * 0.2),
                    borderRadius: DesignConstants.radiusS,
                  ),
                  child: Center(
                    child: Text(
                      attachment.type.icon,
                      style: TextStyle(fontSize: isDesktop ? 16 : 14),
                    ),
                  ),
                ),

                SizedBox(width: DesignConstants.spaceS),

                // 文件信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment.fileName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${attachment.type.displayName} • ${attachment.formattedSize}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // 操作按钮
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => onPreviewAttachment(attachment),
                      icon: Icon(
                        Icons.visibility,
                        size: isDesktop ? 20 : 18,
                      ),
                      tooltip: '预览',
                    ),
                    IconButton(
                      onPressed: () => onRemoveAttachment(attachment.id),
                      icon: Icon(
                        Icons.delete_outline,
                        size: isDesktop ? 20 : 18,
                        color: theme.colorScheme.error,
                      ),
                      tooltip: '移除',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _truncateFileName(String fileName, int maxLength) {
    if (fileName.length <= maxLength) return fileName;

    final parts = fileName.split('.');
    if (parts.length > 1) {
      final name = parts.sublist(0, parts.length - 1).join('.');
      final extension = parts.last;
      final maxNameLength = maxLength - extension.length - 1;

      if (maxNameLength > 3) {
        return '${name.substring(0, maxNameLength)}...$extension';
      }
    }

    return '${fileName.substring(0, maxLength - 3)}...';
  }
}
