import 'dart:convert';

/// 应用设置数据模型
///
/// 表示应用的配置设置项，支持多种数据类型的设置值。
/// 提供类型安全的设置值存储和检索功能。
///
/// 核心特性：
/// - 🔑 **键值存储**: 基于键值对的设置存储
/// - 🎯 **类型安全**: 支持多种数据类型的类型安全操作
/// - 🔄 **动态更新**: 支持设置值的动态更新
/// - 📊 **类型推断**: 自动推断设置值的数据类型
/// - 💾 **持久化**: 支持数据库持久化存储
/// - 📝 **描述信息**: 支持设置项的描述信息
///
/// 支持的数据类型：
/// - String: 字符串类型
/// - bool: 布尔类型
/// - int: 整数类型
/// - double: 浮点数类型
/// - JSON: 复杂对象类型（序列化为 JSON）
///
/// 使用场景：
/// - 应用配置管理
/// - 用户偏好设置
/// - 功能开关控制
/// - 默认值配置
class AppSetting {
  /// 设置项的唯一键名
  final String key;

  /// 设置值（以字符串形式存储）
  final String value;

  /// 设置值的数据类型
  final SettingType type;

  /// 设置项的描述信息（可选）
  final String? description;

  /// 创建时间
  final DateTime createdAt;

  /// 最后更新时间
  final DateTime updatedAt;

  const AppSetting({
    required this.key,
    required this.value,
    required this.type,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从数据库数据创建设置对象
  factory AppSetting.fromData(dynamic data) {
    return AppSetting(
      key: data.key,
      value: data.value,
      type: SettingType.fromString(data.type),
      description: data.description,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  /// 获取类型化的值
  T getValue<T>() {
    switch (type) {
      case SettingType.string:
        return value as T;
      case SettingType.bool:
        return (value.toLowerCase() == 'true') as T;
      case SettingType.int:
        return int.parse(value) as T;
      case SettingType.double:
        return double.parse(value) as T;
      case SettingType.json:
        return jsonDecode(value) as T;
    }
  }

  /// 创建设置对象
  static AppSetting create<T>({
    required String key,
    required T value,
    String? description,
  }) {
    final now = DateTime.now();
    final settingType = _getTypeFromValue(value);
    final stringValue = _valueToString(value, settingType);

    return AppSetting(
      key: key,
      value: stringValue,
      type: settingType,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 更新设置值
  AppSetting updateValue<T>(T newValue) {
    final settingType = _getTypeFromValue(newValue);
    final stringValue = _valueToString(newValue, settingType);

    return AppSetting(
      key: key,
      value: stringValue,
      type: settingType,
      description: description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// 从值推断类型
  static SettingType _getTypeFromValue<T>(T value) {
    if (value is String) return SettingType.string;
    if (value is bool) return SettingType.bool;
    if (value is int) return SettingType.int;
    if (value is double) return SettingType.double;
    return SettingType.json;
  }

  /// 将值转换为字符串
  static String _valueToString<T>(T value, SettingType type) {
    switch (type) {
      case SettingType.string:
      case SettingType.bool:
      case SettingType.int:
      case SettingType.double:
        return value.toString();
      case SettingType.json:
        return jsonEncode(value);
    }
  }

  AppSetting copyWith({
    String? key,
    String? value,
    SettingType? type,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppSetting(
      key: key ?? this.key,
      value: value ?? this.value,
      type: type ?? this.type,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSetting &&
        other.key == key &&
        other.value == value &&
        other.type == type &&
        other.description == description;
  }

  @override
  int get hashCode {
    return key.hashCode ^ value.hashCode ^ type.hashCode ^ description.hashCode;
  }

  @override
  String toString() {
    return 'AppSetting(key: $key, value: $value, type: $type, description: $description)';
  }
}

/// 设置值类型枚举
///
/// 定义应用设置支持的数据类型，用于类型安全的设置值操作。
///
/// 支持的类型：
/// - string: 字符串类型
/// - bool: 布尔类型
/// - int: 整数类型
/// - double: 浮点数类型
/// - json: JSON 对象类型（用于复杂数据结构）
enum SettingType {
  /// 字符串类型
  string,

  /// 布尔类型
  bool,

  /// 整数类型
  int,

  /// 浮点数类型
  double,

  /// JSON 对象类型（用于复杂数据结构）
  json;

  static SettingType fromString(String value) {
    switch (value) {
      case 'string':
        return SettingType.string;
      case 'bool':
        return SettingType.bool;
      case 'int':
        return SettingType.int;
      case 'double':
        return SettingType.double;
      case 'json':
        return SettingType.json;
      default:
        throw ArgumentError('Unknown setting type: $value');
    }
  }

  @override
  String toString() {
    switch (this) {
      case SettingType.string:
        return 'string';
      case SettingType.bool:
        return 'bool';
      case SettingType.int:
        return 'int';
      case SettingType.double:
        return 'double';
      case SettingType.json:
        return 'json';
    }
  }
}

/// 预定义的设置键常量类
///
/// 定义应用中使用的所有设置键名常量，确保键名的一致性和避免拼写错误。
///
/// 设置分类：
/// - 主题设置: 颜色模式、动态颜色、主题方案等
/// - 聊天设置: 气泡样式、调试模式等
/// - 默认模型: 各种功能的默认模型配置
/// - MCP 设置: MCP 协议相关配置
/// - 最后使用: 用户最后使用的配置记录
class SettingKeys {
  // 主题设置
  static const String colorMode = 'theme.color_mode';
  static const String dynamicColorEnabled = 'theme.dynamic_color_enabled';
  static const String themeScheme = 'theme.scheme';

  // 聊天设置
  static const String chatBubbleStyle = 'chat.bubble_style';
  static const String debugMode = 'chat.debug_mode';

  // 默认模型设置
  static const String defaultChatModel = 'default_models.chat';
  static const String defaultTitleModel = 'default_models.title';
  static const String defaultTranslationModel = 'default_models.translation';
  static const String defaultSummaryModel = 'default_models.summary';

  // MCP 设置
  static const String mcpEnabled = 'mcp.enabled';
  static const String mcpServers = 'mcp.servers';

  // 最后使用的配置
  static const String lastUsedAssistantId = 'last_used.assistant_id';
  static const String lastUsedProviderId = 'last_used.provider_id';
  static const String lastUsedModelName = 'last_used.model_name';
}

/// 默认模型配置数据模型
///
/// 表示特定功能的默认模型配置，包含提供商和模型的组合。
/// 用于配置聊天、标题生成、翻译、摘要等功能的默认模型。
///
/// 核心特性：
/// - 🔌 **提供商配置**: 指定默认使用的提供商
/// - 🧠 **模型配置**: 指定默认使用的模型
/// - ✅ **配置检查**: 检查配置是否完整
/// - 🔄 **序列化支持**: 支持 JSON 序列化和反序列化
///
/// 使用场景：
/// - 默认聊天模型配置
/// - 标题生成模型配置
/// - 翻译模型配置
/// - 摘要生成模型配置
class DefaultModelConfig {
  /// 提供商 ID（可选）
  final String? providerId;

  /// 模型名称（可选）
  final String? modelName;

  const DefaultModelConfig({this.providerId, this.modelName});

  factory DefaultModelConfig.fromJson(Map<String, dynamic> json) {
    return DefaultModelConfig(
      providerId: json['providerId'] as String?,
      modelName: json['modelName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'providerId': providerId, 'modelName': modelName};
  }

  /// 检查配置是否完整（提供商 ID 和模型名称都不为空）
  bool get isConfigured => providerId != null && modelName != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DefaultModelConfig &&
        other.providerId == providerId &&
        other.modelName == modelName;
  }

  @override
  int get hashCode => providerId.hashCode ^ modelName.hashCode;

  @override
  String toString() {
    return 'DefaultModelConfig(providerId: $providerId, modelName: $modelName)';
  }
}
