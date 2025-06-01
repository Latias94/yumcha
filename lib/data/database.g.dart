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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ProviderType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ProviderType>($ProvidersTable.$convertertype);
  static const VerificationMeta _apiKeyMeta = const VerificationMeta('apiKey');
  @override
  late final GeneratedColumn<String> apiKey = GeneratedColumn<String>(
    'api_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseUrlMeta = const VerificationMeta(
    'baseUrl',
  );
  @override
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
    'base_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  supportedModels = GeneratedColumn<String>(
    'supported_models',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($ProvidersTable.$convertersupportedModels);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
  customHeaders = GeneratedColumn<String>(
    'custom_headers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Map<String, String>>($ProvidersTable.$convertercustomHeaders);
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    apiKey,
    baseUrl,
    supportedModels,
    customHeaders,
    isEnabled,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'providers';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProviderData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('api_key')) {
      context.handle(
        _apiKeyMeta,
        apiKey.isAcceptableOrUnknown(data['api_key']!, _apiKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_apiKeyMeta);
    }
    if (data.containsKey('base_url')) {
      context.handle(
        _baseUrlMeta,
        baseUrl.isAcceptableOrUnknown(data['base_url']!, _baseUrlMeta),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
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
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $ProvidersTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      apiKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}api_key'],
      )!,
      baseUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_url'],
      ),
      supportedModels: $ProvidersTable.$convertersupportedModels.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}supported_models'],
        )!,
      ),
      customHeaders: $ProvidersTable.$convertercustomHeaders.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}custom_headers'],
        )!,
      ),
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProvidersTable createAlias(String alias) {
    return $ProvidersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ProviderType, int, int> $convertertype =
      const EnumIndexConverter<ProviderType>(ProviderType.values);
  static TypeConverter<List<String>, String> $convertersupportedModels =
      const StringListConverter();
  static TypeConverter<Map<String, String>, String> $convertercustomHeaders =
      const StringMapConverter();
}

class ProviderData extends DataClass implements Insertable<ProviderData> {
  final String id;
  final String name;
  final ProviderType type;
  final String apiKey;
  final String? baseUrl;
  final List<String> supportedModels;
  final Map<String, String> customHeaders;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProviderData({
    required this.id,
    required this.name,
    required this.type,
    required this.apiKey,
    this.baseUrl,
    required this.supportedModels,
    required this.customHeaders,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  });
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
      map['supported_models'] = Variable<String>(
        $ProvidersTable.$convertersupportedModels.toSql(supportedModels),
      );
    }
    {
      map['custom_headers'] = Variable<String>(
        $ProvidersTable.$convertercustomHeaders.toSql(customHeaders),
      );
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
      supportedModels: Value(supportedModels),
      customHeaders: Value(customHeaders),
      isEnabled: Value(isEnabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProviderData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProviderData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: $ProvidersTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      apiKey: serializer.fromJson<String>(json['apiKey']),
      baseUrl: serializer.fromJson<String?>(json['baseUrl']),
      supportedModels: serializer.fromJson<List<String>>(
        json['supportedModels'],
      ),
      customHeaders: serializer.fromJson<Map<String, String>>(
        json['customHeaders'],
      ),
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
      'type': serializer.toJson<int>(
        $ProvidersTable.$convertertype.toJson(type),
      ),
      'apiKey': serializer.toJson<String>(apiKey),
      'baseUrl': serializer.toJson<String?>(baseUrl),
      'supportedModels': serializer.toJson<List<String>>(supportedModels),
      'customHeaders': serializer.toJson<Map<String, String>>(customHeaders),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProviderData copyWith({
    String? id,
    String? name,
    ProviderType? type,
    String? apiKey,
    Value<String?> baseUrl = const Value.absent(),
    List<String>? supportedModels,
    Map<String, String>? customHeaders,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ProviderData(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    apiKey: apiKey ?? this.apiKey,
    baseUrl: baseUrl.present ? baseUrl.value : this.baseUrl,
    supportedModels: supportedModels ?? this.supportedModels,
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
      supportedModels: data.supportedModels.present
          ? data.supportedModels.value
          : this.supportedModels,
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
          ..write('supportedModels: $supportedModels, ')
          ..write('customHeaders: $customHeaders, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    apiKey,
    baseUrl,
    supportedModels,
    customHeaders,
    isEnabled,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProviderData &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.apiKey == this.apiKey &&
          other.baseUrl == this.baseUrl &&
          other.supportedModels == this.supportedModels &&
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
  final Value<List<String>> supportedModels;
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
    this.supportedModels = const Value.absent(),
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
    required List<String> supportedModels,
    required Map<String, String> customHeaders,
    this.isEnabled = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       apiKey = Value(apiKey),
       supportedModels = Value(supportedModels),
       customHeaders = Value(customHeaders),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProviderData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? type,
    Expression<String>? apiKey,
    Expression<String>? baseUrl,
    Expression<String>? supportedModels,
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
      if (supportedModels != null) 'supported_models': supportedModels,
      if (customHeaders != null) 'custom_headers': customHeaders,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProvidersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<ProviderType>? type,
    Value<String>? apiKey,
    Value<String?>? baseUrl,
    Value<List<String>>? supportedModels,
    Value<Map<String, String>>? customHeaders,
    Value<bool>? isEnabled,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProvidersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      supportedModels: supportedModels ?? this.supportedModels,
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
      map['type'] = Variable<int>(
        $ProvidersTable.$convertertype.toSql(type.value),
      );
    }
    if (apiKey.present) {
      map['api_key'] = Variable<String>(apiKey.value);
    }
    if (baseUrl.present) {
      map['base_url'] = Variable<String>(baseUrl.value);
    }
    if (supportedModels.present) {
      map['supported_models'] = Variable<String>(
        $ProvidersTable.$convertersupportedModels.toSql(supportedModels.value),
      );
    }
    if (customHeaders.present) {
      map['custom_headers'] = Variable<String>(
        $ProvidersTable.$convertercustomHeaders.toSql(customHeaders.value),
      );
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
          ..write('supportedModels: $supportedModels, ')
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
    'avatar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('🤖'),
  );
  static const VerificationMeta _systemPromptMeta = const VerificationMeta(
    'systemPrompt',
  );
  @override
  late final GeneratedColumn<String> systemPrompt = GeneratedColumn<String>(
    'system_prompt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelNameMeta = const VerificationMeta(
    'modelName',
  );
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
    'model_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temperatureMeta = const VerificationMeta(
    'temperature',
  );
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
    'temperature',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.7),
  );
  static const VerificationMeta _topPMeta = const VerificationMeta('topP');
  @override
  late final GeneratedColumn<double> topP = GeneratedColumn<double>(
    'top_p',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _maxTokensMeta = const VerificationMeta(
    'maxTokens',
  );
  @override
  late final GeneratedColumn<int> maxTokens = GeneratedColumn<int>(
    'max_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2048),
  );
  static const VerificationMeta _contextLengthMeta = const VerificationMeta(
    'contextLength',
  );
  @override
  late final GeneratedColumn<int> contextLength = GeneratedColumn<int>(
    'context_length',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _streamOutputMeta = const VerificationMeta(
    'streamOutput',
  );
  @override
  late final GeneratedColumn<bool> streamOutput = GeneratedColumn<bool>(
    'stream_output',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("stream_output" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _frequencyPenaltyMeta = const VerificationMeta(
    'frequencyPenalty',
  );
  @override
  late final GeneratedColumn<double> frequencyPenalty = GeneratedColumn<double>(
    'frequency_penalty',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _presencePenaltyMeta = const VerificationMeta(
    'presencePenalty',
  );
  @override
  late final GeneratedColumn<double> presencePenalty = GeneratedColumn<double>(
    'presence_penalty',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
  customHeaders =
      GeneratedColumn<String>(
        'custom_headers',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      ).withConverter<Map<String, String>>(
        $AssistantsTable.$convertercustomHeaders,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  customBody = GeneratedColumn<String>(
    'custom_body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  ).withConverter<Map<String, dynamic>>($AssistantsTable.$convertercustomBody);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  stopSequences = GeneratedColumn<String>(
    'stop_sequences',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($AssistantsTable.$converterstopSequences);
  static const VerificationMeta _enableWebSearchMeta = const VerificationMeta(
    'enableWebSearch',
  );
  @override
  late final GeneratedColumn<bool> enableWebSearch = GeneratedColumn<bool>(
    'enable_web_search',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enable_web_search" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _enableCodeExecutionMeta =
      const VerificationMeta('enableCodeExecution');
  @override
  late final GeneratedColumn<bool> enableCodeExecution = GeneratedColumn<bool>(
    'enable_code_execution',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enable_code_execution" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _enableImageGenerationMeta =
      const VerificationMeta('enableImageGeneration');
  @override
  late final GeneratedColumn<bool> enableImageGeneration =
      GeneratedColumn<bool>(
        'enable_image_generation',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("enable_image_generation" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    avatar,
    systemPrompt,
    providerId,
    modelName,
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
    enableWebSearch,
    enableCodeExecution,
    enableImageGeneration,
    isEnabled,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assistants';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssistantData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
      );
    }
    if (data.containsKey('system_prompt')) {
      context.handle(
        _systemPromptMeta,
        systemPrompt.isAcceptableOrUnknown(
          data['system_prompt']!,
          _systemPromptMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_systemPromptMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(
        _modelNameMeta,
        modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta),
      );
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('temperature')) {
      context.handle(
        _temperatureMeta,
        temperature.isAcceptableOrUnknown(
          data['temperature']!,
          _temperatureMeta,
        ),
      );
    }
    if (data.containsKey('top_p')) {
      context.handle(
        _topPMeta,
        topP.isAcceptableOrUnknown(data['top_p']!, _topPMeta),
      );
    }
    if (data.containsKey('max_tokens')) {
      context.handle(
        _maxTokensMeta,
        maxTokens.isAcceptableOrUnknown(data['max_tokens']!, _maxTokensMeta),
      );
    }
    if (data.containsKey('context_length')) {
      context.handle(
        _contextLengthMeta,
        contextLength.isAcceptableOrUnknown(
          data['context_length']!,
          _contextLengthMeta,
        ),
      );
    }
    if (data.containsKey('stream_output')) {
      context.handle(
        _streamOutputMeta,
        streamOutput.isAcceptableOrUnknown(
          data['stream_output']!,
          _streamOutputMeta,
        ),
      );
    }
    if (data.containsKey('frequency_penalty')) {
      context.handle(
        _frequencyPenaltyMeta,
        frequencyPenalty.isAcceptableOrUnknown(
          data['frequency_penalty']!,
          _frequencyPenaltyMeta,
        ),
      );
    }
    if (data.containsKey('presence_penalty')) {
      context.handle(
        _presencePenaltyMeta,
        presencePenalty.isAcceptableOrUnknown(
          data['presence_penalty']!,
          _presencePenaltyMeta,
        ),
      );
    }
    if (data.containsKey('enable_web_search')) {
      context.handle(
        _enableWebSearchMeta,
        enableWebSearch.isAcceptableOrUnknown(
          data['enable_web_search']!,
          _enableWebSearchMeta,
        ),
      );
    }
    if (data.containsKey('enable_code_execution')) {
      context.handle(
        _enableCodeExecutionMeta,
        enableCodeExecution.isAcceptableOrUnknown(
          data['enable_code_execution']!,
          _enableCodeExecutionMeta,
        ),
      );
    }
    if (data.containsKey('enable_image_generation')) {
      context.handle(
        _enableImageGenerationMeta,
        enableImageGeneration.isAcceptableOrUnknown(
          data['enable_image_generation']!,
          _enableImageGenerationMeta,
        ),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssistantData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssistantData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      )!,
      systemPrompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_prompt'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      )!,
      temperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature'],
      )!,
      topP: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}top_p'],
      )!,
      maxTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_tokens'],
      )!,
      contextLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}context_length'],
      )!,
      streamOutput: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}stream_output'],
      )!,
      frequencyPenalty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}frequency_penalty'],
      ),
      presencePenalty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}presence_penalty'],
      ),
      customHeaders: $AssistantsTable.$convertercustomHeaders.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}custom_headers'],
        )!,
      ),
      customBody: $AssistantsTable.$convertercustomBody.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}custom_body'],
        )!,
      ),
      stopSequences: $AssistantsTable.$converterstopSequences.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}stop_sequences'],
        )!,
      ),
      enableWebSearch: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_web_search'],
      )!,
      enableCodeExecution: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_code_execution'],
      )!,
      enableImageGeneration: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_image_generation'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
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
}

class AssistantData extends DataClass implements Insertable<AssistantData> {
  final String id;
  final String name;
  final String description;
  final String avatar;
  final String systemPrompt;
  final String providerId;
  final String modelName;
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
  final bool enableWebSearch;
  final bool enableCodeExecution;
  final bool enableImageGeneration;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AssistantData({
    required this.id,
    required this.name,
    required this.description,
    required this.avatar,
    required this.systemPrompt,
    required this.providerId,
    required this.modelName,
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
    required this.enableWebSearch,
    required this.enableCodeExecution,
    required this.enableImageGeneration,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['avatar'] = Variable<String>(avatar);
    map['system_prompt'] = Variable<String>(systemPrompt);
    map['provider_id'] = Variable<String>(providerId);
    map['model_name'] = Variable<String>(modelName);
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
        $AssistantsTable.$convertercustomHeaders.toSql(customHeaders),
      );
    }
    {
      map['custom_body'] = Variable<String>(
        $AssistantsTable.$convertercustomBody.toSql(customBody),
      );
    }
    {
      map['stop_sequences'] = Variable<String>(
        $AssistantsTable.$converterstopSequences.toSql(stopSequences),
      );
    }
    map['enable_web_search'] = Variable<bool>(enableWebSearch);
    map['enable_code_execution'] = Variable<bool>(enableCodeExecution);
    map['enable_image_generation'] = Variable<bool>(enableImageGeneration);
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
      providerId: Value(providerId),
      modelName: Value(modelName),
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
      enableWebSearch: Value(enableWebSearch),
      enableCodeExecution: Value(enableCodeExecution),
      enableImageGeneration: Value(enableImageGeneration),
      isEnabled: Value(isEnabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AssistantData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssistantData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      avatar: serializer.fromJson<String>(json['avatar']),
      systemPrompt: serializer.fromJson<String>(json['systemPrompt']),
      providerId: serializer.fromJson<String>(json['providerId']),
      modelName: serializer.fromJson<String>(json['modelName']),
      temperature: serializer.fromJson<double>(json['temperature']),
      topP: serializer.fromJson<double>(json['topP']),
      maxTokens: serializer.fromJson<int>(json['maxTokens']),
      contextLength: serializer.fromJson<int>(json['contextLength']),
      streamOutput: serializer.fromJson<bool>(json['streamOutput']),
      frequencyPenalty: serializer.fromJson<double?>(json['frequencyPenalty']),
      presencePenalty: serializer.fromJson<double?>(json['presencePenalty']),
      customHeaders: serializer.fromJson<Map<String, String>>(
        json['customHeaders'],
      ),
      customBody: serializer.fromJson<Map<String, dynamic>>(json['customBody']),
      stopSequences: serializer.fromJson<List<String>>(json['stopSequences']),
      enableWebSearch: serializer.fromJson<bool>(json['enableWebSearch']),
      enableCodeExecution: serializer.fromJson<bool>(
        json['enableCodeExecution'],
      ),
      enableImageGeneration: serializer.fromJson<bool>(
        json['enableImageGeneration'],
      ),
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
      'providerId': serializer.toJson<String>(providerId),
      'modelName': serializer.toJson<String>(modelName),
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
      'enableWebSearch': serializer.toJson<bool>(enableWebSearch),
      'enableCodeExecution': serializer.toJson<bool>(enableCodeExecution),
      'enableImageGeneration': serializer.toJson<bool>(enableImageGeneration),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AssistantData copyWith({
    String? id,
    String? name,
    String? description,
    String? avatar,
    String? systemPrompt,
    String? providerId,
    String? modelName,
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
    bool? enableWebSearch,
    bool? enableCodeExecution,
    bool? enableImageGeneration,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AssistantData(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    avatar: avatar ?? this.avatar,
    systemPrompt: systemPrompt ?? this.systemPrompt,
    providerId: providerId ?? this.providerId,
    modelName: modelName ?? this.modelName,
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
    enableWebSearch: enableWebSearch ?? this.enableWebSearch,
    enableCodeExecution: enableCodeExecution ?? this.enableCodeExecution,
    enableImageGeneration: enableImageGeneration ?? this.enableImageGeneration,
    isEnabled: isEnabled ?? this.isEnabled,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AssistantData copyWithCompanion(AssistantsCompanion data) {
    return AssistantData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      systemPrompt: data.systemPrompt.present
          ? data.systemPrompt.value
          : this.systemPrompt,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      temperature: data.temperature.present
          ? data.temperature.value
          : this.temperature,
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
      customBody: data.customBody.present
          ? data.customBody.value
          : this.customBody,
      stopSequences: data.stopSequences.present
          ? data.stopSequences.value
          : this.stopSequences,
      enableWebSearch: data.enableWebSearch.present
          ? data.enableWebSearch.value
          : this.enableWebSearch,
      enableCodeExecution: data.enableCodeExecution.present
          ? data.enableCodeExecution.value
          : this.enableCodeExecution,
      enableImageGeneration: data.enableImageGeneration.present
          ? data.enableImageGeneration.value
          : this.enableImageGeneration,
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
          ..write('providerId: $providerId, ')
          ..write('modelName: $modelName, ')
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
          ..write('enableWebSearch: $enableWebSearch, ')
          ..write('enableCodeExecution: $enableCodeExecution, ')
          ..write('enableImageGeneration: $enableImageGeneration, ')
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
    providerId,
    modelName,
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
    enableWebSearch,
    enableCodeExecution,
    enableImageGeneration,
    isEnabled,
    createdAt,
    updatedAt,
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
          other.providerId == this.providerId &&
          other.modelName == this.modelName &&
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
          other.enableWebSearch == this.enableWebSearch &&
          other.enableCodeExecution == this.enableCodeExecution &&
          other.enableImageGeneration == this.enableImageGeneration &&
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
  final Value<String> providerId;
  final Value<String> modelName;
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
  final Value<bool> enableWebSearch;
  final Value<bool> enableCodeExecution;
  final Value<bool> enableImageGeneration;
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
    this.providerId = const Value.absent(),
    this.modelName = const Value.absent(),
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
    this.enableWebSearch = const Value.absent(),
    this.enableCodeExecution = const Value.absent(),
    this.enableImageGeneration = const Value.absent(),
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
    required String providerId,
    required String modelName,
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
    this.enableWebSearch = const Value.absent(),
    this.enableCodeExecution = const Value.absent(),
    this.enableImageGeneration = const Value.absent(),
    this.isEnabled = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       description = Value(description),
       systemPrompt = Value(systemPrompt),
       providerId = Value(providerId),
       modelName = Value(modelName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AssistantData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? avatar,
    Expression<String>? systemPrompt,
    Expression<String>? providerId,
    Expression<String>? modelName,
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
    Expression<bool>? enableWebSearch,
    Expression<bool>? enableCodeExecution,
    Expression<bool>? enableImageGeneration,
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
      if (providerId != null) 'provider_id': providerId,
      if (modelName != null) 'model_name': modelName,
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
      if (enableWebSearch != null) 'enable_web_search': enableWebSearch,
      if (enableCodeExecution != null)
        'enable_code_execution': enableCodeExecution,
      if (enableImageGeneration != null)
        'enable_image_generation': enableImageGeneration,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssistantsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String>? avatar,
    Value<String>? systemPrompt,
    Value<String>? providerId,
    Value<String>? modelName,
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
    Value<bool>? enableWebSearch,
    Value<bool>? enableCodeExecution,
    Value<bool>? enableImageGeneration,
    Value<bool>? isEnabled,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AssistantsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      providerId: providerId ?? this.providerId,
      modelName: modelName ?? this.modelName,
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
      enableWebSearch: enableWebSearch ?? this.enableWebSearch,
      enableCodeExecution: enableCodeExecution ?? this.enableCodeExecution,
      enableImageGeneration:
          enableImageGeneration ?? this.enableImageGeneration,
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
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
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
        $AssistantsTable.$convertercustomHeaders.toSql(customHeaders.value),
      );
    }
    if (customBody.present) {
      map['custom_body'] = Variable<String>(
        $AssistantsTable.$convertercustomBody.toSql(customBody.value),
      );
    }
    if (stopSequences.present) {
      map['stop_sequences'] = Variable<String>(
        $AssistantsTable.$converterstopSequences.toSql(stopSequences.value),
      );
    }
    if (enableWebSearch.present) {
      map['enable_web_search'] = Variable<bool>(enableWebSearch.value);
    }
    if (enableCodeExecution.present) {
      map['enable_code_execution'] = Variable<bool>(enableCodeExecution.value);
    }
    if (enableImageGeneration.present) {
      map['enable_image_generation'] = Variable<bool>(
        enableImageGeneration.value,
      );
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
          ..write('providerId: $providerId, ')
          ..write('modelName: $modelName, ')
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
          ..write('enableWebSearch: $enableWebSearch, ')
          ..write('enableCodeExecution: $enableCodeExecution, ')
          ..write('enableImageGeneration: $enableImageGeneration, ')
          ..write('isEnabled: $isEnabled, ')
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
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [providers, assistants];
}

typedef $$ProvidersTableCreateCompanionBuilder =
    ProvidersCompanion Function({
      required String id,
      required String name,
      required ProviderType type,
      required String apiKey,
      Value<String?> baseUrl,
      required List<String> supportedModels,
      required Map<String, String> customHeaders,
      Value<bool> isEnabled,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ProvidersTableUpdateCompanionBuilder =
    ProvidersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<ProviderType> type,
      Value<String> apiKey,
      Value<String?> baseUrl,
      Value<List<String>> supportedModels,
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
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ProviderType, ProviderType, int> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get apiKey => $composableBuilder(
    column: $table.apiKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get supportedModels => $composableBuilder(
    column: $table.supportedModels,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, String>,
    Map<String, String>,
    String
  >
  get customHeaders => $composableBuilder(
    column: $table.customHeaders,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
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
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apiKey => $composableBuilder(
    column: $table.apiKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supportedModels => $composableBuilder(
    column: $table.supportedModels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customHeaders => $composableBuilder(
    column: $table.customHeaders,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumnWithTypeConverter<List<String>, String> get supportedModels =>
      $composableBuilder(
        column: $table.supportedModels,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Map<String, String>, String>
  get customHeaders => $composableBuilder(
    column: $table.customHeaders,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProvidersTableTableManager
    extends
        RootTableManager<
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
            BaseReferences<_$AppDatabase, $ProvidersTable, ProviderData>,
          ),
          ProviderData,
          PrefetchHooks Function()
        > {
  $$ProvidersTableTableManager(_$AppDatabase db, $ProvidersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProvidersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProvidersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProvidersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<ProviderType> type = const Value.absent(),
                Value<String> apiKey = const Value.absent(),
                Value<String?> baseUrl = const Value.absent(),
                Value<List<String>> supportedModels = const Value.absent(),
                Value<Map<String, String>> customHeaders = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProvidersCompanion(
                id: id,
                name: name,
                type: type,
                apiKey: apiKey,
                baseUrl: baseUrl,
                supportedModels: supportedModels,
                customHeaders: customHeaders,
                isEnabled: isEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required ProviderType type,
                required String apiKey,
                Value<String?> baseUrl = const Value.absent(),
                required List<String> supportedModels,
                required Map<String, String> customHeaders,
                Value<bool> isEnabled = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProvidersCompanion.insert(
                id: id,
                name: name,
                type: type,
                apiKey: apiKey,
                baseUrl: baseUrl,
                supportedModels: supportedModels,
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
        ),
      );
}

typedef $$ProvidersTableProcessedTableManager =
    ProcessedTableManager<
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
        BaseReferences<_$AppDatabase, $ProvidersTable, ProviderData>,
      ),
      ProviderData,
      PrefetchHooks Function()
    >;
typedef $$AssistantsTableCreateCompanionBuilder =
    AssistantsCompanion Function({
      required String id,
      required String name,
      required String description,
      Value<String> avatar,
      required String systemPrompt,
      required String providerId,
      required String modelName,
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
      Value<bool> enableWebSearch,
      Value<bool> enableCodeExecution,
      Value<bool> enableImageGeneration,
      Value<bool> isEnabled,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AssistantsTableUpdateCompanionBuilder =
    AssistantsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> description,
      Value<String> avatar,
      Value<String> systemPrompt,
      Value<String> providerId,
      Value<String> modelName,
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
      Value<bool> enableWebSearch,
      Value<bool> enableCodeExecution,
      Value<bool> enableImageGeneration,
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
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get topP => $composableBuilder(
    column: $table.topP,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxTokens => $composableBuilder(
    column: $table.maxTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contextLength => $composableBuilder(
    column: $table.contextLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get streamOutput => $composableBuilder(
    column: $table.streamOutput,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get frequencyPenalty => $composableBuilder(
    column: $table.frequencyPenalty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get presencePenalty => $composableBuilder(
    column: $table.presencePenalty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, String>,
    Map<String, String>,
    String
  >
  get customHeaders => $composableBuilder(
    column: $table.customHeaders,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>,
    Map<String, dynamic>,
    String
  >
  get customBody => $composableBuilder(
    column: $table.customBody,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get stopSequences => $composableBuilder(
    column: $table.stopSequences,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get enableWebSearch => $composableBuilder(
    column: $table.enableWebSearch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableCodeExecution => $composableBuilder(
    column: $table.enableCodeExecution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableImageGeneration => $composableBuilder(
    column: $table.enableImageGeneration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
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
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get topP => $composableBuilder(
    column: $table.topP,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxTokens => $composableBuilder(
    column: $table.maxTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contextLength => $composableBuilder(
    column: $table.contextLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get streamOutput => $composableBuilder(
    column: $table.streamOutput,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get frequencyPenalty => $composableBuilder(
    column: $table.frequencyPenalty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get presencePenalty => $composableBuilder(
    column: $table.presencePenalty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customHeaders => $composableBuilder(
    column: $table.customHeaders,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customBody => $composableBuilder(
    column: $table.customBody,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stopSequences => $composableBuilder(
    column: $table.stopSequences,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableWebSearch => $composableBuilder(
    column: $table.enableWebSearch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableCodeExecution => $composableBuilder(
    column: $table.enableCodeExecution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableImageGeneration => $composableBuilder(
    column: $table.enableImageGeneration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
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
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<String> get systemPrompt => $composableBuilder(
    column: $table.systemPrompt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => column,
  );

  GeneratedColumn<double> get topP =>
      $composableBuilder(column: $table.topP, builder: (column) => column);

  GeneratedColumn<int> get maxTokens =>
      $composableBuilder(column: $table.maxTokens, builder: (column) => column);

  GeneratedColumn<int> get contextLength => $composableBuilder(
    column: $table.contextLength,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get streamOutput => $composableBuilder(
    column: $table.streamOutput,
    builder: (column) => column,
  );

  GeneratedColumn<double> get frequencyPenalty => $composableBuilder(
    column: $table.frequencyPenalty,
    builder: (column) => column,
  );

  GeneratedColumn<double> get presencePenalty => $composableBuilder(
    column: $table.presencePenalty,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Map<String, String>, String>
  get customHeaders => $composableBuilder(
    column: $table.customHeaders,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  get customBody => $composableBuilder(
    column: $table.customBody,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get stopSequences =>
      $composableBuilder(
        column: $table.stopSequences,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get enableWebSearch => $composableBuilder(
    column: $table.enableWebSearch,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableCodeExecution => $composableBuilder(
    column: $table.enableCodeExecution,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableImageGeneration => $composableBuilder(
    column: $table.enableImageGeneration,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AssistantsTableTableManager
    extends
        RootTableManager<
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
            BaseReferences<_$AppDatabase, $AssistantsTable, AssistantData>,
          ),
          AssistantData,
          PrefetchHooks Function()
        > {
  $$AssistantsTableTableManager(_$AppDatabase db, $AssistantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssistantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssistantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssistantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> avatar = const Value.absent(),
                Value<String> systemPrompt = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> modelName = const Value.absent(),
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
                Value<bool> enableWebSearch = const Value.absent(),
                Value<bool> enableCodeExecution = const Value.absent(),
                Value<bool> enableImageGeneration = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssistantsCompanion(
                id: id,
                name: name,
                description: description,
                avatar: avatar,
                systemPrompt: systemPrompt,
                providerId: providerId,
                modelName: modelName,
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
                enableWebSearch: enableWebSearch,
                enableCodeExecution: enableCodeExecution,
                enableImageGeneration: enableImageGeneration,
                isEnabled: isEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String description,
                Value<String> avatar = const Value.absent(),
                required String systemPrompt,
                required String providerId,
                required String modelName,
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
                Value<bool> enableWebSearch = const Value.absent(),
                Value<bool> enableCodeExecution = const Value.absent(),
                Value<bool> enableImageGeneration = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AssistantsCompanion.insert(
                id: id,
                name: name,
                description: description,
                avatar: avatar,
                systemPrompt: systemPrompt,
                providerId: providerId,
                modelName: modelName,
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
                enableWebSearch: enableWebSearch,
                enableCodeExecution: enableCodeExecution,
                enableImageGeneration: enableImageGeneration,
                isEnabled: isEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssistantsTableProcessedTableManager =
    ProcessedTableManager<
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
        BaseReferences<_$AppDatabase, $AssistantsTable, AssistantData>,
      ),
      AssistantData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProvidersTableTableManager get providers =>
      $$ProvidersTableTableManager(_db, _db.providers);
  $$AssistantsTableTableManager get assistants =>
      $$AssistantsTableTableManager(_db, _db.assistants);
}
