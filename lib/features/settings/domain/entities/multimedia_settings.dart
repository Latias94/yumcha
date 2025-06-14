import 'package:flutter/foundation.dart';

/// 多媒体设置状态
///
/// 管理应用中所有多媒体功能的设置和配置状态。
/// 包含各种多媒体功能的开关、网络配置、资源限制等。
@immutable
class MultimediaSettingsState {
  /// 是否正在加载
  final bool isLoading;
  
  /// 错误信息
  final String? error;
  
  /// 多媒体功能总开关
  final bool isEnabled;
  
  /// AI图像生成功能开关
  final bool imageGenerationEnabled;
  
  /// 文字转语音(TTS)功能开关
  final bool ttsEnabled;
  
  /// 语音转文字(STT)功能开关
  final bool sttEnabled;
  
  /// Web搜索功能开关
  final bool webSearchEnabled;
  
  /// 图像分析功能开关
  final bool imageAnalysisEnabled;
  
  /// 自动检测多媒体需求功能开关
  final bool autoDetectEnabled;
  
  /// HTTP代理服务器URL
  final String? httpProxyUrl;
  
  /// 网络连接超时时间（秒）
  final int connectionTimeout;
  
  /// 最大图像文件大小（MB）
  final int maxImageSize;
  
  /// 最大音频时长（秒）
  final int maxAudioDuration;

  const MultimediaSettingsState({
    this.isLoading = false,
    this.error,
    this.isEnabled = false,
    this.imageGenerationEnabled = true,
    this.ttsEnabled = true,
    this.sttEnabled = true,
    this.webSearchEnabled = true,
    this.imageAnalysisEnabled = true,
    this.autoDetectEnabled = true,
    this.httpProxyUrl,
    this.connectionTimeout = 30,
    this.maxImageSize = 10,
    this.maxAudioDuration = 300,
  });

  /// 检查是否有任何多媒体功能启用
  bool get hasAnyFeatureEnabled {
    return isEnabled && (
      imageGenerationEnabled ||
      ttsEnabled ||
      sttEnabled ||
      webSearchEnabled ||
      imageAnalysisEnabled
    );
  }

  /// 检查是否有网络相关功能启用
  bool get hasNetworkFeaturesEnabled {
    return isEnabled && (
      imageGenerationEnabled ||
      webSearchEnabled ||
      ttsEnabled
    );
  }

  /// 检查是否配置了HTTP代理
  bool get hasHttpProxy {
    return httpProxyUrl != null && httpProxyUrl!.isNotEmpty;
  }

  /// 获取启用的功能列表
  List<String> get enabledFeatures {
    if (!isEnabled) return [];
    
    final features = <String>[];
    if (imageGenerationEnabled) features.add('图像生成');
    if (ttsEnabled) features.add('文字转语音');
    if (sttEnabled) features.add('语音转文字');
    if (webSearchEnabled) features.add('Web搜索');
    if (imageAnalysisEnabled) features.add('图像分析');
    
    return features;
  }

  /// 获取功能启用数量
  int get enabledFeatureCount {
    if (!isEnabled) return 0;
    
    int count = 0;
    if (imageGenerationEnabled) count++;
    if (ttsEnabled) count++;
    if (sttEnabled) count++;
    if (webSearchEnabled) count++;
    if (imageAnalysisEnabled) count++;
    
    return count;
  }

  /// 复制并更新状态
  MultimediaSettingsState copyWith({
    bool? isLoading,
    String? error,
    bool? isEnabled,
    bool? imageGenerationEnabled,
    bool? ttsEnabled,
    bool? sttEnabled,
    bool? webSearchEnabled,
    bool? imageAnalysisEnabled,
    bool? autoDetectEnabled,
    String? httpProxyUrl,
    int? connectionTimeout,
    int? maxImageSize,
    int? maxAudioDuration,
  }) {
    return MultimediaSettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isEnabled: isEnabled ?? this.isEnabled,
      imageGenerationEnabled: imageGenerationEnabled ?? this.imageGenerationEnabled,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      sttEnabled: sttEnabled ?? this.sttEnabled,
      webSearchEnabled: webSearchEnabled ?? this.webSearchEnabled,
      imageAnalysisEnabled: imageAnalysisEnabled ?? this.imageAnalysisEnabled,
      autoDetectEnabled: autoDetectEnabled ?? this.autoDetectEnabled,
      httpProxyUrl: httpProxyUrl ?? this.httpProxyUrl,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      maxImageSize: maxImageSize ?? this.maxImageSize,
      maxAudioDuration: maxAudioDuration ?? this.maxAudioDuration,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'isLoading': isLoading,
      'error': error,
      'isEnabled': isEnabled,
      'imageGenerationEnabled': imageGenerationEnabled,
      'ttsEnabled': ttsEnabled,
      'sttEnabled': sttEnabled,
      'webSearchEnabled': webSearchEnabled,
      'imageAnalysisEnabled': imageAnalysisEnabled,
      'autoDetectEnabled': autoDetectEnabled,
      'httpProxyUrl': httpProxyUrl,
      'connectionTimeout': connectionTimeout,
      'maxImageSize': maxImageSize,
      'maxAudioDuration': maxAudioDuration,
    };
  }

  /// 从JSON创建
  factory MultimediaSettingsState.fromJson(Map<String, dynamic> json) {
    return MultimediaSettingsState(
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
      isEnabled: json['isEnabled'] as bool? ?? false,
      imageGenerationEnabled: json['imageGenerationEnabled'] as bool? ?? true,
      ttsEnabled: json['ttsEnabled'] as bool? ?? true,
      sttEnabled: json['sttEnabled'] as bool? ?? true,
      webSearchEnabled: json['webSearchEnabled'] as bool? ?? true,
      imageAnalysisEnabled: json['imageAnalysisEnabled'] as bool? ?? true,
      autoDetectEnabled: json['autoDetectEnabled'] as bool? ?? true,
      httpProxyUrl: json['httpProxyUrl'] as String?,
      connectionTimeout: json['connectionTimeout'] as int? ?? 30,
      maxImageSize: json['maxImageSize'] as int? ?? 10,
      maxAudioDuration: json['maxAudioDuration'] as int? ?? 300,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is MultimediaSettingsState &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.isEnabled == isEnabled &&
        other.imageGenerationEnabled == imageGenerationEnabled &&
        other.ttsEnabled == ttsEnabled &&
        other.sttEnabled == sttEnabled &&
        other.webSearchEnabled == webSearchEnabled &&
        other.imageAnalysisEnabled == imageAnalysisEnabled &&
        other.autoDetectEnabled == autoDetectEnabled &&
        other.httpProxyUrl == httpProxyUrl &&
        other.connectionTimeout == connectionTimeout &&
        other.maxImageSize == maxImageSize &&
        other.maxAudioDuration == maxAudioDuration;
  }

  @override
  int get hashCode {
    return Object.hash(
      isLoading,
      error,
      isEnabled,
      imageGenerationEnabled,
      ttsEnabled,
      sttEnabled,
      webSearchEnabled,
      imageAnalysisEnabled,
      autoDetectEnabled,
      httpProxyUrl,
      connectionTimeout,
      maxImageSize,
      maxAudioDuration,
    );
  }

  @override
  String toString() {
    return 'MultimediaSettingsState('
        'isLoading: $isLoading, '
        'error: $error, '
        'isEnabled: $isEnabled, '
        'imageGenerationEnabled: $imageGenerationEnabled, '
        'ttsEnabled: $ttsEnabled, '
        'sttEnabled: $sttEnabled, '
        'webSearchEnabled: $webSearchEnabled, '
        'imageAnalysisEnabled: $imageAnalysisEnabled, '
        'autoDetectEnabled: $autoDetectEnabled, '
        'httpProxyUrl: $httpProxyUrl, '
        'connectionTimeout: $connectionTimeout, '
        'maxImageSize: $maxImageSize, '
        'maxAudioDuration: $maxAudioDuration'
        ')';
  }
}

/// 多媒体功能类型枚举
enum MultimediaFeatureType {
  imageGeneration('图像生成'),
  tts('文字转语音'),
  stt('语音转文字'),
  webSearch('Web搜索'),
  imageAnalysis('图像分析');

  const MultimediaFeatureType(this.displayName);
  
  final String displayName;
}

/// 多媒体设置配置项
class MultimediaSettingItem {
  final String key;
  final String title;
  final String description;
  final MultimediaFeatureType type;
  final bool defaultValue;

  const MultimediaSettingItem({
    required this.key,
    required this.title,
    required this.description,
    required this.type,
    required this.defaultValue,
  });
}

/// 预定义的多媒体设置项
class MultimediaSettingItems {
  static const imageGeneration = MultimediaSettingItem(
    key: 'imageGenerationEnabled',
    title: 'AI图像生成',
    description: '启用AI图像创作功能，支持DALL-E、Midjourney等',
    type: MultimediaFeatureType.imageGeneration,
    defaultValue: true,
  );

  static const tts = MultimediaSettingItem(
    key: 'ttsEnabled',
    title: '文字转语音',
    description: '将AI回复转换为语音播放',
    type: MultimediaFeatureType.tts,
    defaultValue: true,
  );

  static const stt = MultimediaSettingItem(
    key: 'sttEnabled',
    title: '语音转文字',
    description: '支持语音输入转换为文字',
    type: MultimediaFeatureType.stt,
    defaultValue: true,
  );

  static const webSearch = MultimediaSettingItem(
    key: 'webSearchEnabled',
    title: 'Web搜索',
    description: '启用实时网络信息搜索功能',
    type: MultimediaFeatureType.webSearch,
    defaultValue: true,
  );

  static const imageAnalysis = MultimediaSettingItem(
    key: 'imageAnalysisEnabled',
    title: '图像分析',
    description: 'AI图像理解和分析功能',
    type: MultimediaFeatureType.imageAnalysis,
    defaultValue: true,
  );

  /// 获取所有设置项
  static List<MultimediaSettingItem> get all => [
    imageGeneration,
    tts,
    stt,
    webSearch,
    imageAnalysis,
  ];
}
