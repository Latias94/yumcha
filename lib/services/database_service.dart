import '../data/database.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static AppDatabase? _database;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  AppDatabase get database {
    _database ??= AppDatabase();
    return _database!;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
