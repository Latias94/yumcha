import 'package:flutter/material.dart';

/// 通知类型枚举
enum NotificationType { success, error, warning, info }

/// 通知重要性级别
enum NotificationImportance {
  /// 低重要性 - 静默通知，不显示 SnackBar
  low,

  /// 中等重要性 - 显示简短的 SnackBar
  medium,

  /// 高重要性 - 显示完整的 SnackBar 带操作按钮
  high,

  /// 关键重要性 - 使用 Overlay 确保在所有内容之上显示
  critical,
}

/// 通知显示模式
enum NotificationMode {
  /// SnackBar 模式（默认）
  snackBar,

  /// Overlay 模式（显示在最顶层）
  overlay,

  /// 静默模式（不显示UI，仅记录日志）
  silent,
}

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
/// - 🎯 **智能重要性**: 根据重要性级别选择合适的显示方式
/// - 🔝 **Overlay 支持**: 关键通知可显示在模态窗口之上
/// - 🔇 **静默模式**: 支持静默通知，减少干扰
///
/// 设计特点：
/// - 使用 Material 3 设计规范
/// - 支持动态颜色和主题切换
/// - 提供一致的用户体验
/// - 自动处理通知的显示和隐藏
/// - 智能通知策略，减少用户干扰
///
/// 使用场景：
/// - 操作成功/失败反馈
/// - 错误信息提示
/// - 用户确认操作
/// - 重要信息通知
///
/// 最佳实践：
/// - 成功操作使用 low 或 medium 重要性
/// - 错误信息使用 high 或 critical 重要性
/// - 在模态窗口中的通知使用 overlay 模式
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Overlay 相关
  OverlayEntry? _currentOverlayEntry;

  // 通知队列管理（预留功能）
  // final List<String> _notificationQueue = [];
  // bool _isShowingNotification = false;

  // 显示通知（智能选择显示方式）
  void showNotification({
    required String message,
    NotificationType type = NotificationType.info,
    NotificationImportance importance = NotificationImportance.medium,
    NotificationMode? mode,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = true,
  }) {
    // 根据重要性自动选择模式
    final effectiveMode = mode ?? _getDefaultModeForImportance(importance);

    // 根据重要性自动选择持续时间
    final effectiveDuration =
        duration ?? _getDefaultDurationForImportance(importance, type);

    switch (effectiveMode) {
      case NotificationMode.snackBar:
        _showSnackBar(
          message: message,
          type: type,
          importance: importance,
          duration: effectiveDuration,
          actionLabel: actionLabel,
          onActionPressed: onActionPressed,
          showCloseButton: showCloseButton,
        );
        break;
      case NotificationMode.overlay:
        _showOverlayNotification(
          message: message,
          type: type,
          importance: importance,
          duration: effectiveDuration,
          actionLabel: actionLabel,
          onActionPressed: onActionPressed,
          showCloseButton: showCloseButton,
        );
        break;
      case NotificationMode.silent:
        // 静默模式，仅记录日志（可以在这里集成日志服务）
        // 这里可以集成 LoggerService 或其他日志框架
        // LoggerService().debug('Silent notification', {'type': type.name, 'message': message});
        break;
    }
  }

  // 显示SnackBar通知（保持向后兼容）
  void showSnackBar({
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = true,
  }) {
    _showSnackBar(
      message: message,
      type: type,
      importance: NotificationImportance.medium,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      showCloseButton: showCloseButton,
    );
  }

  // 内部 SnackBar 实现
  void _showSnackBar({
    required String message,
    required NotificationType type,
    required NotificationImportance importance,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = true,
  }) {
    final context = scaffoldMessengerKey.currentContext;
    if (context == null) return;

    final colorScheme = Theme.of(context).colorScheme;

    final (backgroundColor, textColor, icon) =
        _getNotificationColors(colorScheme, type);

    // 清除之前的通知以避免重叠
    scaffoldMessengerKey.currentState?.clearSnackBars();

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
              // 改进的关闭按钮 - 更大的点击区域
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8), // 增大点击区域
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.close, color: textColor, size: 16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: importance == NotificationImportance.critical ? 12 : 6,
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
    NotificationImportance importance = NotificationImportance.low, // 默认低重要性
    NotificationMode? mode,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = true,
  }) {
    showNotification(
      message: message,
      type: NotificationType.success,
      importance: importance,
      mode: mode,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      showCloseButton: showCloseButton,
    );
  }

  // 显示错误消息
  void showError(
    String message, {
    NotificationImportance importance = NotificationImportance.high, // 默认高重要性
    NotificationMode? mode,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = true,
  }) {
    showNotification(
      message: message,
      type: NotificationType.error,
      importance: importance,
      mode: mode,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      showCloseButton: showCloseButton,
    );
  }

  // 显示警告消息
  void showWarning(
    String message, {
    NotificationImportance importance =
        NotificationImportance.medium, // 默认中等重要性
    NotificationMode? mode,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = true,
  }) {
    showNotification(
      message: message,
      type: NotificationType.warning,
      importance: importance,
      mode: mode,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      showCloseButton: showCloseButton,
    );
  }

  // 显示信息消息
  void showInfo(
    String message, {
    NotificationImportance importance =
        NotificationImportance.medium, // 默认中等重要性
    NotificationMode? mode,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = true,
  }) {
    showNotification(
      message: message,
      type: NotificationType.info,
      importance: importance,
      mode: mode,
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

  // 辅助方法：根据重要性获取默认模式
  NotificationMode _getDefaultModeForImportance(
      NotificationImportance importance) {
    switch (importance) {
      case NotificationImportance.low:
        return NotificationMode.silent; // 低重要性使用静默模式
      case NotificationImportance.medium:
        return NotificationMode.snackBar;
      case NotificationImportance.high:
        return NotificationMode.snackBar;
      case NotificationImportance.critical:
        return NotificationMode.overlay; // 关键重要性使用 overlay
    }
  }

  // 辅助方法：根据重要性和类型获取默认持续时间
  Duration _getDefaultDurationForImportance(
    NotificationImportance importance,
    NotificationType type,
  ) {
    switch (importance) {
      case NotificationImportance.low:
        return const Duration(seconds: 2); // 短时间
      case NotificationImportance.medium:
        return const Duration(seconds: 4); // 中等时间
      case NotificationImportance.high:
        return type == NotificationType.error
            ? const Duration(seconds: 8) // 错误信息显示更长时间
            : const Duration(seconds: 6);
      case NotificationImportance.critical:
        return const Duration(seconds: 10); // 关键信息显示最长时间
    }
  }

  // 辅助方法：获取通知颜色
  (Color backgroundColor, Color textColor, IconData icon)
      _getNotificationColors(
    ColorScheme colorScheme,
    NotificationType type,
  ) {
    switch (type) {
      case NotificationType.success:
        return (
          colorScheme.primaryContainer,
          colorScheme.onPrimaryContainer,
          Icons.check_circle_outline,
        );
      case NotificationType.error:
        return (
          colorScheme.errorContainer,
          colorScheme.onErrorContainer,
          Icons.error_outline,
        );
      case NotificationType.warning:
        return (
          colorScheme.tertiaryContainer,
          colorScheme.onTertiaryContainer,
          Icons.warning_amber_outlined,
        );
      case NotificationType.info:
        return (
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurface,
          Icons.info_outline,
        );
    }
  }

  // Overlay 通知实现
  void _showOverlayNotification({
    required String message,
    required NotificationType type,
    required NotificationImportance importance,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = true,
  }) {
    final context = scaffoldMessengerKey.currentContext;
    if (context == null) return;

    // 清除之前的 overlay 通知
    _currentOverlayEntry?.remove();

    final colorScheme = Theme.of(context).colorScheme;
    final (backgroundColor, textColor, icon) =
        _getNotificationColors(colorScheme, type);

    _currentOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          elevation: 12,
          borderRadius: BorderRadius.circular(12),
          color: backgroundColor,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: textColor, size: 24),
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
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        _currentOverlayEntry?.remove();
                        _currentOverlayEntry = null;
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.close, color: textColor, size: 20),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_currentOverlayEntry!);

    // 自动移除
    Future.delayed(duration, () {
      _currentOverlayEntry?.remove();
      _currentOverlayEntry = null;
    });
  }

  // 清除所有通知
  void clearAllNotifications() {
    scaffoldMessengerKey.currentState?.clearSnackBars();
    _currentOverlayEntry?.remove();
    _currentOverlayEntry = null;
  }
}
