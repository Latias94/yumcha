// 🧪 AI 聊天 API 调试屏幕
//
// 专门用于测试和调试 AI 聊天 API 功能的开发工具界面。
// 基于 llm_dart 服务，支持多种 AI 提供商的直接 API 测试。
//
// 🎯 **主要功能**:
// - 🔧 **API 测试**: 直接测试各种 AI 提供商的 API 接口
// - 🚀 **快速配置**: 提供预设配置快速切换不同模型
// - 📊 **参数调节**: 精确控制温度、Top-P、最大 token 等参数
// - 🌊 **流式支持**: 支持流式和非流式两种请求模式
// - 🧠 **推理模式**: 支持 OpenAI o1、DeepSeek R1 等推理模型的思考过程
// - 📋 **详细日志**: 显示完整的请求响应过程和调试信息
// - 📄 **数据导出**: 支持复制请求体、响应体等技术数据
// - 🎨 **实时显示**: 实时显示流式响应和思考过程
//
// 🔌 **支持的提供商**:
// - OpenAI: GPT-4、GPT-3.5、o1-preview、o1-mini
// - DeepSeek: deepseek-chat、deepseek-r1 (推理模型)
// - Anthropic: Claude 系列模型
// - Google: Gemini 系列模型
// - 其他 OpenAI 兼容接口
//
// 📱 **界面组织**:
// - 快速配置：预设的模型配置选择
// - 提供商设置：选择 AI 服务提供商
// - API 配置：API 密钥、Base URL 设置
// - 参数配置：AI 模型参数调节
// - 消息输入：系统提示词和用户消息
// - 结果显示：可折叠的响应面板
//
// 🛠️ **特殊功能**:
// - 支持推理模型的思考过程显示
// - 流式响应的实时更新
// - Token 使用统计
// - 完整的请求响应日志
// - 错误诊断和调试信息

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/infrastructure/services/ai/providers/ai_service_provider.dart';
import '../../../../shared/presentation/design_system/design_constants.dart';

import '../../../ai_management/domain/entities/ai_provider.dart' as models;
import '../../../ai_management/domain/entities/ai_assistant.dart';
import '../../../ai_management/presentation/providers/unified_ai_management_providers.dart';
import '../../../chat/domain/entities/message.dart';
import '../../../settings/domain/entities/mcp_server_config.dart';
import '../../../settings/presentation/providers/settings_notifier.dart';
import '../../../settings/presentation/providers/mcp_service_provider.dart';
import '../../../settings/presentation/screens/mcp_settings_screen.dart';
import '../../../../shared/infrastructure/services/mcp/mcp_service_manager.dart';
import 'dart:convert';
import 'dart:async';

class AiDebugScreen extends ConsumerStatefulWidget {
  const AiDebugScreen({super.key});

  @override
  ConsumerState<AiDebugScreen> createState() => _AiDebugScreenState();
}

class _AiDebugScreenState extends ConsumerState<AiDebugScreen> {
  // 表单控制器
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();
  final _messageController = TextEditingController();
  final _systemPromptController = TextEditingController();

  // 参数控制器
  final _temperatureController = TextEditingController(text: '0.7');
  final _topPController = TextEditingController(text: '0.9');
  final _maxTokensController = TextEditingController(text: '1000');

  // 状态变量
  String _selectedProvider = 'openai';
  String? _selectedAssistantId;
  bool _isLoading = false;
  bool _isStreamMode = false;
  bool _isResponsePanelExpanded = true;
  bool _enableMcpTools = false;

  // 结果显示
  String _response = '';
  String _thinkingContent = '';
  String _debugInfo = '';
  String _requestBody = '';
  String _responseBody = '';
  final List<String> _streamChunks = [];
  final List<String> _thinkingChunks = [];

  // MCP相关
  String _mcpDebugInfo = '';
  List<McpServerConfig> _availableMcpServers = [];
  final List<String> _selectedMcpServerIds = [];

  // 请求取消相关
  Completer<void>? _currentRequestCompleter;

  // SharedPreferences 键名常量
  static const String _prefKeyApiKey = 'debug_api_key';
  static const String _prefKeyBaseUrl = 'debug_base_url';
  static const String _prefKeyModel = 'debug_model';
  static const String _prefKeyMessage = 'debug_message';
  static const String _prefKeySystemPrompt = 'debug_system_prompt';
  static const String _prefKeyTemperature = 'debug_temperature';
  static const String _prefKeyTopP = 'debug_top_p';
  static const String _prefKeyMaxTokens = 'debug_max_tokens';
  static const String _prefKeyProvider = 'debug_provider';
  static const String _prefKeyStreamMode = 'debug_stream_mode';
  static const String _prefKeyEnableMcp = 'debug_enable_mcp';
  static const String _prefKeySelectedAssistant = 'debug_selected_assistant';

  // 预设配置
  static const Map<String, Map<String, String>> _presets = {
    'OpenAI GPT-4': {
      'provider': 'openai',
      'model': 'gpt-4',
      'baseUrl': 'https://api.openai.com/v1',
    },
    'OpenAI o1-preview (推理)': {
      'provider': 'openai',
      'model': 'o1-preview',
      'baseUrl': 'https://api.openai.com/v1',
    },
    'OpenAI o1-mini (推理)': {
      'provider': 'openai',
      'model': 'o1-mini',
      'baseUrl': 'https://api.openai.com/v1',
    },
    'OpenAI GPT-3.5': {
      'provider': 'openai',
      'model': 'gpt-3.5-turbo',
      'baseUrl': 'https://api.openai.com/v1',
    },
    'DeepSeek': {
      'provider': 'deepseek',
      'model': 'deepseek-chat',
      'baseUrl': 'https://api.deepseek.com/v1',
    },
    'DeepSeek R1 (推理)': {
      'provider': 'deepseek',
      'model': 'deepseek-reasoner',
      'baseUrl': 'https://api.deepseek.com/v1',
    },
    'Anthropic Claude': {
      'provider': 'anthropic',
      'model': 'claude-3-haiku-20240307',
      'baseUrl': 'https://api.anthropic.com/v1',
    },
    'Google Gemini': {
      'provider': 'google',
      'model': 'gemini-2.0-flash',
      'baseUrl': 'https://generativelanguage.googleapis.com/v1beta',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
    _loadMcpServers();
    _setupTextFieldListeners();
  }

  /// 设置文本输入框监听器，实现自动保存
  void _setupTextFieldListeners() {
    // 添加延迟保存，避免频繁保存
    Timer? saveTimer;

    void scheduleSave() {
      saveTimer?.cancel();
      saveTimer = Timer(const Duration(seconds: 1), () {
        _saveCurrentSettings();
      });
    }

    _apiKeyController.addListener(scheduleSave);
    _baseUrlController.addListener(scheduleSave);
    _modelController.addListener(scheduleSave);
    _messageController.addListener(scheduleSave);
    _systemPromptController.addListener(scheduleSave);
    _temperatureController.addListener(scheduleSave);
    _topPController.addListener(scheduleSave);
    _maxTokensController.addListener(scheduleSave);
  }

  /// 加载保存的设置
  Future<void> _loadSavedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _apiKeyController.text = prefs.getString(_prefKeyApiKey) ?? '';
        _baseUrlController.text = prefs.getString(_prefKeyBaseUrl) ?? '';
        _modelController.text = prefs.getString(_prefKeyModel) ?? 'gpt-4';
        _messageController.text = prefs.getString(_prefKeyMessage) ?? '';
        _systemPromptController.text =
            prefs.getString(_prefKeySystemPrompt) ?? '';
        _temperatureController.text =
            prefs.getString(_prefKeyTemperature) ?? '0.7';
        _topPController.text = prefs.getString(_prefKeyTopP) ?? '0.9';
        _maxTokensController.text =
            prefs.getString(_prefKeyMaxTokens) ?? '1000';
        _selectedProvider = prefs.getString(_prefKeyProvider) ?? 'openai';
        _isStreamMode = prefs.getBool(_prefKeyStreamMode) ?? false;
        _enableMcpTools = prefs.getBool(_prefKeyEnableMcp) ?? false;
        _selectedAssistantId = prefs.getString(_prefKeySelectedAssistant);
      });

      // 如果没有保存的设置，加载默认预设
      if (_apiKeyController.text.isEmpty && _modelController.text == 'gpt-4') {
        _loadPreset('OpenAI GPT-4');
      }
    } catch (e) {
      // 如果加载失败，使用默认设置
      _loadPreset('OpenAI GPT-4');
    }
  }

  /// 保存当前设置
  Future<void> _saveCurrentSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_prefKeyApiKey, _apiKeyController.text);
      await prefs.setString(_prefKeyBaseUrl, _baseUrlController.text);
      await prefs.setString(_prefKeyModel, _modelController.text);
      await prefs.setString(_prefKeyMessage, _messageController.text);
      await prefs.setString(_prefKeySystemPrompt, _systemPromptController.text);
      await prefs.setString(_prefKeyTemperature, _temperatureController.text);
      await prefs.setString(_prefKeyTopP, _topPController.text);
      await prefs.setString(_prefKeyMaxTokens, _maxTokensController.text);
      await prefs.setString(_prefKeyProvider, _selectedProvider);
      await prefs.setBool(_prefKeyStreamMode, _isStreamMode);
      await prefs.setBool(_prefKeyEnableMcp, _enableMcpTools);
      if (_selectedAssistantId != null) {
        await prefs.setString(_prefKeySelectedAssistant, _selectedAssistantId!);
      }
    } catch (e) {
      // 保存失败不影响主要功能
    }
  }

  /// 加载可用的MCP服务器
  Future<void> _loadMcpServers() async {
    try {
      // 从设置中获取已配置的MCP服务器
      final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
      final mcpServersConfig = settingsNotifier.getMcpServers();
      final configuredServers = mcpServersConfig.servers;

      setState(() {
        _availableMcpServers = configuredServers;
      });

      if (configuredServers.isNotEmpty) {
        _updateMcpDebugInfo('📋 已加载 ${configuredServers.length} 个已配置的MCP服务器\n');
        for (final server in configuredServers) {
          _updateMcpDebugInfo(
              '  - ${server.name} (${server.type.displayName}) ${server.isEnabled ? '已启用' : '已禁用'}\n');
        }
      } else {
        _updateMcpDebugInfo('📋 暂无已配置的MCP服务器\n');
        _updateMcpDebugInfo('💡 请先在设置页面配置MCP服务器\n');
      }
    } catch (e) {
      _updateMcpDebugInfo('❌ 加载MCP服务器失败: $e\n');
    }
  }

  @override
  void dispose() {
    // 取消当前请求
    if (_currentRequestCompleter != null &&
        !_currentRequestCompleter!.isCompleted) {
      _currentRequestCompleter!.completeError('页面已销毁');
    }

    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    _messageController.dispose();
    _systemPromptController.dispose();
    _temperatureController.dispose();
    _topPController.dispose();
    _maxTokensController.dispose();
    super.dispose();
  }

  void _loadPreset(String presetName) {
    final preset = _presets[presetName];
    if (preset == null) return;

    setState(() {
      _selectedProvider = preset['provider'] ?? 'openai';
      _modelController.text = preset['model'] ?? '';
      _baseUrlController.text = preset['baseUrl'] ?? '';
    });

    // 自动保存设置
    _saveCurrentSettings();
  }

  Future<String> _formatRequestBody() async {
    final message = _messageController.text.trim();

    final requestData = {
      'model': _modelController.text.trim(),
      'messages': [
        if (_systemPromptController.text.trim().isNotEmpty)
          {'role': 'system', 'content': _systemPromptController.text.trim()},
        {'role': 'user', 'content': message},
      ],
      if (_temperatureController.text.isNotEmpty)
        'temperature': double.tryParse(_temperatureController.text),
      if (_topPController.text.isNotEmpty)
        'top_p': double.tryParse(_topPController.text),
      if (_maxTokensController.text.isNotEmpty)
        'max_tokens': int.tryParse(_maxTokensController.text),
      if (_isStreamMode) 'stream': true,
      // 添加真实的MCP工具信息（如果启用了MCP工具）
      // 注意：这里显示的是将要发送给AI服务的工具信息，
      // 实际的工具调用由AI服务内部处理
      if (_enableMcpTools && _selectedMcpServerIds.isNotEmpty)
        'tools': await _getRealMcpTools(_selectedMcpServerIds),
    };

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(requestData);
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      _showError('请输入消息内容');
      return;
    }

    if (_apiKeyController.text.trim().isEmpty) {
      _showError('请输入API密钥');
      return;
    }

    // 保存当前设置
    await _saveCurrentSettings();

    // 创建新的请求 Completer
    _currentRequestCompleter = Completer<void>();

    setState(() {
      _isLoading = true;
      _response = '';
      _thinkingContent = '';
      _debugInfo = '';
      _requestBody = '';
      _responseBody = '';
      _streamChunks.clear();
      _thinkingChunks.clear();
      _mcpDebugInfo = '';
    });

    // 生成请求体
    final requestBody = await _formatRequestBody();
    setState(() {
      _requestBody = requestBody;
    });

    try {
      _updateDebugInfo('🚀 开始LLM Dart请求...\n');
      _updateDebugInfo('提供商: $_selectedProvider\n');
      _updateDebugInfo('模型: ${_modelController.text}\n');
      _updateDebugInfo(
        'API端点: ${_baseUrlController.text.isEmpty ? "默认" : _baseUrlController.text}\n',
      );
      _updateDebugInfo(
        '参数: temperature=${_temperatureController.text}, topP=${_topPController.text}\n',
      );

      // 助手信息
      if (_selectedAssistantId != null) {
        final assistants = ref.read(aiAssistantsProvider);
        final selectedAssistant =
            assistants.where((a) => a.id == _selectedAssistantId).firstOrNull;
        if (selectedAssistant != null) {
          _updateDebugInfo('🤖 助手: ${selectedAssistant.name}\n');
        }
      } else {
        _updateDebugInfo('🧪 助手: 测试助手配置\n');
      }

      // MCP调试信息
      final assistant = await _getSelectedOrTestAssistant();
      if (assistant.enableTools) {
        _updateDebugInfo('🔧 MCP工具: 已启用\n');
        if (_selectedAssistantId != null) {
          _updateDebugInfo('工具配置来源: 选择的助手\n');
          _updateDebugInfo('助手MCP服务器: ${assistant.mcpServerIds.length} 个\n');
        } else {
          _updateDebugInfo('工具配置来源: 测试配置\n');
          _updateDebugInfo('选择的服务器: ${_selectedMcpServerIds.length} 个\n');
        }
        _updateMcpDebugInfo('🔧 MCP工具调试开始...\n');
        _updateMcpDebugInfo('助手工具启用状态: ${assistant.enableTools}\n');
        _updateMcpDebugInfo('MCP服务器ID: ${assistant.mcpServerIds.join(", ")}\n');

        // 检查MCP服务状态
        final mcpState = ref.read(mcpServiceProvider);
        _updateMcpDebugInfo(
            'MCP服务全局状态: ${mcpState.isEnabled ? "已启用" : "未启用"}\n');

        if (!mcpState.isEnabled) {
          _updateMcpDebugInfo('⚠️ MCP服务未启用，请先在设置中启用MCP服务\n');
          _updateMcpDebugInfo('💡 提示: 即使助手启用了工具，MCP服务未启用时也无法使用工具\n');
          _updateMcpDebugInfo('🚫 跳过MCP工具集成，继续发送普通请求\n');
        } else {
          // 检查服务器连接状态
          bool hasDisconnectedServers = false;
          final serverIds = assistant.mcpServerIds;

          for (final serverId in serverIds) {
            final server =
                _availableMcpServers.where((s) => s.id == serverId).firstOrNull;
            if (server != null) {
              final status = ref.read(mcpServerStatusProvider(serverId));
              final statusText = _getStatusText(status);
              _updateMcpDebugInfo(
                  '服务器: ${server.name} (${server.type.displayName}) - $statusText\n');

              if (status != McpServerStatus.connected) {
                _updateMcpDebugInfo('  ⚠️ 服务器未连接，工具可能无法正常使用\n');
                hasDisconnectedServers = true;
              }
            } else {
              _updateMcpDebugInfo('⚠️ 服务器配置未找到: $serverId\n');
            }
          }

          // 如果有未连接的服务器，尝试重新连接
          if (hasDisconnectedServers) {
            _updateMcpDebugInfo('🔄 检测到未连接的服务器，尝试重新连接...\n');
            await _reconnectMcpServersForAssistant(serverIds);
          }

          // 获取实际可用的工具
          try {
            final tools = await _getRealMcpTools(assistant.mcpServerIds);
            _updateMcpDebugInfo('✅ 成功获取 ${tools.length} 个MCP工具\n');
            if (tools.isNotEmpty) {
              _updateMcpDebugInfo('📋 可用工具列表:\n');
              for (final tool in tools) {
                final functionInfo = tool['function'] as Map<String, dynamic>;
                _updateMcpDebugInfo(
                    '  - ${functionInfo['name']}: ${functionInfo['description']}\n');
              }
              _updateMcpDebugInfo('💡 这些工具将通过AI服务传递给LLM，并在需要时自动调用\n');
            } else {
              _updateMcpDebugInfo('⚠️ 未获取到任何可用工具\n');
            }
          } catch (e) {
            _updateMcpDebugInfo('❌ 获取MCP工具失败: $e\n');
          }
        }
        _updateMcpDebugInfo('\n');
      } else {
        _updateDebugInfo('🔧 MCP工具: 未启用\n');
        _updateMcpDebugInfo('⚠️ 工具未启用，AI服务不会集成MCP工具\n');
      }
      _updateDebugInfo('\n');

      await _sendMessageWithAiDartService(message);

      // 请求完成，标记 Completer
      if (!_currentRequestCompleter!.isCompleted) {
        _currentRequestCompleter!.complete();
      }
    } catch (e) {
      _updateDebugInfo('❌ 错误: $e\n');
      _showError('请求失败: $e');

      setState(() {
        _responseBody = jsonEncode({
          'error': {
            'message': e.toString(),
            'type': 'request_error',
            'timestamp': DateTime.now().toIso8601String(),
          },
        });
      });

      // 请求失败，标记 Completer
      if (!_currentRequestCompleter!.isCompleted) {
        _currentRequestCompleter!.completeError(e);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
      _currentRequestCompleter = null;
    }
  }

  /// 取消当前请求
  void _cancelRequest() {
    if (_currentRequestCompleter != null &&
        !_currentRequestCompleter!.isCompleted) {
      _currentRequestCompleter!.completeError('用户取消请求');
      _updateDebugInfo('⚠️ 用户取消了请求\n');
      setState(() {
        _isLoading = false;
      });
      _currentRequestCompleter = null;
    }
  }

  /// 清空所有响应和调试信息
  void _clearAllResponses() {
    setState(() {
      _response = '';
      _thinkingContent = '';
      _debugInfo = '';
      _requestBody = '';
      _responseBody = '';
      _streamChunks.clear();
      _thinkingChunks.clear();
      _mcpDebugInfo = '';
    });
  }

  /// 显示清空确认对话框
  Future<void> _showClearConfirmDialog() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空响应'),
        content: const Text('确定要清空所有响应和调试信息吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (shouldClear == true && mounted) {
      _clearAllResponses();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已清空所有响应')),
      );
    }
  }

  /// 使用基础AI接口发送消息（调试专用）
  ///
  /// 注意：此方法使用 sendChatMessageProvider，这是基础的AI接口，
  /// 不包含标题生成、对话保存等业务逻辑，专门用于API测试和调试。
  ///
  /// 正常聊天请使用 conversationChatProvider。
  Future<void> _sendMessageWithAiDartService(String message) async {
    _updateDebugInfo('🔄 开始请求（使用基础AI接口）...\n');

    try {
      // 转换 provider 类型
      final provider = _convertToModelsProvider();

      // 获取选择的助手或创建测试助手
      final assistant = await _getSelectedOrTestAssistant();

      final modelName = _modelController.text.trim();
      final chatHistory = <Message>[];

      if (_isStreamMode) {
        // 流式请求（使用新架构）
        _updateDebugInfo('🔄 开始流式请求（使用新AI架构）...\n');

        // 注意：这是一个简化的实现，实际的流式处理需要在UI层监听
        _updateDebugInfo('💡 提示：新架构的流式功能需要在UI层使用 ref.listen 监听\n');

        // 作为演示，使用普通请求
        final response = await ref.read(
          sendChatMessageProvider(
            SendChatMessageParams(
              provider: provider,
              assistant: assistant,
              modelName: modelName,
              chatHistory: chatHistory,
              userMessage: message,
              // 使用基础AI接口，不包含业务逻辑
            ),
          ).future,
        );

        setState(() {
          _response = response.content;
          _thinkingContent = response.thinking ?? '';
          _responseBody = jsonEncode({
            'new_ai_architecture': true,
            'stream_mode': false, // 简化实现
            'content': response.content,
            'thinking_content': response.thinking,
            'usage': response.usage != null
                ? {
                    'prompt_tokens': response.usage!.promptTokens,
                    'completion_tokens': response.usage!.completionTokens,
                    'total_tokens': response.usage!.totalTokens,
                  }
                : null,
          });
        });

        _updateDebugInfo('✅ 新架构请求完成\n');
        _updateDebugInfo('响应长度: ${response.content.length} 字符\n');
        if (response.thinking != null && response.thinking!.isNotEmpty) {
          _updateDebugInfo('🧠 思考内容长度: ${response.thinking!.length} 字符\n');
        }
      } else {
        // 普通请求（使用新架构）
        final response = await ref.read(
          sendChatMessageProvider(
            SendChatMessageParams(
              provider: provider,
              assistant: assistant,
              modelName: modelName,
              chatHistory: chatHistory,
              userMessage: message,
              // 使用基础AI接口，不包含业务逻辑
            ),
          ).future,
        );

        setState(() {
          _response = response.content;
          _thinkingContent = response.thinking ?? '';
          _responseBody = jsonEncode({
            'llm_dart_service': true,
            'stream_mode': false,
            'content': response.content,
            'thinking_content': response.thinking,
            'usage': response.usage != null
                ? {
                    'prompt_tokens': response.usage!.promptTokens,
                    'completion_tokens': response.usage!.completionTokens,
                    'total_tokens': response.usage!.totalTokens,
                  }
                : null,
          });
        });

        _updateDebugInfo('✅ llm_dart 请求完成\n');
        _updateDebugInfo('响应长度: ${response.content.length} 字符\n');
        if (response.thinking != null && response.thinking!.isNotEmpty) {
          _updateDebugInfo('🧠 思考内容长度: ${response.thinking!.length} 字符\n');
        }
        if (response.usage != null) {
          _updateDebugInfo('Token使用情况:\n');
          _updateDebugInfo('  输入: ${response.usage!.promptTokens}\n');
          _updateDebugInfo('  输出: ${response.usage!.completionTokens}\n');
          _updateDebugInfo('  总计: ${response.usage!.totalTokens}\n');
        }
      }
    } catch (e) {
      _updateDebugInfo('❌ 请求失败: $e\n');
      setState(() {
        _responseBody = jsonEncode({'error': true, 'message': e.toString()});
      });
      rethrow;
    }
  }

  /// 获取选择的助手或创建测试助手
  Future<AiAssistant> _getSelectedOrTestAssistant() async {
    // 如果选择了助手，使用选择的助手
    if (_selectedAssistantId != null) {
      final assistants = ref.read(aiAssistantsProvider);
      final selectedAssistant =
          assistants.where((a) => a.id == _selectedAssistantId).firstOrNull;

      if (selectedAssistant != null) {
        _updateDebugInfo('🤖 使用选择的助手: ${selectedAssistant.name}\n');
        _updateDebugInfo(
            '助手工具设置: ${selectedAssistant.enableTools ? "已启用" : "未启用"}\n');
        if (selectedAssistant.enableTools &&
            selectedAssistant.mcpServerIds.isNotEmpty) {
          _updateDebugInfo(
              '助手MCP服务器: ${selectedAssistant.mcpServerIds.join(", ")}\n');
        }
        return selectedAssistant;
      }
    }

    // 创建测试助手
    _updateDebugInfo('🧪 使用测试助手配置\n');
    return AiAssistant(
      id: 'debug-assistant',
      name: 'Debug Assistant',
      description: 'AI Debug Assistant for testing',
      systemPrompt: _systemPromptController.text.trim().isEmpty
          ? 'You are a helpful assistant.'
          : _systemPromptController.text.trim(),
      temperature: double.tryParse(_temperatureController.text) ?? 0.7,
      maxTokens: int.tryParse(_maxTokensController.text) ?? 1000,
      topP: double.tryParse(_topPController.text) ?? 0.9,
      enableReasoning: false,
      enableTools: _enableMcpTools,
      mcpServerIds: _enableMcpTools ? _selectedMcpServerIds : [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 转换 provider 类型
  models.AiProvider _convertToModelsProvider() {
    models.ProviderType providerType;
    switch (_selectedProvider) {
      case 'openai':
        providerType = models.ProviderType.openai;
        break;
      case 'anthropic':
        providerType = models.ProviderType.anthropic;
        break;
      case 'google':
        providerType = models.ProviderType.google;
        break;
      default:
        providerType = models.ProviderType.openai;
    }

    return models.AiProvider(
      id: 'debug-provider',
      name: 'Debug Provider',
      type: providerType,
      apiKey: _apiKeyController.text.trim(),
      baseUrl: _baseUrlController.text.trim().isEmpty
          ? null
          : _baseUrlController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void _updateDebugInfo(String info) {
    setState(() {
      _debugInfo += info;
    });
  }

  void _updateMcpDebugInfo(String info) {
    setState(() {
      _mcpDebugInfo += info;
    });
  }

  String _getMessageHintText() {
    // 如果选择了助手
    if (_selectedAssistantId != null) {
      final assistants = ref.read(aiAssistantsProvider);
      final selectedAssistant =
          assistants.where((a) => a.id == _selectedAssistantId).firstOrNull;

      if (selectedAssistant != null && selectedAssistant.enableTools) {
        return '请帮我调用可用的工具（使用助手的MCP配置）';
      }
      return '你好，请介绍一下你自己。（使用选择的助手）';
    }

    // 使用测试配置
    if (_enableMcpTools &&
        _availableMcpServers.where((s) => s.isEnabled).isNotEmpty) {
      return '请帮我调用可用的工具（测试MCP配置）';
    }

    return '你好，请介绍一下你自己。';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
  }

  @override
  Widget build(BuildContext context) {
    // 监听设置变化，当MCP服务器配置发生变化时重新加载
    ref.listen(settingsNotifierProvider, (previous, next) {
      if (!next.isLoading && next.error == null) {
        _loadMcpServers();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI聊天API调试 (llm_dart)'),
        actions: [
          // 取消请求按钮（仅在请求进行中显示）
          if (_isLoading)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _cancelRequest,
              tooltip: '取消请求',
              color: Theme.of(context).colorScheme.error,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMcpServers,
            tooltip: '刷新MCP服务器',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _showClearConfirmDialog,
            tooltip: '清空所有响应',
          ),
        ],
      ),
      body: Column(
        children: [
          // 配置面板
          Expanded(
            child: SingleChildScrollView(
              padding: DesignConstants.paddingL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPresetSection(),
                  SizedBox(height: DesignConstants.spaceL),
                  _buildAssistantSection(),
                  SizedBox(height: DesignConstants.spaceL),
                  _buildProviderSection(),
                  SizedBox(height: DesignConstants.spaceL),
                  _buildApiConfigSection(),
                  SizedBox(height: DesignConstants.spaceL),
                  _buildParametersSection(),
                  SizedBox(height: DesignConstants.spaceL),
                  _buildMcpSection(),
                  SizedBox(height: DesignConstants.spaceL),
                  _buildMessageSection(),
                  SizedBox(height: DesignConstants.spaceL),
                  _buildActionSection(),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // 可收起的结果面板
          _buildCollapsibleResponsePanel(),
        ],
      ),
    );
  }

  Widget _buildPresetSection() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '快速配置',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: DesignConstants.spaceS),
            Wrap(
              spacing: DesignConstants.spaceS,
              runSpacing: DesignConstants.spaceXS,
              children: _presets.keys.map((preset) {
                return ChoiceChip(
                  label: Text(preset, style: const TextStyle(fontSize: 12)),
                  selected: false,
                  onSelected: (_) => _loadPreset(preset),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistantSection() {
    final assistants = ref.watch(aiAssistantsProvider);
    final enabledAssistants = assistants.where((a) => a.isEnabled).toList();

    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.smart_toy,
                    size: DesignConstants.iconSizeS,
                    color: Theme.of(context).colorScheme.primary),
                SizedBox(width: DesignConstants.spaceS),
                const Text(
                  'AI助手选择',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceS),
            if (enabledAssistants.isEmpty)
              Container(
                padding: DesignConstants.paddingM,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: DesignConstants.radiusS,
                ),
                child: const Text(
                  '暂无可用助手，将使用测试助手配置',
                  style: TextStyle(fontSize: 12),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String?>(
                    value: _selectedAssistantId,
                    decoration: const InputDecoration(
                      labelText: '选择助手',
                      hintText: '选择一个助手或使用测试配置',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('使用测试助手配置'),
                      ),
                      ...enabledAssistants.map((assistant) {
                        return DropdownMenuItem<String?>(
                          value: assistant.id,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🤖'),
                              SizedBox(width: DesignConstants.spaceS),
                              Flexible(
                                child: Text(
                                  assistant.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (assistant.enableTools) ...[
                                SizedBox(width: DesignConstants.spaceXS),
                                Icon(Icons.extension,
                                    size: DesignConstants.iconSizeS,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ],
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedAssistantId = value;
                        // 如果选择了助手，清空MCP工具选择（使用助手的配置）
                        if (value != null) {
                          _enableMcpTools = false;
                          _selectedMcpServerIds.clear();
                        }
                      });
                      _saveCurrentSettings();
                    },
                  ),
                  if (_selectedAssistantId != null) ...[
                    SizedBox(height: DesignConstants.spaceS),
                    _buildSelectedAssistantInfo(),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedAssistantInfo() {
    final assistants = ref.watch(aiAssistantsProvider);
    final selectedAssistant =
        assistants.where((a) => a.id == _selectedAssistantId).firstOrNull;

    if (selectedAssistant == null) return const SizedBox.shrink();

    return Container(
      padding: DesignConstants.paddingS,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primaryContainer
            .withValues(alpha: 0.3),
        borderRadius: DesignConstants.radiusXS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '助手信息:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: DesignConstants.spaceXS),
          Text(
            '• 工具功能: ${selectedAssistant.enableTools ? "已启用" : "未启用"}',
            style: const TextStyle(fontSize: 11),
          ),
          if (selectedAssistant.enableTools &&
              selectedAssistant.mcpServerIds.isNotEmpty)
            Text(
              '• MCP服务器: ${selectedAssistant.mcpServerIds.length}个',
              style: const TextStyle(fontSize: 11),
            ),
          if (selectedAssistant.systemPrompt.isNotEmpty)
            Text(
              '• 系统提示词: ${selectedAssistant.systemPrompt.length > 50 ? "${selectedAssistant.systemPrompt.substring(0, 50)}..." : selectedAssistant.systemPrompt}',
              style: const TextStyle(fontSize: 11),
            ),
        ],
      ),
    );
  }

  Widget _buildProviderSection() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI提供商',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: DesignConstants.spaceS),
            DropdownButtonFormField<String>(
              value: _selectedProvider,
              items: const [
                DropdownMenuItem(
                  value: 'openai',
                  child: Text('OpenAI (及兼容接口)'),
                ),
                DropdownMenuItem(value: 'anthropic', child: Text('Anthropic')),
                DropdownMenuItem(value: 'google', child: Text('Google Gemini')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedProvider = value;
                  });
                  _saveCurrentSettings();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiConfigSection() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'API配置',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: DesignConstants.spaceS),
            TextFormField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API密钥',
                hintText: '输入您的API密钥',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: DesignConstants.spaceS),
            TextFormField(
              controller: _baseUrlController,
              decoration: const InputDecoration(
                labelText: 'API端点 (可选)',
                hintText: 'https://api.example.com/v1',
                border: OutlineInputBorder(),
                helperText: '留空使用默认端点',
              ),
            ),
            SizedBox(height: DesignConstants.spaceS),
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: '模型名称',
                hintText: 'gpt-4, claude-3-haiku-20240307',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParametersSection() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '参数设置',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: DesignConstants.spaceS),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _temperatureController,
                    decoration: const InputDecoration(
                      labelText: 'Temperature',
                      hintText: '0.0-2.0',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: DesignConstants.spaceS),
                Expanded(
                  child: TextFormField(
                    controller: _topPController,
                    decoration: const InputDecoration(
                      labelText: 'Top P',
                      hintText: '0.0-1.0',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: DesignConstants.spaceS),
                Expanded(
                  child: TextFormField(
                    controller: _maxTokensController,
                    decoration: const InputDecoration(
                      labelText: 'Max Tokens',
                      hintText: '1000',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: DesignConstants.spaceS),
            TextFormField(
              controller: _systemPromptController,
              decoration: const InputDecoration(
                labelText: '系统提示词 (可选)',
                hintText: '你是一个乐于助人的AI助手',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMcpSection() {
    final isAssistantSelected = _selectedAssistantId != null;

    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.extension,
                    size: DesignConstants.iconSizeS,
                    color: Theme.of(context).colorScheme.primary),
                SizedBox(width: DesignConstants.spaceS),
                const Text(
                  'MCP工具测试',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Switch(
                  value: _enableMcpTools,
                  onChanged: isAssistantSelected
                      ? null
                      : (value) {
                          setState(() {
                            _enableMcpTools = value;
                            if (!value) {
                              _selectedMcpServerIds.clear();
                            }
                          });
                          _saveCurrentSettings();
                        },
                ),
              ],
            ),
            if (isAssistantSelected) ...[
              SizedBox(height: DesignConstants.spaceS),
              Container(
                padding: DesignConstants.paddingS,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: DesignConstants.radiusXS,
                ),
                child: const Text(
                  '💡 已选择助手，将使用助手的MCP工具配置',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
            if (_enableMcpTools && !isAssistantSelected) ...[
              SizedBox(height: DesignConstants.spaceM),
              const Text(
                '选择MCP服务器:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: DesignConstants.spaceS),
              if (_availableMcpServers.isEmpty)
                Container(
                  padding: DesignConstants.paddingM,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: DesignConstants.radiusS,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '暂无已配置的MCP服务器',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: DesignConstants.spaceS),
                      const Text(
                        '请先在设置页面配置MCP服务器，然后返回此页面进行测试。',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: DesignConstants.spaceS),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const McpSettingsScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.settings,
                            size: DesignConstants.iconSizeS),
                        label: const Text('前往MCP设置',
                            style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: DesignConstants.spaceS,
                              vertical: DesignConstants.spaceXS),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: DesignConstants.spaceS,
                  runSpacing: DesignConstants.spaceXS,
                  children: _availableMcpServers
                      .where((server) => server.isEnabled)
                      .map((server) {
                    final isSelected =
                        _selectedMcpServerIds.contains(server.id);
                    final mcpState = ref.watch(mcpServiceProvider);
                    final serverStatus = mcpState.serverStatuses[server.id] ??
                        McpServerStatus.disconnected;

                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getServerStatusIcon(serverStatus),
                            size: DesignConstants.iconSizeS,
                            color: _getServerStatusColor(serverStatus, context),
                          ),
                          SizedBox(width: DesignConstants.spaceXS),
                          Text(
                            '${server.name} (${server.type.displayName})',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedMcpServerIds.add(server.id);
                          } else {
                            _selectedMcpServerIds.remove(server.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              SizedBox(height: DesignConstants.spaceS),
              Container(
                padding: DesignConstants.paddingS,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.3),
                  borderRadius: DesignConstants.radiusXS,
                ),
                child: Text(
                  '💡 启用MCP工具后，AI可以调用选中服务器提供的工具。\n'
                  '${_availableMcpServers.where((s) => s.isEnabled).isEmpty ? '请先在设置页面配置并启用MCP服务器。' : '测试消息示例：\n'
                      '• "请帮我调用可用的工具"\n'
                      '• "请列出你可以使用的工具"\n'
                      '• "请使用工具帮我完成任务"'}',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageSection() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '消息内容',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: DesignConstants.spaceS),
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: '输入消息',
                hintText: _getMessageHintText(),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection() {
    return Card(
      child: Padding(
        padding: DesignConstants.paddingL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 流式模式切换
            Row(
              children: [
                Switch(
                  value: _isStreamMode,
                  onChanged: (value) {
                    setState(() {
                      _isStreamMode = value;
                    });
                    _saveCurrentSettings();
                  },
                ),
                SizedBox(width: DesignConstants.spaceS),
                const Text('流式模式'),
                const Spacer(),
                if (_isLoading) ...[
                  ElevatedButton.icon(
                    onPressed: _cancelRequest,
                    icon: const Icon(Icons.stop),
                    label: const Text('取消请求'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.errorContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  SizedBox(width: DesignConstants.spaceS),
                  ElevatedButton.icon(
                    onPressed: null,
                    icon: SizedBox(
                      width: DesignConstants.iconSizeS,
                      height: DesignConstants.iconSizeS,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                    label: const Text('发送中...'),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                    label: const Text('发送消息'),
                  ),
                  SizedBox(width: DesignConstants.spaceM),
                  OutlinedButton.icon(
                    onPressed: _diagnoseProvider,
                    icon: const Icon(Icons.health_and_safety),
                    label: const Text('诊断配置'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsibleResponsePanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isResponsePanelExpanded ? 400 : 60,
      child: Column(
        children: [
          // 面板头部 - 可点击收起/展开
          Container(
            height: 60,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isResponsePanelExpanded = !_isResponsePanelExpanded;
                });
              },
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: DesignConstants.spaceL),
                child: Row(
                  children: [
                    Icon(
                      _isResponsePanelExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: DesignConstants.spaceS),
                    Text(
                      '请求响应面板',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const Spacer(),
                    if (_response.isNotEmpty || _debugInfo.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: DesignConstants.spaceS,
                          vertical: DesignConstants.spaceXS,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          borderRadius: DesignConstants.radiusM,
                        ),
                        child: Text(
                          '有数据',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    SizedBox(width: DesignConstants.spaceS),
                    Text(
                      _isResponsePanelExpanded ? '收起' : '展开',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 面板内容 - 只在展开时显示
          if (_isResponsePanelExpanded)
            Expanded(
              child: DefaultTabController(
                length: _enableMcpTools ? 6 : 5,
                child: Column(
                  children: [
                    // 标签栏
                    Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: TabBar(
                        isScrollable: true,
                        tabs: [
                          const Tab(text: '响应内容'),
                          const Tab(text: '思考过程'),
                          const Tab(text: '请求体'),
                          const Tab(text: '响应体'),
                          const Tab(text: '调试信息'),
                          if (_enableMcpTools) const Tab(text: 'MCP调试'),
                        ],
                      ),
                    ),

                    // 标签内容
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildResponseTab(),
                          _buildThinkingTab(),
                          _buildRequestTab(),
                          _buildResponseBodyTab(),
                          _buildDebugTab(),
                          if (_enableMcpTools) _buildMcpDebugTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResponseTab() {
    return Container(
      padding: DesignConstants.paddingL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'AI响应内容',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_response.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(_response),
                  tooltip: '复制响应',
                ),
            ],
          ),
          SizedBox(height: DesignConstants.spaceS),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: DesignConstants.paddingM,
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: DesignConstants.radiusS,
              ),
              child: SingleChildScrollView(
                child: Text(
                  _response.isEmpty ? '等待响应...' : _response,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingTab() {
    return Container(
      padding: DesignConstants.paddingL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology,
                  size: DesignConstants.iconSizeS,
                  color: Theme.of(context).colorScheme.tertiary),
              SizedBox(width: DesignConstants.spaceS),
              const Text(
                '思考过程',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_thinkingContent.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignConstants.spaceS,
                    vertical: DesignConstants.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .tertiaryContainer
                        .withValues(alpha: 0.3),
                    borderRadius: DesignConstants.radiusM,
                  ),
                  child: Text(
                    '${_thinkingContent.length} 字符',
                    style: TextStyle(
                        fontSize: 12,
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer),
                  ),
                ),
                SizedBox(width: DesignConstants.spaceS),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(_thinkingContent),
                  tooltip: '复制思考内容',
                ),
              ],
            ],
          ),
          SizedBox(height: DesignConstants.spaceS),
          if (_thinkingContent.isEmpty)
            Expanded(
              child: Container(
                width: double.infinity,
                padding: DesignConstants.paddingM,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: DesignConstants.radiusS,
                  color: Theme.of(context)
                      .colorScheme
                      .tertiaryContainer
                      .withValues(alpha: 0.3),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.psychology,
                          size: DesignConstants.iconSizeXXL,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                      SizedBox(height: DesignConstants.spaceL),
                      Text(
                        '暂无思考内容',
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 16),
                      ),
                      SizedBox(height: DesignConstants.spaceS),
                      Text(
                        '推理模型（如 o1、DeepSeek R1）会在此显示思考过程',
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Container(
                width: double.infinity,
                padding: DesignConstants.paddingM,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: DesignConstants.radiusS,
                  color: Theme.of(context)
                      .colorScheme
                      .tertiaryContainer
                      .withValues(alpha: 0.3),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _thinkingContent,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRequestTab() {
    return Container(
      padding: DesignConstants.paddingL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '请求体',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_requestBody.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(_requestBody),
                  tooltip: '复制请求体',
                ),
            ],
          ),
          SizedBox(height: DesignConstants.spaceS),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: DesignConstants.paddingM,
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: DesignConstants.radiusS,
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _requestBody.isEmpty ? '点击发送消息后将显示请求详情...' : _requestBody,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseBodyTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '响应体',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_responseBody.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(_responseBody),
                  tooltip: '复制响应体',
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context)
                    .colorScheme
                    .secondaryContainer
                    .withValues(alpha: 0.3),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _responseBody.isEmpty ? '等待响应体...' : _responseBody,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '调试信息',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_debugInfo.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(_debugInfo),
                  tooltip: '复制调试信息',
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _debugInfo.isEmpty ? '等待调试信息...' : _debugInfo,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMcpDebugTab() {
    return Container(
      padding: DesignConstants.paddingL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.extension,
                  size: DesignConstants.iconSizeS,
                  color: Theme.of(context).colorScheme.primary),
              SizedBox(width: DesignConstants.spaceS),
              const Text(
                'MCP调试信息',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_mcpDebugInfo.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(_mcpDebugInfo),
                  tooltip: '复制MCP调试信息',
                ),
            ],
          ),
          SizedBox(height: DesignConstants.spaceS),
          if (_selectedMcpServerIds.isNotEmpty) ...[
            Container(
              padding: DesignConstants.paddingS,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: DesignConstants.radiusXS,
              ),
              child: Text(
                '已选择的MCP服务器: ${_selectedMcpServerIds.length} 个\n'
                '服务器ID: ${_selectedMcpServerIds.join(", ")}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            SizedBox(height: DesignConstants.spaceS),
          ],
          Expanded(
            child: Container(
              width: double.infinity,
              padding: DesignConstants.paddingM,
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: DesignConstants.radiusS,
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.1),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _mcpDebugInfo.isEmpty
                      ? '等待MCP调试信息...\n\n'
                          '💡 提示：\n'
                          '1. 启用MCP工具开关\n'
                          '2. 选择要使用的MCP服务器\n'
                          '3. 发送包含工具调用请求的消息\n'
                          '4. 观察AI是否能识别并调用MCP工具'
                      : _mcpDebugInfo,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取服务器状态图标
  IconData _getServerStatusIcon(McpServerStatus status) {
    switch (status) {
      case McpServerStatus.connected:
        return Icons.check_circle;
      case McpServerStatus.connecting:
        return Icons.sync;
      case McpServerStatus.error:
        return Icons.error;
      case McpServerStatus.disconnected:
        return Icons.circle_outlined;
    }
  }

  /// 获取服务器状态颜色
  Color _getServerStatusColor(McpServerStatus status, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case McpServerStatus.connected:
        return colorScheme.primary;
      case McpServerStatus.connecting:
        return colorScheme.tertiary;
      case McpServerStatus.error:
        return colorScheme.error;
      case McpServerStatus.disconnected:
        return colorScheme.onSurfaceVariant;
    }
  }

  /// 获取服务器状态文本
  String _getStatusText(McpServerStatus status) {
    switch (status) {
      case McpServerStatus.connected:
        return '已连接';
      case McpServerStatus.connecting:
        return '连接中';
      case McpServerStatus.error:
        return '连接错误';
      case McpServerStatus.disconnected:
        return '未连接';
    }
  }

  /// 获取真实的MCP工具列表
  Future<List<Map<String, dynamic>>> _getRealMcpTools(
      [List<String>? serverIds]) async {
    try {
      // 🔧 修复：通过Riverpod Provider获取MCP服务管理器，而不是直接创建新实例
      final mcpManager = ref.read(mcpServiceManagerProvider);
      final targetServerIds = serverIds ?? _selectedMcpServerIds;

      // 检查MCP服务是否启用
      if (!mcpManager.isEnabled) {
        _updateMcpDebugInfo('⚠️ MCP服务未启用，无法获取工具\n');
        return [];
      }

      // 检查服务器连接状态
      final connectedServerIds = <String>[];
      for (final serverId in targetServerIds) {
        final status = mcpManager.getServerStatus(serverId);
        if (status == McpServerStatus.connected) {
          connectedServerIds.add(serverId);
        } else {
          _updateMcpDebugInfo(
              '⚠️ 服务器 $serverId 未连接 (状态: ${status.displayName})\n');
        }
      }

      if (connectedServerIds.isEmpty) {
        _updateMcpDebugInfo('⚠️ 没有已连接的MCP服务器，无法获取工具\n');
        return [];
      }

      _updateMcpDebugInfo('🔍 从 ${connectedServerIds.length} 个已连接服务器获取工具...\n');

      final mcpTools = await mcpManager.getAvailableTools(connectedServerIds);

      if (mcpTools.isEmpty) {
        _updateMcpDebugInfo('⚠️ 未找到可用的MCP工具\n');
        return [];
      }

      _updateMcpDebugInfo('✅ 成功获取 ${mcpTools.length} 个MCP工具\n');

      // 转换为OpenAI function calling格式
      return mcpTools.map((mcpTool) {
        return {
          'type': 'function',
          'function': {
            'name': mcpTool.name,
            'description': mcpTool.description ?? '无描述',
            'parameters': _convertMcpSchemaToOpenAISchema(mcpTool.inputSchema),
          },
        };
      }).toList();
    } catch (e) {
      _updateMcpDebugInfo('❌ 获取MCP工具失败: $e\n');

      // 如果获取失败，返回空列表而不是错误工具
      return [];
    }
  }

  /// 将MCP输入模式转换为OpenAI参数模式
  Map<String, dynamic> _convertMcpSchemaToOpenAISchema(
      Map<String, dynamic>? inputSchema) {
    if (inputSchema == null) {
      return {
        'type': 'object',
        'properties': {},
        'required': [],
      };
    }

    // 提取属性定义
    final properties = <String, dynamic>{};
    final mcpProperties =
        inputSchema['properties'] as Map<String, dynamic>? ?? {};

    for (final entry in mcpProperties.entries) {
      final propName = entry.key;
      final propDef = entry.value as Map<String, dynamic>;

      properties[propName] = {
        'type': propDef['type'] ?? 'string',
        'description': propDef['description'] ?? '',
        if (propDef['enum'] != null) 'enum': propDef['enum'],
        if (propDef['default'] != null) 'default': propDef['default'],
        if (propDef['minimum'] != null) 'minimum': propDef['minimum'],
        if (propDef['maximum'] != null) 'maximum': propDef['maximum'],
      };
    }

    // 提取必需参数
    final required = (inputSchema['required'] as List?)?.cast<String>() ?? [];

    return {
      'type': inputSchema['type'] ?? 'object',
      'properties': properties,
      'required': required,
    };
  }

  /// 重新连接MCP服务器（用于助手配置）
  Future<void> _reconnectMcpServersForAssistant(List<String> serverIds) async {
    try {
      final mcpNotifier = ref.read(mcpServiceProvider.notifier);

      for (final serverId in serverIds) {
        final status = ref.read(mcpServerStatusProvider(serverId));
        if (status != McpServerStatus.connected) {
          _updateMcpDebugInfo('🔄 重新连接服务器: $serverId\n');
          await mcpNotifier.reconnectServer(serverId);

          // 等待一下让连接状态更新
          await Future.delayed(const Duration(milliseconds: 500));

          final newStatus = ref.read(mcpServerStatusProvider(serverId));
          _updateMcpDebugInfo('  结果: ${_getStatusText(newStatus)}\n');
        }
      }
    } catch (e) {
      _updateMcpDebugInfo('❌ 重新连接失败: $e\n');
    }
  }

  /// 诊断提供商配置
  Future<void> _diagnoseProvider() async {
    if (_apiKeyController.text.trim().isEmpty) {
      _showError('请先输入API密钥');
      return;
    }

    setState(() {
      _isLoading = true;
      _debugInfo = '';
      _response = '';
      _thinkingContent = '';
      _requestBody = '';
      _responseBody = '';
    });

    try {
      _updateDebugInfo('🔍 开始诊断提供商配置...\n\n');

      // 创建提供商配置
      final provider = _convertToModelsProvider();
      final modelName = _modelController.text.trim();

      _updateDebugInfo('📋 基本配置检查:\n');
      _updateDebugInfo('  提供商: ${provider.name}\n');
      _updateDebugInfo('  模型: $modelName\n');
      _updateDebugInfo(
          '  API密钥: ${provider.apiKey.isNotEmpty ? "已配置" : "未配置"}\n');
      _updateDebugInfo('  基础URL: ${provider.baseUrl ?? "使用默认"}\n\n');

      // 使用ChatService的诊断功能
      final chatService = ref.read(aiChatServiceProvider);
      final diagnosis = await chatService.diagnoseProvider(
        provider: provider,
        modelName: modelName,
      );

      _updateDebugInfo('🏥 诊断结果:\n');
      _updateDebugInfo(
          '  整体状态: ${diagnosis['isHealthy'] ? "✅ 健康" : "❌ 有问题"}\n\n');

      // 显示各项检查结果
      final checks = diagnosis['checks'] as Map<String, dynamic>;
      _updateDebugInfo('📊 详细检查:\n');
      checks.forEach((key, value) {
        final status = value == true ? '✅' : '❌';
        final keyName = _getCheckDisplayName(key);
        _updateDebugInfo('  $keyName: $status\n');
      });

      // 显示问题和建议
      final issues = diagnosis['issues'] as List<String>;
      final suggestions = diagnosis['suggestions'] as List<String>;

      if (issues.isNotEmpty) {
        _updateDebugInfo('\n⚠️ 发现的问题:\n');
        for (int i = 0; i < issues.length; i++) {
          _updateDebugInfo('  ${i + 1}. ${issues[i]}\n');
        }
      }

      if (suggestions.isNotEmpty) {
        _updateDebugInfo('\n💡 解决建议:\n');
        for (int i = 0; i < suggestions.length; i++) {
          _updateDebugInfo('  ${i + 1}. ${suggestions[i]}\n');
        }
      }

      if (diagnosis['isHealthy'] == true) {
        _updateDebugInfo('\n🎉 配置正常！可以正常发送消息。\n');
      } else {
        _updateDebugInfo('\n🔧 请根据上述建议修复配置问题。\n');
      }
    } catch (e) {
      _updateDebugInfo('\n❌ 诊断过程出错: $e\n');
      _showError('诊断失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 获取检查项的显示名称
  String _getCheckDisplayName(String key) {
    switch (key) {
      case 'apiKey':
        return 'API密钥';
      case 'baseUrl':
        return '基础URL';
      case 'connection':
        return '网络连接';
      default:
        return key;
    }
  }
}
