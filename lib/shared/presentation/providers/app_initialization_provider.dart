/// 🚀 应用初始化Provider
///
/// 遵循Riverpod最佳实践的应用初始化管理系统。
/// 负责协调所有服务的初始化，确保依赖关系正确。
///
/// ## 🎯 设计原则
/// - **依赖注入**: 通过Provider注入所有依赖
/// - **分层初始化**: 按依赖关系分层初始化服务
/// - **错误处理**: 完整的错误处理和恢复机制
/// - **状态跟踪**: 详细的初始化状态跟踪
/// - **性能优化**: 避免重复初始化和内存泄漏
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/services/logger_service.dart';
import '../../infrastructure/services/preference_service.dart';
import '../../infrastructure/services/data_initialization_service.dart';
import '../../infrastructure/services/ai/ai_service_manager.dart';
import '../../infrastructure/services/mcp/mcp_service_manager.dart';
import '../../../app/config/splash_config.dart';
import '../../../features/chat/presentation/widgets/bubble/bubble_system.dart';

import '../../../features/ai_management/presentation/providers/unified_ai_management_providers.dart';
import '../../../features/settings/presentation/providers/settings_notifier.dart';
import '../../../features/settings/presentation/providers/mcp_service_provider.dart';
import '../../../features/chat/presentation/providers/chat_configuration_notifier.dart' as chat_config;
import '../../../features/chat/presentation/providers/unified_chat_notifier.dart' as unified_chat; // 新增：统一聊天Provider
import 'favorite_model_notifier.dart';
import 'configuration_persistence_notifier.dart';
import '../../../app/theme/theme_provider.dart';

/// 应用初始化状态
class AppInitializationState {
  const AppInitializationState({
    this.isDataInitialized = false,
    this.isProvidersLoaded = false,
    this.isAssistantsLoaded = false,
    this.isSettingsLoaded = false,
    this.isFavoriteModelsLoaded = false,
    this.isAiServicesInitialized = false,
    this.isMcpInitialized = false,
    this.error,
    this.currentStep = '',
    this.startTime,
    this.canNavigateAway = false,
  });

  /// 数据初始化是否完成
  final bool isDataInitialized;

  /// 提供商数据是否加载完成
  final bool isProvidersLoaded;

  /// 助手数据是否加载完成
  final bool isAssistantsLoaded;

  /// 设置数据是否加载完成
  final bool isSettingsLoaded;

  /// 收藏模型数据是否加载完成
  final bool isFavoriteModelsLoaded;

  /// AI服务是否初始化完成
  final bool isAiServicesInitialized;

  /// MCP服务是否初始化完成
  final bool isMcpInitialized;

  /// 初始化错误
  final String? error;

  /// 当前初始化步骤
  final String currentStep;

  /// 启动页面开始显示的时间
  final DateTime? startTime;

  /// 是否可以导航离开启动页面
  final bool canNavigateAway;

  /// 是否所有核心数据都已加载
  bool get isCoreDataLoaded =>
      isProvidersLoaded && isAssistantsLoaded && isSettingsLoaded && isFavoriteModelsLoaded;

  /// 是否所有服务都已初始化
  bool get isFullyInitialized =>
      isDataInitialized && isCoreDataLoaded && isAiServicesInitialized && isMcpInitialized;

  /// 是否正在初始化
  bool get isInitializing => !isFullyInitialized && error == null;

  /// 是否有错误
  bool get hasError => error != null;

  /// 是否可以进入主应用（初始化完成且满足最小显示时间）
  bool get canEnterMainApp => isFullyInitialized && canNavigateAway;

  AppInitializationState copyWith({
    bool? isDataInitialized,
    bool? isProvidersLoaded,
    bool? isAssistantsLoaded,
    bool? isSettingsLoaded,
    bool? isFavoriteModelsLoaded,
    bool? isAiServicesInitialized,
    bool? isMcpInitialized,
    String? error,
    String? currentStep,
    DateTime? startTime,
    bool? canNavigateAway,
  }) {
    return AppInitializationState(
      isDataInitialized: isDataInitialized ?? this.isDataInitialized,
      isProvidersLoaded: isProvidersLoaded ?? this.isProvidersLoaded,
      isAssistantsLoaded: isAssistantsLoaded ?? this.isAssistantsLoaded,
      isSettingsLoaded: isSettingsLoaded ?? this.isSettingsLoaded,
      isFavoriteModelsLoaded: isFavoriteModelsLoaded ?? this.isFavoriteModelsLoaded,
      isAiServicesInitialized:
          isAiServicesInitialized ?? this.isAiServicesInitialized,
      isMcpInitialized: isMcpInitialized ?? this.isMcpInitialized,
      error: error,
      currentStep: currentStep ?? this.currentStep,
      startTime: startTime ?? this.startTime,
      canNavigateAway: canNavigateAway ?? this.canNavigateAway,
    );
  }
}

/// 应用初始化管理器
///
/// 负责协调所有服务的初始化过程，遵循依赖关系顺序。
/// 支持最小显示时间控制，确保良好的用户体验。
class AppInitializationNotifier extends StateNotifier<AppInitializationState> {
  AppInitializationNotifier(this._ref)
      : super(AppInitializationState(
          startTime: DateTime.now(),
        )) {
    _initialize();
  }

  final Ref _ref;
  final LoggerService _logger = LoggerService();

  /// 开始初始化过程
  Future<void> _initialize() async {
    try {
      _logger.info('🚀 开始应用初始化流程');

      // 步骤0: 初始化基础服务（在Riverpod之外必须初始化的服务）
      await _initializeBasicServices();

      // 步骤1: 初始化默认数据
      await _initializeData();

      // 步骤2: 初始化AI服务
      await _initializeAiServices();

      // 步骤3: 初始化MCP服务
      await _initializeMcpServices();

      _logger.info('✅ 应用初始化完成');

      // 检查最小显示时间
      await _checkMinDisplayTime();
    } catch (e, stackTrace) {
      _logger.error('❌ 应用初始化失败', {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
      });

      state = state.copyWith(
        error: '初始化失败: $e',
        currentStep: '初始化失败',
      );
    }
  }

  /// 初始化基础服务
  ///
  /// 只初始化在 Riverpod 之外必须初始化的服务：
  /// - 日志服务（用于记录初始化过程）
  /// - 偏好设置服务（某些Provider可能需要）
  /// - 气泡系统（消息显示组件）
  Future<void> _initializeBasicServices() async {
    state = state.copyWith(currentStep: '正在初始化基础服务...');

    try {
      // 1. 初始化日志服务（启用HTTP日志记录）
      _logger.info('⚙️ 初始化日志服务');
      LoggerService().initialize(enableHttpLogging: true);
      _logger.info('✅ 日志服务初始化完成');

      // 2. 初始化偏好设置服务
      _logger.info('⚙️ 初始化偏好设置服务');
      await PreferenceService().init();
      _logger.info('✅ 偏好设置服务初始化完成');

      // 3. 初始化气泡系统
      _logger.info('💬 初始化气泡系统');
      BubbleSystem.initialize();
      _logger.info('✅ 气泡系统初始化完成');

      state = state.copyWith(currentStep: '基础服务初始化完成');
      _logger.info('🎉 基础服务初始化完成');
    } catch (e) {
      _logger.error('❌ 基础服务初始化失败', {'error': e.toString()});
      rethrow;
    }
  }

  /// 检查并等待最小显示时间
  Future<void> _checkMinDisplayTime() async {
    if (!SplashConfig.enableMinDisplayTime) {
      // 如果禁用了最小显示时间，立即允许导航
      state = state.copyWith(canNavigateAway: true);
      return;
    }

    final startTime = state.startTime;
    if (startTime == null) {
      // 如果没有开始时间，立即允许导航
      state = state.copyWith(canNavigateAway: true);
      return;
    }

    final elapsed = DateTime.now().difference(startTime);
    final remaining = SplashConfig.minDisplayDuration - elapsed;

    if (remaining.isNegative || remaining == Duration.zero) {
      // 已经满足最小显示时间，立即允许导航
      state = state.copyWith(canNavigateAway: true);
      _logger.info('✅ 已满足最小显示时间，允许导航');
    } else {
      // 还需要等待一段时间
      state = state.copyWith(
        currentStep: '准备就绪，即将进入应用...',
      );

      _logger.info('⏱️ 等待最小显示时间: ${remaining.inMilliseconds}ms');

      // 等待剩余时间
      await Future.delayed(remaining);

      // 允许导航
      state = state.copyWith(canNavigateAway: true);
      _logger.info('✅ 最小显示时间已满足，允许导航');
    }
  }

  /// 初始化默认数据
  Future<void> _initializeData() async {
    state = state.copyWith(currentStep: '正在初始化数据...');

    try {
      // 通过Provider获取初始化结果
      await _ref.read(initializeDefaultDataProvider.future);

      // 主动触发统一AI管理Provider的初始化
      state = state.copyWith(currentStep: '正在初始化AI管理器...');

      // 触发统一AI管理Provider的初始化
      _ref.read(unifiedAiManagementProvider);

      // 等待统一AI管理器初始化完成
      await _waitForUnifiedAiManagement();

      // 主动触发关键Provider的加载，确保数据可用
      state = state.copyWith(currentStep: '正在加载核心数据...');

      // 等待所有核心数据Provider加载完成
      await Future.wait([
        _waitForProviderData(),
        _waitForAssistantData(),
        _waitForSettingsData(),
        _waitForFavoriteModelsData(),
      ]);

      // 触发其他重要Provider的初始化
      state = state.copyWith(currentStep: '正在初始化其他核心服务...');
      await _initializeOtherCoreProviders();

      // 触发聊天配置Provider的初始化
      state = state.copyWith(currentStep: '正在初始化聊天配置...');
      await _initializeChatConfiguration();

      // 触发新的统一聊天系统初始化
      state = state.copyWith(currentStep: '正在初始化统一聊天系统...');
      await _initializeUnifiedChatSystem();

      state = state.copyWith(
        isDataInitialized: true,
        currentStep: '数据初始化完成',
      );

      _logger.info('✅ 数据初始化完成');
    } catch (e) {
      _logger.error('❌ 数据初始化失败', {'error': e.toString()});
      rethrow;
    }
  }

  /// 初始化AI服务
  Future<void> _initializeAiServices() async {
    state = state.copyWith(currentStep: '正在初始化AI服务...');

    try {
      // 通过Provider获取AI服务管理器并初始化
      await _ref.read(initializeAiServicesProvider.future);

      state = state.copyWith(
        isAiServicesInitialized: true,
        currentStep: 'AI服务初始化完成',
      );

      _logger.info('✅ AI服务初始化完成');
    } catch (e) {
      _logger.error('❌ AI服务初始化失败', {'error': e.toString()});
      rethrow;
    }
  }

  /// 初始化MCP服务
  Future<void> _initializeMcpServices() async {
    state = state.copyWith(currentStep: '正在初始化MCP服务...');

    try {
      _logger.info('🔧 开始初始化MCP服务...');

      // 1. 首先初始化McpServiceManager（核心服务）
      final mcpServiceManager = _ref.read(mcpServiceManagerProvider);
      await mcpServiceManager.initialize();

      _logger.info('McpServiceManager初始化完成', {
        'isInitialized': mcpServiceManager.isInitialized,
        'isEnabled': mcpServiceManager.isEnabled,
      });

      // 2. 然后创建MCP服务Provider（UI状态管理）
      // 这会触发_loadInitialState，根据设置决定是否启用MCP并初始化服务器
      _ref.read(mcpServiceProvider.notifier);

      // 3. 等待MCP服务Provider完成初始化
      // 使用轮询方式等待，而不是硬编码延迟
      int attempts = 0;
      const maxAttempts = 50; // 最多等待5秒
      bool initializationCompleted = false;

      while (attempts < maxAttempts && !initializationCompleted) {
        try {
          final mcpState = _ref.read(mcpServiceProvider);

          // 检查是否完成初始化（不在加载中且没有错误）
          if (!mcpState.isLoading) {
            initializationCompleted = true;
            _logger.info('MCP服务Provider初始化完成', {
              'attempts': attempts,
              'isEnabled': mcpState.isEnabled,
              'serverCount': mcpState.serverStatuses.length,
            });
            break;
          }

          _logger.debug('等待MCP服务Provider初始化完成', {
            'attempt': attempts + 1,
            'maxAttempts': maxAttempts,
            'isLoading': mcpState.isLoading,
          });

        } catch (e) {
          _logger.warning('检查MCP服务Provider状态时出错', {
            'attempt': attempts + 1,
            'error': e.toString(),
          });
        }

        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      if (!initializationCompleted && attempts >= maxAttempts) {
        _logger.warning('MCP服务Provider初始化超时，但继续启动', {
          'maxAttempts': maxAttempts,
          'timeoutMs': maxAttempts * 100,
        });
      }

      state = state.copyWith(
        isMcpInitialized: true,
        currentStep: 'MCP服务初始化完成',
      );

      _logger.info('✅ MCP服务初始化完成', {
        'attempts': attempts,
        'maxAttempts': maxAttempts,
      });
    } catch (e) {
      _logger.error('❌ MCP服务初始化失败', {'error': e.toString()});
      // MCP初始化失败不应阻塞应用启动
      state = state.copyWith(
        isMcpInitialized: true,
        currentStep: 'MCP服务初始化失败，继续启动',
      );
    }
  }

  /// 等待提供商数据加载完成
  Future<void> _waitForProviderData() async {
    const maxWaitTime = Duration(seconds: 15);
    const checkInterval = Duration(milliseconds: 100);
    final startTime = DateTime.now();

    _logger.info('🔌 开始等待提供商数据加载...');

    while (DateTime.now().difference(startTime) < maxWaitTime) {
      try {
        // 首先确保统一AI管理Provider已初始化
        final unifiedState = _ref.read(unifiedAiManagementProvider);

        if (!unifiedState.isInitialized) {
          _logger.debug('统一AI管理器尚未初始化，等待中...');
          await Future.delayed(checkInterval);
          continue;
        }

        // 使用新的统一AI管理Provider
        final providers = _ref.read(aiProvidersProvider);
        final enabledProviders = providers.where((p) => p.isEnabled).toList();

        _logger.debug('提供商数据检查: 总数=${providers.length}, 启用数=${enabledProviders.length}');

        if (enabledProviders.isNotEmpty) {
          _logger.info('✅ 找到可用提供商: ${enabledProviders.map((p) => '${p.id}(${p.name})').join(', ')}');
          state = state.copyWith(
            isProvidersLoaded: true,
            currentStep: '提供商数据加载完成',
          );
          return;
        }

        _logger.debug('提供商数据仍在加载中...');

      } catch (error) {
        _logger.error('提供商数据加载错误: $error');
        _logger.warning('⚠️ 提供商数据加载失败，但继续初始化');

        // 标记为已加载，避免阻塞初始化
        state = state.copyWith(
          isProvidersLoaded: true,
          currentStep: '提供商数据加载失败，继续初始化',
        );
        return;
      }

      // 等待一段时间后重试
      await Future.delayed(checkInterval);
    }

    _logger.warning('⏱️ 等待提供商数据超时，继续初始化');
    // 超时也标记为已加载，避免阻塞
    state = state.copyWith(
      isProvidersLoaded: true,
      currentStep: '提供商数据加载超时，继续初始化',
    );
  }

  /// 等待助手数据加载完成
  Future<void> _waitForAssistantData() async {
    const maxWaitTime = Duration(seconds: 15);
    const checkInterval = Duration(milliseconds: 100);
    final startTime = DateTime.now();

    _logger.info('🤖 开始等待助手数据加载...');

    while (DateTime.now().difference(startTime) < maxWaitTime) {
      try {
        // 首先确保统一AI管理Provider已初始化
        final unifiedState = _ref.read(unifiedAiManagementProvider);

        if (!unifiedState.isInitialized) {
          _logger.debug('统一AI管理器尚未初始化，等待中...');
          await Future.delayed(checkInterval);
          continue;
        }

        // 使用新的统一AI管理Provider
        final assistants = _ref.read(aiAssistantsProvider);
        final enabledAssistants = assistants.where((a) => a.isEnabled).toList();

        _logger.debug('助手数据检查: 总数=${assistants.length}, 启用数=${enabledAssistants.length}');

        if (enabledAssistants.isNotEmpty) {
          _logger.info('✅ 找到可用助手: ${enabledAssistants.map((a) => '${a.id}(${a.name})').join(', ')}');
          state = state.copyWith(
            isAssistantsLoaded: true,
            currentStep: '助手数据加载完成',
          );
          return;
        }

        _logger.debug('助手数据仍在加载中...');

      } catch (error) {
        _logger.error('助手数据加载错误: $error');
        _logger.warning('⚠️ 助手数据加载失败，但继续初始化');

        // 标记为已加载，避免阻塞初始化
        state = state.copyWith(
          isAssistantsLoaded: true,
          currentStep: '助手数据加载失败，继续初始化',
        );
        return;
      }

      // 等待一段时间后重试
      await Future.delayed(checkInterval);
    }

    _logger.warning('⏱️ 等待助手数据超时，继续初始化');
    // 超时也标记为已加载，避免阻塞
    state = state.copyWith(
      isAssistantsLoaded: true,
      currentStep: '助手数据加载超时，继续初始化',
    );
  }

  /// 等待设置数据加载完成
  Future<void> _waitForSettingsData() async {
    const maxWaitTime = Duration(seconds: 10);
    const checkInterval = Duration(milliseconds: 100);
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < maxWaitTime) {
      final settingsState = _ref.read(settingsNotifierProvider);

      // 检查是否加载完成
      if (!settingsState.isLoading && settingsState.error == null) {
        _logger.info('✅ 设置数据加载完成');
        state = state.copyWith(
          isSettingsLoaded: true,
          currentStep: '设置数据加载完成',
        );
        return;
      }

      // 检查是否有错误
      if (settingsState.error != null) {
        _logger.warning('⚠️ 设置数据加载失败，但继续初始化');
        // 标记为已加载，避免阻塞初始化
        state = state.copyWith(
          isSettingsLoaded: true,
          currentStep: '设置数据加载失败，继续初始化',
        );
        return;
      }

      // 等待一段时间后重试
      await Future.delayed(checkInterval);
    }

    _logger.warning('⏱️ 等待设置数据超时，继续初始化');
    // 超时也标记为已加载，避免阻塞
    state = state.copyWith(
      isSettingsLoaded: true,
      currentStep: '设置数据加载超时，继续初始化',
    );
  }

  /// 等待统一AI管理器初始化完成
  Future<void> _waitForUnifiedAiManagement() async {
    const maxWaitTime = Duration(seconds: 20);
    const checkInterval = Duration(milliseconds: 100);
    final startTime = DateTime.now();

    _logger.info('🔧 开始等待统一AI管理器初始化...');

    while (DateTime.now().difference(startTime) < maxWaitTime) {
      try {
        final unifiedState = _ref.read(unifiedAiManagementProvider);

        if (unifiedState.isInitialized) {
          _logger.info('✅ 统一AI管理器初始化完成');
          return;
        }

        if (unifiedState.error != null) {
          _logger.warning('⚠️ 统一AI管理器初始化失败: ${unifiedState.error}');
          return;
        }

        _logger.debug('统一AI管理器仍在初始化中...');

      } catch (error) {
        _logger.error('统一AI管理器初始化检查错误: $error');
        _logger.warning('⚠️ 统一AI管理器初始化检查失败，但继续初始化');
        return;
      }

      // 等待一段时间后重试
      await Future.delayed(checkInterval);
    }

    _logger.warning('⏱️ 等待统一AI管理器初始化超时，继续初始化');
  }

  /// 初始化其他核心Provider
  Future<void> _initializeOtherCoreProviders() async {
    try {
      _logger.info('🔧 开始初始化其他核心Provider...');

      // 1. 初始化主题Provider - 确保主题设置可用
      _ref.read(themeProvider);
      _logger.debug('主题Provider已触发初始化');

      // 2. 初始化配置持久化Provider - 确保配置保存功能可用
      _ref.read(configurationPersistenceNotifierProvider);
      _logger.debug('配置持久化Provider已触发初始化');

      // 等待一小段时间让Provider完成初始化
      await Future.delayed(const Duration(milliseconds: 200));

      _logger.info('✅ 其他核心Provider初始化完成');
    } catch (error) {
      _logger.error('❌ 其他核心Provider初始化失败: $error');
      // 这些Provider初始化失败不应阻塞应用启动
    }
  }

  /// 初始化聊天配置
  Future<void> _initializeChatConfiguration() async {
    try {
      _logger.info('🔧 开始初始化聊天配置...');

      // 触发聊天配置Provider的初始化
      _ref.read(chat_config.chatConfigurationProvider);

      // 等待聊天配置初始化完成
      await _waitForChatConfiguration();

      _logger.info('✅ 聊天配置初始化完成');
    } catch (error) {
      _logger.error('❌ 聊天配置初始化失败: $error');
      // 聊天配置初始化失败不应阻塞应用启动
    }
  }

  /// 等待聊天配置初始化完成
  Future<void> _waitForChatConfiguration() async {
    const maxWaitTime = Duration(seconds: 10);
    const checkInterval = Duration(milliseconds: 100);
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < maxWaitTime) {
      try {
        final chatConfig = _ref.read(chat_config.chatConfigurationProvider);

        if (!chatConfig.isLoading && chatConfig.error == null) {
          _logger.info('✅ 聊天配置加载完成');
          return;
        }

        if (chatConfig.error != null) {
          _logger.warning('⚠️ 聊天配置加载失败: ${chatConfig.error}');
          return;
        }

        _logger.debug('聊天配置仍在加载中...');

      } catch (error) {
        _logger.error('聊天配置检查错误: $error');
        return;
      }

      // 等待一段时间后重试
      await Future.delayed(checkInterval);
    }

    _logger.warning('⏱️ 等待聊天配置超时，继续初始化');
  }

  /// 初始化统一聊天系统
  Future<void> _initializeUnifiedChatSystem() async {
    try {
      _logger.info('🔧 开始初始化统一聊天系统...');

      // 触发统一聊天Provider的初始化
      _ref.read(unified_chat.unifiedChatProvider);

      // 等待统一聊天系统初始化完成
      await _waitForUnifiedChatSystem();

      _logger.info('✅ 统一聊天系统初始化完成');
    } catch (error) {
      _logger.error('❌ 统一聊天系统初始化失败: $error');
      // 统一聊天系统初始化失败不应阻塞应用启动
    }
  }

  /// 等待统一聊天系统初始化完成
  Future<void> _waitForUnifiedChatSystem() async {
    const maxWaitTime = Duration(seconds: 10);
    const checkInterval = Duration(milliseconds: 100);
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < maxWaitTime) {
      try {
        final unifiedChatState = _ref.read(unified_chat.unifiedChatProvider);

        // 检查是否初始化完成（不在加载中且没有错误）
        if (!unifiedChatState.isLoading && !unifiedChatState.hasError) {
          _logger.info('✅ 统一聊天系统加载完成');
          return;
        }

        if (unifiedChatState.hasError) {
          _logger.warning('⚠️ 统一聊天系统加载失败: ${unifiedChatState.primaryError}');
          return;
        }

        _logger.debug('统一聊天系统仍在加载中...');

      } catch (error) {
        _logger.error('统一聊天系统检查错误: $error');
        return;
      }

      // 等待一段时间后重试
      await Future.delayed(checkInterval);
    }

    _logger.warning('⏱️ 等待统一聊天系统超时，继续初始化');
  }

  /// 等待收藏模型数据加载完成
  Future<void> _waitForFavoriteModelsData() async {
    const maxWaitTime = Duration(seconds: 10);
    const checkInterval = Duration(milliseconds: 100);
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < maxWaitTime) {
      final favoriteModelsAsync = _ref.read(favoriteModelNotifierProvider);

      // 检查是否加载完成
      final hasData = favoriteModelsAsync.whenOrNull(
            data: (models) => true,
          ) ??
          false;

      if (hasData) {
        _logger.info('✅ 收藏模型数据加载完成');
        state = state.copyWith(
          isFavoriteModelsLoaded: true,
          currentStep: '收藏模型数据加载完成',
        );
        return;
      }

      // 检查是否有错误
      final hasError = favoriteModelsAsync.whenOrNull(
            error: (error, stack) => true,
          ) ??
          false;

      if (hasError) {
        _logger.warning('⚠️ 收藏模型数据加载失败，但继续初始化');
        // 标记为已加载，避免阻塞初始化
        state = state.copyWith(
          isFavoriteModelsLoaded: true,
          currentStep: '收藏模型数据加载失败，继续初始化',
        );
        return;
      }

      // 等待一段时间后重试
      await Future.delayed(checkInterval);
    }

    _logger.warning('⏱️ 等待收藏模型数据超时，继续初始化');
    // 超时也标记为已加载，避免阻塞
    state = state.copyWith(
      isFavoriteModelsLoaded: true,
      currentStep: '收藏模型数据加载超时，继续初始化',
    );
  }

  /// 重试初始化
  Future<void> retry() async {
    state = const AppInitializationState();
    await _initialize();
  }
}

/// 应用初始化Provider
///
/// 提供应用初始化状态管理，遵循Riverpod最佳实践。
///
/// ## 特性
/// - ⚡ **异步初始化**: 不阻塞UI线程
/// - 🔄 **状态跟踪**: 详细的初始化状态
/// - 🛡️ **错误处理**: 完整的错误处理和重试机制
/// - 📊 **依赖管理**: 正确的Provider依赖关系
///
/// ## 使用方式
/// ```dart
/// final initState = ref.watch(appInitializationProvider);
/// if (initState.isFullyInitialized) {
///   // 显示主界面
/// } else if (initState.hasError) {
///   // 显示错误界面
/// } else {
///   // 显示加载界面
/// }
/// ```
final appInitializationProvider =
    StateNotifierProvider<AppInitializationNotifier, AppInitializationState>(
  (ref) => AppInitializationNotifier(ref),
);
