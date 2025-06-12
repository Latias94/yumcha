import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../features/ai_management/domain/entities/ai_provider.dart'
    as models;
import '../../../features/ai_management/domain/entities/ai_model.dart';
import 'database.dart';

// 将模型枚举转换为数据库枚举
ProviderType modelToDbProviderType(models.ProviderType type) {
  switch (type) {
    case models.ProviderType.openai:
      return ProviderType.openai;
    case models.ProviderType.anthropic:
      return ProviderType.anthropic;
    case models.ProviderType.google:
      return ProviderType.google;
    case models.ProviderType.ollama:
      return ProviderType.ollama;
    case models.ProviderType.custom:
      return ProviderType.custom;
  }
}

// 将数据库枚举转换为模型枚举
models.ProviderType dbToModelProviderType(ProviderType type) {
  switch (type) {
    case ProviderType.openai:
      return models.ProviderType.openai;
    case ProviderType.anthropic:
      return models.ProviderType.anthropic;
    case ProviderType.google:
      return models.ProviderType.google;
    case ProviderType.ollama:
      return models.ProviderType.ollama;
    case ProviderType.custom:
      return models.ProviderType.custom;
  }
}

// JSON 转换器
class JsonConverter<T> extends TypeConverter<T, String> {
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  const JsonConverter(this.fromJson, this.toJson);

  @override
  T fromSql(String fromDb) {
    return fromJson(json.decode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(T value) {
    return json.encode(toJson(value));
  }
}

// 字符串列表转换器
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return List<String>.from(json.decode(fromDb) as List);
  }

  @override
  String toSql(List<String> value) {
    return json.encode(value);
  }
}

// Map<String, String> 转换器
class StringMapConverter extends TypeConverter<Map<String, String>, String> {
  const StringMapConverter();

  @override
  Map<String, String> fromSql(String fromDb) {
    if (fromDb.isEmpty || fromDb == '{}') return {};
    final Map<String, dynamic> decoded =
        json.decode(fromDb) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value.toString()));
  }

  @override
  String toSql(Map<String, String> value) {
    return json.encode(value);
  }
}

// Map<String, dynamic> 转换器
class DynamicMapConverter extends TypeConverter<Map<String, dynamic>, String> {
  const DynamicMapConverter();

  @override
  Map<String, dynamic> fromSql(String fromDb) {
    if (fromDb.isEmpty || fromDb == '{}') return {};
    return json.decode(fromDb) as Map<String, dynamic>;
  }

  @override
  String toSql(Map<String, dynamic> value) {
    return json.encode(value);
  }
}

// AiModel 列表转换器
class ModelListConverter extends TypeConverter<List<AiModel>, String> {
  const ModelListConverter();

  @override
  List<AiModel> fromSql(String fromDb) {
    if (fromDb.isEmpty || fromDb == '[]') return [];
    final List<dynamic> decoded = json.decode(fromDb) as List<dynamic>;
    return decoded
        .map((item) => AiModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<AiModel> value) {
    return json.encode(value.map((model) => model.toJson()).toList());
  }
}
