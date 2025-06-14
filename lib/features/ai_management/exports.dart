/// AI 管理功能导出文件
///
/// 这个文件统一导出 AI 管理相关的所有功能，简化导入路径
library;

// 领域层
export 'domain/entities/ai_provider.dart';
export 'domain/entities/ai_assistant.dart';
export 'domain/entities/ai_model.dart';
export 'domain/entities/provider_model_config.dart';
export 'domain/usecases/configure_provider_usecase.dart';

// 数据层
export 'data/repositories/provider_repository.dart';
export 'data/repositories/assistant_repository.dart';
export 'data/models/openai_config.dart';

// 表现层
export 'presentation/providers/unified_ai_management_notifier.dart';
export 'presentation/providers/configuration_management_providers.dart';
export 'presentation/screens/providers_screen.dart';
export 'presentation/screens/assistants_screen.dart';
export 'presentation/screens/provider_edit_screen.dart';
export 'presentation/screens/assistant_edit_screen.dart';
export 'presentation/screens/ai_settings_screen.dart';
export 'presentation/screens/configuration_management_screen.dart';
