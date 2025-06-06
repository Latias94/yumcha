import '../models/chat_models.dart';
import '../models/tool_models.dart';
import 'llm_error.dart';

/// Enumeration of LLM capabilities that providers can support
enum LLMCapability {
  /// Basic chat functionality
  chat,

  /// Streaming chat responses
  streaming,

  /// Vector embeddings generation
  embedding,

  /// Text-to-speech conversion
  textToSpeech,

  /// Speech-to-text conversion
  speechToText,

  /// Model listing
  modelListing,

  /// Function/tool calling
  toolCalling,

  /// Reasoning/thinking capabilities
  reasoning,

  /// Text completion (non-chat)
  completion,
}

/// Response from a chat provider
abstract class ChatResponse {
  /// Get the text content of the response
  String? get text;

  /// Get tool calls from the response
  List<ToolCall>? get toolCalls;

  /// Get thinking/reasoning content (for providers that support it)
  String? get thinking => null;

  /// Get usage information if available
  UsageInfo? get usage => null;
}

/// Usage information for API calls
class UsageInfo {
  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;

  const UsageInfo({this.promptTokens, this.completionTokens, this.totalTokens});

  /// Adds two UsageInfo instances together for token usage accumulation
  UsageInfo operator +(UsageInfo other) {
    return UsageInfo(
      promptTokens: (promptTokens ?? 0) + (other.promptTokens ?? 0),
      completionTokens: (completionTokens ?? 0) + (other.completionTokens ?? 0),
      totalTokens: (totalTokens ?? 0) + (other.totalTokens ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {
        if (promptTokens != null) 'prompt_tokens': promptTokens,
        if (completionTokens != null) 'completion_tokens': completionTokens,
        if (totalTokens != null) 'total_tokens': totalTokens,
      };

  factory UsageInfo.fromJson(Map<String, dynamic> json) => UsageInfo(
        promptTokens: json['prompt_tokens'] as int?,
        completionTokens: json['completion_tokens'] as int?,
        totalTokens: json['total_tokens'] as int?,
      );

  @override
  String toString() =>
      'UsageInfo(prompt: $promptTokens, completion: $completionTokens, total: $totalTokens)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsageInfo &&
          runtimeType == other.runtimeType &&
          promptTokens == other.promptTokens &&
          completionTokens == other.completionTokens &&
          totalTokens == other.totalTokens;

  @override
  int get hashCode => Object.hash(promptTokens, completionTokens, totalTokens);
}

/// Core chat capability interface that most LLM providers implement
abstract class ChatCapability {
  /// Sends a chat request to the provider with a sequence of messages.
  ///
  /// [messages] - The conversation history as a list of chat messages
  ///
  /// Returns the provider's response or throws an LLMError
  Future<ChatResponse> chat(List<ChatMessage> messages) async {
    return chatWithTools(messages, null);
  }

  /// Sends a chat request to the provider with a sequence of messages and tools.
  ///
  /// [messages] - The conversation history as a list of chat messages
  /// [tools] - Optional list of tools to use in the chat
  ///
  /// Returns the provider's response or throws an LLMError
  Future<ChatResponse> chatWithTools(
    List<ChatMessage> messages,
    List<Tool>? tools,
  );

  /// Sends a streaming chat request to the provider
  ///
  /// [messages] - The conversation history as a list of chat messages
  /// [tools] - Optional list of tools to use in the chat
  ///
  /// Returns a stream of chat events
  Stream<ChatStreamEvent> chatStream(
    List<ChatMessage> messages, {
    List<Tool>? tools,
  });

  /// Get current memory contents if provider supports memory
  Future<List<ChatMessage>?> memoryContents() async => null;

  /// Summarizes a conversation history into a concise 2-3 sentence summary
  ///
  /// [messages] - The conversation messages to summarize
  ///
  /// Returns a string containing the summary or throws an LLMError
  Future<String> summarizeHistory(List<ChatMessage> messages) async {
    final prompt =
        'Summarize in 2-3 sentences:\n${messages.map((m) => '${m.role.name}: ${m.content}').join('\n')}';
    final request = [ChatMessage.user(prompt)];
    final response = await chat(request);
    final text = response.text;
    if (text == null) {
      throw const GenericError('no text in summary response');
    }
    return text;
  }
}

/// Stream event for streaming chat responses
sealed class ChatStreamEvent {
  const ChatStreamEvent();
}

/// Text delta event
class TextDeltaEvent extends ChatStreamEvent {
  final String delta;

  const TextDeltaEvent(this.delta);
}

/// Tool call delta event
class ToolCallDeltaEvent extends ChatStreamEvent {
  final ToolCall toolCall;

  const ToolCallDeltaEvent(this.toolCall);
}

/// Completion event
class CompletionEvent extends ChatStreamEvent {
  final ChatResponse response;

  const CompletionEvent(this.response);
}

/// Thinking/reasoning delta event for reasoning models
class ThinkingDeltaEvent extends ChatStreamEvent {
  final String delta;

  const ThinkingDeltaEvent(this.delta);
}

/// Error event
class ErrorEvent extends ChatStreamEvent {
  final LLMError error;

  const ErrorEvent(this.error);
}

/// Completion request for text completion providers
class CompletionRequest {
  final String prompt;
  final int? maxTokens;
  final double? temperature;
  final double? topP;
  final int? topK;
  final List<String>? stop;

  const CompletionRequest({
    required this.prompt,
    this.maxTokens,
    this.temperature,
    this.topP,
    this.topK,
    this.stop,
  });

  Map<String, dynamic> toJson() => {
        'prompt': prompt,
        if (maxTokens != null) 'max_tokens': maxTokens,
        if (temperature != null) 'temperature': temperature,
        if (topP != null) 'top_p': topP,
        if (topK != null) 'top_k': topK,
        if (stop != null) 'stop': stop,
      };
}

/// Completion response from text completion providers
class CompletionResponse {
  final String text;
  final UsageInfo? usage;

  const CompletionResponse({required this.text, this.usage});

  @override
  String toString() => text;
}

/// Capability interface for vector embeddings
abstract class EmbeddingCapability {
  /// Generate embeddings for the given input texts
  ///
  /// [input] - List of strings to generate embeddings for
  ///
  /// Returns a list of embedding vectors or throws an LLMError
  Future<List<List<double>>> embed(List<String> input);
}

/// Capability interface for speech-to-text conversion
abstract class SpeechToTextCapability {
  /// Transcribe audio data to text
  ///
  /// [audio] - Raw audio data as bytes
  ///
  /// Returns transcribed text or throws an LLMError
  Future<String> transcribe(List<int> audio);

  /// Transcribe audio file to text
  ///
  /// [filePath] - Path to the audio file
  ///
  /// Returns transcribed text or throws an LLMError
  Future<String> transcribeFile(String filePath);
}

/// Capability interface for text-to-speech conversion
abstract class TextToSpeechCapability {
  /// Convert text to speech audio
  ///
  /// [text] - Text to convert to speech
  ///
  /// Returns audio data as bytes or throws an LLMError
  Future<List<int>> speech(String text);
}

/// Capability interface for model listing
abstract class ModelListingCapability {
  /// Get available models from the provider
  ///
  /// Returns a list of available models or throws an LLMError
  Future<List<AIModel>> models();
}

/// Capability interface for text completion (non-chat)
abstract class CompletionCapability {
  /// Sends a completion request to generate text
  ///
  /// [request] - The completion request parameters
  ///
  /// Returns the generated completion text or throws an LLMError
  Future<CompletionResponse> complete(CompletionRequest request);
}

/// Provider capability declaration interface
abstract class ProviderCapabilities {
  /// Set of capabilities this provider supports
  Set<LLMCapability> get supportedCapabilities;

  /// Check if this provider supports a specific capability
  bool supports(LLMCapability capability) =>
      supportedCapabilities.contains(capability);
}

/// Basic LLM provider with just chat capability
abstract class BasicLLMProvider
    implements ChatCapability, ProviderCapabilities {}

/// LLM provider with chat and embedding capabilities
abstract class EmbeddingLLMProvider
    implements ChatCapability, EmbeddingCapability, ProviderCapabilities {}

/// LLM provider with voice capabilities
abstract class VoiceLLMProvider
    implements
        ChatCapability,
        TextToSpeechCapability,
        SpeechToTextCapability,
        ProviderCapabilities {}

/// Full-featured LLM provider with all common capabilities
abstract class FullLLMProvider
    implements
        ChatCapability,
        EmbeddingCapability,
        ModelListingCapability,
        ProviderCapabilities {}
