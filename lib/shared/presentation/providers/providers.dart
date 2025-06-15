/// 导出所有 Riverpod Providers
///
/// 这个文件汇总了应用中所有的状态管理 Providers，
/// 方便在其他地方导入和使用。
///
/// ⚠️ **重要提醒**：
/// - 优先使用新的统一AI管理Provider
/// - 旧的Provider已标记为@Deprecated，将在下个版本删除
/// - 聊天功能请使用 unified_chat_notifier.dart 中的Provider
library;

// ✅ 旧的AI管理Provider已删除 - 已完全迁移到新的统一AI管理系统
// 所有AI管理功能现在通过统一Provider提供

// ✅ 新的统一AI管理Provider - 推荐使用
export '../../../features/ai_management/presentation/providers/unified_ai_management_notifier.dart';
export '../../../features/ai_management/presentation/providers/unified_ai_management_providers.dart';

// ✅ 兼容性Provider已清理 - 请使用统一聊天系统
// 所有聊天功能现在通过 unified_chat_notifier.dart 提供

// ⚠️ 过时的聊天状态Provider - 不导出，避免冲突
// export '../../../features/chat/presentation/providers/unified_chat_state_notifier.dart';

// ✅ AI服务Provider
export '../../infrastructure/services/ai/providers/ai_service_provider.dart'
    hide modelCapabilitiesProvider;
export '../../infrastructure/services/ai/ai_service_manager.dart'
    hide aiServiceStatsProvider;
