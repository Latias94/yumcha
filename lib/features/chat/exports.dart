/// 聊天功能导出文件
/// 
/// 这个文件统一导出聊天相关的所有功能，简化导入路径
library chat_exports;

// 领域层
export 'domain/entities/message.dart';
export 'domain/entities/conversation.dart';

// 数据层
export 'data/repositories/conversation_repository.dart';
export 'data/repositories/message_repository.dart';

// 表现层
export 'presentation/screens/chat_screen.dart';
export 'presentation/screens/chat_display_settings_screen.dart';
export 'presentation/providers/chat_notifier.dart';
