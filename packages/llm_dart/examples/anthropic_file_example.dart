// ignore_for_file: avoid_print
// Import required modules from the LLM Dart library for Anthropic file operations
import 'dart:io';
import 'dart:typed_data';
import 'package:llm_dart/llm_dart.dart';

/// Example demonstrating Anthropic Claude file processing capabilities
///
/// This example shows:
/// - PDF document analysis
/// - Different file types support
/// - File MIME type handling
/// - Error handling for unsupported files
/// - Best practices for file uploads
///
/// Prerequisites:
/// - Anthropic API key (set ANTHROPIC_API_KEY environment variable)
/// - Claude model that supports document processing
///
/// Usage:
/// ```bash
/// export ANTHROPIC_API_KEY=sk-ant-your_key_here
/// dart run anthropic_file_example.dart
/// ```
void main() async {
  // Get Anthropic API key from environment variable
  final apiKey = Platform.environment['ANTHROPIC_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    print('❌ Please set ANTHROPIC_API_KEY environment variable');
    print('   Example: export ANTHROPIC_API_KEY=sk-ant-your_key_here');
    return;
  }

  print('📄 Anthropic File Processing Example');
  print('=' * 60);

  try {
    // Initialize Claude with a model that supports document processing
    final llm = await ai()
        .anthropic()
        .apiKey(apiKey)
        .model('claude-3-5-sonnet-20241022') // Supports PDF and vision
        .maxTokens(4000)
        .temperature(0.3) // Lower temperature for document analysis
        .build();

    print('✅ Claude provider initialized successfully');
    print('   Model: claude-3-5-sonnet-20241022');
    print('   File capabilities: PDF ✅, Images ✅');
    print('   Max file size: 32MB (PDF), 5MB (Images)');
    print('');

    // Example 1: PDF document analysis (simulated)
    await pdfAnalysisExample(llm);

    print('');

    // Example 2: Different file types demonstration
    await fileTypesExample(llm);

    print('');

    // Example 3: File upload best practices
    await fileBestPracticesExample();

    print('');

    // Example 4: Error handling for unsupported files
    await errorHandlingExample(llm);

  } catch (e) {
    print('❌ Error: $e');
    if (e.toString().contains('401') || e.toString().contains('auth')) {
      print('   Please check your Anthropic API key');
    } else if (e.toString().contains('model')) {
      print('   The specified model may not be available');
      print('   Try using claude-3-5-sonnet-20241022 or newer models');
    }
  }
}

/// Demonstrates PDF document analysis
Future<void> pdfAnalysisExample(ChatCapability llm) async {
  print('📄 PDF Document Analysis');
  print('-' * 40);

  // Simulate PDF content (in real usage, you'd load from file)
  print('📝 Simulating PDF analysis...');
  print('   In real usage: final pdfBytes = await File("document.pdf").readAsBytes();');
  print('');

  // Create a simulated PDF message
  final messages = [
    ChatMessage.user(
      'I have a PDF research paper about renewable energy. '
      'If I uploaded it, what kind of analysis could you perform?'
    ),
  ];

  final response = await llm.chat(messages);
  print('🤖 Claude\'s response:');
  print(response.text ?? 'No response');

  print('');
  print('💡 Real PDF usage example:');
  print('```dart');
  print('// Load PDF file');
  print('final pdfFile = File("research_paper.pdf");');
  print('final pdfBytes = await pdfFile.readAsBytes();');
  print('');
  print('// Create PDF message');
  print('final messages = [');
  print('  ChatMessage.pdf(');
  print('    role: ChatRole.user,');
  print('    data: pdfBytes,');
  print('    content: "Please summarize the key findings in this research paper",');
  print('  ),');
  print('];');
  print('');
  print('// Analyze with Claude');
  print('final response = await llm.chat(messages);');
  print('print("Summary: \${response.text}");');
  print('```');
}

/// Demonstrates different file types
Future<void> fileTypesExample(ChatCapability llm) async {
  print('📋 File Types Support');
  print('-' * 40);

  print('🎯 Anthropic Claude supports:');
  print('');
  
  print('📄 Documents:');
  print('   ✅ PDF (application/pdf) - Full support up to 32MB');
  print('   ❌ Word (.docx) - Not supported');
  print('   ❌ Excel (.xlsx) - Not supported');
  print('   ❌ PowerPoint (.pptx) - Not supported');
  print('');
  
  print('🖼️ Images:');
  print('   ✅ JPEG (image/jpeg) - Supported');
  print('   ✅ PNG (image/png) - Supported');
  print('   ✅ GIF (image/gif) - Supported');
  print('   ✅ WebP (image/webp) - Supported');
  print('');
  
  print('🎵 Audio/Video:');
  print('   ❌ MP3, WAV, MP4 - Not supported by Anthropic');
  print('   💡 Consider using Google AI or OpenAI for audio/video');
  print('');

  // Demonstrate file type checking
  print('💻 File type usage examples:');
  print('```dart');
  print('// PDF document');
  print('ChatMessage.file(');
  print('  role: ChatRole.user,');
  print('  mime: FileMime.pdf,');
  print('  data: pdfBytes,');
  print('  content: "Analyze this document",');
  print(')');
  print('');
  print('// Or use convenience method');
  print('ChatMessage.pdf(');
  print('  role: ChatRole.user,');
  print('  data: pdfBytes,');
  print('  content: "Analyze this document",');
  print(')');
  print('');
  print('// Image file');
  print('ChatMessage.image(');
  print('  role: ChatRole.user,');
  print('  mime: ImageMime.jpeg,');
  print('  data: imageBytes,');
  print('  content: "Describe this image",');
  print(')');
  print('```');
}

/// Demonstrates file upload best practices
Future<void> fileBestPracticesExample() async {
  print('💡 File Upload Best Practices');
  print('-' * 40);

  print('📏 Size Limits:');
  print('   • PDF: Maximum 32MB');
  print('   • Images: Maximum 5MB per image');
  print('   • Total conversation: Consider token limits');
  print('');

  print('🔍 File Validation:');
  print('```dart');
  print('Future<bool> validatePdfFile(File file) async {');
  print('  // Check file size');
  print('  final fileSize = await file.length();');
  print('  if (fileSize > 32 * 1024 * 1024) { // 32MB');
  print('    print("PDF file too large: \${fileSize / 1024 / 1024:.1f}MB");');
  print('    return false;');
  print('  }');
  print('');
  print('  // Check file extension');
  print('  if (!file.path.toLowerCase().endsWith(".pdf")) {');
  print('    print("File is not a PDF");');
  print('    return false;');
  print('  }');
  print('');
  print('  return true;');
  print('}');
  print('```');
  print('');

  print('⚡ Performance Tips:');
  print('   • Compress large PDFs before upload');
  print('   • Use specific prompts for better analysis');
  print('   • Consider breaking large documents into sections');
  print('   • Cache file bytes to avoid re-reading');
  print('');

  print('🎯 Effective Prompts:');
  print('   • "Summarize the key points in this document"');
  print('   • "Extract all dates and numbers from this PDF"');
  print('   • "What are the main conclusions in this research?"');
  print('   • "Create a bullet-point summary of each section"');
}

/// Demonstrates error handling for unsupported files
Future<void> errorHandlingExample(ChatCapability llm) async {
  print('⚠️ Error Handling for Unsupported Files');
  print('-' * 40);

  // Simulate trying to send an unsupported file type
  print('🧪 Testing unsupported file type...');
  
  // Create a simulated Word document message (which will be rejected)
  final messages = [
    ChatMessage.user(
      'What would happen if I tried to upload a Word document (.docx) to Claude?'
    ),
  ];

  final response = await llm.chat(messages);
  print('🤖 Claude\'s response about unsupported files:');
  print(response.text ?? 'No response');
  print('');

  print('💻 Error handling code example:');
  print('```dart');
  print('try {');
  print('  // This would show an error message for unsupported file');
  print('  final messages = [');
  print('    ChatMessage.file(');
  print('      role: ChatRole.user,');
  print('      mime: FileMime.docx, // Unsupported by Anthropic');
  print('      data: docxBytes,');
  print('      content: "Analyze this Word document",');
  print('    ),');
  print('  ];');
  print('');
  print('  final response = await llm.chat(messages);');
  print('  // Response will contain error message about unsupported format');
  print('  print(response.text);');
  print('');
  print('} catch (e) {');
  print('  print("Error processing file: \$e");');
  print('  // Handle the error appropriately');
  print('}');
  print('```');
  print('');

  print('✅ Recommended error handling:');
  print('   • Validate file types before sending');
  print('   • Provide clear error messages to users');
  print('   • Suggest alternative formats (PDF instead of Word)');
  print('   • Implement fallback strategies');
}
