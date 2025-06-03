import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';
import '../screens/config_screen.dart';
import '../screens/providers_screen.dart';
import '../screens/assistants_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/provider_edit_screen.dart';
import '../screens/assistant_edit_screen.dart';
import '../screens/chat_style_settings_screen.dart';
import '../models/ai_provider.dart';
import '../models/ai_assistant.dart';
import '../models/conversation_ui_state.dart';
import '../navigation/main_navigation.dart';
import '../services/logger_service.dart';

/// 应用路由管理
class AppRouter {
  // 路由名称常量
  static const String home = '/';
  static const String chat = '/chat';
  static const String config = '/config';
  static const String providers = '/providers';
  static const String providerEdit = '/provider-edit';
  static const String assistants = '/assistants';
  static const String assistantEdit = '/assistant-edit';
  static const String settings = '/settings';
  static const String chatStyleSettings = '/chat-style-settings';

  /// 生成路由
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
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  /// 替换当前页面
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

  /// 清空栈并导航到指定页面
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
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  /// 检查是否可以返回
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }
}
