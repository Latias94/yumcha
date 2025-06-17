/// 统一的气泡系统导出文件
///
/// 提供所有气泡相关组件和工具的统一入口

import 'bubble_block_renderer.dart';

// 核心组件
export 'message_bubble.dart';
export 'bubble_content.dart';

// 配置和样式
export 'bubble_style.dart';
export 'bubble_theme.dart';
export 'bubble_layout.dart';
export 'bubble_animation.dart';

// 上下文和工具
export 'bubble_context.dart';
export 'bubble_size.dart';
export 'bubble_decoration.dart';

// 渲染系统
export 'bubble_block_renderer.dart';

// 适配器
export 'adapters/bubble_block_adapter.dart';
export 'adapters/text_bubble_adapter.dart';
export 'adapters/code_bubble_adapter.dart';
export 'adapters/thinking_bubble_adapter.dart';
export 'adapters/image_bubble_adapter.dart';
export 'adapters/tool_call_bubble_adapter.dart';
export 'adapters/file_bubble_adapter.dart';
export 'adapters/error_bubble_adapter.dart';
export 'adapters/quote_bubble_adapter.dart';

/// 气泡系统初始化器
///
/// 负责初始化整个气泡系统
class BubbleSystem {
  BubbleSystem._();

  static bool _initialized = false;

  /// 初始化气泡系统
  static void initialize() {
    if (_initialized) return;

    // 初始化块渲染器
    BubbleBlockRenderer.instance.initialize();

    _initialized = true;
  }

  /// 检查是否已初始化
  static bool get isInitialized => _initialized;

  /// 清理气泡系统
  static void dispose() {
    if (!_initialized) return;

    BubbleBlockRenderer.instance.dispose();
    _initialized = false;
  }

  /// 获取系统信息
  static Map<String, dynamic> getSystemInfo() {
    return {
      'initialized': _initialized,
      'renderer': BubbleBlockRenderer.instance.getAdapterStats(),
    };
  }
}
