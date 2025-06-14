// 🔄 配置导入导出数据模型
//
// 定义配置导入导出功能所需的所有数据模型，包括导出结果、导入结果、
// 配置数据结构、元数据等。这些模型确保配置数据的完整性和兼容性。
//
// 🎯 **核心功能**:
// - 📦 **配置数据**: 完整的配置数据结构定义
// - 📊 **导出结果**: 导出操作的结果和统计信息
// - 📥 **导入结果**: 导入操作的结果和错误处理
// - 🔍 **导入预览**: 导入前的内容预览和验证
// - 🏷️ **元数据管理**: 版本、时间戳、应用信息等
//
// 🛡️ **安全特性**:
// - 数据加密支持
// - 版本兼容性检查
// - 配置验证机制
// - 冲突解决策略

import 'package:flutter/foundation.dart';
import 'ai_provider.dart';
import 'ai_assistant.dart';

/// 导出格式枚举
enum ExportFormat {
  json('JSON', '.json'),
  yaml('YAML', '.yaml'),
  encrypted('加密JSON', '.enc');

  const ExportFormat(this.displayName, this.extension);
  final String displayName;
  final String extension;
}

/// 冲突解决策略
enum ConflictResolutionStrategy {
  ask('询问用户'),
  merge('智能合并'),
  overwrite('覆盖现有'),
  skip('跳过冲突'),
  cancel('取消导入');

  const ConflictResolutionStrategy(this.displayName);
  final String displayName;
}

/// 配置数据结构
@immutable
class ConfigurationData {
  final List<AiProvider>? providers;
  final List<AiAssistant>? assistants;
  final UserPreferences? preferences;
  final AppSettings? settings;
  final ExportMetadata metadata;

  const ConfigurationData({
    this.providers,
    this.assistants,
    this.preferences,
    this.settings,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'providers': providers?.map((p) => p.toJson()).toList(),
    'assistants': assistants?.map((a) => a.toJson()).toList(),
    'preferences': preferences?.toJson(),
    'settings': settings?.toJson(),
    'metadata': metadata.toJson(),
  };

  factory ConfigurationData.fromJson(Map<String, dynamic> json) {
    return ConfigurationData(
      providers: (json['providers'] as List<dynamic>?)
          ?.map((p) => AiProvider.fromJson(p as Map<String, dynamic>))
          .toList(),
      assistants: (json['assistants'] as List<dynamic>?)
          ?.map((a) => AiAssistant.fromJson(a as Map<String, dynamic>))
          .toList(),
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>)
          : null,
      settings: json['settings'] != null
          ? AppSettings.fromJson(json['settings'] as Map<String, dynamic>)
          : null,
      metadata: ExportMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );
  }

  /// 获取配置数据的统计信息
  ConfigurationStatistics get statistics => ConfigurationStatistics(
    providerCount: providers?.length ?? 0,
    assistantCount: assistants?.length ?? 0,
    hasPreferences: preferences != null,
    hasSettings: settings != null,
    totalSize: _calculateSize(),
  );

  int _calculateSize() {
    // 简单的大小估算
    int size = 0;
    if (providers != null) size += providers!.length * 1024; // 每个提供商约1KB
    if (assistants != null) size += assistants!.length * 512; // 每个助手约512B
    if (preferences != null) size += 256; // 偏好设置约256B
    if (settings != null) size += 256; // 应用设置约256B
    return size;
  }
}

/// 导出元数据
@immutable
class ExportMetadata {
  final String version;
  final DateTime timestamp;
  final String appVersion;
  final String platform;
  final Map<String, dynamic> customData;

  const ExportMetadata({
    required this.version,
    required this.timestamp,
    required this.appVersion,
    required this.platform,
    this.customData = const {},
  });

  Map<String, dynamic> toJson() => {
    'version': version,
    'timestamp': timestamp.toIso8601String(),
    'appVersion': appVersion,
    'platform': platform,
    'customData': customData,
  };

  factory ExportMetadata.fromJson(Map<String, dynamic> json) {
    return ExportMetadata(
      version: json['version'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      appVersion: json['appVersion'] as String,
      platform: json['platform'] as String,
      customData: Map<String, dynamic>.from(json['customData'] as Map? ?? {}),
    );
  }
}

/// 导出结果
@immutable
class ExportResult {
  final bool success;
  final String? filePath;
  final String? error;
  final ExportStatistics statistics;

  const ExportResult({
    required this.success,
    this.filePath,
    this.error,
    required this.statistics,
  });

  factory ExportResult.success(String filePath, ExportStatistics statistics) {
    return ExportResult(
      success: true,
      filePath: filePath,
      statistics: statistics,
    );
  }

  factory ExportResult.failed(String error) {
    return ExportResult(
      success: false,
      error: error,
      statistics: const ExportStatistics(),
    );
  }
}

/// 导出统计信息
@immutable
class ExportStatistics {
  final int providerCount;
  final int assistantCount;
  final bool includesPreferences;
  final bool includesSettings;
  final int fileSizeBytes;
  final Duration exportDuration;

  const ExportStatistics({
    this.providerCount = 0,
    this.assistantCount = 0,
    this.includesPreferences = false,
    this.includesSettings = false,
    this.fileSizeBytes = 0,
    this.exportDuration = Duration.zero,
  });

  String get formattedFileSize {
    if (fileSizeBytes < 1024) return '${fileSizeBytes}B';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(1)}KB';
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// 导入结果
@immutable
class ImportResult {
  final bool success;
  final List<String> errors;
  final List<String> warnings;
  final ImportStatistics statistics;

  const ImportResult({
    required this.success,
    this.errors = const [],
    this.warnings = const [],
    required this.statistics,
  });

  factory ImportResult.success(ImportStatistics statistics, {List<String>? warnings}) {
    return ImportResult(
      success: true,
      warnings: warnings ?? [],
      statistics: statistics,
    );
  }

  factory ImportResult.failed(List<String> errors) {
    return ImportResult(
      success: false,
      errors: errors,
      statistics: const ImportStatistics(),
    );
  }
}

/// 导入统计信息
@immutable
class ImportStatistics {
  final int providersImported;
  final int assistantsImported;
  final int providersSkipped;
  final int assistantsSkipped;
  final int conflictsResolved;
  final bool preferencesImported;
  final bool settingsImported;
  final Duration importDuration;

  const ImportStatistics({
    this.providersImported = 0,
    this.assistantsImported = 0,
    this.providersSkipped = 0,
    this.assistantsSkipped = 0,
    this.conflictsResolved = 0,
    this.preferencesImported = false,
    this.settingsImported = false,
    this.importDuration = Duration.zero,
  });

  int get totalImported => providersImported + assistantsImported;
  int get totalSkipped => providersSkipped + assistantsSkipped;

  ImportStatistics copyWith({
    int? providersImported,
    int? assistantsImported,
    int? providersSkipped,
    int? assistantsSkipped,
    int? conflictsResolved,
    bool? preferencesImported,
    bool? settingsImported,
    Duration? importDuration,
  }) {
    return ImportStatistics(
      providersImported: providersImported ?? this.providersImported,
      assistantsImported: assistantsImported ?? this.assistantsImported,
      providersSkipped: providersSkipped ?? this.providersSkipped,
      assistantsSkipped: assistantsSkipped ?? this.assistantsSkipped,
      conflictsResolved: conflictsResolved ?? this.conflictsResolved,
      preferencesImported: preferencesImported ?? this.preferencesImported,
      settingsImported: settingsImported ?? this.settingsImported,
      importDuration: importDuration ?? this.importDuration,
    );
  }
}

/// 导入预览
@immutable
class ImportPreview {
  final ConfigurationStatistics statistics;
  final List<ProviderPreview> providers;
  final List<AssistantPreview> assistants;
  final bool hasPreferences;
  final bool hasSettings;
  final List<ConflictInfo> conflicts;
  final ValidationResult validation;

  const ImportPreview({
    required this.statistics,
    this.providers = const [],
    this.assistants = const [],
    this.hasPreferences = false,
    this.hasSettings = false,
    this.conflicts = const [],
    required this.validation,
  });

  factory ImportPreview.fromConfigData(ConfigurationData configData) {
    // 这里应该实现实际的预览逻辑
    // 暂时返回基本信息
    return ImportPreview(
      statistics: configData.statistics,
      validation: const ValidationResult(isValid: true),
    );
  }

  bool get hasConflicts => conflicts.isNotEmpty;
  bool get isValid => validation.isValid;
}

/// 配置统计信息
@immutable
class ConfigurationStatistics {
  final int providerCount;
  final int assistantCount;
  final bool hasPreferences;
  final bool hasSettings;
  final int totalSize;

  const ConfigurationStatistics({
    this.providerCount = 0,
    this.assistantCount = 0,
    this.hasPreferences = false,
    this.hasSettings = false,
    this.totalSize = 0,
  });
}

/// 提供商预览信息
@immutable
class ProviderPreview {
  final String id;
  final String name;
  final String type;
  final bool isEnabled;
  final int modelCount;
  final bool hasConflict;

  const ProviderPreview({
    required this.id,
    required this.name,
    required this.type,
    required this.isEnabled,
    required this.modelCount,
    this.hasConflict = false,
  });
}

/// 助手预览信息
@immutable
class AssistantPreview {
  final String id;
  final String name;
  final String description;
  final bool isEnabled;
  final bool hasConflict;

  const AssistantPreview({
    required this.id,
    required this.name,
    required this.description,
    required this.isEnabled,
    this.hasConflict = false,
  });
}

/// 冲突信息
@immutable
class ConflictInfo {
  final String type; // 'provider' | 'assistant' | 'setting'
  final String id;
  final String name;
  final String description;
  final ConflictResolutionStrategy suggestedStrategy;

  const ConflictInfo({
    required this.type,
    required this.id,
    required this.name,
    required this.description,
    required this.suggestedStrategy,
  });
}

/// 验证结果
@immutable
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });
}

/// 用户偏好设置（临时定义，应该从实际的设置模型中导入）
@immutable
class UserPreferences {
  final String? defaultTheme;
  final String? defaultLanguage;
  final Map<String, dynamic> customSettings;

  const UserPreferences({
    this.defaultTheme,
    this.defaultLanguage,
    this.customSettings = const {},
  });

  Map<String, dynamic> toJson() => {
    'defaultTheme': defaultTheme,
    'defaultLanguage': defaultLanguage,
    'customSettings': customSettings,
  };

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      defaultTheme: json['defaultTheme'] as String?,
      defaultLanguage: json['defaultLanguage'] as String?,
      customSettings: Map<String, dynamic>.from(json['customSettings'] as Map? ?? {}),
    );
  }
}

/// 应用设置（临时定义，应该从实际的设置模型中导入）
@immutable
class AppSettings {
  final bool enableAnalytics;
  final bool enableCrashReporting;
  final Map<String, dynamic> advancedSettings;

  const AppSettings({
    this.enableAnalytics = false,
    this.enableCrashReporting = false,
    this.advancedSettings = const {},
  });

  Map<String, dynamic> toJson() => {
    'enableAnalytics': enableAnalytics,
    'enableCrashReporting': enableCrashReporting,
    'advancedSettings': advancedSettings,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      enableAnalytics: json['enableAnalytics'] as bool? ?? false,
      enableCrashReporting: json['enableCrashReporting'] as bool? ?? false,
      advancedSettings: Map<String, dynamic>.from(json['advancedSettings'] as Map? ?? {}),
    );
  }
}
