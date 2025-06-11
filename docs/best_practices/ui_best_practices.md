# 🎨 UI 最佳实践指南

本文档总结了 YumCha 应用的 UI 设计最佳实践，确保整个应用的视觉一致性和用户体验的统一性。

## 📋 目录

- [设计系统](#设计系统)
- [Material Design 3 规范](#material-design-3-规范)
- [组件设计原则](#组件设计原则)
- [响应式设计](#响应式设计)
- [动画与交互](#动画与交互)
- [主题与颜色](#主题与颜色)
- [代码组织](#代码组织)

## 🎯 设计系统

### 设计常量统一管理

**位置**: `lib/shared/presentation/design_system/design_constants.dart`

所有设计相关的常量都应该在此文件中定义，包括：

```dart
// ✅ 推荐做法
Container(
  padding: DesignConstants.paddingM,
  decoration: BoxDecoration(
    borderRadius: DesignConstants.radiusM,
    boxShadow: DesignConstants.shadowS(theme),
  ),
)

// ❌ 避免做法
Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(...)],
  ),
)
```

### 设计规范层次

#### 圆角半径规范
- `radiusXS` (4px) - 小型元素，如标签
- `radiusS` (8px) - 按钮、输入框内部元素
- `radiusM` (12px) - 卡片、容器
- `radiusL` (16px) - 对话框、底部面板
- `radiusXL` (20px) - 大型容器
- `radiusXXL` (24px) - 输入框、主要按钮

#### 间距规范
- `spaceXS` (4px) - 紧密元素间距
- `spaceS` (8px) - 相关元素间距
- `spaceM` (12px) - 组件内部间距
- `spaceL` (16px) - 组件间距
- `spaceXL` (20px) - 区块间距
- `spaceXXL` (24px) - 页面边距
- `spaceXXXL` (32px) - 大区块间距

#### 阴影层次
- `shadowNone` - 无阴影
- `shadowXS` - 极轻微阴影，用于悬停状态
- `shadowS` - 轻微阴影，用于卡片
- `shadowM` - 中等阴影，用于浮动元素
- `shadowL` - 明显阴影，用于模态框
- `shadowXL` - 强阴影，用于重要提示

## 🎨 Material Design 3 规范

### 颜色系统

使用 Material 3 的动态颜色系统：

```dart
// ✅ 推荐做法 - 使用语义化颜色
Container(
  color: theme.colorScheme.primaryContainer,
  child: Text(
    'Primary content',
    style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
  ),
)

// ❌ 避免做法 - 硬编码颜色
Container(
  color: Colors.blue[100],
  child: Text('Content', style: TextStyle(color: Colors.blue[900])),
)
```

### 主题扩展

使用主题扩展方法简化常用装饰：

```dart
// ✅ 推荐做法
Container(decoration: theme.cardDecoration)

// ✅ 推荐做法
TextField(decoration: InputDecoration.collapsed(
  hintText: 'Input...',
).copyWith(
  filled: true,
  fillColor: theme.colorScheme.surfaceContainerHighest,
))
```

## 🧩 组件设计原则

### 1. 一致性原则

所有相似功能的组件应该使用相同的设计模式：

```dart
// ✅ 所有按钮使用统一尺寸
Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
  return Container(
    width: DesignConstants.buttonHeightM,
    height: DesignConstants.buttonHeightM,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: DesignConstants.shadowS(theme),
    ),
    child: IconButton(
      icon: Icon(icon, size: DesignConstants.iconSizeM),
      onPressed: onPressed,
    ),
  );
}
```

### 2. 状态反馈原则

为用户交互提供清晰的视觉反馈：

```dart
// ✅ 推荐做法 - 明确的状态区分
Container(
  decoration: _focusNode.hasFocus
      ? theme.inputFocusDecoration
      : theme.inputDecoration,
)

// ✅ 加载状态指示
if (widget.isLoading)
  AiThinkingIndicator(
    isStreaming: widget.isStreaming,
    message: widget.isStreaming ? '正在接收回复...' : 'AI正在思考中...',
  )
```

### 3. 可访问性原则

确保所有交互元素都有适当的提示和尺寸：

```dart
// ✅ 推荐做法
IconButton(
  icon: Icon(Icons.send),
  onPressed: _handleSend,
  tooltip: '发送消息', // 提供工具提示
)

// ✅ 确保最小触摸目标尺寸
Container(
  width: DesignConstants.buttonHeightM, // 至少 40px
  height: DesignConstants.buttonHeightM,
)
```

## 📱 响应式设计

### 断点使用

```dart
// ✅ 推荐做法 - 使用设计系统的断点方法
Widget build(BuildContext context) {
  return Padding(
    padding: DesignConstants.responsivePadding(context),
    child: Column(
      children: [
        if (DesignConstants.isDesktop(context))
          DesktopSpecificWidget(),
        if (DesignConstants.isMobile(context))
          MobileSpecificWidget(),
      ],
    ),
  );
}
```

### 自适应布局

```dart
// ✅ 推荐做法 - 响应式间距
EdgeInsets.symmetric(
  horizontal: DesignConstants.isDesktop(context)
      ? DesignConstants.spaceXXL
      : DesignConstants.spaceL,
)

// ✅ 响应式文本行数
TextField(
  maxLines: DesignConstants.isDesktop(context) ? 5 : 4,
)
```

## 🎬 动画与交互

### 动画时长规范

```dart
// ✅ 推荐做法 - 使用标准动画时长
AnimatedContainer(
  duration: DesignConstants.animationNormal, // 250ms
  curve: Curves.easeInOut,
)

// 快速反馈动画
AnimatedOpacity(
  duration: DesignConstants.animationFast, // 150ms
)

// 复杂转场动画
PageRouteBuilder(
  transitionDuration: DesignConstants.animationSlow, // 400ms
)
```

### 交互反馈

```dart
// ✅ 推荐做法 - 渐进式反馈
AnimatedBuilder(
  animation: _pulseAnimation,
  builder: (context, child) {
    return Transform.scale(
      scale: _pulseAnimation.value,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: DesignConstants.shadowGlow(
            theme,
            theme.colorScheme.primary,
          ),
        ),
      ),
    );
  },
)
```

## 🎨 主题与颜色

### 主题适配

```dart
// ✅ 推荐做法 - 智能主题适配
Color _getBackgroundColor(ThemeData theme) {
  final brightness = theme.brightness;
  if (brightness == Brightness.light) {
    return theme.colorScheme.surfaceContainerLowest;
  } else {
    return theme.colorScheme.surfaceContainerLow;
  }
}
```

### 透明度使用

```dart
// ✅ 推荐做法 - 使用语义化透明度
Container(
  color: theme.colorScheme.primary.withValues(
    alpha: DesignConstants.opacityHigh, // 0.8
  ),
)
```

## 📁 代码组织

### 文件结构

```text
lib/
├── shared/
│   └── presentation/
│       ├── design_system/
│       │   ├── design_constants.dart     # 设计常量
│       │   ├── theme_extensions.dart     # 主题扩展
│       │   └── component_styles.dart     # 组件样式
│       └── widgets/
│           ├── common/                   # 通用组件
│           └── specialized/              # 专用组件
└── features/
    └── [feature]/
        └── presentation/
            ├── screens/
            └── widgets/                  # 功能特定组件
```

### 组件命名规范

```dart
// ✅ 推荐做法 - 清晰的命名
class AiThinkingIndicator extends StatefulWidget
class ChatMessageView extends ConsumerStatefulWidget
class ModelSelectorButton extends StatelessWidget

// 私有方法命名
Widget _buildInputField(ThemeData theme, bool isEditing)
Widget _buildActionButtons(ThemeData theme, bool isEditing)
void _handleSendMessage()
```

### 样式分离

```dart
// ✅ 推荐做法 - 将复杂样式提取为方法
class ChatInput extends StatefulWidget {

  BoxDecoration _getInputDecoration(ThemeData theme, bool hasFocus) {
    return hasFocus ? theme.inputFocusDecoration : theme.inputDecoration;
  }

  Widget _buildStyledButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color? backgroundColor,
  }) {
    return Container(
      width: DesignConstants.buttonHeightM,
      height: DesignConstants.buttonHeightM,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: DesignConstants.shadowS(theme),
      ),
      child: IconButton(
        icon: Icon(icon, size: DesignConstants.iconSizeM),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}
```

## � 聊天界面特定最佳实践

### AppBar 设计

```dart
// ✅ 推荐做法 - 双行信息显示
AppBar(
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      // 主标题 - 应用名称
      Text('YumCha', style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      )),
      // 副标题 - 当前助手信息
      Row(
        children: [
          Text(assistant.avatar, style: TextStyle(fontSize: 14)),
          SizedBox(width: DesignConstants.spaceXS),
          Flexible(child: Text(assistant.name)),
          SizedBox(width: DesignConstants.spaceS),
          // 模型信息标签
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: DesignConstants.spaceXS,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
              borderRadius: DesignConstants.radiusS,
            ),
            child: Text(providerId, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    ],
  ),
)
```

### AI 状态指示

```dart
// ✅ 推荐做法 - 区分流式和非流式状态
if (isLoading)
  AiThinkingIndicator(
    isStreaming: isStreaming,
    message: isStreaming ? '正在接收回复...' : 'AI正在思考中...',
  )
```

### 输入框状态反馈

```dart
// ✅ 推荐做法 - 加载状态的视觉反馈
TextField(
  decoration: InputDecoration(
    hintText: _getInputHintText(isEditing),
    hintStyle: TextStyle(
      color: widget.isLoading
          ? theme.colorScheme.primary.withValues(alpha: 0.7)
          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      fontStyle: widget.isLoading ? FontStyle.italic : FontStyle.normal,
    ),
    prefixIcon: widget.isLoading ? _buildLoadingIndicator() : null,
  ),
)
```

### 空状态设计

```dart
// ✅ 推荐做法 - 友好的空状态
Widget _buildEmptyState(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 渐变图标
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.8),
                theme.colorScheme.secondary.withValues(alpha: 0.6),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: DesignConstants.shadowGlow(theme, theme.colorScheme.primary),
          ),
          child: Icon(Icons.auto_awesome, size: 40),
        ),
        SizedBox(height: DesignConstants.spaceXXL),
        Text('开始新的对话', style: theme.textTheme.headlineSmall),
        SizedBox(height: DesignConstants.spaceM),
        Text('在下方输入消息开始与AI助手对话\n体验智能、流畅的AI交互'),
        SizedBox(height: DesignConstants.spaceXXXL),
        // 功能提示卡片
        _buildFeatureTipsCard(),
      ],
    ),
  );
}
```

## 📱💻 跨平台适配最佳实践

### 响应式断点策略

```dart
// ✅ 推荐做法 - 使用设计系统的断点判断
Widget build(BuildContext context) {
  final isMobile = DesignConstants.isMobile(context);
  final isTablet = DesignConstants.isTablet(context);
  final isDesktop = DesignConstants.isDesktop(context);

  return Scaffold(
    body: isMobile
        ? _buildMobileLayout()
        : isTablet
            ? _buildTabletLayout()
            : _buildDesktopLayout(),
  );
}
```

### 移动端优化

```dart
// ✅ 移动端特定优化
class MobileChatOptimizations {
  // 触摸友好的按钮尺寸
  static const double minTouchTarget = 44.0;

  // 移动端输入框配置
  Widget buildMobileInput() {
    return TextField(
      maxLines: 4, // 移动端限制行数
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      // 移动端特定的内边距
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignConstants.spaceL,
          vertical: DesignConstants.spaceM,
        ),
      ),
    );
  }

  // 移动端消息气泡最大宽度
  static double getMaxBubbleWidth(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.85;
  }
}
```

### 桌面端优化

```dart
// ✅ 桌面端特定优化
class DesktopChatOptimizations {
  // 桌面端输入框配置
  Widget buildDesktopInput() {
    return TextField(
      maxLines: 5, // 桌面端允许更多行数
      minLines: 1,
      // 桌面端支持快捷键
      onSubmitted: (text) => _handleSubmit(text),
      // 桌面端更大的内边距
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignConstants.spaceXL,
          vertical: DesignConstants.spaceL,
        ),
        // 桌面端显示快捷键提示
        helperText: 'Enter 发送，Shift+Enter 换行',
      ),
    );
  }

  // 桌面端消息气泡最大宽度
  static double getMaxBubbleWidth(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.7;
  }

  // 桌面端侧边栏支持
  Widget buildDesktopLayout() {
    return Row(
      children: [
        // 可选的侧边栏
        if (_showSidebar)
          Container(
            width: 300,
            child: _buildSidebar(),
          ),
        // 主聊天区域
        Expanded(child: _buildChatArea()),
      ],
    );
  }
}
```

### 平板端适配

```dart
// ✅ 平板端特定优化
class TabletChatOptimizations {
  // 平板端布局 - 介于移动端和桌面端之间
  Widget buildTabletLayout() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceXXL,
        vertical: DesignConstants.spaceL,
      ),
      child: Column(
        children: [
          // 平板端可以显示更多信息
          _buildEnhancedAppBar(),
          Expanded(child: _buildChatArea()),
          _buildTabletInputArea(),
        ],
      ),
    );
  }

  // 平板端输入区域
  Widget buildTabletInputArea() {
    return Container(
      constraints: BoxConstraints(maxWidth: 800), // 限制最大宽度
      child: _buildInputField(),
    );
  }
}
```

### 自适应间距和尺寸

```dart
// ✅ 推荐做法 - 自适应尺寸计算
class AdaptiveSpacing {
  static EdgeInsets getMessagePadding(BuildContext context) {
    if (DesignConstants.isMobile(context)) {
      return EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceL,
        vertical: DesignConstants.spaceS,
      );
    } else if (DesignConstants.isTablet(context)) {
      return EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceXL,
        vertical: DesignConstants.spaceM,
      );
    } else {
      return EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceXXL,
        vertical: DesignConstants.spaceL,
      );
    }
  }

  static double getMessageFontSize(BuildContext context) {
    if (DesignConstants.isMobile(context)) {
      return 14.0;
    } else if (DesignConstants.isTablet(context)) {
      return 15.0;
    } else {
      return 16.0;
    }
  }
}
```

### 键盘和输入适配

```dart
// ✅ 推荐做法 - 键盘适配
class KeyboardAdaptation {
  // 移动端键盘弹出时的处理
  Widget buildWithKeyboardPadding({required Widget child}) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 自动调整避开键盘
      body: child,
    );
  }

  // 桌面端快捷键支持
  Widget buildWithShortcuts({required Widget child}) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.enter): SendMessageIntent(),
        LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.enter):
            NewLineIntent(),
      },
      child: Actions(
        actions: {
          SendMessageIntent: CallbackAction<SendMessageIntent>(
            onInvoke: (intent) => _handleSendMessage(),
          ),
          NewLineIntent: CallbackAction<NewLineIntent>(
            onInvoke: (intent) => _handleNewLine(),
          ),
        },
        child: child,
      ),
    );
  }
}
```

### 平台特定UI组件

```dart
// ✅ 推荐做法 - 平台适配组件
class PlatformAdaptiveButton extends StatelessWidget {
  const PlatformAdaptiveButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    if (DesignConstants.isMobile(context)) {
      // 移动端使用更大的触摸目标
      return Container(
        constraints: BoxConstraints(
          minWidth: DesignConstants.buttonHeightL,
          minHeight: DesignConstants.buttonHeightL,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          child: child,
        ),
      );
    } else {
      // 桌面端可以使用更紧凑的按钮
      return Tooltip(
        message: tooltip ?? '',
        child: ElevatedButton(
          onPressed: onPressed,
          child: child,
        ),
      );
    }
  }
}
```

## 🔍 代码审查检查清单

在提交 UI 相关代码前，请检查：

### 基础设计规范

- [ ] 是否使用了 `DesignConstants` 中的常量而非硬编码值
- [ ] 是否遵循了 Material 3 的颜色系统
- [ ] 是否为交互元素提供了适当的反馈
- [ ] 是否使用了语义化的命名
- [ ] 动画时长是否合理且一致
- [ ] 是否适配了深色/浅色主题

### 响应式设计

- [ ] 是否考虑了响应式设计
- [ ] 是否在移动端、平板端、桌面端都进行了测试
- [ ] 触摸目标是否满足最小尺寸要求（44px）
- [ ] 是否考虑了键盘弹出对布局的影响
- [ ] 文本大小是否在不同设备上合适

### 聊天界面特定

- [ ] 聊天界面是否提供了清晰的状态反馈
- [ ] AI响应状态是否有适当的视觉指示
- [ ] 消息气泡宽度是否在不同屏幕尺寸下合适
- [ ] 输入框是否根据平台优化（行数、快捷键等）

### 无障碍性

- [ ] 是否提供了无障碍支持（tooltip、语义标签等）
- [ ] 颜色对比度是否符合要求
- [ ] 是否支持屏幕阅读器
- [ ] 键盘导航是否完整

## 📚 参考资源

- [Material Design 3 Guidelines](https://m3.material.io/)
- [Flutter Material 3 Documentation](https://docs.flutter.dev/ui/design/material)
- [Accessibility Guidelines](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)

---

*本文档会随着应用的发展持续更新，请定期查看最新版本。*
