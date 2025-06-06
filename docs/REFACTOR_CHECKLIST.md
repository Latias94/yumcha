# ✅ YumCha 重构执行清单

基于发现的具体问题，制定详细的重构执行清单。按优先级和风险级别组织，确保重构过程可控和可追踪。

## 🚨 立即执行（高优先级，低风险）

### 阶段 1：文件重命名和清理

#### 1.1 重命名混淆的屏幕文件
- [ ] `chat_style_settings_screen.dart` → `chat_display_settings_screen.dart`
- [ ] `ai_debug_screen.dart` → `ai_api_test_screen.dart`
- [ ] `debug_screen.dart` → `ai_debug_logs_screen.dart`
- [ ] `config_screen.dart` → `quick_setup_screen.dart`

**执行命令**:
```bash
git mv lib/screens/chat_style_settings_screen.dart lib/screens/chat_display_settings_screen.dart
git mv lib/screens/ai_debug_screen.dart lib/screens/ai_api_test_screen.dart
git mv lib/screens/debug_screen.dart lib/screens/ai_debug_logs_screen.dart
git mv lib/screens/config_screen.dart lib/screens/quick_setup_screen.dart
```

**需要更新的文件**:
- [ ] `lib/navigation/app_router.dart` - 更新路由常量和生成逻辑
- [ ] `lib/screens/settings_screen.dart` - 更新导入语句
- [ ] 其他引用这些文件的地方

#### 1.2 合并重复的组件目录
- [ ] 将 `lib/widgets/` 内容移动到 `lib/components/`
- [ ] 删除空的 `lib/widgets/` 目录
- [ ] 更新所有相关的 import 语句

**执行命令**:
```bash
# 移动文件
mv lib/widgets/* lib/components/
rmdir lib/widgets

# 更新 import 语句
find lib -name "*.dart" -exec sed -i.bak 's|../widgets/|../components/|g' {} \;
find lib -name "*.dart" -exec sed -i.bak 's|widgets/|components/|g' {} \;
```

#### 1.3 标记废弃的 AI 服务文件
- [ ] 在 `lib/services/ai_service.dart` 添加 `@deprecated` 注释
- [ ] 在 `lib/services/ai_request_service.dart` 添加 `@deprecated` 注释
- [ ] 在 `lib/services/ai_service_new.dart` 添加 `@deprecated` 注释
- [ ] 在 `lib/services/ai_dart_service.dart` 添加 `@deprecated` 注释
- [ ] 创建迁移指南文档

**示例注释**:
```dart
/// @deprecated 此文件已废弃，请使用 lib/services/ai/ 目录下的新架构
/// 迁移指南：参考 MIGRATION_GUIDE.md
@deprecated
class AiService {
  // 现有代码...
}
```

### 阶段 2：代码规范统一

#### 2.1 统一 import 语句顺序
- [ ] 检查所有 `.dart` 文件的 import 顺序
- [ ] 按规范重新排序：Dart 核心库 → Flutter 库 → 第三方包 → 项目内部
- [ ] 运行 `dart format` 格式化所有代码

#### 2.2 添加文件头注释
- [ ] 为所有主要文件添加统一的头注释格式
- [ ] 包含功能描述、主要特性、使用场景等信息

#### 2.3 统一错误处理
- [ ] 检查所有异常处理代码
- [ ] 确保使用统一的错误处理模式
- [ ] 替换 `print` 语句为 `LoggerService`

## 🔄 中期执行（中优先级，中风险）

### 阶段 3：目录结构重组

#### 3.1 创建新的目录结构
- [ ] 创建 `lib/core/` 目录及子目录
- [ ] 创建 `lib/shared/` 目录及子目录
- [ ] 创建 `lib/features/` 目录及子目录
- [ ] 创建 `lib/app/` 目录及子目录

**执行命令**:
```bash
mkdir -p lib/core/{constants,exceptions,extensions,utils,types}
mkdir -p lib/shared/{data,domain,presentation,infrastructure}
mkdir -p lib/features/{chat,ai_management,settings,search,debug}
mkdir -p lib/app/{navigation,theme,config}
```

#### 3.2 移动聊天相关文件
- [ ] `screens/chat_screen.dart` → `features/chat/presentation/screens/`
- [ ] `screens/chat_search_screen.dart` → `features/chat/presentation/screens/`
- [ ] `screens/chat_display_settings_screen.dart` → `features/chat/presentation/screens/`
- [ ] `ui/chat/` → `features/chat/presentation/widgets/`
- [ ] `providers/chat_*.dart` → `features/chat/presentation/providers/`

#### 3.3 移动 AI 管理相关文件
- [ ] `screens/assistants_screen.dart` → `features/ai_management/presentation/screens/`
- [ ] `screens/assistant_edit_screen.dart` → `features/ai_management/presentation/screens/`
- [ ] `screens/providers_screen.dart` → `features/ai_management/presentation/screens/`
- [ ] `screens/provider_edit_screen.dart` → `features/ai_management/presentation/screens/`
- [ ] `providers/ai_*.dart` → `features/ai_management/presentation/providers/`

#### 3.4 移动设置相关文件
- [ ] `screens/settings_screen.dart` → `features/settings/presentation/screens/`
- [ ] `screens/default_models_screen.dart` → `features/settings/presentation/screens/`
- [ ] `screens/mcp_settings_screen.dart` → `features/settings/presentation/screens/`
- [ ] `providers/settings_notifier.dart` → `features/settings/presentation/providers/`
- [ ] `providers/theme_provider.dart` → `features/settings/presentation/providers/`

#### 3.5 移动共享资源
- [ ] `data/` → `shared/data/database/`
- [ ] `models/` → `shared/domain/entities/`
- [ ] `services/` → `shared/infrastructure/services/`
- [ ] `navigation/` → `app/navigation/`

### 阶段 4：代码重构

#### 4.1 创建模块导出文件
- [ ] 创建 `features/chat/chat_module.dart`
- [ ] 创建 `features/ai_management/ai_management_module.dart`
- [ ] 创建 `features/settings/settings_module.dart`
- [ ] 创建 `shared/shared_module.dart`

#### 4.2 更新所有 import 语句
- [ ] 使用脚本批量更新 import 语句
- [ ] 手动检查和修复复杂的引用关系
- [ ] 确保所有文件都能正确编译

#### 4.3 更新路由配置
- [ ] 更新 `app_router.dart` 中的所有路由路径
- [ ] 测试所有页面导航功能
- [ ] 确保深度链接正常工作

## 🚀 长期执行（低优先级，高收益）

### 阶段 5：架构升级

#### 5.1 建立插件系统
- [ ] 创建 `lib/plugins/` 目录结构
- [ ] 定义插件接口
- [ ] 创建插件注册系统
- [ ] 迁移现有功能到插件架构

#### 5.2 国际化支持
- [ ] 创建 `lib/l10n/` 目录
- [ ] 配置 Flutter 国际化
- [ ] 提取所有硬编码字符串
- [ ] 创建多语言资源文件

#### 5.3 平台特定代码
- [ ] 创建 `lib/platform/` 目录
- [ ] 实现平台适配层
- [ ] 分离平台特定功能
- [ ] 优化不同平台的用户体验

## 📋 验证清单

### 每个阶段完成后检查

#### 编译检查
- [ ] `flutter clean && flutter pub get`
- [ ] `flutter build apk --debug` 成功
- [ ] `dart analyze` 无错误
- [ ] `dart format --set-exit-if-changed lib/` 通过

#### 功能检查
- [ ] 应用正常启动
- [ ] 所有主要功能正常工作
- [ ] 页面导航正常
- [ ] 状态管理正常

#### 代码质量检查
- [ ] 文件命名符合规范
- [ ] 目录结构正确
- [ ] Import 语句规范
- [ ] 注释完整准确

#### 测试检查
- [ ] 单元测试通过
- [ ] 集成测试通过
- [ ] 手动测试主要功能

## 🔧 自动化脚本

### 重构脚本模板
```bash
#!/bin/bash
# refactor_phase_1.sh

set -e  # 遇到错误立即退出

echo "🚀 开始阶段1重构：文件重命名和清理"

# 1. 重命名屏幕文件
echo "📝 重命名屏幕文件..."
git mv lib/screens/chat_style_settings_screen.dart lib/screens/chat_display_settings_screen.dart
git mv lib/screens/ai_debug_screen.dart lib/screens/ai_api_test_screen.dart
git mv lib/screens/debug_screen.dart lib/screens/ai_debug_logs_screen.dart
git mv lib/screens/config_screen.dart lib/screens/quick_setup_screen.dart

# 2. 更新 import 语句
echo "🔄 更新 import 语句..."
find lib -name "*.dart" -exec sed -i.bak 's/chat_style_settings_screen\.dart/chat_display_settings_screen.dart/g' {} \;
find lib -name "*.dart" -exec sed -i.bak 's/ai_debug_screen\.dart/ai_api_test_screen.dart/g' {} \;
find lib -name "*.dart" -exec sed -i.bak 's/debug_screen\.dart/ai_debug_logs_screen.dart/g' {} \;
find lib -name "*.dart" -exec sed -i.bak 's/config_screen\.dart/quick_setup_screen.dart/g' {} \;

# 3. 合并组件目录
echo "📁 合并组件目录..."
if [ -d "lib/widgets" ]; then
    mv lib/widgets/* lib/components/ 2>/dev/null || true
    rmdir lib/widgets 2>/dev/null || true
fi

# 4. 更新组件 import
find lib -name "*.dart" -exec sed -i.bak 's|../widgets/|../components/|g' {} \;
find lib -name "*.dart" -exec sed -i.bak 's|widgets/|components/|g' {} \;

# 5. 清理备份文件
find lib -name "*.bak" -delete

# 6. 格式化代码
echo "🎨 格式化代码..."
dart format lib/

# 7. 检查编译
echo "✅ 检查编译..."
flutter clean
flutter pub get
dart analyze

echo "🎉 阶段1重构完成！"
```

## ⚠️ 风险控制

### 重构前准备
- [ ] 创建重构分支：`git checkout -b refactor/project-structure`
- [ ] 备份当前代码：`git tag backup-before-refactor`
- [ ] 确保所有测试通过
- [ ] 通知团队成员重构计划

### 重构过程中
- [ ] 每个阶段完成后立即提交
- [ ] 详细记录每次变更
- [ ] 遇到问题立即停止并分析
- [ ] 保持与团队的沟通

### 重构后验证
- [ ] 完整的功能测试
- [ ] 性能对比测试
- [ ] 代码质量检查
- [ ] 团队代码审查

---

> 💡 **执行建议**: 严格按照阶段顺序执行，每个阶段完成后都要进行充分的验证。如果遇到问题，可以回滚到上一个稳定状态。

> 🚨 **重要提醒**: 重构是一个渐进的过程，不要试图一次性完成所有改动。保持耐心，确保每一步都是稳定和可验证的。
