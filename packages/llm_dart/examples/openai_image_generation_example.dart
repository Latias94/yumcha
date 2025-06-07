// ignore_for_file: avoid_print

import 'dart:io';
import 'package:llm_dart/llm_dart.dart';

/// Example demonstrating image generation capabilities with OpenAI DALL-E
///
/// This example shows how to:
/// 1. Configure an OpenAI provider for image generation
/// 2. Generate images with different parameters
/// 3. Handle image generation responses
///
/// Usage:
/// ```bash
/// export OPENAI_API_KEY="your-api-key-here"
/// dart run examples/image_generation_example.dart
/// ```
Future<void> main() async {
  // Get API key from environment
  final apiKey = Platform.environment['OPENAI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('❌ Please set OPENAI_API_KEY environment variable');
    exit(1);
  }

  print('🎨 OpenAI Image Generation Example');
  print('=' * 50);

  try {
    // Create OpenAI provider with image generation capabilities
    final provider = await ai()
        .openai()
        .apiKey(apiKey)
        .model('dall-e-3') // Use DALL-E 3 for high-quality images
        .imageSize('1024x1024') // Set default image size
        .build();

    // Check if provider supports image generation
    if (provider is! ImageGenerationCapability) {
      print('❌ Provider does not support image generation');
      exit(1);
    }

    final imageProvider = provider as ImageGenerationCapability;

    // Example 1: Basic image generation
    print('\n📸 Example 1: Basic Image Generation');
    print('-' * 30);

    final basicPrompt =
        'A serene mountain landscape at sunset with a lake reflection';
    print('Prompt: $basicPrompt');
    print('Generating image...');

    final basicImages = await imageProvider.generateImage(
      prompt: basicPrompt,
    );

    print('✅ Generated ${basicImages.length} image(s):');
    for (int i = 0; i < basicImages.length; i++) {
      print('  Image ${i + 1}: ${basicImages[i]}');
    }

    // Example 2: Advanced image generation with parameters
    print('\n🎯 Example 2: Advanced Image Generation');
    print('-' * 30);

    final advancedPrompt =
        'A futuristic cyberpunk city with neon lights and flying cars';
    print('Prompt: $advancedPrompt');
    print('Parameters: DALL-E 3, 1024x1024, enhanced prompt');
    print('Generating image...');

    final advancedImages = await imageProvider.generateImage(
      prompt: advancedPrompt,
      model: 'dall-e-3',
      imageSize: '1024x1024',
      promptEnhancement: true, // Let OpenAI enhance the prompt
    );

    print('✅ Generated ${advancedImages.length} image(s):');
    for (int i = 0; i < advancedImages.length; i++) {
      print('  Image ${i + 1}: ${advancedImages[i]}');
    }

    // Example 3: Multiple images with DALL-E 2
    print('\n🔢 Example 3: Multiple Images (DALL-E 2)');
    print('-' * 30);

    final multiPrompt = 'A cute cartoon robot playing with colorful blocks';
    print('Prompt: $multiPrompt');
    print('Parameters: DALL-E 2, 512x512, batch size 2');
    print('Generating images...');

    final multiImages = await imageProvider.generateImage(
      prompt: multiPrompt,
      model: 'dall-e-2',
      imageSize: '512x512',
      batchSize: 2, // Generate 2 images
    );

    print('✅ Generated ${multiImages.length} image(s):');
    for (int i = 0; i < multiImages.length; i++) {
      print('  Image ${i + 1}: ${multiImages[i]}');
    }

    // Example 4: Using builder pattern for configuration
    print('\n⚙️ Example 4: Builder Pattern Configuration');
    print('-' * 30);

    final configuredProvider = await ai()
        .openai()
        .apiKey(apiKey)
        .model('dall-e-3')
        .imageSize('1024x1024')
        .promptEnhancement(true)
        .build() as ImageGenerationCapability;

    final builderPrompt = 'An abstract geometric pattern with vibrant colors';
    print('Prompt: $builderPrompt');
    print('Using pre-configured provider settings');
    print('Generating image...');

    final builderImages = await configuredProvider.generateImage(
      prompt: builderPrompt,
    );

    print('✅ Generated ${builderImages.length} image(s):');
    for (int i = 0; i < builderImages.length; i++) {
      print('  Image ${i + 1}: ${builderImages[i]}');
    }

    print('\n🎉 Image generation examples completed successfully!');
    print('\n💡 Tips:');
    print('  • DALL-E 3 produces higher quality images but is more expensive');
    print(
        '  • DALL-E 2 allows multiple images per request and is more affordable');
    print('  • Use descriptive prompts for better results');
    print(
        '  • Consider image size based on your use case (larger = more expensive)');
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}
