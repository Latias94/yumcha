import '../models/chat_models.dart';
import '../models/tool_models.dart';
import 'llm_error.dart';

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
}

/// Trait for providers that support chat-style interactions.
abstract class ChatProvider {
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

/// Trait for providers that support streaming chat interactions
abstract class StreamingChatProvider extends ChatProvider {
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

/// Trait for providers that support text completion
abstract class CompletionProvider {
  /// Sends a completion request to generate text
  ///
  /// [request] - The completion request parameters
  ///
  /// Returns the generated completion text or throws an LLMError
  Future<CompletionResponse> complete(CompletionRequest request);
}

/// Trait for providers that support vector embeddings
abstract class EmbeddingProvider {
  /// Generate embeddings for the given input texts
  ///
  /// [input] - List of strings to generate embeddings for
  ///
  /// Returns a list of embedding vectors or throws an LLMError
  Future<List<List<double>>> embed(List<String> input);
}

/// Trait for providers that support speech-to-text conversion
abstract class SpeechToTextProvider {
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

/// Trait for providers that support text-to-speech conversion
abstract class TextToSpeechProvider {
  /// Convert text to speech audio
  ///
  /// [text] - Text to convert to speech
  ///
  /// Returns audio data as bytes or throws an LLMError
  Future<List<int>> speech(String text);
}

/// Core trait that all LLM providers should implement
/// Combines chat, completion, embedding, and speech capabilities
abstract class LLMProvider
    implements
        ChatProvider,
        CompletionProvider,
        EmbeddingProvider,
        SpeechToTextProvider,
        TextToSpeechProvider {
  /// Get available tools for this provider
  List<Tool>? get tools => null;
}
