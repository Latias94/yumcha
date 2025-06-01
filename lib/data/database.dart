import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'converters.dart';

part 'database.g.dart';

// 定义数据库中的枚举类型
enum ProviderType { openai, anthropic, google, ollama, custom }

// 提供商表
@DataClassName('ProviderData')
class Providers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get type => intEnum<ProviderType>()(); // 存储枚举值
  TextColumn get apiKey => text()();
  TextColumn get baseUrl => text().nullable()();
  TextColumn get supportedModels =>
      text().map(const StringListConverter())(); // JSON string
  TextColumn get customHeaders =>
      text().map(const StringMapConverter())(); // JSON string
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// 助手表
@DataClassName('AssistantData')
class Assistants extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get avatar => text().withDefault(const Constant('🤖'))();
  TextColumn get systemPrompt => text()();
  TextColumn get providerId => text()();
  TextColumn get modelName => text()();

  // AI参数
  RealColumn get temperature => real().withDefault(const Constant(0.7))();
  RealColumn get topP => real().withDefault(const Constant(1.0))();
  IntColumn get maxTokens => integer().withDefault(const Constant(2048))();
  IntColumn get contextLength => integer().withDefault(const Constant(10))();
  BoolColumn get streamOutput => boolean().withDefault(const Constant(true))();
  RealColumn get frequencyPenalty => real().nullable()();
  RealColumn get presencePenalty => real().nullable()();

  // 自定义配置
  TextColumn get customHeaders => text()
      .map(const StringMapConverter())
      .withDefault(const Constant('{}'))(); // JSON string
  TextColumn get customBody => text()
      .map(const DynamicMapConverter())
      .withDefault(const Constant('{}'))(); // JSON string
  TextColumn get stopSequences => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))(); // JSON string

  // 功能设置
  BoolColumn get enableWebSearch =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get enableCodeExecution =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get enableImageGeneration =>
      boolean().withDefault(const Constant(false))();

  // 元数据
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Providers, Assistants])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // 提供商相关操作
  Future<List<ProviderData>> getAllProviders() => select(providers).get();

  Future<ProviderData?> getProvider(String id) =>
      (select(providers)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<int> insertProvider(ProvidersCompanion provider) =>
      into(providers).insert(provider);

  Future<bool> updateProvider(String id, ProvidersCompanion provider) async {
    final result = await (update(
      providers,
    )..where((p) => p.id.equals(id))).write(provider);
    return result > 0;
  }

  Future<int> deleteProvider(String id) =>
      (delete(providers)..where((p) => p.id.equals(id))).go();

  // 助手相关操作
  Future<List<AssistantData>> getAllAssistants() => select(assistants).get();

  Future<AssistantData?> getAssistant(String id) =>
      (select(assistants)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<int> insertAssistant(AssistantsCompanion assistant) =>
      into(assistants).insert(assistant);

  Future<bool> updateAssistant(String id, AssistantsCompanion assistant) async {
    final result = await (update(
      assistants,
    )..where((a) => a.id.equals(id))).write(assistant);
    return result > 0;
  }

  Future<int> deleteAssistant(String id) =>
      (delete(assistants)..where((a) => a.id.equals(id))).go();

  // 获取指定提供商的助手
  Future<List<AssistantData>> getAssistantsByProvider(String providerId) =>
      (select(assistants)..where((a) => a.providerId.equals(providerId))).get();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'yumcha.db'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    return NativeDatabase.createInBackground(file);
  });
}
