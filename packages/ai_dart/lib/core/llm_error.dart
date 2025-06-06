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
  String toString() =>
      'Response Format Error: $message. Raw response: $rawResponse';
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

/// Rate limit exceeded error
class RateLimitError extends LLMError {
  final Duration? retryAfter;
  final int? remainingRequests;

  const RateLimitError(super.message,
      {this.retryAfter, this.remainingRequests});

  @override
  String toString() =>
      'Rate Limit Error: $message${retryAfter != null ? ' (retry after ${retryAfter!.inSeconds}s)' : ''}';
}

/// Quota exceeded error
class QuotaExceededError extends LLMError {
  final String? quotaType; // 'tokens', 'requests', 'credits'

  const QuotaExceededError(super.message, {this.quotaType});

  @override
  String toString() =>
      'Quota Exceeded Error: $message${quotaType != null ? ' (quota type: $quotaType)' : ''}';
}

/// Model not available error
class ModelNotAvailableError extends LLMError {
  final String model;
  final List<String>? availableModels;

  const ModelNotAvailableError(this.model, {this.availableModels})
      : super('Model not available: $model');

  @override
  String toString() {
    final base = 'Model Not Available Error: $message';
    if (availableModels != null && availableModels!.isNotEmpty) {
      return '$base. Available models: ${availableModels!.join(', ')}';
    }
    return base;
  }
}

/// Content filter error
class ContentFilterError extends LLMError {
  final String? filterType; // 'safety', 'content_policy', etc.

  const ContentFilterError(super.message, {this.filterType});

  @override
  String toString() =>
      'Content Filter Error: $message${filterType != null ? ' (filter: $filterType)' : ''}';
}

/// Server error (5xx status codes)
class ServerError extends LLMError {
  final int? statusCode;

  const ServerError(super.message, {this.statusCode});

  @override
  String toString() =>
      'Server Error: $message${statusCode != null ? ' (HTTP $statusCode)' : ''}';
}

/// HTTP error mapper utility
class HttpErrorMapper {
  /// Map HTTP status code to appropriate LLM error
  static LLMError mapStatusCode(int statusCode, String message,
      [Map<String, dynamic>? responseData]) {
    switch (statusCode) {
      case 400:
        return InvalidRequestError(message);
      case 401:
        return AuthError(message);
      case 403:
        return AuthError('Forbidden: $message');
      case 404:
        final model = responseData?['model'] as String?;
        return ModelNotAvailableError(model ?? 'unknown');
      case 422:
        return InvalidRequestError('Validation error: $message');
      case 429:
        final retryAfter = responseData?['retry_after'] as int?;
        final remaining = responseData?['remaining_requests'] as int?;
        return RateLimitError(
          message,
          retryAfter: retryAfter != null ? Duration(seconds: retryAfter) : null,
          remainingRequests: remaining,
        );
      case 500:
        return ServerError(message, statusCode: statusCode);
      case 502:
        return ServerError('Bad Gateway: $message', statusCode: statusCode);
      case 503:
        return ServerError('Service Unavailable: $message',
            statusCode: statusCode);
      case 504:
        return ServerError('Gateway Timeout: $message', statusCode: statusCode);
      default:
        if (statusCode >= 400 && statusCode < 500) {
          return HttpError('Client error (HTTP $statusCode): $message');
        } else if (statusCode >= 500) {
          return ServerError('Server error (HTTP $statusCode): $message',
              statusCode: statusCode);
        } else {
          return HttpError('HTTP $statusCode: $message');
        }
    }
  }

  /// Extract retry-after duration from response headers
  static Duration? extractRetryAfter(Map<String, dynamic>? headers) {
    if (headers == null) return null;

    final retryAfter = headers['retry-after'] ?? headers['Retry-After'];
    if (retryAfter == null) return null;

    if (retryAfter is int) {
      return Duration(seconds: retryAfter);
    } else if (retryAfter is String) {
      final seconds = int.tryParse(retryAfter);
      if (seconds != null) {
        return Duration(seconds: seconds);
      }
    }

    return null;
  }
}
