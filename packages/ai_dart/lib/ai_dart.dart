/// AI Dart Library - A modular Dart library for AI provider interactions
///
/// This library provides a unified interface for interacting with different
/// AI providers, starting with OpenAI. It's designed to be modular and
/// extensible, following the architecture of the Rust llm library.
library ai_dart;

// Core exports
export 'core/chat_provider.dart';
export 'core/llm_error.dart';

// Model exports
export 'models/chat_models.dart';
export 'models/tool_models.dart';

// Provider exports
export 'providers/openai_provider.dart';
export 'providers/anthropic_provider.dart';
export 'providers/google_provider.dart';
export 'providers/deepseek_provider.dart';
export 'providers/ollama_provider.dart';
export 'providers/xai_provider.dart';
export 'providers/phind_provider.dart';
export 'providers/groq_provider.dart';
export 'providers/elevenlabs_provider.dart';

// Builder exports
export 'builder/llm_builder.dart';
