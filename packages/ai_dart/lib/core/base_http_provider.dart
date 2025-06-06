import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import 'chat_provider.dart';
import 'llm_error.dart';
import '../models/chat_models.dart';
import '../models/tool_models.dart';

/// Base class for HTTP-based LLM providers
///
/// This class provides common functionality for providers that use HTTP APIs,
/// reducing code duplication and ensuring consistent error handling.
abstract class BaseHttpProvider implements ChatCapability {
  final Dio _dio;
  final Logger _logger;

  BaseHttpProvider(this._dio, String loggerName) : _logger = Logger(loggerName);

  /// Protected access to Dio instance for subclasses
  Dio get dio => _dio;

  /// Protected access to Logger instance for subclasses
  Logger get logger => _logger;

  /// Provider-specific name for logging and error messages
  String get providerName;

  /// Build the request body for chat requests
  ///
  /// Each provider should implement this to format requests according to their API
  Map<String, dynamic> buildRequestBody(
    List<ChatMessage> messages,
    List<Tool>? tools,
    bool stream,
  );

  /// Parse the response into a ChatResponse
  ///
  /// Each provider should implement this to parse their specific response format
  ChatResponse parseResponse(Map<String, dynamic> responseData);

  /// Parse streaming events
  ///
  /// Each provider should implement this to parse their specific streaming format
  List<ChatStreamEvent> parseStreamEvents(String chunk);

  /// Get the chat endpoint path
  String get chatEndpoint;

  /// Validate API key before making requests
  void validateApiKey(String? apiKey) {
    if (apiKey == null || apiKey.isEmpty) {
      throw AuthError('Missing $providerName API key');
    }
  }

  @override
  Future<ChatResponse> chatWithTools(
    List<ChatMessage> messages,
    List<Tool>? tools,
  ) async {
    try {
      final requestBody = buildRequestBody(messages, tools, false);

      // Optimized trace logging with condition check
      if (_logger.isLoggable(Level.FINEST)) {
        _logger.finest(
            '$providerName request payload: ${jsonEncode(requestBody)}');
      }

      _logger.fine('$providerName request: POST $chatEndpoint');

      final response = await _dio.post(chatEndpoint, data: requestBody);

      _logger.fine('$providerName HTTP status: ${response.statusCode}');

      // Enhanced error handling with detailed information
      if (response.statusCode != 200) {
        _handleHttpError(response.statusCode, response.data);
      }

      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw ResponseFormatError(
          'Invalid response format from $providerName API',
          responseData.toString(),
        );
      }

      return parseResponse(responseData);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw GenericError('Unexpected error: $e');
    }
  }

  @override
  Stream<ChatStreamEvent> chatStream(
    List<ChatMessage> messages, {
    List<Tool>? tools,
  }) async* {
    try {
      final requestBody = buildRequestBody(messages, tools, true);

      // Optimized trace logging with condition check
      if (_logger.isLoggable(Level.FINEST)) {
        _logger.finest(
            '$providerName stream request payload: ${jsonEncode(requestBody)}');
      }

      _logger.fine('$providerName stream request: POST $chatEndpoint');

      final response = await _dio.post(
        chatEndpoint,
        data: requestBody,
        options: Options(responseType: ResponseType.stream),
      );

      _logger.fine('$providerName stream HTTP status: ${response.statusCode}');

      if (response.statusCode != 200) {
        yield ErrorEvent(
          ProviderError(
              '$providerName API returned status ${response.statusCode}'),
        );
        return;
      }

      final stream = response.data as ResponseBody;

      await for (final chunk in stream.stream.map(utf8.decode)) {
        try {
          final events = parseStreamEvents(chunk);
          for (final event in events) {
            yield event;
          }
        } catch (e) {
          // Skip malformed chunks but log them
          _logger.warning('Failed to parse stream chunk: $e');
          continue;
        }
      }
    } on DioException catch (e) {
      yield ErrorEvent(handleDioError(e));
    } catch (e) {
      yield ErrorEvent(GenericError('Unexpected error: $e'));
    }
  }

  /// Handle HTTP error responses with provider-specific error messages
  void _handleHttpError(int? statusCode, dynamic errorData) {
    if (statusCode == 401) {
      throw AuthError('Invalid $providerName API key');
    } else if (statusCode == 429) {
      throw const ProviderError('Rate limit exceeded');
    } else if (statusCode == 400) {
      throw ResponseFormatError(
        'Bad request - check your parameters',
        errorData?.toString() ?? '',
      );
    } else if (statusCode == 500) {
      throw ProviderError('$providerName server error');
    } else {
      throw ResponseFormatError(
        '$providerName API returned error status: $statusCode',
        errorData?.toString() ?? '',
      );
    }
  }

  /// Handle Dio exceptions with consistent error mapping
  LLMError handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        final error = HttpError('Request timeout: ${e.message}');
        _logger.warning('$providerName timeout error: ${error.message}');
        return error;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        _logger.warning('$providerName bad response: $statusCode, data: $data');

        if (statusCode == 401) {
          return AuthError('Invalid $providerName API key');
        } else if (statusCode == 429) {
          return const ProviderError('Rate limit exceeded');
        } else {
          return ProviderError('HTTP $statusCode: $data');
        }
      case DioExceptionType.cancel:
        return const GenericError('Request was cancelled');
      case DioExceptionType.connectionError:
        return HttpError('Connection error: ${e.message}');
      case DioExceptionType.badCertificate:
        return HttpError('SSL certificate error: ${e.message}');
      case DioExceptionType.unknown:
        return GenericError('Network error: ${e.message}');
    }
  }

  /// Create a standardized Dio instance with common configuration
  static Dio createDio({
    required String baseUrl,
    required Map<String, String> headers,
    Duration? timeout,
  }) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout ?? const Duration(seconds: 30),
        receiveTimeout: timeout ?? const Duration(seconds: 30),
        headers: headers,
      ),
    );
  }
}
