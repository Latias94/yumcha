import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yumcha/features/settings/domain/entities/app_setting.dart';
import 'package:yumcha/features/settings/presentation/providers/settings_notifier.dart';
import '../../domain/entities/multimedia_settings.dart';
import '../../../../shared/data/database/repositories/setting_repository.dart';
import '../../../../shared/presentation/providers/dependency_providers.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';
import '../../../../core/utils/error_handler.dart';

/// 多媒体设置状态管理器
///
/// 负责管理应用中所有多媒体功能的设置和配置。
/// 遵循Riverpod最佳实践，使用响应式监听模式。
///
/// 核心特性：
/// - 🎨 **图像生成设置**: AI图像创作功能的开关和配置
/// - 🎵 **语音处理设置**: TTS/STT功能的配置
/// - 🔍 **Web搜索设置**: 网络搜索功能的配置
/// - 🖼️ **多模态设置**: 图像分析等多模态功能配置
/// - 🌐 **网络配置**: HTTP代理等网络相关设置
/// - ⚙️ **智能检测**: 自动检测用户意图的设置
///
/// 设计原则：
/// - 使用getter方式获取依赖，避免late final重复初始化问题
/// - 实现响应式监听，自动同步相关状态变化
/// - 完整的参数验证和错误处理
/// - 统一的日志记录和错误包装
class MultimediaSettingsNotifier
    extends StateNotifier<MultimediaSettingsState> {
  MultimediaSettingsNotifier(this._ref)
      : super(const MultimediaSettingsState()) {
    _initialize();
    _setupListeners();
  }

  final Ref _ref;
  final LoggerService _logger = LoggerService();

  /// 获取Repository实例 - 使用getter避免late final问题
  SettingRepository get _repository => _ref.read(settingRepositoryProvider);

  /// 初始化多媒体设置
  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true);

      // 加载所有多媒体相关设置
      await _loadMultimediaSettings();

      _logger.info('多媒体设置初始化成功');
    } catch (error, stackTrace) {
      _logger.error('多媒体设置初始化失败', {'error': error.toString()});
      state = state.copyWith(
        isLoading: false,
        error: '多媒体设置初始化失败: $error',
      );
    }
  }

  /// 设置监听器
  void _setupListeners() {
    // 监听基础设置变化
    _ref.listen(settingsNotifierProvider, (previous, next) {
      _handleBaseSettingsChanged(previous, next);
    });
  }

  /// 处理基础设置变化
  void _handleBaseSettingsChanged(
    SettingsState? previous,
    SettingsState next,
  ) {
    // 当基础设置加载完成时，重新加载多媒体设置
    if (previous?.isLoading == true && next.isLoading == false) {
      _loadMultimediaSettings();
    }
  }

  /// 加载多媒体设置
  Future<void> _loadMultimediaSettings() async {
    try {
      // 加载各项多媒体设置
      final isEnabled = await _repository.getSettingValue<bool>(
            SettingKeys.multimediaEnabled,
          ) ??
          false;

      final imageGenerationEnabled = await _repository.getSettingValue<bool>(
            SettingKeys.imageGenerationEnabled,
          ) ??
          true;

      final ttsEnabled = await _repository.getSettingValue<bool>(
            SettingKeys.ttsEnabled,
          ) ??
          true;

      final sttEnabled = await _repository.getSettingValue<bool>(
            SettingKeys.sttEnabled,
          ) ??
          true;

      final webSearchEnabled = await _repository.getSettingValue<bool>(
            SettingKeys.webSearchEnabled,
          ) ??
          true;

      final imageAnalysisEnabled = await _repository.getSettingValue<bool>(
            SettingKeys.imageAnalysisEnabled,
          ) ??
          true;

      final autoDetectEnabled = await _repository.getSettingValue<bool>(
            SettingKeys.autoDetectMultimedia,
          ) ??
          true;

      final httpProxyUrl = await _repository.getSettingValue<String>(
        SettingKeys.httpProxyUrl,
      );

      final connectionTimeout = await _repository.getSettingValue<int>(
            SettingKeys.connectionTimeout,
          ) ??
          30;

      final maxImageSize = await _repository.getSettingValue<int>(
            SettingKeys.maxImageSize,
          ) ??
          10; // 10MB

      final maxAudioDuration = await _repository.getSettingValue<int>(
            SettingKeys.maxAudioDuration,
          ) ??
          300; // 5分钟

      // 更新状态
      state = MultimediaSettingsState(
        isLoading: false,
        isEnabled: isEnabled,
        imageGenerationEnabled: imageGenerationEnabled,
        ttsEnabled: ttsEnabled,
        sttEnabled: sttEnabled,
        webSearchEnabled: webSearchEnabled,
        imageAnalysisEnabled: imageAnalysisEnabled,
        autoDetectEnabled: autoDetectEnabled,
        httpProxyUrl: httpProxyUrl,
        connectionTimeout: connectionTimeout,
        maxImageSize: maxImageSize,
        maxAudioDuration: maxAudioDuration,
      );

      _logger.debug('多媒体设置加载完成', {
        'isEnabled': isEnabled,
        'imageGeneration': imageGenerationEnabled,
        'tts': ttsEnabled,
        'stt': sttEnabled,
        'webSearch': webSearchEnabled,
        'imageAnalysis': imageAnalysisEnabled,
      });
    } catch (error, stackTrace) {
      _logger.error('加载多媒体设置失败', {'error': error.toString()});
      state = state.copyWith(
        isLoading: false,
        error: '加载多媒体设置失败: $error',
      );
    }
  }

  /// 启用/禁用多媒体功能
  Future<void> setMultimediaEnabled(bool enabled) async {
    try {
      await _repository.setSetting(
        key: SettingKeys.multimediaEnabled,
        value: enabled,
        description: '多媒体功能总开关',
      );

      state = state.copyWith(isEnabled: enabled);

      _logger.info('多媒体功能开关更新', {'enabled': enabled});
    } catch (error, stackTrace) {
      _logger.error('更新多媒体功能开关失败', {'error': error.toString()});
      throw DatabaseError(
        message: '更新多媒体功能开关失败',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// 设置图像生成功能
  Future<void> setImageGenerationEnabled(bool enabled) async {
    try {
      await _repository.setSetting(
        key: SettingKeys.imageGenerationEnabled,
        value: enabled,
        description: 'AI图像生成功能开关',
      );

      state = state.copyWith(imageGenerationEnabled: enabled);

      _logger.info('图像生成功能开关更新', {'enabled': enabled});
    } catch (error, stackTrace) {
      _logger.error('更新图像生成功能开关失败', {'error': error.toString()});
      rethrow;
    }
  }

  /// 设置TTS功能
  Future<void> setTtsEnabled(bool enabled) async {
    try {
      await _repository.setSetting(
        key: SettingKeys.ttsEnabled,
        value: enabled,
        description: '文字转语音功能开关',
      );

      state = state.copyWith(ttsEnabled: enabled);

      _logger.info('TTS功能开关更新', {'enabled': enabled});
    } catch (error, stackTrace) {
      _logger.error('更新TTS功能开关失败', {'error': error.toString()});
      rethrow;
    }
  }

  /// 设置STT功能
  Future<void> setSttEnabled(bool enabled) async {
    try {
      await _repository.setSetting(
        key: SettingKeys.sttEnabled,
        value: enabled,
        description: '语音转文字功能开关',
      );

      state = state.copyWith(sttEnabled: enabled);

      _logger.info('STT功能开关更新', {'enabled': enabled});
    } catch (error, stackTrace) {
      _logger.error('更新STT功能开关失败', {'error': error.toString()});
      rethrow;
    }
  }

  /// 设置Web搜索功能
  Future<void> setWebSearchEnabled(bool enabled) async {
    try {
      await _repository.setSetting(
        key: SettingKeys.webSearchEnabled,
        value: enabled,
        description: 'Web搜索功能开关',
      );

      state = state.copyWith(webSearchEnabled: enabled);

      _logger.info('Web搜索功能开关更新', {'enabled': enabled});
    } catch (error, stackTrace) {
      _logger.error('更新Web搜索功能开关失败', {'error': error.toString()});
      rethrow;
    }
  }

  /// 设置图像分析功能
  Future<void> setImageAnalysisEnabled(bool enabled) async {
    try {
      await _repository.setSetting(
        key: SettingKeys.imageAnalysisEnabled,
        value: enabled,
        description: '图像分析功能开关',
      );

      state = state.copyWith(imageAnalysisEnabled: enabled);

      _logger.info('图像分析功能开关更新', {'enabled': enabled});
    } catch (error, stackTrace) {
      _logger.error('更新图像分析功能开关失败', {'error': error.toString()});
      rethrow;
    }
  }

  /// 设置自动检测功能
  Future<void> setAutoDetectEnabled(bool enabled) async {
    try {
      await _repository.setSetting(
        key: SettingKeys.autoDetectMultimedia,
        value: enabled,
        description: '自动检测多媒体需求功能开关',
      );

      state = state.copyWith(autoDetectEnabled: enabled);

      _logger.info('自动检测功能开关更新', {'enabled': enabled});
    } catch (error, stackTrace) {
      _logger.error('更新自动检测功能开关失败', {'error': error.toString()});
      rethrow;
    }
  }

  /// 设置HTTP代理
  Future<void> setHttpProxyUrl(String? proxyUrl) async {
    try {
      // 验证代理URL格式
      if (proxyUrl != null && proxyUrl.isNotEmpty) {
        final uri = Uri.tryParse(proxyUrl);
        if (uri == null || !uri.scheme.startsWith('http')) {
          throw ValidationError(
            message: '无效的代理URL格式',
            code: 'INVALID_PROXY_URL',
          );
        }
      }

      await _repository.setSetting(
        key: SettingKeys.httpProxyUrl,
        value: proxyUrl,
        description: 'HTTP代理服务器URL',
      );

      state = state.copyWith(httpProxyUrl: proxyUrl);

      _logger.info('HTTP代理URL更新', {'proxyUrl': proxyUrl});
    } catch (error, stackTrace) {
      _logger.error('更新HTTP代理URL失败', {'error': error.toString()});
      rethrow;
    }
  }

  /// 设置连接超时时间
  Future<void> setConnectionTimeout(int timeout) async {
    try {
      // 验证超时时间范围
      if (timeout < 5 || timeout > 300) {
        throw ValidationError(
          message: '连接超时时间必须在5-300秒之间',
          code: 'INVALID_TIMEOUT',
        );
      }

      await _repository.setSetting(
        key: SettingKeys.connectionTimeout,
        value: timeout,
        description: '网络连接超时时间（秒）',
      );

      state = state.copyWith(connectionTimeout: timeout);

      _logger.info('连接超时时间更新', {'timeout': timeout});
    } catch (error, stackTrace) {
      _logger.error('更新连接超时时间失败', {'error': error.toString()});
      rethrow;
    }
  }

  /// 刷新设置
  Future<void> refresh() async {
    await _loadMultimediaSettings();
  }

  /// 重置所有多媒体设置为默认值
  Future<void> resetToDefaults() async {
    try {
      state = state.copyWith(isLoading: true);

      // 重置所有设置为默认值
      await _repository.setMultipleSettings({
        SettingKeys.multimediaEnabled: false,
        SettingKeys.imageGenerationEnabled: true,
        SettingKeys.ttsEnabled: true,
        SettingKeys.sttEnabled: true,
        SettingKeys.webSearchEnabled: true,
        SettingKeys.imageAnalysisEnabled: true,
        SettingKeys.autoDetectMultimedia: true,
        SettingKeys.httpProxyUrl: null,
        SettingKeys.connectionTimeout: 30,
        SettingKeys.maxImageSize: 10,
        SettingKeys.maxAudioDuration: 300,
      });

      // 重新加载设置
      await _loadMultimediaSettings();

      _logger.info('多媒体设置已重置为默认值');
    } catch (error, stackTrace) {
      _logger.error('重置多媒体设置失败', {'error': error.toString()});
      state = state.copyWith(
        isLoading: false,
        error: '重置多媒体设置失败: $error',
      );
    }
  }
}

/// 多媒体设置Provider
final multimediaSettingsProvider =
    StateNotifierProvider<MultimediaSettingsNotifier, MultimediaSettingsState>(
  (ref) => MultimediaSettingsNotifier(ref),
);

/// 检查多媒体功能是否启用的便捷Provider
final isMultimediaEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(multimediaSettingsProvider);
  return settings.isEnabled;
});

/// 检查特定多媒体功能是否可用的Provider
final multimediaCapabilityProvider =
    Provider.family<bool, String>((ref, capability) {
  final settings = ref.watch(multimediaSettingsProvider);

  if (!settings.isEnabled) return false;

  switch (capability) {
    case 'imageGeneration':
      return settings.imageGenerationEnabled;
    case 'tts':
      return settings.ttsEnabled;
    case 'stt':
      return settings.sttEnabled;
    case 'webSearch':
      return settings.webSearchEnabled;
    case 'imageAnalysis':
      return settings.imageAnalysisEnabled;
    default:
      return false;
  }
});
