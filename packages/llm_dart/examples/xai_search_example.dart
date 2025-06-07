// Import required modules from the LLM Dart library for xAI search integration
import 'dart:io';
import 'package:llm_dart/llm_dart.dart';

/// Example demonstrating how to use the xAI provider with search functionality
///
/// Note: This example shows the API usage pattern. The xAI provider is not
/// fully registered in the current registry, so it will show "Unknown provider" errors.
/// This demonstrates how search parameters would be used when the provider is available.
void main() async {
  // ignore_for_file: avoid_print

  // Get xAI API key from environment variable or use test key as fallback
  final apiKey = Platform.environment['XAI_API_KEY'] ?? 'xai-test-key';

  print('=== xAI Search Examples (API Demonstration) ===\n');
  print('Note: These examples show the correct API usage pattern.');
  print('The xAI provider is not fully registered yet, so you will see');
  print('"Unknown provider" errors, but the syntax is correct.\n');

  print('=== Basic Search Example ===');
  await basicSearchExample(apiKey);

  print('\n=== Date Range Search Example ===');
  await dateRangeSearchExample(apiKey);

  print('\n=== Search with Source Exclusions Example ===');
  await sourceExclusionSearchExample(apiKey);

  print('\n=== Search Parameters Configuration Examples ===');
  demonstrateSearchParametersConfiguration();
}

/// Example 1: Basic search with auto mode and result limit
Future<void> basicSearchExample(String apiKey) async {
  try {
    final searchParams = SearchParameters(mode: 'auto', maxSearchResults: 10);

    final llm = await ai()
        .provider('xai')
        .apiKey(apiKey)
        .model('grok-3-latest')
        .extension('searchParameters', searchParams)
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

    final llm = await ai()
        .provider('xai')
        .apiKey(apiKey)
        .model('grok-3-latest')
        .extension('searchParameters', searchParams)
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

    final llm = await ai()
        .provider('xai')
        .apiKey(apiKey)
        .model('grok-3-latest')
        .extension('searchParameters', searchParams)
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

/// Demonstrate how to configure search parameters for xAI
void demonstrateSearchParametersConfiguration() {
  print('1. Basic Search Parameters:');
  final basicParams = SearchParameters(
    mode: 'auto',
    maxSearchResults: 10,
  );
  print('   Mode: ${basicParams.mode}');
  print('   Max Results: ${basicParams.maxSearchResults}');

  print('\n2. Date Range Search Parameters:');
  final dateRangeParams = SearchParameters(
    mode: 'auto',
    maxSearchResults: 5,
    fromDate: '2023-01-01',
    toDate: '2023-12-31',
  );
  print('   From Date: ${dateRangeParams.fromDate}');
  print('   To Date: ${dateRangeParams.toDate}');

  print('\n3. Source Exclusion Parameters:');
  final sourceParams = SearchParameters(
    mode: 'auto',
    maxSearchResults: 8,
    sources: [
      SearchSource(sourceType: 'web', excludedWebsites: ['example.com']),
      SearchSource(sourceType: 'news', excludedWebsites: ['news.example.com']),
    ],
  );
  print('   Sources configured: ${sourceParams.sources?.length ?? 0}');
  for (int i = 0; i < (sourceParams.sources?.length ?? 0); i++) {
    final source = sourceParams.sources![i];
    print(
        '   Source ${i + 1}: ${source.sourceType} (excludes: ${source.excludedWebsites?.join(', ') ?? 'none'})');
  }

  print('\n4. How to use with the new API:');
  print('   ```dart');
  print('   final llm = await ai()');
  print('       .provider("xai")');
  print('       .apiKey("your-api-key")');
  print('       .model("grok-3-latest")');
  print('       .extension("searchParameters", searchParams)');
  print('       .build();');
  print('   ```');

  print('\n5. JSON representation:');
  print('   Basic params JSON: ${basicParams.toJson()}');
}
