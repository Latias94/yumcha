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

import '../../../ai_management/domain/entities/ai_provider.dart' as models;
import '../../../ai_management/domain/entities/ai_assistant.dart';
import '../../../chat/domain/entities/message.dart';
import '../../../settings/domain/entities/mcp_server_config.dart';
import '../../../settings/presentation/providers/settings_notifier.dart';
import '../../../settings/presentation/providers/mcp_service_provider.dart';
import '../../../settings/presentation/screens/mcp_settings_screen.dart';
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
  List<String> _selectedMcpServerIds = [];

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
      'provider': 'openai', // 使用OpenAI兼容接口
      'model': 'deepseek-chat',
      'baseUrl': 'https://api.deepseek.com/v1',
    },
    'DeepSeek R1 (推理)': {
      'provider': 'openai', // 使用OpenAI兼容接口
      'model': 'deepseek-r1',
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
      'baseUrl': 'https://generativelanguage.googleapis.com/v1',
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

  String _formatRequestBody() {
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
      // 添加工具信息（如果启用了MCP工具）
      if (_enableMcpTools && _selectedMcpServerIds.isNotEmpty)
        'tools': _selectedMcpServerIds.map((serverId) {
          final server =
              _availableMcpServers.firstWhere((s) => s.id == serverId);
          return {
            'type': 'function',
            'function': {
              'name':
                  'mcp_tool_${server.name.toLowerCase().replaceAll(' ', '_')}',
              'description': '来自 ${server.name} 服务器的MCP工具',
              'parameters': {
                'type': 'object',
                'properties': {},
                'required': [],
              },
            },
          };
        }).toList(),
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
    setState(() {
      _requestBody = _formatRequestBody();
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

      // MCP调试信息
      if (_enableMcpTools) {
        _updateDebugInfo('🔧 MCP工具: 已启用\n');
        _updateDebugInfo('选择的服务器: ${_selectedMcpServerIds.length} 个\n');
        _updateMcpDebugInfo('🔧 MCP工具调试开始...\n');
        _updateMcpDebugInfo('助手工具启用状态: $_enableMcpTools\n');
        _updateMcpDebugInfo('选择的服务器ID: ${_selectedMcpServerIds.join(", ")}\n');
        for (final serverId in _selectedMcpServerIds) {
          final server =
              _availableMcpServers.firstWhere((s) => s.id == serverId);
          _updateMcpDebugInfo(
              '服务器: ${server.name} (${server.type.displayName})\n');
        }
        _updateMcpDebugInfo('💡 提示: 工具将被添加到请求体的 tools 字段中\n');
        _updateMcpDebugInfo('\n');
      } else {
        _updateDebugInfo('🔧 MCP工具: 未启用\n');
        _updateMcpDebugInfo('⚠️ 工具未启用，请求体中不会包含 tools 字段\n');
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

      // 创建测试助手
      final assistant = AiAssistant(
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
        enableTools: _enableMcpTools, // 关键修复：根据MCP工具开关设置enableTools
        mcpServerIds: _enableMcpTools ? _selectedMcpServerIds : [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPresetSection(),
                  const SizedBox(height: 16),
                  _buildProviderSection(),
                  const SizedBox(height: 16),
                  _buildApiConfigSection(),
                  const SizedBox(height: 16),
                  _buildParametersSection(),
                  const SizedBox(height: 16),
                  _buildMcpSection(),
                  const SizedBox(height: 16),
                  _buildMessageSection(),
                  const SizedBox(height: 16),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '快速配置',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
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

  Widget _buildProviderSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI提供商',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'API配置',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API密钥',
                hintText: '输入您的API密钥',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _baseUrlController,
              decoration: const InputDecoration(
                labelText: 'API端点 (可选)',
                hintText: 'https://api.example.com/v1',
                border: OutlineInputBorder(),
                helperText: '留空使用默认端点',
              ),
            ),
            const SizedBox(height: 8),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '参数设置',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
                const SizedBox(width: 8),
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
                const SizedBox(width: 8),
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
            const SizedBox(height: 8),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.extension,
                    size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'MCP工具测试',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Switch(
                  value: _enableMcpTools,
                  onChanged: (value) {
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
            if (_enableMcpTools) ...[
              const SizedBox(height: 12),
              const Text(
                '选择MCP服务器:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              if (_availableMcpServers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '暂无已配置的MCP服务器',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '请先在设置页面配置MCP服务器，然后返回此页面进行测试。',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const McpSettingsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings, size: 16),
                        label: const Text('前往MCP设置',
                            style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
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
                            size: 12,
                            color: _getServerStatusColor(serverStatus, context),
                          ),
                          const SizedBox(width: 4),
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
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '消息内容',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: '输入消息',
                hintText: _enableMcpTools &&
                        _availableMcpServers
                            .where((s) => s.isEnabled)
                            .isNotEmpty
                    ? '请帮我调用可用的工具'
                    : '你好，请介绍一下你自己。',
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
        padding: const EdgeInsets.all(16),
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
                const SizedBox(width: 8),
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
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: null,
                    icon: const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    label: const Text('发送中...'),
                  ),
                ] else
                  ElevatedButton.icon(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                    label: const Text('发送消息'),
                  ),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      _isResponsePanelExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '有数据',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
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
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology,
                  size: 20, color: Theme.of(context).colorScheme.tertiary),
              const SizedBox(width: 8),
              const Text(
                '思考过程',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_thinkingContent.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .tertiaryContainer
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_thinkingContent.length} 字符',
                    style: TextStyle(
                        fontSize: 12,
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(_thinkingContent),
                  tooltip: '复制思考内容',
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (_thinkingContent.isEmpty)
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
                      .tertiaryContainer
                      .withValues(alpha: 0.3),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.psychology,
                          size: 48,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text(
                        '暂无思考内容',
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 16),
                      ),
                      const SizedBox(height: 8),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
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
      padding: const EdgeInsets.all(16),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.extension,
                  size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
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
          const SizedBox(height: 8),
          if (_selectedMcpServerIds.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '已选择的MCP服务器: ${_selectedMcpServerIds.length} 个\n'
                '服务器ID: ${_selectedMcpServerIds.join(", ")}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
          ],
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
}
