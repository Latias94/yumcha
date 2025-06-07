// ignore_for_file: avoid_print

import 'package:llm_dart/llm_dart.dart';

/// Helper class for querying provider capabilities
class ProviderCapabilityQuery {
  /// Get all registered providers and their capabilities
  static Map<String, Set<LLMCapability>> getAllProviderCapabilities() {
    final capabilities = <String, Set<LLMCapability>>{};

    // Get all registered factories
    final factories = LLMProviderRegistry.getAllFactories();

    for (final factory in factories.values) {
      capabilities[factory.providerId] = factory.supportedCapabilities;
    }

    return capabilities;
  }

  /// Check if a specific provider supports a capability
  static bool providerSupports(String providerId, LLMCapability capability) {
    final factory = LLMProviderRegistry.getFactory(providerId);
    if (factory == null) return false;

    return factory.supportedCapabilities.contains(capability);
  }

  /// Get providers that support a specific capability
  static List<String> getProvidersWithCapability(LLMCapability capability) {
    final providers = <String>[];
    final factories = LLMProviderRegistry.getAllFactories();

    for (final factory in factories.values) {
      if (factory.supportedCapabilities.contains(capability)) {
        providers.add(factory.providerId);
      }
    }

    return providers;
  }

  /// Get the best provider for a set of required capabilities
  static String? getBestProviderFor(Set<LLMCapability> requiredCapabilities) {
    final factories = LLMProviderRegistry.getAllFactories();

    for (final factory in factories.values) {
      if (requiredCapabilities
          .every((cap) => factory.supportedCapabilities.contains(cap))) {
        return factory.providerId;
      }
    }

    return null;
  }

  /// Print capability matrix for all providers
  static void printCapabilityMatrix() {
    final capabilities = getAllProviderCapabilities();
    final allCapabilities = LLMCapability.values;

    print('Provider Capability Matrix:');
    print('');

    // Header
    final header = 'Provider'.padRight(12);
    final capHeaders = allCapabilities
        .map((cap) => cap.name.substring(0, 4).padRight(5))
        .join('');
    print('$header $capHeaders');
    print('-' * (header.length + capHeaders.length));

    // Rows
    for (final entry in capabilities.entries) {
      final provider = entry.key.padRight(12);
      final caps = allCapabilities.map((cap) {
        final supported = entry.value.contains(cap);
        return (supported ? '✅' : '❌').padRight(5);
      }).join('');
      print('$provider $caps');
    }
  }
}

/// Example showing how to query provider capabilities through factories
/// This is a better approach than using is/as checks
void main() async {
  print('=== Provider Capability Query Example ===\n');

  // 1. Print capability matrix
  ProviderCapabilityQuery.printCapabilityMatrix();

  print('\n=== Capability Queries ===\n');

  // 2. Check specific provider capabilities
  print(
      'OpenAI supports embedding: ${ProviderCapabilityQuery.providerSupports('openai', LLMCapability.embedding)}');
  print(
      'Anthropic supports embedding: ${ProviderCapabilityQuery.providerSupports('anthropic', LLMCapability.embedding)}');
  print(
      'Ollama supports model listing: ${ProviderCapabilityQuery.providerSupports('ollama', LLMCapability.modelListing)}');

  print('\n=== Find Providers by Capability ===\n');

  // 3. Find providers with specific capabilities
  final embeddingProviders = ProviderCapabilityQuery.getProvidersWithCapability(
      LLMCapability.embedding);
  print('Providers with embedding: $embeddingProviders');

  final reasoningProviders = ProviderCapabilityQuery.getProvidersWithCapability(
      LLMCapability.reasoning);
  print('Providers with reasoning: $reasoningProviders');

  final ttsProviders = ProviderCapabilityQuery.getProvidersWithCapability(
      LLMCapability.textToSpeech);
  print('Providers with text-to-speech: $ttsProviders');

  print('\n=== Find Best Provider for Requirements ===\n');

  // 4. Find best provider for specific requirements
  final chatAndEmbedding = {LLMCapability.chat, LLMCapability.embedding};
  final bestForEmbedding =
      ProviderCapabilityQuery.getBestProviderFor(chatAndEmbedding);
  print('Best provider for chat + embedding: $bestForEmbedding');

  final chatAndReasoning = {LLMCapability.chat, LLMCapability.reasoning};
  final bestForReasoning =
      ProviderCapabilityQuery.getBestProviderFor(chatAndReasoning);
  print('Best provider for chat + reasoning: $bestForReasoning');

  final allVoice = {
    LLMCapability.chat,
    LLMCapability.textToSpeech,
    LLMCapability.speechToText
  };
  final bestForVoice = ProviderCapabilityQuery.getBestProviderFor(allVoice);
  print('Best provider for full voice capabilities: $bestForVoice');

  print('\n=== Smart Provider Selection ===\n');

  // 5. Smart provider selection based on needs
  await demonstrateSmartSelection();
}

/// Demonstrate smart provider selection
Future<void> demonstrateSmartSelection() async {
  // Scenario 1: Need embedding functionality
  print('Scenario 1: Need embedding functionality');
  final embeddingProviders = ProviderCapabilityQuery.getProvidersWithCapability(
      LLMCapability.embedding);
  if (embeddingProviders.isNotEmpty) {
    print('  Available providers: $embeddingProviders');
    print('  Selecting: ${embeddingProviders.first}');

    try {
      final provider = await ai()
          .provider(embeddingProviders.first)
          .apiKey('test-key')
          .model('test-model')
          .build();

      // Now we know this provider supports embedding
      if (provider is EmbeddingCapability) {
        print('  ✅ Provider supports embedding interface');
      }
    } catch (e) {
      print('  ❌ Error creating provider: $e');
    }
  }

  print('');

  // Scenario 2: Need reasoning functionality
  print('Scenario 2: Need reasoning functionality');
  final reasoningProviders = ProviderCapabilityQuery.getProvidersWithCapability(
      LLMCapability.reasoning);
  if (reasoningProviders.isNotEmpty) {
    print('  Available providers: $reasoningProviders');
    print('  Selecting: ${reasoningProviders.first}');
  }

  print('');

  // Scenario 3: Need local deployment
  print('Scenario 3: Need local deployment');
  if (ProviderCapabilityQuery.providerSupports('ollama', LLMCapability.chat)) {
    print('  Ollama supports chat - good for local deployment');
    if (ProviderCapabilityQuery.providerSupports(
        'ollama', LLMCapability.embedding)) {
      print('  Ollama also supports embedding - perfect for local RAG');
    }
  }
}

/// Extension to make capability checking easier
extension ProviderCapabilityExtensions on String {
  /// Check if this provider ID supports a capability
  bool supports(LLMCapability capability) {
    return ProviderCapabilityQuery.providerSupports(this, capability);
  }

  /// Get all capabilities for this provider
  Set<LLMCapability> get capabilities {
    final factory = LLMProviderRegistry.getFactory(this);
    return factory?.supportedCapabilities ?? {};
  }

  /// Check if this provider supports all required capabilities
  bool supportsAll(Set<LLMCapability> capabilities) {
    return capabilities.every((cap) => supports(cap));
  }
}

/// Example using extensions
void extensionExample() {
  // ignore_for_file: avoid_print

  print('\n=== Extension Example ===\n');

  // Check capabilities using extensions
  print(
      'OpenAI supports embedding: ${'openai'.supports(LLMCapability.embedding)}');
  print(
      'Anthropic supports reasoning: ${'anthropic'.supports(LLMCapability.reasoning)}');

  // Get all capabilities
  print('OpenAI capabilities: ${'openai'.capabilities}');
  print('Ollama capabilities: ${'ollama'.capabilities}');

  // Check multiple capabilities
  final voiceCapabilities = {
    LLMCapability.textToSpeech,
    LLMCapability.speechToText
  };
  print('OpenAI supports voice: ${'openai'.supportsAll(voiceCapabilities)}');
  print(
      'Anthropic supports voice: ${'anthropic'.supportsAll(voiceCapabilities)}');
}
