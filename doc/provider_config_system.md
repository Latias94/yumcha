# 提供商标准配置系统

## 概述

提供商标准配置系统是为了帮助应用识别和推断知名大提供商（如 OpenAI、Anthropic、Google 等）的模型能力和参数而设计的。该系统与用户的 `AiModel` 配置是分离的，仅提供标准的模型信息供应用参考。

## 设计理念

### 核心原则

1. **分离关注点**：标准配置与用户配置完全分离
2. **谨慎应用**：只有确认是官方提供商时才应用标准配置
3. **补充增强**：标准配置用于补充而非覆盖用户配置
4. **参考依据**：为模型能力识别提供可靠的参考依据

### 使用场景

- **用户配置了官方 OpenAI 提供商**：应用标准配置来增强模型信息
- **用户配置了第三方 OpenAI 兼容提供商**：不应用标准配置，因为实现可能不同
- **模型能力推断**：基于标准配置推断未知模型的可能能力
- **参数建议**：为用户提供模型的推荐参数和设置

## 系统架构

### 核心组件

```
lib/models/provider_model_config.dart          # 标准配置数据模型
lib/config/providers/openai_config.dart        # OpenAI 标准配置
lib/services/provider_config_service.dart      # 配置服务
lib/utils/model_config_utils.dart              # 配置应用工具
```

### 数据模型

#### ModelAbility（模型能力）
- `functionCall`：函数调用/工具调用
- `reasoning`：推理能力
- `vision`：视觉理解
- `search`：网络搜索
- `embedding`：嵌入向量

#### ModelType（模型类型）
- `chat`：聊天模型
- `embedding`：嵌入模型
- `stt`：语音转文字
- `tts`：文字转语音
- `image`：图像生成
- `realtime`：实时对话

#### ProviderModelConfig（提供商模型配置）
包含模型的完整标准信息：
- 基本信息：ID、显示名称、描述
- 能力配置：支持的能力列表
- 技术参数：上下文窗口、最大输出
- 定价信息：输入/输出价格
- 设置信息：扩展参数、分辨率等

## 使用方法

### 1. 获取标准配置信息

```dart
final configService = ProviderConfigService();

// 获取提供商配置
final openaiConfig = configService.getProviderConfig('openai');

// 获取特定模型配置
final gpt4oConfig = configService.getModelConfig('openai', 'gpt-4o');

// 检查模型能力
final supportsVision = configService.modelSupportsAbility('openai', 'gpt-4o', ModelAbility.vision);
```

### 2. 应用配置到用户模型

```dart
// 为用户的模型应用标准配置（仅官方提供商）
final enhancedModel = ModelConfigUtils.applyProviderConfig(userModel, userProvider);

// 批量应用配置
final enhancedModels = ModelConfigUtils.applyProviderConfigToModels(userModels, userProvider);
```

### 3. 获取推荐参数

```dart
// 获取模型的推荐参数
final parameters = ModelConfigUtils.getRecommendedParameters('gpt-4o', provider);

// 获取模型显示信息
final displayInfo = ModelConfigUtils.getModelDisplayInfo('gpt-4o', provider);
```

### 4. 能力检查

```dart
// 检查模型是否支持特定能力
final supportsVision = ModelConfigUtils.modelSupportsCapability(
  'gpt-4o', 
  provider, 
  ModelCapability.vision
);

// 检查是否为推荐模型
final isRecommended = ModelConfigUtils.isRecommendedModel('gpt-4o', provider);

// 检查是否为遗留模型
final isLegacy = ModelConfigUtils.isLegacyModel('gpt-4o', provider);
```

## 官方提供商判断

系统通过检查提供商的基础 URL 来判断是否为官方提供商：

- **OpenAI**：`api.openai.com` 或空（默认）
- **Anthropic**：`api.anthropic.com` 或空（默认）
- **Google**：`generativelanguage.googleapis.com` 或空（默认）

只有官方提供商才会应用标准配置，第三方提供商即使使用相同的模型名称也不会应用。

## 配置应用策略

### 能力合并
- 保留用户原有配置的能力
- 添加标准配置中的能力
- 去重处理

### 元数据处理
- 用户已配置的元数据优先
- 标准配置作为补充信息
- 标准配置信息存储在 `standardConfig` 字段中

### 显示名称
- 用户配置的显示名称优先
- 如果用户未配置则使用标准配置

## 扩展新提供商

要添加新的提供商配置：

1. 在 `lib/config/providers/` 下创建新的配置文件
2. 定义提供商的标准模型配置
3. 在 `ProviderConfigService` 中注册新配置
4. 在 `ModelConfigUtils._isOfficialProvider` 中添加官方 URL 判断

## 注意事项

1. **不要直接转换**：标准配置不应直接转换为用户的 `AiModel`
2. **谨慎应用**：只对确认的官方提供商应用标准配置
3. **保留用户配置**：始终优先保留用户的自定义配置
4. **定期更新**：标准配置需要根据提供商的更新进行维护

## 示例

详细的使用示例请参考 `lib/examples/provider_config_example.dart` 文件。
