/// YumCha 应用主导出文件
/// 
/// 这个文件是整个应用的统一导出入口，提供最常用的导入路径
/// 使用方式：import 'package:yumcha/exports.dart';
library yumcha_exports;

// 核心功能
export 'core/exports.dart';

// 共享功能
export 'shared/exports.dart';

// 功能模块
export 'features/ai_management/exports.dart';
export 'features/chat/exports.dart';
export 'features/settings/exports.dart';

// 应用层
export 'app/navigation/app_router.dart';
export 'app/theme/app_theme.dart';
