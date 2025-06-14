import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/mcp_server_config.dart';
import '../../domain/usecases/manage_mcp_server_usecase.dart';
import '../../../../shared/infrastructure/services/logger_service.dart';
import 'settings_notifier.dart';

/// MCP 服务状态
class McpServiceState {
  final bool isEnabled;
  final Map<String, McpServerStatus> serverStatuses;
  final Map<String, String?> serverErrors;
  final Map<String, List<dynamic>> serverTools; // 使用dynamic因为Tool类型来自mcp_dart
  final bool isLoading;

  const McpServiceState({
    this.isEnabled = false,
    this.serverStatuses = const {},
    this.serverErrors = const {},
    this.serverTools = const {},
    this.isLoading = false,
  });

  McpServiceState copyWith({
    bool? isEnabled,
    Map<String, McpServerStatus>? serverStatuses,
    Map<String, String?>? serverErrors,
    Map<String, List<dynamic>>? serverTools,
    bool? isLoading,
  }) {
    return McpServiceState(
      isEnabled: isEnabled ?? this.isEnabled,
      serverStatuses: serverStatuses ?? this.serverStatuses,
      serverErrors: serverErrors ?? this.serverErrors,
      serverTools: serverTools ?? this.serverTools,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is McpServiceState &&
        other.isEnabled == isEnabled &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return Object.hash(isEnabled, isLoading);
  }
}

/// MCP 服务状态管理器
class McpServiceNotifier extends StateNotifier<McpServiceState> {
  McpServiceNotifier(this._ref) : super(const McpServiceState()) {
    _init();
  }

  final Ref _ref;

  /// 获取SettingsNotifier实例
  SettingsNotifier get _settingsNotifier =>
      _ref.read(settingsNotifierProvider.notifier);
  final ManageMcpServerUseCase _mcpService = ManageMcpServerUseCase();
  final LoggerService _logger = LoggerService();
  Timer? _statusUpdateTimer;

  /// 初始化
  void _init() {
    // 监听设置变化并响应式地更新MCP状态
    _ref.listen<SettingsState>(settingsNotifierProvider, (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false) {
        // 设置加载完成，初始化MCP状态
        _loadInitialState();
      }
    });

    // 如果设置已经加载完成，立即初始化
    final settingsState = _ref.read(settingsNotifierProvider);
    if (!settingsState.isLoading) {
      Future.microtask(() => _loadInitialState());
    }

    // 启动定时器，定期更新服务器状态
    _statusUpdateTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _updateServerStatuses(),
    );
  }

  /// 加载初始状态
  Future<void> _loadInitialState() async {
    try {
      final mcpEnabled = _settingsNotifier.getMcpEnabled();
      final mcpServers = _settingsNotifier.getMcpServers();

      state = state.copyWith(isEnabled: mcpEnabled);

      if (mcpEnabled) {
        // 异步初始化服务器
        await _mcpService.setEnabled(true);
        await _mcpService.initializeServers(mcpServers.enabledServers);
        // 更新服务器状态
        await _updateServerStatuses();
      }

      _logger.info('MCP初始状态加载完成', {
        'enabled': mcpEnabled,
        'serverCount': mcpServers.servers.length,
      });
    } catch (e) {
      _logger.error('MCP初始状态加载失败', {'error': e.toString()});
    }
  }

  @override
  void dispose() {
    _statusUpdateTimer?.cancel();
    super.dispose();
  }

  /// 设置MCP启用状态
  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(isLoading: true);

    try {
      // 保存到设置
      await _settingsNotifier.setMcpEnabled(enabled);

      // 更新MCP服务
      _mcpService.setEnabled(enabled);

      if (!enabled) {
        // 禁用时清空所有状态
        state = McpServiceState(
          isEnabled: false,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isEnabled: true,
          isLoading: false,
        );
      }

      _logger.info('MCP服务${enabled ? "启用" : "禁用"}');
    } catch (e) {
      _logger.error('设置MCP启用状态失败', {'error': e.toString()});
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// 初始化服务器列表
  Future<void> initializeServers(List<McpServerConfig> configs) async {
    if (!state.isEnabled) return;

    state = state.copyWith(isLoading: true);

    try {
      await _mcpService.initializeServers(configs);
      await _updateServerStatuses();

      _logger.info('MCP服务器初始化完成', {'count': configs.length});
    } catch (e) {
      _logger.error('MCP服务器初始化失败', {'error': e.toString()});
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// 重新连接服务器
  Future<void> reconnectServer(String serverId) async {
    final currentStatuses =
        Map<String, McpServerStatus>.from(state.serverStatuses);
    currentStatuses[serverId] = McpServerStatus.connecting;

    state = state.copyWith(serverStatuses: currentStatuses);

    try {
      await _mcpService.reconnectServer(serverId);
      await _updateServerStatuses();

      _logger.info('MCP服务器重连完成', {'serverId': serverId});
    } catch (e) {
      _logger.error('MCP服务器重连失败', {
        'serverId': serverId,
        'error': e.toString(),
      });

      final errorStatuses =
          Map<String, McpServerStatus>.from(state.serverStatuses);
      errorStatuses[serverId] = McpServerStatus.error;

      final errors = Map<String, String?>.from(state.serverErrors);
      errors[serverId] = e.toString();

      state = state.copyWith(
        serverStatuses: errorStatuses,
        serverErrors: errors,
      );
    }
  }

  /// 断开服务器连接
  Future<void> disconnectServer(String serverId) async {
    try {
      await _mcpService.disconnectServer(serverId);

      final statuses = Map<String, McpServerStatus>.from(state.serverStatuses);
      statuses[serverId] = McpServerStatus.disconnected;

      final errors = Map<String, String?>.from(state.serverErrors);
      errors.remove(serverId);

      state = state.copyWith(
        serverStatuses: statuses,
        serverErrors: errors,
      );

      _logger.info('MCP服务器断开连接', {'serverId': serverId});
    } catch (e) {
      _logger.error('断开MCP服务器失败', {
        'serverId': serverId,
        'error': e.toString(),
      });
    }
  }

  /// 获取服务器状态
  McpServerStatus getServerStatus(String serverId) {
    return state.serverStatuses[serverId] ?? McpServerStatus.disconnected;
  }

  /// 获取服务器错误信息
  String? getServerError(String serverId) {
    return state.serverErrors[serverId];
  }

  /// 获取服务器工具列表
  List<dynamic> getServerTools(String serverId) {
    return state.serverTools[serverId] ?? [];
  }

  /// 获取所有可用工具
  List<dynamic> getAllAvailableTools() {
    return _mcpService.getAllAvailableTools();
  }

  /// 调用工具
  Future<McpToolResult> callTool({
    required String toolName,
    required Map<String, dynamic> arguments,
  }) async {
    return await _mcpService.callTool(
      toolName: toolName,
      arguments: arguments,
    );
  }

  /// 更新服务器状态
  Future<void> _updateServerStatuses() async {
    if (!state.isEnabled) return;

    try {
      final servers = _mcpService.servers;
      final statuses = <String, McpServerStatus>{};
      final errors = <String, String?>{};
      final tools = <String, List<dynamic>>{};

      for (final entry in servers.entries) {
        final serverId = entry.key;
        final instance = entry.value;

        statuses[serverId] = instance.status;
        errors[serverId] = instance.errorMessage;
        tools[serverId] = instance.availableTools;
      }

      // 只有状态真正改变时才更新
      if (_hasStatusChanged(statuses, errors, tools)) {
        state = state.copyWith(
          serverStatuses: statuses,
          serverErrors: errors,
          serverTools: tools,
          isLoading: false,
        );
      }
    } catch (e) {
      _logger.error('更新MCP服务器状态失败', {'error': e.toString()});
    }
  }

  /// 检查状态是否改变
  bool _hasStatusChanged(
    Map<String, McpServerStatus> newStatuses,
    Map<String, String?> newErrors,
    Map<String, List<dynamic>> newTools,
  ) {
    // 简单的状态比较
    if (newStatuses.length != state.serverStatuses.length) return true;
    if (newErrors.length != state.serverErrors.length) return true;
    if (newTools.length != state.serverTools.length) return true;

    for (final entry in newStatuses.entries) {
      if (state.serverStatuses[entry.key] != entry.value) return true;
    }

    for (final entry in newErrors.entries) {
      if (state.serverErrors[entry.key] != entry.value) return true;
    }

    for (final entry in newTools.entries) {
      final currentTools = state.serverTools[entry.key] ?? [];
      if (currentTools.length != entry.value.length) return true;
    }

    return false;
  }

  /// 强制刷新状态
  Future<void> refresh() async {
    await _updateServerStatuses();
  }
}

/// MCP 服务状态 Provider
final mcpServiceProvider =
    StateNotifierProvider<McpServiceNotifier, McpServiceState>((ref) {
  return McpServiceNotifier(ref);
});

/// 获取特定服务器状态的 Provider
final mcpServerStatusProvider =
    Provider.autoDispose.family<McpServerStatus, String>((ref, serverId) {
  final mcpState = ref.watch(mcpServiceProvider);
  return mcpState.serverStatuses[serverId] ?? McpServerStatus.disconnected;
});

/// 获取特定服务器错误的 Provider
final mcpServerErrorProvider =
    Provider.autoDispose.family<String?, String>((ref, serverId) {
  final mcpState = ref.watch(mcpServiceProvider);
  return mcpState.serverErrors[serverId];
});

/// 获取特定服务器工具的 Provider
final mcpServerToolsProvider =
    Provider.autoDispose.family<List<dynamic>, String>((ref, serverId) {
  final mcpState = ref.watch(mcpServiceProvider);
  return mcpState.serverTools[serverId] ?? [];
});

/// 获取所有可用工具的 Provider
final mcpAllToolsProvider = Provider.autoDispose<List<dynamic>>((ref) {
  final notifier = ref.read(mcpServiceProvider.notifier);
  return notifier.getAllAvailableTools();
});
