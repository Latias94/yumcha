import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_setting.dart';
import '../../domain/entities/mcp_server_config.dart';
import '../../../../shared/data/database/repositories/setting_repository.dart';
import '../../../../shared/infrastructure/services/database_service.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';

/// 设置状态
class SettingsState {
  final Map<String, AppSetting> settings;
  final bool isLoading;
  final String? error;

  const SettingsState({
    this.settings = const {},
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    Map<String, AppSetting>? settings,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// 获取设置值
  T? getValue<T>(String key) {
    final setting = settings[key];
    return setting?.getValue<T>();
  }

  /// 获取设置值，如果不存在则返回默认值
  T getValueOrDefault<T>(String key, T defaultValue) {
    final setting = settings[key];
    return setting?.getValue<T>() ?? defaultValue;
  }

  /// 检查设置是否存在
  bool hasSetting(String key) {
    return settings.containsKey(key);
  }
}

/// 设置管理 Notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState(isLoading: true)) {
    _initialize();
  }

  late final SettingRepository _repository;
  final LoggerService _logger = LoggerService();

  /// 初始化
  Future<void> _initialize() async {
    try {
      _repository = SettingRepository(DatabaseService.instance.database);
      await _loadAllSettings();
    } catch (error) {
      _logger.error('设置初始化失败', {'error': error.toString()});
      state = state.copyWith(isLoading: false, error: '设置初始化失败: $error');
    }
  }

  /// 加载所有设置
  Future<void> _loadAllSettings() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final settingsList = await _repository.getAllSettings();
      final settingsMap = <String, AppSetting>{};
      for (final setting in settingsList) {
        settingsMap[setting.key] = setting;
      }
      state = state.copyWith(settings: settingsMap, isLoading: false);
      _logger.info('设置加载完成', {'count': settingsList.length});
    } catch (error) {
      _logger.error('设置加载失败', {'error': error.toString()});
      state = state.copyWith(isLoading: false, error: '设置加载失败: $error');
    }
  }

  /// 刷新设置
  Future<void> refresh() async {
    await _loadAllSettings();
  }

  /// 设置值
  Future<void> setSetting<T>({
    required String key,
    required T value,
    String? description,
  }) async {
    try {
      await _repository.setSetting(
        key: key,
        value: value,
        description: description,
      );

      // 更新本地状态
      final setting = AppSetting.create(
        key: key,
        value: value,
        description: description,
      );
      final updatedSettings = Map<String, AppSetting>.from(state.settings);
      updatedSettings[key] = setting;
      state = state.copyWith(settings: updatedSettings);

      _logger.debug('设置已更新', {'key': key, 'value': value.toString()});
    } catch (error) {
      _logger.error('设置更新失败', {'key': key, 'error': error.toString()});
      state = state.copyWith(error: '设置更新失败: $error');
    }
  }

  /// 获取设置值
  T? getValue<T>(String key) {
    return state.getValue<T>(key);
  }

  /// 获取设置值，如果不存在则返回默认值
  T getValueOrDefault<T>(String key, T defaultValue) {
    return state.getValueOrDefault<T>(key, defaultValue);
  }

  /// 删除设置
  Future<void> deleteSetting(String key) async {
    try {
      await _repository.deleteSetting(key);
      final updatedSettings = Map<String, AppSetting>.from(state.settings);
      updatedSettings.remove(key);
      state = state.copyWith(settings: updatedSettings);
      _logger.debug('设置已删除', {'key': key});
    } catch (error) {
      _logger.error('设置删除失败', {'key': key, 'error': error.toString()});
      state = state.copyWith(error: '设置删除失败: $error');
    }
  }

  /// 批量设置
  Future<void> setMultipleSettings(Map<String, dynamic> settings) async {
    try {
      await _repository.setMultipleSettings(settings);
      await _loadAllSettings(); // 重新加载所有设置
      _logger.info('批量设置完成', {'count': settings.length});
    } catch (error) {
      _logger.error('批量设置失败', {'error': error.toString()});
      state = state.copyWith(error: '批量设置失败: $error');
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }

  // === 默认模型设置方法 ===

  /// 获取默认聊天模型
  DefaultModelConfig? getDefaultChatModel() {
    final value = getValue<Map<String, dynamic>>(SettingKeys.defaultChatModel);
    return value != null ? DefaultModelConfig.fromJson(value) : null;
  }

  /// 设置默认聊天模型
  Future<void> setDefaultChatModel(DefaultModelConfig config) async {
    await setSetting(
      key: SettingKeys.defaultChatModel,
      value: config.toJson(),
      description: '默认聊天模型配置',
    );
  }

  /// 获取默认标题生成模型
  DefaultModelConfig? getDefaultTitleModel() {
    final value = getValue<Map<String, dynamic>>(SettingKeys.defaultTitleModel);
    return value != null ? DefaultModelConfig.fromJson(value) : null;
  }

  /// 设置默认标题生成模型
  Future<void> setDefaultTitleModel(DefaultModelConfig config) async {
    await setSetting(
      key: SettingKeys.defaultTitleModel,
      value: config.toJson(),
      description: '默认标题生成模型配置',
    );
  }

  /// 获取默认翻译模型
  DefaultModelConfig? getDefaultTranslationModel() {
    final value = getValue<Map<String, dynamic>>(
      SettingKeys.defaultTranslationModel,
    );
    return value != null ? DefaultModelConfig.fromJson(value) : null;
  }

  /// 设置默认翻译模型
  Future<void> setDefaultTranslationModel(DefaultModelConfig config) async {
    await setSetting(
      key: SettingKeys.defaultTranslationModel,
      value: config.toJson(),
      description: '默认翻译模型配置',
    );
  }

  /// 获取默认摘要模型
  DefaultModelConfig? getDefaultSummaryModel() {
    final value = getValue<Map<String, dynamic>>(
      SettingKeys.defaultSummaryModel,
    );
    return value != null ? DefaultModelConfig.fromJson(value) : null;
  }

  /// 设置默认摘要模型
  Future<void> setDefaultSummaryModel(DefaultModelConfig config) async {
    await setSetting(
      key: SettingKeys.defaultSummaryModel,
      value: config.toJson(),
      description: '默认摘要模型配置',
    );
  }

  // === 主题设置方法 ===

  /// 获取颜色模式
  int getColorMode() {
    return getValueOrDefault<int>(SettingKeys.colorMode, 0);
  }

  /// 设置颜色模式
  Future<void> setColorMode(int mode) async {
    await setSetting(
      key: SettingKeys.colorMode,
      value: mode,
      description: '应用颜色模式',
    );
  }

  /// 获取动态颜色启用状态
  bool getDynamicColorEnabled() {
    return getValueOrDefault<bool>(SettingKeys.dynamicColorEnabled, true);
  }

  /// 设置动态颜色启用状态
  Future<void> setDynamicColorEnabled(bool enabled) async {
    await setSetting(
      key: SettingKeys.dynamicColorEnabled,
      value: enabled,
      description: '动态颜色启用状态',
    );
  }

  /// 获取主题方案
  int getThemeScheme() {
    return getValueOrDefault<int>(SettingKeys.themeScheme, 0);
  }

  /// 设置主题方案
  Future<void> setThemeScheme(int scheme) async {
    await setSetting(
      key: SettingKeys.themeScheme,
      value: scheme,
      description: '应用主题方案',
    );
  }

  // === 聊天设置方法 ===

  /// 获取聊天气泡样式
  String getChatBubbleStyle() {
    return getValueOrDefault<String>(SettingKeys.chatBubbleStyle, 'list');
  }

  /// 设置聊天气泡样式
  Future<void> setChatBubbleStyle(String style) async {
    await setSetting(
      key: SettingKeys.chatBubbleStyle,
      value: style,
      description: '聊天气泡样式',
    );
  }

  /// 获取调试模式状态
  bool getDebugMode() {
    return getValueOrDefault<bool>(SettingKeys.debugMode, false);
  }

  /// 设置调试模式状态
  Future<void> setDebugMode(bool enabled) async {
    await setSetting(
      key: SettingKeys.debugMode,
      value: enabled,
      description: '调试模式启用状态',
    );
  }

  // === MCP 设置方法 ===

  /// 获取 MCP 启用状态
  bool getMcpEnabled() {
    return getValueOrDefault<bool>(SettingKeys.mcpEnabled, false);
  }

  /// 设置 MCP 启用状态
  Future<void> setMcpEnabled(bool enabled) async {
    await setSetting(
      key: SettingKeys.mcpEnabled,
      value: enabled,
      description: 'MCP 服务启用状态',
    );
  }

  /// 获取 MCP 服务器配置
  McpServersConfig getMcpServers() {
    final value = getValue<Map<String, dynamic>>(SettingKeys.mcpServers);
    return value != null
        ? McpServersConfig.fromJson(value)
        : McpServersConfig.empty();
  }

  /// 设置 MCP 服务器配置
  Future<void> setMcpServers(McpServersConfig config) async {
    await setSetting(
      key: SettingKeys.mcpServers,
      value: config.toJson(),
      description: 'MCP 服务器配置',
    );
  }
}

/// 设置管理 Provider
final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
      (ref) => SettingsNotifier(),
    );

/// 获取特定设置值的 Provider
final settingValueProvider = Provider.family<dynamic, String>((ref, key) {
  final settings = ref.watch(settingsNotifierProvider);
  return settings.getValue(key);
});

/// 默认模型配置 Providers
final defaultChatModelProvider = Provider<DefaultModelConfig?>((ref) {
  final notifier = ref.read(settingsNotifierProvider.notifier);
  return notifier.getDefaultChatModel();
});

final defaultTitleModelProvider = Provider<DefaultModelConfig?>((ref) {
  final notifier = ref.read(settingsNotifierProvider.notifier);
  return notifier.getDefaultTitleModel();
});

final defaultTranslationModelProvider = Provider<DefaultModelConfig?>((ref) {
  final notifier = ref.read(settingsNotifierProvider.notifier);
  return notifier.getDefaultTranslationModel();
});

final defaultSummaryModelProvider = Provider<DefaultModelConfig?>((ref) {
  final notifier = ref.read(settingsNotifierProvider.notifier);
  return notifier.getDefaultSummaryModel();
});
