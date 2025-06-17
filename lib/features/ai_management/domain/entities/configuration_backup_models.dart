// 🔄 配置备份恢复数据模型
//
// 定义配置备份恢复功能所需的所有数据模型，包括备份信息、恢复选项、
// 备份类型、触发器等。这些模型确保备份数据的完整性和可靠性。
//
// 🎯 **核心功能**:
// - 💾 **备份信息**: 备份的元数据和状态管理
// - 🔄 **恢复选项**: 灵活的恢复配置和策略
// - 📊 **备份统计**: 备份操作的统计和监控
// - 🕒 **调度管理**: 自动备份的调度和触发
// - 🧹 **清理策略**: 备份文件的生命周期管理
//
// 🛡️ **可靠性特性**:
// - 备份完整性验证
// - 增量备份支持
// - 自动清理机制
// - 恢复前验证

import 'package:flutter/foundation.dart';
import 'configuration_export_models.dart';

/// 备份类型枚举
enum BackupType {
  full('完整备份', '包含所有配置数据'),
  providersOnly('仅提供商', '只备份AI提供商配置'),
  assistantsOnly('仅助手', '只备份AI助手配置'),
  settingsOnly('仅设置', '只备份应用设置'),
  incremental('增量备份', '只备份变更的配置');

  const BackupType(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// 备份触发器枚举
enum BackupTrigger {
  manual('手动备份', '用户主动创建'),
  scheduled('定时备份', '按计划自动创建'),
  beforeRestore('恢复前备份', '恢复操作前自动创建'),
  beforeReset('重置前备份', '重置配置前自动创建'),
  beforeUpdate('更新前备份', '应用更新前自动创建'),
  beforeImport('导入前备份', '导入配置前自动创建');

  const BackupTrigger(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// 备份信息
@immutable
class BackupInfo {
  final String id;
  final BackupType type;
  final String description;
  final List<String> tags;
  final DateTime timestamp;
  final int size;
  final String filePath;
  final bool isAutomatic;
  final BackupTrigger? trigger;
  final String? checksum;
  final BackupMetadata metadata;

  const BackupInfo({
    required this.id,
    required this.type,
    required this.description,
    required this.tags,
    required this.timestamp,
    required this.size,
    required this.filePath,
    required this.isAutomatic,
    this.trigger,
    this.checksum,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'description': description,
        'tags': tags,
        'timestamp': timestamp.toIso8601String(),
        'size': size,
        'filePath': filePath,
        'isAutomatic': isAutomatic,
        'trigger': trigger?.name,
        'checksum': checksum,
        'metadata': metadata.toJson(),
      };

  factory BackupInfo.fromJson(Map<String, dynamic> json) {
    return BackupInfo(
      id: json['id'] as String,
      type: BackupType.values.firstWhere((t) => t.name == json['type']),
      description: json['description'] as String,
      tags: List<String>.from(json['tags'] as List),
      timestamp: DateTime.parse(json['timestamp'] as String),
      size: json['size'] as int,
      filePath: json['filePath'] as String,
      isAutomatic: json['isAutomatic'] as bool,
      trigger: json['trigger'] != null
          ? BackupTrigger.values.firstWhere((t) => t.name == json['trigger'])
          : null,
      checksum: json['checksum'] as String?,
      metadata:
          BackupMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );
  }

  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  bool get isExpired {
    // 备份保留期：手动备份30天，自动备份7天
    final retentionDays = isAutomatic ? 7 : 30;
    return DateTime.now().difference(timestamp).inDays > retentionDays;
  }
}

/// 备份元数据
@immutable
class BackupMetadata {
  final String appVersion;
  final String platform;
  final int providerCount;
  final int assistantCount;
  final bool hasPreferences;
  final bool hasSettings;
  final Map<String, dynamic> customData;

  const BackupMetadata({
    required this.appVersion,
    required this.platform,
    this.providerCount = 0,
    this.assistantCount = 0,
    this.hasPreferences = false,
    this.hasSettings = false,
    this.customData = const {},
  });

  Map<String, dynamic> toJson() => {
        'appVersion': appVersion,
        'platform': platform,
        'providerCount': providerCount,
        'assistantCount': assistantCount,
        'hasPreferences': hasPreferences,
        'hasSettings': hasSettings,
        'customData': customData,
      };

  factory BackupMetadata.fromJson(Map<String, dynamic> json) {
    return BackupMetadata(
      appVersion: json['appVersion'] as String,
      platform: json['platform'] as String,
      providerCount: json['providerCount'] as int? ?? 0,
      assistantCount: json['assistantCount'] as int? ?? 0,
      hasPreferences: json['hasPreferences'] as bool? ?? false,
      hasSettings: json['hasSettings'] as bool? ?? false,
      customData: Map<String, dynamic>.from(json['customData'] as Map? ?? {}),
    );
  }
}

/// 恢复选项
@immutable
class RestoreOptions {
  final bool restoreProviders;
  final bool restoreAssistants;
  final bool restoreSettings;
  final bool restorePreferences;
  final ConflictResolutionStrategy conflictStrategy;
  final bool createBackupBeforeRestore;
  final bool validateBeforeRestore;

  const RestoreOptions({
    this.restoreProviders = true,
    this.restoreAssistants = true,
    this.restoreSettings = true,
    this.restorePreferences = true,
    this.conflictStrategy = ConflictResolutionStrategy.ask,
    this.createBackupBeforeRestore = true,
    this.validateBeforeRestore = true,
  });

  factory RestoreOptions.defaultOptions() => const RestoreOptions();

  factory RestoreOptions.providersOnly() => const RestoreOptions(
        restoreProviders: true,
        restoreAssistants: false,
        restoreSettings: false,
        restorePreferences: false,
      );

  factory RestoreOptions.assistantsOnly() => const RestoreOptions(
        restoreProviders: false,
        restoreAssistants: true,
        restoreSettings: false,
        restorePreferences: false,
      );

  Map<String, dynamic> toJson() => {
        'restoreProviders': restoreProviders,
        'restoreAssistants': restoreAssistants,
        'restoreSettings': restoreSettings,
        'restorePreferences': restorePreferences,
        'conflictStrategy': conflictStrategy.name,
        'createBackupBeforeRestore': createBackupBeforeRestore,
        'validateBeforeRestore': validateBeforeRestore,
      };

  factory RestoreOptions.fromJson(Map<String, dynamic> json) {
    return RestoreOptions(
      restoreProviders: json['restoreProviders'] as bool? ?? true,
      restoreAssistants: json['restoreAssistants'] as bool? ?? true,
      restoreSettings: json['restoreSettings'] as bool? ?? true,
      restorePreferences: json['restorePreferences'] as bool? ?? true,
      conflictStrategy: ConflictResolutionStrategy.values.firstWhere(
        (s) => s.name == json['conflictStrategy'],
        orElse: () => ConflictResolutionStrategy.ask,
      ),
      createBackupBeforeRestore:
          json['createBackupBeforeRestore'] as bool? ?? true,
      validateBeforeRestore: json['validateBeforeRestore'] as bool? ?? true,
    );
  }
}

/// 恢复结果
@immutable
class RestoreResult {
  final bool success;
  final List<String> errors;
  final List<String> warnings;
  final RestoreStatistics statistics;
  final String? backupId; // 恢复前创建的备份ID

  const RestoreResult({
    required this.success,
    this.errors = const [],
    this.warnings = const [],
    required this.statistics,
    this.backupId,
  });

  factory RestoreResult.success(RestoreStatistics statistics,
      {String? backupId}) {
    return RestoreResult(
      success: true,
      statistics: statistics,
      backupId: backupId,
    );
  }

  factory RestoreResult.failed(String error) {
    return RestoreResult(
      success: false,
      errors: [error],
      statistics: const RestoreStatistics(),
    );
  }
}

/// 恢复统计信息
@immutable
class RestoreStatistics {
  final int providersRestored;
  final int assistantsRestored;
  final bool preferencesRestored;
  final bool settingsRestored;
  final int conflictsResolved;
  final Duration restoreDuration;

  const RestoreStatistics({
    this.providersRestored = 0,
    this.assistantsRestored = 0,
    this.preferencesRestored = false,
    this.settingsRestored = false,
    this.conflictsResolved = 0,
    this.restoreDuration = Duration.zero,
  });

  int get totalRestored => providersRestored + assistantsRestored;
}

/// 清理结果
@immutable
class CleanupResult {
  final int deletedCount;
  final int freedSpace;
  final List<String> errors;

  const CleanupResult({
    this.deletedCount = 0,
    this.freedSpace = 0,
    this.errors = const [],
  });

  String get formattedFreedSpace {
    if (freedSpace < 1024) return '${freedSpace}B';
    if (freedSpace < 1024 * 1024)
      return '${(freedSpace / 1024).toStringAsFixed(1)}KB';
    return '${(freedSpace / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// 备份设置
@immutable
class BackupSettings {
  final bool enableAutoBackup;
  final Duration autoBackupInterval;
  final int maxManualBackups;
  final int maxAutoBackups;
  final int retentionDays;
  final bool enableCompression;
  final bool enableEncryption;
  final String? encryptionKey;

  const BackupSettings({
    this.enableAutoBackup = true,
    this.autoBackupInterval = const Duration(days: 1),
    this.maxManualBackups = 10,
    this.maxAutoBackups = 7,
    this.retentionDays = 30,
    this.enableCompression = true,
    this.enableEncryption = false,
    this.encryptionKey,
  });

  Map<String, dynamic> toJson() => {
        'enableAutoBackup': enableAutoBackup,
        'autoBackupIntervalHours': autoBackupInterval.inHours,
        'maxManualBackups': maxManualBackups,
        'maxAutoBackups': maxAutoBackups,
        'retentionDays': retentionDays,
        'enableCompression': enableCompression,
        'enableEncryption': enableEncryption,
        'encryptionKey': encryptionKey,
      };

  factory BackupSettings.fromJson(Map<String, dynamic> json) {
    return BackupSettings(
      enableAutoBackup: json['enableAutoBackup'] as bool? ?? true,
      autoBackupInterval:
          Duration(hours: json['autoBackupIntervalHours'] as int? ?? 24),
      maxManualBackups: json['maxManualBackups'] as int? ?? 10,
      maxAutoBackups: json['maxAutoBackups'] as int? ?? 7,
      retentionDays: json['retentionDays'] as int? ?? 30,
      enableCompression: json['enableCompression'] as bool? ?? true,
      enableEncryption: json['enableEncryption'] as bool? ?? false,
      encryptionKey: json['encryptionKey'] as String?,
    );
  }
}

/// 备份验证结果
@immutable
class BackupValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final BackupMetadata? metadata;

  const BackupValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
    this.metadata,
  });

  factory BackupValidationResult.valid(BackupMetadata metadata) {
    return BackupValidationResult(
      isValid: true,
      metadata: metadata,
    );
  }

  factory BackupValidationResult.invalid(List<String> errors) {
    return BackupValidationResult(
      isValid: false,
      errors: errors,
    );
  }
}
