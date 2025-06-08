# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-6-8

### Added

- Initial release of LLM Dart library
- Multi-provider support for AI interactions
- Unified interface for OpenAI, Anthropic, Google, DeepSeek, Ollama, xAI, Phind, Groq, and ElevenLabs
- Builder pattern API for easy configuration
- Streaming support for real-time responses
- Tool calling capabilities for function execution
- Structured output with JSON schema support
- Comprehensive error handling with specific error types
- Provider registry system for extensibility
- Capability-based design for type safety

#### Supported Providers

- **OpenAI**: GPT models with reasoning support
- **Anthropic**: Claude models with thinking capabilities
- **Google**: Gemini models
- **DeepSeek**: DeepSeek reasoning models
- **Ollama**: Local model support
- **xAI**: Grok models
- **Phind**: Phind models
- **Groq**: Fast inference
- **ElevenLabs**: Text-to-Speech and Speech-to-Text

#### Features

- Chat completion with multiple providers
- Real-time streaming responses
- Function/tool calling
- Structured JSON output
- Provider-specific extensions
- Custom provider registration
- Comprehensive examples and documentation

#### Examples

- Basic usage examples for all providers
- Streaming examples
- Tool calling examples
- Custom provider implementation
- Advanced configuration examples
- ElevenLabs TTS/STT examples

### Technical Details

- Built with Dart 3.0+ support
- Flutter 3.8+ compatibility
- Uses Dio for HTTP requests
- Comprehensive error handling
- Type-safe interfaces
- Modular architecture

### Documentation

- Complete API documentation
- Extensive examples directory
- Setup and configuration guides
- Best practices documentation
- Provider-specific guides
