import '../core/chat_provider.dart';
import '../core/llm_error.dart';
import '../providers/openai_provider.dart';
import '../providers/anthropic_provider.dart';
import '../providers/google_provider.dart';
import '../providers/deepseek_provider.dart';
import '../providers/ollama_provider.dart';
import '../providers/xai_provider.dart';
import '../providers/phind_provider.dart';
import '../providers/groq_provider.dart';
import '../providers/elevenlabs_provider.dart';
import '../models/tool_models.dart';

/// Supported LLM backend providers
enum LLMBackend {
  /// OpenAI API provider (GPT-3, GPT-4, etc.)
  openai,

  /// Anthropic API provider (Claude models)
  anthropic,

  /// Ollama local LLM provider for self-hosted models
  ollama,

  /// DeepSeek API provider for their LLM models
  deepseek,

  /// X.AI (formerly Twitter) API provider
  xai,

  /// Phind API provider for code-specialized models
  phind,

  /// Google Gemini API provider
  google,

  /// Groq API provider
  groq,

  /// ElevenLabs API provider
  elevenlabs,
}

/// Builder for configuring and instantiating LLM providers
///
/// Provides a fluent interface similar to the Rust llm crate for setting
/// various configuration options like model selection, API keys, generation parameters, etc.
class LLMBuilder {
  /// Selected backend provider
  LLMBackend? _backend;

  /// API key for authentication with the provider
  String? _apiKey;

  /// Base URL for API requests (primarily for self-hosted instances)
  String? _baseUrl;

  /// Model identifier/name to use
  String? _model;

  /// Maximum tokens to generate in responses
  int? _maxTokens;

  /// Temperature parameter for controlling response randomness (0.0-1.0)
  double? _temperature;

  /// System prompt/context to guide model behavior
  String? _systemPrompt;

  /// Request timeout duration
  Duration? _timeout;

  /// Whether to enable streaming responses
  bool? _stream;

  /// Top-p (nucleus) sampling parameter
  double? _topP;

  /// Top-k sampling parameter
  int? _topK;

  /// Function tools
  List<Tool>? _tools;

  /// Tool choice
  ToolChoice? _toolChoice;

  /// Reasoning effort level
  String? _reasoningEffort;

  /// JSON schema for structured output
  StructuredOutputFormat? _jsonSchema;

  /// Voice for TTS
  String? _voice;

  /// Embedding encoding format
  String? _embeddingEncodingFormat;

  /// Embedding dimensions
  int? _embeddingDimensions;

  /// Search parameters for providers that support search functionality
  SearchParameters? _searchParameters;

  /// Creates a new empty builder instance with default values
  LLMBuilder();

  /// Sets the backend provider to use
  LLMBuilder backend(LLMBackend backend) {
    _backend = backend;
    return this;
  }

  /// Sets the API key for authentication
  LLMBuilder apiKey(String key) {
    _apiKey = key;
    return this;
  }

  /// Sets the base URL for API requests
  LLMBuilder baseUrl(String url) {
    // Ensure the URL ends with a slash
    _baseUrl = url.endsWith('/') ? url : '$url/';
    return this;
  }

  /// Sets the model identifier to use
  LLMBuilder model(String model) {
    _model = model;
    return this;
  }

  /// Sets the maximum number of tokens to generate
  LLMBuilder maxTokens(int tokens) {
    _maxTokens = tokens;
    return this;
  }

  /// Sets the temperature for controlling response randomness (0.0-1.0)
  LLMBuilder temperature(double temp) {
    _temperature = temp;
    return this;
  }

  /// Sets the system prompt/context
  LLMBuilder systemPrompt(String prompt) {
    _systemPrompt = prompt;
    return this;
  }

  /// Sets the request timeout
  LLMBuilder timeout(Duration timeout) {
    _timeout = timeout;
    return this;
  }

  /// Enables or disables streaming responses
  LLMBuilder stream(bool enable) {
    _stream = enable;
    return this;
  }

  /// Sets the top-p (nucleus) sampling parameter
  LLMBuilder topP(double topP) {
    _topP = topP;
    return this;
  }

  /// Sets the top-k sampling parameter
  LLMBuilder topK(int topK) {
    _topK = topK;
    return this;
  }

  /// Sets the function tools
  LLMBuilder tools(List<Tool> tools) {
    _tools = tools;
    return this;
  }

  /// Sets the tool choice
  LLMBuilder toolChoice(ToolChoice choice) {
    _toolChoice = choice;
    return this;
  }

  /// Sets the reasoning effort level
  LLMBuilder reasoningEffort(String effort) {
    _reasoningEffort = effort;
    return this;
  }

  /// Sets the JSON schema for structured output
  LLMBuilder jsonSchema(StructuredOutputFormat schema) {
    _jsonSchema = schema;
    return this;
  }

  /// Sets the voice for TTS
  LLMBuilder voice(String voice) {
    _voice = voice;
    return this;
  }

  /// Sets the encoding format for embeddings
  LLMBuilder embeddingEncodingFormat(String format) {
    _embeddingEncodingFormat = format;
    return this;
  }

  /// Sets the dimensions for embeddings
  LLMBuilder embeddingDimensions(int dimensions) {
    _embeddingDimensions = dimensions;
    return this;
  }

  /// Sets the search parameters for providers that support search functionality
  LLMBuilder searchParameters(SearchParameters parameters) {
    _searchParameters = parameters;
    return this;
  }

  /// Builds and returns a configured LLM provider instance
  ///
  /// Returns a unified ChatProvider interface that can be used consistently
  /// regardless of the underlying backend provider.
  ///
  /// Throws [LLMError] if:
  /// - No backend is specified
  /// - Required configuration like API keys are missing
  Future<ChatProvider> build() async {
    if (_backend == null) {
      throw const GenericError('No backend specified');
    }

    switch (_backend!) {
      case LLMBackend.openai:
        if (_apiKey == null) {
          throw const AuthError('No API key provided for OpenAI');
        }
        return OpenAIProvider(
          OpenAIConfig(
            apiKey: _apiKey!,
            baseUrl: _baseUrl ?? 'https://api.openai.com/v1/',
            model: _model ?? 'gpt-3.5-turbo',
            maxTokens: _maxTokens,
            temperature: _temperature,
            systemPrompt: _systemPrompt,
            timeout: _timeout,
            stream: _stream ?? false,
            topP: _topP,
            topK: _topK,
            tools: _tools,
            toolChoice: _toolChoice,
            reasoningEffort: _reasoningEffort,
            jsonSchema: _jsonSchema,
            voice: _voice,
            embeddingEncodingFormat: _embeddingEncodingFormat,
            embeddingDimensions: _embeddingDimensions,
          ),
        );

      case LLMBackend.anthropic:
        if (_apiKey == null) {
          throw const AuthError('No API key provided for Anthropic');
        }
        return AnthropicProvider(
          AnthropicConfig(
            apiKey: _apiKey!,
            baseUrl: _baseUrl ?? 'https://api.anthropic.com/v1/',
            model: _model ?? 'claude-3-5-sonnet-20241022',
            maxTokens: _maxTokens,
            temperature: _temperature,
            systemPrompt: _systemPrompt,
            timeout: _timeout,
            stream: _stream ?? false,
            topP: _topP,
            topK: _topK,
            tools: _tools,
            toolChoice: _toolChoice,
            reasoning: _reasoningEffort != null,
            thinkingBudgetTokens: _reasoningEffort != null ? 16000 : null,
          ),
        );

      case LLMBackend.deepseek:
        if (_apiKey == null) {
          throw const AuthError('No API key provided for DeepSeek');
        }
        return DeepSeekProvider(
          DeepSeekConfig(
            apiKey: _apiKey!,
            baseUrl: _baseUrl ?? 'https://api.deepseek.com/v1/',
            model: _model ?? 'deepseek-chat',
            maxTokens: _maxTokens,
            temperature: _temperature,
            systemPrompt: _systemPrompt,
            timeout: _timeout,
            stream: _stream ?? false,
            topP: _topP,
            topK: _topK,
            tools: _tools,
            toolChoice: _toolChoice,
          ),
        );

      case LLMBackend.google:
        if (_apiKey == null) {
          throw const AuthError('No API key provided for Google');
        }
        return GoogleProvider(
          GoogleConfig(
            apiKey: _apiKey!,
            baseUrl:
                _baseUrl ?? 'https://generativelanguage.googleapis.com/v1beta/',
            model: _model ?? 'gemini-1.5-flash',
            maxTokens: _maxTokens,
            temperature: _temperature,
            systemPrompt: _systemPrompt,
            timeout: _timeout,
            stream: _stream ?? false,
            topP: _topP,
            topK: _topK,
            tools: _tools,
            jsonSchema: _jsonSchema,
          ),
        );

      case LLMBackend.ollama:
        return OllamaProvider(
          OllamaConfig(
            baseUrl: _baseUrl ?? 'http://localhost:11434',
            apiKey: _apiKey,
            model: _model ?? 'llama3.1',
            maxTokens: _maxTokens,
            temperature: _temperature,
            systemPrompt: _systemPrompt,
            timeout: _timeout,
            stream: _stream ?? false,
            topP: _topP,
            topK: _topK,
            tools: _tools,
            jsonSchema: _jsonSchema,
          ),
        );

      case LLMBackend.xai:
        if (_apiKey == null) {
          throw const AuthError('No API key provided for XAI');
        }
        return XAIProvider(
          XAIConfig(
            apiKey: _apiKey!,
            baseUrl: _baseUrl ?? 'https://api.x.ai/v1/',
            model: _model ?? 'grok-2-latest',
            maxTokens: _maxTokens,
            temperature: _temperature,
            systemPrompt: _systemPrompt,
            timeout: _timeout,
            stream: _stream ?? false,
            topP: _topP,
            topK: _topK,
            tools: _tools,
            toolChoice: _toolChoice,
            jsonSchema: _jsonSchema,
            embeddingEncodingFormat: _embeddingEncodingFormat,
            embeddingDimensions: _embeddingDimensions,
            searchParameters: _searchParameters,
          ),
        );

      case LLMBackend.phind:
        return PhindProvider(
          PhindConfig(
            apiKey: _apiKey ?? '',
            baseUrl: _baseUrl ?? 'https://https.extension.phind.com',
            model: _model ?? 'Phind-70B',
            maxTokens: _maxTokens,
            temperature: _temperature,
            systemPrompt: _systemPrompt,
            timeout: _timeout,
            stream: _stream ?? false,
            topP: _topP,
            topK: _topK,
            tools: _tools,
            toolChoice: _toolChoice,
          ),
        );

      case LLMBackend.groq:
        if (_apiKey == null) {
          throw const AuthError('No API key provided for Groq');
        }
        return GroqProvider(
          GroqConfig(
            apiKey: _apiKey!,
            baseUrl: _baseUrl ?? 'https://api.groq.com/openai/v1',
            model: _model ?? 'llama3-8b-8192',
            maxTokens: _maxTokens,
            temperature: _temperature,
            systemPrompt: _systemPrompt,
            timeout: _timeout,
            stream: _stream ?? false,
            topP: _topP,
            topK: _topK,
            tools: _tools,
            toolChoice: _toolChoice,
          ),
        );

      case LLMBackend.elevenlabs:
        if (_apiKey == null) {
          throw const AuthError('No API key provided for ElevenLabs');
        }
        return ElevenLabsProvider(
          ElevenLabsConfig(
            apiKey: _apiKey!,
            baseUrl: _baseUrl ?? 'https://api.elevenlabs.io/v1',
            model: _model ?? 'eleven_multilingual_v2',
            timeout: _timeout,
            voiceId: _voice,
          ),
        );
    }
  }
}
