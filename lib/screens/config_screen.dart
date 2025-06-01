import 'package:flutter/material.dart';
import 'providers_screen.dart';
import 'assistants_screen.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('配置管理')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 提供商管理
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.cloud, color: Colors.white),
              ),
              title: const Text(
                '提供商管理',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('管理AI服务提供商，配置API密钥和模型'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProvidersScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // 助手管理
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.smart_toy, color: Colors.white),
              ),
              title: const Text(
                '助手管理',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('创建和管理AI助手，配置角色和参数'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AssistantsScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),

          // 快速操作
          const Text(
            '快速操作',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProvidersScreen(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.add_circle, size: 32, color: Colors.blue),
                          SizedBox(height: 8),
                          Text(
                            '添加提供商',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AssistantsScreen(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.add_circle, size: 32, color: Colors.green),
                          SizedBox(height: 8),
                          Text(
                            '创建助手',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 使用说明
          Card(
            color: Colors.blue[50],
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        '使用说明',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '1. 首先添加AI服务提供商，配置API密钥\n'
                    '2. 然后创建助手，选择提供商和模型\n'
                    '3. 配置助手的角色、参数和功能\n'
                    '4. 在聊天中选择助手开始对话',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
