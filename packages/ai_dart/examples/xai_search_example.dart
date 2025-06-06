// Import required modules from the AI Dart library for xAI search integration
import 'dart:io';
import '../lib/builder/llm_builder.dart';
import '../lib/models/chat_models.dart';
import '../lib/providers/xai_provider.dart';

/// Example demonstrating how to use the xAI provider with search functionality
void main() async {
  // Get xAI API key from environment variable or use test key as fallback
  final apiKey = Platform.environment['XAI_API_KEY'] ?? 'xai-test-key';

  print('=== Basic Search Example ===');
  await basicSearchExample(apiKey);

  print('\n=== Date Range Search Example ===');
  await dateRangeSearchExample(apiKey);

  print('\n=== Search with Source Exclusions Example ===');
  await sourceExclusionSearchExample(apiKey);
}

/// Example 1: Basic search with auto mode and result limit
Future<void> basicSearchExample(String apiKey) async {
  try {
    final searchParams = SearchParameters(mode: 'auto', maxSearchResults: 10);

    final llm = await LLMBuilder()
        .backend(LLMBackend.xai)
        .apiKey(apiKey)
        .model('grok-3-latest')
        .searchParameters(searchParams)
        .build();

    final messages = [
      ChatMessage.user(
        'What are some recently discovered alternative DNA shapes?',
      ),
    ];

    final response = await llm.chat(messages);
    print('Response: ${response.text ?? 'No response'}');
  } catch (e) {
    print('Basic search error: $e');
  }
}

/// Example 2: Search with date range
Future<void> dateRangeSearchExample(String apiKey) async {
  try {
    final searchParams = SearchParameters(
      mode: 'auto',
      maxSearchResults: 5,
      fromDate: '2022-01-01',
      toDate: '2022-12-31',
    );

    final llm = await LLMBuilder()
        .backend(LLMBackend.xai)
        .apiKey(apiKey)
        .model('grok-3-latest')
        .searchParameters(searchParams)
        .build();

    final messages = [
      ChatMessage.user('What were the major AI breakthroughs in 2022?'),
    ];

    final response = await llm.chat(messages);
    print('Response: ${response.text ?? 'No response'}');
  } catch (e) {
    print('Date range search error: $e');
  }
}

/// Example 3: Search with source exclusions
Future<void> sourceExclusionSearchExample(String apiKey) async {
  try {
    final searchParams = SearchParameters(
      mode: 'auto',
      maxSearchResults: 8,
      fromDate: '2023-01-01',
      sources: [
        SearchSource(sourceType: 'web', excludedWebsites: ['wikipedia.org']),
        SearchSource(sourceType: 'news', excludedWebsites: ['bbc.co.uk']),
      ],
    );

    final llm = await LLMBuilder()
        .backend(LLMBackend.xai)
        .apiKey(apiKey)
        .model('grok-3-latest')
        .searchParameters(searchParams)
        .build();

    final messages = [
      ChatMessage.user(
        'What are the latest developments in quantum computing?',
      ),
    ];

    final response = await llm.chat(messages);
    print('Response: ${response.text ?? 'No response'}');
  } catch (e) {
    print('Source exclusion search error: $e');
  }
}
