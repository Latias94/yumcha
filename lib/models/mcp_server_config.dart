/// MCP 服务器配置模型
class McpServerConfig {
  final String id;
  final String name;
  final String description;
  final McpServerType type;
  final String command;
  final List<String> args;
  final Map<String, String> env;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const McpServerConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.command,
    required this.args,
    required this.env,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 JSON 创建配置
  factory McpServerConfig.fromJson(Map<String, dynamic> json) {
    return McpServerConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      type: McpServerType.fromString(json['type'] as String),
      command: json['command'] as String,
      args: List<String>.from(json['args'] as List? ?? []),
      env: Map<String, String>.from(json['env'] as Map? ?? {}),
      isEnabled: json['isEnabled'] as bool? ?? true,
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
      'isEnabled': isEnabled,
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
    bool? isEnabled,
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
      isEnabled: isEnabled ?? this.isEnabled,
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
      isEnabled: isEnabled,
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

/// MCP 服务器类型
enum McpServerType {
  stdio,
  http,
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

/// MCP 服务器列表配置
class McpServersConfig {
  final List<McpServerConfig> servers;
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
