# 📋 YumCha 项目开发规范

为确保代码质量、团队协作效率和项目可维护性，制定以下开发规范。所有团队成员（包括 AI 代码生成）都必须遵循这些规范。

## 🏗️ 目录结构规范

### 顶层架构
```
lib/
├── core/                    # 🎯 核心基础设施（不依赖业务逻辑）
├── shared/                  # 🎯 共享组件（跨功能模块使用）
├── features/                # 🎯 功能模块（按业务领域组织）
├── app/                     # 🎯 应用层（启动、配置、导航）
├── l10n/                    # 🌐 国际化资源
├── plugins/                 # 🔌 插件系统（可选）
└── main.dart               # 应用入口
```

### 功能模块结构（features/）
```
features/{feature_name}/
├── data/                    # 数据层
│   ├── models/             # 数据模型（JSON 序列化）
│   ├── repositories/       # 仓库实现
│   └── datasources/        # 数据源（本地/远程）
├── domain/                  # 领域层
│   ├── entities/           # 业务实体
│   ├── repositories/       # 仓库接口
│   └── usecases/           # 用例（业务逻辑）
├── presentation/            # 表现层
│   ├── screens/            # 页面
│   ├── widgets/            # 组件
│   ├── providers/          # 状态管理
│   └── controllers/        # 控制器
└── {feature_name}_module.dart  # 模块导出文件
```

### 共享层结构（shared/）
```
shared/
├── data/                    # 共享数据层
│   ├── database/           # 数据库相关
│   ├── models/             # 通用数据模型
│   └── repositories/       # 通用仓库
├── domain/                  # 共享领域层
│   ├── entities/           # 通用业务实体
│   └── value_objects/      # 值对象
├── presentation/            # 共享表现层
│   ├── widgets/            # 通用组件
│   ├── themes/             # 主题相关
│   └── providers/          # 通用状态管理
└── infrastructure/          # 基础设施层
    ├── services/           # 服务实现
    ├── network/            # 网络层
    └── storage/            # 存储层
```

## 📝 文件命名规范

### 通用规则
- 使用 `snake_case` 命名法
- 文件名应该清晰描述其功能
- 避免缩写，使用完整单词
- 相关文件使用一致的前缀

### 具体规范

#### 屏幕文件（Screens）
```
{feature}_{purpose}_screen.dart

示例：
✅ chat_screen.dart
✅ chat_search_screen.dart  
✅ chat_display_settings_screen.dart
✅ ai_api_test_screen.dart
✅ ai_debug_logs_screen.dart

❌ chat_style_settings_screen.dart  # 不够具体
❌ debug_screen.dart                # 太模糊
❌ config_screen.dart               # 不够描述性
```

#### 组件文件（Widgets）
```
{purpose}_{type}.dart

示例：
✅ message_bubble_widget.dart
✅ chat_input_widget.dart
✅ model_selection_dialog.dart
✅ provider_list_widget.dart

❌ widget.dart                      # 太模糊
❌ component.dart                   # 不够具体
```

#### 服务文件（Services）
```
{domain}_service.dart

示例：
✅ chat_service.dart
✅ model_service.dart
✅ embedding_service.dart
✅ notification_service.dart

❌ ai_service.dart                  # 太宽泛
❌ service.dart                     # 太模糊
```

#### 状态管理文件（Providers/Notifiers）
```
{domain}_{type}.dart

示例：
✅ chat_provider.dart
✅ ai_assistant_notifier.dart
✅ conversation_notifier.dart
✅ theme_provider.dart

❌ providers.dart                   # 太模糊
❌ notifier.dart                    # 不够具体
```

#### 模型文件（Models/Entities）
```
{entity_name}.dart

示例：
✅ ai_assistant.dart
✅ ai_provider.dart
✅ chat_message.dart
✅ user_profile.dart

❌ model.dart                       # 太模糊
❌ data.dart                        # 不够具体
```

## 🎯 代码组织规范

### Import 语句顺序
```dart
// 1. Dart 核心库
import 'dart:async';
import 'dart:convert';

// 2. Flutter 库
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. 第三方包（按字母顺序）
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// 4. 项目内部导入（按层级顺序）
import '../../../core/constants/app_constants.dart';
import '../../../shared/domain/entities/base_entity.dart';
import '../../domain/entities/chat_message.dart';
import '../widgets/message_bubble_widget.dart';
```

### 文件头注释规范
```dart
// 🎯 {功能描述}
//
// {详细说明文件的用途和主要功能}
// 
// 🎯 **主要功能**:
// - 📝 **功能1**: 功能1的描述
// - 🔄 **功能2**: 功能2的描述
// - ⚙️ **功能3**: 功能3的描述
//
// 📱 **使用场景**:
// - 场景1描述
// - 场景2描述
//
// 🔧 **技术特点**:
// - 技术特点1
// - 技术特点2

import 'package:flutter/material.dart';
// ... 其他 imports

class ExampleWidget extends StatelessWidget {
  // 类实现
}
```

### 类和方法注释规范
```dart
/// 类的简要描述
/// 
/// 详细描述类的用途、职责和使用方式。
/// 
/// **主要功能**:
/// - 功能1描述
/// - 功能2描述
/// 
/// **使用示例**:
/// ```dart
/// final example = ExampleClass();
/// await example.doSomething();
/// ```
class ExampleClass {
  
  /// 方法的简要描述
  /// 
  /// **参数说明**:
  /// - [param1]: 参数1的描述
  /// - [param2]: 参数2的描述
  /// 
  /// **返回值**:
  /// - 返回值的描述
  /// 
  /// **异常**:
  /// - [ExceptionType]: 异常情况描述
  Future<String> exampleMethod(String param1, int param2) async {
    // 方法实现
  }
}
```

## 🔧 技术规范

### 状态管理规范
```dart
// ✅ 使用 Riverpod 进行状态管理
final exampleProvider = StateNotifierProvider<ExampleNotifier, ExampleState>(
  (ref) => ExampleNotifier(),
);

// ✅ 状态类使用 @immutable
@immutable
class ExampleState {
  final String data;
  final bool isLoading;
  final String? error;
  
  const ExampleState({
    required this.data,
    this.isLoading = false,
    this.error,
  });
  
  // ✅ 提供 copyWith 方法
  ExampleState copyWith({
    String? data,
    bool? isLoading,
    String? error,
  }) {
    return ExampleState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// ❌ 避免直接访问 Repository
// 错误示例：
class BadService {
  final Repository _repository = Repository();  // ❌
}

// ✅ 正确示例：通过 Riverpod 注入
class GoodService {
  Future<void> doSomething(WidgetRef ref) async {
    final repository = ref.read(repositoryProvider);  // ✅
  }
}
```

### 错误处理规范
```dart
// ✅ 使用统一的异常类型
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, [this.code]);
}

class NetworkException extends AppException {
  const NetworkException(String message) : super(message, 'NETWORK_ERROR');
}

// ✅ 统一的错误处理模式
Future<Result<T>> safeCall<T>(Future<T> Function() operation) async {
  try {
    final result = await operation();
    return Success(result);
  } on AppException catch (e) {
    return Failure(e);
  } catch (e) {
    return Failure(UnknownException(e.toString()));
  }
}
```

### 日志记录规范
```dart
// ✅ 使用统一的日志服务
final logger = LoggerService();

// ✅ 结构化日志
logger.info('用户登录', {
  'userId': userId,
  'timestamp': DateTime.now().toIso8601String(),
  'platform': Platform.operatingSystem,
});

// ✅ 错误日志包含上下文
logger.error('API 调用失败', {
  'endpoint': '/api/chat',
  'statusCode': response.statusCode,
  'error': error.toString(),
});

// ❌ 避免使用 print
print('Debug message');  // ❌

// ✅ 使用日志服务
logger.debug('Debug message');  // ✅
```

## 🚫 禁止事项

### 代码组织禁止
```dart
// ❌ 禁止直接访问数据库或 Repository
class BadWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = DatabaseService.instance.database;  // ❌
    final repository = ProviderRepository();             // ❌
    return Container();
  }
}

// ❌ 禁止在 UI 层写业务逻辑
class BadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // ❌ 业务逻辑不应该在 UI 层
        final result = complexBusinessLogic();
        if (result.isSuccess) {
          // 更多业务逻辑...
        }
      },
      child: Text('Button'),
    );
  }
}

// ❌ 禁止硬编码字符串
Text('聊天')  // ❌

// ✅ 使用国际化
Text(context.l10n.chat)  // ✅
```

### 文件组织禁止
```dart
// ❌ 禁止创建重复功能的文件
lib/services/
├── ai_service.dart          // ❌ 与下面功能重复
├── ai_request_service.dart  // ❌ 与上面功能重复
└── ai_service_new.dart      // ❌ 又是重复

// ❌ 禁止模糊的文件名
├── utils.dart               // ❌ 太模糊
├── helpers.dart             // ❌ 不够具体
├── common.dart              // ❌ 太宽泛
└── stuff.dart               // ❌ 完全不知道是什么

// ❌ 禁止混乱的目录结构
lib/
├── components/              // ❌ 与 widgets 功能重复
├── widgets/                 // ❌ 与 components 功能重复
└── ui/                      // ❌ 与上面两个都重复
```

## ✅ 最佳实践

### 模块化开发
```dart
// ✅ 每个功能模块提供统一导出
// features/chat/chat_module.dart
export 'presentation/screens/chat_screen.dart';
export 'presentation/widgets/message_bubble_widget.dart';
export 'presentation/providers/chat_provider.dart';
export 'domain/entities/chat_message.dart';

// ✅ 使用模块注册器
class ChatModule {
  static void register() {
    // 注册模块的 providers、services 等
  }
}
```

### 依赖注入
```dart
// ✅ 使用 Riverpod 进行依赖注入
final chatServiceProvider = Provider<ChatService>((ref) {
  final logger = ref.read(loggerServiceProvider);
  final repository = ref.read(chatRepositoryProvider);
  return ChatService(logger: logger, repository: repository);
});
```

### 测试友好
```dart
// ✅ 提供测试用的 mock 实现
abstract class ChatRepository {
  Future<List<ChatMessage>> getMessages();
}

class MockChatRepository implements ChatRepository {
  @override
  Future<List<ChatMessage>> getMessages() async {
    return [/* mock data */];
  }
}
```

## 🔍 代码审查清单

### 提交前检查
- [ ] 文件命名符合规范
- [ ] 目录结构正确
- [ ] Import 语句顺序正确
- [ ] 添加了适当的注释
- [ ] 没有硬编码字符串
- [ ] 使用了统一的错误处理
- [ ] 通过了所有测试
- [ ] 运行了 `dart analyze` 无警告
- [ ] 运行了 `dart format` 格式化代码

### AI 代码生成检查
- [ ] 生成的代码符合项目规范
- [ ] 没有创建重复功能的文件
- [ ] 文件放在了正确的目录
- [ ] 使用了项目的状态管理模式
- [ ] 遵循了项目的错误处理规范

## 🤖 AI 代码生成规范

### AI 生成代码的特殊要求

#### 生成前准备
```markdown
在请求 AI 生成代码时，请提供以下上下文：

1. **目标功能模块**: 明确代码属于哪个功能模块
2. **文件位置**: 指定文件应该放在哪个目录
3. **命名规范**: 提供期望的文件名和类名
4. **依赖关系**: 说明需要依赖的其他组件
5. **项目规范**: 引用本文档的相关规范

示例提示：
"请在 features/chat/presentation/widgets/ 目录下创建一个消息气泡组件，
文件名为 message_bubble_widget.dart，遵循项目的组件命名规范，
使用 Riverpod 进行状态管理，添加适当的注释。"
```

#### 生成后检查
```markdown
AI 生成代码后，必须检查以下项目：

✅ 文件命名是否符合规范
✅ 目录位置是否正确
✅ Import 语句是否按规范排序
✅ 是否添加了文件头注释
✅ 是否使用了项目的状态管理模式
✅ 是否遵循了错误处理规范
✅ 是否避免了硬编码字符串
✅ 是否与现有代码重复
```

### 常见 AI 生成问题及解决方案

#### 问题1：重复功能文件
```dart
// ❌ AI 可能生成重复的服务文件
lib/services/
├── ai_service.dart          // 已存在
├── ai_service_new.dart      // ❌ AI 生成的重复文件
└── ai_request_handler.dart  // ❌ 又是类似功能

// ✅ 正确做法：检查现有文件，扩展或重构
lib/services/ai/
├── ai_service_manager.dart  // 统一管理
├── chat/
│   └── chat_service.dart    // 具体功能
└── models/
    └── model_service.dart   // 具体功能
```

#### 问题2：不一致的命名
```dart
// ❌ AI 可能生成不一致的命名
chat_style_settings_screen.dart  // 旧的命名方式
chatDisplayScreen.dart           // 驼峰命名（错误）
chat-display-screen.dart         // 连字符命名（错误）

// ✅ 统一使用 snake_case
chat_display_settings_screen.dart
```

#### 问题3：错误的目录结构
```dart
// ❌ AI 可能放错位置
lib/
├── widgets/                 // AI 可能放在这里
│   └── chat_widget.dart
├── components/              // 或者放在这里
│   └── message_component.dart
└── ui/                      // 或者放在这里
    └── chat_ui.dart

// ✅ 正确的位置
lib/features/chat/presentation/widgets/
├── chat_widget.dart
├── message_bubble_widget.dart
└── chat_input_widget.dart
```

## 🔧 自动化工具配置

### 代码格式化配置
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

  strong-mode:
    implicit-casts: false
    implicit-dynamic: false

linter:
  rules:
    # 强制规范
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - prefer_final_fields
    - prefer_final_locals
    - avoid_print
    - avoid_unnecessary_containers
    - use_key_in_widget_constructors

    # 命名规范
    - file_names
    - library_names
    - non_constant_identifier_names
    - constant_identifier_names
```

### Git Hooks 配置
```bash
#!/bin/sh
# .git/hooks/pre-commit

echo "运行代码质量检查..."

# 格式化检查
dart format --set-exit-if-changed lib/
if [ $? -ne 0 ]; then
  echo "❌ 代码格式不符合规范，请运行 'dart format lib/'"
  exit 1
fi

# 静态分析
dart analyze
if [ $? -ne 0 ]; then
  echo "❌ 静态分析发现问题，请修复后再提交"
  exit 1
fi

# 文件命名检查
python scripts/check_naming.py
if [ $? -ne 0 ]; then
  echo "❌ 文件命名不符合规范"
  exit 1
fi

echo "✅ 代码质量检查通过"
```

### 自动化检查脚本
```python
#!/usr/bin/env python3
# scripts/check_naming.py

import os
import re
import sys

def check_file_naming():
    """检查文件命名是否符合规范"""
    errors = []

    for root, dirs, files in os.walk('lib'):
        for file in files:
            if file.endswith('.dart'):
                # 检查是否使用 snake_case
                if not re.match(r'^[a-z][a-z0-9_]*\.dart$', file):
                    errors.append(f"文件名不符合 snake_case 规范: {os.path.join(root, file)}")

                # 检查是否有禁止的命名模式
                forbidden_patterns = [
                    r'.*_new\.dart$',      # 禁止 _new 后缀
                    r'.*_old\.dart$',      # 禁止 _old 后缀
                    r'^utils\.dart$',      # 禁止模糊的 utils.dart
                    r'^helpers\.dart$',    # 禁止模糊的 helpers.dart
                ]

                for pattern in forbidden_patterns:
                    if re.match(pattern, file):
                        errors.append(f"禁止的文件命名模式: {os.path.join(root, file)}")

    if errors:
        for error in errors:
            print(f"❌ {error}")
        return False

    return True

if __name__ == "__main__":
    if not check_file_naming():
        sys.exit(1)
    print("✅ 文件命名检查通过")
```

## 📚 开发工作流程

### 新功能开发流程
```markdown
1. **需求分析**
   - 确定功能属于哪个模块
   - 设计 API 接口
   - 确定数据模型

2. **创建分支**
   ```bash
   git checkout -b feature/chat-voice-message
   ```

3. **创建目录结构**
   ```bash
   mkdir -p features/chat/presentation/widgets
   mkdir -p features/chat/domain/entities
   mkdir -p features/chat/data/models
   ```

4. **编写代码**
   - 遵循命名规范
   - 添加适当注释
   - 使用统一的状态管理

5. **测试验证**
   ```bash
   flutter test
   dart analyze
   dart format lib/
   ```

6. **代码审查**
   - 自我检查规范遵循情况
   - 提交 Pull Request
   - 团队代码审查

7. **合并代码**
   ```bash
   git merge feature/chat-voice-message
   ```
```

### AI 辅助开发流程
```markdown
1. **准备 AI 提示**
   - 明确功能需求
   - 指定文件位置和命名
   - 引用项目规范

2. **生成代码**
   - 使用 AI 生成初始代码
   - 检查生成结果

3. **规范检查**
   - 对照规范清单检查
   - 修正不符合规范的部分

4. **集成测试**
   - 确保与现有代码兼容
   - 运行完整测试套件

5. **文档更新**
   - 更新相关文档
   - 添加使用示例
```

---

> 💡 **重要提醒**: 这些规范不仅适用于人工编写的代码，也适用于 AI 生成的代码。在使用 AI 生成代码时，请确保生成的代码符合这些规范，必要时进行调整。

> 🚨 **强制执行**: 所有不符合规范的代码都不应该被合并到主分支。建议在 CI/CD 流程中集成自动检查工具。

> 🤖 **AI 协作**: 在与 AI 协作开发时，请将本规范文档作为上下文提供给 AI，确保生成的代码符合项目标准。
