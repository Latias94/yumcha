import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_configuration.dart';
import '../../infrastructure/services/chat_configuration_validator.dart';
import 'chat_configuration_notifier.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';
import '../../../ai_management/presentation/providers/ai_provider_notifier.dart';
import '../../../ai_management/presentation/providers/ai_assistant_notifier.dart';

/// 聊天配置监控状态
///
/// 包含配置的健康状态、问题诊断和修复建议。
class ChatConfigurationMonitorState {
  final ChatConfiguration? configuration;
  final bool isValid;
  final String? issue;
  final List<String> fixSuggestions;
  final int healthScore;
  final String healthStatus;
  final String healthDescription;
  final DateTime lastChecked;

  const ChatConfigurationMonitorState({
    this.configuration,
    this.isValid = false,
    this.issue,
    this.fixSuggestions = const [],
    this.healthScore = 0,
    this.healthStatus = '未知',
    this.healthDescription = '配置状态未知',
    required this.lastChecked,
  });

  ChatConfigurationMonitorState copyWith({
    ChatConfiguration? configuration,
    bool? isValid,
    String? issue,
    List<String>? fixSuggestions,
    int? healthScore,
    String? healthStatus,
    String? healthDescription,
    DateTime? lastChecked,
  }) {
    return ChatConfigurationMonitorState(
      configuration: configuration ?? this.configuration,
      isValid: isValid ?? this.isValid,
      issue: issue,
      fixSuggestions: fixSuggestions ?? this.fixSuggestions,
      healthScore: healthScore ?? this.healthScore,
      healthStatus: healthStatus ?? this.healthStatus,
      healthDescription: healthDescription ?? this.healthDescription,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }

  /// 是否需要用户关注
  bool get needsAttention => !isValid || healthScore < 70;

  /// 是否可以进行聊天
  bool get canChat => isValid && healthScore >= 50;

  /// 获取状态颜色指示
  String get statusColor {
    if (healthScore >= 90) return 'green';
    if (healthScore >= 70) return 'blue';
    if (healthScore >= 50) return 'orange';
    return 'red';
  }
}

/// 聊天配置监控器
///
/// 实时监控聊天配置的状态，提供配置健康检查和问题诊断。
///
/// 核心功能：
/// - 🔍 **实时监控**: 监控配置变化并实时更新状态
/// - 📊 **健康评估**: 评估配置的健康状态和可用性
/// - 🚨 **问题检测**: 自动检测配置问题并提供诊断
/// - 💡 **修复建议**: 提供具体的配置修复建议
/// - 📈 **状态历史**: 跟踪配置状态的变化历史
class ChatConfigurationMonitor
    extends StateNotifier<ChatConfigurationMonitorState> {
  ChatConfigurationMonitor(this._ref)
      : super(ChatConfigurationMonitorState(lastChecked: DateTime.now())) {
    _initialize();
  }

  final Ref _ref;
  final LoggerService _logger = LoggerService();

  /// 初始化监控器
  void _initialize() {
    // 监听配置变化
    _ref.listen(chatConfigurationProvider, (previous, next) {
      _updateMonitorState(next);
    });

    // 监听提供商数据变化
    _ref.listen(aiProviderNotifierProvider, (previous, next) {
      // 当提供商数据变化时，刷新聊天配置并重新检查
      _refreshConfigurationAndCheck();
    });

    // 监听助手数据变化
    _ref.listen(aiAssistantNotifierProvider, (previous, next) {
      // 当助手数据变化时，刷新聊天配置并重新检查
      _refreshConfigurationAndCheck();
    });

    // 初始检查
    final currentConfig = _ref.read(chatConfigurationProvider);
    _updateMonitorState(currentConfig);
  }

  /// 更新监控状态
  void _updateMonitorState(ChatConfigurationState configState) {
    try {
      final config = configState.chatConfiguration;

      // 验证配置
      final isValid = ChatConfigurationValidator.isConfigurationValid(config);
      final issue = ChatConfigurationValidator.getConfigurationIssue(config);
      final fixSuggestions =
          ChatConfigurationValidator.getFixSuggestions(config);

      // 评估健康状态
      final health =
          ChatConfigurationValidator.evaluateConfigurationHealth(config);

      // 更新状态
      state = state.copyWith(
        configuration: config,
        isValid: isValid,
        issue: issue,
        fixSuggestions: fixSuggestions,
        healthScore: health.score,
        healthStatus: health.status,
        healthDescription: health.description,
        lastChecked: DateTime.now(),
      );

      // 记录状态变化
      _logger.info('配置监控状态更新', {
        'isValid': isValid,
        'healthScore': health.score,
        'healthStatus': health.status,
        'issue': issue,
        'fixSuggestionsCount': fixSuggestions.length,
      });

      // 如果配置有严重问题，记录警告
      if (health.score < 30) {
        _logger.warning('聊天配置存在严重问题', {
          'score': health.score,
          'issue': issue,
          'suggestions': fixSuggestions,
        });
      }
    } catch (e) {
      _logger.error('配置监控更新失败', {'error': e.toString()});

      state = state.copyWith(
        isValid: false,
        issue: '配置监控失败: $e',
        fixSuggestions: ['重新启动应用', '检查配置完整性'],
        healthScore: 0,
        healthStatus: '错误',
        healthDescription: '配置监控出现错误',
        lastChecked: DateTime.now(),
      );
    }
  }

  /// 刷新配置并重新检查
  void _refreshConfigurationAndCheck() {
    try {
      // 刷新聊天配置（异步操作）
      final chatConfigNotifier = _ref.read(chatConfigurationProvider.notifier);

      // 使用 Future.microtask 来异步执行刷新操作
      Future.microtask(() async {
        try {
          await chatConfigNotifier.refresh();

          // 刷新完成后重新检查配置状态
          final currentConfig = _ref.read(chatConfigurationProvider);
          _updateMonitorState(currentConfig);

          _logger.debug('配置刷新并重新检查完成');
        } catch (e) {
          _logger.error('异步配置刷新失败', {'error': e.toString()});
        }
      });

    } catch (e) {
      _logger.error('配置刷新失败', {'error': e.toString()});
    }
  }

  /// 手动刷新配置状态
  void refresh() {
    final currentConfig = _ref.read(chatConfigurationProvider);
    _updateMonitorState(currentConfig);
  }

  /// 获取配置问题的详细信息
  Map<String, dynamic> getDetailedDiagnostics() {
    final config = state.configuration;

    return {
      'timestamp': state.lastChecked.toIso8601String(),
      'isValid': state.isValid,
      'healthScore': state.healthScore,
      'healthStatus': state.healthStatus,
      'issue': state.issue,
      'fixSuggestions': state.fixSuggestions,
      'configuration': {
        'hasAssistant': config != null,
        'assistantEnabled': config?.assistant.isEnabled ?? false,
        'assistantName': config?.assistant.name,
        'hasProvider': config != null,
        'providerEnabled': config?.provider.isEnabled ?? false,
        'providerName': config?.provider.name,
        'hasModel': config != null,
        'modelName': config?.model.name,
      },
    };
  }

  /// 检查是否可以开始聊天
  bool canStartChat() {
    return state.canChat;
  }

  /// 获取聊天前的检查结果
  ({bool canProceed, String? blockingIssue, List<String> warnings})
      checkBeforeChat() {
    if (!state.isValid) {
      return (
        canProceed: false,
        blockingIssue: state.issue ?? '配置无效',
        warnings: [],
      );
    }

    final warnings = <String>[];

    // 检查健康分数
    if (state.healthScore < 70) {
      warnings.add('配置健康状态一般，可能影响聊天体验');
    }

    // 检查具体组件
    final config = state.configuration;
    if (config != null) {
      if (!config.assistant.isEnabled) {
        warnings.add('当前助手已禁用');
      }
      if (!config.provider.isEnabled) {
        warnings.add('当前提供商已禁用');
      }
    }

    return (
      canProceed: state.canChat,
      blockingIssue: state.canChat ? null : (state.issue ?? '配置不完整'),
      warnings: warnings,
    );
  }
}

/// 聊天配置监控Provider
final chatConfigurationMonitorProvider = StateNotifierProvider<
    ChatConfigurationMonitor, ChatConfigurationMonitorState>(
  (ref) => ChatConfigurationMonitor(ref),
);

/// 配置是否有效的Provider
final isConfigurationValidProvider = Provider<bool>((ref) {
  final monitor = ref.watch(chatConfigurationMonitorProvider);
  return monitor.isValid;
});

/// 配置健康分数Provider
final configurationHealthScoreProvider = Provider<int>((ref) {
  final monitor = ref.watch(chatConfigurationMonitorProvider);
  return monitor.healthScore;
});

/// 配置问题Provider
final configurationIssueProvider = Provider<String?>((ref) {
  final monitor = ref.watch(chatConfigurationMonitorProvider);
  return monitor.issue;
});

/// 配置修复建议Provider
final configurationFixSuggestionsProvider = Provider<List<String>>((ref) {
  final monitor = ref.watch(chatConfigurationMonitorProvider);
  return monitor.fixSuggestions;
});

/// 是否可以开始聊天Provider
final canStartChatProvider = Provider<bool>((ref) {
  final monitor = ref.watch(chatConfigurationMonitorProvider);
  return monitor.canChat;
});

/// 配置需要关注Provider
final configurationNeedsAttentionProvider = Provider<bool>((ref) {
  final monitor = ref.watch(chatConfigurationMonitorProvider);
  return monitor.needsAttention;
});
