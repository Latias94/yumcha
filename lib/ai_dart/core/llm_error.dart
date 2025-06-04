/// Error types that can occur when interacting with LLM providers.
/// Based on the Rust llm library error handling.
abstract class LLMError implements Exception {
  final String message;
  
  const LLMError(this.message);
  
  @override
  String toString() => message;
}

/// HTTP request/response errors
class HttpError extends LLMError {
  const HttpError(super.message);
  
  @override
  String toString() => 'HTTP Error: $message';
}

/// Authentication and authorization errors
class AuthError extends LLMError {
  const AuthError(super.message);
  
  @override
  String toString() => 'Auth Error: $message';
}

/// Invalid request parameters or format
class InvalidRequestError extends LLMError {
  const InvalidRequestError(super.message);
  
  @override
  String toString() => 'Invalid Request: $message';
}

/// Errors returned by the LLM provider
class ProviderError extends LLMError {
  const ProviderError(super.message);
  
  @override
  String toString() => 'Provider Error: $message';
}

/// API response parsing or format error
class ResponseFormatError extends LLMError {
  final String rawResponse;
  
  const ResponseFormatError(super.message, this.rawResponse);
  
  @override
  String toString() => 'Response Format Error: $message. Raw response: $rawResponse';
}

/// Generic error
class GenericError extends LLMError {
  const GenericError(super.message);
  
  @override
  String toString() => 'Generic Error: $message';
}

/// JSON serialization/deserialization errors
class JsonError extends LLMError {
  const JsonError(super.message);
  
  @override
  String toString() => 'JSON Parse Error: $message';
}

/// Tool configuration error
class ToolConfigError extends LLMError {
  const ToolConfigError(super.message);
  
  @override
  String toString() => 'Tool Configuration Error: $message';
}
