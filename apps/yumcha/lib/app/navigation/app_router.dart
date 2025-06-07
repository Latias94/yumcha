// 🧭 应用路由管理器
//
// YumCha 应用的核心路由管理系统，负责处理所有页面导航和路由配置。
// 提供统一的路由管理和导航功能，确保应用的导航体验一致性。
//
// 🎯 **主要功能**:
// - 🗺️ **路由定义**: 定义应用中所有页面的路由路径
// - 🔄 **路由生成**: 根据路由名称动态生成对应的页面
// - 📝 **参数传递**: 支持页面间的参数传递和数据共享
// - 🔍 **路由日志**: 记录路由导航的详细日志信息
// - 🛡️ **错误处理**: 处理未知路由和导航错误
// - 🚀 **导航方法**: 提供便捷的导航操作方法
//
// 🗺️ **支持的路由**:
// - **主页路由**: 应用主界面和聊天功能
// - **配置路由**: 各种设置和配置页面
// - **管理路由**: AI 助手和提供商管理
// - **编辑路由**: 创建和编辑功能页面
//
// 🔧 **路由特性**:
// - 支持命名路由和参数传递
// - 集成日志记录和调试信息
// - 提供多种导航模式（push、replace、clear）
// - 统一的错误页面处理
//
// 💡 **设计理念**:
// - 集中管理所有路由配置
// - 提供类型安全的导航方法
// - 支持复杂的页面参数传递
// - 便于维护和扩展

import 'package:flutter/material.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/settings/presentation/screens/quick_setup_screen.dart';
import '../../features/ai_management/presentation/screens/providers_screen.dart';
import '../../features/ai_management/presentation/screens/assistants_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/ai_management/presentation/screens/provider_edit_screen.dart';
import '../../features/ai_management/presentation/screens/assistant_edit_screen.dart';
import '../../features/chat/presentation/screens/chat_display_settings_screen.dart';
import '../../features/ai_management/domain/entities/ai_provider.dart';
import '../../features/ai_management/domain/entities/ai_assistant.dart';
import '../../features/chat/domain/entities/conversation_ui_state.dart';
import 'main_navigation.dart';
import '../../shared/infrastructure/services/logger_service.dart';

/// 应用路由管理器
///
/// 负责管理 YumCha 应用的所有路由配置和导航逻辑。
/// 提供统一的路由管理接口和便捷的导航方法。
class AppRouter {
  /// 路由名称常量定义
  ///
  /// 定义应用中所有页面的路由路径，确保路由名称的一致性。
  /// 使用常量避免拼写错误和便于维护。

  /// 主页路由 - 应用的主界面，包含聊天功能和侧边栏
  static const String home = '/';

  /// 聊天页面路由 - 独立的聊天界面
  static const String chat = '/chat';

  /// 配置管理路由 - 配置管理中心
  static const String config = '/config';

  /// AI 提供商管理路由 - 管理所有 AI 服务提供商
  static const String providers = '/providers';

  /// AI 提供商编辑路由 - 创建和编辑提供商配置
  static const String providerEdit = '/provider-edit';

  /// AI 助手管理路由 - 管理所有 AI 助手
  static const String assistants = '/assistants';

  /// AI 助手编辑路由 - 创建和编辑助手配置
  static const String assistantEdit = '/assistant-edit';

  /// 应用设置路由 - 主要的应用设置界面
  static const String settings = '/settings';

  /// 聊天样式设置路由 - 聊天界面样式配置
  static const String chatStyleSettings = '/chat-style-settings';

  /// 路由生成器
  ///
  /// 根据路由设置生成对应的页面路由。
  /// 这是 Flutter 路由系统的核心方法，负责将路由名称映射到具体的页面。
  ///
  /// **参数说明**:
  /// - [settings]: 路由设置，包含路由名称和传递的参数
  ///
  /// **返回值**:
  /// - 返回对应的 MaterialPageRoute 或错误页面路由
  ///
  /// **支持的参数类型**:
  /// - `Map<String, dynamic>`: 通用参数映射
  /// - 具体的模型对象: AiProvider、AiAssistant、ConversationUiState 等
  ///
  /// **日志记录**:
  /// - 记录所有路由生成的详细信息
  /// - 便于调试和问题排查
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final logger = LoggerService();

    logger.info('AppRouter.generateRoute 被调用', {
      'routeName': settings.name,
      'arguments': settings.arguments,
    });

    switch (settings.name) {
      case home:
        final args = settings.arguments as Map<String, dynamic>?;
        final conversationId = args?['conversationId'] as String?;
        final messageId = args?['messageId'] as String?;

        logger.info('生成主页路由', {
          'conversationId': conversationId,
          'messageId': messageId,
        });

        return MaterialPageRoute(
          builder: (_) => MainNavigation(
            initialConversationId: conversationId,
            initialMessageId: messageId,
          ),
          settings: settings,
        );

      case chat:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationState:
                args?['conversationState'] as ConversationUiState,
            showAppBar: args?['showAppBar'] as bool? ?? true,
            onAssistantConfigChanged: args?['onAssistantConfigChanged'],
            onConversationUpdated: args?['onConversationUpdated'],
          ),
          settings: settings,
        );

      case config:
        return MaterialPageRoute(
          builder: (_) => const ConfigScreen(),
          settings: settings,
        );

      case providers:
        return MaterialPageRoute(
          builder: (_) => const ProvidersScreen(),
          settings: settings,
        );

      case providerEdit:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) =>
              ProviderEditScreen(provider: args?['provider'] as AiProvider?),
          settings: settings,
        );

      case assistants:
        return MaterialPageRoute(
          builder: (_) => const AssistantsScreen(),
          settings: settings,
        );

      case assistantEdit:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AssistantEditScreen(
            assistant: args?['assistant'] as AiAssistant?,
            providers: args?['providers'] as List<AiProvider>? ?? [],
          ),
          settings: settings,
        );

      case AppRouter.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      case chatStyleSettings:
        return MaterialPageRoute(
          builder: (_) => const DisplaySettingsScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('页面未找到')),
            body: const Center(child: Text('页面不存在')),
          ),
          settings: settings,
        );
    }
  }

  /// 导航到指定页面
  ///
  /// 将新页面推入导航栈，保留当前页面在栈中。
  /// 用户可以通过返回按钮或手势返回到上一页。
  ///
  /// **参数说明**:
  /// - [context]: 当前的构建上下文
  /// - [routeName]: 目标路由名称，使用 AppRouter 中定义的常量
  /// - [arguments]: 传递给目标页面的参数
  ///
  /// **返回值**:
  /// - 返回 Future，包含目标页面返回的结果
  ///
  /// **使用示例**:
  /// ```dart
  /// AppRouter.pushNamed(context, AppRouter.settings);
  /// ```
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  /// 替换当前页面
  ///
  /// 用新页面替换当前页面，当前页面将从导航栈中移除。
  /// 用户无法返回到被替换的页面。
  ///
  /// **参数说明**:
  /// - [context]: 当前的构建上下文
  /// - [routeName]: 目标路由名称
  /// - [arguments]: 传递给目标页面的参数
  /// - [result]: 返回给上一页的结果
  ///
  /// **使用场景**:
  /// - 登录后跳转到主页
  /// - 完成引导流程后进入应用
  /// - 重置当前页面状态
  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// 清空导航栈并导航到指定页面
  ///
  /// 清空所有导航历史，然后导航到指定页面。
  /// 用户无法返回到之前的任何页面。
  ///
  /// **参数说明**:
  /// - [context]: 当前的构建上下文
  /// - [routeName]: 目标路由名称
  /// - [arguments]: 传递给目标页面的参数
  /// - [predicate]: 决定保留哪些路由的条件函数，默认清空所有
  ///
  /// **使用场景**:
  /// - 退出登录返回登录页
  /// - 重置应用状态
  /// - 深度链接导航
  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// 返回上一页
  ///
  /// 从导航栈中弹出当前页面，返回到上一页。
  /// 可以传递结果给上一页。
  ///
  /// **参数说明**:
  /// - [context]: 当前的构建上下文
  /// - [result]: 返回给上一页的结果（可选）
  ///
  /// **使用示例**:
  /// ```dart
  /// AppRouter.pop(context, {'success': true});
  /// ```
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  /// 检查是否可以返回
  ///
  /// 检查当前导航栈是否有可以返回的页面。
  /// 用于控制返回按钮的显示状态。
  ///
  /// **参数说明**:
  /// - [context]: 当前的构建上下文
  ///
  /// **返回值**:
  /// - true: 可以返回上一页
  /// - false: 已经是根页面，无法返回
  ///
  /// **使用示例**:
  /// ```dart
  /// if (AppRouter.canPop(context)) {
  ///   // 显示返回按钮
  /// }
  /// ```
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }
}
