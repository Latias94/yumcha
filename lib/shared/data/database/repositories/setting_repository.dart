import 'package:drift/drift.dart';
import '../database.dart';
import '../../../../features/settings/domain/entities/app_setting.dart';

/// 设置数据访问层
class SettingRepository {
  final AppDatabase _database;

  SettingRepository(this._database);

  /// 获取所有设置
  Future<List<AppSetting>> getAllSettings() async {
    final query = _database.select(_database.settings);
    final results = await query.get();
    return results.map((data) => AppSetting.fromData(data)).toList();
  }

  /// 根据键获取设置
  Future<AppSetting?> getSetting(String key) async {
    final query = _database.select(_database.settings)
      ..where((tbl) => tbl.key.equals(key));
    final result = await query.getSingleOrNull();
    return result != null ? AppSetting.fromData(result) : null;
  }

  /// 获取类型化的设置值
  Future<T?> getSettingValue<T>(String key) async {
    final setting = await getSetting(key);
    return setting?.getValue<T>();
  }

  /// 设置值
  Future<void> setSetting<T>({
    required String key,
    required T value,
    String? description,
  }) async {
    final setting = AppSetting.create(
      key: key,
      value: value,
      description: description,
    );

    await _database.into(_database.settings).insertOnConflictUpdate(
          SettingsCompanion(
            key: Value(setting.key),
            value: Value(setting.value),
            type: Value(setting.type.toString()),
            description: Value(setting.description),
            createdAt: Value(setting.createdAt),
            updatedAt: Value(setting.updatedAt),
          ),
        );
  }

  /// 更新设置值
  Future<void> updateSetting<T>(String key, T value) async {
    final existingSetting = await getSetting(key);
    if (existingSetting != null) {
      final updatedSetting = existingSetting.updateValue(value);
      await _database.update(_database.settings).replace(
            SettingsCompanion(
              key: Value(updatedSetting.key),
              value: Value(updatedSetting.value),
              type: Value(updatedSetting.type.toString()),
              description: Value(updatedSetting.description),
              createdAt: Value(updatedSetting.createdAt),
              updatedAt: Value(updatedSetting.updatedAt),
            ),
          );
    } else {
      await setSetting(key: key, value: value);
    }
  }

  /// 删除设置
  Future<void> deleteSetting(String key) async {
    await (_database.delete(
      _database.settings,
    )..where((tbl) => tbl.key.equals(key)))
        .go();
  }

  /// 批量设置
  Future<void> setMultipleSettings(Map<String, dynamic> settings) async {
    await _database.transaction(() async {
      for (final entry in settings.entries) {
        await setSetting(key: entry.key, value: entry.value);
      }
    });
  }

  /// 根据键前缀获取设置
  Future<List<AppSetting>> getSettingsByPrefix(String prefix) async {
    final query = _database.select(_database.settings)
      ..where((tbl) => tbl.key.like('$prefix%'));
    final results = await query.get();
    return results.map((data) => AppSetting.fromData(data)).toList();
  }

  /// 检查设置是否存在
  Future<bool> hasSettingKey(String key) async {
    final query = _database.select(_database.settings)
      ..where((tbl) => tbl.key.equals(key));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  /// 获取设置数量
  Future<int> getSettingsCount() async {
    final query = _database.selectOnly(_database.settings)
      ..addColumns([_database.settings.key.count()]);
    final result = await query.getSingle();
    return result.read(_database.settings.key.count()) ?? 0;
  }

  /// 清空所有设置
  Future<void> clearAllSettings() async {
    await _database.delete(_database.settings).go();
  }

  /// 导出设置为Map
  Future<Map<String, dynamic>> exportSettings() async {
    final settings = await getAllSettings();
    final result = <String, dynamic>{};
    for (final setting in settings) {
      result[setting.key] = setting.getValue();
    }
    return result;
  }

  /// 从Map导入设置
  Future<void> importSettings(Map<String, dynamic> settingsMap) async {
    await _database.transaction(() async {
      for (final entry in settingsMap.entries) {
        await setSetting(key: entry.key, value: entry.value);
      }
    });
  }

  // === 便捷方法：默认模型设置 ===

  /// 获取默认聊天模型
  Future<DefaultModelConfig?> getDefaultChatModel() async {
    final value = await getSettingValue<Map<String, dynamic>>(
      SettingKeys.defaultChatModel,
    );
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
  Future<DefaultModelConfig?> getDefaultTitleModel() async {
    final value = await getSettingValue<Map<String, dynamic>>(
      SettingKeys.defaultTitleModel,
    );
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
  Future<DefaultModelConfig?> getDefaultTranslationModel() async {
    final value = await getSettingValue<Map<String, dynamic>>(
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
  Future<DefaultModelConfig?> getDefaultSummaryModel() async {
    final value = await getSettingValue<Map<String, dynamic>>(
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

  // === 便捷方法：主题设置 ===

  /// 获取颜色模式
  Future<int?> getColorMode() async {
    return await getSettingValue<int>(SettingKeys.colorMode);
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
  Future<bool?> getDynamicColorEnabled() async {
    return await getSettingValue<bool>(SettingKeys.dynamicColorEnabled);
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
  Future<int?> getThemeScheme() async {
    return await getSettingValue<int>(SettingKeys.themeScheme);
  }

  /// 设置主题方案
  Future<void> setThemeScheme(int scheme) async {
    await setSetting(
      key: SettingKeys.themeScheme,
      value: scheme,
      description: '应用主题方案',
    );
  }

  // === 便捷方法：聊天设置 ===

  /// 获取聊天气泡样式
  Future<String?> getChatBubbleStyle() async {
    return await getSettingValue<String>(SettingKeys.chatBubbleStyle);
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
  Future<bool?> getDebugMode() async {
    return await getSettingValue<bool>(SettingKeys.debugMode);
  }

  /// 设置调试模式状态
  Future<void> setDebugMode(bool enabled) async {
    await setSetting(
      key: SettingKeys.debugMode,
      value: enabled,
      description: '调试模式启用状态',
    );
  }

  // === 便捷方法：MCP 设置 ===

  /// 获取 MCP 启用状态
  Future<bool?> getMcpEnabled() async {
    return await getSettingValue<bool>(SettingKeys.mcpEnabled);
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
  Future<Map<String, dynamic>?> getMcpServers() async {
    return await getSettingValue<Map<String, dynamic>>(SettingKeys.mcpServers);
  }

  /// 设置 MCP 服务器配置
  Future<void> setMcpServers(Map<String, dynamic> config) async {
    await setSetting(
      key: SettingKeys.mcpServers,
      value: config,
      description: 'MCP 服务器配置',
    );
  }
}
