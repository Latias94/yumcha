// ignore_for_file: avoid_print
// Import required modules from the LLM Dart library for ElevenLabs integration
import 'dart:io';
import 'dart:typed_data';
import 'package:llm_dart/llm_dart.dart';

/// Example demonstrating how to use the ElevenLabs provider for TTS and STT
///
/// This example shows:
/// - Text-to-Speech (TTS) with optimized voice settings for clear speech
/// - Speech-to-Text (STT) with multiple models and text cleaning
/// - Advanced features like model listing and voice configuration testing
/// - Text post-processing to handle common STT formatting issues
///
/// Prerequisites:
/// - ElevenLabs API key (set ELEVENLABS_API_KEY environment variable)
/// - Internet connection for API calls
///
/// Usage:
/// ```bash
/// export ELEVENLABS_API_KEY=your_api_key_here
/// dart run elevenlabs_example.dart
/// ```
void main() async {
  // Get ElevenLabs API key from environment variable
  final apiKey = Platform.environment['ELEVENLABS_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    print('❌ Please set ELEVENLABS_API_KEY environment variable');
    print('   Example: export ELEVENLABS_API_KEY=your_api_key_here');
    return;
  }

  print('🎙️ ElevenLabs TTS/STT Example');
  print('=' * 50);

  try {
    // Initialize and configure the ElevenLabs client
    final provider = await ai()
        .elevenlabs() // Use ElevenLabs as the provider
        .apiKey(apiKey) // Set the API key
        .model('eleven_multilingual_v2') // Use multilingual model for TTS
        .voiceId('JBFqnCBsd6RMkjVDRZzb') // Set voice ID (George voice)
        .stability(0.7) // Higher stability for cleaner speech (0.0-1.0)
        .similarityBoost(0.9) // Higher similarity for better quality (0.0-1.0)
        .style(0.1) // Minimal style for natural speech (0.0-1.0)
        .useSpeakerBoost(true) // Enable speaker boost
        .build();

    // Cast to ElevenLabsProvider to access TTS/STT methods
    final elevenLabsProvider = provider as ElevenLabsProvider;

    print('✅ ElevenLabs provider initialized successfully');
    print('   API Key: ${apiKey.substring(0, 8)}...');
    print('   Model: eleven_multilingual_v2');
    print('   Voice ID: JBFqnCBsd6RMkjVDRZzb');
    print('');

    // Demonstrate Text-to-Speech (TTS)
    // await demonstrateTTS(elevenLabsProvider);

    print('');

    // Demonstrate Speech-to-Text (STT) if audio file exists
    await demonstrateSTT(elevenLabsProvider);

    print('');

    // Demonstrate advanced features
    // await demonstrateAdvancedFeatures(elevenLabsProvider);
  } catch (e) {
    print('❌ Error: $e');
    if (e.toString().contains('401') || e.toString().contains('auth')) {
      print('   Please check your ElevenLabs API key');
    }
  }
}

/// Demonstrates Text-to-Speech functionality
Future<void> demonstrateTTS(ElevenLabsProvider provider) async {
  print('🔊 Text-to-Speech Demo');
  print('-' * 30);

  const text =
      'Hello! This is an example of text-to-speech synthesis using ElevenLabs. '
      'The voice quality is quite impressive, don\'t you think?';

  print('Text to convert: "$text"');
  print('Converting to speech...');

  try {
    // Convert text to speech
    final ttsResponse = await provider.textToSpeech(text);

    // Save audio to file
    const outputFile = 'elevenlabs_output.mp3';
    await File(outputFile).writeAsBytes(ttsResponse.audioData);

    print('✅ TTS completed successfully!');
    print('   Audio saved to: $outputFile');
    print('   Audio size: ${ttsResponse.audioData.length} bytes');
    print('   Content type: ${ttsResponse.contentType ?? 'audio/mpeg'}');
  } catch (e) {
    print('❌ TTS failed: $e');
  }
}

/// Demonstrates Speech-to-Text functionality
Future<void> demonstrateSTT(ElevenLabsProvider provider) async {
  print('🎤 Speech-to-Text Demo');
  print('-' * 30);

  // Check if we have an audio file to transcribe
  const audioFile = 'elevenlabs_output.mp3';
  final file = File(audioFile);

  if (!await file.exists()) {
    print('ℹ️  No audio file found for STT demo');
    print(
        '   Run TTS first to generate an audio file, or provide your own audio file');
    return;
  }

  print('Audio file: $audioFile');
  print('Transcribing audio...');

  try {
    // Method 1: Transcribe from file path
    final sttResponse = await provider.speechToTextFromFile(
      audioFile,
      model: 'scribe_v1', // Use scribe model for STT
    );

    print('✅ STT completed successfully!');
    print('   Raw transcribed text: "${sttResponse.text}"');

    // Clean up the transcribed text (remove extra spaces)
    final cleanedText = _cleanTranscribedText(sttResponse.text);
    print('   Cleaned text: "$cleanedText"');

    print('   Language: ${sttResponse.languageCode ?? 'auto-detected'}');
    print(
        '   Language confidence: ${sttResponse.languageProbability?.toStringAsFixed(2) ?? 'N/A'}');

    // Show word-level timing if available
    if (sttResponse.words != null && sttResponse.words!.isNotEmpty) {
      print('   Word-level timing:');
      for (final word in sttResponse.words!.take(5)) {
        // Show first 5 words
        print(
            '     "${word.text}" (${word.start.toStringAsFixed(2)}s - ${word.end.toStringAsFixed(2)}s)');
      }
      if (sttResponse.words!.length > 5) {
        print('     ... and ${sttResponse.words!.length - 5} more words');
      }
    }

    // Method 2: Demonstrate transcribing from audio bytes
    print('');
    print('🔄 Alternative: Transcribing from audio bytes...');

    final audioBytes = await file.readAsBytes();
    final sttResponse2 = await provider.speechToText(
      Uint8List.fromList(audioBytes),
      model: 'scribe_v1_experimental', // Use experimental model for comparison
    );

    print('✅ Bytes-based STT completed!');
    print('   Raw transcribed text: "${sttResponse2.text}"');

    // Clean up the transcribed text
    final cleanedText2 = _cleanTranscribedText(sttResponse2.text);
    print('   Cleaned text: "$cleanedText2"');
  } catch (e) {
    print('❌ STT failed: $e');
    if (e.toString().contains('format')) {
      print('   Try using a different audio format (WAV, MP3, etc.)');
    }
  }
}

/// Demonstrates advanced ElevenLabs features
Future<void> demonstrateAdvancedFeatures(ElevenLabsProvider provider) async {
  print('🚀 Advanced Features Demo');
  print('-' * 30);

  try {
    // Get available models
    print('📋 Available models:');
    final models = await provider.getModels();
    for (final model in models.take(3)) {
      // Show first 3 models
      print(
          '   - ${model['name'] ?? model['model_id']} (${model['model_id']})');
    }
    if (models.length > 3) {
      print('   ... and ${models.length - 3} more models');
    }

    print('');

    // Demonstrate different voice settings
    print('🎛️  Testing different voice settings...');
    const testText = 'This is a test with different voice settings.';

    final settingsTests = [
      {'name': 'High Stability', 'stability': 0.9, 'similarityBoost': 0.5},
      {'name': 'High Similarity', 'stability': 0.3, 'similarityBoost': 0.9},
      {'name': 'Balanced', 'stability': 0.5, 'similarityBoost': 0.7},
    ];

    for (final settings in settingsTests) {
      try {
        // Create a new provider with different settings
        final testProvider = await ai()
            .elevenlabs()
            .apiKey(provider.config.apiKey)
            .model('eleven_multilingual_v2')
            .voiceId('JBFqnCBsd6RMkjVDRZzb')
            .stability(settings['stability'] as double)
            .similarityBoost(settings['similarityBoost'] as double)
            .build() as ElevenLabsProvider;

        final response = await testProvider.textToSpeech(testText);
        final filename =
            'test_${(settings['name'] as String).toLowerCase().replaceAll(' ', '_')}.mp3';
        await File(filename).writeAsBytes(response.audioData);

        print(
            '   ✅ ${settings['name']}: $filename (${response.audioData.length} bytes)');
      } catch (e) {
        print('   ❌ ${settings['name']}: $e');
      }
    }
  } catch (e) {
    print('❌ Advanced features demo failed: $e');
  }
}

/// Cleans up transcribed text by removing extra spaces and normalizing formatting
String _cleanTranscribedText(String text) {
  return text
      // Replace multiple spaces with single space
      .replaceAll(RegExp(r'\s+'), ' ')
      // Remove spaces before punctuation
      .replaceAll(RegExp(r'\s+([,.!?;:])'), r'$1')
      // Add space after punctuation if missing
      .replaceAll(RegExp(r'([,.!?;:])([A-Za-z])'), r'$1 $2')
      // Trim leading/trailing spaces
      .trim();
}
