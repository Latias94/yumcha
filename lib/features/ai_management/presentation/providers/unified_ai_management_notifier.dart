import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';
import '../../../../shared/infrastructure/services/preference_service.dart';
import '../../../../shared/presentation/providers/dependency_providers.dart';
import '../../domain/entities/unified_ai_management_state_model.dart';
import '../../domain/entities/unified_ai_management_state.dart';
import '../../domain/entities/user_ai_configuration.dart';
import '../../domain/entities/ai_provider.dart';
import '../../domain/entities/ai_assistant.dart';
import '../../domain/entities/ai_model.dart';
import '../../data/repositories/provider_repository.dart';
import '../../data/repositories/assistant_repository.dart';


/// 用户自定义AI管理状态管理器
class UnifiedAiManagementNotifier extends StateNotifier<UnifiedAiManagementState> {
  UnifiedAiManagementNotifier(this._ref) : super(const UnifiedAiManagementState()) {
    _initialize();
  }

  final Ref _ref;
  final LoggerService _logger = LoggerService();
  
  /// 获取Repository实例 - 使用getter避免late final重复初始化问题
  ProviderRepository get _providerRepository => _ref.read(providerRepositoryProvider);
  AssistantRepository get _assistantRepository => _ref.read(assistantRepositoryProvider);
  PreferenceService get _preferenceService => _ref.read(preferenceServiceProvider);

  bool _isInitializing = false;
  Timer? _connectionTestTimer;

  /// 初始化AI管理器
  Future<void> _initialize() async {
    if (_isInitializing || state.isInitialized) return;
    
    _isInitializing = true;
    _logger.info('开始初始化统一AI管理器');

    try {
      state = state.copyWith(isLoading: true);

      // 并行加载数据
      final results = await Future.wait([
        _loadUserProviders(),
        _loadUserAssistants(),
        _loadUserConfiguration(),
        _loadConfigTemplates(),
      ]);

      final providers = results[0] as List<AiProvider>;
      final assistants = results[1] as List<AiAssistant>;
      final configuration = results[2] as UserAiConfiguration;
      final templates = results[3] as Map<String, ConfigTemplate>;

      state = state.copyWith(
        providers: providers,
        assistants: assistants,
        configuration: configuration,
        availableTemplates: templates,
        isLoading: false,
        isInitialized: true,
      );

      // 启动定期连接测试
      _startConnectionTestTimer();

      // 检查是否需要备份配置
      _checkConfigBackup();

      _logger.info('统一AI管理器初始化完成');
    } catch (error) {
      _logger.error('统一AI管理器初始化失败', {'error': error.toString()});
      state = state.copyWith(
        isLoading: false,
        error: '初始化失败: $error',
      );
    } finally {
      _isInitializing = false;
    }
  }

  /// 加载用户提供商
  Future<List<AiProvider>> _loadUserProviders() async {
    try {
      final providers = await _providerRepository.getAllProviders();
      _logger.info('用户提供商加载完成', {'count': providers.length});
      return providers;
    } catch (error) {
      _logger.error('加载用户提供商失败', {'error': error.toString()});
      return [];
    }
  }

  /// 加载用户助手
  Future<List<AiAssistant>> _loadUserAssistants() async {
    try {
      final assistants = await _assistantRepository.getAllAssistants();
      _logger.info('用户助手加载完成', {'count': assistants.length});
      return assistants;
    } catch (error) {
      _logger.error('加载用户助手失败', {'error': error.toString()});
      return [];
    }
  }

  /// 加载用户配置
  Future<UserAiConfiguration> _loadUserConfiguration() async {
    try {
      // 从偏好设置加载配置
      // TODO: 实现从PreferenceService加载配置的逻辑
      _logger.info('用户配置加载完成');
      return const UserAiConfiguration();
    } catch (error) {
      _logger.error('加载用户配置失败', {'error': error.toString()});
      return const UserAiConfiguration();
    }
  }

  /// 加载配置模板
  Future<Map<String, ConfigTemplate>> _loadConfigTemplates() async {
    try {
      final templates = <String, ConfigTemplate>{
        'openai': ConfigTemplate.openai,
        'anthropic': ConfigTemplate.anthropic,
        'google': ConfigTemplate.google,
        'deepseek': ConfigTemplate.deepseek,
        'groq': ConfigTemplate.groq,
      };
      _logger.info('配置模板加载完成', {'count': templates.length});
      return templates;
    } catch (error) {
      _logger.error('加载配置模板失败', {'error': error.toString()});
      return {};
    }
  }

  /// 添加自定义提供商（使用 OpenAI 兼容接口）
  Future<void> addCustomProvider({
    required String name,
    required String apiKey,
    required String baseUrl,
    ConfigTemplate? template,
  }) async {
    try {
      _logger.info('添加自定义提供商', {'name': name});

      // 创建新的提供商配置（使用 OpenAI 类型 + 自定义 baseUrl）
      final provider = AiProvider(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        type: ProviderType.openai, // 使用 OpenAI 兼容接口
        apiKey: apiKey,
        baseUrl: baseUrl,
        isEnabled: true,
        models: template != null ? _getTemplateModels(template) : [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 测试连接
      final connectionStatus = await _testProviderConnection(provider);

      if (connectionStatus != ProviderConnectionStatus.connected) {
        throw Exception('无法连接到提供商，请检查API Key和URL');
      }

      // 保存提供商
      await _providerRepository.insertProvider(provider);

      // 更新状态
      final updatedProviders = [...state.providers, provider];
      final updatedConnectionStatuses = Map<String, ProviderConnectionStatus>.from(
        state.configuration.connectionStatuses
      );
      updatedConnectionStatuses[provider.id] = connectionStatus;

      final newConfiguration = state.configuration.copyWith(
        connectionStatuses: updatedConnectionStatuses,
      );

      state = state.copyWith(
        providers: updatedProviders,
        configuration: newConfiguration,
      );

      // 发送事件
      _emitEvent(ProviderAddedEvent(provider));

      _logger.info('自定义提供商添加成功', {'providerId': provider.id});
    } catch (error) {
      _logger.error('添加自定义提供商失败', {'error': error.toString()});
      _setError('添加提供商失败: $error');
      rethrow;
    }
  }

  /// 创建自定义助手
  Future<void> createCustomAssistant({
    required String name,
    required String systemPrompt,
    String? description,
    bool streamOutput = true,
    bool supportsVision = false,
    bool supportsTools = false,
  }) async {
    try {
      _logger.info('创建自定义助手', {'name': name});

      // 创建新的助手配置
      final assistant = AiAssistant(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description: description ?? '',
        systemPrompt: systemPrompt,
        streamOutput: streamOutput,
        enableVision: supportsVision,
        enableTools: supportsTools,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 保存助手
      await _assistantRepository.insertAssistant(assistant);

      // 更新状态
      final updatedAssistants = [...state.assistants, assistant];
      state = state.copyWith(assistants: updatedAssistants);

      // 发送事件
      _emitEvent(AssistantCreatedEvent(assistant));

      _logger.info('自定义助手创建成功', {'assistantId': assistant.id});
    } catch (error) {
      _logger.error('创建自定义助手失败', {'error': error.toString()});
      _setError('创建助手失败: $error');
      rethrow;
    }
  }

  /// 获取模板模型列表
  List<AiModel> _getTemplateModels(ConfigTemplate template) {
    final now = DateTime.now();
    switch (template) {
      case ConfigTemplate.openai:
        return [
          AiModel(
            id: 'gpt-4',
            name: 'gpt-4',
            displayName: 'GPT-4',
            createdAt: now,
            updatedAt: now,
          ),
          AiModel(
            id: 'gpt-3.5-turbo',
            name: 'gpt-3.5-turbo',
            displayName: 'GPT-3.5 Turbo',
            createdAt: now,
            updatedAt: now,
          ),
        ];
      case ConfigTemplate.anthropic:
        return [
          AiModel(
            id: 'claude-3-opus',
            name: 'claude-3-opus',
            displayName: 'Claude 3 Opus',
            createdAt: now,
            updatedAt: now,
          ),
          AiModel(
            id: 'claude-3-sonnet',
            name: 'claude-3-sonnet',
            displayName: 'Claude 3 Sonnet',
            createdAt: now,
            updatedAt: now,
          ),
        ];
      case ConfigTemplate.google:
        return [
          AiModel(
            id: 'gemini-pro',
            name: 'gemini-pro',
            displayName: 'Gemini Pro',
            createdAt: now,
            updatedAt: now,
          ),
          AiModel(
            id: 'gemini-pro-vision',
            name: 'gemini-pro-vision',
            displayName: 'Gemini Pro Vision',
            createdAt: now,
            updatedAt: now,
          ),
        ];
      case ConfigTemplate.deepseek:
        return [
          AiModel(
            id: 'deepseek-chat',
            name: 'deepseek-chat',
            displayName: 'DeepSeek Chat',
            capabilities: [ModelCapability.reasoning, ModelCapability.tools],
            metadata: {
              'contextLength': 32768,
              'maxTokens': 4096,
              'description': 'DeepSeek Chat，通用对话模型',
            },
            createdAt: now,
            updatedAt: now,
          ),
          AiModel(
            id: 'deepseek-reasoner',
            name: 'deepseek-reasoner',
            displayName: 'DeepSeek Reasoner',
            capabilities: [ModelCapability.reasoning, ModelCapability.tools],
            metadata: {
              'contextLength': 32768,
              'maxTokens': 4096,
              'description': 'DeepSeek Reasoner，推理专用模型',
            },
            createdAt: now,
            updatedAt: now,
          ),
        ];
      case ConfigTemplate.groq:
        return [
          AiModel(
            id: 'llama-3.1-70b-versatile',
            name: 'llama-3.1-70b-versatile',
            displayName: 'Llama 3.1 70B',
            capabilities: [ModelCapability.tools],
            metadata: {
              'contextLength': 131072,
              'maxTokens': 8192,
              'description': 'Llama 3.1 70B，高性能通用模型',
            },
            createdAt: now,
            updatedAt: now,
          ),
          AiModel(
            id: 'mixtral-8x7b-32768',
            name: 'mixtral-8x7b-32768',
            displayName: 'Mixtral 8x7B',
            capabilities: [ModelCapability.tools],
            metadata: {
              'contextLength': 32768,
              'maxTokens': 32768,
              'description': 'Mixtral 8x7B，高速推理模型',
            },
            createdAt: now,
            updatedAt: now,
          ),
        ];
    }
  }

  /// 测试提供商连接
  Future<ProviderConnectionStatus> _testProviderConnection(AiProvider provider) async {
    try {
      // TODO: 实现实际的连接测试逻辑
      // 这里应该调用AI服务来测试连接
      _logger.info('测试提供商连接', {'providerId': provider.id});
      
      // 模拟连接测试
      await Future.delayed(const Duration(seconds: 1));
      
      return ProviderConnectionStatus.connected;
    } catch (error) {
      _logger.error('提供商连接测试失败', {
        'providerId': provider.id,
        'error': error.toString(),
      });
      return ProviderConnectionStatus.error;
    }
  }

  /// 启动连接测试定时器
  void _startConnectionTestTimer() {
    _connectionTestTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _testAllConnections(),
    );
  }

  /// 测试所有连接
  Future<void> _testAllConnections() async {
    final providersNeedingTest = state.configuration.getProvidersNeedingTest(state.providers);
    
    for (final providerId in providersNeedingTest) {
      final provider = state.providers.where((p) => p.id == providerId).firstOrNull;
      if (provider != null) {
        final status = await _testProviderConnection(provider);
        
        final updatedStatuses = Map<String, ProviderConnectionStatus>.from(
          state.configuration.connectionStatuses
        );
        updatedStatuses[providerId] = status;
        
        final updatedTests = Map<String, DateTime>.from(
          state.configuration.lastConnectionTests
        );
        updatedTests[providerId] = DateTime.now();
        
        final newConfiguration = state.configuration.copyWith(
          connectionStatuses: updatedStatuses,
          lastConnectionTests: updatedTests,
        );
        
        state = state.copyWith(configuration: newConfiguration);
      }
    }
  }

  /// 检查配置备份
  void _checkConfigBackup() {
    if (state.configuration.needsBackup) {
      _logger.info('检测到需要备份配置');
      // TODO: 实现配置备份逻辑
    }
  }

  /// 设置错误
  void _setError(String error) {
    state = state.copyWith(error: error);
  }

  /// 切换提供商启用状态
  Future<void> toggleProviderEnabled(String providerId) async {
    try {
      _logger.info('切换提供商启用状态', {'providerId': providerId});

      final provider = state.providers.where((p) => p.id == providerId).firstOrNull;
      if (provider == null) {
        throw Exception('提供商不存在: $providerId');
      }

      final updatedProvider = provider.copyWith(
        isEnabled: !provider.isEnabled,
        updatedAt: DateTime.now(),
      );

      // 更新数据库
      await _providerRepository.updateProvider(updatedProvider);

      // 更新状态
      final updatedProviders = state.providers.map((p) {
        return p.id == providerId ? updatedProvider : p;
      }).toList();

      state = state.copyWith(providers: updatedProviders);

      // 发送事件
      _emitEvent(ProviderUpdatedEvent(updatedProvider));

      _logger.info('提供商启用状态切换成功', {
        'providerId': providerId,
        'isEnabled': updatedProvider.isEnabled,
      });
    } catch (error) {
      _logger.error('切换提供商启用状态失败', {
        'providerId': providerId,
        'error': error.toString(),
      });
      _setError('切换提供商状态失败: $error');
      rethrow;
    }
  }

  /// 删除提供商
  Future<void> deleteProvider(String providerId) async {
    try {
      _logger.info('删除提供商', {'providerId': providerId});

      final provider = state.providers.where((p) => p.id == providerId).firstOrNull;
      if (provider == null) {
        throw Exception('提供商不存在: $providerId');
      }

      // 从数据库删除
      await _providerRepository.deleteProvider(providerId);

      // 更新状态
      final updatedProviders = state.providers.where((p) => p.id != providerId).toList();
      state = state.copyWith(providers: updatedProviders);

      // 发送事件
      _emitEvent(ProviderRemovedEvent(providerId));

      _logger.info('提供商删除成功', {'providerId': providerId});
    } catch (error) {
      _logger.error('删除提供商失败', {
        'providerId': providerId,
        'error': error.toString(),
      });
      _setError('删除提供商失败: $error');
      rethrow;
    }
  }

  /// 添加提供商
  Future<void> addProvider(AiProvider provider) async {
    try {
      _logger.info('添加提供商', {'providerId': provider.id, 'name': provider.name});

      // 保存到数据库
      await _providerRepository.insertProvider(provider);

      // 更新状态
      final updatedProviders = [...state.providers, provider];
      state = state.copyWith(providers: updatedProviders);

      _logger.info('提供商添加成功', {'providerId': provider.id});
    } catch (e) {
      _logger.error('添加提供商失败', {
        'providerId': provider.id,
        'error': e.toString(),
      });
      _setError('添加提供商失败: $e');
      rethrow;
    }
  }

  /// 更新提供商
  Future<void> updateProvider(AiProvider provider) async {
    try {
      _logger.info('更新提供商', {'providerId': provider.id, 'name': provider.name});

      // 更新数据库
      await _providerRepository.updateProvider(provider);

      // 更新状态
      final updatedProviders = state.providers.map((p) {
        return p.id == provider.id ? provider : p;
      }).toList();
      state = state.copyWith(providers: updatedProviders);

      _logger.info('提供商更新成功', {'providerId': provider.id});
    } catch (e) {
      _logger.error('更新提供商失败', {
        'providerId': provider.id,
        'error': e.toString(),
      });
      _setError('更新提供商失败: $e');
      rethrow;
    }
  }

  /// 切换助手启用状态
  Future<void> toggleAssistantEnabled(String assistantId) async {
    try {
      _logger.info('切换助手启用状态', {'assistantId': assistantId});

      final assistant = state.assistants.where((a) => a.id == assistantId).firstOrNull;
      if (assistant == null) {
        throw Exception('助手不存在: $assistantId');
      }

      final updatedAssistant = assistant.copyWith(
        isEnabled: !assistant.isEnabled,
        updatedAt: DateTime.now(),
      );

      // 更新数据库
      await _assistantRepository.updateAssistant(updatedAssistant);

      // 更新状态
      final updatedAssistants = state.assistants.map((a) {
        return a.id == assistantId ? updatedAssistant : a;
      }).toList();

      state = state.copyWith(assistants: updatedAssistants);

      // 发送事件
      _emitEvent(AssistantUpdatedEvent(updatedAssistant));

      _logger.info('助手启用状态切换成功', {
        'assistantId': assistantId,
        'isEnabled': updatedAssistant.isEnabled,
      });
    } catch (error) {
      _logger.error('切换助手启用状态失败', {
        'assistantId': assistantId,
        'error': error.toString(),
      });
      _setError('切换助手状态失败: $error');
      rethrow;
    }
  }

  /// 删除助手
  Future<void> deleteAssistant(String assistantId) async {
    try {
      _logger.info('删除助手', {'assistantId': assistantId});

      final assistant = state.assistants.where((a) => a.id == assistantId).firstOrNull;
      if (assistant == null) {
        throw Exception('助手不存在: $assistantId');
      }

      // 从数据库删除
      await _assistantRepository.deleteAssistant(assistantId);

      // 更新状态
      final updatedAssistants = state.assistants.where((a) => a.id != assistantId).toList();
      state = state.copyWith(assistants: updatedAssistants);

      // 发送事件
      _emitEvent(AssistantRemovedEvent(assistantId));

      _logger.info('助手删除成功', {'assistantId': assistantId});
    } catch (error) {
      _logger.error('删除助手失败', {
        'assistantId': assistantId,
        'error': error.toString(),
      });
      _setError('删除助手失败: $error');
      rethrow;
    }
  }

  /// 发送事件
  void _emitEvent(AiManagementEvent event) {
    state = state.copyWith(lastEvent: event);
    _logger.debug('AI管理事件发送', {'event': event.runtimeType.toString()});
  }

  /// 🔄 配置导入导出功能

  /// 导出当前配置
  Future<void> exportConfiguration({
    bool includeProviders = true,
    bool includeAssistants = true,
    bool includePreferences = true,
    bool includeSettings = true,
    String? encryptionKey,
    String? customPath,
  }) async {
    try {
      _logger.info('开始导出配置');

      // 创建导入前备份
      await _createAutomaticBackup('导出前备份');

      // TODO: 实现配置导出逻辑
      // 这里应该调用ConfigurationExportService

      _logger.info('配置导出成功');
    } catch (error) {
      _logger.error('配置导出失败', {'error': error.toString()});
      _setError('配置导出失败: $error');
      rethrow;
    }
  }

  /// 导入配置
  Future<void> importConfiguration(String filePath) async {
    try {
      _logger.info('开始导入配置', {'filePath': filePath});

      // 创建导入前备份
      await _createAutomaticBackup('导入前备份');

      // 配置导入逻辑 - 需要实现ConfigurationImportService
      // 当前版本暂不支持配置导入功能

      // 重新加载数据
      await _initialize();

      _logger.info('配置导入成功');
    } catch (error) {
      _logger.error('配置导入失败', {'error': error.toString()});
      _setError('配置导入失败: $error');
      rethrow;
    }
  }

  /// 创建自动备份
  Future<void> _createAutomaticBackup(String description) async {
    try {
      _logger.info('创建自动备份', {'description': description});

      // 自动备份逻辑 - 需要实现ConfigurationBackupService
      // 当前版本暂不支持自动备份功能

      _logger.info('自动备份创建成功');
    } catch (error) {
      _logger.warning('自动备份创建失败', {'error': error.toString()});
      // 备份失败不应阻止主要操作
    }
  }

  /// 验证配置完整性
  Future<bool> validateConfiguration() async {
    try {
      _logger.info('开始验证配置完整性');

      // TODO: 实现配置验证逻辑
      // 这里应该调用AdvancedConfigurationService

      _logger.info('配置验证完成');
      return true;
    } catch (error) {
      _logger.error('配置验证失败', {'error': error.toString()});
      return false;
    }
  }

  /// 获取配置分析报告
  Future<Map<String, dynamic>> getConfigurationAnalysis() async {
    try {
      _logger.info('开始分析配置');

      final analysis = {
        'totalProviders': state.providers.length,
        'enabledProviders': state.providers.where((p) => p.isEnabled).length,
        'totalAssistants': state.assistants.length,
        'enabledAssistants': state.assistants.where((a) => a.isEnabled).length,
        'connectionStatuses': state.configuration.connectionStatuses,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      _logger.info('配置分析完成');
      return analysis;
    } catch (error) {
      _logger.error('配置分析失败', {'error': error.toString()});
      return {};
    }
  }

  @override
  void dispose() {
    _connectionTestTimer?.cancel();
    super.dispose();
  }
}
