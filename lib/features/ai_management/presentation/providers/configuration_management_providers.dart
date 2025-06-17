// 🔄 配置管理Provider
//
// 提供配置导入导出、备份恢复、高级管理等功能的Provider。
// 统一管理配置相关的状态和服务。
//
// 🎯 **核心功能**:
// - 📤 **导出服务**: 配置导出功能的Provider
// - 📥 **导入服务**: 配置导入功能的Provider
// - 💾 **备份服务**: 配置备份恢复的Provider
// - 🔧 **高级服务**: 高级配置管理的Provider
// - 📊 **状态管理**: 配置操作状态的统一管理

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/services/configuration_export_service.dart';
import '../../infrastructure/services/configuration_import_service.dart';
import '../../infrastructure/services/configuration_backup_service.dart';
import '../../infrastructure/services/advanced_configuration_service.dart';
import '../../domain/entities/configuration_backup_models.dart';
import '../../domain/entities/configuration_export_models.dart';

/// 配置导出服务Provider
final configurationExportServiceProvider = Provider<ConfigurationExportService>(
  (ref) => ConfigurationExportService(ref),
);

/// 配置导入服务Provider
final configurationImportServiceProvider = Provider<ConfigurationImportService>(
  (ref) => ConfigurationImportService(ref),
);

/// 配置备份服务Provider
final configurationBackupServiceProvider = Provider<ConfigurationBackupService>(
  (ref) => ConfigurationBackupService(ref),
);

/// 高级配置管理服务Provider
final advancedConfigurationServiceProvider =
    Provider<AdvancedConfigurationService>(
  (ref) => AdvancedConfigurationService(ref),
);

/// 备份列表Provider
final backupListProvider =
    FutureProvider.autoDispose<List<BackupInfo>>((ref) async {
  final backupService = ref.read(configurationBackupServiceProvider);
  return await backupService.getBackupList();
});

/// 配置分析Provider
final configurationAnalysisProvider =
    FutureProvider.autoDispose<ConfigurationAnalysis>((ref) async {
  final advancedService = ref.read(advancedConfigurationServiceProvider);
  return await advancedService.analyzeConfiguration();
});

/// 配置模板Provider
final configurationTemplatesProvider =
    Provider<List<ConfigurationTemplate>>((ref) {
  final advancedService = ref.read(advancedConfigurationServiceProvider);
  return advancedService.getBuiltInTemplates();
});

/// 配置验证Provider
final configurationValidationProvider =
    FutureProvider.autoDispose<ValidationResult>((ref) async {
  final advancedService = ref.read(advancedConfigurationServiceProvider);
  return await advancedService.validateConfigurationIntegrity();
});

/// 导出操作状态Provider
class ExportOperationNotifier extends StateNotifier<AsyncValue<ExportResult?>> {
  ExportOperationNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  /// 执行导出操作
  Future<void> exportConfiguration({
    bool includeProviders = true,
    bool includeAssistants = true,
    bool includePreferences = true,
    bool includeSettings = true,
    String? encryptionKey,
    ExportFormat format = ExportFormat.json,
    String? customPath,
  }) async {
    state = const AsyncValue.loading();

    try {
      final exportService = _ref.read(configurationExportServiceProvider);
      final result = await exportService.exportConfiguration(
        includeProviders: includeProviders,
        includeAssistants: includeAssistants,
        includePreferences: includePreferences,
        includeSettings: includeSettings,
        encryptionKey: encryptionKey,
        format: format,
        customPath: customPath,
      );

      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 清除操作结果
  void clearResult() {
    state = const AsyncValue.data(null);
  }
}

final exportOperationProvider =
    StateNotifierProvider<ExportOperationNotifier, AsyncValue<ExportResult?>>(
  (ref) => ExportOperationNotifier(ref),
);

/// 导入操作状态Provider
class ImportOperationNotifier extends StateNotifier<AsyncValue<ImportResult?>> {
  ImportOperationNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  /// 预览导入内容
  Future<ImportPreview?> previewImport(
      String filePath, String? decryptionKey) async {
    try {
      final importService = _ref.read(configurationImportServiceProvider);
      return await importService.previewImport(filePath, decryptionKey);
    } catch (error) {
      return null;
    }
  }

  /// 执行导入操作
  Future<void> importConfiguration(
    String filePath, {
    String? decryptionKey,
    ConflictResolutionStrategy strategy = ConflictResolutionStrategy.ask,
    bool validateBeforeImport = true,
    bool createBackupBeforeImport = true,
  }) async {
    state = const AsyncValue.loading();

    try {
      final importService = _ref.read(configurationImportServiceProvider);
      final result = await importService.importConfiguration(
        filePath,
        decryptionKey: decryptionKey,
        strategy: strategy,
        validateBeforeImport: validateBeforeImport,
        createBackupBeforeImport: createBackupBeforeImport,
      );

      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 清除操作结果
  void clearResult() {
    state = const AsyncValue.data(null);
  }
}

final importOperationProvider =
    StateNotifierProvider<ImportOperationNotifier, AsyncValue<ImportResult?>>(
  (ref) => ImportOperationNotifier(ref),
);

/// 备份操作状态Provider
class BackupOperationNotifier extends StateNotifier<AsyncValue<BackupInfo?>> {
  BackupOperationNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  /// 创建手动备份
  Future<void> createManualBackup({
    String? description,
    List<String>? tags,
    BackupType type = BackupType.full,
  }) async {
    state = const AsyncValue.loading();

    try {
      final backupService = _ref.read(configurationBackupServiceProvider);
      final result = await backupService.createManualBackup(
        description: description,
        tags: tags,
        type: type,
      );

      state = AsyncValue.data(result);

      // 刷新备份列表
      _ref.invalidate(backupListProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 清除操作结果
  void clearResult() {
    state = const AsyncValue.data(null);
  }
}

final backupOperationProvider =
    StateNotifierProvider<BackupOperationNotifier, AsyncValue<BackupInfo?>>(
  (ref) => BackupOperationNotifier(ref),
);

/// 恢复操作状态Provider
class RestoreOperationNotifier
    extends StateNotifier<AsyncValue<RestoreResult?>> {
  RestoreOperationNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  /// 从备份恢复配置
  Future<void> restoreFromBackup(
    String backupId, {
    RestoreOptions? options,
    bool validateBeforeRestore = true,
  }) async {
    state = const AsyncValue.loading();

    try {
      final backupService = _ref.read(configurationBackupServiceProvider);
      final result = await backupService.restoreFromBackup(
        backupId,
        options: options,
        validateBeforeRestore: validateBeforeRestore,
      );

      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 清除操作结果
  void clearResult() {
    state = const AsyncValue.data(null);
  }
}

final restoreOperationProvider =
    StateNotifierProvider<RestoreOperationNotifier, AsyncValue<RestoreResult?>>(
  (ref) => RestoreOperationNotifier(ref),
);

/// 批量操作状态Provider
class BatchOperationNotifier
    extends StateNotifier<AsyncValue<BatchOperationResult?>> {
  BatchOperationNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  /// 批量导入配置
  Future<void> batchImportConfigurations(
    List<String> filePaths, {
    ConflictResolutionStrategy strategy = ConflictResolutionStrategy.ask,
  }) async {
    state = const AsyncValue.loading();

    try {
      final advancedService = _ref.read(advancedConfigurationServiceProvider);
      final result = await advancedService.batchImportConfigurations(
        filePaths,
        strategy: strategy,
      );

      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 清除操作结果
  void clearResult() {
    state = const AsyncValue.data(null);
  }
}

final batchOperationProvider = StateNotifierProvider<BatchOperationNotifier,
    AsyncValue<BatchOperationResult?>>(
  (ref) => BatchOperationNotifier(ref),
);

/// 备份清理操作Provider
class BackupCleanupNotifier extends StateNotifier<AsyncValue<CleanupResult?>> {
  BackupCleanupNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  /// 清理过期备份
  Future<void> cleanupExpiredBackups() async {
    state = const AsyncValue.loading();

    try {
      final backupService = _ref.read(configurationBackupServiceProvider);
      final result = await backupService.cleanupExpiredBackups();

      state = AsyncValue.data(result);

      // 刷新备份列表
      _ref.invalidate(backupListProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 删除指定备份
  Future<void> deleteBackup(String backupId) async {
    try {
      final backupService = _ref.read(configurationBackupServiceProvider);
      await backupService.deleteBackup(backupId);

      // 刷新备份列表
      _ref.invalidate(backupListProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 清除操作结果
  void clearResult() {
    state = const AsyncValue.data(null);
  }
}

final backupCleanupProvider =
    StateNotifierProvider<BackupCleanupNotifier, AsyncValue<CleanupResult?>>(
  (ref) => BackupCleanupNotifier(ref),
);

/// 配置管理主界面状态Provider
class ConfigurationManagementNotifier
    extends StateNotifier<ConfigurationManagementState> {
  ConfigurationManagementNotifier(this._ref)
      : super(const ConfigurationManagementState());

  final Ref _ref;

  /// 设置当前选中的标签页
  void setSelectedTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  /// 设置显示高级选项
  void setShowAdvancedOptions(bool show) {
    state = state.copyWith(showAdvancedOptions: show);
  }

  /// 刷新所有数据
  Future<void> refreshAll() async {
    _ref.invalidate(backupListProvider);
    _ref.invalidate(configurationAnalysisProvider);
    _ref.invalidate(configurationValidationProvider);
  }
}

/// 配置管理状态
class ConfigurationManagementState {
  final int selectedTabIndex;
  final bool showAdvancedOptions;

  const ConfigurationManagementState({
    this.selectedTabIndex = 0,
    this.showAdvancedOptions = false,
  });

  ConfigurationManagementState copyWith({
    int? selectedTabIndex,
    bool? showAdvancedOptions,
  }) {
    return ConfigurationManagementState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      showAdvancedOptions: showAdvancedOptions ?? this.showAdvancedOptions,
    );
  }
}

final configurationManagementProvider = StateNotifierProvider<
    ConfigurationManagementNotifier, ConfigurationManagementState>(
  (ref) => ConfigurationManagementNotifier(ref),
);
