import '../../data/database/database.dart';

/// 数据库服务 - 应用数据持久化的统一访问入口
///
/// DatabaseService是整个应用数据存储的门面服务，提供：
/// - 🏗️ **统一访问**: 为所有Repository提供统一的数据库访问入口
/// - 🔄 **连接管理**: 管理数据库连接的创建、复用和关闭
/// - 💾 **实例控制**: 确保全应用使用同一个数据库实例
/// - 🛡️ **资源管理**: 负责数据库资源的正确释放
///
/// ## 🏗️ 架构设计
///
/// ### 门面模式 (Facade Pattern)
/// 为复杂的Drift数据库操作提供简单的访问接口：
/// ```dart
/// final db = DatabaseService.instance.database;
/// ```
///
/// ### 单例模式
/// 确保全应用使用同一个数据库连接：
/// - 避免多个数据库实例
/// - 减少资源消耗
/// - 保证数据一致性
///
/// ### 懒加载
/// 数据库实例在首次访问时才创建：
/// - 减少应用启动时间
/// - 按需分配资源
/// - 支持异步初始化
///
/// ## 📊 底层数据库架构
///
/// 使用 **Drift ORM** 作为数据访问层：
/// - **数据库引擎**: SQLite
/// - **ORM框架**: Drift (原Moor)
/// - **数据库文件**: `yumcha.db`
/// - **当前版本**: 2
///
/// ### 核心数据表
/// - **providers**: AI提供商配置 (OpenAI, Anthropic等)
/// - **assistants**: AI助手配置 (系统提示、参数等)
/// - **conversations**: 对话元数据 (标题、时间等)
/// - **messages**: 聊天消息内容 (用户/AI消息)
/// - **favorite_models**: 收藏的AI模型
/// - **settings**: 应用设置和用户偏好
///
/// ## 🚀 使用示例
///
/// ### 获取数据库实例
/// ```dart
/// final dbService = DatabaseService.instance;
/// final db = dbService.database;
/// ```
///
/// ### 在Repository中使用
/// ```dart
/// class ConversationRepository {
///   final _db = DatabaseService.instance.database;
///
///   Future<List<ConversationData>> getAll() {
///     return _db.getAllConversations();
///   }
/// }
/// ```
///
/// ### 应用关闭时清理
/// ```dart
/// await DatabaseService.instance.close();
/// ```
///
/// ## ⚙️ 性能特性
/// - **连接池**: 自动管理数据库连接
/// - **索引优化**: 为常用查询创建索引
/// - **事务支持**: 支持ACID事务操作
/// - **迁移管理**: 自动处理数据库结构升级
///
/// ## 🔒 线程安全
/// - Drift ORM本身是线程安全的
/// - 单例模式确保实例唯一性
/// - 支持多个Repository并发访问
class DatabaseService {
  /// 单例实例
  static DatabaseService? _instance;

  /// 数据库实例
  ///
  /// 使用懒加载模式，在首次访问时创建。
  /// 整个应用生命周期中只会创建一个实例。
  static AppDatabase? _database;

  /// 私有构造函数，防止外部直接实例化
  DatabaseService._();

  /// 获取单例实例
  ///
  /// 使用懒加载模式创建单例实例。
  ///
  /// @returns DatabaseService的唯一实例
  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  /// 获取数据库实例
  ///
  /// 提供对底层AppDatabase的访问。AppDatabase包含了所有的
  /// 数据表操作方法和查询接口。
  ///
  /// ## 🎯 功能特性
  /// - **自动初始化**: 首次访问时自动创建数据库
  /// - **迁移管理**: 自动处理数据库版本升级
  /// - **索引优化**: 自动创建性能优化索引
  /// - **事务支持**: 支持复杂的事务操作
  ///
  /// @returns AppDatabase实例，包含所有数据操作方法
  ///
  /// ## 使用示例
  /// ```dart
  /// final db = DatabaseService.instance.database;
  ///
  /// // 查询所有对话
  /// final conversations = await db.getAllConversations();
  ///
  /// // 插入新消息
  /// await db.insertMessage(MessagesCompanion.insert(
  ///   id: messageId,
  ///   conversationId: conversationId,
  ///   content: content,
  ///   isFromUser: true,
  ///   timestamp: DateTime.now(),
  /// ));
  /// ```
  AppDatabase get database {
    _database ??= AppDatabase();
    return _database!;
  }

  /// 关闭数据库连接
  ///
  /// 正确关闭数据库连接并释放相关资源。应该在应用关闭时调用。
  ///
  /// ## 🧹 清理操作
  /// - 关闭数据库连接
  /// - 释放文件句柄
  /// - 清空实例缓存
  /// - 准备下次重新初始化
  ///
  /// ## ⚠️ 注意事项
  /// - 关闭后再次访问database会重新创建实例
  /// - 确保没有正在进行的数据库操作
  /// - 通常在应用退出时调用
  ///
  /// ## 使用示例
  /// ```dart
  /// // 应用关闭时
  /// @override
  /// void dispose() {
  ///   DatabaseService.instance.close();
  ///   super.dispose();
  /// }
  /// ```
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
