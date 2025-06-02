use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};
use anyhow::Result;
use std::collections::HashMap;

// Flutter Rust Bridge StreamSink
use crate::frb_generated::StreamSink;

// ===== 数据结构定义 =====

/// AI提供商类型
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum AiProvider {
    OpenAI,
    Anthropic,
    Cohere,
    Gemini,
    Groq,
    Ollama,
    Xai,
    DeepSeek,
    Custom { name: String },
}

/// 聊天消息角色
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ChatRole {
    System,
    User,
    Assistant,
}

/// 聊天消息内容
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChatMessage {
    pub role: ChatRole,
    pub content: String,
}

/// AI聊天配置选项
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AiChatOptions {
    /// 模型名称 (例如: "gpt-4", "claude-3-haiku-20240307")
    pub model: String,
    /// 自定义服务器地址 (可选)
    pub base_url: Option<String>,
    /// API密钥
    pub api_key: String,
    /// 温度参数 (0.0-2.0)
    pub temperature: Option<f64>,
    /// Top-p参数 (0.0-1.0)
    pub top_p: Option<f64>,
    /// 最大生成token数
    pub max_tokens: Option<u32>,
    /// 系统提示词
    pub system_prompt: Option<String>,
    /// 停止序列
    pub stop_sequences: Option<Vec<String>>,
}

/// 聊天响应
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChatResponse {
    pub content: String,
    pub model: String,
    pub usage: Option<TokenUsage>,
}

/// Token使用情况
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TokenUsage {
    pub prompt_tokens: Option<i32>,
    pub completion_tokens: Option<i32>,
    pub total_tokens: Option<i32>,
}

/// 流式聊天事件
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ChatStreamEvent {
    /// 开始流式响应
    Start,
    /// 内容块
    Content { content: String },
    /// 完成响应
    Done { 
        total_content: String,
        usage: Option<TokenUsage> 
    },
    /// 错误
    Error { message: String },
}

// ===== AI聊天接口实现 =====

/// 初始化AI聊天客户端
#[derive(Debug, Clone)]
pub struct AiChatClient {
    pub provider: AiProvider,
    pub options: AiChatOptions,
}

impl AiChatClient {
    /// 创建新的AI聊天客户端
    #[frb(sync)]
    pub fn new(provider: AiProvider, options: AiChatOptions) -> Self {
        Self { provider, options }
    }

    /// 获取支持的模型列表
    pub async fn get_available_models(&self) -> Result<Vec<String>> {
        let client = self.create_genai_client().await?;
        
        let adapter_kind = self.get_adapter_kind();
        let models = client.all_model_names(adapter_kind).await?;
        
        Ok(models)
    }

    /// 单次聊天 (非流式)
    pub async fn chat(&self, messages: Vec<ChatMessage>) -> Result<ChatResponse> {
        let client = self.create_genai_client().await?;
        let chat_req = self.build_chat_request(messages)?;
        let chat_options = self.build_chat_options();

        let chat_res = client
            .exec_chat(&self.options.model, chat_req, chat_options.as_ref())
            .await?;

        let content = chat_res
            .content_text_as_str()
            .unwrap_or("No response")
            .to_string();

        let usage = Some(TokenUsage {
            prompt_tokens: chat_res.usage.prompt_tokens,
            completion_tokens: chat_res.usage.completion_tokens,
            total_tokens: chat_res.usage.total_tokens,
        });

        Ok(ChatResponse {
            content,
            model: chat_res.model_iden.model_name.to_string(),
            usage,
        })
    }

    /// 流式聊天
    pub async fn chat_stream(
        &self,
        messages: Vec<ChatMessage>,
        sink: StreamSink<ChatStreamEvent>,
    ) -> Result<()> {
        let client = self.create_genai_client().await?;
        let chat_req = self.build_chat_request(messages)?;
        let chat_options = self.build_chat_options_for_stream();

        // 发送开始事件
        sink.add(ChatStreamEvent::Start);

        match client
            .exec_chat_stream(&self.options.model, chat_req, chat_options.as_ref())
            .await
        {
            Ok(mut stream_res) => {
                let mut total_content = String::new();
                
                // 使用 futures::StreamExt 来处理流
                use futures::StreamExt;
                
                while let Some(event) = stream_res.stream.next().await {
                    match event {
                        Ok(genai::chat::ChatStreamEvent::Start) => {
                            // 已经发送了开始事件，跳过
                        }
                        Ok(genai::chat::ChatStreamEvent::Chunk(chunk)) => {
                            total_content.push_str(&chunk.content);
                            sink.add(ChatStreamEvent::Content {
                                content: chunk.content,
                            });
                        }
                        Ok(genai::chat::ChatStreamEvent::End(end)) => {
                            let usage = end.captured_usage.map(|u| TokenUsage {
                                prompt_tokens: u.prompt_tokens,
                                completion_tokens: u.completion_tokens,
                                total_tokens: u.total_tokens,
                            });

                            sink.add(ChatStreamEvent::Done {
                                total_content,
                                usage,
                            });
                            break;
                        }
                        Ok(genai::chat::ChatStreamEvent::ReasoningChunk(_)) => {
                            // 推理内容暂时忽略
                        }
                        Err(e) => {
                            sink.add_error(anyhow::anyhow!("Stream error: {}", e));
                            break;
                        }
                    }
                }
            }
            Err(e) => {
                sink.add_error(anyhow::anyhow!("Chat stream error: {}", e));
            }
        }

        Ok(())
    }

    // ===== 私有辅助方法 =====

    /// 规范化 URL，确保结尾有斜杠
    fn normalize_base_url(url: &str) -> String {
        let trimmed = url.trim();
        if trimmed.is_empty() {
            return trimmed.to_string();
        }
        
        if trimmed.ends_with('/') {
            trimmed.to_string()
        } else {
            format!("{}/", trimmed)
        }
    }

    async fn create_genai_client(&self) -> Result<genai::Client> {
        use genai::resolver::{AuthData, Endpoint, ServiceTargetResolver};
        use genai::{Client, ServiceTarget};

        let mut client_builder = Client::builder();

        // 如果有自定义服务器地址，设置服务目标解析器
        if let Some(base_url) = &self.options.base_url {
            let api_key = self.options.api_key.clone();
            // 规范化 URL，确保结尾有斜杠
            let base_url = Self::normalize_base_url(base_url);
            let adapter_kind = self.get_adapter_kind();

            let target_resolver = ServiceTargetResolver::from_resolver_fn(
                move |service_target: ServiceTarget| -> Result<ServiceTarget, genai::resolver::Error> {
                    let ServiceTarget { model, .. } = service_target;
                    let endpoint = Endpoint::from_owned(base_url.clone());
                    let auth = AuthData::from_single(api_key.clone());
                    let model = genai::ModelIden::new(adapter_kind, model.model_name);
                    Ok(ServiceTarget { endpoint, auth, model })
                },
            );

            client_builder = client_builder.with_service_target_resolver(target_resolver);
        } else {
            // 使用默认配置，通过环境变量设置API密钥
            self.set_env_api_key();
        }

        Ok(client_builder.build())
    }

    fn get_adapter_kind(&self) -> genai::adapter::AdapterKind {
        match self.provider {
            AiProvider::OpenAI => genai::adapter::AdapterKind::OpenAI,
            AiProvider::Anthropic => genai::adapter::AdapterKind::Anthropic,
            AiProvider::Cohere => genai::adapter::AdapterKind::Cohere,
            AiProvider::Gemini => genai::adapter::AdapterKind::Gemini,
            AiProvider::Groq => genai::adapter::AdapterKind::Groq,
            AiProvider::Ollama => genai::adapter::AdapterKind::Ollama,
            AiProvider::Xai => genai::adapter::AdapterKind::Xai,
            AiProvider::DeepSeek => genai::adapter::AdapterKind::OpenAI, // DeepSeek使用OpenAI兼容接口
            AiProvider::Custom { .. } => genai::adapter::AdapterKind::OpenAI, // 默认使用OpenAI兼容
        }
    }

    fn set_env_api_key(&self) {
        let env_key = match self.provider {
            AiProvider::OpenAI => "OPENAI_API_KEY",
            AiProvider::Anthropic => "ANTHROPIC_API_KEY",
            AiProvider::Cohere => "COHERE_API_KEY",
            AiProvider::Gemini => "GEMINI_API_KEY",
            AiProvider::Groq => "GROQ_API_KEY",
            AiProvider::Ollama => "", // Ollama通常不需要API密钥
            AiProvider::Xai => "XAI_API_KEY",
            AiProvider::DeepSeek => "DEEPSEEK_API_KEY",
            AiProvider::Custom { .. } => "CUSTOM_API_KEY",
        };

        if !env_key.is_empty() {
            std::env::set_var(env_key, &self.options.api_key);
        }
    }

    fn build_chat_request(&self, messages: Vec<ChatMessage>) -> Result<genai::chat::ChatRequest> {
        let mut chat_req = genai::chat::ChatRequest::default();

        // 设置系统提示词
        if let Some(system_prompt) = &self.options.system_prompt {
            chat_req = chat_req.with_system(system_prompt);
        }

        // 添加消息
        for msg in messages {
            let genai_msg = match msg.role {
                ChatRole::System => genai::chat::ChatMessage::system(msg.content),
                ChatRole::User => genai::chat::ChatMessage::user(msg.content),
                ChatRole::Assistant => genai::chat::ChatMessage::assistant(msg.content),
            };
            chat_req = chat_req.append_message(genai_msg);
        }

        Ok(chat_req)
    }

    fn build_chat_options(&self) -> Option<genai::chat::ChatOptions> {
        let mut options = genai::chat::ChatOptions::default();
        let mut has_options = false;

        if let Some(temperature) = self.options.temperature {
            options = options.with_temperature(temperature);
            has_options = true;
        }

        if let Some(top_p) = self.options.top_p {
            options = options.with_top_p(top_p);
            has_options = true;
        }

        if let Some(max_tokens) = self.options.max_tokens {
            options = options.with_max_tokens(max_tokens);
            has_options = true;
        }

        if let Some(stop_sequences) = &self.options.stop_sequences {
            options = options.with_stop_sequences(stop_sequences.clone());
            has_options = true;
        }

        if has_options {
            Some(options)
        } else {
            None
        }
    }

    fn build_chat_options_for_stream(&self) -> Option<genai::chat::ChatOptions> {
        let mut options = self.build_chat_options().unwrap_or_default();
        
        // 流式聊天时启用内容和使用情况捕获
        options = options
            .with_capture_content(true)
            .with_capture_usage(true);

        Some(options)
    }
}

// ===== 便捷函数 =====

/// 创建AI聊天客户端
#[frb(sync)]
pub fn create_ai_chat_client(provider: AiProvider, options: AiChatOptions) -> AiChatClient {
    AiChatClient::new(provider, options)
}

/// 快速聊天 (使用默认配置)
pub async fn quick_chat(
    provider: AiProvider,
    model: String,
    api_key: String,
    message: String,
) -> Result<String> {
    let options = AiChatOptions {
        model,
        base_url: None,
        api_key,
        temperature: Some(0.7),
        top_p: None,
        max_tokens: None,
        system_prompt: None,
        stop_sequences: None,
    };

    let client = AiChatClient::new(provider, options);
    let messages = vec![ChatMessage {
        role: ChatRole::User,
        content: message,
    }];

    let response = client.chat(messages).await?;
    Ok(response.content)
}

/// 快速流式聊天
pub async fn quick_chat_stream(
    provider: AiProvider,
    model: String,
    api_key: String,
    message: String,
    sink: StreamSink<ChatStreamEvent>,
) -> Result<()> {
    let options = AiChatOptions {
        model,
        base_url: None,
        api_key,
        temperature: Some(0.7),
        top_p: None,
        max_tokens: None,
        system_prompt: None,
        stop_sequences: None,
    };

    let client = AiChatClient::new(provider, options);
    let messages = vec![ChatMessage {
        role: ChatRole::User,
        content: message,
    }];

    client.chat_stream(messages, sink).await
}

// ===== 简单的测试函数 =====

/// 简单的流式测试函数 - 发送一些测试数据
pub async fn test_stream(sink: StreamSink<ChatStreamEvent>) -> Result<()> {
    use tokio::time::{sleep, Duration};

    sink.add(ChatStreamEvent::Start);
    
    for i in 1..=5 {
        sleep(Duration::from_millis(500)).await;
        sink.add(ChatStreamEvent::Content {
            content: format!("Test chunk {}", i),
        });
    }
    
    sink.add(ChatStreamEvent::Done {
        total_content: "Test chunk 1Test chunk 2Test chunk 3Test chunk 4Test chunk 5".to_string(),
        usage: Some(TokenUsage {
            prompt_tokens: Some(10),
            completion_tokens: Some(20),
            total_tokens: Some(30),
        }),
    });

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_normalize_base_url() {
        // 测试已经有斜杠的URL
        assert_eq!(
            AiChatClient::normalize_base_url("https://api.openai.com/v1/"),
            "https://api.openai.com/v1/"
        );

        // 测试没有斜杠的URL
        assert_eq!(
            AiChatClient::normalize_base_url("https://api.openai.com/v1"),
            "https://api.openai.com/v1/"
        );

        // 测试有多余空格的URL
        assert_eq!(
            AiChatClient::normalize_base_url("  https://api.deepseek.com/v1  "),
            "https://api.deepseek.com/v1/"
        );

        // 测试空字符串
        assert_eq!(AiChatClient::normalize_base_url(""), "");

        // 测试只有空格的字符串
        assert_eq!(AiChatClient::normalize_base_url("   "), "");

        // 测试复杂的URL
        assert_eq!(
            AiChatClient::normalize_base_url("https://api.moonshot.cn/v1/chat/completions"),
            "https://api.moonshot.cn/v1/chat/completions/"
        );
    }
} 
