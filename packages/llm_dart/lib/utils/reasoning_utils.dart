/// Utilities for handling reasoning/thinking content in AI responses
/// This matches the logic from the TypeScript implementation

import '../models/chat_models.dart';

/// Result of reasoning detection
class ReasoningDetectionResult {
  final bool isReasoningJustDone;
  final bool hasReasoningContent;
  final String updatedLastChunk;

  const ReasoningDetectionResult({
    required this.isReasoningJustDone,
    required this.hasReasoningContent,
    required this.updatedLastChunk,
  });
}

/// Utilities for handling reasoning/thinking content
class ReasoningUtils {
  /// Check if reasoning just finished based on delta content
  /// This matches the TypeScript isReasoningJustDone function
  static ReasoningDetectionResult checkReasoningStatus({
    required Map<String, dynamic>? delta,
    required bool hasReasoningContent,
    required String lastChunk,
  }) {
    if (delta == null || delta['content'] == null) {
      return ReasoningDetectionResult(
        isReasoningJustDone: false,
        hasReasoningContent: hasReasoningContent,
        updatedLastChunk: lastChunk,
      );
    }

    final deltaContent = delta['content'] as String;

    // 检查当前chunk和上一个chunk的组合是否形成###Response标记
    final combinedChunks = lastChunk + deltaContent;
    final updatedLastChunk = deltaContent;

    // 检测思考结束
    if (combinedChunks.contains('###Response') || deltaContent == '</think>') {
      return ReasoningDetectionResult(
        isReasoningJustDone: true,
        hasReasoningContent: hasReasoningContent,
        updatedLastChunk: updatedLastChunk,
      );
    }

    // 如果有reasoning_content或reasoning或thinking，说明是在思考中
    bool updatedHasReasoningContent = hasReasoningContent;
    if (delta['reasoning_content'] != null ||
        delta['reasoning'] != null ||
        delta['thinking'] != null) {
      updatedHasReasoningContent = true;
    }

    // 如果之前有reasoning_content或reasoning，现在有普通content，说明思考结束
    if (hasReasoningContent && deltaContent.isNotEmpty) {
      return ReasoningDetectionResult(
        isReasoningJustDone: true,
        hasReasoningContent: updatedHasReasoningContent,
        updatedLastChunk: updatedLastChunk,
      );
    }

    return ReasoningDetectionResult(
      isReasoningJustDone: false,
      hasReasoningContent: updatedHasReasoningContent,
      updatedLastChunk: updatedLastChunk,
    );
  }

  /// Extract reasoning content from delta
  static String? extractReasoningContent(Map<String, dynamic>? delta) {
    if (delta == null) return null;

    return delta['reasoning_content'] as String? ??
        delta['reasoning'] as String? ??
        delta['thinking'] as String?;
  }

  /// Check if delta contains reasoning content
  static bool hasReasoningContent(Map<String, dynamic>? delta) {
    if (delta == null) return false;

    return delta['reasoning_content'] != null ||
        delta['reasoning'] != null ||
        delta['thinking'] != null;
  }

  /// Filter thinking content from text for display purposes
  /// Removes <think>...</think> tags and their content
  static String filterThinkingContent(String content) {
    // Remove <think>...</think> tags and their content
    return content
        .replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '')
        .trim();
  }

  /// Check if content contains thinking tags
  static bool containsThinkingTags(String content) {
    return content.contains('<think>') || content.contains('</think>');
  }

  /// Extract content without thinking tags
  static String extractContentWithoutThinking(String content) {
    // If content contains thinking tags, filter them out
    if (containsThinkingTags(content)) {
      return filterThinkingContent(content);
    }
    return content;
  }

  /// Check if the model is an OpenAI reasoning model (o1, o3, o4 series)
  /// This is used for specific OpenAI API parameter handling
  static bool isOpenAIReasoningModel(String model) {
    return model.startsWith('o1') ||
        model.startsWith('o3') ||
        model.startsWith('o4');
  }

  /// Check if the model is known to support reasoning (broader check)
  /// This is a hint for UI behavior, but actual reasoning detection
  /// should be based on response content, not model name
  static bool isKnownReasoningModel(String model) {
    return isOpenAIReasoningModel(model) ||
        model.contains('deepseek-r1') ||
        model.contains('claude-3.7-sonnet') ||
        model.contains('claude-3-7-sonnet') ||
        model.contains('qwen') && model.contains('reasoning') ||
        model.toLowerCase().contains('reasoning') ||
        model.toLowerCase().contains('thinking');
  }

  /// Get reasoning effort parameter for different providers
  static Map<String, dynamic> getReasoningEffortParams({
    required String providerId,
    required String model,
    ReasoningEffort? reasoningEffort,
  }) {
    if (reasoningEffort == null) return {};

    // Groq doesn't support reasoning effort
    if (providerId == 'groq') {
      return {};
    }

    // OpenRouter format
    if (providerId == 'openrouter') {
      return {
        'reasoning': {
          'effort': reasoningEffort.value,
        },
      };
    }

    // Grok reasoning models
    if (model.contains('grok') && isKnownReasoningModel(model)) {
      return {
        'reasoning_effort': reasoningEffort.value,
      };
    }

    // Default format (OpenAI, DeepSeek, etc.)
    return {
      'reasoning_effort': reasoningEffort.value,
    };
  }

  /// Get appropriate max tokens parameter for reasoning models
  static Map<String, dynamic> getMaxTokensParams({
    required String model,
    int? maxTokens,
  }) {
    if (maxTokens == null) return {};

    // OpenAI reasoning models use max_completion_tokens
    if (isOpenAIReasoningModel(model)) {
      return {
        'max_completion_tokens': maxTokens,
      };
    }

    // Standard models use max_tokens
    return {
      'max_tokens': maxTokens,
    };
  }

  /// Check if temperature should be disabled for reasoning models
  static bool shouldDisableTemperature(String model) {
    // OpenAI reasoning models don't support temperature
    if (isOpenAIReasoningModel(model)) {
      return true;
    }

    // Other known reasoning models that might not support temperature
    // This can be expanded based on provider documentation
    return false;
  }

  /// Check if top_p should be disabled for reasoning models
  static bool shouldDisableTopP(String model) {
    // OpenAI reasoning models don't support top_p
    if (isOpenAIReasoningModel(model)) {
      return true;
    }

    // Other known reasoning models that might not support top_p
    return false;
  }

  /// Parse reasoning metrics from response
  static Map<String, dynamic> parseReasoningMetrics({
    required DateTime startTime,
    DateTime? firstTokenTime,
    DateTime? firstContentTime,
    int? completionTokens,
  }) {
    final now = DateTime.now();
    final timeCompletionMs = now.difference(startTime).inMilliseconds;
    final timeFirstTokenMs =
        firstTokenTime?.difference(startTime).inMilliseconds ?? 0;
    final timeThinkingMs =
        firstContentTime?.difference(startTime).inMilliseconds ?? 0;

    return {
      'completion_tokens': completionTokens,
      'time_completion_millsec': timeCompletionMs,
      'time_first_token_millsec': timeFirstTokenMs,
      'time_thinking_millsec': timeThinkingMs,
    };
  }
}
