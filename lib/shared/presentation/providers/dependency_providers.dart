import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/services/database_service.dart';
import '../../infrastructure/services/preference_service.dart';
import '../../infrastructure/services/logger_service.dart';
import '../../data/database/database.dart';
import '../../../features/ai_management/data/repositories/provider_repository.dart';
import '../../../features/ai_management/data/repositories/assistant_repository.dart';
import '../../../features/ai_management/data/repositories/favorite_model_repository.dart';
import '../../../features/chat/data/repositories/conversation_repository.dart';
import '../../../features/chat/domain/repositories/message_repository.dart';
import '../../../features/chat/data/repositories/message_repository_impl.dart';
import '../../../features/chat/infrastructure/services/chat_error_handler.dart';

import '../../data/database/repositories/setting_repository.dart';
import '../../infrastructure/services/media/media_storage_service.dart';
import '../../infrastructure/services/message_id_service.dart';

/// 🗄️ 依赖注入Providers
///
/// 这个文件定义了应用中所有Repository的依赖注入Providers，
/// 遵循Riverpod最佳实践，避免直接访问单例服务。
///
/// ## 🎯 设计原则
/// - **依赖注入**: 通过Provider注入依赖，而不是直接访问单例
/// - **可测试性**: 便于单元测试时Mock依赖
/// - **解耦**: 减少组件间的直接依赖
/// - **一致性**: 统一的依赖管理方式

/// 数据库Provider - 单例模式
///
/// 提供应用的数据库实例，所有Repository都通过这个Provider获取数据库连接。
/// 这样可以确保数据库的单例性，同时支持测试时的Mock。
final databaseProvider = Provider<AppDatabase>((ref) {
  return DatabaseService.instance.database;
});

/// 偏好设置服务Provider - 单例模式
///
/// 提供应用的偏好设置服务实例，用于管理用户偏好和应用状态持久化。
/// 支持模型偏好、助手偏好、界面偏好等设置的存储和读取。
final preferenceServiceProvider = Provider<PreferenceService>((ref) {
  return PreferenceService();
});

/// 日志服务Provider - 单例模式
///
/// 提供应用的日志服务实例，用于统一的日志记录和调试。
/// 支持不同级别的日志输出和格式化。
final loggerServiceProvider = Provider<LoggerService>((ref) {
  return LoggerService();
});

/// 聊天错误处理器Provider - 单例模式
///
/// 提供聊天功能的错误处理服务，用于统一处理聊天相关的错误。
final chatErrorHandlerProvider = Provider<ChatErrorHandler>((ref) {
  return ChatErrorHandler();
});

/// AI提供商Repository Provider
///
/// 通过依赖注入获取数据库实例，创建ProviderRepository。
/// 替代直接在Notifier中创建Repository的方式。
final providerRepositoryProvider = Provider<ProviderRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return ProviderRepository(database);
});

/// AI助手Repository Provider
///
/// 通过依赖注入获取数据库实例，创建AssistantRepository。
final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return AssistantRepository(database);
});

/// 收藏模型Repository Provider
///
/// 通过依赖注入获取数据库实例，创建FavoriteModelRepository。
final favoriteModelRepositoryProvider =
    Provider<FavoriteModelRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return FavoriteModelRepository(database);
});

/// 对话Repository Provider
///
/// 通过依赖注入获取数据库实例，创建ConversationRepository。
final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final messageRepository = ref.watch(messageRepositoryProvider);
  return ConversationRepository(database, messageRepository);
});

/// 设置Repository Provider
///
/// 通过依赖注入获取数据库实例，创建SettingRepository。
final settingRepositoryProvider = Provider<SettingRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return SettingRepository(database);
});

/// 消息Repository Provider
///
/// 通过依赖注入获取数据库实例，创建MessageRepositoryImpl。
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return MessageRepositoryImpl(database);
});

/// 多媒体存储服务Provider
///
/// 提供多媒体文件的存储和管理服务。
final mediaStorageServiceProvider = Provider<MediaStorageService>((ref) {
  return MediaStorageService();
});

/// 消息ID服务Provider
///
/// 提供统一的消息ID生成和管理服务。
final messageIdServiceProvider = Provider<MessageIdService>((ref) {
  return MessageIdService();
});

// 注意：blockBasedChatServiceProvider 已在
// lib/shared/infrastructure/services/ai/providers/block_chat_provider.dart 中定义
// 请从该文件导入使用
