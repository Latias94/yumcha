import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/services/logger_service.dart';
import '../../../features/ai_management/domain/entities/ai_assistant.dart';
import '../../../features/ai_management/domain/entities/ai_provider.dart';
import '../../../features/ai_management/domain/entities/ai_model.dart';
import 'dependency_providers.dart';

/// 配置持久化数据模型
class PersistedConfiguration {
  final String? lastUsedAssistantId;
  final String? lastUsedProviderId;
  final String? lastUsedModelName;
  final DateTime? lastUpdated;

  const PersistedConfiguration({
    this.lastUsedAssistantId,
    this.lastUsedProviderId,
    this.lastUsedModelName,
    this.lastUpdated,
  });

  PersistedConfiguration copyWith({
    String? lastUsedAssistantId,
    String? lastUsedProviderId,
    String? lastUsedModelName,
    DateTime? lastUpdated,
  }) {
    return PersistedConfiguration(
      lastUsedAssistantId: lastUsedAssistantId ?? this.lastUsedAssistantId,
      lastUsedProviderId: lastUsedProviderId ?? this.lastUsedProviderId,
      lastUsedModelName: lastUsedModelName ?? this.lastUsedModelName,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get hasCompleteConfiguration =>
      lastUsedAssistantId != null &&
      lastUsedProviderId != null &&
      lastUsedModelName != null;
}

/// 配置持久化管理器 - 专门负责用户配置的持久化
///
/// 职责：
/// - 💾 保存用户的最后使用配置
/// - 🔄 恢复用户的配置偏好
/// - 🎯 提供配置的默认值
/// - 📊 配置使用统计
class ConfigurationPersistenceNotifier
    extends StateNotifier<PersistedConfiguration> {
  ConfigurationPersistenceNotifier(this._ref)
      : super(const PersistedConfiguration()) {
    _loadConfiguration();
  }

  final Ref _ref;
  final LoggerService _logger = LoggerService();

  /// 加载持久化配置
  Future<void> _loadConfiguration() async {
    try {
      final preferenceService = _ref.read(preferenceServiceProvider);
      final assistantId = await preferenceService.getLastUsedAssistantId();
      final modelConfig = await preferenceService.getLastUsedModel();

      state = PersistedConfiguration(
        lastUsedAssistantId: assistantId,
        lastUsedProviderId: modelConfig?['providerId'],
        lastUsedModelName: modelConfig?['modelName'],
        lastUpdated: DateTime.now(),
      );

      _logger.info('配置加载成功', {
        'assistantId': assistantId,
        'providerId': modelConfig?['providerId'],
        'modelName': modelConfig?['modelName'],
      });
    } catch (e) {
      _logger.error('配置加载失败', {'error': e.toString()});
    }
  }

  /// 保存助手配置
  Future<void> saveAssistantConfiguration(AiAssistant assistant) async {
    try {
      final preferenceService = _ref.read(preferenceServiceProvider);
      await preferenceService.saveLastUsedAssistantId(assistant.id);

      state = state.copyWith(
        lastUsedAssistantId: assistant.id,
        lastUpdated: DateTime.now(),
      );

      _logger.info('助手配置保存成功', {'assistantId': assistant.id});
    } catch (e) {
      _logger.error('助手配置保存失败', {
        'assistantId': assistant.id,
        'error': e.toString(),
      });
    }
  }

  /// 保存模型配置
  Future<void> saveModelConfiguration(
      AiProvider provider, AiModel model) async {
    try {
      final preferenceService = _ref.read(preferenceServiceProvider);
      await preferenceService.saveLastUsedModel(provider.id, model.name);

      state = state.copyWith(
        lastUsedProviderId: provider.id,
        lastUsedModelName: model.name,
        lastUpdated: DateTime.now(),
      );

      _logger.info('模型配置保存成功', {
        'providerId': provider.id,
        'modelName': model.name,
      });
    } catch (e) {
      _logger.error('模型配置保存失败', {
        'providerId': provider.id,
        'modelName': model.name,
        'error': e.toString(),
      });
    }
  }

  /// 保存完整配置
  Future<void> saveCompleteConfiguration({
    required AiAssistant assistant,
    required AiProvider provider,
    required AiModel model,
  }) async {
    try {
      final preferenceService = _ref.read(preferenceServiceProvider);
      // 批量保存，减少I/O操作
      await Future.wait([
        preferenceService.saveLastUsedAssistantId(assistant.id),
        preferenceService.saveLastUsedModel(provider.id, model.name),
      ]);

      state = PersistedConfiguration(
        lastUsedAssistantId: assistant.id,
        lastUsedProviderId: provider.id,
        lastUsedModelName: model.name,
        lastUpdated: DateTime.now(),
      );

      _logger.info('完整配置保存成功', {
        'assistantId': assistant.id,
        'providerId': provider.id,
        'modelName': model.name,
      });
    } catch (e) {
      _logger.error('完整配置保存失败', {'error': e.toString()});
    }
  }

  /// 清除配置
  Future<void> clearConfiguration() async {
    try {
      final preferenceService = _ref.read(preferenceServiceProvider);
      await Future.wait([
        preferenceService.clearModelPreferences(),
        preferenceService.clearAssistantPreferences(),
      ]);

      state = const PersistedConfiguration();
      _logger.info('配置清除成功');
    } catch (e) {
      _logger.error('配置清除失败', {'error': e.toString()});
    }
  }

  /// 获取配置摘要
  Map<String, dynamic> getConfigurationSummary() {
    return {
      'hasAssistant': state.lastUsedAssistantId != null,
      'hasProvider': state.lastUsedProviderId != null,
      'hasModel': state.lastUsedModelName != null,
      'isComplete': state.hasCompleteConfiguration,
      'lastUpdated': state.lastUpdated?.toIso8601String(),
    };
  }

  /// 刷新配置
  Future<void> refresh() async {
    await _loadConfiguration();
  }
}

/// 配置持久化Provider
final configurationPersistenceNotifierProvider = StateNotifierProvider<
    ConfigurationPersistenceNotifier, PersistedConfiguration>(
  (ref) => ConfigurationPersistenceNotifier(ref),
);

/// 获取最后使用的助手ID
final lastUsedAssistantIdProvider = Provider<String?>((ref) {
  final config = ref.watch(configurationPersistenceNotifierProvider);
  return config.lastUsedAssistantId;
});

/// 获取最后使用的提供商ID
final lastUsedProviderIdProvider = Provider<String?>((ref) {
  final config = ref.watch(configurationPersistenceNotifierProvider);
  return config.lastUsedProviderId;
});

/// 获取最后使用的模型名称
final lastUsedModelNameProvider = Provider<String?>((ref) {
  final config = ref.watch(configurationPersistenceNotifierProvider);
  return config.lastUsedModelName;
});

/// 检查是否有完整配置
final hasCompleteConfigurationProvider = Provider<bool>((ref) {
  final config = ref.watch(configurationPersistenceNotifierProvider);
  return config.hasCompleteConfiguration;
});
