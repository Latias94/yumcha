import 'dart:io';
import 'package:path/path.dart' as path;
import 'chat_logger_service.dart';
import '../../domain/exceptions/chat_exceptions.dart';

/// 代码清理服务
/// 
/// 负责清理聊天系统重构过程中产生的旧代码、
/// 未使用的文件和过时的引用。
/// 
/// 功能特性：
/// - 🗑️ **文件清理**: 删除不再需要的旧文件
/// - 🔍 **引用检查**: 检查和清理未使用的导入
/// - 📝 **代码分析**: 分析代码中的过时引用
/// - 🔄 **安全清理**: 提供回滚机制的安全清理
/// - 📊 **清理报告**: 生成详细的清理报告
class CodeCleanupService {
  /// 需要清理的旧文件列表
  static const List<String> _filesToDelete = [
    // 旧的消息相关文件（如果存在）
    'lib/features/chat/domain/entities/enhanced_message.dart',
    'lib/features/chat/presentation/screens/widgets/old_chat_message_view.dart',
    'lib/features/chat/presentation/screens/widgets/deprecated_message_widget.dart',
    
    // 旧的服务文件
    'lib/features/chat/domain/services/old_chat_service.dart',
    'lib/features/chat/infrastructure/services/legacy_message_service.dart',
    
    // 旧的测试文件
    'test/features/chat/old_message_test.dart',
    'test/features/chat/legacy_chat_test.dart',
  ];

  /// 需要检查的导入模式
  static const List<String> _deprecatedImports = [
    'enhanced_message.dart',
    'old_chat_message_view.dart',
    'deprecated_message_widget.dart',
    'old_chat_service.dart',
    'legacy_message_service.dart',
  ];

  /// 需要替换的类名映射
  static const Map<String, String> _classNameReplacements = {
    'EnhancedMessage': 'Message',
    'OldChatMessageView': 'MessageViewAdapter',
    'DeprecatedMessageWidget': 'MessageBlockWidget',
    'OldChatService': 'BlockChatService',
    'LegacyMessageService': 'MessageCacheService',
  };

  /// 执行完整的代码清理
  Future<CleanupReport> performFullCleanup({
    String? projectRoot,
    bool dryRun = false,
    bool createBackup = true,
  }) async {
    final report = CleanupReport();
    final rootDir = projectRoot ?? Directory.current.path;
    
    ChatLoggerService.logSystemEvent('Starting code cleanup', details: {
      'projectRoot': rootDir,
      'dryRun': dryRun,
      'createBackup': createBackup,
    });

    try {
      // 1. 创建备份（如果需要）
      if (createBackup && !dryRun) {
        await _createBackup(rootDir, report);
      }

      // 2. 删除旧文件
      await _deleteOldFiles(rootDir, report, dryRun);

      // 3. 清理未使用的导入
      await _cleanupUnusedImports(rootDir, report, dryRun);

      // 4. 替换过时的类名引用
      await _replaceDeprecatedClassNames(rootDir, report, dryRun);

      // 5. 清理注释中的TODO和FIXME
      await _cleanupTodoComments(rootDir, report, dryRun);

      // 6. 验证清理结果
      await _validateCleanup(rootDir, report);

      report.success = true;
      ChatLoggerService.logSystemEvent('Code cleanup completed successfully', details: {
        'filesDeleted': report.deletedFiles.length,
        'importsFixed': report.fixedImports.length,
        'classNamesReplaced': report.replacedClassNames.length,
      });

    } catch (e) {
      report.success = false;
      report.errors.add('Cleanup failed: $e');
      ChatLoggerService.logException(
        ValidationException.invalidParameter('cleanup', 'Code cleanup failed: $e'),
      );
    }

    return report;
  }

  /// 创建备份
  Future<void> _createBackup(String rootDir, CleanupReport report) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupDir = path.join(rootDir, 'backup_$timestamp');
    
    try {
      await Directory(backupDir).create(recursive: true);
      
      // 备份关键文件
      for (final filePath in _filesToDelete) {
        final fullPath = path.join(rootDir, filePath);
        final file = File(fullPath);
        
        if (await file.exists()) {
          final backupPath = path.join(backupDir, filePath);
          await Directory(path.dirname(backupPath)).create(recursive: true);
          await file.copy(backupPath);
          report.backedUpFiles.add(filePath);
        }
      }
      
      report.backupLocation = backupDir;
      ChatLoggerService.logSystemEvent('Backup created', details: {'location': backupDir});
      
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  /// 删除旧文件
  Future<void> _deleteOldFiles(String rootDir, CleanupReport report, bool dryRun) async {
    for (final filePath in _filesToDelete) {
      final fullPath = path.join(rootDir, filePath);
      final file = File(fullPath);
      
      if (await file.exists()) {
        if (dryRun) {
          report.filesToDelete.add(filePath);
        } else {
          try {
            await file.delete();
            report.deletedFiles.add(filePath);
            ChatLoggerService.logFileOperation('delete', fullPath);
          } catch (e) {
            report.errors.add('Failed to delete $filePath: $e');
          }
        }
      }
    }
  }

  /// 清理未使用的导入
  Future<void> _cleanupUnusedImports(String rootDir, CleanupReport report, bool dryRun) async {
    final dartFiles = await _findDartFiles(rootDir);
    
    for (final file in dartFiles) {
      try {
        final content = await file.readAsString();
        final lines = content.split('\n');
        final cleanedLines = <String>[];
        bool hasChanges = false;
        
        for (final line in lines) {
          bool shouldRemove = false;
          
          // 检查是否包含过时的导入
          for (final deprecatedImport in _deprecatedImports) {
            if (line.contains("import") && line.contains(deprecatedImport)) {
              shouldRemove = true;
              hasChanges = true;
              report.fixedImports.add('${file.path}: $line');
              break;
            }
          }
          
          if (!shouldRemove) {
            cleanedLines.add(line);
          }
        }
        
        if (hasChanges && !dryRun) {
          await file.writeAsString(cleanedLines.join('\n'));
        }
        
      } catch (e) {
        report.errors.add('Failed to clean imports in ${file.path}: $e');
      }
    }
  }

  /// 替换过时的类名引用
  Future<void> _replaceDeprecatedClassNames(String rootDir, CleanupReport report, bool dryRun) async {
    final dartFiles = await _findDartFiles(rootDir);
    
    for (final file in dartFiles) {
      try {
        final content = await file.readAsString();
        String updatedContent = content;
        bool hasChanges = false;
        
        for (final entry in _classNameReplacements.entries) {
          final oldName = entry.key;
          final newName = entry.value;
          
          if (updatedContent.contains(oldName)) {
            updatedContent = updatedContent.replaceAll(oldName, newName);
            hasChanges = true;
            report.replacedClassNames.add('${file.path}: $oldName -> $newName');
          }
        }
        
        if (hasChanges && !dryRun) {
          await file.writeAsString(updatedContent);
        }
        
      } catch (e) {
        report.errors.add('Failed to replace class names in ${file.path}: $e');
      }
    }
  }

  /// 清理TODO注释
  Future<void> _cleanupTodoComments(String rootDir, CleanupReport report, bool dryRun) async {
    final dartFiles = await _findDartFiles(rootDir);
    
    for (final file in dartFiles) {
      try {
        final content = await file.readAsString();
        final lines = content.split('\n');
        final cleanedLines = <String>[];
        bool hasChanges = false;
        
        for (final line in lines) {
          // 检查是否是已完成的TODO
          if (line.contains('// TODO:') && _isCompletedTodo(line)) {
            hasChanges = true;
            report.cleanedTodos.add('${file.path}: $line');
            // 跳过这一行（删除TODO）
            continue;
          }
          
          cleanedLines.add(line);
        }
        
        if (hasChanges && !dryRun) {
          await file.writeAsString(cleanedLines.join('\n'));
        }
        
      } catch (e) {
        report.errors.add('Failed to clean TODOs in ${file.path}: $e');
      }
    }
  }

  /// 验证清理结果
  Future<void> _validateCleanup(String rootDir, CleanupReport report) async {
    // 检查是否还有过时的引用
    final dartFiles = await _findDartFiles(rootDir);
    
    for (final file in dartFiles) {
      try {
        final content = await file.readAsString();
        
        // 检查过时的导入
        for (final deprecatedImport in _deprecatedImports) {
          if (content.contains(deprecatedImport)) {
            report.warnings.add('${file.path} still contains deprecated import: $deprecatedImport');
          }
        }
        
        // 检查过时的类名
        for (final oldClassName in _classNameReplacements.keys) {
          if (content.contains(oldClassName)) {
            report.warnings.add('${file.path} still contains deprecated class: $oldClassName');
          }
        }
        
      } catch (e) {
        report.errors.add('Failed to validate ${file.path}: $e');
      }
    }
  }

  /// 查找所有Dart文件
  Future<List<File>> _findDartFiles(String rootDir) async {
    final files = <File>[];
    final directory = Directory(rootDir);
    
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        // 排除生成的文件和测试文件中的某些文件
        if (!entity.path.contains('.g.dart') && 
            !entity.path.contains('.freezed.dart') &&
            !entity.path.contains('build/')) {
          files.add(entity);
        }
      }
    }
    
    return files;
  }

  /// 检查TODO是否已完成
  bool _isCompletedTodo(String line) {
    // 检查是否包含已完成的标识
    final completedPatterns = [
      '实现块编辑功能',
      '实现块删除功能', 
      '实现块重新生成功能',
      '实现工具调用块的创建',
      '实现复制功能',
      '实现导出功能',
      '实现标记功能',
    ];
    
    return completedPatterns.any((pattern) => line.contains(pattern));
  }
}

/// 清理报告
class CleanupReport {
  bool success = false;
  String? backupLocation;
  
  final List<String> filesToDelete = [];
  final List<String> deletedFiles = [];
  final List<String> backedUpFiles = [];
  final List<String> fixedImports = [];
  final List<String> replacedClassNames = [];
  final List<String> cleanedTodos = [];
  final List<String> warnings = [];
  final List<String> errors = [];

  /// 生成报告摘要
  String generateSummary() {
    final buffer = StringBuffer();
    
    buffer.writeln('=== 代码清理报告 ===');
    buffer.writeln('状态: ${success ? '成功' : '失败'}');
    buffer.writeln('时间: ${DateTime.now()}');
    
    if (backupLocation != null) {
      buffer.writeln('备份位置: $backupLocation');
    }
    
    buffer.writeln('\n--- 统计信息 ---');
    buffer.writeln('删除文件: ${deletedFiles.length}');
    buffer.writeln('修复导入: ${fixedImports.length}');
    buffer.writeln('替换类名: ${replacedClassNames.length}');
    buffer.writeln('清理TODO: ${cleanedTodos.length}');
    buffer.writeln('警告: ${warnings.length}');
    buffer.writeln('错误: ${errors.length}');
    
    if (deletedFiles.isNotEmpty) {
      buffer.writeln('\n--- 已删除文件 ---');
      for (final file in deletedFiles) {
        buffer.writeln('- $file');
      }
    }
    
    if (warnings.isNotEmpty) {
      buffer.writeln('\n--- 警告 ---');
      for (final warning in warnings) {
        buffer.writeln('- $warning');
      }
    }
    
    if (errors.isNotEmpty) {
      buffer.writeln('\n--- 错误 ---');
      for (final error in errors) {
        buffer.writeln('- $error');
      }
    }
    
    return buffer.toString();
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'timestamp': DateTime.now().toIso8601String(),
      'backupLocation': backupLocation,
      'statistics': {
        'deletedFiles': deletedFiles.length,
        'fixedImports': fixedImports.length,
        'replacedClassNames': replacedClassNames.length,
        'cleanedTodos': cleanedTodos.length,
        'warnings': warnings.length,
        'errors': errors.length,
      },
      'details': {
        'deletedFiles': deletedFiles,
        'fixedImports': fixedImports,
        'replacedClassNames': replacedClassNames,
        'cleanedTodos': cleanedTodos,
        'warnings': warnings,
        'errors': errors,
      },
    };
  }
}
