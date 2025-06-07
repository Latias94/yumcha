import 'package:flutter/material.dart';

/// 通知类型枚举
enum NotificationType { success, error, warning, info }

/// 通知服务
///
/// 提供统一的用户通知功能，支持多种通知样式和交互方式。
///
/// 主要功能：
/// - 📢 **SnackBar 通知**: 底部浮动通知，支持自动关闭
/// - 🎨 **主题适配**: 自动适配 Material 3 主题颜色
/// - 🔔 **多种类型**: 成功、错误、警告、信息四种通知类型
/// - 💬 **确认对话框**: 支持用户确认操作的对话框
/// - 📋 **底部通知卡片**: 更丰富的通知展示方式
/// - ⚙️ **自定义操作**: 支持自定义操作按钮和回调
///
/// 设计特点：
/// - 使用 Material 3 设计规范
/// - 支持动态颜色和主题切换
/// - 提供一致的用户体验
/// - 自动处理通知的显示和隐藏
///
/// 使用场景：
/// - 操作成功/失败反馈
/// - 错误信息提示
/// - 用户确认操作
/// - 重要信息通知
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // 显示SnackBar通知
  void showSnackBar({
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = true,
  }) {
    final context = scaffoldMessengerKey.currentContext;
    if (context == null) return;

    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case NotificationType.success:
        backgroundColor = colorScheme.primaryContainer;
        textColor = colorScheme.onPrimaryContainer;
        icon = Icons.check_circle_outline;
        break;
      case NotificationType.error:
        backgroundColor = colorScheme.errorContainer;
        textColor = colorScheme.onErrorContainer;
        icon = Icons.error_outline;
        break;
      case NotificationType.warning:
        backgroundColor = colorScheme.tertiaryContainer;
        textColor = colorScheme.onTertiaryContainer;
        icon = Icons.warning_amber_outlined;
        break;
      case NotificationType.info:
        backgroundColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurface;
        icon = Icons.info_outline;
        break;
    }

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showCloseButton) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.close, color: textColor, size: 16),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 40), // 降低底部间距从80到40
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // 增加圆角
        ),
        elevation: 6, // 增加阴影
        action: actionLabel != null && onActionPressed != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: textColor,
                onPressed: onActionPressed,
              )
            : null,
      ),
    );
  }

  // 显示成功消息
  void showSuccess(
    String message, {
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = true,
  }) {
    showSnackBar(
      message: message,
      type: NotificationType.success,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      showCloseButton: showCloseButton,
    );
  }

  // 显示错误消息
  void showError(
    String message, {
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = true,
  }) {
    showSnackBar(
      message: message,
      type: NotificationType.error,
      duration: const Duration(seconds: 6),
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      showCloseButton: showCloseButton,
    );
  }

  // 显示警告消息
  void showWarning(
    String message, {
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = true,
  }) {
    showSnackBar(
      message: message,
      type: NotificationType.warning,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      showCloseButton: showCloseButton,
    );
  }

  // 显示信息消息
  void showInfo(
    String message, {
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = true,
  }) {
    showSnackBar(
      message: message,
      type: NotificationType.info,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      showCloseButton: showCloseButton,
    );
  }

  // 显示对话框
  Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = '确认',
    String cancelText = '取消',
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // 显示底部通知卡片
  void showBottomNotification({
    required BuildContext context,
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 5),
    List<Widget>? actions,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case NotificationType.success:
        backgroundColor = colorScheme.primaryContainer;
        textColor = colorScheme.onPrimaryContainer;
        icon = Icons.check_circle_outline;
        break;
      case NotificationType.error:
        backgroundColor = colorScheme.errorContainer;
        textColor = colorScheme.onErrorContainer;
        icon = Icons.error_outline;
        break;
      case NotificationType.warning:
        backgroundColor = colorScheme.tertiaryContainer;
        textColor = colorScheme.onTertiaryContainer;
        icon = Icons.warning_amber_outlined;
        break;
      case NotificationType.info:
        backgroundColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurface;
        icon = Icons.info_outline;
        break;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: textColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: textColor, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: textColor),
            ),
            if (actions != null) ...[
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
            ],
          ],
        ),
      ),
    );

    // 自动关闭
    Future.delayed(duration, () {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}
