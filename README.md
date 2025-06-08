# yumcha

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

An AI chat client Flutter application with MCP (Model Context Protocol) integration.

## 📦 Packages

This repository contains multiple packages:

### 📱 Flutter App

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

**[apps/yumcha](apps/yumcha/)** - The main Flutter application for AI chat.

> **Acknowledgments**: The UI design of this application is primarily inspired by [rikkahub](https://github.com/rikkahub/rikkahub) - A native Android LLM chat client that supports switching between different providers for conversations. We appreciate their excellent design and user experience contributions to the AI chat client community.

### 🤖 LLM Dart Library
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**[packages/llm_dart](packages/llm_dart/)** - A modular Dart library for AI provider interactions

- **Multi-provider support**: OpenAI, Anthropic, Google, DeepSeek, Ollama, xAI, Groq, ElevenLabs
- **Unified API**: Consistent interface across all providers
- **TTS/STT**: Text-to-Speech and Speech-to-Text with ElevenLabs
- **Streaming**: Real-time response streaming
- **Tool calling**: Function calling capabilities
- **Examples**: [Comprehensive examples and documentation](packages/llm_dart/examples/)


## 📄 Licenses

- **Flutter App** (main application): AGPL v3 License
- **LLM Dart Library** (`packages/llm_dart/`): MIT License

## 🚀 Getting Started

### Prerequisites

- Flutter 3.8.0+
- Dart 3.5.0+
- Melos (for monorepo management)

Install Melos globally:
```bash
dart pub global activate melos
```

### Installation

```bash
git clone https://github.com/Latias94/yumcha.git
cd yumcha
melos bootstrap
```

### Running the App
```bash
cd apps/yumcha
flutter run
```

## 📚 Documentation

- [LLM Dart Library Documentation](packages/llm_dart/)
- [LLM Dart Examples](packages/llm_dart/examples/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project uses dual licensing:
- The Flutter application is licensed under the AGPL v3 License
- The LLM Dart library is licensed under the MIT License

See the respective LICENSE files for details.
