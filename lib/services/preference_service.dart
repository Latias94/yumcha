import 'package:shared_preferences/shared_preferences.dart';

/// 用户偏好设置服务
class PreferenceService {
  static final PreferenceService _instance = PreferenceService._internal();
  factory PreferenceService() => _instance;
  PreferenceService._internal();

  SharedPreferences? _prefs;

  /// 初始化
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 确保已初始化
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }

  // === 模型相关偏好 ===

  /// 保存最后使用的模型
  Future<void> saveLastUsedModel(String providerId, String modelName) async {
    await _ensureInitialized();
    await _prefs!.setString('last_used_provider_id', providerId);
    await _prefs!.setString('last_used_model_name', modelName);
  }

  /// 获取最后使用的提供商ID
  Future<String?> getLastUsedProviderId() async {
    await _ensureInitialized();
    return _prefs!.getString('last_used_provider_id');
  }

  /// 获取最后使用的模型名称
  Future<String?> getLastUsedModelName() async {
    await _ensureInitialized();
    return _prefs!.getString('last_used_model_name');
  }

  /// 获取最后使用的模型组合
  Future<Map<String, String>?> getLastUsedModel() async {
    await _ensureInitialized();
    final providerId = _prefs!.getString('last_used_provider_id');
    final modelName = _prefs!.getString('last_used_model_name');

    if (providerId != null && modelName != null) {
      return {'providerId': providerId, 'modelName': modelName};
    }

    return null;
  }

  // === 助手相关偏好 ===

  /// 保存最后使用的助手
  Future<void> saveLastUsedAssistant(String assistantId) async {
    await _ensureInitialized();
    await _prefs!.setString('last_used_assistant_id', assistantId);
  }

  /// 保存最后使用的助手ID（别名方法）
  Future<void> saveLastUsedAssistantId(String assistantId) async {
    await saveLastUsedAssistant(assistantId);
  }

  /// 获取最后使用的助手ID
  Future<String?> getLastUsedAssistantId() async {
    await _ensureInitialized();
    return _prefs!.getString('last_used_assistant_id');
  }

  // === 界面相关偏好 ===

  /// 保存主题模式
  Future<void> saveThemeMode(String themeMode) async {
    await _ensureInitialized();
    await _prefs!.setString('theme_mode', themeMode);
  }

  /// 获取主题模式
  Future<String?> getThemeMode() async {
    await _ensureInitialized();
    return _prefs!.getString('theme_mode');
  }

  /// 保存是否开启调试模式
  Future<void> saveDebugMode(bool enabled) async {
    await _ensureInitialized();
    await _prefs!.setBool('debug_mode', enabled);
  }

  /// 获取是否开启调试模式
  Future<bool> getDebugMode() async {
    await _ensureInitialized();
    return _prefs!.getBool('debug_mode') ?? false;
  }

  // === 清理方法 ===

  /// 清除所有偏好设置
  Future<void> clear() async {
    await _ensureInitialized();
    await _prefs!.clear();
  }

  /// 清除模型相关设置
  Future<void> clearModelPreferences() async {
    await _ensureInitialized();
    await _prefs!.remove('last_used_provider_id');
    await _prefs!.remove('last_used_model_name');
  }
}
