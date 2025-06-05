import 'dart:convert';

/// 应用设置模型
class AppSetting {
  final String key;
  final String value;
  final SettingType type;
  final String? description;
  final DateTime createdAt;
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
enum SettingType {
  string,
  bool,
  int,
  double,
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

/// 预定义的设置键
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

/// 默认模型配置
class DefaultModelConfig {
  final String? providerId;
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
