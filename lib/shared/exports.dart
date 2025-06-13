/// 共享功能导出文件
///
/// 这个文件统一导出所有共享功能，简化导入路径
library;

// 数据层
export 'data/database/database.dart';
export 'data/database/converters.dart';

// 基础设施层
export 'infrastructure/services/validation_service.dart';
export 'infrastructure/services/logger_service.dart';

// AI 服务
export 'infrastructure/services/ai/ai_service_manager.dart';
export 'infrastructure/services/ai/providers/ai_service_provider.dart'
    hide aiChatServiceStatsProvider;
export 'infrastructure/services/ai/core/ai_response_models.dart';
export 'infrastructure/services/ai/core/ai_service_base.dart';

// 表现层
export 'presentation/providers/providers.dart';
export 'presentation/providers/conversation_notifier.dart';
