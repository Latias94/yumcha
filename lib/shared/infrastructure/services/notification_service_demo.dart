import 'package:flutter/material.dart';
import 'notification_service.dart';

/// 通知服务演示页面
///
/// 用于测试和演示改进后的通知服务功能
class NotificationServiceDemo extends StatelessWidget {
  const NotificationServiceDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知服务演示'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '重要性级别测试',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 低重要性（静默）
            ElevatedButton(
              onPressed: () {
                NotificationService().showSuccess(
                  '数据已保存（静默模式）',
                  importance: NotificationImportance.low,
                );
              },
              child: const Text('低重要性成功通知（静默）'),
            ),

            // 中等重要性
            ElevatedButton(
              onPressed: () {
                NotificationService().showSuccess(
                  '配置已更新',
                  importance: NotificationImportance.medium,
                );
              },
              child: const Text('中等重要性成功通知'),
            ),

            // 高重要性错误
            ElevatedButton(
              onPressed: () {
                NotificationService().showError(
                  '网络连接失败',
                  importance: NotificationImportance.high,
                );
              },
              child: const Text('高重要性错误通知'),
            ),

            // 关键重要性（Overlay）
            ElevatedButton(
              onPressed: () {
                NotificationService().showError(
                  '系统错误：数据库连接失败',
                  importance: NotificationImportance.critical,
                );
              },
              child: const Text('关键重要性错误通知（Overlay）'),
            ),

            const SizedBox(height: 24),
            const Text(
              '模态窗口测试',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 模态窗口中的通知测试
            ElevatedButton(
              onPressed: () {
                _showModalWithNotification(context);
              },
              child: const Text('测试模态窗口中的通知'),
            ),

            const SizedBox(height: 24),
            const Text(
              '其他功能测试',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 清除所有通知
            ElevatedButton(
              onPressed: () {
                NotificationService().clearAllNotifications();
              },
              child: const Text('清除所有通知'),
            ),

            // 批量通知测试
            ElevatedButton(
              onPressed: () {
                _showBatchNotifications();
              },
              child: const Text('批量通知测试'),
            ),
          ],
        ),
      ),
    );
  }

  void _showModalWithNotification(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('模态窗口'),
        content: const Text('这是一个模态窗口，点击按钮测试通知显示层级。'),
        actions: [
          TextButton(
            onPressed: () {
              // 使用 SnackBar 模式（会被模态窗口遮挡）
              NotificationService().showError(
                '这个通知会被模态窗口遮挡',
                mode: NotificationMode.snackBar,
              );
            },
            child: const Text('SnackBar 通知'),
          ),
          TextButton(
            onPressed: () {
              // 使用 Overlay 模式（显示在模态窗口之上）
              NotificationService().showError(
                '这个通知显示在模态窗口之上',
                mode: NotificationMode.overlay,
              );
            },
            child: const Text('Overlay 通知'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showBatchNotifications() {
    // 模拟批量操作
    final items = ['项目A', '项目B', '项目C'];

    for (int i = 0; i < items.length; i++) {
      Future.delayed(Duration(milliseconds: i * 500), () {
        NotificationService().showSuccess(
          '处理完成: ${items[i]}',
          importance: NotificationImportance.low, // 使用静默模式
        );
      });
    }

    // 最后显示汇总
    Future.delayed(Duration(milliseconds: items.length * 500), () {
      NotificationService().showSuccess(
        '批量处理完成，共处理 ${items.length} 项',
        importance: NotificationImportance.medium,
      );
    });
  }
}
