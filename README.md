# yumcha

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

An AI chat client Flutter application with MCP (Model Context Protocol) integration.

## 📦 Packages

This repository contains multiple packages:

### 🤖 LLM Dart Library
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**[packages/llm_dart](packages/llm_dart/)** - A modular Dart library for AI provider interactions

- **Multi-provider support**: OpenAI, Anthropic, Google, DeepSeek, Ollama, xAI, Groq, ElevenLabs
- **Unified API**: Consistent interface across all providers
- **TTS/STT**: Text-to-Speech and Speech-to-Text with ElevenLabs
- **Streaming**: Real-time response streaming
- **Tool calling**: Function calling capabilities
- **Examples**: [Comprehensive examples and documentation](packages/llm_dart/examples/)

### 📱 Flutter App
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

The main Flutter application for AI chat with MCP integration.

## 📄 Licenses

- **LLM Dart Library** (`packages/llm_dart/`): MIT License
- **Flutter App** (main application): AGPL v3 License

## 🚀 Getting Started

### Prerequisites
- Flutter 3.8+
- Dart 3.0+

### Installation
```bash
git clone https://github.com/Latias94/yumcha.git
cd yumcha
flutter pub get
```

### Running the App
```bash
flutter run
```

## 📚 Documentation

- [LLM Dart Library Documentation](packages/llm_dart/)
- [LLM Dart Examples](packages/llm_dart/examples/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project uses dual licensing:
- The LLM Dart library is licensed under the MIT License
- The Flutter application is licensed under the AGPL v3 License

See the respective LICENSE files for details.
