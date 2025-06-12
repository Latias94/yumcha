# NotificationService 使用指南

## 🎯 改进后的通知服务特性

### 新增功能
1. **智能重要性级别** - 根据操作重要性自动选择显示方式
2. **改进的关闭按钮** - 更大的点击区域，更好的用户体验
3. **Overlay 通知** - 解决模态窗口层级问题
4. **静默模式** - 减少不必要的用户干扰
5. **自动通知管理** - 避免通知重叠

## 📋 重要性级别说明

### NotificationImportance.low (低重要性)
- **默认行为**: 静默模式，不显示UI
- **使用场景**: 常规成功操作（保存、更新等）
- **持续时间**: 2秒

### NotificationImportance.medium (中等重要性)
- **默认行为**: 显示 SnackBar
- **使用场景**: 一般信息提示、警告
- **持续时间**: 4秒

### NotificationImportance.high (高重要性)
- **默认行为**: 显示 SnackBar，错误信息显示更长时间
- **使用场景**: 错误信息、重要警告
- **持续时间**: 6-8秒

### NotificationImportance.critical (关键重要性)
- **默认行为**: 使用 Overlay 显示在最顶层
- **使用场景**: 系统错误、关键操作失败
- **持续时间**: 10秒

## 🔧 使用示例

### 1. 基础用法（向后兼容）
```dart
// 原有的调用方式仍然有效
NotificationService().showSuccess('操作成功');
NotificationService().showError('操作失败');
```

### 2. 使用重要性级别
```dart
// 静默成功通知（推荐用于常规操作）
NotificationService().showSuccess(
  '数据已保存',
  importance: NotificationImportance.low, // 静默模式
);

// 重要的成功通知
NotificationService().showSuccess(
  '重要配置已更新',
  importance: NotificationImportance.medium, // 显示 SnackBar
);

// 关键错误通知（显示在模态窗口之上）
NotificationService().showError(
  '系统连接失败',
  importance: NotificationImportance.critical, // 使用 Overlay
);
```

### 3. 强制指定显示模式
```dart
// 在模态窗口中显示通知
NotificationService().showError(
  '验证失败',
  mode: NotificationMode.overlay, // 强制使用 Overlay
);

// 强制静默模式
NotificationService().showSuccess(
  '自动保存完成',
  mode: NotificationMode.silent, // 强制静默
);
```

### 4. 使用新的统一接口
```dart
NotificationService().showNotification(
  message: '自定义通知',
  type: NotificationType.info,
  importance: NotificationImportance.medium,
  mode: NotificationMode.snackBar,
  actionLabel: '查看详情',
  onActionPressed: () {
    // 处理操作
  },
);
```

## 🎨 最佳实践建议

### 成功通知
```dart
// ✅ 推荐：常规操作使用低重要性
NotificationService().showSuccess(
  '助手已保存',
  importance: NotificationImportance.low,
);

// ✅ 推荐：重要操作使用中等重要性
NotificationService().showSuccess(
  '配置已导入',
  importance: NotificationImportance.medium,
);
```

### 错误通知
```dart
// ✅ 推荐：一般错误使用高重要性
NotificationService().showError(
  '保存失败: 网络错误',
  importance: NotificationImportance.high,
);

// ✅ 推荐：系统级错误使用关键重要性
NotificationService().showError(
  '数据库连接失败',
  importance: NotificationImportance.critical,
);
```

### 在模态窗口中的通知
```dart
// ✅ 推荐：在对话框中显示错误
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    // ... 对话框内容
  ),
);

// 使用 overlay 模式确保通知显示在对话框之上
NotificationService().showError(
  '验证失败',
  mode: NotificationMode.overlay,
);
```

## 🔄 迁移指南

### 现有代码迁移
大部分现有代码无需修改，但建议根据操作重要性调整：

```dart
// 原代码
NotificationService().showSuccess('助手已删除');

// 建议改为
NotificationService().showSuccess(
  '助手已删除',
  importance: NotificationImportance.low, // 减少干扰
);
```

### 批量操作优化
```dart
// 对于频繁的操作，使用静默模式
for (final item in items) {
  await processItem(item);
  NotificationService().showSuccess(
    '处理完成: ${item.name}',
    importance: NotificationImportance.low, // 静默
  );
}

// 最后显示汇总信息
NotificationService().showSuccess(
  '批量处理完成，共处理 ${items.length} 项',
  importance: NotificationImportance.medium,
);
```

## 🛠️ 高级功能

### 清除所有通知
```dart
// 清除所有正在显示的通知
NotificationService().clearAllNotifications();
```

### 自定义持续时间
```dart
NotificationService().showNotification(
  message: '自定义通知',
  type: NotificationType.info,
  duration: const Duration(seconds: 15), // 自定义持续时间
);
```
