import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/search_state.dart';
import '../providers/chat_state_provider.dart';
import '../../features/chat/domain/entities/message.dart';

/// Search options for configuring search behavior
class SearchOptions {
  final String query;
  final bool caseSensitive;
  final bool wholeWord;
  final bool useRegex;
  final bool includeUserMessages;
  final bool includeAssistantMessages;
  final String? conversationFilter;
  final DateRange? dateFilter;
  final MessageTypeFilter? messageTypeFilter;
  final int maxResults;

  const SearchOptions({
    required this.query,
    this.caseSensitive = false,
    this.wholeWord = false,
    this.useRegex = false,
    this.includeUserMessages = true,
    this.includeAssistantMessages = true,
    this.conversationFilter,
    this.dateFilter,
    this.messageTypeFilter,
    this.maxResults = 100,
  });
}

/// Search service
///
/// Handles the actual search operations including content matching, filtering, and ranking.
/// Inspired by Cherry Studio's search functionality but optimized for Flutter/Dart.
class SearchService {
  final Ref _ref;

  SearchService(this._ref);

  /// Search messages based on the provided options
  Future<List<SearchResult>> searchMessages(SearchOptions options) async {
    try {
      // Get all messages from chat state
      final chatState = _ref.read(chatStateProvider);
      final allMessages = chatState.messages;

      // Filter messages based on options
      final filteredMessages = _filterMessages(allMessages, options);

      // Perform content search
      final results = <SearchResult>[];

      for (final message in filteredMessages) {
        final matches = _findMatches(message, options);
        results.addAll(matches);
      }

      // Sort results by relevance and timestamp
      results.sort((a, b) {
        // First sort by score (higher is better)
        final scoreComparison = b.score.compareTo(a.score);
        if (scoreComparison != 0) return scoreComparison;

        // Then sort by timestamp (newer first)
        return b.timestamp.compareTo(a.timestamp);
      });

      // Limit results
      if (results.length > options.maxResults) {
        return results.take(options.maxResults).toList();
      }

      return results;
    } catch (error) {
      throw SearchException('Search failed: $error');
    }
  }

  /// Filter messages based on search options
  List<Message> _filterMessages(List<Message> messages, SearchOptions options) {
    return messages.where((message) {
      // Filter by message type
      if (!options.includeUserMessages && message.isFromUser) {
        return false;
      }
      if (!options.includeAssistantMessages && !message.isFromUser) {
        return false;
      }

      // Filter by conversation
      if (options.conversationFilter != null &&
          message.conversationId != options.conversationFilter) {
        return false;
      }

      // Filter by date range
      if (options.dateFilter != null) {
        final messageDate = message.createdAt;
        if (messageDate.isBefore(options.dateFilter!.start) ||
            messageDate.isAfter(options.dateFilter!.end)) {
          return false;
        }
      }

      // Filter by message type filter
      if (options.messageTypeFilter != null) {
        switch (options.messageTypeFilter!) {
          case MessageTypeFilter.userOnly:
            return message.isFromUser;
          case MessageTypeFilter.assistantOnly:
            return !message.isFromUser;
          case MessageTypeFilter.systemOnly:
            // Assuming system messages have a specific role or type
            return false; // TODO: Implement system message detection
          case MessageTypeFilter.all:
            return true;
        }
      }

      return true;
    }).toList();
  }

  /// Find matches within a message
  List<SearchResult> _findMatches(Message message, SearchOptions options) {
    final content = message.content;
    final query = options.query;

    if (content.isEmpty || query.isEmpty) {
      return [];
    }

    final results = <SearchResult>[];

    try {
      if (options.useRegex) {
        // Use regex search
        final pattern = RegExp(
          query,
          caseSensitive: options.caseSensitive,
          multiLine: true,
        );

        final matches = pattern.allMatches(content);
        for (final match in matches) {
          results.add(_createSearchResult(
            message,
            match.start,
            match.end,
            content,
            options,
          ));
        }
      } else {
        // Use simple text search
        final searchContent =
            options.caseSensitive ? content : content.toLowerCase();
        final searchQuery = options.caseSensitive ? query : query.toLowerCase();

        if (options.wholeWord) {
          // Whole word matching
          final pattern = RegExp(
            r'\b' + RegExp.escape(searchQuery) + r'\b',
            caseSensitive: options.caseSensitive,
          );

          final matches = pattern.allMatches(searchContent);
          for (final match in matches) {
            results.add(_createSearchResult(
              message,
              match.start,
              match.end,
              content,
              options,
            ));
          }
        } else {
          // Simple substring search
          int startIndex = 0;
          while (true) {
            final index = searchContent.indexOf(searchQuery, startIndex);
            if (index == -1) break;

            results.add(_createSearchResult(
              message,
              index,
              index + searchQuery.length,
              content,
              options,
            ));

            startIndex = index + 1;
          }
        }
      }
    } catch (error) {
      // Handle regex errors gracefully
      // Fall back to simple search if regex fails
      if (options.useRegex) {
        final fallbackOptions = SearchOptions(
          query: options.query,
          caseSensitive: options.caseSensitive,
          wholeWord: false,
          useRegex: false,
          includeUserMessages: options.includeUserMessages,
          includeAssistantMessages: options.includeAssistantMessages,
          conversationFilter: options.conversationFilter,
          dateFilter: options.dateFilter,
          messageTypeFilter: options.messageTypeFilter,
          maxResults: options.maxResults,
        );
        return _findMatches(message, fallbackOptions);
      }
    }

    return results;
  }

  /// Create a search result from a match
  SearchResult _createSearchResult(
    Message message,
    int startIndex,
    int endIndex,
    String content,
    SearchOptions options,
  ) {
    // Calculate context
    const contextLength = 50;
    final beforeStart = (startIndex - contextLength).clamp(0, content.length);
    final afterEnd = (endIndex + contextLength).clamp(0, content.length);

    final beforeContext = content.substring(beforeStart, startIndex);
    final afterContext = content.substring(endIndex, afterEnd);
    final matchedContent = content.substring(startIndex, endIndex);

    // Calculate relevance score
    final score = _calculateRelevanceScore(
      matchedContent,
      options.query,
      message,
      startIndex,
      content,
    );

    return SearchResult(
      id: '${message.id}_${startIndex}_${endIndex}',
      messageId: message.id,
      conversationId: message.conversationId,
      content: matchedContent,
      fullContent: content,
      startIndex: startIndex,
      endIndex: endIndex,
      beforeContext: beforeContext,
      afterContext: afterContext,
      score: score,
      isUserMessage: message.isFromUser,
      timestamp: message.createdAt,
      metadata: {
        'messageRole': message.isFromUser ? 'user' : 'assistant',
        'messageLength': content.length,
        'matchPosition': startIndex / content.length,
      },
    );
  }

  /// Calculate relevance score for a search result
  double _calculateRelevanceScore(
    String matchedContent,
    String query,
    Message message,
    int position,
    String fullContent,
  ) {
    double score = 1.0;

    // Exact match bonus
    if (matchedContent.toLowerCase() == query.toLowerCase()) {
      score += 0.5;
    }

    // Position bonus (matches at the beginning are more relevant)
    final positionRatio = position / fullContent.length;
    score += (1.0 - positionRatio) * 0.2;

    // Length bonus (shorter messages with matches are more relevant)
    if (fullContent.length < 100) {
      score += 0.3;
    } else if (fullContent.length < 500) {
      score += 0.1;
    }

    // Recent message bonus
    final daysSinceCreated =
        DateTime.now().difference(message.createdAt).inDays;
    if (daysSinceCreated < 7) {
      score += 0.2;
    } else if (daysSinceCreated < 30) {
      score += 0.1;
    }

    return score.clamp(0.0, 3.0);
  }

  /// Get search suggestions based on query
  Future<List<String>> getSuggestions(String query) async {
    if (query.length < 2) return [];

    try {
      // Get recent search terms that match the query
      final suggestions = <String>[];

      // Add common search terms (this could be enhanced with ML)
      final commonTerms = [
        'error',
        'help',
        'how to',
        'what is',
        'explain',
        'example',
        'code',
        'function',
        'class',
        'method',
        'variable',
        'import',
        'install',
        'setup',
        'configure',
        'debug',
        'fix',
        'issue',
      ];

      for (final term in commonTerms) {
        if (term.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(term);
        }
      }

      // Limit suggestions
      return suggestions.take(5).toList();
    } catch (error) {
      return [];
    }
  }

  /// Clear search cache (if any)
  void clearCache() {
    // TODO: Implement search result caching if needed
  }
}

/// Search exception
class SearchException implements Exception {
  final String message;

  const SearchException(this.message);

  @override
  String toString() => 'SearchException: $message';
}

/// Search service provider
final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService(ref);
});
