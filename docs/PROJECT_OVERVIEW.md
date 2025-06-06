# YumCha AI 聊天应用 - 项目详情文档

## 项目概述

YumCha 是一个基于 Flutter 开发的跨平台 AI 聊天应用，支持桌面端和移动端。应用采用 Material Design 3 设计规范，使用独立的 `ai_dart` 库提供统一的 AI 聊天接口。

用户可以配置多个 AI 提供商，包括 OpenAI、DeepSeek、Anthropic、Google、Ollama、Phind 等，并为每个提供商配置不同的 API 密钥和模型，一个提供商可以配置多个模型。用户可以创建多个 AI 助手，每个助手不绑定提供商和模型，可以设置个性化的系统提示词和温度参数等AI参数。
用户首先通过 AI 助手创建聊天，在聊天过程中可以切换不同的提供商模型（某个提供商中的某个模型）。

### 核心功能
- **AI 助手聊天**：支持多种 AI 提供商（OpenAI、DeepSeek、Anthropic、Google、Ollama、Phind 等）
- **多提供商管理**：统一管理不同 AI 服务提供商和模型
- **实时流式对话**：支持流式和非流式 AI 响应，支持推理模型（o1、R1 等）
- **模型收藏系统**：可收藏常用模型便于快速访问
- **聊天历史管理**：完整的对话记录和管理功能
- **聊天搜索功能**：支持搜索聊天记录和对话标题
- **调试和测试工具**：内置 AI API 测试和调试功能

### 未来功能规划
- **AI 角色聊天**：计划支持 SillyTavern 兼容的角色扮演对话功能
- **世界信息系统**：支持复杂的世界设定和角色背景
- **插件系统**：支持第三方插件和扩展

## 技术架构

### 技术栈
- **Flutter 3.8+**：跨平台 UI 框架
- **Material Design 3**：现代化 UI 设计系统
- **Riverpod 2.6+**：状态管理解决方案
- **Drift 2.16+**：SQLite 数据库 ORM
- **ai_dart**：独立的 AI 聊天接口库，支持多种 LLM 提供商

### 数据库设计
使用 SQLite 数据库，通过 Drift ORM 管理，包含以下核心表：

#### 1. Providers 表（AI 提供商）
```dart
- id: String (主键)
- name: String (提供商名称)
- type: ProviderType (枚举：openai, anthropic, google, ollama, custom)
- apiKey: String (API 密钥)
- baseUrl: String? (自定义 API 地址)
- models: List<AiModel> (支持的模型列表，JSON 存储)
- customHeaders: Map<String, String> (自定义请求头)
- isEnabled: bool (是否启用)
- createdAt/updatedAt: DateTime (时间戳)
```

#### 2. Assistants 表（AI 助手）
```dart
- id: String (主键)
- name: String (助手名称)
- description: String (描述)
- avatar: String (头像，默认 🤖)
- systemPrompt: String (系统提示词)
- temperature: double (温度参数 0.0-2.0)
- topP: double (Top-P 参数)
- maxTokens: int? (最大 token 数)
- contextLength: int (上下文长度)
- streamOutput: bool (是否流式输出)
- frequencyPenalty/presencePenalty: double (惩罚参数)
- customHeaders/customBody: Map (自定义配置)
- stopSequences: List<String> (停止序列)
- 功能开关: enableCodeExecution, enableImageGeneration, enableTools, 
  enableReasoning, enableVision, enableEmbedding
- isEnabled: bool
- createdAt/updatedAt: DateTime
```

#### 3. Conversations 表（对话）
```dart
- id: String (主键)
- title: String (对话标题)
- assistantId: String (关联助手 ID)
- providerId: String (使用的提供商 ID)
- modelId: String? (使用的模型 ID)
- lastMessageAt: DateTime (最后消息时间)
- createdAt/updatedAt: DateTime
```

#### 4. Messages 表（消息）
```dart
- id: String (主键)
- conversationId: String (关联对话 ID)
- content: String (消息内容)
- author: String (作者)
- isFromUser: bool (是否来自用户)
- imageUrl: String? (图片 URL)
- avatarUrl: String? (头像 URL)
- timestamp: DateTime (消息时间戳)
- createdAt: DateTime
```

#### 5. FavoriteModels 表（收藏模型）
```dart
- id: String (主键)
- providerId: String (提供商 ID)
- modelName: String (模型名称)
- createdAt: DateTime
```

## 状态管理架构

### Riverpod Providers 体系

**重要原则：所有数据库访问必须通过 Riverpod Notifiers 进行，禁止直接访问 DatabaseService.instance.database 或直接创建 Repository 实例。**

#### 1. AI 提供商管理
- `AiProviderNotifier`: 管理提供商列表的增删改查
- `aiProviderNotifierProvider`: 提供商列表状态
- `aiProviderProvider`: 获取特定提供商
- `enabledAiProvidersProvider`: 获取启用的提供商列表

#### 2. AI 助手管理
- `AiAssistantNotifier`: 管理助手列表的增删改查
- `aiAssistantNotifierProvider`: 助手列表状态
- `aiAssistantProvider`: 获取特定助手
- `enabledAiAssistantsProvider`: 获取启用的助手列表

#### 3. 聊天状态管理
- `ChatNotifier`: 管理聊天消息和配置
- `ChatConfigurationNotifier`: 管理聊天配置（助手、提供商、模型选择）
- `CurrentConversationNotifier`: 管理当前对话状态

#### 4. 收藏模型管理
- `FavoriteModelNotifier`: 管理模型收藏功能

### 数据库访问规范

#### 正确的访问方式
```dart
// ✅ 正确：通过 Riverpod Notifier 访问数据
final providers = ref.watch(aiProviderNotifierProvider);
final assistants = ref.watch(aiAssistantNotifierProvider);

// ✅ 正确：在 Notifier 中调用方法
ref.read(aiProviderNotifierProvider.notifier).addProvider(provider);
ref.read(aiAssistantNotifierProvider.notifier).updateAssistant(assistant);
```

#### 错误的访问方式
```dart
// ❌ 错误：直接访问数据库服务
final db = DatabaseService.instance.database;
final repository = ProviderRepository(db);

// ❌ 错误：在 UI 组件中直接创建 Repository
final providerRepo = ProviderRepository(DatabaseService.instance.database);
final providers = await providerRepo.getAllProviders();
```

#### 架构层次
1. **UI 层**：只能通过 Riverpod Providers 访问数据
2. **Notifier 层**：负责状态管理，内部使用 Repository
3. **Repository 层**：数据访问层，只能在 Notifier 中使用
4. **Database 层**：SQLite 数据库，只能在 Repository 中访问

### 必须使用的 Notifiers

当需要访问数据库时，必须使用以下对应的 Notifier：

#### 提供商数据访问
- 使用 `AiProviderNotifier` (通过 `aiProviderNotifierProvider`)
- 提供方法：`getAllProviders()`, `addProvider()`, `updateProvider()`, `deleteProvider()`

#### 助手数据访问
- 使用 `AiAssistantNotifier` (通过 `aiAssistantNotifierProvider`)
- 提供方法：`getAllAssistants()`, `addAssistant()`, `updateAssistant()`, `deleteAssistant()`

#### 对话数据访问
- 使用 `ConversationNotifier` (通过 `conversationNotifierProvider`)
- 提供方法：对话创建、更新、删除和消息管理

#### 收藏模型数据访问
- 使用 `FavoriteModelNotifier` (通过 `favoriteModelNotifierProvider`)
- 提供方法：`addFavorite()`, `removeFavorite()`, `isFavorite()`

#### 聊天配置访问
- 使用 `ChatConfigurationNotifier` (通过 `chatConfigurationNotifierProvider`)
- 提供方法：助手、提供商、模型选择和配置管理

## 服务层架构

### 核心服务

#### 1. DatabaseService
- 单例模式管理 SQLite 数据库连接
- 提供数据库初始化和迁移功能

#### 2. AI 相关服务
- **新架构** (`lib/services/ai/`): 模块化的 AI 服务架构
  - `AiServiceManager`: AI 服务管理器，统一管理各种 AI 功能
  - `ChatService`: 聊天服务，处理对话逻辑
  - `ModelService`: 模型服务，管理模型信息和能力
  - `EmbeddingService`: 嵌入服务，处理向量嵌入功能
- **ai_dart 库**: 独立的 AI 接口库，位于 `packages/ai_dart/`
  - 支持多种 LLM 提供商的统一接口
  - 可独立发布和维护
  - 提供流式和非流式聊天功能

#### 3. Repository 层
- `ProviderRepository`: 提供商数据访问层
- `AssistantRepository`: 助手数据访问层
- `ConversationRepository`: 对话数据访问层
- `FavoriteModelRepository`: 收藏模型数据访问层

#### 4. 工具服务
- `LoggerService`: 日志记录服务，支持 AI 专用日志方法
- `NotificationService`: 通知服务，支持多种通知类型
- `ThemeService`: 主题服务，支持 Material 3 动态颜色
- `PreferenceService`: 偏好设置服务
- `ValidationService`: 数据验证服务

### 错误处理系统

#### ErrorHandler 工具类
- 统一的错误处理机制
- 支持异步和同步操作的错误捕获
- 自动错误分类和用户友好提示
- 集成日志记录和通知显示

#### 错误类型定义
```dart
enum ErrorType { network, database, api, validation, permission, unknown }

// 具体错误类
- AppError: 应用错误基类
- NetworkError: 网络错误
- DatabaseError: 数据库错误
- ApiError: API 错误
- ValidationError: 验证错误
- PermissionError: 权限错误
```

## ai_dart 库集成

### ai_dart 库架构
```
packages/ai_dart/
├── lib/
│   ├── src/
│   │   ├── providers/          # AI 提供商实现
│   │   │   ├── openai/
│   │   │   ├── anthropic/
│   │   │   ├── google/
│   │   │   ├── deepseek/
│   │   │   ├── ollama/
│   │   │   └── phind/
│   │   ├── models/             # 数据模型
│   │   ├── interfaces/         # 统一接口
│   │   └── core/               # 核心功能
│   └── ai_dart.dart           # 主导出文件
├── pubspec.yaml               # 独立包配置
└── README.md                  # 独立文档
```

### AI 聊天功能
- **统一接口**: 为所有 AI 提供商提供一致的 API
- **流式支持**: 支持实时流式响应
- **推理模型**: 支持 OpenAI o1、DeepSeek R1 等推理模型
- **多提供商**: OpenAI、Anthropic、Google、DeepSeek、Ollama、Phind 等
- **独立发布**: 可作为独立的 Dart 包发布到 pub.dev

### 关键 API
```dart
// 发送聊天消息
Future<AiResponse> sendMessage({
  required String providerId,
  required String modelName,
  required String message,
  Map<String, dynamic>? parameters,
});

// 流式聊天
Stream<AiStreamEvent> sendStreamMessage({
  required String providerId,
  required String modelName,
  required String message,
  Map<String, dynamic>? parameters,
});

// 获取模型列表
Future<List<AiModel>> getModels(String providerId);
```

## UI 界面架构

### 主要界面

#### 1. 主导航 (MainNavigation)
- 集成抽屉导航和聊天界面
- 支持新对话创建和对话切换
- 响应式布局适配不同屏幕尺寸

#### 2. 聊天界面 (ChatScreen/ChatView)
- 支持实时消息显示和输入
- 集成 markdown 渲染（markdown_widget）
- 支持消息编辑和重新生成
- 流式响应实时显示

#### 3. 设置界面 (SettingsScreen)
- 主题设置（颜色模式、动态颜色）
- 显示设置（聊天样式配置）
- 提供商和助手管理入口

#### 4. 管理界面
- `ProvidersScreen`: 提供商管理
- `AssistantsScreen`: 助手管理
- `ProviderEditScreen`: 提供商编辑
- `AssistantEditScreen`: 助手编辑

### UI 组件

#### 1. 聊天组件
- `ChatHistoryView`: 聊天历史显示
- `ChatInput`: 聊天输入框
- `StreamResponse`: 流式响应处理

#### 2. 通用组件
- `AppDrawer`: 应用抽屉导航
- `ModelSelectionDialog`: 模型选择对话框
- `ModelListManager`: 模型列表管理器

## 主题系统

### Material Design 3 支持
- 完整的 Material 3 颜色系统
- 支持动态颜色（Android 12+）
- 自定义颜色方案和排版

### 主题配置
```dart
// 颜色模式
enum ColorMode { system, light, dark }

// 主题服务功能
- 动态颜色检测和应用
- 主题模式切换
- 颜色方案自定义
- 持久化主题设置
```

## 依赖管理

### 主要依赖
```yaml
dependencies:
  flutter_riverpod: ^2.6.1          # 状态管理
  drift: ^2.16.0                    # 数据库 ORM
  ai_dart:                          # AI 聊天接口库
    path: packages/ai_dart          # 本地路径（开发时）
    # ai_dart: ^1.0.0              # 发布版本（生产时）
  dynamic_color: ^1.7.0             # 动态颜色
  markdown_widget: ^2.3.2+8         # Markdown 渲染
  chat_bubbles: ^1.7.0              # 聊天气泡
  infinite_scroll_pagination: ^5.0.0 # 分页列表
  logger: ^2.4.0                    # 日志记录
  uuid: ^4.5.1                     # UUID 生成
  shared_preferences: ^2.5.3        # 偏好设置
  dio: ^5.3.0                       # HTTP 客户端（ai_dart 依赖）
```

## 开发和调试

### 日志系统
- 分级日志记录（debug, info, warning, error, fatal）
- AI 专用日志方法（请求、响应、流式数据）
- 开发和生产环境不同的日志策略

### 调试功能
- `AiDebugLogsScreen`: AI 调试日志界面（原 `DebugScreen`）
- `AiApiTestScreen`: AI API 测试界面（原 `AiDebugScreen`）
- `QuickSetupScreen`: 快速配置界面（原 `ConfigScreen`）
- 详细的错误追踪和报告

### 测试支持
- 集成测试框架
- ai_dart 库单元测试
- 数据库迁移测试
- Riverpod 状态管理测试

## 部署和构建

### 支持平台
- Android
- iOS  
- Windows
- macOS
- Linux
- Web

### 构建配置
- Flutter 3.8+ SDK
- Dart 3.0+ SDK
- 平台特定的构建依赖
- ai_dart 库的依赖管理

## 项目特色

这个项目展现了现代 Flutter 应用开发的最佳实践，具有以下特色：

### 技术特色
- **独立 AI 库**: ai_dart 作为独立库，可复用和独立维护
- **模块化架构**: 清晰的分层架构和模块化设计
- **完善的状态管理**: 基于 Riverpod 的统一状态管理
- **优雅的 UI 设计**: Material Design 3 和动态颜色支持
- **健壮的错误处理**: 统一的错误处理和日志系统

### 功能特色
- **多提供商支持**: 统一接口支持多种 AI 服务提供商
- **推理模型支持**: 支持 OpenAI o1、DeepSeek R1 等推理模型
- **实时流式对话**: 流畅的实时对话体验
- **跨平台支持**: 支持移动端、桌面端和 Web 端
- **未来扩展性**: 为角色扮演等高级功能预留架构空间
