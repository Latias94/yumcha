import 'dart:convert';

/// Role of a participant in a chat conversation.
enum ChatRole {
  /// The user/human participant in the conversation
  user,

  /// The AI assistant participant in the conversation
  assistant,

  /// System message for setting context
  system,
}

/// The supported MIME type of an image.
enum ImageMime {
  /// JPEG image
  jpeg,

  /// PNG image
  png,

  /// GIF image
  gif,

  /// WebP image
  webp,
}

extension ImageMimeExtension on ImageMime {
  String get mimeType {
    switch (this) {
      case ImageMime.jpeg:
        return 'image/jpeg';
      case ImageMime.png:
        return 'image/png';
      case ImageMime.gif:
        return 'image/gif';
      case ImageMime.webp:
        return 'image/webp';
    }
  }
}

/// Represents an AI model with its metadata
class AIModel {
  /// The unique identifier of the model
  final String id;

  /// Human-readable description of the model
  final String? description;

  /// The object type (typically "model")
  final String object;

  /// The organization that owns the model
  final String? ownedBy;

  const AIModel({
    required this.id,
    this.description,
    this.object = 'model',
    this.ownedBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        if (description != null) 'description': description,
        'object': object,
        if (ownedBy != null) 'owned_by': ownedBy,
      };

  factory AIModel.fromJson(Map<String, dynamic> json) => AIModel(
        id: json['id'] as String,
        description: json['description'] as String?,
        object: json['object'] as String? ?? 'model',
        ownedBy: json['owned_by'] as String?,
      );

  @override
  String toString() =>
      'AIModel(id: $id, description: $description, ownedBy: $ownedBy)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Tool call represents a function call that an LLM wants to make.
class ToolCall {
  /// The ID of the tool call.
  final String id;

  /// The type of the tool call (usually "function").
  final String callType;

  /// The function to call.
  final FunctionCall function;

  const ToolCall({
    required this.id,
    required this.callType,
    required this.function,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': callType,
        'function': function.toJson(),
      };

  factory ToolCall.fromJson(Map<String, dynamic> json) => ToolCall(
        id: json['id'] as String,
        callType: json['type'] as String,
        function:
            FunctionCall.fromJson(json['function'] as Map<String, dynamic>),
      );

  @override
  String toString() => jsonEncode(toJson());
}

/// FunctionCall contains details about which function to call and with what arguments.
class FunctionCall {
  /// The name of the function to call.
  final String name;

  /// The arguments to pass to the function, typically serialized as a JSON string.
  final String arguments;

  const FunctionCall({required this.name, required this.arguments});

  Map<String, dynamic> toJson() => {'name': name, 'arguments': arguments};

  factory FunctionCall.fromJson(Map<String, dynamic> json) => FunctionCall(
        name: json['name'] as String,
        arguments: json['arguments'] as String,
      );

  @override
  String toString() => jsonEncode(toJson());
}

/// The type of a message in a chat conversation.
sealed class MessageType {
  const MessageType();
}

/// A text message
class TextMessage extends MessageType {
  const TextMessage();
}

/// An image message
class ImageMessage extends MessageType {
  final ImageMime mime;
  final List<int> data;

  const ImageMessage(this.mime, this.data);
}

/// PDF message
class PdfMessage extends MessageType {
  final List<int> data;

  const PdfMessage(this.data);
}

/// An image URL message
class ImageUrlMessage extends MessageType {
  final String url;

  const ImageUrlMessage(this.url);
}

/// A tool use message
class ToolUseMessage extends MessageType {
  final List<ToolCall> toolCalls;

  const ToolUseMessage(this.toolCalls);
}

/// Tool result message
class ToolResultMessage extends MessageType {
  final List<ToolCall> results;

  const ToolResultMessage(this.results);
}

/// A single message in a chat conversation.
class ChatMessage {
  /// The role of who sent this message (user or assistant)
  final ChatRole role;

  /// The type of the message (text, image, audio, video, etc)
  final MessageType messageType;

  /// The text content of the message
  final String content;

  const ChatMessage({
    required this.role,
    required this.messageType,
    required this.content,
  });

  /// Create a user message
  factory ChatMessage.user(String content) => ChatMessage(
        role: ChatRole.user,
        messageType: const TextMessage(),
        content: content,
      );

  /// Create an assistant message
  factory ChatMessage.assistant(String content) => ChatMessage(
        role: ChatRole.assistant,
        messageType: const TextMessage(),
        content: content,
      );

  /// Create a system message
  factory ChatMessage.system(String content) => ChatMessage(
        role: ChatRole.system,
        messageType: const TextMessage(),
        content: content,
      );

  /// Create an image message
  factory ChatMessage.image({
    required ChatRole role,
    required ImageMime mime,
    required List<int> data,
    String content = '',
  }) =>
      ChatMessage(
        role: role,
        messageType: ImageMessage(mime, data),
        content: content,
      );

  /// Create an image URL message
  factory ChatMessage.imageUrl({
    required ChatRole role,
    required String url,
    String content = '',
  }) =>
      ChatMessage(
        role: role,
        messageType: ImageUrlMessage(url),
        content: content,
      );

  /// Create a tool use message
  factory ChatMessage.toolUse({
    required List<ToolCall> toolCalls,
    String content = '',
  }) =>
      ChatMessage(
        role: ChatRole.assistant,
        messageType: ToolUseMessage(toolCalls),
        content: content,
      );

  /// Create a tool result message
  factory ChatMessage.toolResult({
    required List<ToolCall> results,
    String content = '',
  }) =>
      ChatMessage(
        role: ChatRole.user,
        messageType: ToolResultMessage(results),
        content: content,
      );
}

/// Reasoning effort levels for models that support reasoning
enum ReasoningEffort {
  low,
  medium,
  high;

  /// Convert to string value for API requests
  String get value {
    switch (this) {
      case ReasoningEffort.low:
        return 'low';
      case ReasoningEffort.medium:
        return 'medium';
      case ReasoningEffort.high:
        return 'high';
    }
  }

  /// Create from string value
  static ReasoningEffort? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'low':
        return ReasoningEffort.low;
      case 'medium':
        return ReasoningEffort.medium;
      case 'high':
        return ReasoningEffort.high;
      default:
        return null;
    }
  }
}
