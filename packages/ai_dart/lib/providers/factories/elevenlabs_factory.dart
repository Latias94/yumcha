import '../../core/chat_provider.dart';
import '../../core/config.dart';
import '../../core/registry.dart';
import '../elevenlabs_provider.dart';

/// Factory for creating ElevenLabs provider instances
/// 
/// Note: ElevenLabs is primarily a TTS/STT service and does not support chat functionality.
/// This factory creates ElevenLabsProvider instances for voice synthesis and recognition.
class ElevenLabsProviderFactory implements LLMProviderFactory<ElevenLabsProvider> {
  @override
  String get providerId => 'elevenlabs';

  @override
  String get displayName => 'ElevenLabs';

  @override
  String get description =>
      'ElevenLabs voice synthesis and speech recognition services';

  @override
  Set<LLMCapability> get supportedCapabilities => {
        LLMCapability.textToSpeech,
        LLMCapability.speechToText,
      };

  @override
  ElevenLabsProvider create(LLMConfig config) {
    final elevenLabsConfig = _transformConfig(config);
    return ElevenLabsProvider(elevenLabsConfig);
  }

  @override
  bool validateConfig(LLMConfig config) {
    // ElevenLabs requires an API key
    return config.apiKey != null && config.apiKey!.isNotEmpty;
  }

  @override
  LLMConfig getDefaultConfig() {
    return LLMConfig(
      baseUrl: 'https://api.elevenlabs.io/v1/',
      model: 'eleven_monolingual_v1',
    );
  }

  /// Transform unified config to ElevenLabs-specific config
  ElevenLabsConfig _transformConfig(LLMConfig config) {
    return ElevenLabsConfig(
      apiKey: config.apiKey!,
      baseUrl: config.baseUrl,
      model: config.model,
      timeout: config.timeout,
      // ElevenLabs-specific extensions
      voiceId: config.getExtension<String>('voiceId'),
      stability: config.getExtension<double>('stability'),
      similarityBoost: config.getExtension<double>('similarityBoost'),
      style: config.getExtension<double>('style'),
      useSpeakerBoost: config.getExtension<bool>('useSpeakerBoost'),
    );
  }
}
