use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};
use anyhow::Result;

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

/// 提供商能力信息
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProviderCapabilities {
    /// 是否支持列出模型
    pub supports_list_models: bool,
    /// 是否支持自定义服务器地址
    pub supports_custom_base_url: bool,
    /// 提供商描述
    pub description: String,
}

/// 模型列表响应
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModelListResponse {
    /// 模型列表
    pub models: Vec<String>,
    /// 是否成功
    pub success: bool,
    /// 错误信息（如果有）
    pub error_message: Option<String>,
}

/// OpenAI API 模型对象（简化版，只关心我们需要的字段）
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OpenAiModel {
    pub id: String,
    #[serde(default)]
    pub object: Option<String>,
    #[serde(default)]
    pub created: Option<i64>,
    #[serde(default)]
    pub owned_by: Option<String>,
    // 忽略其他字段
}

/// OpenAI API 模型列表响应
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OpenAiModelsResponse {
    #[serde(default)]
    pub object: Option<String>,
    pub data: Vec<OpenAiModel>,
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

    /// 获取支持的模型列表（带错误处理）
    pub async fn get_available_models_safe(&self) -> ModelListResponse {
        // 对于支持 OpenAI 兼容接口的提供商，直接调用 API
        if self.supports_openai_compatible_api() {
            match self.fetch_models_from_openai_api().await {
                Ok(models) => ModelListResponse {
                    models,
                    success: true,
                    error_message: None,
                },
                Err(e) => ModelListResponse {
                    models: vec![],
                    success: false,
                    error_message: Some(format!("获取模型列表失败: {}", e)),
                },
            }
        } else {
            // 对于其他提供商，使用 genai crate 的静态列表
            match self.get_available_models().await {
                Ok(models) => ModelListResponse {
                    models,
                    success: true,
                    error_message: None,
                },
                Err(e) => ModelListResponse {
                    models: vec![],
                    success: false,
                    error_message: Some(format!("获取模型列表失败: {}", e)),
                },
            }
        }
    }

    /// 检查是否支持 OpenAI 兼容 API
    fn supports_openai_compatible_api(&self) -> bool {
        match self.provider {
            AiProvider::OpenAI => true,
            AiProvider::DeepSeek => true,
            AiProvider::Custom { .. } => true,
            _ => false,
        }
    }

    /// 从 OpenAI 兼容 API 获取模型列表
    async fn fetch_models_from_openai_api(&self) -> Result<Vec<String>> {
        let base_url = self.options.base_url
            .as_ref()
            .map(|url| Self::normalize_base_url(url))
            .unwrap_or_else(|| self.get_default_base_url());

        let url = format!("{}models", base_url);

        let client = reqwest::Client::new();
        let response = client
            .get(&url)
            .header("Authorization", format!("Bearer {}", self.options.api_key))
            .header("Content-Type", "application/json")
            .timeout(std::time::Duration::from_secs(30))
            .send()
            .await?;

        if !response.status().is_success() {
            return Err(anyhow::anyhow!(
                "HTTP 错误: {} - {}",
                response.status(),
                response.text().await.unwrap_or_default()
            ));
        }

        let models_response: OpenAiModelsResponse = response.json().await?;

        // 过滤掉非聊天模型
        let models: Vec<String> = models_response
            .data
            .into_iter()
            .map(|model| model.id)
            .filter(|model_id| self.should_include_model(model_id))
            .collect();

        Ok(models)
    }

    /// 获取默认的 base URL
    fn get_default_base_url(&self) -> String {
        match self.provider {
            AiProvider::OpenAI => "https://api.openai.com/v1/".to_string(),
            AiProvider::DeepSeek => "https://api.deepseek.com/v1/".to_string(),
            _ => "https://api.openai.com/v1/".to_string(),
        }
    }



    /// 判断是否应该包含该模型
    fn should_include_model(&self, model_id: &str) -> bool {
        let exclude_patterns = [
            "whisper", "tts", "dall-e", "embedding", "moderation",
            "babbage", "ada", "curie", "davinci",
        ];

        let lower_model_id = model_id.to_lowercase();
        !exclude_patterns.iter().any(|pattern| lower_model_id.contains(pattern))
    }

    /// 检查提供商是否支持列出模型
    #[frb(sync)]
    pub fn supports_list_models(&self) -> bool {
        match self.provider {
            AiProvider::OpenAI => true,
            AiProvider::Ollama => true,
            AiProvider::Anthropic => false, // Anthropic 不支持动态获取模型列表
            AiProvider::Cohere => false,
            AiProvider::Gemini => false,
            AiProvider::Groq => false,
            AiProvider::Xai => false,
            AiProvider::DeepSeek => true, // DeepSeek 使用 OpenAI 兼容接口
            AiProvider::Custom { .. } => true, // 自定义提供商假设支持 OpenAI 兼容接口
        }
    }

    /// 获取提供商能力信息
    #[frb(sync)]
    pub fn get_provider_capabilities(&self) -> ProviderCapabilities {
        match self.provider {
            AiProvider::OpenAI => ProviderCapabilities {
                supports_list_models: true,
                supports_custom_base_url: true,
                description: "OpenAI 官方 API，支持 GPT 系列模型".to_string(),
            },
            AiProvider::Anthropic => ProviderCapabilities {
                supports_list_models: false,
                supports_custom_base_url: false,
                description: "Anthropic Claude 系列模型，需要手动配置模型列表".to_string(),
            },
            AiProvider::Cohere => ProviderCapabilities {
                supports_list_models: false,
                supports_custom_base_url: false,
                description: "Cohere Command 系列模型，需要手动配置模型列表".to_string(),
            },
            AiProvider::Gemini => ProviderCapabilities {
                supports_list_models: false,
                supports_custom_base_url: false,
                description: "Google Gemini 系列模型，需要手动配置模型列表".to_string(),
            },
            AiProvider::Groq => ProviderCapabilities {
                supports_list_models: false,
                supports_custom_base_url: false,
                description: "Groq 高速推理平台，需要手动配置模型列表".to_string(),
            },
            AiProvider::Ollama => ProviderCapabilities {
                supports_list_models: true,
                supports_custom_base_url: true,
                description: "Ollama 本地模型服务，支持动态获取已安装的模型".to_string(),
            },
            AiProvider::Xai => ProviderCapabilities {
                supports_list_models: false,
                supports_custom_base_url: false,
                description: "xAI Grok 系列模型，需要手动配置模型列表".to_string(),
            },
            AiProvider::DeepSeek => ProviderCapabilities {
                supports_list_models: true,
                supports_custom_base_url: true,
                description: "DeepSeek 模型，使用 OpenAI 兼容接口".to_string(),
            },
            AiProvider::Custom { ref name } => ProviderCapabilities {
                supports_list_models: true,
                supports_custom_base_url: true,
                description: format!("自定义提供商: {}，假设支持 OpenAI 兼容接口", name),
            },
        }
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

/// 检查提供商是否支持列出模型
#[frb(sync)]
pub fn check_provider_supports_list_models(provider: AiProvider) -> bool {
    match provider {
        AiProvider::OpenAI => true,
        AiProvider::Ollama => true,
        AiProvider::Anthropic => false,
        AiProvider::Cohere => false,
        AiProvider::Gemini => false,
        AiProvider::Groq => false,
        AiProvider::Xai => false,
        AiProvider::DeepSeek => true,
        AiProvider::Custom { .. } => true,
    }
}

/// 获取提供商能力信息
#[frb(sync)]
pub fn get_provider_capabilities_info(provider: AiProvider) -> ProviderCapabilities {
    match provider {
        AiProvider::OpenAI => ProviderCapabilities {
            supports_list_models: true,
            supports_custom_base_url: true,
            description: "OpenAI 官方 API，支持 GPT 系列模型".to_string(),
        },
        AiProvider::Anthropic => ProviderCapabilities {
            supports_list_models: false,
            supports_custom_base_url: false,
            description: "Anthropic Claude 系列模型，需要手动配置模型列表".to_string(),
        },
        AiProvider::Cohere => ProviderCapabilities {
            supports_list_models: false,
            supports_custom_base_url: false,
            description: "Cohere Command 系列模型，需要手动配置模型列表".to_string(),
        },
        AiProvider::Gemini => ProviderCapabilities {
            supports_list_models: false,
            supports_custom_base_url: false,
            description: "Google Gemini 系列模型，需要手动配置模型列表".to_string(),
        },
        AiProvider::Groq => ProviderCapabilities {
            supports_list_models: false,
            supports_custom_base_url: false,
            description: "Groq 高速推理平台，需要手动配置模型列表".to_string(),
        },
        AiProvider::Ollama => ProviderCapabilities {
            supports_list_models: true,
            supports_custom_base_url: true,
            description: "Ollama 本地模型服务，支持动态获取已安装的模型".to_string(),
        },
        AiProvider::Xai => ProviderCapabilities {
            supports_list_models: false,
            supports_custom_base_url: false,
            description: "xAI Grok 系列模型，需要手动配置模型列表".to_string(),
        },
        AiProvider::DeepSeek => ProviderCapabilities {
            supports_list_models: true,
            supports_custom_base_url: true,
            description: "DeepSeek 模型，使用 OpenAI 兼容接口".to_string(),
        },
        AiProvider::Custom { ref name } => ProviderCapabilities {
            supports_list_models: true,
            supports_custom_base_url: true,
            description: format!("自定义提供商: {}，假设支持 OpenAI 兼容接口", name),
        },
    }
}

/// 快速获取模型列表（带错误处理）
pub async fn get_models_from_provider(
    provider: AiProvider,
    api_key: String,
    base_url: Option<String>,
) -> ModelListResponse {
    // 首先检查是否支持列出模型
    if !check_provider_supports_list_models(provider.clone()) {
        return ModelListResponse {
            models: vec![],
            success: false,
            error_message: Some("此提供商不支持动态获取模型列表，请手动添加模型".to_string()),
        };
    }

    let options = AiChatOptions {
        model: "dummy".to_string(), // 临时模型名，不会被使用
        base_url,
        api_key,
        temperature: None,
        top_p: None,
        max_tokens: None,
        system_prompt: None,
        stop_sequences: None,
    };

    let client = AiChatClient::new(provider, options);
    client.get_available_models_safe().await
}

/// 标准化 base URL，确保以斜杠结尾
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

/// 直接从 OpenAI 兼容 API 获取模型列表
pub async fn fetch_openai_compatible_models(
    api_key: String,
    base_url: String,
) -> ModelListResponse {
    // 使用更好的 URL 标准化逻辑
    let normalized_url = normalize_base_url(&base_url);
    let url = format!("{}models", normalized_url);

    let client = reqwest::Client::new();

    match client
        .get(&url)
        .header("Authorization", format!("Bearer {}", api_key))
        .header("Content-Type", "application/json")
        .timeout(std::time::Duration::from_secs(30))
        .send()
        .await
    {
        Ok(response) => {
            if !response.status().is_success() {
                let status = response.status();
                let error_text = response.text().await.unwrap_or_default();
                return ModelListResponse {
                    models: vec![],
                    success: false,
                    error_message: Some(format!("HTTP 错误 {}: {}", status, error_text)),
                };
            }

            match response.json::<OpenAiModelsResponse>().await {
                Ok(models_response) => {
                    let exclude_patterns = [
                        "whisper", "tts", "dall-e", "embedding", "moderation",
                        "babbage", "ada", "curie", "davinci",
                    ];

                    let models: Vec<String> = models_response
                        .data
                        .into_iter()
                        .map(|model| model.id)
                        .filter(|model_id| {
                            let lower_model_id = model_id.to_lowercase();
                            !exclude_patterns.iter().any(|pattern| lower_model_id.contains(pattern))
                        })
                        .collect();

                    ModelListResponse {
                        models,
                        success: true,
                        error_message: None,
                    }
                }
                Err(e) => ModelListResponse {
                    models: vec![],
                    success: false,
                    error_message: Some(format!("解析响应失败: {}", e)),
                },
            }
        }
        Err(e) => ModelListResponse {
            models: vec![],
            success: false,
            error_message: Some(format!("网络请求失败: {}", e)),
        },
    }
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
