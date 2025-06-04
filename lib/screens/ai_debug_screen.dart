import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ai_dart_service.dart';
import '../models/ai_provider.dart' as models;
import '../models/ai_assistant.dart';
import '../models/message.dart';
import 'dart:convert';

class AiDebugScreen extends StatefulWidget {
  const AiDebugScreen({super.key});

  @override
  State<AiDebugScreen> createState() => _AiDebugScreenState();
}

class _AiDebugScreenState extends State<AiDebugScreen> {
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

  // 结果显示
  String _response = '';
  String _thinkingContent = '';
  String _debugInfo = '';
  String _requestBody = '';
  String _responseBody = '';
  final List<String> _streamChunks = [];
  final List<String> _thinkingChunks = [];

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
    _loadPreset('OpenAI GPT-4');
  }

  @override
  void dispose() {
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

    setState(() {
      _isLoading = true;
      _response = '';
      _thinkingContent = '';
      _debugInfo = '';
      _requestBody = '';
      _responseBody = '';
      _streamChunks.clear();
      _thinkingChunks.clear();
    });

    // 生成请求体
    setState(() {
      _requestBody = _formatRequestBody();
    });

    try {
      _updateDebugInfo('🚀 开始AI Dart请求...\n');
      _updateDebugInfo('提供商: $_selectedProvider\n');
      _updateDebugInfo('模型: ${_modelController.text}\n');
      _updateDebugInfo(
        'API端点: ${_baseUrlController.text.isEmpty ? "默认" : _baseUrlController.text}\n',
      );
      _updateDebugInfo(
        '参数: temperature=${_temperatureController.text}, topP=${_topPController.text}\n\n',
      );

      await _sendMessageWithAiDartService(message);
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 使用 ai_dart service 发送消息
  Future<void> _sendMessageWithAiDartService(String message) async {
    final aiService = AiDartService();

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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final modelName = _modelController.text.trim();
    final chatHistory = <Message>[];

    if (_isStreamMode) {
      // 流式请求
      final stream = aiService.sendChatStreamRequest(
        provider: provider,
        assistant: assistant,
        modelName: modelName,
        chatHistory: chatHistory,
        userMessage: message,
      );

      String fullResponse = '';
      String fullThinking = '';
      await for (final event in stream) {
        if (event.hasContent) {
          setState(() {
            _streamChunks.add(event.delta!);
            fullResponse += event.delta!;
            _response = fullResponse;
          });
          _updateDebugInfo('📝 收到内容块: ${event.delta!.length} 字符\n');
        } else if (event.hasThinking) {
          setState(() {
            _thinkingChunks.add(event.thinkingDelta!);
            fullThinking += event.thinkingDelta!;
            _thinkingContent = fullThinking;
          });
          _updateDebugInfo('🧠 收到思考块: ${event.thinkingDelta!.length} 字符\n');
        } else if (event.isCompleted) {
          // 处理完成时的最终思考内容
          if (event.finalThinking != null && event.finalThinking!.isNotEmpty) {
            setState(() {
              _thinkingContent = event.finalThinking!;
            });
            _updateDebugInfo(
              '🧠 收到完整思考内容: ${event.finalThinking!.length} 字符\n',
            );
          }

          setState(() {
            _responseBody = jsonEncode({
              'ai_dart_service': true,
              'stream_mode': true,
              'total_chunks': _streamChunks.length,
              'thinking_chunks': _thinkingChunks.length,
              'total_content': fullResponse,
              'thinking_content': _thinkingContent.isNotEmpty
                  ? _thinkingContent
                  : null,
              'usage': event.usage != null
                  ? {
                      'prompt_tokens': event.usage!.promptTokens,
                      'completion_tokens': event.usage!.completionTokens,
                      'total_tokens': event.usage!.totalTokens,
                    }
                  : null,
            });
          });
          _updateDebugInfo('✅ ai_dart 流式响应完成\n');
          if (event.usage != null) {
            _updateDebugInfo('Token使用情况:\n');
            _updateDebugInfo('  输入: ${event.usage!.promptTokens}\n');
            _updateDebugInfo('  输出: ${event.usage!.completionTokens}\n');
            _updateDebugInfo('  总计: ${event.usage!.totalTokens}\n');
          }
        } else if (event.isError) {
          _updateDebugInfo('❌ ai_dart 流式错误: ${event.error}\n');
          throw Exception(event.error);
        }
      }
    } else {
      // 普通请求
      final response = await aiService.sendChatRequest(
        provider: provider,
        assistant: assistant,
        modelName: modelName,
        chatHistory: chatHistory,
        userMessage: message,
      );

      setState(() {
        _response = response.content ?? '';
        _thinkingContent = response.thinking ?? '';
        _responseBody = jsonEncode({
          'ai_dart_service': true,
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

      _updateDebugInfo('✅ ai_dart 请求完成\n');
      _updateDebugInfo('响应长度: ${(response.content ?? '').length} 字符\n');
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI聊天API调试 (ai_dart)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              setState(() {
                _response = '';
                _thinkingContent = '';
                _debugInfo = '';
                _requestBody = '';
                _responseBody = '';
                _streamChunks.clear();
                _thinkingChunks.clear();
              });
            },
            tooltip: '清空结果',
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
              decoration: const InputDecoration(
                labelText: '输入消息',
                hintText: '你好，请介绍一下你自己。',
                border: OutlineInputBorder(),
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
                  },
                ),
                const SizedBox(width: 8),
                const Text('流式模式'),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(_isLoading ? '发送中...' : '发送消息'),
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
                length: 5,
                child: Column(
                  children: [
                    // 标签栏
                    Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: const TabBar(
                        isScrollable: true,
                        tabs: [
                          Tab(text: '响应内容'),
                          Tab(text: '思考过程'),
                          Tab(text: '请求体'),
                          Tab(text: '响应体'),
                          Tab(text: '调试信息'),
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
                border: Border.all(color: Colors.grey.shade300),
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
              const Icon(Icons.psychology, size: 20, color: Colors.orange),
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
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_thinkingContent.length} 字符',
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
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
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.orange.shade50,
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.psychology, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        '暂无思考内容',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '推理模型（如 o1、DeepSeek R1）会在此显示思考过程',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
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
                  border: Border.all(color: Colors.orange.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.orange.shade50,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _thinkingContent,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: Colors.black87,
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
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue.shade50,
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
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.green.shade50,
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
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
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
}
