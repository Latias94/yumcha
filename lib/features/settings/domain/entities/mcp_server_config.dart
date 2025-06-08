/// MCP 服务器配置数据模型
///
/// 表示 MCP (Model Context Protocol) 服务器的配置信息。
/// MCP 是一个开放协议，允许 AI 应用连接到外部工具和数据源。
///
/// 核心特性：
/// - 🔌 **多协议支持**: 支持 STDIO、HTTP、SSE 连接类型
/// - ⚙️ **命令配置**: 支持自定义启动命令和参数
/// - 🌐 **环境变量**: 支持自定义环境变量配置
/// - 📱 **平台适配**: 根据平台能力自动适配连接方式
/// - ✅ **启用控制**: 可以启用或禁用特定服务器
/// - 🔄 **序列化支持**: 支持 JSON 序列化和反序列化
/// - 🛠️ **工具管理**: 管理服务器提供的工具列表
///
/// 连接类型说明：
/// - **STDIO**: 本地进程通信（桌面平台）
/// - **HTTP**: HTTP API 连接（所有平台）
/// - **SSE**: 服务器发送事件（所有平台）
///
/// 使用场景：
/// - MCP 服务器的配置管理
/// - 外部工具和服务的集成
/// - AI 功能的扩展和增强
class McpServerConfig {
  /// 服务器唯一标识符
  final String id;

  /// 服务器名称
  final String name;

  /// 服务器描述
  final String description;

  /// 服务器连接类型
  final McpServerType type;

  /// 启动命令（STDIO类型）或服务器URL（HTTP/SSE类型）
  final String command;

  /// 命令参数列表（仅STDIO类型使用）
  final List<String> args;

  /// 环境变量配置
  final Map<String, String> env;

  /// 自定义HTTP头部（仅HTTP/SSE类型使用）
  final Map<String, String> headers;

  /// 是否启用此服务器
  final bool isEnabled;

  /// 服务器提供的工具列表
  final List<McpTool> tools;

  /// 创建时间
  final DateTime createdAt;

  /// 最后更新时间
  final DateTime updatedAt;

  const McpServerConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.command,
    required this.args,
    required this.env,
    required this.headers,
    required this.isEnabled,
    required this.tools,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 JSON 创建配置
  factory McpServerConfig.fromJson(Map<String, dynamic> json) {
    final toolsList = json['tools'] as List? ?? [];
    return McpServerConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      type: McpServerType.fromString(json['type'] as String),
      command: json['command'] as String,
      args: List<String>.from(json['args'] as List? ?? []),
      env: Map<String, String>.from(json['env'] as Map? ?? {}),
      headers: Map<String, String>.from(json['headers'] as Map? ?? {}),
      isEnabled: json['isEnabled'] as bool? ?? true,
      tools: toolsList
          .map((tool) => McpTool.fromJson(tool as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString(),
      'command': command,
      'args': args,
      'env': env,
      'headers': headers,
      'isEnabled': isEnabled,
      'tools': tools.map((tool) => tool.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 创建副本
  McpServerConfig copyWith({
    String? id,
    String? name,
    String? description,
    McpServerType? type,
    String? command,
    List<String>? args,
    Map<String, String>? env,
    Map<String, String>? headers,
    bool? isEnabled,
    List<McpTool>? tools,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return McpServerConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      command: command ?? this.command,
      args: args ?? this.args,
      env: env ?? this.env,
      headers: headers ?? this.headers,
      isEnabled: isEnabled ?? this.isEnabled,
      tools: tools ?? this.tools,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 创建新的服务器配置
  static McpServerConfig create({
    required String name,
    required String description,
    required McpServerType type,
    required String command,
    List<String>? args,
    Map<String, String>? env,
    Map<String, String>? headers,
    bool isEnabled = true,
  }) {
    final now = DateTime.now();
    return McpServerConfig(
      id: 'mcp_${now.millisecondsSinceEpoch}',
      name: name,
      description: description,
      type: type,
      command: command,
      args: args ?? [],
      env: env ?? {},
      headers: headers ?? {},
      isEnabled: isEnabled,
      tools: [],
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  String toString() {
    return 'McpServerConfig(id: $id, name: $name, type: $type, enabled: $isEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is McpServerConfig && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// MCP 服务器连接类型枚举
///
/// 定义 MCP 服务器支持的连接方式，不同类型适用于不同的部署场景。
///
/// 连接类型说明：
/// - **STDIO**: 标准输入输出，适用于本地进程通信
/// - **HTTP**: HTTP API 接口，适用于远程服务调用
/// - **SSE**: 服务器发送事件，适用于实时数据推送
enum McpServerType {
  /// 标准输入输出连接（本地进程）
  stdio,

  /// HTTP API 连接（远程服务）
  http,

  /// 服务器发送事件连接（实时推送）
  sse;

  /// 从字符串创建类型
  static McpServerType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'stdio':
        return McpServerType.stdio;
      case 'http':
        return McpServerType.http;
      case 'sse':
        return McpServerType.sse;
      default:
        return McpServerType.stdio;
    }
  }

  /// 转换为字符串
  @override
  String toString() {
    switch (this) {
      case McpServerType.stdio:
        return 'stdio';
      case McpServerType.http:
        return 'http';
      case McpServerType.sse:
        return 'sse';
    }
  }

  /// 获取显示名称
  String get displayName {
    switch (this) {
      case McpServerType.stdio:
        return 'Standard I/O';
      case McpServerType.http:
        return 'HTTP';
      case McpServerType.sse:
        return 'Server-Sent Events';
    }
  }
}

/// MCP 服务器列表配置数据模型
///
/// 管理多个 MCP 服务器的配置集合，提供统一的服务器管理功能。
///
/// 核心功能：
/// - 📋 **服务器列表**: 管理多个 MCP 服务器配置
/// - 🔍 **查找功能**: 按 ID 查找特定服务器
/// - ✅ **筛选功能**: 获取启用的服务器列表
/// - ➕ **增删改**: 支持服务器的增加、删除、更新操作
/// - 🔄 **序列化**: 支持整体配置的序列化和反序列化
///
/// 使用场景：
/// - MCP 服务器的批量管理
/// - 配置的导入导出
/// - 服务器状态的统一控制
class McpServersConfig {
  /// MCP 服务器配置列表
  final List<McpServerConfig> servers;

  /// 配置最后更新时间
  final DateTime updatedAt;

  const McpServersConfig({required this.servers, required this.updatedAt});

  /// 从 JSON 创建配置
  factory McpServersConfig.fromJson(Map<String, dynamic> json) {
    final serversList = json['servers'] as List? ?? [];
    return McpServersConfig(
      servers: serversList
          .map(
            (server) =>
                McpServerConfig.fromJson(server as Map<String, dynamic>),
          )
          .toList(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'servers': servers.map((server) => server.toJson()).toList(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 创建副本
  McpServersConfig copyWith({
    List<McpServerConfig>? servers,
    DateTime? updatedAt,
  }) {
    return McpServersConfig(
      servers: servers ?? this.servers,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 创建空配置
  static McpServersConfig empty() {
    return McpServersConfig(servers: [], updatedAt: DateTime.now());
  }

  /// 获取启用的服务器
  List<McpServerConfig> get enabledServers {
    return servers.where((server) => server.isEnabled).toList();
  }

  /// 根据 ID 查找服务器
  McpServerConfig? findById(String id) {
    try {
      return servers.firstWhere((server) => server.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 添加服务器
  McpServersConfig addServer(McpServerConfig server) {
    final updatedServers = List<McpServerConfig>.from(servers);
    updatedServers.add(server);
    return copyWith(servers: updatedServers, updatedAt: DateTime.now());
  }

  /// 更新服务器
  McpServersConfig updateServer(McpServerConfig server) {
    final updatedServers = servers.map((s) {
      return s.id == server.id ? server : s;
    }).toList();
    return copyWith(servers: updatedServers, updatedAt: DateTime.now());
  }

  /// 删除服务器
  McpServersConfig removeServer(String id) {
    final updatedServers = servers.where((s) => s.id != id).toList();
    return copyWith(servers: updatedServers, updatedAt: DateTime.now());
  }

  @override
  String toString() {
    return 'McpServersConfig(servers: ${servers.length}, updatedAt: $updatedAt)';
  }
}

/// MCP 工具配置数据模型
///
/// 表示 MCP 服务器提供的工具信息。
///
/// 核心特性：
/// - 🛠️ **工具信息**: 工具名称、描述、输入模式
/// - ✅ **启用控制**: 可以启用或禁用特定工具
/// - 📋 **参数定义**: 支持工具参数的结构化定义
/// - 🔄 **序列化支持**: 支持 JSON 序列化和反序列化
class McpTool {
  /// 工具名称
  final String name;

  /// 工具描述
  final String? description;

  /// 是否启用此工具
  final bool isEnabled;

  /// 工具输入参数模式
  final Map<String, dynamic>? inputSchema;

  const McpTool({
    required this.name,
    this.description,
    this.isEnabled = true,
    this.inputSchema,
  });

  /// 从 JSON 创建工具配置
  factory McpTool.fromJson(Map<String, dynamic> json) {
    return McpTool(
      name: json['name'] as String,
      description: json['description'] as String?,
      isEnabled: json['isEnabled'] as bool? ?? true,
      inputSchema: json['inputSchema'] as Map<String, dynamic>?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'isEnabled': isEnabled,
      'inputSchema': inputSchema,
    };
  }

  /// 创建副本
  McpTool copyWith({
    String? name,
    String? description,
    bool? isEnabled,
    Map<String, dynamic>? inputSchema,
  }) {
    return McpTool(
      name: name ?? this.name,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      inputSchema: inputSchema ?? this.inputSchema,
    );
  }

  @override
  String toString() {
    return 'McpTool(name: $name, enabled: $isEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is McpTool && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

/// MCP 服务器状态枚举
///
/// 表示 MCP 服务器的连接状态。
enum McpServerStatus {
  /// 未连接
  disconnected,

  /// 连接中
  connecting,

  /// 已连接
  connected,

  /// 连接错误
  error;

  /// 获取状态显示名称
  String get displayName {
    switch (this) {
      case McpServerStatus.disconnected:
        return '未连接';
      case McpServerStatus.connecting:
        return '连接中';
      case McpServerStatus.connected:
        return '已连接';
      case McpServerStatus.error:
        return '连接失败';
    }
  }
}
