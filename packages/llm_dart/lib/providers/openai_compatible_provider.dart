import '../core/config.dart';
import '../core/chat_provider.dart';
import '../core/base_http_provider.dart';
import '../utils/config_utils.dart';
import '../models/chat_models.dart';
import '../models/tool_models.dart';
import 'openai_provider.dart';

/// OpenAI-compatible provider that supports provider-specific transformers
///
/// This provider wraps the standard OpenAI provider to support
/// provider-specific request body and headers transformations,
/// enabling proper support for providers like Google Gemini that
/// have specific requirements when using OpenAI-compatible interfaces.
class OpenAICompatibleProvider extends BaseHttpProvider {
  /// The underlying OpenAI provider
  final OpenAIProvider _openaiProvider;

  /// The provider configuration containing transformers
  final OpenAICompatibleProviderConfig providerConfig;

  /// The original LLM configuration for transformer access
  final LLMConfig originalConfig;

  OpenAICompatibleProvider(
    OpenAIConfig config,
    this.providerConfig,
    this.originalConfig,
  )   : _openaiProvider = OpenAIProvider(config),
        super(
          BaseHttpProvider.createDio(
            baseUrl: config.baseUrl,
            headers: _buildTransformedHeaders(
                config, providerConfig, originalConfig),
            timeout: config.timeout,
          ),
          'OpenAICompatibleProvider',
        );

  /// Build headers with transformations applied
  static Map<String, String> _buildTransformedHeaders(
    OpenAIConfig config,
    OpenAICompatibleProviderConfig providerConfig,
    LLMConfig originalConfig,
  ) {
    // Start with standard OpenAI headers
    final baseHeaders = ConfigUtils.buildOpenAIHeaders(config.apiKey);

    // Apply provider-specific header transformations if available
    if (providerConfig.headersTransformer != null) {
      return providerConfig.headersTransformer!.transform(
        baseHeaders,
        originalConfig,
        providerConfig,
      );
    }

    return baseHeaders;
  }

  @override
  String get providerName =>
      'OpenAI-Compatible (${providerConfig.displayName})';

  @override
  String get chatEndpoint => _openaiProvider.chatEndpoint;

  @override
  Map<String, dynamic> buildRequestBody(
    List<ChatMessage> messages,
    List<Tool>? tools,
    bool stream,
  ) {
    // Build the standard OpenAI request body
    final body = _openaiProvider.buildRequestBody(messages, tools, stream);

    // Apply provider-specific transformations if available
    final transformedBody = providerConfig.requestBodyTransformer != null
        ? providerConfig.requestBodyTransformer!.transform(
            body,
            originalConfig,
            providerConfig,
          )
        : body;

    // Handle extra_body parameters (for OpenAI-compatible interfaces)
    // This merges provider-specific parameters from extra_body into the main request body
    final extraBody = transformedBody['extra_body'] as Map<String, dynamic>?;
    if (extraBody != null) {
      // Merge extra_body contents into the main body
      transformedBody.addAll(extraBody);
      // Remove the extra_body field itself as it should not be sent to the API
      transformedBody.remove('extra_body');
    }

    return transformedBody;
  }

  @override
  ChatResponse parseResponse(Map<String, dynamic> responseData) {
    return _openaiProvider.parseResponse(responseData);
  }

  @override
  List<ChatStreamEvent> parseStreamEvents(String chunk) {
    return _openaiProvider.parseStreamEvents(chunk);
  }

  // Override ChatCapability methods to use our own request building
  @override
  Future<ChatResponse> chat(List<ChatMessage> messages) {
    return chatWithTools(messages, null);
  }

  @override
  Stream<ChatStreamEvent> chatStream(
    List<ChatMessage> messages, {
    List<Tool>? tools,
  }) {
    // Use the BaseHttpProvider's chatStream which will call our buildRequestBody
    return super.chatStream(messages, tools: tools);
  }

  @override
  Future<ChatResponse> chatWithTools(
    List<ChatMessage> messages,
    List<Tool>? tools,
  ) {
    // Use the BaseHttpProvider's chatWithTools which will call our buildRequestBody
    return super.chatWithTools(messages, tools);
  }

  @override
  Future<List<ChatMessage>?> memoryContents() {
    return _openaiProvider.memoryContents();
  }

  @override
  Future<String> summarizeHistory(List<ChatMessage> messages) {
    return _openaiProvider.summarizeHistory(messages);
  }

  /// Get the provider ID for this compatible provider
  String get compatibleProviderId => providerConfig.providerId;

  /// Check if this provider supports a specific capability
  bool supportsCapability(LLMCapability capability) {
    return providerConfig.supportedCapabilities.contains(capability);
  }

  /// Get model-specific configuration if available
  ModelCapabilityConfig? getModelConfig(String model) {
    return providerConfig.modelConfigs[model];
  }
}
