import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/message.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';
import '../../../../shared/infrastructure/services/notification_service.dart';
import '../../../../core/providers/message_operation_state_provider.dart';
import '../../../../core/providers/runtime_state_provider.dart';

/// 消息编辑对话框
///
/// 支持编辑用户消息和AI消息的内容
class MessageEditDialog extends ConsumerStatefulWidget {
  const MessageEditDialog({
    super.key,
    required this.message,
    required this.onSave,
  });

  /// 要编辑的消息
  final Message message;

  /// 保存回调
  final Function(String content) onSave;

  @override
  ConsumerState<MessageEditDialog> createState() => _MessageEditDialogState();
}

class _MessageEditDialogState extends ConsumerState<MessageEditDialog> {
  late final TextEditingController _contentController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.message.content);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  /// 保存编辑内容
  void _save() async {
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      NotificationService().showWarning('消息内容不能为空');
      return;
    }

    if (content == widget.message.content) {
      // 内容没有变化，直接关闭
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use the new message operation state management
      await ref
          .read(messageOperationStateProvider.notifier)
          .editMessage(widget.message.id, content);

      if (mounted) {
        Navigator.of(context).pop();
        // Success notification is handled by the service
      }
    } catch (e) {
      if (mounted) {
        NotificationService().showError('更新失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 构建按钮内容
  Widget _buildButtonContent(ThemeData theme) {
    return AnimatedSwitcher(
      duration: DesignConstants.animationFast,
      child: _isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onPrimary,
              ),
            )
          : const Text('保存'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUserMessage = widget.message.isFromUser;

    return AlertDialog(
      // ✅ 使用对话框标准圆角
      shape: RoundedRectangleBorder(
        borderRadius: DesignConstants.radiusL,
      ),
      // ✅ 使用对话框标准阴影
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      // ✅ 使用对话框标准内边距
      contentPadding: DesignConstants.dialogPadding,
      titlePadding: DesignConstants.dialogPadding.copyWith(bottom: 0),
      actionsPadding:
          DesignConstants.dialogPadding.copyWith(top: DesignConstants.spaceM),
      title: Row(
        children: [
          Icon(
            isUserMessage ? Icons.person : Icons.smart_toy,
            color: theme.colorScheme.primary,
            size: DesignConstants.iconSizeM,
          ),
          SizedBox(width: DesignConstants.spaceS),
          Expanded(
            child: Text(
              isUserMessage ? '编辑用户消息' : '编辑AI消息',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        // ✅ 响应式对话框宽度
        constraints: BoxConstraints(
          maxWidth: DesignConstants.getMaxContentWidth(context) * 0.9,
          minWidth: DesignConstants.isMobile(context) ? 280 : 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 提示信息
            AnimatedContainer(
              duration: DesignConstants.animationFast,
              padding: DesignConstants.paddingM,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: DesignConstants.radiusS,
                // ✅ 使用标准阴影
                boxShadow: DesignConstants.shadowXS(theme),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: DesignConstants.iconSizeS,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: DesignConstants.spaceS),
                  Expanded(
                    child: Text(
                      isUserMessage
                          ? '编辑用户消息后，相关的AI回复将被删除并重新生成'
                          : '编辑AI消息内容，修改后的内容将直接保存',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: DesignConstants.spaceL),

            // 内容编辑框
            TextField(
              controller: _contentController,
              maxLines: null,
              // ✅ 响应式行数
              minLines: DesignConstants.isMobile(context) ? 3 : 4,
              maxLength: 4000, // 添加字符限制
              decoration: InputDecoration(
                labelText: '消息内容',
                hintText: '请输入消息内容...',
                border: OutlineInputBorder(
                  borderRadius: DesignConstants.radiusM,
                  borderSide: BorderSide(
                    width: DesignConstants.borderWidthThin,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: DesignConstants.radiusM,
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: DesignConstants.borderWidthMedium,
                  ),
                ),
                alignLabelWithHint: true,
                // ✅ 使用语义化颜色
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLowest,
              ),
              textInputAction: TextInputAction.newline,
              // ✅ 响应式字体大小
              style: TextStyle(
                fontSize: DesignConstants.getResponsiveFontSize(context),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
      actions: [
        // ✅ 响应式按钮布局
        if (DesignConstants.isMobile(context))
          // 移动端：垂直布局
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                onPressed: _isLoading ? null : _save,
                child: _buildButtonContent(theme),
              ),
              SizedBox(height: DesignConstants.spaceS),
              TextButton(
                onPressed:
                    _isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
            ],
          )
        else
          // 桌面端：水平布局
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed:
                    _isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              SizedBox(width: DesignConstants.spaceM),
              FilledButton(
                onPressed: _isLoading ? null : _save,
                child: _buildButtonContent(theme),
              ),
            ],
          ),
      ],
    );
  }
}
