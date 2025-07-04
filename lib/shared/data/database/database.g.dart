// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProvidersTable extends Providers
    with TableInfo<$ProvidersTable, ProviderData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProvidersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<ProviderType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ProviderType>($ProvidersTable.$convertertype);
  static const VerificationMeta _apiKeyMeta = const VerificationMeta('apiKey');
  @override
  late final GeneratedColumn<String> apiKey = GeneratedColumn<String>(
      'api_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _baseUrlMeta =
      const VerificationMeta('baseUrl');
  @override
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
      'base_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<AiModel>, String> models =
      GeneratedColumn<String>('models', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<AiModel>>($ProvidersTable.$convertermodels);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
      customHeaders = GeneratedColumn<String>(
              'custom_headers', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Map<String, String>>(
              $ProvidersTable.$convertercustomHeaders);
  static const VerificationMeta _isEnabledMeta =
      const VerificationMeta('isEnabled');
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
      'is_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        type,
        apiKey,
        baseUrl,
        models,
        customHeaders,
        isEnabled,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'providers';
  @override
  VerificationContext validateIntegrity(Insertable<ProviderData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('api_key')) {
      context.handle(_apiKeyMeta,
          apiKey.isAcceptableOrUnknown(data['api_key']!, _apiKeyMeta));
    } else if (isInserting) {
      context.missing(_apiKeyMeta);
    }
    if (data.containsKey('base_url')) {
      context.handle(_baseUrlMeta,
          baseUrl.isAcceptableOrUnknown(data['base_url']!, _baseUrlMeta));
    }
    if (data.containsKey('is_enabled')) {
      context.handle(_isEnabledMeta,
          isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProviderData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProviderData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: $ProvidersTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      apiKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}api_key'])!,
      baseUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}base_url']),
      models: $ProvidersTable.$convertermodels.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}models'])!),
      customHeaders: $ProvidersTable.$convertercustomHeaders.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}custom_headers'])!),
      isEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_enabled'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ProvidersTable createAlias(String alias) {
    return $ProvidersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ProviderType, int, int> $convertertype =
      const EnumIndexConverter<ProviderType>(ProviderType.values);
  static TypeConverter<List<AiModel>, String> $convertermodels =
      const ModelListConverter();
  static TypeConverter<Map<String, String>, String> $convertercustomHeaders =
      const StringMapConverter();
}

class ProviderData extends DataClass implements Insertable<ProviderData> {
  final String id;
  final String name;
  final ProviderType type;
  final String apiKey;
  final String? baseUrl;
  final List<AiModel> models;
  final Map<String, String> customHeaders;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProviderData(
      {required this.id,
      required this.name,
      required this.type,
      required this.apiKey,
      this.baseUrl,
      required this.models,
      required this.customHeaders,
      required this.isEnabled,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<int>($ProvidersTable.$convertertype.toSql(type));
    }
    map['api_key'] = Variable<String>(apiKey);
    if (!nullToAbsent || baseUrl != null) {
      map['base_url'] = Variable<String>(baseUrl);
    }
    {
      map['models'] =
          Variable<String>($ProvidersTable.$convertermodels.toSql(models));
    }
    {
      map['custom_headers'] = Variable<String>(
          $ProvidersTable.$convertercustomHeaders.toSql(customHeaders));
    }
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProvidersCompanion toCompanion(bool nullToAbsent) {
    return ProvidersCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      apiKey: Value(apiKey),
      baseUrl: baseUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(baseUrl),
      models: Value(models),
      customHeaders: Value(customHeaders),
      isEnabled: Value(isEnabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProviderData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProviderData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: $ProvidersTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      apiKey: serializer.fromJson<String>(json['apiKey']),
      baseUrl: serializer.fromJson<String?>(json['baseUrl']),
      models: serializer.fromJson<List<AiModel>>(json['models']),
      customHeaders:
          serializer.fromJson<Map<String, String>>(json['customHeaders']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type':
          serializer.toJson<int>($ProvidersTable.$convertertype.toJson(type)),
      'apiKey': serializer.toJson<String>(apiKey),
      'baseUrl': serializer.toJson<String?>(baseUrl),
      'models': serializer.toJson<List<AiModel>>(models),
      'customHeaders': serializer.toJson<Map<String, String>>(customHeaders),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProviderData copyWith(
          {String? id,
          String? name,
          ProviderType? type,
          String? apiKey,
          Value<String?> baseUrl = const Value.absent(),
          List<AiModel>? models,
          Map<String, String>? customHeaders,
          bool? isEnabled,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ProviderData(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        apiKey: apiKey ?? this.apiKey,
        baseUrl: baseUrl.present ? baseUrl.value : this.baseUrl,
        models: models ?? this.models,
        customHeaders: customHeaders ?? this.customHeaders,
        isEnabled: isEnabled ?? this.isEnabled,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ProviderData copyWithCompanion(ProvidersCompanion data) {
    return ProviderData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      apiKey: data.apiKey.present ? data.apiKey.value : this.apiKey,
      baseUrl: data.baseUrl.present ? data.baseUrl.value : this.baseUrl,
      models: data.models.present ? data.models.value : this.models,
      customHeaders: data.customHeaders.present
          ? data.customHeaders.value
          : this.customHeaders,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProviderData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('apiKey: $apiKey, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('models: $models, ')
          ..write('customHeaders: $customHeaders, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, apiKey, baseUrl, models,
      customHeaders, isEnabled, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProviderData &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.apiKey == this.apiKey &&
          other.baseUrl == this.baseUrl &&
          other.models == this.models &&
          other.customHeaders == this.customHeaders &&
          other.isEnabled == this.isEnabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProvidersCompanion extends UpdateCompanion<ProviderData> {
  final Value<String> id;
  final Value<String> name;
  final Value<ProviderType> type;
  final Value<String> apiKey;
  final Value<String?> baseUrl;
  final Value<List<AiModel>> models;
  final Value<Map<String, String>> customHeaders;
  final Value<bool> isEnabled;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProvidersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.apiKey = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.models = const Value.absent(),
    this.customHeaders = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProvidersCompanion.insert({
    required String id,
    required String name,
    required ProviderType type,
    required String apiKey,
    this.baseUrl = const Value.absent(),
    this.models = const Value.absent(),
    required Map<String, String> customHeaders,
    this.isEnabled = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        type = Value(type),
        apiKey = Value(apiKey),
        customHeaders = Value(customHeaders),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ProviderData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? type,
    Expression<String>? apiKey,
    Expression<String>? baseUrl,
    Expression<String>? models,
    Expression<String>? customHeaders,
    Expression<bool>? isEnabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (apiKey != null) 'api_key': apiKey,
      if (baseUrl != null) 'base_url': baseUrl,
      if (models != null) 'models': models,
      if (customHeaders != null) 'custom_headers': customHeaders,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProvidersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<ProviderType>? type,
      Value<String>? apiKey,
      Value<String?>? baseUrl,
      Value<List<AiModel>>? models,
      Value<Map<String, String>>? customHeaders,
      Value<bool>? isEnabled,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ProvidersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      models: models ?? this.models,
      customHeaders: customHeaders ?? this.customHeaders,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] =
          Variable<int>($ProvidersTable.$convertertype.toSql(type.value));
    }
    if (apiKey.present) {
      map['api_key'] = Variable<String>(apiKey.value);
    }
    if (baseUrl.present) {
      map['base_url'] = Variable<String>(baseUrl.value);
    }
    if (models.present) {
      map['models'] = Variable<String>(
          $ProvidersTable.$convertermodels.toSql(models.value));
    }
    if (customHeaders.present) {
      map['custom_headers'] = Variable<String>(
          $ProvidersTable.$convertercustomHeaders.toSql(customHeaders.value));
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProvidersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('apiKey: $apiKey, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('models: $models, ')
          ..write('customHeaders: $customHeaders, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssistantsTable extends Assistants
    with TableInfo<$AssistantsTable, AssistantData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssistantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
      'avatar', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('🤖'));
  static const VerificationMeta _systemPromptMeta =
      const VerificationMeta('systemPrompt');
  @override
  late final GeneratedColumn<String> systemPrompt = GeneratedColumn<String>(
      'system_prompt', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _temperatureMeta =
      const VerificationMeta('temperature');
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
      'temperature', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.7));
  static const VerificationMeta _topPMeta = const VerificationMeta('topP');
  @override
  late final GeneratedColumn<double> topP = GeneratedColumn<double>(
      'top_p', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _maxTokensMeta =
      const VerificationMeta('maxTokens');
  @override
  late final GeneratedColumn<int> maxTokens = GeneratedColumn<int>(
      'max_tokens', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(2048));
  static const VerificationMeta _contextLengthMeta =
      const VerificationMeta('contextLength');
  @override
  late final GeneratedColumn<int> contextLength = GeneratedColumn<int>(
      'context_length', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(10));
  static const VerificationMeta _streamOutputMeta =
      const VerificationMeta('streamOutput');
  @override
  late final GeneratedColumn<bool> streamOutput = GeneratedColumn<bool>(
      'stream_output', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("stream_output" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _frequencyPenaltyMeta =
      const VerificationMeta('frequencyPenalty');
  @override
  late final GeneratedColumn<double> frequencyPenalty = GeneratedColumn<double>(
      'frequency_penalty', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _presencePenaltyMeta =
      const VerificationMeta('presencePenalty');
  @override
  late final GeneratedColumn<double> presencePenalty = GeneratedColumn<double>(
      'presence_penalty', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
      customHeaders = GeneratedColumn<String>(
              'custom_headers', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('{}'))
          .withConverter<Map<String, String>>(
              $AssistantsTable.$convertercustomHeaders);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
      customBody = GeneratedColumn<String>('custom_body', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('{}'))
          .withConverter<Map<String, dynamic>>(
              $AssistantsTable.$convertercustomBody);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
      stopSequences = GeneratedColumn<String>(
              'stop_sequences', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>(
              $AssistantsTable.$converterstopSequences);
  static const VerificationMeta _enableCodeExecutionMeta =
      const VerificationMeta('enableCodeExecution');
  @override
  late final GeneratedColumn<bool> enableCodeExecution = GeneratedColumn<bool>(
      'enable_code_execution', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("enable_code_execution" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _enableImageGenerationMeta =
      const VerificationMeta('enableImageGeneration');
  @override
  late final GeneratedColumn<bool> enableImageGeneration =
      GeneratedColumn<bool>('enable_image_generation', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("enable_image_generation" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _enableToolsMeta =
      const VerificationMeta('enableTools');
  @override
  late final GeneratedColumn<bool> enableTools = GeneratedColumn<bool>(
      'enable_tools', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("enable_tools" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _enableReasoningMeta =
      const VerificationMeta('enableReasoning');
  @override
  late final GeneratedColumn<bool> enableReasoning = GeneratedColumn<bool>(
      'enable_reasoning', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("enable_reasoning" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _enableVisionMeta =
      const VerificationMeta('enableVision');
  @override
  late final GeneratedColumn<bool> enableVision = GeneratedColumn<bool>(
      'enable_vision', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("enable_vision" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _enableEmbeddingMeta =
      const VerificationMeta('enableEmbedding');
  @override
  late final GeneratedColumn<bool> enableEmbedding = GeneratedColumn<bool>(
      'enable_embedding', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("enable_embedding" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
      mcpServerIds = GeneratedColumn<String>(
              'mcp_server_ids', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>($AssistantsTable.$convertermcpServerIds);
  static const VerificationMeta _isEnabledMeta =
      const VerificationMeta('isEnabled');
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
      'is_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        avatar,
        systemPrompt,
        temperature,
        topP,
        maxTokens,
        contextLength,
        streamOutput,
        frequencyPenalty,
        presencePenalty,
        customHeaders,
        customBody,
        stopSequences,
        enableCodeExecution,
        enableImageGeneration,
        enableTools,
        enableReasoning,
        enableVision,
        enableEmbedding,
        mcpServerIds,
        isEnabled,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assistants';
  @override
  VerificationContext validateIntegrity(Insertable<AssistantData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(_avatarMeta,
          avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta));
    }
    if (data.containsKey('system_prompt')) {
      context.handle(
          _systemPromptMeta,
          systemPrompt.isAcceptableOrUnknown(
              data['system_prompt']!, _systemPromptMeta));
    } else if (isInserting) {
      context.missing(_systemPromptMeta);
    }
    if (data.containsKey('temperature')) {
      context.handle(
          _temperatureMeta,
          temperature.isAcceptableOrUnknown(
              data['temperature']!, _temperatureMeta));
    }
    if (data.containsKey('top_p')) {
      context.handle(
          _topPMeta, topP.isAcceptableOrUnknown(data['top_p']!, _topPMeta));
    }
    if (data.containsKey('max_tokens')) {
      context.handle(_maxTokensMeta,
          maxTokens.isAcceptableOrUnknown(data['max_tokens']!, _maxTokensMeta));
    }
    if (data.containsKey('context_length')) {
      context.handle(
          _contextLengthMeta,
          contextLength.isAcceptableOrUnknown(
              data['context_length']!, _contextLengthMeta));
    }
    if (data.containsKey('stream_output')) {
      context.handle(
          _streamOutputMeta,
          streamOutput.isAcceptableOrUnknown(
              data['stream_output']!, _streamOutputMeta));
    }
    if (data.containsKey('frequency_penalty')) {
      context.handle(
          _frequencyPenaltyMeta,
          frequencyPenalty.isAcceptableOrUnknown(
              data['frequency_penalty']!, _frequencyPenaltyMeta));
    }
    if (data.containsKey('presence_penalty')) {
      context.handle(
          _presencePenaltyMeta,
          presencePenalty.isAcceptableOrUnknown(
              data['presence_penalty']!, _presencePenaltyMeta));
    }
    if (data.containsKey('enable_code_execution')) {
      context.handle(
          _enableCodeExecutionMeta,
          enableCodeExecution.isAcceptableOrUnknown(
              data['enable_code_execution']!, _enableCodeExecutionMeta));
    }
    if (data.containsKey('enable_image_generation')) {
      context.handle(
          _enableImageGenerationMeta,
          enableImageGeneration.isAcceptableOrUnknown(
              data['enable_image_generation']!, _enableImageGenerationMeta));
    }
    if (data.containsKey('enable_tools')) {
      context.handle(
          _enableToolsMeta,
          enableTools.isAcceptableOrUnknown(
              data['enable_tools']!, _enableToolsMeta));
    }
    if (data.containsKey('enable_reasoning')) {
      context.handle(
          _enableReasoningMeta,
          enableReasoning.isAcceptableOrUnknown(
              data['enable_reasoning']!, _enableReasoningMeta));
    }
    if (data.containsKey('enable_vision')) {
      context.handle(
          _enableVisionMeta,
          enableVision.isAcceptableOrUnknown(
              data['enable_vision']!, _enableVisionMeta));
    }
    if (data.containsKey('enable_embedding')) {
      context.handle(
          _enableEmbeddingMeta,
          enableEmbedding.isAcceptableOrUnknown(
              data['enable_embedding']!, _enableEmbeddingMeta));
    }
    if (data.containsKey('is_enabled')) {
      context.handle(_isEnabledMeta,
          isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssistantData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssistantData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      avatar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar'])!,
      systemPrompt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}system_prompt'])!,
      temperature: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}temperature'])!,
      topP: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}top_p'])!,
      maxTokens: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_tokens'])!,
      contextLength: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}context_length'])!,
      streamOutput: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}stream_output'])!,
      frequencyPenalty: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}frequency_penalty']),
      presencePenalty: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}presence_penalty']),
      customHeaders: $AssistantsTable.$convertercustomHeaders.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}custom_headers'])!),
      customBody: $AssistantsTable.$convertercustomBody.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}custom_body'])!),
      stopSequences: $AssistantsTable.$converterstopSequences.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}stop_sequences'])!),
      enableCodeExecution: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}enable_code_execution'])!,
      enableImageGeneration: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}enable_image_generation'])!,
      enableTools: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enable_tools'])!,
      enableReasoning: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enable_reasoning'])!,
      enableVision: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enable_vision'])!,
      enableEmbedding: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enable_embedding'])!,
      mcpServerIds: $AssistantsTable.$convertermcpServerIds.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}mcp_server_ids'])!),
      isEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_enabled'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AssistantsTable createAlias(String alias) {
    return $AssistantsTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, String>, String> $convertercustomHeaders =
      const StringMapConverter();
  static TypeConverter<Map<String, dynamic>, String> $convertercustomBody =
      const DynamicMapConverter();
  static TypeConverter<List<String>, String> $converterstopSequences =
      const StringListConverter();
  static TypeConverter<List<String>, String> $convertermcpServerIds =
      const StringListConverter();
}

class AssistantData extends DataClass implements Insertable<AssistantData> {
  final String id;
  final String name;
  final String description;
  final String avatar;
  final String systemPrompt;
  final double temperature;
  final double topP;
  final int maxTokens;
  final int contextLength;
  final bool streamOutput;
  final double? frequencyPenalty;
  final double? presencePenalty;
  final Map<String, String> customHeaders;
  final Map<String, dynamic> customBody;
  final List<String> stopSequences;
  final bool enableCodeExecution;
  final bool enableImageGeneration;
  final bool enableTools;
  final bool enableReasoning;
  final bool enableVision;
  final bool enableEmbedding;
  final List<String> mcpServerIds;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AssistantData(
      {required this.id,
      required this.name,
      required this.description,
      required this.avatar,
      required this.systemPrompt,
      required this.temperature,
      required this.topP,
      required this.maxTokens,
      required this.contextLength,
      required this.streamOutput,
      this.frequencyPenalty,
      this.presencePenalty,
      required this.customHeaders,
      required this.customBody,
      required this.stopSequences,
      required this.enableCodeExecution,
      required this.enableImageGeneration,
      required this.enableTools,
      required this.enableReasoning,
      required this.enableVision,
      required this.enableEmbedding,
      required this.mcpServerIds,
      required this.isEnabled,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['avatar'] = Variable<String>(avatar);
    map['system_prompt'] = Variable<String>(systemPrompt);
    map['temperature'] = Variable<double>(temperature);
    map['top_p'] = Variable<double>(topP);
    map['max_tokens'] = Variable<int>(maxTokens);
    map['context_length'] = Variable<int>(contextLength);
    map['stream_output'] = Variable<bool>(streamOutput);
    if (!nullToAbsent || frequencyPenalty != null) {
      map['frequency_penalty'] = Variable<double>(frequencyPenalty);
    }
    if (!nullToAbsent || presencePenalty != null) {
      map['presence_penalty'] = Variable<double>(presencePenalty);
    }
    {
      map['custom_headers'] = Variable<String>(
          $AssistantsTable.$convertercustomHeaders.toSql(customHeaders));
    }
    {
      map['custom_body'] = Variable<String>(
          $AssistantsTable.$convertercustomBody.toSql(customBody));
    }
    {
      map['stop_sequences'] = Variable<String>(
          $AssistantsTable.$converterstopSequences.toSql(stopSequences));
    }
    map['enable_code_execution'] = Variable<bool>(enableCodeExecution);
    map['enable_image_generation'] = Variable<bool>(enableImageGeneration);
    map['enable_tools'] = Variable<bool>(enableTools);
    map['enable_reasoning'] = Variable<bool>(enableReasoning);
    map['enable_vision'] = Variable<bool>(enableVision);
    map['enable_embedding'] = Variable<bool>(enableEmbedding);
    {
      map['mcp_server_ids'] = Variable<String>(
          $AssistantsTable.$convertermcpServerIds.toSql(mcpServerIds));
    }
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AssistantsCompanion toCompanion(bool nullToAbsent) {
    return AssistantsCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      avatar: Value(avatar),
      systemPrompt: Value(systemPrompt),
      temperature: Value(temperature),
      topP: Value(topP),
      maxTokens: Value(maxTokens),
      contextLength: Value(contextLength),
      streamOutput: Value(streamOutput),
      frequencyPenalty: frequencyPenalty == null && nullToAbsent
          ? const Value.absent()
          : Value(frequencyPenalty),
      presencePenalty: presencePenalty == null && nullToAbsent
          ? const Value.absent()
          : Value(presencePenalty),
      customHeaders: Value(customHeaders),
      customBody: Value(customBody),
      stopSequences: Value(stopSequences),
      enableCodeExecution: Value(enableCodeExecution),
      enableImageGeneration: Value(enableImageGeneration),
      enableTools: Value(enableTools),
      enableReasoning: Value(enableReasoning),
      enableVision: Value(enableVision),
      enableEmbedding: Value(enableEmbedding),
      mcpServerIds: Value(mcpServerIds),
      isEnabled: Value(isEnabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AssistantData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssistantData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      avatar: serializer.fromJson<String>(json['avatar']),
      systemPrompt: serializer.fromJson<String>(json['systemPrompt']),
      temperature: serializer.fromJson<double>(json['temperature']),
      topP: serializer.fromJson<double>(json['topP']),
      maxTokens: serializer.fromJson<int>(json['maxTokens']),
      contextLength: serializer.fromJson<int>(json['contextLength']),
      streamOutput: serializer.fromJson<bool>(json['streamOutput']),
      frequencyPenalty: serializer.fromJson<double?>(json['frequencyPenalty']),
      presencePenalty: serializer.fromJson<double?>(json['presencePenalty']),
      customHeaders:
          serializer.fromJson<Map<String, String>>(json['customHeaders']),
      customBody: serializer.fromJson<Map<String, dynamic>>(json['customBody']),
      stopSequences: serializer.fromJson<List<String>>(json['stopSequences']),
      enableCodeExecution:
          serializer.fromJson<bool>(json['enableCodeExecution']),
      enableImageGeneration:
          serializer.fromJson<bool>(json['enableImageGeneration']),
      enableTools: serializer.fromJson<bool>(json['enableTools']),
      enableReasoning: serializer.fromJson<bool>(json['enableReasoning']),
      enableVision: serializer.fromJson<bool>(json['enableVision']),
      enableEmbedding: serializer.fromJson<bool>(json['enableEmbedding']),
      mcpServerIds: serializer.fromJson<List<String>>(json['mcpServerIds']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'avatar': serializer.toJson<String>(avatar),
      'systemPrompt': serializer.toJson<String>(systemPrompt),
      'temperature': serializer.toJson<double>(temperature),
      'topP': serializer.toJson<double>(topP),
      'maxTokens': serializer.toJson<int>(maxTokens),
      'contextLength': serializer.toJson<int>(contextLength),
      'streamOutput': serializer.toJson<bool>(streamOutput),
      'frequencyPenalty': serializer.toJson<double?>(frequencyPenalty),
      'presencePenalty': serializer.toJson<double?>(presencePenalty),
      'customHeaders': serializer.toJson<Map<String, String>>(customHeaders),
      'customBody': serializer.toJson<Map<String, dynamic>>(customBody),
      'stopSequences': serializer.toJson<List<String>>(stopSequences),
      'enableCodeExecution': serializer.toJson<bool>(enableCodeExecution),
      'enableImageGeneration': serializer.toJson<bool>(enableImageGeneration),
      'enableTools': serializer.toJson<bool>(enableTools),
      'enableReasoning': serializer.toJson<bool>(enableReasoning),
      'enableVision': serializer.toJson<bool>(enableVision),
      'enableEmbedding': serializer.toJson<bool>(enableEmbedding),
      'mcpServerIds': serializer.toJson<List<String>>(mcpServerIds),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AssistantData copyWith(
          {String? id,
          String? name,
          String? description,
          String? avatar,
          String? systemPrompt,
          double? temperature,
          double? topP,
          int? maxTokens,
          int? contextLength,
          bool? streamOutput,
          Value<double?> frequencyPenalty = const Value.absent(),
          Value<double?> presencePenalty = const Value.absent(),
          Map<String, String>? customHeaders,
          Map<String, dynamic>? customBody,
          List<String>? stopSequences,
          bool? enableCodeExecution,
          bool? enableImageGeneration,
          bool? enableTools,
          bool? enableReasoning,
          bool? enableVision,
          bool? enableEmbedding,
          List<String>? mcpServerIds,
          bool? isEnabled,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      AssistantData(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        avatar: avatar ?? this.avatar,
        systemPrompt: systemPrompt ?? this.systemPrompt,
        temperature: temperature ?? this.temperature,
        topP: topP ?? this.topP,
        maxTokens: maxTokens ?? this.maxTokens,
        contextLength: contextLength ?? this.contextLength,
        streamOutput: streamOutput ?? this.streamOutput,
        frequencyPenalty: frequencyPenalty.present
            ? frequencyPenalty.value
            : this.frequencyPenalty,
        presencePenalty: presencePenalty.present
            ? presencePenalty.value
            : this.presencePenalty,
        customHeaders: customHeaders ?? this.customHeaders,
        customBody: customBody ?? this.customBody,
        stopSequences: stopSequences ?? this.stopSequences,
        enableCodeExecution: enableCodeExecution ?? this.enableCodeExecution,
        enableImageGeneration:
            enableImageGeneration ?? this.enableImageGeneration,
        enableTools: enableTools ?? this.enableTools,
        enableReasoning: enableReasoning ?? this.enableReasoning,
        enableVision: enableVision ?? this.enableVision,
        enableEmbedding: enableEmbedding ?? this.enableEmbedding,
        mcpServerIds: mcpServerIds ?? this.mcpServerIds,
        isEnabled: isEnabled ?? this.isEnabled,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AssistantData copyWithCompanion(AssistantsCompanion data) {
    return AssistantData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      systemPrompt: data.systemPrompt.present
          ? data.systemPrompt.value
          : this.systemPrompt,
      temperature:
          data.temperature.present ? data.temperature.value : this.temperature,
      topP: data.topP.present ? data.topP.value : this.topP,
      maxTokens: data.maxTokens.present ? data.maxTokens.value : this.maxTokens,
      contextLength: data.contextLength.present
          ? data.contextLength.value
          : this.contextLength,
      streamOutput: data.streamOutput.present
          ? data.streamOutput.value
          : this.streamOutput,
      frequencyPenalty: data.frequencyPenalty.present
          ? data.frequencyPenalty.value
          : this.frequencyPenalty,
      presencePenalty: data.presencePenalty.present
          ? data.presencePenalty.value
          : this.presencePenalty,
      customHeaders: data.customHeaders.present
          ? data.customHeaders.value
          : this.customHeaders,
      customBody:
          data.customBody.present ? data.customBody.value : this.customBody,
      stopSequences: data.stopSequences.present
          ? data.stopSequences.value
          : this.stopSequences,
      enableCodeExecution: data.enableCodeExecution.present
          ? data.enableCodeExecution.value
          : this.enableCodeExecution,
      enableImageGeneration: data.enableImageGeneration.present
          ? data.enableImageGeneration.value
          : this.enableImageGeneration,
      enableTools:
          data.enableTools.present ? data.enableTools.value : this.enableTools,
      enableReasoning: data.enableReasoning.present
          ? data.enableReasoning.value
          : this.enableReasoning,
      enableVision: data.enableVision.present
          ? data.enableVision.value
          : this.enableVision,
      enableEmbedding: data.enableEmbedding.present
          ? data.enableEmbedding.value
          : this.enableEmbedding,
      mcpServerIds: data.mcpServerIds.present
          ? data.mcpServerIds.value
          : this.mcpServerIds,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssistantData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('avatar: $avatar, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('temperature: $temperature, ')
          ..write('topP: $topP, ')
          ..write('maxTokens: $maxTokens, ')
          ..write('contextLength: $contextLength, ')
          ..write('streamOutput: $streamOutput, ')
          ..write('frequencyPenalty: $frequencyPenalty, ')
          ..write('presencePenalty: $presencePenalty, ')
          ..write('customHeaders: $customHeaders, ')
          ..write('customBody: $customBody, ')
          ..write('stopSequences: $stopSequences, ')
          ..write('enableCodeExecution: $enableCodeExecution, ')
          ..write('enableImageGeneration: $enableImageGeneration, ')
          ..write('enableTools: $enableTools, ')
          ..write('enableReasoning: $enableReasoning, ')
          ..write('enableVision: $enableVision, ')
          ..write('enableEmbedding: $enableEmbedding, ')
          ..write('mcpServerIds: $mcpServerIds, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        description,
        avatar,
        systemPrompt,
        temperature,
        topP,
        maxTokens,
        contextLength,
        streamOutput,
        frequencyPenalty,
        presencePenalty,
        customHeaders,
        customBody,
        stopSequences,
        enableCodeExecution,
        enableImageGeneration,
        enableTools,
        enableReasoning,
        enableVision,
        enableEmbedding,
        mcpServerIds,
        isEnabled,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssistantData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.avatar == this.avatar &&
          other.systemPrompt == this.systemPrompt &&
          other.temperature == this.temperature &&
          other.topP == this.topP &&
          other.maxTokens == this.maxTokens &&
          other.contextLength == this.contextLength &&
          other.streamOutput == this.streamOutput &&
          other.frequencyPenalty == this.frequencyPenalty &&
          other.presencePenalty == this.presencePenalty &&
          other.customHeaders == this.customHeaders &&
          other.customBody == this.customBody &&
          other.stopSequences == this.stopSequences &&
          other.enableCodeExecution == this.enableCodeExecution &&
          other.enableImageGeneration == this.enableImageGeneration &&
          other.enableTools == this.enableTools &&
          other.enableReasoning == this.enableReasoning &&
          other.enableVision == this.enableVision &&
          other.enableEmbedding == this.enableEmbedding &&
          other.mcpServerIds == this.mcpServerIds &&
          other.isEnabled == this.isEnabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AssistantsCompanion extends UpdateCompanion<AssistantData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String> avatar;
  final Value<String> systemPrompt;
  final Value<double> temperature;
  final Value<double> topP;
  final Value<int> maxTokens;
  final Value<int> contextLength;
  final Value<bool> streamOutput;
  final Value<double?> frequencyPenalty;
  final Value<double?> presencePenalty;
  final Value<Map<String, String>> customHeaders;
  final Value<Map<String, dynamic>> customBody;
  final Value<List<String>> stopSequences;
  final Value<bool> enableCodeExecution;
  final Value<bool> enableImageGeneration;
  final Value<bool> enableTools;
  final Value<bool> enableReasoning;
  final Value<bool> enableVision;
  final Value<bool> enableEmbedding;
  final Value<List<String>> mcpServerIds;
  final Value<bool> isEnabled;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AssistantsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.avatar = const Value.absent(),
    this.systemPrompt = const Value.absent(),
    this.temperature = const Value.absent(),
    this.topP = const Value.absent(),
    this.maxTokens = const Value.absent(),
    this.contextLength = const Value.absent(),
    this.streamOutput = const Value.absent(),
    this.frequencyPenalty = const Value.absent(),
    this.presencePenalty = const Value.absent(),
    this.customHeaders = const Value.absent(),
    this.customBody = const Value.absent(),
    this.stopSequences = const Value.absent(),
    this.enableCodeExecution = const Value.absent(),
    this.enableImageGeneration = const Value.absent(),
    this.enableTools = const Value.absent(),
    this.enableReasoning = const Value.absent(),
    this.enableVision = const Value.absent(),
    this.enableEmbedding = const Value.absent(),
    this.mcpServerIds = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssistantsCompanion.insert({
    required String id,
    required String name,
    required String description,
    this.avatar = const Value.absent(),
    required String systemPrompt,
    this.temperature = const Value.absent(),
    this.topP = const Value.absent(),
    this.maxTokens = const Value.absent(),
    this.contextLength = const Value.absent(),
    this.streamOutput = const Value.absent(),
    this.frequencyPenalty = const Value.absent(),
    this.presencePenalty = const Value.absent(),
    this.customHeaders = const Value.absent(),
    this.customBody = const Value.absent(),
    this.stopSequences = const Value.absent(),
    this.enableCodeExecution = const Value.absent(),
    this.enableImageGeneration = const Value.absent(),
    this.enableTools = const Value.absent(),
    this.enableReasoning = const Value.absent(),
    this.enableVision = const Value.absent(),
    this.enableEmbedding = const Value.absent(),
    this.mcpServerIds = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        description = Value(description),
        systemPrompt = Value(systemPrompt);
  static Insertable<AssistantData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? avatar,
    Expression<String>? systemPrompt,
    Expression<double>? temperature,
    Expression<double>? topP,
    Expression<int>? maxTokens,
    Expression<int>? contextLength,
    Expression<bool>? streamOutput,
    Expression<double>? frequencyPenalty,
    Expression<double>? presencePenalty,
    Expression<String>? customHeaders,
    Expression<String>? customBody,
    Expression<String>? stopSequences,
    Expression<bool>? enableCodeExecution,
    Expression<bool>? enableImageGeneration,
    Expression<bool>? enableTools,
    Expression<bool>? enableReasoning,
    Expression<bool>? enableVision,
    Expression<bool>? enableEmbedding,
    Expression<String>? mcpServerIds,
    Expression<bool>? isEnabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (avatar != null) 'avatar': avatar,
      if (systemPrompt != null) 'system_prompt': systemPrompt,
      if (temperature != null) 'temperature': temperature,
      if (topP != null) 'top_p': topP,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (contextLength != null) 'context_length': contextLength,
      if (streamOutput != null) 'stream_output': streamOutput,
      if (frequencyPenalty != null) 'frequency_penalty': frequencyPenalty,
      if (presencePenalty != null) 'presence_penalty': presencePenalty,
      if (customHeaders != null) 'custom_headers': customHeaders,
      if (customBody != null) 'custom_body': customBody,
      if (stopSequences != null) 'stop_sequences': stopSequences,
      if (enableCodeExecution != null)
        'enable_code_execution': enableCodeExecution,
      if (enableImageGeneration != null)
        'enable_image_generation': enableImageGeneration,
      if (enableTools != null) 'enable_tools': enableTools,
      if (enableReasoning != null) 'enable_reasoning': enableReasoning,
      if (enableVision != null) 'enable_vision': enableVision,
      if (enableEmbedding != null) 'enable_embedding': enableEmbedding,
      if (mcpServerIds != null) 'mcp_server_ids': mcpServerIds,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssistantsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? description,
      Value<String>? avatar,
      Value<String>? systemPrompt,
      Value<double>? temperature,
      Value<double>? topP,
      Value<int>? maxTokens,
      Value<int>? contextLength,
      Value<bool>? streamOutput,
      Value<double?>? frequencyPenalty,
      Value<double?>? presencePenalty,
      Value<Map<String, String>>? customHeaders,
      Value<Map<String, dynamic>>? customBody,
      Value<List<String>>? stopSequences,
      Value<bool>? enableCodeExecution,
      Value<bool>? enableImageGeneration,
      Value<bool>? enableTools,
      Value<bool>? enableReasoning,
      Value<bool>? enableVision,
      Value<bool>? enableEmbedding,
      Value<List<String>>? mcpServerIds,
      Value<bool>? isEnabled,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AssistantsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      maxTokens: maxTokens ?? this.maxTokens,
      contextLength: contextLength ?? this.contextLength,
      streamOutput: streamOutput ?? this.streamOutput,
      frequencyPenalty: frequencyPenalty ?? this.frequencyPenalty,
      presencePenalty: presencePenalty ?? this.presencePenalty,
      customHeaders: customHeaders ?? this.customHeaders,
      customBody: customBody ?? this.customBody,
      stopSequences: stopSequences ?? this.stopSequences,
      enableCodeExecution: enableCodeExecution ?? this.enableCodeExecution,
      enableImageGeneration:
          enableImageGeneration ?? this.enableImageGeneration,
      enableTools: enableTools ?? this.enableTools,
      enableReasoning: enableReasoning ?? this.enableReasoning,
      enableVision: enableVision ?? this.enableVision,
      enableEmbedding: enableEmbedding ?? this.enableEmbedding,
      mcpServerIds: mcpServerIds ?? this.mcpServerIds,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (systemPrompt.present) {
      map['system_prompt'] = Variable<String>(systemPrompt.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (topP.present) {
      map['top_p'] = Variable<double>(topP.value);
    }
    if (maxTokens.present) {
      map['max_tokens'] = Variable<int>(maxTokens.value);
    }
    if (contextLength.present) {
      map['context_length'] = Variable<int>(contextLength.value);
    }
    if (streamOutput.present) {
      map['stream_output'] = Variable<bool>(streamOutput.value);
    }
    if (frequencyPenalty.present) {
      map['frequency_penalty'] = Variable<double>(frequencyPenalty.value);
    }
    if (presencePenalty.present) {
      map['presence_penalty'] = Variable<double>(presencePenalty.value);
    }
    if (customHeaders.present) {
      map['custom_headers'] = Variable<String>(
          $AssistantsTable.$convertercustomHeaders.toSql(customHeaders.value));
    }
    if (customBody.present) {
      map['custom_body'] = Variable<String>(
          $AssistantsTable.$convertercustomBody.toSql(customBody.value));
    }
    if (stopSequences.present) {
      map['stop_sequences'] = Variable<String>(
          $AssistantsTable.$converterstopSequences.toSql(stopSequences.value));
    }
    if (enableCodeExecution.present) {
      map['enable_code_execution'] = Variable<bool>(enableCodeExecution.value);
    }
    if (enableImageGeneration.present) {
      map['enable_image_generation'] =
          Variable<bool>(enableImageGeneration.value);
    }
    if (enableTools.present) {
      map['enable_tools'] = Variable<bool>(enableTools.value);
    }
    if (enableReasoning.present) {
      map['enable_reasoning'] = Variable<bool>(enableReasoning.value);
    }
    if (enableVision.present) {
      map['enable_vision'] = Variable<bool>(enableVision.value);
    }
    if (enableEmbedding.present) {
      map['enable_embedding'] = Variable<bool>(enableEmbedding.value);
    }
    if (mcpServerIds.present) {
      map['mcp_server_ids'] = Variable<String>(
          $AssistantsTable.$convertermcpServerIds.toSql(mcpServerIds.value));
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssistantsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('avatar: $avatar, ')
          ..write('systemPrompt: $systemPrompt, ')
          ..write('temperature: $temperature, ')
          ..write('topP: $topP, ')
          ..write('maxTokens: $maxTokens, ')
          ..write('contextLength: $contextLength, ')
          ..write('streamOutput: $streamOutput, ')
          ..write('frequencyPenalty: $frequencyPenalty, ')
          ..write('presencePenalty: $presencePenalty, ')
          ..write('customHeaders: $customHeaders, ')
          ..write('customBody: $customBody, ')
          ..write('stopSequences: $stopSequences, ')
          ..write('enableCodeExecution: $enableCodeExecution, ')
          ..write('enableImageGeneration: $enableImageGeneration, ')
          ..write('enableTools: $enableTools, ')
          ..write('enableReasoning: $enableReasoning, ')
          ..write('enableVision: $enableVision, ')
          ..write('enableEmbedding: $enableEmbedding, ')
          ..write('mcpServerIds: $mcpServerIds, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, ConversationData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assistantIdMeta =
      const VerificationMeta('assistantId');
  @override
  late final GeneratedColumn<String> assistantId = GeneratedColumn<String>(
      'assistant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _providerIdMeta =
      const VerificationMeta('providerId');
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
      'provider_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modelIdMeta =
      const VerificationMeta('modelId');
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
      'model_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastMessageAtMeta =
      const VerificationMeta('lastMessageAt');
  @override
  late final GeneratedColumn<DateTime> lastMessageAt =
      GeneratedColumn<DateTime>('last_message_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        assistantId,
        providerId,
        modelId,
        lastMessageAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(Insertable<ConversationData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('assistant_id')) {
      context.handle(
          _assistantIdMeta,
          assistantId.isAcceptableOrUnknown(
              data['assistant_id']!, _assistantIdMeta));
    } else if (isInserting) {
      context.missing(_assistantIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
          _providerIdMeta,
          providerId.isAcceptableOrUnknown(
              data['provider_id']!, _providerIdMeta));
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(_modelIdMeta,
          modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta));
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
          _lastMessageAtMeta,
          lastMessageAt.isAcceptableOrUnknown(
              data['last_message_at']!, _lastMessageAtMeta));
    } else if (isInserting) {
      context.missing(_lastMessageAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConversationData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConversationData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      assistantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}assistant_id'])!,
      providerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider_id'])!,
      modelId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_id']),
      lastMessageAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_message_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class ConversationData extends DataClass
    implements Insertable<ConversationData> {
  final String id;
  final String title;
  final String assistantId;
  final String providerId;
  final String? modelId;
  final DateTime lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ConversationData(
      {required this.id,
      required this.title,
      required this.assistantId,
      required this.providerId,
      this.modelId,
      required this.lastMessageAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['assistant_id'] = Variable<String>(assistantId);
    map['provider_id'] = Variable<String>(providerId);
    if (!nullToAbsent || modelId != null) {
      map['model_id'] = Variable<String>(modelId);
    }
    map['last_message_at'] = Variable<DateTime>(lastMessageAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      id: Value(id),
      title: Value(title),
      assistantId: Value(assistantId),
      providerId: Value(providerId),
      modelId: modelId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelId),
      lastMessageAt: Value(lastMessageAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ConversationData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      assistantId: serializer.fromJson<String>(json['assistantId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      modelId: serializer.fromJson<String?>(json['modelId']),
      lastMessageAt: serializer.fromJson<DateTime>(json['lastMessageAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'assistantId': serializer.toJson<String>(assistantId),
      'providerId': serializer.toJson<String>(providerId),
      'modelId': serializer.toJson<String?>(modelId),
      'lastMessageAt': serializer.toJson<DateTime>(lastMessageAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ConversationData copyWith(
          {String? id,
          String? title,
          String? assistantId,
          String? providerId,
          Value<String?> modelId = const Value.absent(),
          DateTime? lastMessageAt,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ConversationData(
        id: id ?? this.id,
        title: title ?? this.title,
        assistantId: assistantId ?? this.assistantId,
        providerId: providerId ?? this.providerId,
        modelId: modelId.present ? modelId.value : this.modelId,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ConversationData copyWithCompanion(ConversationsCompanion data) {
    return ConversationData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      assistantId:
          data.assistantId.present ? data.assistantId.value : this.assistantId,
      providerId:
          data.providerId.present ? data.providerId.value : this.providerId,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConversationData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('assistantId: $assistantId, ')
          ..write('providerId: $providerId, ')
          ..write('modelId: $modelId, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, assistantId, providerId, modelId,
      lastMessageAt, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationData &&
          other.id == this.id &&
          other.title == this.title &&
          other.assistantId == this.assistantId &&
          other.providerId == this.providerId &&
          other.modelId == this.modelId &&
          other.lastMessageAt == this.lastMessageAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ConversationsCompanion extends UpdateCompanion<ConversationData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> assistantId;
  final Value<String> providerId;
  final Value<String?> modelId;
  final Value<DateTime> lastMessageAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.assistantId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationsCompanion.insert({
    required String id,
    required String title,
    required String assistantId,
    required String providerId,
    this.modelId = const Value.absent(),
    required DateTime lastMessageAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        assistantId = Value(assistantId),
        providerId = Value(providerId),
        lastMessageAt = Value(lastMessageAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ConversationData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? assistantId,
    Expression<String>? providerId,
    Expression<String>? modelId,
    Expression<DateTime>? lastMessageAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (assistantId != null) 'assistant_id': assistantId,
      if (providerId != null) 'provider_id': providerId,
      if (modelId != null) 'model_id': modelId,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? assistantId,
      Value<String>? providerId,
      Value<String?>? modelId,
      Value<DateTime>? lastMessageAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ConversationsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      assistantId: assistantId ?? this.assistantId,
      providerId: providerId ?? this.providerId,
      modelId: modelId ?? this.modelId,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (assistantId.present) {
      map['assistant_id'] = Variable<String>(assistantId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('assistantId: $assistantId, ')
          ..write('providerId: $providerId, ')
          ..write('modelId: $modelId, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages
    with TableInfo<$MessagesTable, MessageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assistantIdMeta =
      const VerificationMeta('assistantId');
  @override
  late final GeneratedColumn<String> assistantId = GeneratedColumn<String>(
      'assistant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> blockIds =
      GeneratedColumn<String>('block_ids', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>($MessagesTable.$converterblockIds);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('userSuccess'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _modelIdMeta =
      const VerificationMeta('modelId');
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
      'model_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        conversationId,
        role,
        assistantId,
        blockIds,
        status,
        createdAt,
        updatedAt,
        modelId,
        metadata
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<MessageData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('assistant_id')) {
      context.handle(
          _assistantIdMeta,
          assistantId.isAcceptableOrUnknown(
              data['assistant_id']!, _assistantIdMeta));
    } else if (isInserting) {
      context.missing(_assistantIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(_modelIdMeta,
          modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta));
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      conversationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conversation_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      assistantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}assistant_id'])!,
      blockIds: $MessagesTable.$converterblockIds.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}block_ids'])!),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      modelId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_id']),
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata']),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterblockIds =
      const StringListConverter();
}

class MessageData extends DataClass implements Insertable<MessageData> {
  final String id;
  final String conversationId;
  final String role;
  final String assistantId;
  final List<String> blockIds;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? modelId;
  final String? metadata;
  const MessageData(
      {required this.id,
      required this.conversationId,
      required this.role,
      required this.assistantId,
      required this.blockIds,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      this.modelId,
      this.metadata});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['role'] = Variable<String>(role);
    map['assistant_id'] = Variable<String>(assistantId);
    {
      map['block_ids'] =
          Variable<String>($MessagesTable.$converterblockIds.toSql(blockIds));
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || modelId != null) {
      map['model_id'] = Variable<String>(modelId);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      assistantId: Value(assistantId),
      blockIds: Value(blockIds),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      modelId: modelId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelId),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
    );
  }

  factory MessageData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageData(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      role: serializer.fromJson<String>(json['role']),
      assistantId: serializer.fromJson<String>(json['assistantId']),
      blockIds: serializer.fromJson<List<String>>(json['blockIds']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      modelId: serializer.fromJson<String?>(json['modelId']),
      metadata: serializer.fromJson<String?>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'role': serializer.toJson<String>(role),
      'assistantId': serializer.toJson<String>(assistantId),
      'blockIds': serializer.toJson<List<String>>(blockIds),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'modelId': serializer.toJson<String?>(modelId),
      'metadata': serializer.toJson<String?>(metadata),
    };
  }

  MessageData copyWith(
          {String? id,
          String? conversationId,
          String? role,
          String? assistantId,
          List<String>? blockIds,
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<String?> modelId = const Value.absent(),
          Value<String?> metadata = const Value.absent()}) =>
      MessageData(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        role: role ?? this.role,
        assistantId: assistantId ?? this.assistantId,
        blockIds: blockIds ?? this.blockIds,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        modelId: modelId.present ? modelId.value : this.modelId,
        metadata: metadata.present ? metadata.value : this.metadata,
      );
  MessageData copyWithCompanion(MessagesCompanion data) {
    return MessageData(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      assistantId:
          data.assistantId.present ? data.assistantId.value : this.assistantId,
      blockIds: data.blockIds.present ? data.blockIds.value : this.blockIds,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageData(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('assistantId: $assistantId, ')
          ..write('blockIds: $blockIds, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('modelId: $modelId, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, conversationId, role, assistantId,
      blockIds, status, createdAt, updatedAt, modelId, metadata);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageData &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.assistantId == this.assistantId &&
          other.blockIds == this.blockIds &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.modelId == this.modelId &&
          other.metadata == this.metadata);
}

class MessagesCompanion extends UpdateCompanion<MessageData> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> role;
  final Value<String> assistantId;
  final Value<List<String>> blockIds;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> modelId;
  final Value<String?> metadata;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.assistantId = const Value.absent(),
    this.blockIds = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.modelId = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String conversationId,
    required String role,
    required String assistantId,
    this.blockIds = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.modelId = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        conversationId = Value(conversationId),
        role = Value(role),
        assistantId = Value(assistantId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<MessageData> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? role,
    Expression<String>? assistantId,
    Expression<String>? blockIds,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? modelId,
    Expression<String>? metadata,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (assistantId != null) 'assistant_id': assistantId,
      if (blockIds != null) 'block_ids': blockIds,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (modelId != null) 'model_id': modelId,
      if (metadata != null) 'metadata': metadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? conversationId,
      Value<String>? role,
      Value<String>? assistantId,
      Value<List<String>>? blockIds,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String?>? modelId,
      Value<String?>? metadata,
      Value<int>? rowid}) {
    return MessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      assistantId: assistantId ?? this.assistantId,
      blockIds: blockIds ?? this.blockIds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      modelId: modelId ?? this.modelId,
      metadata: metadata ?? this.metadata,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (assistantId.present) {
      map['assistant_id'] = Variable<String>(assistantId.value);
    }
    if (blockIds.present) {
      map['block_ids'] = Variable<String>(
          $MessagesTable.$converterblockIds.toSql(blockIds.value));
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('assistantId: $assistantId, ')
          ..write('blockIds: $blockIds, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('modelId: $modelId, ')
          ..write('metadata: $metadata, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessageBlocksTable extends MessageBlocks
    with TableInfo<$MessageBlocksTable, MessageBlockData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageBlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageIdMeta =
      const VerificationMeta('messageId');
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
      'message_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('success'));
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        messageId,
        type,
        status,
        content,
        metadata,
        orderIndex,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_blocks';
  @override
  VerificationContext validateIntegrity(Insertable<MessageBlockData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta));
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageBlockData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageBlockData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      messageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata']),
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MessageBlocksTable createAlias(String alias) {
    return $MessageBlocksTable(attachedDatabase, alias);
  }
}

class MessageBlockData extends DataClass
    implements Insertable<MessageBlockData> {
  final String id;
  final String messageId;
  final String type;
  final String status;
  final String? content;
  final String? metadata;
  final int orderIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MessageBlockData(
      {required this.id,
      required this.messageId,
      required this.type,
      required this.status,
      this.content,
      this.metadata,
      required this.orderIndex,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['message_id'] = Variable<String>(messageId);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    map['order_index'] = Variable<int>(orderIndex);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MessageBlocksCompanion toCompanion(bool nullToAbsent) {
    return MessageBlocksCompanion(
      id: Value(id),
      messageId: Value(messageId),
      type: Value(type),
      status: Value(status),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      orderIndex: Value(orderIndex),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MessageBlockData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageBlockData(
      id: serializer.fromJson<String>(json['id']),
      messageId: serializer.fromJson<String>(json['messageId']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      content: serializer.fromJson<String?>(json['content']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'messageId': serializer.toJson<String>(messageId),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'content': serializer.toJson<String?>(content),
      'metadata': serializer.toJson<String?>(metadata),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MessageBlockData copyWith(
          {String? id,
          String? messageId,
          String? type,
          String? status,
          Value<String?> content = const Value.absent(),
          Value<String?> metadata = const Value.absent(),
          int? orderIndex,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      MessageBlockData(
        id: id ?? this.id,
        messageId: messageId ?? this.messageId,
        type: type ?? this.type,
        status: status ?? this.status,
        content: content.present ? content.value : this.content,
        metadata: metadata.present ? metadata.value : this.metadata,
        orderIndex: orderIndex ?? this.orderIndex,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  MessageBlockData copyWithCompanion(MessageBlocksCompanion data) {
    return MessageBlockData(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      content: data.content.present ? data.content.value : this.content,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageBlockData(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('content: $content, ')
          ..write('metadata: $metadata, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, messageId, type, status, content,
      metadata, orderIndex, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageBlockData &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.type == this.type &&
          other.status == this.status &&
          other.content == this.content &&
          other.metadata == this.metadata &&
          other.orderIndex == this.orderIndex &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MessageBlocksCompanion extends UpdateCompanion<MessageBlockData> {
  final Value<String> id;
  final Value<String> messageId;
  final Value<String> type;
  final Value<String> status;
  final Value<String?> content;
  final Value<String?> metadata;
  final Value<int> orderIndex;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MessageBlocksCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.content = const Value.absent(),
    this.metadata = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageBlocksCompanion.insert({
    required String id,
    required String messageId,
    required String type,
    this.status = const Value.absent(),
    this.content = const Value.absent(),
    this.metadata = const Value.absent(),
    this.orderIndex = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        messageId = Value(messageId),
        type = Value(type),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<MessageBlockData> custom({
    Expression<String>? id,
    Expression<String>? messageId,
    Expression<String>? type,
    Expression<String>? status,
    Expression<String>? content,
    Expression<String>? metadata,
    Expression<int>? orderIndex,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (content != null) 'content': content,
      if (metadata != null) 'metadata': metadata,
      if (orderIndex != null) 'order_index': orderIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageBlocksCompanion copyWith(
      {Value<String>? id,
      Value<String>? messageId,
      Value<String>? type,
      Value<String>? status,
      Value<String?>? content,
      Value<String?>? metadata,
      Value<int>? orderIndex,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return MessageBlocksCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      type: type ?? this.type,
      status: status ?? this.status,
      content: content ?? this.content,
      metadata: metadata ?? this.metadata,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageBlocksCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('content: $content, ')
          ..write('metadata: $metadata, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoriteModelsTable extends FavoriteModels
    with TableInfo<$FavoriteModelsTable, FavoriteModelData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteModelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _providerIdMeta =
      const VerificationMeta('providerId');
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
      'provider_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modelNameMeta =
      const VerificationMeta('modelName');
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
      'model_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, providerId, modelName, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_models';
  @override
  VerificationContext validateIntegrity(Insertable<FavoriteModelData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
          _providerIdMeta,
          providerId.isAcceptableOrUnknown(
              data['provider_id']!, _providerIdMeta));
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(_modelNameMeta,
          modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta));
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FavoriteModelData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteModelData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      providerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider_id'])!,
      modelName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FavoriteModelsTable createAlias(String alias) {
    return $FavoriteModelsTable(attachedDatabase, alias);
  }
}

class FavoriteModelData extends DataClass
    implements Insertable<FavoriteModelData> {
  final String id;
  final String providerId;
  final String modelName;
  final DateTime createdAt;
  const FavoriteModelData(
      {required this.id,
      required this.providerId,
      required this.modelName,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['provider_id'] = Variable<String>(providerId);
    map['model_name'] = Variable<String>(modelName);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FavoriteModelsCompanion toCompanion(bool nullToAbsent) {
    return FavoriteModelsCompanion(
      id: Value(id),
      providerId: Value(providerId),
      modelName: Value(modelName),
      createdAt: Value(createdAt),
    );
  }

  factory FavoriteModelData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteModelData(
      id: serializer.fromJson<String>(json['id']),
      providerId: serializer.fromJson<String>(json['providerId']),
      modelName: serializer.fromJson<String>(json['modelName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'providerId': serializer.toJson<String>(providerId),
      'modelName': serializer.toJson<String>(modelName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FavoriteModelData copyWith(
          {String? id,
          String? providerId,
          String? modelName,
          DateTime? createdAt}) =>
      FavoriteModelData(
        id: id ?? this.id,
        providerId: providerId ?? this.providerId,
        modelName: modelName ?? this.modelName,
        createdAt: createdAt ?? this.createdAt,
      );
  FavoriteModelData copyWithCompanion(FavoriteModelsCompanion data) {
    return FavoriteModelData(
      id: data.id.present ? data.id.value : this.id,
      providerId:
          data.providerId.present ? data.providerId.value : this.providerId,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteModelData(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('modelName: $modelName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, providerId, modelName, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteModelData &&
          other.id == this.id &&
          other.providerId == this.providerId &&
          other.modelName == this.modelName &&
          other.createdAt == this.createdAt);
}

class FavoriteModelsCompanion extends UpdateCompanion<FavoriteModelData> {
  final Value<String> id;
  final Value<String> providerId;
  final Value<String> modelName;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FavoriteModelsCompanion({
    this.id = const Value.absent(),
    this.providerId = const Value.absent(),
    this.modelName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoriteModelsCompanion.insert({
    required String id,
    required String providerId,
    required String modelName,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        providerId = Value(providerId),
        modelName = Value(modelName);
  static Insertable<FavoriteModelData> custom({
    Expression<String>? id,
    Expression<String>? providerId,
    Expression<String>? modelName,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerId != null) 'provider_id': providerId,
      if (modelName != null) 'model_name': modelName,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoriteModelsCompanion copyWith(
      {Value<String>? id,
      Value<String>? providerId,
      Value<String>? modelName,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return FavoriteModelsCompanion(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      modelName: modelName ?? this.modelName,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteModelsCompanion(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('modelName: $modelName, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [key, value, type, description, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<SettingData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingData extends DataClass implements Insertable<SettingData> {
  final String key;
  final String value;
  final String type;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SettingData(
      {required this.key,
      required this.value,
      required this.type,
      this.description,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
      type: Value(type),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SettingData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      type: serializer.fromJson<String>(json['type']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'type': serializer.toJson<String>(type),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SettingData copyWith(
          {String? key,
          String? value,
          String? type,
          Value<String?> description = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      SettingData(
        key: key ?? this.key,
        value: value ?? this.value,
        type: type ?? this.type,
        description: description.present ? description.value : this.description,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SettingData copyWithCompanion(SettingsCompanion data) {
    return SettingData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      type: data.type.present ? data.type.value : this.type,
      description:
          data.description.present ? data.description.value : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingData(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(key, value, type, description, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingData &&
          other.key == this.key &&
          other.value == this.value &&
          other.type == this.type &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<SettingData> {
  final Value<String> key;
  final Value<String> value;
  final Value<String> type;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    required String type,
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value),
        type = Value(type);
  static Insertable<SettingData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<String>? type,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? key,
      Value<String>? value,
      Value<String>? type,
      Value<String?>? description,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      type: type ?? this.type,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProvidersTable providers = $ProvidersTable(this);
  late final $AssistantsTable assistants = $AssistantsTable(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $MessageBlocksTable messageBlocks = $MessageBlocksTable(this);
  late final $FavoriteModelsTable favoriteModels = $FavoriteModelsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        providers,
        assistants,
        conversations,
        messages,
        messageBlocks,
        favoriteModels,
        settings
      ];
}

typedef $$ProvidersTableCreateCompanionBuilder = ProvidersCompanion Function({
  required String id,
  required String name,
  required ProviderType type,
  required String apiKey,
  Value<String?> baseUrl,
  Value<List<AiModel>> models,
  required Map<String, String> customHeaders,
  Value<bool> isEnabled,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ProvidersTableUpdateCompanionBuilder = ProvidersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<ProviderType> type,
  Value<String> apiKey,
  Value<String?> baseUrl,
  Value<List<AiModel>> models,
  Value<Map<String, String>> customHeaders,
  Value<bool> isEnabled,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ProvidersTableFilterComposer
    extends Composer<_$AppDatabase, $ProvidersTable> {
  $$ProvidersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ProviderType, ProviderType, int> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get apiKey => $composableBuilder(
      column: $table.apiKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get baseUrl => $composableBuilder(
      column: $table.baseUrl, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<AiModel>, List<AiModel>, String>
      get models => $composableBuilder(
          column: $table.models,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Map<String, String>, Map<String, String>,
          String>
      get customHeaders => $composableBuilder(
          column: $table.customHeaders,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ProvidersTableOrderingComposer
    extends Composer<_$AppDatabase, $ProvidersTable> {
  $$ProvidersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get apiKey => $composableBuilder(
      column: $table.apiKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get baseUrl => $composableBuilder(
      column: $table.baseUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get models => $composableBuilder(
      column: $table.models, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customHeaders => $composableBuilder(
      column: $table.customHeaders,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProvidersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProvidersTable> {
  $$ProvidersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ProviderType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get apiKey =>
      $composableBuilder(column: $table.apiKey, builder: (column) => column);

  GeneratedColumn<String> get baseUrl =>
      $composableBuilder(column: $table.baseUrl, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<AiModel>, String> get models =>
      $composableBuilder(column: $table.models, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String>
      get customHeaders => $composableBuilder(
          column: $table.customHeaders, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProvidersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProvidersTable,
    ProviderData,
    $$ProvidersTableFilterComposer,
    $$ProvidersTableOrderingComposer,
    $$ProvidersTableAnnotationComposer,
    $$ProvidersTableCreateCompanionBuilder,
    $$ProvidersTableUpdateCompanionBuilder,
    (
      ProviderData,
      BaseReferences<_$AppDatabase, $ProvidersTable, ProviderData>
    ),
    ProviderData,
    PrefetchHooks Function()> {
  $$ProvidersTableTableManager(_$AppDatabase db, $ProvidersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProvidersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProvidersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProvidersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<ProviderType> type = const Value.absent(),
            Value<String> apiKey = const Value.absent(),
            Value<String?> baseUrl = const Value.absent(),
            Value<List<AiModel>> models = const Value.absent(),
            Value<Map<String, String>> customHeaders = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProvidersCompanion(
            id: id,
            name: name,
            type: type,
            apiKey: apiKey,
            baseUrl: baseUrl,
            models: models,
            customHeaders: customHeaders,
            isEnabled: isEnabled,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required ProviderType type,
            required String apiKey,
            Value<String?> baseUrl = const Value.absent(),
            Value<List<AiModel>> models = const Value.absent(),
            required Map<String, String> customHeaders,
            Value<bool> isEnabled = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProvidersCompanion.insert(
            id: id,
            name: name,
            type: type,
            apiKey: apiKey,
            baseUrl: baseUrl,
            models: models,
            customHeaders: customHeaders,
            isEnabled: isEnabled,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProvidersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProvidersTable,
    ProviderData,
    $$ProvidersTableFilterComposer,
    $$ProvidersTableOrderingComposer,
    $$ProvidersTableAnnotationComposer,
    $$ProvidersTableCreateCompanionBuilder,
    $$ProvidersTableUpdateCompanionBuilder,
    (
      ProviderData,
      BaseReferences<_$AppDatabase, $ProvidersTable, ProviderData>
    ),
    ProviderData,
    PrefetchHooks Function()>;
typedef $$AssistantsTableCreateCompanionBuilder = AssistantsCompanion Function({
  required String id,
  required String name,
  required String description,
  Value<String> avatar,
  required String systemPrompt,
  Value<double> temperature,
  Value<double> topP,
  Value<int> maxTokens,
  Value<int> contextLength,
  Value<bool> streamOutput,
  Value<double?> frequencyPenalty,
  Value<double?> presencePenalty,
  Value<Map<String, String>> customHeaders,
  Value<Map<String, dynamic>> customBody,
  Value<List<String>> stopSequences,
  Value<bool> enableCodeExecution,
  Value<bool> enableImageGeneration,
  Value<bool> enableTools,
  Value<bool> enableReasoning,
  Value<bool> enableVision,
  Value<bool> enableEmbedding,
  Value<List<String>> mcpServerIds,
  Value<bool> isEnabled,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$AssistantsTableUpdateCompanionBuilder = AssistantsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> description,
  Value<String> avatar,
  Value<String> systemPrompt,
  Value<double> temperature,
  Value<double> topP,
  Value<int> maxTokens,
  Value<int> contextLength,
  Value<bool> streamOutput,
  Value<double?> frequencyPenalty,
  Value<double?> presencePenalty,
  Value<Map<String, String>> customHeaders,
  Value<Map<String, dynamic>> customBody,
  Value<List<String>> stopSequences,
  Value<bool> enableCodeExecution,
  Value<bool> enableImageGeneration,
  Value<bool> enableTools,
  Value<bool> enableReasoning,
  Value<bool> enableVision,
  Value<bool> enableEmbedding,
  Value<List<String>> mcpServerIds,
  Value<bool> isEnabled,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AssistantsTableFilterComposer
    extends Composer<_$AppDatabase, $AssistantsTable> {
  $$AssistantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatar => $composableBuilder(
      column: $table.avatar, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get systemPrompt => $composableBuilder(
      column: $table.systemPrompt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get topP => $composableBuilder(
      column: $table.topP, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxTokens => $composableBuilder(
      column: $table.maxTokens, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get contextLength => $composableBuilder(
      column: $table.contextLength, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get streamOutput => $composableBuilder(
      column: $table.streamOutput, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get frequencyPenalty => $composableBuilder(
      column: $table.frequencyPenalty,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get presencePenalty => $composableBuilder(
      column: $table.presencePenalty,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Map<String, String>, Map<String, String>,
          String>
      get customHeaders => $composableBuilder(
          column: $table.customHeaders,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Map<String, dynamic>, Map<String, dynamic>,
          String>
      get customBody => $composableBuilder(
          column: $table.customBody,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
      get stopSequences => $composableBuilder(
          column: $table.stopSequences,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get enableCodeExecution => $composableBuilder(
      column: $table.enableCodeExecution,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enableImageGeneration => $composableBuilder(
      column: $table.enableImageGeneration,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enableTools => $composableBuilder(
      column: $table.enableTools, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enableReasoning => $composableBuilder(
      column: $table.enableReasoning,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enableVision => $composableBuilder(
      column: $table.enableVision, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enableEmbedding => $composableBuilder(
      column: $table.enableEmbedding,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
      get mcpServerIds => $composableBuilder(
          column: $table.mcpServerIds,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AssistantsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssistantsTable> {
  $$AssistantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatar => $composableBuilder(
      column: $table.avatar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get systemPrompt => $composableBuilder(
      column: $table.systemPrompt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get topP => $composableBuilder(
      column: $table.topP, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxTokens => $composableBuilder(
      column: $table.maxTokens, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get contextLength => $composableBuilder(
      column: $table.contextLength,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get streamOutput => $composableBuilder(
      column: $table.streamOutput,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get frequencyPenalty => $composableBuilder(
      column: $table.frequencyPenalty,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get presencePenalty => $composableBuilder(
      column: $table.presencePenalty,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customHeaders => $composableBuilder(
      column: $table.customHeaders,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customBody => $composableBuilder(
      column: $table.customBody, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stopSequences => $composableBuilder(
      column: $table.stopSequences,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enableCodeExecution => $composableBuilder(
      column: $table.enableCodeExecution,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enableImageGeneration => $composableBuilder(
      column: $table.enableImageGeneration,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enableTools => $composableBuilder(
      column: $table.enableTools, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enableReasoning => $composableBuilder(
      column: $table.enableReasoning,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enableVision => $composableBuilder(
      column: $table.enableVision,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enableEmbedding => $composableBuilder(
      column: $table.enableEmbedding,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mcpServerIds => $composableBuilder(
      column: $table.mcpServerIds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AssistantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssistantsTable> {
  $$AssistantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<String> get systemPrompt => $composableBuilder(
      column: $table.systemPrompt, builder: (column) => column);

  GeneratedColumn<double> get temperature => $composableBuilder(
      column: $table.temperature, builder: (column) => column);

  GeneratedColumn<double> get topP =>
      $composableBuilder(column: $table.topP, builder: (column) => column);

  GeneratedColumn<int> get maxTokens =>
      $composableBuilder(column: $table.maxTokens, builder: (column) => column);

  GeneratedColumn<int> get contextLength => $composableBuilder(
      column: $table.contextLength, builder: (column) => column);

  GeneratedColumn<bool> get streamOutput => $composableBuilder(
      column: $table.streamOutput, builder: (column) => column);

  GeneratedColumn<double> get frequencyPenalty => $composableBuilder(
      column: $table.frequencyPenalty, builder: (column) => column);

  GeneratedColumn<double> get presencePenalty => $composableBuilder(
      column: $table.presencePenalty, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String>
      get customHeaders => $composableBuilder(
          column: $table.customHeaders, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
      get customBody => $composableBuilder(
          column: $table.customBody, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get stopSequences =>
      $composableBuilder(
          column: $table.stopSequences, builder: (column) => column);

  GeneratedColumn<bool> get enableCodeExecution => $composableBuilder(
      column: $table.enableCodeExecution, builder: (column) => column);

  GeneratedColumn<bool> get enableImageGeneration => $composableBuilder(
      column: $table.enableImageGeneration, builder: (column) => column);

  GeneratedColumn<bool> get enableTools => $composableBuilder(
      column: $table.enableTools, builder: (column) => column);

  GeneratedColumn<bool> get enableReasoning => $composableBuilder(
      column: $table.enableReasoning, builder: (column) => column);

  GeneratedColumn<bool> get enableVision => $composableBuilder(
      column: $table.enableVision, builder: (column) => column);

  GeneratedColumn<bool> get enableEmbedding => $composableBuilder(
      column: $table.enableEmbedding, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get mcpServerIds =>
      $composableBuilder(
          column: $table.mcpServerIds, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AssistantsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AssistantsTable,
    AssistantData,
    $$AssistantsTableFilterComposer,
    $$AssistantsTableOrderingComposer,
    $$AssistantsTableAnnotationComposer,
    $$AssistantsTableCreateCompanionBuilder,
    $$AssistantsTableUpdateCompanionBuilder,
    (
      AssistantData,
      BaseReferences<_$AppDatabase, $AssistantsTable, AssistantData>
    ),
    AssistantData,
    PrefetchHooks Function()> {
  $$AssistantsTableTableManager(_$AppDatabase db, $AssistantsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssistantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssistantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssistantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> avatar = const Value.absent(),
            Value<String> systemPrompt = const Value.absent(),
            Value<double> temperature = const Value.absent(),
            Value<double> topP = const Value.absent(),
            Value<int> maxTokens = const Value.absent(),
            Value<int> contextLength = const Value.absent(),
            Value<bool> streamOutput = const Value.absent(),
            Value<double?> frequencyPenalty = const Value.absent(),
            Value<double?> presencePenalty = const Value.absent(),
            Value<Map<String, String>> customHeaders = const Value.absent(),
            Value<Map<String, dynamic>> customBody = const Value.absent(),
            Value<List<String>> stopSequences = const Value.absent(),
            Value<bool> enableCodeExecution = const Value.absent(),
            Value<bool> enableImageGeneration = const Value.absent(),
            Value<bool> enableTools = const Value.absent(),
            Value<bool> enableReasoning = const Value.absent(),
            Value<bool> enableVision = const Value.absent(),
            Value<bool> enableEmbedding = const Value.absent(),
            Value<List<String>> mcpServerIds = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssistantsCompanion(
            id: id,
            name: name,
            description: description,
            avatar: avatar,
            systemPrompt: systemPrompt,
            temperature: temperature,
            topP: topP,
            maxTokens: maxTokens,
            contextLength: contextLength,
            streamOutput: streamOutput,
            frequencyPenalty: frequencyPenalty,
            presencePenalty: presencePenalty,
            customHeaders: customHeaders,
            customBody: customBody,
            stopSequences: stopSequences,
            enableCodeExecution: enableCodeExecution,
            enableImageGeneration: enableImageGeneration,
            enableTools: enableTools,
            enableReasoning: enableReasoning,
            enableVision: enableVision,
            enableEmbedding: enableEmbedding,
            mcpServerIds: mcpServerIds,
            isEnabled: isEnabled,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String description,
            Value<String> avatar = const Value.absent(),
            required String systemPrompt,
            Value<double> temperature = const Value.absent(),
            Value<double> topP = const Value.absent(),
            Value<int> maxTokens = const Value.absent(),
            Value<int> contextLength = const Value.absent(),
            Value<bool> streamOutput = const Value.absent(),
            Value<double?> frequencyPenalty = const Value.absent(),
            Value<double?> presencePenalty = const Value.absent(),
            Value<Map<String, String>> customHeaders = const Value.absent(),
            Value<Map<String, dynamic>> customBody = const Value.absent(),
            Value<List<String>> stopSequences = const Value.absent(),
            Value<bool> enableCodeExecution = const Value.absent(),
            Value<bool> enableImageGeneration = const Value.absent(),
            Value<bool> enableTools = const Value.absent(),
            Value<bool> enableReasoning = const Value.absent(),
            Value<bool> enableVision = const Value.absent(),
            Value<bool> enableEmbedding = const Value.absent(),
            Value<List<String>> mcpServerIds = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssistantsCompanion.insert(
            id: id,
            name: name,
            description: description,
            avatar: avatar,
            systemPrompt: systemPrompt,
            temperature: temperature,
            topP: topP,
            maxTokens: maxTokens,
            contextLength: contextLength,
            streamOutput: streamOutput,
            frequencyPenalty: frequencyPenalty,
            presencePenalty: presencePenalty,
            customHeaders: customHeaders,
            customBody: customBody,
            stopSequences: stopSequences,
            enableCodeExecution: enableCodeExecution,
            enableImageGeneration: enableImageGeneration,
            enableTools: enableTools,
            enableReasoning: enableReasoning,
            enableVision: enableVision,
            enableEmbedding: enableEmbedding,
            mcpServerIds: mcpServerIds,
            isEnabled: isEnabled,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AssistantsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AssistantsTable,
    AssistantData,
    $$AssistantsTableFilterComposer,
    $$AssistantsTableOrderingComposer,
    $$AssistantsTableAnnotationComposer,
    $$AssistantsTableCreateCompanionBuilder,
    $$AssistantsTableUpdateCompanionBuilder,
    (
      AssistantData,
      BaseReferences<_$AppDatabase, $AssistantsTable, AssistantData>
    ),
    AssistantData,
    PrefetchHooks Function()>;
typedef $$ConversationsTableCreateCompanionBuilder = ConversationsCompanion
    Function({
  required String id,
  required String title,
  required String assistantId,
  required String providerId,
  Value<String?> modelId,
  required DateTime lastMessageAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ConversationsTableUpdateCompanionBuilder = ConversationsCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> assistantId,
  Value<String> providerId,
  Value<String?> modelId,
  Value<DateTime> lastMessageAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assistantId => $composableBuilder(
      column: $table.assistantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get providerId => $composableBuilder(
      column: $table.providerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelId => $composableBuilder(
      column: $table.modelId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastMessageAt => $composableBuilder(
      column: $table.lastMessageAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assistantId => $composableBuilder(
      column: $table.assistantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get providerId => $composableBuilder(
      column: $table.providerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelId => $composableBuilder(
      column: $table.modelId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastMessageAt => $composableBuilder(
      column: $table.lastMessageAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get assistantId => $composableBuilder(
      column: $table.assistantId, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
      column: $table.providerId, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastMessageAt => $composableBuilder(
      column: $table.lastMessageAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ConversationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConversationsTable,
    ConversationData,
    $$ConversationsTableFilterComposer,
    $$ConversationsTableOrderingComposer,
    $$ConversationsTableAnnotationComposer,
    $$ConversationsTableCreateCompanionBuilder,
    $$ConversationsTableUpdateCompanionBuilder,
    (
      ConversationData,
      BaseReferences<_$AppDatabase, $ConversationsTable, ConversationData>
    ),
    ConversationData,
    PrefetchHooks Function()> {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> assistantId = const Value.absent(),
            Value<String> providerId = const Value.absent(),
            Value<String?> modelId = const Value.absent(),
            Value<DateTime> lastMessageAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConversationsCompanion(
            id: id,
            title: title,
            assistantId: assistantId,
            providerId: providerId,
            modelId: modelId,
            lastMessageAt: lastMessageAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String assistantId,
            required String providerId,
            Value<String?> modelId = const Value.absent(),
            required DateTime lastMessageAt,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ConversationsCompanion.insert(
            id: id,
            title: title,
            assistantId: assistantId,
            providerId: providerId,
            modelId: modelId,
            lastMessageAt: lastMessageAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConversationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConversationsTable,
    ConversationData,
    $$ConversationsTableFilterComposer,
    $$ConversationsTableOrderingComposer,
    $$ConversationsTableAnnotationComposer,
    $$ConversationsTableCreateCompanionBuilder,
    $$ConversationsTableUpdateCompanionBuilder,
    (
      ConversationData,
      BaseReferences<_$AppDatabase, $ConversationsTable, ConversationData>
    ),
    ConversationData,
    PrefetchHooks Function()>;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  required String id,
  required String conversationId,
  required String role,
  required String assistantId,
  Value<List<String>> blockIds,
  Value<String> status,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String?> modelId,
  Value<String?> metadata,
  Value<int> rowid,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<String> id,
  Value<String> conversationId,
  Value<String> role,
  Value<String> assistantId,
  Value<List<String>> blockIds,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String?> modelId,
  Value<String?> metadata,
  Value<int> rowid,
});

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assistantId => $composableBuilder(
      column: $table.assistantId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
      get blockIds => $composableBuilder(
          column: $table.blockIds,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelId => $composableBuilder(
      column: $table.modelId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assistantId => $composableBuilder(
      column: $table.assistantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get blockIds => $composableBuilder(
      column: $table.blockIds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelId => $composableBuilder(
      column: $table.modelId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conversationId => $composableBuilder(
      column: $table.conversationId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get assistantId => $composableBuilder(
      column: $table.assistantId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get blockIds =>
      $composableBuilder(column: $table.blockIds, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);
}

class $$MessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessagesTable,
    MessageData,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (MessageData, BaseReferences<_$AppDatabase, $MessagesTable, MessageData>),
    MessageData,
    PrefetchHooks Function()> {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> conversationId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> assistantId = const Value.absent(),
            Value<List<String>> blockIds = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String?> modelId = const Value.absent(),
            Value<String?> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion(
            id: id,
            conversationId: conversationId,
            role: role,
            assistantId: assistantId,
            blockIds: blockIds,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            modelId: modelId,
            metadata: metadata,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String conversationId,
            required String role,
            required String assistantId,
            Value<List<String>> blockIds = const Value.absent(),
            Value<String> status = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String?> modelId = const Value.absent(),
            Value<String?> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion.insert(
            id: id,
            conversationId: conversationId,
            role: role,
            assistantId: assistantId,
            blockIds: blockIds,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            modelId: modelId,
            metadata: metadata,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessagesTable,
    MessageData,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (MessageData, BaseReferences<_$AppDatabase, $MessagesTable, MessageData>),
    MessageData,
    PrefetchHooks Function()>;
typedef $$MessageBlocksTableCreateCompanionBuilder = MessageBlocksCompanion
    Function({
  required String id,
  required String messageId,
  required String type,
  Value<String> status,
  Value<String?> content,
  Value<String?> metadata,
  Value<int> orderIndex,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$MessageBlocksTableUpdateCompanionBuilder = MessageBlocksCompanion
    Function({
  Value<String> id,
  Value<String> messageId,
  Value<String> type,
  Value<String> status,
  Value<String?> content,
  Value<String?> metadata,
  Value<int> orderIndex,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$MessageBlocksTableFilterComposer
    extends Composer<_$AppDatabase, $MessageBlocksTable> {
  $$MessageBlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$MessageBlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $MessageBlocksTable> {
  $$MessageBlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$MessageBlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessageBlocksTable> {
  $$MessageBlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MessageBlocksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessageBlocksTable,
    MessageBlockData,
    $$MessageBlocksTableFilterComposer,
    $$MessageBlocksTableOrderingComposer,
    $$MessageBlocksTableAnnotationComposer,
    $$MessageBlocksTableCreateCompanionBuilder,
    $$MessageBlocksTableUpdateCompanionBuilder,
    (
      MessageBlockData,
      BaseReferences<_$AppDatabase, $MessageBlocksTable, MessageBlockData>
    ),
    MessageBlockData,
    PrefetchHooks Function()> {
  $$MessageBlocksTableTableManager(_$AppDatabase db, $MessageBlocksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageBlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessageBlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessageBlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> messageId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String?> metadata = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessageBlocksCompanion(
            id: id,
            messageId: messageId,
            type: type,
            status: status,
            content: content,
            metadata: metadata,
            orderIndex: orderIndex,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String messageId,
            required String type,
            Value<String> status = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String?> metadata = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MessageBlocksCompanion.insert(
            id: id,
            messageId: messageId,
            type: type,
            status: status,
            content: content,
            metadata: metadata,
            orderIndex: orderIndex,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MessageBlocksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessageBlocksTable,
    MessageBlockData,
    $$MessageBlocksTableFilterComposer,
    $$MessageBlocksTableOrderingComposer,
    $$MessageBlocksTableAnnotationComposer,
    $$MessageBlocksTableCreateCompanionBuilder,
    $$MessageBlocksTableUpdateCompanionBuilder,
    (
      MessageBlockData,
      BaseReferences<_$AppDatabase, $MessageBlocksTable, MessageBlockData>
    ),
    MessageBlockData,
    PrefetchHooks Function()>;
typedef $$FavoriteModelsTableCreateCompanionBuilder = FavoriteModelsCompanion
    Function({
  required String id,
  required String providerId,
  required String modelName,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$FavoriteModelsTableUpdateCompanionBuilder = FavoriteModelsCompanion
    Function({
  Value<String> id,
  Value<String> providerId,
  Value<String> modelName,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$FavoriteModelsTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteModelsTable> {
  $$FavoriteModelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get providerId => $composableBuilder(
      column: $table.providerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelName => $composableBuilder(
      column: $table.modelName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$FavoriteModelsTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteModelsTable> {
  $$FavoriteModelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get providerId => $composableBuilder(
      column: $table.providerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelName => $composableBuilder(
      column: $table.modelName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FavoriteModelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteModelsTable> {
  $$FavoriteModelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
      column: $table.providerId, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FavoriteModelsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FavoriteModelsTable,
    FavoriteModelData,
    $$FavoriteModelsTableFilterComposer,
    $$FavoriteModelsTableOrderingComposer,
    $$FavoriteModelsTableAnnotationComposer,
    $$FavoriteModelsTableCreateCompanionBuilder,
    $$FavoriteModelsTableUpdateCompanionBuilder,
    (
      FavoriteModelData,
      BaseReferences<_$AppDatabase, $FavoriteModelsTable, FavoriteModelData>
    ),
    FavoriteModelData,
    PrefetchHooks Function()> {
  $$FavoriteModelsTableTableManager(
      _$AppDatabase db, $FavoriteModelsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteModelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteModelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteModelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> providerId = const Value.absent(),
            Value<String> modelName = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FavoriteModelsCompanion(
            id: id,
            providerId: providerId,
            modelName: modelName,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String providerId,
            required String modelName,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FavoriteModelsCompanion.insert(
            id: id,
            providerId: providerId,
            modelName: modelName,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FavoriteModelsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FavoriteModelsTable,
    FavoriteModelData,
    $$FavoriteModelsTableFilterComposer,
    $$FavoriteModelsTableOrderingComposer,
    $$FavoriteModelsTableAnnotationComposer,
    $$FavoriteModelsTableCreateCompanionBuilder,
    $$FavoriteModelsTableUpdateCompanionBuilder,
    (
      FavoriteModelData,
      BaseReferences<_$AppDatabase, $FavoriteModelsTable, FavoriteModelData>
    ),
    FavoriteModelData,
    PrefetchHooks Function()>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  required String type,
  Value<String?> description,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<String> type,
  Value<String?> description,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    SettingData,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (SettingData, BaseReferences<_$AppDatabase, $SettingsTable, SettingData>),
    SettingData,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            key: key,
            value: value,
            type: type,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            required String type,
            Value<String?> description = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            key: key,
            value: value,
            type: type,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    SettingData,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (SettingData, BaseReferences<_$AppDatabase, $SettingsTable, SettingData>),
    SettingData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProvidersTableTableManager get providers =>
      $$ProvidersTableTableManager(_db, _db.providers);
  $$AssistantsTableTableManager get assistants =>
      $$AssistantsTableTableManager(_db, _db.assistants);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$MessageBlocksTableTableManager get messageBlocks =>
      $$MessageBlocksTableTableManager(_db, _db.messageBlocks);
  $$FavoriteModelsTableTableManager get favoriteModels =>
      $$FavoriteModelsTableTableManager(_db, _db.favoriteModels);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
