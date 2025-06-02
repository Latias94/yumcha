import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../src/rust/api/ai_chat.dart';
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
  final _stopSequencesController = TextEditingController();

  // 状态变量
  AiProvider _selectedProvider = const AiProvider.openAi();
  bool _isLoading = false;
  bool _isStreamMode = false;

  // 结果显示
  String _response = '';
  String _debugInfo = '';
  String _requestBody = '';
  String _responseBody = '';
  String _rawRequestInfo = '';
  final List<String> _streamChunks = [];
  TokenUsage? _lastUsage;

  // 预设配置 - 增加更多兼容接口
  static const Map<String, Map<String, String>> _presets = {
    'OpenAI GPT-4': {
      'provider': 'openai',
      'model': 'gpt-4',
      'baseUrl': 'https://api.openai.com/v1',
    },
    'OpenAI GPT-3.5': {
      'provider': 'openai',
      'model': 'gpt-3.5-turbo',
      'baseUrl': 'https://api.openai.com/v1',
    },
    'Azure OpenAI': {
      'provider': 'openai',
      'model': 'gpt-4',
      'baseUrl':
          'https://your-resource.openai.azure.com/openai/deployments/your-deployment/chat/completions?api-version=2024-02-15-preview',
    },
    'DeepSeek': {
      'provider': 'deepseek',
      'model': 'deepseek-chat',
      'baseUrl': 'https://api.deepseek.com/v1',
    },
    'Moonshot': {
      'provider': 'openai',
      'model': 'moonshot-v1-8k',
      'baseUrl': 'https://api.moonshot.cn/v1',
    },
    'GLM-4': {
      'provider': 'openai',
      'model': 'glm-4',
      'baseUrl': 'https://open.bigmodel.cn/api/paas/v4',
    },
    'Anthropic Claude': {
      'provider': 'anthropic',
      'model': 'claude-3-haiku-20240307',
      'baseUrl': 'https://api.anthropic.com/v1',
    },
    'Google Gemini': {
      'provider': 'gemini',
      'model': 'gemini-2.0-flash',
      'baseUrl': 'https://generativelanguage.googleapis.com/v1',
    },
    'Groq Llama': {
      'provider': 'groq',
      'model': 'llama-3.1-8b-instant',
      'baseUrl': 'https://api.groq.com/openai/v1',
    },
    'Local Ollama': {
      'provider': 'ollama',
      'model': 'llama3.1:8b',
      'baseUrl': 'http://localhost:11434/v1',
    },
    'Custom OpenAI Compatible': {
      'provider': 'openai',
      'model': 'custom-model',
      'baseUrl': 'http://localhost:8000/v1',
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
    _stopSequencesController.dispose();
    super.dispose();
  }

  void _loadPreset(String presetName) {
    final preset = _presets[presetName];
    if (preset == null) return;

    setState(() {
      switch (preset['provider']) {
        case 'openai':
          _selectedProvider = const AiProvider.openAi();
          break;
        case 'anthropic':
          _selectedProvider = const AiProvider.anthropic();
          break;
        case 'gemini':
          _selectedProvider = const AiProvider.gemini();
          break;
        case 'groq':
          _selectedProvider = const AiProvider.groq();
          break;
        case 'ollama':
          _selectedProvider = const AiProvider.ollama();
          break;
        case 'deepseek':
          _selectedProvider = const AiProvider.deepSeek();
          break;
        default:
          _selectedProvider = const AiProvider.openAi();
      }

      _modelController.text = preset['model'] ?? '';
      _baseUrlController.text = preset['baseUrl'] ?? '';
    });
  }

  AiChatOptions _buildChatOptions() {
    List<String>? stopSequences;
    if (_stopSequencesController.text.trim().isNotEmpty) {
      stopSequences = _stopSequencesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return AiChatOptions(
      model: _modelController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      baseUrl: _baseUrlController.text.trim().isEmpty
          ? null
          : _baseUrlController.text.trim(),
      temperature: double.tryParse(_temperatureController.text),
      topP: double.tryParse(_topPController.text),
      maxTokens: int.tryParse(_maxTokensController.text),
      systemPrompt: _systemPromptController.text.trim().isEmpty
          ? null
          : _systemPromptController.text.trim(),
      stopSequences: stopSequences,
    );
  }

  String _formatRequestBody() {
    final options = _buildChatOptions();
    final message = _messageController.text.trim();

    final requestData = {
      'model': options.model,
      'messages': [
        if (options.systemPrompt != null)
          {'role': 'system', 'content': options.systemPrompt},
        {'role': 'user', 'content': message},
      ],
      if (options.temperature != null) 'temperature': options.temperature,
      if (options.topP != null) 'top_p': options.topP,
      if (options.maxTokens != null) 'max_tokens': options.maxTokens,
      if (options.stopSequences != null && options.stopSequences!.isNotEmpty)
        'stop': options.stopSequences,
      if (_isStreamMode) 'stream': true,
    };

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(requestData);
  }

  String _formatRequestInfo() {
    final options = _buildChatOptions();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${options.apiKey.substring(0, 8)}...${options.apiKey.substring(options.apiKey.length - 4)}',
      'User-Agent': 'YumCha-AI-Debug/1.0',
    };

    final info = StringBuffer();
    info.writeln('📡 HTTP 请求信息');
    info.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    info.writeln('URL: ${options.baseUrl ?? "默认端点"}');
    info.writeln('Method: POST');
    info.writeln('Provider: $_selectedProvider');
    info.writeln();
    info.writeln('Headers:');
    headers.forEach((key, value) {
      info.writeln('  $key: $value');
    });
    info.writeln();

    return info.toString();
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
      _debugInfo = '';
      _requestBody = '';
      _responseBody = '';
      _rawRequestInfo = '';
      _streamChunks.clear();
      _lastUsage = null;
    });

    // 生成请求体和请求信息
    setState(() {
      _requestBody = _formatRequestBody();
      _rawRequestInfo = _formatRequestInfo();
    });

    try {
      final options = _buildChatOptions();
      final client = AiChatClient(
        provider: _selectedProvider,
        options: options,
      );

      final messages = [ChatMessage(role: ChatRole.user, content: message)];

      _updateDebugInfo('🚀 开始请求...\n');
      _updateDebugInfo('提供商: $_selectedProvider\n');
      _updateDebugInfo('模型: ${_modelController.text}\n');
      _updateDebugInfo(
        'API端点: ${_baseUrlController.text.isEmpty ? "默认" : _baseUrlController.text}\n',
      );
      _updateDebugInfo(
        '参数: temperature=${_temperatureController.text}, topP=${_topPController.text}\n',
      );
      if (_stopSequencesController.text.trim().isNotEmpty) {
        _updateDebugInfo('停止序列: ${_stopSequencesController.text}\n');
      }
      _updateDebugInfo('\n');

      if (_isStreamMode) {
        await _handleStreamChat(client, messages);
      } else {
        await _handleNormalChat(client, messages);
      }
    } catch (e) {
      _updateDebugInfo('❌ 错误: $e\n');
      _showError('请求失败: $e');

      // 生成错误响应体
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

  Future<void> _handleNormalChat(
    AiChatClient client,
    List<ChatMessage> messages,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final response = await client.chat(messages: messages);
      stopwatch.stop();

      setState(() {
        _response = response.content;
        _lastUsage = response.usage;
      });

      // 生成模拟响应体
      final responseData = {
        'id': 'chatcmpl-${DateTime.now().millisecondsSinceEpoch}',
        'object': 'chat.completion',
        'created': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'model': response.model,
        'choices': [
          {
            'index': 0,
            'message': {'role': 'assistant', 'content': response.content},
            'finish_reason': 'stop',
          },
        ],
        if (response.usage != null)
          'usage': {
            'prompt_tokens': response.usage!.promptTokens,
            'completion_tokens': response.usage!.completionTokens,
            'total_tokens': response.usage!.totalTokens,
          },
      };

      setState(() {
        _responseBody = const JsonEncoder.withIndent(
          '  ',
        ).convert(responseData);
      });

      _updateDebugInfo('✅ 请求完成 (${stopwatch.elapsedMilliseconds}ms)\n');
      _updateDebugInfo('响应模型: ${response.model}\n');
      _updateDebugInfo('响应长度: ${response.content.length} 字符\n');
      if (response.usage != null) {
        _updateDebugInfo('Token使用情况:\n');
        _updateDebugInfo('  输入: ${response.usage!.promptTokens}\n');
        _updateDebugInfo('  输出: ${response.usage!.completionTokens}\n');
        _updateDebugInfo('  总计: ${response.usage!.totalTokens}\n');
      }
    } catch (e) {
      stopwatch.stop();
      _updateDebugInfo('❌ 请求失败 (${stopwatch.elapsedMilliseconds}ms): $e\n');
      rethrow;
    }
  }

  Future<void> _handleStreamChat(
    AiChatClient client,
    List<ChatMessage> messages,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final stream = client.chatStream(messages: messages);
      String fullResponse = '';
      final List<Map<String, dynamic>> streamEvents = [];

      await for (final event in stream) {
        switch (event) {
          case ChatStreamEvent_Start():
            _updateDebugInfo('🟢 开始接收流式响应\n');
            streamEvents.add({
              'event': 'start',
              'timestamp': DateTime.now().toIso8601String(),
            });
            break;

          case ChatStreamEvent_Content(:final content):
            setState(() {
              _streamChunks.add(content);
              fullResponse += content;
              _response = fullResponse;
            });
            _updateDebugInfo('📝 收到块: ${content.length} 字符\n');
            streamEvents.add({
              'event': 'content',
              'data': {
                'content': content,
                'timestamp': DateTime.now().toIso8601String(),
              },
            });
            break;

          case ChatStreamEvent_Done(:final totalContent, :final usage):
            stopwatch.stop();
            setState(() {
              _response = totalContent;
              _lastUsage = usage;
            });

            streamEvents.add({
              'event': 'done',
              'data': {
                'total_content': totalContent,
                'usage': usage != null
                    ? {
                        'prompt_tokens': usage.promptTokens,
                        'completion_tokens': usage.completionTokens,
                        'total_tokens': usage.totalTokens,
                      }
                    : null,
                'timestamp': DateTime.now().toIso8601String(),
              },
            });

            // 生成流式响应体
            setState(() {
              _responseBody = const JsonEncoder.withIndent('  ').convert({
                'stream_events': streamEvents,
                'total_chunks': _streamChunks.length,
                'total_duration_ms': stopwatch.elapsedMilliseconds,
              });
            });

            _updateDebugInfo('✅ 流式响应完成 (${stopwatch.elapsedMilliseconds}ms)\n');
            _updateDebugInfo('总字符数: ${totalContent.length}\n');
            _updateDebugInfo('总块数: ${_streamChunks.length}\n');
            if (usage != null) {
              _updateDebugInfo('Token使用情况:\n');
              _updateDebugInfo('  输入: ${usage.promptTokens}\n');
              _updateDebugInfo('  输出: ${usage.completionTokens}\n');
              _updateDebugInfo('  总计: ${usage.totalTokens}\n');
            }
            break;

          case ChatStreamEvent_Error(:final message):
            stopwatch.stop();
            _updateDebugInfo(
              '❌ 流式响应错误 (${stopwatch.elapsedMilliseconds}ms): $message\n',
            );
            streamEvents.add({
              'event': 'error',
              'data': {
                'message': message,
                'timestamp': DateTime.now().toIso8601String(),
              },
            });
            break;
        }
      }
    } catch (e) {
      stopwatch.stop();
      _updateDebugInfo('❌ 流式请求失败 (${stopwatch.elapsedMilliseconds}ms): $e\n');
      rethrow;
    }
  }

  Future<void> _testStream() async {
    setState(() {
      _isLoading = true;
      _response = '';
      _debugInfo = '';
      _streamChunks.clear();
      _requestBody = '';
      _responseBody = '';
      _rawRequestInfo = '';
    });

    try {
      _updateDebugInfo('🧪 开始测试流式功能...\n');

      // 生成测试请求信息
      setState(() {
        _requestBody = jsonEncode({
          'test_mode': true,
          'stream': true,
          'message': 'Test stream functionality',
        });
        _rawRequestInfo = '''📡 测试请求信息
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
URL: Internal Test Stream
Method: TEST
Provider: Test
''';
      });

      final stream = testStream();
      await for (final event in stream) {
        switch (event) {
          case ChatStreamEvent_Start():
            _updateDebugInfo('🟢 测试开始\n');
            break;

          case ChatStreamEvent_Content(:final content):
            setState(() {
              _streamChunks.add(content);
              _response += content;
            });
            _updateDebugInfo('📝 测试块: $content\n');
            break;

          case ChatStreamEvent_Done(:final totalContent, :final usage):
            setState(() {
              _response = totalContent;
              _lastUsage = usage;
              _responseBody = const JsonEncoder.withIndent('  ').convert({
                'test_mode': true,
                'total_content': totalContent,
                'chunks_count': _streamChunks.length,
                'usage': usage != null
                    ? {
                        'prompt_tokens': usage.promptTokens,
                        'completion_tokens': usage.completionTokens,
                        'total_tokens': usage.totalTokens,
                      }
                    : null,
              });
            });
            _updateDebugInfo('✅ 测试完成\n');
            _updateDebugInfo('完整内容: $totalContent\n');
            if (usage != null) {
              _updateDebugInfo('模拟Token使用: ${usage.totalTokens}\n');
            }
            break;

          case ChatStreamEvent_Error(:final message):
            _updateDebugInfo('❌ 测试错误: $message\n');
            break;
        }
      }
    } catch (e) {
      _updateDebugInfo('❌ 测试失败: $e\n');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
        title: const Text('AI聊天API调试'),
        actions: [
          IconButton(
            icon: const Icon(Icons.science),
            onPressed: _isLoading ? null : _testStream,
            tooltip: '测试流式功能',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              setState(() {
                _response = '';
                _debugInfo = '';
                _requestBody = '';
                _responseBody = '';
                _rawRequestInfo = '';
                _streamChunks.clear();
                _lastUsage = null;
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
            flex: 2,
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

          // 结果面板
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // 结果标签栏
                Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const TabBar(
                    tabs: [
                      Tab(text: '响应内容'),
                      Tab(text: '请求体'),
                      Tab(text: '响应体'),
                      Tab(text: '调试信息'),
                      Tab(text: 'Token统计'),
                    ],
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    children: [
                      _buildResponseTab(),
                      _buildRequestTab(),
                      _buildResponseBodyTab(),
                      _buildDebugTab(),
                      _buildUsageTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
              '快速配置 (支持OpenAI兼容接口)',
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
              value: _selectedProvider.when(
                openAi: () => 'openai',
                anthropic: () => 'anthropic',
                cohere: () => 'cohere',
                gemini: () => 'gemini',
                groq: () => 'groq',
                ollama: () => 'ollama',
                xai: () => 'xai',
                deepSeek: () => 'deepseek',
                custom: (name) => 'custom',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'openai',
                  child: Text('OpenAI (及兼容接口)'),
                ),
                DropdownMenuItem(value: 'anthropic', child: Text('Anthropic')),
                DropdownMenuItem(value: 'cohere', child: Text('Cohere')),
                DropdownMenuItem(value: 'gemini', child: Text('Google Gemini')),
                DropdownMenuItem(value: 'groq', child: Text('Groq')),
                DropdownMenuItem(value: 'ollama', child: Text('Ollama')),
                DropdownMenuItem(value: 'xai', child: Text('XAI')),
                DropdownMenuItem(value: 'deepseek', child: Text('DeepSeek')),
                DropdownMenuItem(value: 'custom', child: Text('自定义')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    switch (value) {
                      case 'openai':
                        _selectedProvider = const AiProvider.openAi();
                        break;
                      case 'anthropic':
                        _selectedProvider = const AiProvider.anthropic();
                        break;
                      case 'cohere':
                        _selectedProvider = const AiProvider.cohere();
                        break;
                      case 'gemini':
                        _selectedProvider = const AiProvider.gemini();
                        break;
                      case 'groq':
                        _selectedProvider = const AiProvider.groq();
                        break;
                      case 'ollama':
                        _selectedProvider = const AiProvider.ollama();
                        break;
                      case 'xai':
                        _selectedProvider = const AiProvider.xai();
                        break;
                      case 'deepseek':
                        _selectedProvider = const AiProvider.deepSeek();
                        break;
                      case 'custom':
                        _selectedProvider = const AiProvider.custom(
                          name: 'custom',
                        );
                        break;
                    }
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
                helperText: '支持OpenAI、DeepSeek、Moonshot、GLM等',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _baseUrlController,
              decoration: const InputDecoration(
                labelText: 'API端点 (可自定义)',
                hintText: 'https://api.example.com/v1',
                border: OutlineInputBorder(),
                helperText: '留空使用默认端点，支持OpenAI兼容接口，自动确保URL结尾斜杠',
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: '模型名称 (可自定义)',
                hintText: 'gpt-4, deepseek-chat, moonshot-v1-8k',
                border: OutlineInputBorder(),
                helperText: '可输入任何兼容模型名称',
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
            const SizedBox(height: 8),
            TextFormField(
              controller: _stopSequencesController,
              decoration: const InputDecoration(
                labelText: '停止序列 (可选)',
                hintText: '用逗号分隔，如: END,```',
                border: OutlineInputBorder(),
                helperText: '多个停止序列用逗号分隔',
              ),
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

  Widget _buildRequestTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '请求信息',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_requestBody.isNotEmpty || _rawRequestInfo.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () =>
                      _copyToClipboard('$_rawRequestInfo\n请求体:\n$_requestBody'),
                  tooltip: '复制请求信息',
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
                  _requestBody.isEmpty && _rawRequestInfo.isEmpty
                      ? '点击发送消息后将显示请求详情...'
                      : '$_rawRequestInfo\n请求体:\n$_requestBody',
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

  Widget _buildUsageTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Token使用统计',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_lastUsage != null) ...[
            _buildUsageCard('输入Token', _lastUsage!.promptTokens, Icons.input),
            const SizedBox(height: 8),
            _buildUsageCard(
              '输出Token',
              _lastUsage!.completionTokens,
              Icons.output,
            ),
            const SizedBox(height: 8),
            _buildUsageCard('总Token', _lastUsage!.totalTokens, Icons.calculate),
            const SizedBox(height: 16),
            if (_isStreamMode && _streamChunks.isNotEmpty) ...[
              const Text(
                '流式统计',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildUsageCard('总块数', _streamChunks.length, Icons.view_stream),
              const SizedBox(height: 8),
              _buildUsageCard(
                '平均块大小',
                _streamChunks.isEmpty
                    ? 0
                    : (_response.length / _streamChunks.length).round(),
                Icons.assessment,
              ),
            ],
          ] else ...[
            const Center(
              child: Text(
                '暂无Token使用数据\n发送消息后此处将显示详细统计',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUsageCard(String label, int? value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    value?.toString() ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TabBarView 需要 DefaultTabController
class AiDebugScreenWrapper extends StatelessWidget {
  const AiDebugScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(length: 5, child: AiDebugScreen());
  }
}
