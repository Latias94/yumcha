// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assistant_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AssistantState {
// === Loading State ===
  /// Whether assistants are currently loading
  bool get isLoading => throw _privateConstructorUsedError;

  /// Whether assistants have been initialized
  bool get isInitialized => throw _privateConstructorUsedError;

  /// Assistant loading error
  String? get error =>
      throw _privateConstructorUsedError; // === Assistant Management ===
  /// All available assistants
  List<AssistantConfig> get assistants => throw _privateConstructorUsedError;

  /// Currently selected assistant
  AssistantConfig? get selectedAssistant => throw _privateConstructorUsedError;

  /// Default assistant (fallback when no assistant is selected)
  AssistantConfig? get defaultAssistant => throw _privateConstructorUsedError;

  /// Recently used assistants
  List<String> get recentAssistantIds => throw _privateConstructorUsedError;

  /// Favorite assistant IDs
  Set<String> get favoriteAssistantIds =>
      throw _privateConstructorUsedError; // === Assistant Organization ===
  /// Assistant tags/categories
  List<String> get availableTags => throw _privateConstructorUsedError;

  /// Tag order for display
  List<String> get tagOrder => throw _privateConstructorUsedError;

  /// Collapsed tags in UI
  Map<String, bool> get collapsedTags => throw _privateConstructorUsedError;

  /// Assistant sorting preference
  AssistantSortBy get sortBy => throw _privateConstructorUsedError;

  /// Sort order (ascending/descending)
  bool get sortAscending =>
      throw _privateConstructorUsedError; // === Assistant Operations ===
  /// Assistants currently being created
  Set<String> get creatingAssistants => throw _privateConstructorUsedError;

  /// Assistants currently being updated
  Set<String> get updatingAssistants => throw _privateConstructorUsedError;

  /// Assistants currently being deleted
  Set<String> get deletingAssistants => throw _privateConstructorUsedError;

  /// Assistant operation errors
  Map<String, String> get operationErrors =>
      throw _privateConstructorUsedError; // === Model Management ===
  /// Available models for assistants
  List<ModelInfo> get availableModels => throw _privateConstructorUsedError;

  /// Model selection state
  String? get selectedModelId => throw _privateConstructorUsedError;

  /// Model loading state
  bool get isLoadingModels =>
      throw _privateConstructorUsedError; // === Assistant Templates ===
  /// Available assistant templates
  List<AssistantTemplate> get templates => throw _privateConstructorUsedError;

  /// Template categories
  List<String> get templateCategories => throw _privateConstructorUsedError;

  /// Whether templates are loading
  bool get isLoadingTemplates =>
      throw _privateConstructorUsedError; // === Search and Filter ===
  /// Search query for assistants
  String get searchQuery => throw _privateConstructorUsedError;

  /// Active filter tags
  Set<String> get activeFilterTags => throw _privateConstructorUsedError;

  /// Show only enabled assistants
  bool get showOnlyEnabled => throw _privateConstructorUsedError;

  /// Show only favorite assistants
  bool get showOnlyFavorites =>
      throw _privateConstructorUsedError; // === Statistics ===
  /// Total number of assistants
  int get totalAssistants => throw _privateConstructorUsedError;

  /// Number of enabled assistants
  int get enabledAssistantCount => throw _privateConstructorUsedError;

  /// Number of custom assistants
  int get customAssistants => throw _privateConstructorUsedError;

  /// Assistant usage statistics
  Map<String, AssistantUsageStats> get usageStats =>
      throw _privateConstructorUsedError; // === Import/Export ===
  /// Whether import/export is in progress
  bool get isImportExportInProgress => throw _privateConstructorUsedError;

  /// Import/export progress (0.0 to 1.0)
  double get importExportProgress => throw _privateConstructorUsedError;

  /// Import/export error
  String? get importExportError =>
      throw _privateConstructorUsedError; // === Performance ===
  /// Last update timestamp
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Cache expiry time
  DateTime? get cacheExpiry => throw _privateConstructorUsedError;

  /// Whether cache is valid
  bool get isCacheValid => throw _privateConstructorUsedError;

  /// Create a copy of AssistantState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssistantStateCopyWith<AssistantState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssistantStateCopyWith<$Res> {
  factory $AssistantStateCopyWith(
          AssistantState value, $Res Function(AssistantState) then) =
      _$AssistantStateCopyWithImpl<$Res, AssistantState>;
  @useResult
  $Res call(
      {bool isLoading,
      bool isInitialized,
      String? error,
      List<AssistantConfig> assistants,
      AssistantConfig? selectedAssistant,
      AssistantConfig? defaultAssistant,
      List<String> recentAssistantIds,
      Set<String> favoriteAssistantIds,
      List<String> availableTags,
      List<String> tagOrder,
      Map<String, bool> collapsedTags,
      AssistantSortBy sortBy,
      bool sortAscending,
      Set<String> creatingAssistants,
      Set<String> updatingAssistants,
      Set<String> deletingAssistants,
      Map<String, String> operationErrors,
      List<ModelInfo> availableModels,
      String? selectedModelId,
      bool isLoadingModels,
      List<AssistantTemplate> templates,
      List<String> templateCategories,
      bool isLoadingTemplates,
      String searchQuery,
      Set<String> activeFilterTags,
      bool showOnlyEnabled,
      bool showOnlyFavorites,
      int totalAssistants,
      int enabledAssistantCount,
      int customAssistants,
      Map<String, AssistantUsageStats> usageStats,
      bool isImportExportInProgress,
      double importExportProgress,
      String? importExportError,
      DateTime? lastUpdated,
      DateTime? cacheExpiry,
      bool isCacheValid});

  $AssistantConfigCopyWith<$Res>? get selectedAssistant;
  $AssistantConfigCopyWith<$Res>? get defaultAssistant;
}

/// @nodoc
class _$AssistantStateCopyWithImpl<$Res, $Val extends AssistantState>
    implements $AssistantStateCopyWith<$Res> {
  _$AssistantStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssistantState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isInitialized = null,
    Object? error = freezed,
    Object? assistants = null,
    Object? selectedAssistant = freezed,
    Object? defaultAssistant = freezed,
    Object? recentAssistantIds = null,
    Object? favoriteAssistantIds = null,
    Object? availableTags = null,
    Object? tagOrder = null,
    Object? collapsedTags = null,
    Object? sortBy = null,
    Object? sortAscending = null,
    Object? creatingAssistants = null,
    Object? updatingAssistants = null,
    Object? deletingAssistants = null,
    Object? operationErrors = null,
    Object? availableModels = null,
    Object? selectedModelId = freezed,
    Object? isLoadingModels = null,
    Object? templates = null,
    Object? templateCategories = null,
    Object? isLoadingTemplates = null,
    Object? searchQuery = null,
    Object? activeFilterTags = null,
    Object? showOnlyEnabled = null,
    Object? showOnlyFavorites = null,
    Object? totalAssistants = null,
    Object? enabledAssistantCount = null,
    Object? customAssistants = null,
    Object? usageStats = null,
    Object? isImportExportInProgress = null,
    Object? importExportProgress = null,
    Object? importExportError = freezed,
    Object? lastUpdated = freezed,
    Object? cacheExpiry = freezed,
    Object? isCacheValid = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      assistants: null == assistants
          ? _value.assistants
          : assistants // ignore: cast_nullable_to_non_nullable
              as List<AssistantConfig>,
      selectedAssistant: freezed == selectedAssistant
          ? _value.selectedAssistant
          : selectedAssistant // ignore: cast_nullable_to_non_nullable
              as AssistantConfig?,
      defaultAssistant: freezed == defaultAssistant
          ? _value.defaultAssistant
          : defaultAssistant // ignore: cast_nullable_to_non_nullable
              as AssistantConfig?,
      recentAssistantIds: null == recentAssistantIds
          ? _value.recentAssistantIds
          : recentAssistantIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      favoriteAssistantIds: null == favoriteAssistantIds
          ? _value.favoriteAssistantIds
          : favoriteAssistantIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      availableTags: null == availableTags
          ? _value.availableTags
          : availableTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tagOrder: null == tagOrder
          ? _value.tagOrder
          : tagOrder // ignore: cast_nullable_to_non_nullable
              as List<String>,
      collapsedTags: null == collapsedTags
          ? _value.collapsedTags
          : collapsedTags // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as AssistantSortBy,
      sortAscending: null == sortAscending
          ? _value.sortAscending
          : sortAscending // ignore: cast_nullable_to_non_nullable
              as bool,
      creatingAssistants: null == creatingAssistants
          ? _value.creatingAssistants
          : creatingAssistants // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      updatingAssistants: null == updatingAssistants
          ? _value.updatingAssistants
          : updatingAssistants // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      deletingAssistants: null == deletingAssistants
          ? _value.deletingAssistants
          : deletingAssistants // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      operationErrors: null == operationErrors
          ? _value.operationErrors
          : operationErrors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      availableModels: null == availableModels
          ? _value.availableModels
          : availableModels // ignore: cast_nullable_to_non_nullable
              as List<ModelInfo>,
      selectedModelId: freezed == selectedModelId
          ? _value.selectedModelId
          : selectedModelId // ignore: cast_nullable_to_non_nullable
              as String?,
      isLoadingModels: null == isLoadingModels
          ? _value.isLoadingModels
          : isLoadingModels // ignore: cast_nullable_to_non_nullable
              as bool,
      templates: null == templates
          ? _value.templates
          : templates // ignore: cast_nullable_to_non_nullable
              as List<AssistantTemplate>,
      templateCategories: null == templateCategories
          ? _value.templateCategories
          : templateCategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isLoadingTemplates: null == isLoadingTemplates
          ? _value.isLoadingTemplates
          : isLoadingTemplates // ignore: cast_nullable_to_non_nullable
              as bool,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      activeFilterTags: null == activeFilterTags
          ? _value.activeFilterTags
          : activeFilterTags // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      showOnlyEnabled: null == showOnlyEnabled
          ? _value.showOnlyEnabled
          : showOnlyEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      showOnlyFavorites: null == showOnlyFavorites
          ? _value.showOnlyFavorites
          : showOnlyFavorites // ignore: cast_nullable_to_non_nullable
              as bool,
      totalAssistants: null == totalAssistants
          ? _value.totalAssistants
          : totalAssistants // ignore: cast_nullable_to_non_nullable
              as int,
      enabledAssistantCount: null == enabledAssistantCount
          ? _value.enabledAssistantCount
          : enabledAssistantCount // ignore: cast_nullable_to_non_nullable
              as int,
      customAssistants: null == customAssistants
          ? _value.customAssistants
          : customAssistants // ignore: cast_nullable_to_non_nullable
              as int,
      usageStats: null == usageStats
          ? _value.usageStats
          : usageStats // ignore: cast_nullable_to_non_nullable
              as Map<String, AssistantUsageStats>,
      isImportExportInProgress: null == isImportExportInProgress
          ? _value.isImportExportInProgress
          : isImportExportInProgress // ignore: cast_nullable_to_non_nullable
              as bool,
      importExportProgress: null == importExportProgress
          ? _value.importExportProgress
          : importExportProgress // ignore: cast_nullable_to_non_nullable
              as double,
      importExportError: freezed == importExportError
          ? _value.importExportError
          : importExportError // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cacheExpiry: freezed == cacheExpiry
          ? _value.cacheExpiry
          : cacheExpiry // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isCacheValid: null == isCacheValid
          ? _value.isCacheValid
          : isCacheValid // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of AssistantState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AssistantConfigCopyWith<$Res>? get selectedAssistant {
    if (_value.selectedAssistant == null) {
      return null;
    }

    return $AssistantConfigCopyWith<$Res>(_value.selectedAssistant!, (value) {
      return _then(_value.copyWith(selectedAssistant: value) as $Val);
    });
  }

  /// Create a copy of AssistantState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AssistantConfigCopyWith<$Res>? get defaultAssistant {
    if (_value.defaultAssistant == null) {
      return null;
    }

    return $AssistantConfigCopyWith<$Res>(_value.defaultAssistant!, (value) {
      return _then(_value.copyWith(defaultAssistant: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AssistantStateImplCopyWith<$Res>
    implements $AssistantStateCopyWith<$Res> {
  factory _$$AssistantStateImplCopyWith(_$AssistantStateImpl value,
          $Res Function(_$AssistantStateImpl) then) =
      __$$AssistantStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isInitialized,
      String? error,
      List<AssistantConfig> assistants,
      AssistantConfig? selectedAssistant,
      AssistantConfig? defaultAssistant,
      List<String> recentAssistantIds,
      Set<String> favoriteAssistantIds,
      List<String> availableTags,
      List<String> tagOrder,
      Map<String, bool> collapsedTags,
      AssistantSortBy sortBy,
      bool sortAscending,
      Set<String> creatingAssistants,
      Set<String> updatingAssistants,
      Set<String> deletingAssistants,
      Map<String, String> operationErrors,
      List<ModelInfo> availableModels,
      String? selectedModelId,
      bool isLoadingModels,
      List<AssistantTemplate> templates,
      List<String> templateCategories,
      bool isLoadingTemplates,
      String searchQuery,
      Set<String> activeFilterTags,
      bool showOnlyEnabled,
      bool showOnlyFavorites,
      int totalAssistants,
      int enabledAssistantCount,
      int customAssistants,
      Map<String, AssistantUsageStats> usageStats,
      bool isImportExportInProgress,
      double importExportProgress,
      String? importExportError,
      DateTime? lastUpdated,
      DateTime? cacheExpiry,
      bool isCacheValid});

  @override
  $AssistantConfigCopyWith<$Res>? get selectedAssistant;
  @override
  $AssistantConfigCopyWith<$Res>? get defaultAssistant;
}

/// @nodoc
class __$$AssistantStateImplCopyWithImpl<$Res>
    extends _$AssistantStateCopyWithImpl<$Res, _$AssistantStateImpl>
    implements _$$AssistantStateImplCopyWith<$Res> {
  __$$AssistantStateImplCopyWithImpl(
      _$AssistantStateImpl _value, $Res Function(_$AssistantStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AssistantState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isInitialized = null,
    Object? error = freezed,
    Object? assistants = null,
    Object? selectedAssistant = freezed,
    Object? defaultAssistant = freezed,
    Object? recentAssistantIds = null,
    Object? favoriteAssistantIds = null,
    Object? availableTags = null,
    Object? tagOrder = null,
    Object? collapsedTags = null,
    Object? sortBy = null,
    Object? sortAscending = null,
    Object? creatingAssistants = null,
    Object? updatingAssistants = null,
    Object? deletingAssistants = null,
    Object? operationErrors = null,
    Object? availableModels = null,
    Object? selectedModelId = freezed,
    Object? isLoadingModels = null,
    Object? templates = null,
    Object? templateCategories = null,
    Object? isLoadingTemplates = null,
    Object? searchQuery = null,
    Object? activeFilterTags = null,
    Object? showOnlyEnabled = null,
    Object? showOnlyFavorites = null,
    Object? totalAssistants = null,
    Object? enabledAssistantCount = null,
    Object? customAssistants = null,
    Object? usageStats = null,
    Object? isImportExportInProgress = null,
    Object? importExportProgress = null,
    Object? importExportError = freezed,
    Object? lastUpdated = freezed,
    Object? cacheExpiry = freezed,
    Object? isCacheValid = null,
  }) {
    return _then(_$AssistantStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      assistants: null == assistants
          ? _value._assistants
          : assistants // ignore: cast_nullable_to_non_nullable
              as List<AssistantConfig>,
      selectedAssistant: freezed == selectedAssistant
          ? _value.selectedAssistant
          : selectedAssistant // ignore: cast_nullable_to_non_nullable
              as AssistantConfig?,
      defaultAssistant: freezed == defaultAssistant
          ? _value.defaultAssistant
          : defaultAssistant // ignore: cast_nullable_to_non_nullable
              as AssistantConfig?,
      recentAssistantIds: null == recentAssistantIds
          ? _value._recentAssistantIds
          : recentAssistantIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      favoriteAssistantIds: null == favoriteAssistantIds
          ? _value._favoriteAssistantIds
          : favoriteAssistantIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      availableTags: null == availableTags
          ? _value._availableTags
          : availableTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tagOrder: null == tagOrder
          ? _value._tagOrder
          : tagOrder // ignore: cast_nullable_to_non_nullable
              as List<String>,
      collapsedTags: null == collapsedTags
          ? _value._collapsedTags
          : collapsedTags // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as AssistantSortBy,
      sortAscending: null == sortAscending
          ? _value.sortAscending
          : sortAscending // ignore: cast_nullable_to_non_nullable
              as bool,
      creatingAssistants: null == creatingAssistants
          ? _value._creatingAssistants
          : creatingAssistants // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      updatingAssistants: null == updatingAssistants
          ? _value._updatingAssistants
          : updatingAssistants // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      deletingAssistants: null == deletingAssistants
          ? _value._deletingAssistants
          : deletingAssistants // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      operationErrors: null == operationErrors
          ? _value._operationErrors
          : operationErrors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      availableModels: null == availableModels
          ? _value._availableModels
          : availableModels // ignore: cast_nullable_to_non_nullable
              as List<ModelInfo>,
      selectedModelId: freezed == selectedModelId
          ? _value.selectedModelId
          : selectedModelId // ignore: cast_nullable_to_non_nullable
              as String?,
      isLoadingModels: null == isLoadingModels
          ? _value.isLoadingModels
          : isLoadingModels // ignore: cast_nullable_to_non_nullable
              as bool,
      templates: null == templates
          ? _value._templates
          : templates // ignore: cast_nullable_to_non_nullable
              as List<AssistantTemplate>,
      templateCategories: null == templateCategories
          ? _value._templateCategories
          : templateCategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isLoadingTemplates: null == isLoadingTemplates
          ? _value.isLoadingTemplates
          : isLoadingTemplates // ignore: cast_nullable_to_non_nullable
              as bool,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      activeFilterTags: null == activeFilterTags
          ? _value._activeFilterTags
          : activeFilterTags // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      showOnlyEnabled: null == showOnlyEnabled
          ? _value.showOnlyEnabled
          : showOnlyEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      showOnlyFavorites: null == showOnlyFavorites
          ? _value.showOnlyFavorites
          : showOnlyFavorites // ignore: cast_nullable_to_non_nullable
              as bool,
      totalAssistants: null == totalAssistants
          ? _value.totalAssistants
          : totalAssistants // ignore: cast_nullable_to_non_nullable
              as int,
      enabledAssistantCount: null == enabledAssistantCount
          ? _value.enabledAssistantCount
          : enabledAssistantCount // ignore: cast_nullable_to_non_nullable
              as int,
      customAssistants: null == customAssistants
          ? _value.customAssistants
          : customAssistants // ignore: cast_nullable_to_non_nullable
              as int,
      usageStats: null == usageStats
          ? _value._usageStats
          : usageStats // ignore: cast_nullable_to_non_nullable
              as Map<String, AssistantUsageStats>,
      isImportExportInProgress: null == isImportExportInProgress
          ? _value.isImportExportInProgress
          : isImportExportInProgress // ignore: cast_nullable_to_non_nullable
              as bool,
      importExportProgress: null == importExportProgress
          ? _value.importExportProgress
          : importExportProgress // ignore: cast_nullable_to_non_nullable
              as double,
      importExportError: freezed == importExportError
          ? _value.importExportError
          : importExportError // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cacheExpiry: freezed == cacheExpiry
          ? _value.cacheExpiry
          : cacheExpiry // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isCacheValid: null == isCacheValid
          ? _value.isCacheValid
          : isCacheValid // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$AssistantStateImpl extends _AssistantState {
  const _$AssistantStateImpl(
      {this.isLoading = false,
      this.isInitialized = false,
      this.error = null,
      final List<AssistantConfig> assistants = const [],
      this.selectedAssistant = null,
      this.defaultAssistant = null,
      final List<String> recentAssistantIds = const [],
      final Set<String> favoriteAssistantIds = const {},
      final List<String> availableTags = const [],
      final List<String> tagOrder = const [],
      final Map<String, bool> collapsedTags = const {},
      this.sortBy = AssistantSortBy.name,
      this.sortAscending = true,
      final Set<String> creatingAssistants = const {},
      final Set<String> updatingAssistants = const {},
      final Set<String> deletingAssistants = const {},
      final Map<String, String> operationErrors = const {},
      final List<ModelInfo> availableModels = const [],
      this.selectedModelId = null,
      this.isLoadingModels = false,
      final List<AssistantTemplate> templates = const [],
      final List<String> templateCategories = const [],
      this.isLoadingTemplates = false,
      this.searchQuery = '',
      final Set<String> activeFilterTags = const {},
      this.showOnlyEnabled = false,
      this.showOnlyFavorites = false,
      this.totalAssistants = 0,
      this.enabledAssistantCount = 0,
      this.customAssistants = 0,
      final Map<String, AssistantUsageStats> usageStats = const {},
      this.isImportExportInProgress = false,
      this.importExportProgress = 0.0,
      this.importExportError = null,
      this.lastUpdated = null,
      this.cacheExpiry = null,
      this.isCacheValid = true})
      : _assistants = assistants,
        _recentAssistantIds = recentAssistantIds,
        _favoriteAssistantIds = favoriteAssistantIds,
        _availableTags = availableTags,
        _tagOrder = tagOrder,
        _collapsedTags = collapsedTags,
        _creatingAssistants = creatingAssistants,
        _updatingAssistants = updatingAssistants,
        _deletingAssistants = deletingAssistants,
        _operationErrors = operationErrors,
        _availableModels = availableModels,
        _templates = templates,
        _templateCategories = templateCategories,
        _activeFilterTags = activeFilterTags,
        _usageStats = usageStats,
        super._();

// === Loading State ===
  /// Whether assistants are currently loading
  @override
  @JsonKey()
  final bool isLoading;

  /// Whether assistants have been initialized
  @override
  @JsonKey()
  final bool isInitialized;

  /// Assistant loading error
  @override
  @JsonKey()
  final String? error;
// === Assistant Management ===
  /// All available assistants
  final List<AssistantConfig> _assistants;
// === Assistant Management ===
  /// All available assistants
  @override
  @JsonKey()
  List<AssistantConfig> get assistants {
    if (_assistants is EqualUnmodifiableListView) return _assistants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assistants);
  }

  /// Currently selected assistant
  @override
  @JsonKey()
  final AssistantConfig? selectedAssistant;

  /// Default assistant (fallback when no assistant is selected)
  @override
  @JsonKey()
  final AssistantConfig? defaultAssistant;

  /// Recently used assistants
  final List<String> _recentAssistantIds;

  /// Recently used assistants
  @override
  @JsonKey()
  List<String> get recentAssistantIds {
    if (_recentAssistantIds is EqualUnmodifiableListView)
      return _recentAssistantIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentAssistantIds);
  }

  /// Favorite assistant IDs
  final Set<String> _favoriteAssistantIds;

  /// Favorite assistant IDs
  @override
  @JsonKey()
  Set<String> get favoriteAssistantIds {
    if (_favoriteAssistantIds is EqualUnmodifiableSetView)
      return _favoriteAssistantIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_favoriteAssistantIds);
  }

// === Assistant Organization ===
  /// Assistant tags/categories
  final List<String> _availableTags;
// === Assistant Organization ===
  /// Assistant tags/categories
  @override
  @JsonKey()
  List<String> get availableTags {
    if (_availableTags is EqualUnmodifiableListView) return _availableTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableTags);
  }

  /// Tag order for display
  final List<String> _tagOrder;

  /// Tag order for display
  @override
  @JsonKey()
  List<String> get tagOrder {
    if (_tagOrder is EqualUnmodifiableListView) return _tagOrder;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tagOrder);
  }

  /// Collapsed tags in UI
  final Map<String, bool> _collapsedTags;

  /// Collapsed tags in UI
  @override
  @JsonKey()
  Map<String, bool> get collapsedTags {
    if (_collapsedTags is EqualUnmodifiableMapView) return _collapsedTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_collapsedTags);
  }

  /// Assistant sorting preference
  @override
  @JsonKey()
  final AssistantSortBy sortBy;

  /// Sort order (ascending/descending)
  @override
  @JsonKey()
  final bool sortAscending;
// === Assistant Operations ===
  /// Assistants currently being created
  final Set<String> _creatingAssistants;
// === Assistant Operations ===
  /// Assistants currently being created
  @override
  @JsonKey()
  Set<String> get creatingAssistants {
    if (_creatingAssistants is EqualUnmodifiableSetView)
      return _creatingAssistants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_creatingAssistants);
  }

  /// Assistants currently being updated
  final Set<String> _updatingAssistants;

  /// Assistants currently being updated
  @override
  @JsonKey()
  Set<String> get updatingAssistants {
    if (_updatingAssistants is EqualUnmodifiableSetView)
      return _updatingAssistants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_updatingAssistants);
  }

  /// Assistants currently being deleted
  final Set<String> _deletingAssistants;

  /// Assistants currently being deleted
  @override
  @JsonKey()
  Set<String> get deletingAssistants {
    if (_deletingAssistants is EqualUnmodifiableSetView)
      return _deletingAssistants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_deletingAssistants);
  }

  /// Assistant operation errors
  final Map<String, String> _operationErrors;

  /// Assistant operation errors
  @override
  @JsonKey()
  Map<String, String> get operationErrors {
    if (_operationErrors is EqualUnmodifiableMapView) return _operationErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_operationErrors);
  }

// === Model Management ===
  /// Available models for assistants
  final List<ModelInfo> _availableModels;
// === Model Management ===
  /// Available models for assistants
  @override
  @JsonKey()
  List<ModelInfo> get availableModels {
    if (_availableModels is EqualUnmodifiableListView) return _availableModels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableModels);
  }

  /// Model selection state
  @override
  @JsonKey()
  final String? selectedModelId;

  /// Model loading state
  @override
  @JsonKey()
  final bool isLoadingModels;
// === Assistant Templates ===
  /// Available assistant templates
  final List<AssistantTemplate> _templates;
// === Assistant Templates ===
  /// Available assistant templates
  @override
  @JsonKey()
  List<AssistantTemplate> get templates {
    if (_templates is EqualUnmodifiableListView) return _templates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_templates);
  }

  /// Template categories
  final List<String> _templateCategories;

  /// Template categories
  @override
  @JsonKey()
  List<String> get templateCategories {
    if (_templateCategories is EqualUnmodifiableListView)
      return _templateCategories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_templateCategories);
  }

  /// Whether templates are loading
  @override
  @JsonKey()
  final bool isLoadingTemplates;
// === Search and Filter ===
  /// Search query for assistants
  @override
  @JsonKey()
  final String searchQuery;

  /// Active filter tags
  final Set<String> _activeFilterTags;

  /// Active filter tags
  @override
  @JsonKey()
  Set<String> get activeFilterTags {
    if (_activeFilterTags is EqualUnmodifiableSetView) return _activeFilterTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_activeFilterTags);
  }

  /// Show only enabled assistants
  @override
  @JsonKey()
  final bool showOnlyEnabled;

  /// Show only favorite assistants
  @override
  @JsonKey()
  final bool showOnlyFavorites;
// === Statistics ===
  /// Total number of assistants
  @override
  @JsonKey()
  final int totalAssistants;

  /// Number of enabled assistants
  @override
  @JsonKey()
  final int enabledAssistantCount;

  /// Number of custom assistants
  @override
  @JsonKey()
  final int customAssistants;

  /// Assistant usage statistics
  final Map<String, AssistantUsageStats> _usageStats;

  /// Assistant usage statistics
  @override
  @JsonKey()
  Map<String, AssistantUsageStats> get usageStats {
    if (_usageStats is EqualUnmodifiableMapView) return _usageStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_usageStats);
  }

// === Import/Export ===
  /// Whether import/export is in progress
  @override
  @JsonKey()
  final bool isImportExportInProgress;

  /// Import/export progress (0.0 to 1.0)
  @override
  @JsonKey()
  final double importExportProgress;

  /// Import/export error
  @override
  @JsonKey()
  final String? importExportError;
// === Performance ===
  /// Last update timestamp
  @override
  @JsonKey()
  final DateTime? lastUpdated;

  /// Cache expiry time
  @override
  @JsonKey()
  final DateTime? cacheExpiry;

  /// Whether cache is valid
  @override
  @JsonKey()
  final bool isCacheValid;

  @override
  String toString() {
    return 'AssistantState(isLoading: $isLoading, isInitialized: $isInitialized, error: $error, assistants: $assistants, selectedAssistant: $selectedAssistant, defaultAssistant: $defaultAssistant, recentAssistantIds: $recentAssistantIds, favoriteAssistantIds: $favoriteAssistantIds, availableTags: $availableTags, tagOrder: $tagOrder, collapsedTags: $collapsedTags, sortBy: $sortBy, sortAscending: $sortAscending, creatingAssistants: $creatingAssistants, updatingAssistants: $updatingAssistants, deletingAssistants: $deletingAssistants, operationErrors: $operationErrors, availableModels: $availableModels, selectedModelId: $selectedModelId, isLoadingModels: $isLoadingModels, templates: $templates, templateCategories: $templateCategories, isLoadingTemplates: $isLoadingTemplates, searchQuery: $searchQuery, activeFilterTags: $activeFilterTags, showOnlyEnabled: $showOnlyEnabled, showOnlyFavorites: $showOnlyFavorites, totalAssistants: $totalAssistants, enabledAssistantCount: $enabledAssistantCount, customAssistants: $customAssistants, usageStats: $usageStats, isImportExportInProgress: $isImportExportInProgress, importExportProgress: $importExportProgress, importExportError: $importExportError, lastUpdated: $lastUpdated, cacheExpiry: $cacheExpiry, isCacheValid: $isCacheValid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssistantStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other._assistants, _assistants) &&
            (identical(other.selectedAssistant, selectedAssistant) ||
                other.selectedAssistant == selectedAssistant) &&
            (identical(other.defaultAssistant, defaultAssistant) ||
                other.defaultAssistant == defaultAssistant) &&
            const DeepCollectionEquality()
                .equals(other._recentAssistantIds, _recentAssistantIds) &&
            const DeepCollectionEquality()
                .equals(other._favoriteAssistantIds, _favoriteAssistantIds) &&
            const DeepCollectionEquality()
                .equals(other._availableTags, _availableTags) &&
            const DeepCollectionEquality().equals(other._tagOrder, _tagOrder) &&
            const DeepCollectionEquality()
                .equals(other._collapsedTags, _collapsedTags) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.sortAscending, sortAscending) ||
                other.sortAscending == sortAscending) &&
            const DeepCollectionEquality()
                .equals(other._creatingAssistants, _creatingAssistants) &&
            const DeepCollectionEquality()
                .equals(other._updatingAssistants, _updatingAssistants) &&
            const DeepCollectionEquality()
                .equals(other._deletingAssistants, _deletingAssistants) &&
            const DeepCollectionEquality()
                .equals(other._operationErrors, _operationErrors) &&
            const DeepCollectionEquality()
                .equals(other._availableModels, _availableModels) &&
            (identical(other.selectedModelId, selectedModelId) ||
                other.selectedModelId == selectedModelId) &&
            (identical(other.isLoadingModels, isLoadingModels) ||
                other.isLoadingModels == isLoadingModels) &&
            const DeepCollectionEquality()
                .equals(other._templates, _templates) &&
            const DeepCollectionEquality()
                .equals(other._templateCategories, _templateCategories) &&
            (identical(other.isLoadingTemplates, isLoadingTemplates) ||
                other.isLoadingTemplates == isLoadingTemplates) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            const DeepCollectionEquality()
                .equals(other._activeFilterTags, _activeFilterTags) &&
            (identical(other.showOnlyEnabled, showOnlyEnabled) ||
                other.showOnlyEnabled == showOnlyEnabled) &&
            (identical(other.showOnlyFavorites, showOnlyFavorites) ||
                other.showOnlyFavorites == showOnlyFavorites) &&
            (identical(other.totalAssistants, totalAssistants) ||
                other.totalAssistants == totalAssistants) &&
            (identical(other.enabledAssistantCount, enabledAssistantCount) ||
                other.enabledAssistantCount == enabledAssistantCount) &&
            (identical(other.customAssistants, customAssistants) ||
                other.customAssistants == customAssistants) &&
            const DeepCollectionEquality()
                .equals(other._usageStats, _usageStats) &&
            (identical(
                    other.isImportExportInProgress, isImportExportInProgress) ||
                other.isImportExportInProgress == isImportExportInProgress) &&
            (identical(other.importExportProgress, importExportProgress) ||
                other.importExportProgress == importExportProgress) &&
            (identical(other.importExportError, importExportError) ||
                other.importExportError == importExportError) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.cacheExpiry, cacheExpiry) ||
                other.cacheExpiry == cacheExpiry) &&
            (identical(other.isCacheValid, isCacheValid) ||
                other.isCacheValid == isCacheValid));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        isLoading,
        isInitialized,
        error,
        const DeepCollectionEquality().hash(_assistants),
        selectedAssistant,
        defaultAssistant,
        const DeepCollectionEquality().hash(_recentAssistantIds),
        const DeepCollectionEquality().hash(_favoriteAssistantIds),
        const DeepCollectionEquality().hash(_availableTags),
        const DeepCollectionEquality().hash(_tagOrder),
        const DeepCollectionEquality().hash(_collapsedTags),
        sortBy,
        sortAscending,
        const DeepCollectionEquality().hash(_creatingAssistants),
        const DeepCollectionEquality().hash(_updatingAssistants),
        const DeepCollectionEquality().hash(_deletingAssistants),
        const DeepCollectionEquality().hash(_operationErrors),
        const DeepCollectionEquality().hash(_availableModels),
        selectedModelId,
        isLoadingModels,
        const DeepCollectionEquality().hash(_templates),
        const DeepCollectionEquality().hash(_templateCategories),
        isLoadingTemplates,
        searchQuery,
        const DeepCollectionEquality().hash(_activeFilterTags),
        showOnlyEnabled,
        showOnlyFavorites,
        totalAssistants,
        enabledAssistantCount,
        customAssistants,
        const DeepCollectionEquality().hash(_usageStats),
        isImportExportInProgress,
        importExportProgress,
        importExportError,
        lastUpdated,
        cacheExpiry,
        isCacheValid
      ]);

  /// Create a copy of AssistantState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssistantStateImplCopyWith<_$AssistantStateImpl> get copyWith =>
      __$$AssistantStateImplCopyWithImpl<_$AssistantStateImpl>(
          this, _$identity);
}

abstract class _AssistantState extends AssistantState {
  const factory _AssistantState(
      {final bool isLoading,
      final bool isInitialized,
      final String? error,
      final List<AssistantConfig> assistants,
      final AssistantConfig? selectedAssistant,
      final AssistantConfig? defaultAssistant,
      final List<String> recentAssistantIds,
      final Set<String> favoriteAssistantIds,
      final List<String> availableTags,
      final List<String> tagOrder,
      final Map<String, bool> collapsedTags,
      final AssistantSortBy sortBy,
      final bool sortAscending,
      final Set<String> creatingAssistants,
      final Set<String> updatingAssistants,
      final Set<String> deletingAssistants,
      final Map<String, String> operationErrors,
      final List<ModelInfo> availableModels,
      final String? selectedModelId,
      final bool isLoadingModels,
      final List<AssistantTemplate> templates,
      final List<String> templateCategories,
      final bool isLoadingTemplates,
      final String searchQuery,
      final Set<String> activeFilterTags,
      final bool showOnlyEnabled,
      final bool showOnlyFavorites,
      final int totalAssistants,
      final int enabledAssistantCount,
      final int customAssistants,
      final Map<String, AssistantUsageStats> usageStats,
      final bool isImportExportInProgress,
      final double importExportProgress,
      final String? importExportError,
      final DateTime? lastUpdated,
      final DateTime? cacheExpiry,
      final bool isCacheValid}) = _$AssistantStateImpl;
  const _AssistantState._() : super._();

// === Loading State ===
  /// Whether assistants are currently loading
  @override
  bool get isLoading;

  /// Whether assistants have been initialized
  @override
  bool get isInitialized;

  /// Assistant loading error
  @override
  String? get error; // === Assistant Management ===
  /// All available assistants
  @override
  List<AssistantConfig> get assistants;

  /// Currently selected assistant
  @override
  AssistantConfig? get selectedAssistant;

  /// Default assistant (fallback when no assistant is selected)
  @override
  AssistantConfig? get defaultAssistant;

  /// Recently used assistants
  @override
  List<String> get recentAssistantIds;

  /// Favorite assistant IDs
  @override
  Set<String> get favoriteAssistantIds; // === Assistant Organization ===
  /// Assistant tags/categories
  @override
  List<String> get availableTags;

  /// Tag order for display
  @override
  List<String> get tagOrder;

  /// Collapsed tags in UI
  @override
  Map<String, bool> get collapsedTags;

  /// Assistant sorting preference
  @override
  AssistantSortBy get sortBy;

  /// Sort order (ascending/descending)
  @override
  bool get sortAscending; // === Assistant Operations ===
  /// Assistants currently being created
  @override
  Set<String> get creatingAssistants;

  /// Assistants currently being updated
  @override
  Set<String> get updatingAssistants;

  /// Assistants currently being deleted
  @override
  Set<String> get deletingAssistants;

  /// Assistant operation errors
  @override
  Map<String, String> get operationErrors; // === Model Management ===
  /// Available models for assistants
  @override
  List<ModelInfo> get availableModels;

  /// Model selection state
  @override
  String? get selectedModelId;

  /// Model loading state
  @override
  bool get isLoadingModels; // === Assistant Templates ===
  /// Available assistant templates
  @override
  List<AssistantTemplate> get templates;

  /// Template categories
  @override
  List<String> get templateCategories;

  /// Whether templates are loading
  @override
  bool get isLoadingTemplates; // === Search and Filter ===
  /// Search query for assistants
  @override
  String get searchQuery;

  /// Active filter tags
  @override
  Set<String> get activeFilterTags;

  /// Show only enabled assistants
  @override
  bool get showOnlyEnabled;

  /// Show only favorite assistants
  @override
  bool get showOnlyFavorites; // === Statistics ===
  /// Total number of assistants
  @override
  int get totalAssistants;

  /// Number of enabled assistants
  @override
  int get enabledAssistantCount;

  /// Number of custom assistants
  @override
  int get customAssistants;

  /// Assistant usage statistics
  @override
  Map<String, AssistantUsageStats> get usageStats; // === Import/Export ===
  /// Whether import/export is in progress
  @override
  bool get isImportExportInProgress;

  /// Import/export progress (0.0 to 1.0)
  @override
  double get importExportProgress;

  /// Import/export error
  @override
  String? get importExportError; // === Performance ===
  /// Last update timestamp
  @override
  DateTime? get lastUpdated;

  /// Cache expiry time
  @override
  DateTime? get cacheExpiry;

  /// Whether cache is valid
  @override
  bool get isCacheValid;

  /// Create a copy of AssistantState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssistantStateImplCopyWith<_$AssistantStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AssistantConfig {
  /// Unique assistant ID
  String get id => throw _privateConstructorUsedError;

  /// Assistant name
  String get name => throw _privateConstructorUsedError;

  /// Assistant description
  String get description => throw _privateConstructorUsedError;

  /// Assistant avatar (emoji or image path)
  String get avatar => throw _privateConstructorUsedError;

  /// System prompt
  String get systemPrompt => throw _privateConstructorUsedError;

  /// Assistant tags/categories
  List<String> get tags => throw _privateConstructorUsedError;

  /// Whether assistant is enabled
  bool get isEnabled => throw _privateConstructorUsedError;

  /// Whether this is a custom assistant
  bool get isCustom => throw _privateConstructorUsedError;

  /// Assistant settings
  AssistantSettings get settings => throw _privateConstructorUsedError;

  /// Associated model ID
  String? get modelId => throw _privateConstructorUsedError;

  /// Creation timestamp
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Last update timestamp
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Last used timestamp
  DateTime? get lastUsedAt => throw _privateConstructorUsedError;

  /// Assistant metadata
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Create a copy of AssistantConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssistantConfigCopyWith<AssistantConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssistantConfigCopyWith<$Res> {
  factory $AssistantConfigCopyWith(
          AssistantConfig value, $Res Function(AssistantConfig) then) =
      _$AssistantConfigCopyWithImpl<$Res, AssistantConfig>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String avatar,
      String systemPrompt,
      List<String> tags,
      bool isEnabled,
      bool isCustom,
      AssistantSettings settings,
      String? modelId,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? lastUsedAt,
      Map<String, dynamic> metadata});

  $AssistantSettingsCopyWith<$Res> get settings;
}

/// @nodoc
class _$AssistantConfigCopyWithImpl<$Res, $Val extends AssistantConfig>
    implements $AssistantConfigCopyWith<$Res> {
  _$AssistantConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssistantConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? avatar = null,
    Object? systemPrompt = null,
    Object? tags = null,
    Object? isEnabled = null,
    Object? isCustom = null,
    Object? settings = null,
    Object? modelId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastUsedAt = freezed,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: null == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String,
      systemPrompt: null == systemPrompt
          ? _value.systemPrompt
          : systemPrompt // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      isCustom: null == isCustom
          ? _value.isCustom
          : isCustom // ignore: cast_nullable_to_non_nullable
              as bool,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as AssistantSettings,
      modelId: freezed == modelId
          ? _value.modelId
          : modelId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUsedAt: freezed == lastUsedAt
          ? _value.lastUsedAt
          : lastUsedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }

  /// Create a copy of AssistantConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AssistantSettingsCopyWith<$Res> get settings {
    return $AssistantSettingsCopyWith<$Res>(_value.settings, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AssistantConfigImplCopyWith<$Res>
    implements $AssistantConfigCopyWith<$Res> {
  factory _$$AssistantConfigImplCopyWith(_$AssistantConfigImpl value,
          $Res Function(_$AssistantConfigImpl) then) =
      __$$AssistantConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String avatar,
      String systemPrompt,
      List<String> tags,
      bool isEnabled,
      bool isCustom,
      AssistantSettings settings,
      String? modelId,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? lastUsedAt,
      Map<String, dynamic> metadata});

  @override
  $AssistantSettingsCopyWith<$Res> get settings;
}

/// @nodoc
class __$$AssistantConfigImplCopyWithImpl<$Res>
    extends _$AssistantConfigCopyWithImpl<$Res, _$AssistantConfigImpl>
    implements _$$AssistantConfigImplCopyWith<$Res> {
  __$$AssistantConfigImplCopyWithImpl(
      _$AssistantConfigImpl _value, $Res Function(_$AssistantConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of AssistantConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? avatar = null,
    Object? systemPrompt = null,
    Object? tags = null,
    Object? isEnabled = null,
    Object? isCustom = null,
    Object? settings = null,
    Object? modelId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastUsedAt = freezed,
    Object? metadata = null,
  }) {
    return _then(_$AssistantConfigImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: null == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String,
      systemPrompt: null == systemPrompt
          ? _value.systemPrompt
          : systemPrompt // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      isCustom: null == isCustom
          ? _value.isCustom
          : isCustom // ignore: cast_nullable_to_non_nullable
              as bool,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as AssistantSettings,
      modelId: freezed == modelId
          ? _value.modelId
          : modelId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUsedAt: freezed == lastUsedAt
          ? _value.lastUsedAt
          : lastUsedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$AssistantConfigImpl implements _AssistantConfig {
  const _$AssistantConfigImpl(
      {required this.id,
      required this.name,
      this.description = '',
      this.avatar = '🤖',
      required this.systemPrompt,
      final List<String> tags = const [],
      this.isEnabled = true,
      this.isCustom = true,
      this.settings = const AssistantSettings(),
      this.modelId = null,
      required this.createdAt,
      required this.updatedAt,
      this.lastUsedAt = null,
      final Map<String, dynamic> metadata = const {}})
      : _tags = tags,
        _metadata = metadata;

  /// Unique assistant ID
  @override
  final String id;

  /// Assistant name
  @override
  final String name;

  /// Assistant description
  @override
  @JsonKey()
  final String description;

  /// Assistant avatar (emoji or image path)
  @override
  @JsonKey()
  final String avatar;

  /// System prompt
  @override
  final String systemPrompt;

  /// Assistant tags/categories
  final List<String> _tags;

  /// Assistant tags/categories
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  /// Whether assistant is enabled
  @override
  @JsonKey()
  final bool isEnabled;

  /// Whether this is a custom assistant
  @override
  @JsonKey()
  final bool isCustom;

  /// Assistant settings
  @override
  @JsonKey()
  final AssistantSettings settings;

  /// Associated model ID
  @override
  @JsonKey()
  final String? modelId;

  /// Creation timestamp
  @override
  final DateTime createdAt;

  /// Last update timestamp
  @override
  final DateTime updatedAt;

  /// Last used timestamp
  @override
  @JsonKey()
  final DateTime? lastUsedAt;

  /// Assistant metadata
  final Map<String, dynamic> _metadata;

  /// Assistant metadata
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'AssistantConfig(id: $id, name: $name, description: $description, avatar: $avatar, systemPrompt: $systemPrompt, tags: $tags, isEnabled: $isEnabled, isCustom: $isCustom, settings: $settings, modelId: $modelId, createdAt: $createdAt, updatedAt: $updatedAt, lastUsedAt: $lastUsedAt, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssistantConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.systemPrompt, systemPrompt) ||
                other.systemPrompt == systemPrompt) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.isCustom, isCustom) ||
                other.isCustom == isCustom) &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            (identical(other.modelId, modelId) || other.modelId == modelId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastUsedAt, lastUsedAt) ||
                other.lastUsedAt == lastUsedAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      avatar,
      systemPrompt,
      const DeepCollectionEquality().hash(_tags),
      isEnabled,
      isCustom,
      settings,
      modelId,
      createdAt,
      updatedAt,
      lastUsedAt,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of AssistantConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssistantConfigImplCopyWith<_$AssistantConfigImpl> get copyWith =>
      __$$AssistantConfigImplCopyWithImpl<_$AssistantConfigImpl>(
          this, _$identity);
}

abstract class _AssistantConfig implements AssistantConfig {
  const factory _AssistantConfig(
      {required final String id,
      required final String name,
      final String description,
      final String avatar,
      required final String systemPrompt,
      final List<String> tags,
      final bool isEnabled,
      final bool isCustom,
      final AssistantSettings settings,
      final String? modelId,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final DateTime? lastUsedAt,
      final Map<String, dynamic> metadata}) = _$AssistantConfigImpl;

  /// Unique assistant ID
  @override
  String get id;

  /// Assistant name
  @override
  String get name;

  /// Assistant description
  @override
  String get description;

  /// Assistant avatar (emoji or image path)
  @override
  String get avatar;

  /// System prompt
  @override
  String get systemPrompt;

  /// Assistant tags/categories
  @override
  List<String> get tags;

  /// Whether assistant is enabled
  @override
  bool get isEnabled;

  /// Whether this is a custom assistant
  @override
  bool get isCustom;

  /// Assistant settings
  @override
  AssistantSettings get settings;

  /// Associated model ID
  @override
  String? get modelId;

  /// Creation timestamp
  @override
  DateTime get createdAt;

  /// Last update timestamp
  @override
  DateTime get updatedAt;

  /// Last used timestamp
  @override
  DateTime? get lastUsedAt;

  /// Assistant metadata
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of AssistantConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssistantConfigImplCopyWith<_$AssistantConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AssistantSettings {
  /// Temperature (0.0 to 2.0)
  double get temperature => throw _privateConstructorUsedError;

  /// Top P (0.0 to 1.0)
  double get topP => throw _privateConstructorUsedError;

  /// Max tokens
  int get maxTokens => throw _privateConstructorUsedError;

  /// Context length
  int get contextLength => throw _privateConstructorUsedError;

  /// Whether to stream output
  bool get streamOutput => throw _privateConstructorUsedError;

  /// Frequency penalty
  double? get frequencyPenalty => throw _privateConstructorUsedError;

  /// Presence penalty
  double? get presencePenalty => throw _privateConstructorUsedError;

  /// Stop sequences
  List<String> get stopSequences => throw _privateConstructorUsedError;

  /// Custom parameters
  Map<String, dynamic> get customParameters =>
      throw _privateConstructorUsedError;

  /// Create a copy of AssistantSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssistantSettingsCopyWith<AssistantSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssistantSettingsCopyWith<$Res> {
  factory $AssistantSettingsCopyWith(
          AssistantSettings value, $Res Function(AssistantSettings) then) =
      _$AssistantSettingsCopyWithImpl<$Res, AssistantSettings>;
  @useResult
  $Res call(
      {double temperature,
      double topP,
      int maxTokens,
      int contextLength,
      bool streamOutput,
      double? frequencyPenalty,
      double? presencePenalty,
      List<String> stopSequences,
      Map<String, dynamic> customParameters});
}

/// @nodoc
class _$AssistantSettingsCopyWithImpl<$Res, $Val extends AssistantSettings>
    implements $AssistantSettingsCopyWith<$Res> {
  _$AssistantSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssistantSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperature = null,
    Object? topP = null,
    Object? maxTokens = null,
    Object? contextLength = null,
    Object? streamOutput = null,
    Object? frequencyPenalty = freezed,
    Object? presencePenalty = freezed,
    Object? stopSequences = null,
    Object? customParameters = null,
  }) {
    return _then(_value.copyWith(
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      topP: null == topP
          ? _value.topP
          : topP // ignore: cast_nullable_to_non_nullable
              as double,
      maxTokens: null == maxTokens
          ? _value.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int,
      contextLength: null == contextLength
          ? _value.contextLength
          : contextLength // ignore: cast_nullable_to_non_nullable
              as int,
      streamOutput: null == streamOutput
          ? _value.streamOutput
          : streamOutput // ignore: cast_nullable_to_non_nullable
              as bool,
      frequencyPenalty: freezed == frequencyPenalty
          ? _value.frequencyPenalty
          : frequencyPenalty // ignore: cast_nullable_to_non_nullable
              as double?,
      presencePenalty: freezed == presencePenalty
          ? _value.presencePenalty
          : presencePenalty // ignore: cast_nullable_to_non_nullable
              as double?,
      stopSequences: null == stopSequences
          ? _value.stopSequences
          : stopSequences // ignore: cast_nullable_to_non_nullable
              as List<String>,
      customParameters: null == customParameters
          ? _value.customParameters
          : customParameters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssistantSettingsImplCopyWith<$Res>
    implements $AssistantSettingsCopyWith<$Res> {
  factory _$$AssistantSettingsImplCopyWith(_$AssistantSettingsImpl value,
          $Res Function(_$AssistantSettingsImpl) then) =
      __$$AssistantSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double temperature,
      double topP,
      int maxTokens,
      int contextLength,
      bool streamOutput,
      double? frequencyPenalty,
      double? presencePenalty,
      List<String> stopSequences,
      Map<String, dynamic> customParameters});
}

/// @nodoc
class __$$AssistantSettingsImplCopyWithImpl<$Res>
    extends _$AssistantSettingsCopyWithImpl<$Res, _$AssistantSettingsImpl>
    implements _$$AssistantSettingsImplCopyWith<$Res> {
  __$$AssistantSettingsImplCopyWithImpl(_$AssistantSettingsImpl _value,
      $Res Function(_$AssistantSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of AssistantSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperature = null,
    Object? topP = null,
    Object? maxTokens = null,
    Object? contextLength = null,
    Object? streamOutput = null,
    Object? frequencyPenalty = freezed,
    Object? presencePenalty = freezed,
    Object? stopSequences = null,
    Object? customParameters = null,
  }) {
    return _then(_$AssistantSettingsImpl(
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      topP: null == topP
          ? _value.topP
          : topP // ignore: cast_nullable_to_non_nullable
              as double,
      maxTokens: null == maxTokens
          ? _value.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int,
      contextLength: null == contextLength
          ? _value.contextLength
          : contextLength // ignore: cast_nullable_to_non_nullable
              as int,
      streamOutput: null == streamOutput
          ? _value.streamOutput
          : streamOutput // ignore: cast_nullable_to_non_nullable
              as bool,
      frequencyPenalty: freezed == frequencyPenalty
          ? _value.frequencyPenalty
          : frequencyPenalty // ignore: cast_nullable_to_non_nullable
              as double?,
      presencePenalty: freezed == presencePenalty
          ? _value.presencePenalty
          : presencePenalty // ignore: cast_nullable_to_non_nullable
              as double?,
      stopSequences: null == stopSequences
          ? _value._stopSequences
          : stopSequences // ignore: cast_nullable_to_non_nullable
              as List<String>,
      customParameters: null == customParameters
          ? _value._customParameters
          : customParameters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$AssistantSettingsImpl implements _AssistantSettings {
  const _$AssistantSettingsImpl(
      {this.temperature = 0.7,
      this.topP = 1.0,
      this.maxTokens = 2048,
      this.contextLength = 10,
      this.streamOutput = true,
      this.frequencyPenalty = null,
      this.presencePenalty = null,
      final List<String> stopSequences = const [],
      final Map<String, dynamic> customParameters = const {}})
      : _stopSequences = stopSequences,
        _customParameters = customParameters;

  /// Temperature (0.0 to 2.0)
  @override
  @JsonKey()
  final double temperature;

  /// Top P (0.0 to 1.0)
  @override
  @JsonKey()
  final double topP;

  /// Max tokens
  @override
  @JsonKey()
  final int maxTokens;

  /// Context length
  @override
  @JsonKey()
  final int contextLength;

  /// Whether to stream output
  @override
  @JsonKey()
  final bool streamOutput;

  /// Frequency penalty
  @override
  @JsonKey()
  final double? frequencyPenalty;

  /// Presence penalty
  @override
  @JsonKey()
  final double? presencePenalty;

  /// Stop sequences
  final List<String> _stopSequences;

  /// Stop sequences
  @override
  @JsonKey()
  List<String> get stopSequences {
    if (_stopSequences is EqualUnmodifiableListView) return _stopSequences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stopSequences);
  }

  /// Custom parameters
  final Map<String, dynamic> _customParameters;

  /// Custom parameters
  @override
  @JsonKey()
  Map<String, dynamic> get customParameters {
    if (_customParameters is EqualUnmodifiableMapView) return _customParameters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_customParameters);
  }

  @override
  String toString() {
    return 'AssistantSettings(temperature: $temperature, topP: $topP, maxTokens: $maxTokens, contextLength: $contextLength, streamOutput: $streamOutput, frequencyPenalty: $frequencyPenalty, presencePenalty: $presencePenalty, stopSequences: $stopSequences, customParameters: $customParameters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssistantSettingsImpl &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.topP, topP) || other.topP == topP) &&
            (identical(other.maxTokens, maxTokens) ||
                other.maxTokens == maxTokens) &&
            (identical(other.contextLength, contextLength) ||
                other.contextLength == contextLength) &&
            (identical(other.streamOutput, streamOutput) ||
                other.streamOutput == streamOutput) &&
            (identical(other.frequencyPenalty, frequencyPenalty) ||
                other.frequencyPenalty == frequencyPenalty) &&
            (identical(other.presencePenalty, presencePenalty) ||
                other.presencePenalty == presencePenalty) &&
            const DeepCollectionEquality()
                .equals(other._stopSequences, _stopSequences) &&
            const DeepCollectionEquality()
                .equals(other._customParameters, _customParameters));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      temperature,
      topP,
      maxTokens,
      contextLength,
      streamOutput,
      frequencyPenalty,
      presencePenalty,
      const DeepCollectionEquality().hash(_stopSequences),
      const DeepCollectionEquality().hash(_customParameters));

  /// Create a copy of AssistantSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssistantSettingsImplCopyWith<_$AssistantSettingsImpl> get copyWith =>
      __$$AssistantSettingsImplCopyWithImpl<_$AssistantSettingsImpl>(
          this, _$identity);
}

abstract class _AssistantSettings implements AssistantSettings {
  const factory _AssistantSettings(
      {final double temperature,
      final double topP,
      final int maxTokens,
      final int contextLength,
      final bool streamOutput,
      final double? frequencyPenalty,
      final double? presencePenalty,
      final List<String> stopSequences,
      final Map<String, dynamic> customParameters}) = _$AssistantSettingsImpl;

  /// Temperature (0.0 to 2.0)
  @override
  double get temperature;

  /// Top P (0.0 to 1.0)
  @override
  double get topP;

  /// Max tokens
  @override
  int get maxTokens;

  /// Context length
  @override
  int get contextLength;

  /// Whether to stream output
  @override
  bool get streamOutput;

  /// Frequency penalty
  @override
  double? get frequencyPenalty;

  /// Presence penalty
  @override
  double? get presencePenalty;

  /// Stop sequences
  @override
  List<String> get stopSequences;

  /// Custom parameters
  @override
  Map<String, dynamic> get customParameters;

  /// Create a copy of AssistantSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssistantSettingsImplCopyWith<_$AssistantSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ModelInfo {
  /// Model ID
  String get id => throw _privateConstructorUsedError;

  /// Model name
  String get name => throw _privateConstructorUsedError;

  /// Provider ID
  String get providerId => throw _privateConstructorUsedError;

  /// Model description
  String get description => throw _privateConstructorUsedError;

  /// Whether model supports streaming
  bool get supportsStreaming => throw _privateConstructorUsedError;

  /// Whether model supports function calling
  bool get supportsFunctionCalling => throw _privateConstructorUsedError;

  /// Whether model supports vision
  bool get supportsVision => throw _privateConstructorUsedError;

  /// Maximum context length
  int get maxContextLength => throw _privateConstructorUsedError;

  /// Model capabilities
  List<String> get capabilities => throw _privateConstructorUsedError;

  /// Model metadata
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Create a copy of ModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModelInfoCopyWith<ModelInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModelInfoCopyWith<$Res> {
  factory $ModelInfoCopyWith(ModelInfo value, $Res Function(ModelInfo) then) =
      _$ModelInfoCopyWithImpl<$Res, ModelInfo>;
  @useResult
  $Res call(
      {String id,
      String name,
      String providerId,
      String description,
      bool supportsStreaming,
      bool supportsFunctionCalling,
      bool supportsVision,
      int maxContextLength,
      List<String> capabilities,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$ModelInfoCopyWithImpl<$Res, $Val extends ModelInfo>
    implements $ModelInfoCopyWith<$Res> {
  _$ModelInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? providerId = null,
    Object? description = null,
    Object? supportsStreaming = null,
    Object? supportsFunctionCalling = null,
    Object? supportsVision = null,
    Object? maxContextLength = null,
    Object? capabilities = null,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      providerId: null == providerId
          ? _value.providerId
          : providerId // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      supportsStreaming: null == supportsStreaming
          ? _value.supportsStreaming
          : supportsStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      supportsFunctionCalling: null == supportsFunctionCalling
          ? _value.supportsFunctionCalling
          : supportsFunctionCalling // ignore: cast_nullable_to_non_nullable
              as bool,
      supportsVision: null == supportsVision
          ? _value.supportsVision
          : supportsVision // ignore: cast_nullable_to_non_nullable
              as bool,
      maxContextLength: null == maxContextLength
          ? _value.maxContextLength
          : maxContextLength // ignore: cast_nullable_to_non_nullable
              as int,
      capabilities: null == capabilities
          ? _value.capabilities
          : capabilities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModelInfoImplCopyWith<$Res>
    implements $ModelInfoCopyWith<$Res> {
  factory _$$ModelInfoImplCopyWith(
          _$ModelInfoImpl value, $Res Function(_$ModelInfoImpl) then) =
      __$$ModelInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String providerId,
      String description,
      bool supportsStreaming,
      bool supportsFunctionCalling,
      bool supportsVision,
      int maxContextLength,
      List<String> capabilities,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$ModelInfoImplCopyWithImpl<$Res>
    extends _$ModelInfoCopyWithImpl<$Res, _$ModelInfoImpl>
    implements _$$ModelInfoImplCopyWith<$Res> {
  __$$ModelInfoImplCopyWithImpl(
      _$ModelInfoImpl _value, $Res Function(_$ModelInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? providerId = null,
    Object? description = null,
    Object? supportsStreaming = null,
    Object? supportsFunctionCalling = null,
    Object? supportsVision = null,
    Object? maxContextLength = null,
    Object? capabilities = null,
    Object? metadata = null,
  }) {
    return _then(_$ModelInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      providerId: null == providerId
          ? _value.providerId
          : providerId // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      supportsStreaming: null == supportsStreaming
          ? _value.supportsStreaming
          : supportsStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      supportsFunctionCalling: null == supportsFunctionCalling
          ? _value.supportsFunctionCalling
          : supportsFunctionCalling // ignore: cast_nullable_to_non_nullable
              as bool,
      supportsVision: null == supportsVision
          ? _value.supportsVision
          : supportsVision // ignore: cast_nullable_to_non_nullable
              as bool,
      maxContextLength: null == maxContextLength
          ? _value.maxContextLength
          : maxContextLength // ignore: cast_nullable_to_non_nullable
              as int,
      capabilities: null == capabilities
          ? _value._capabilities
          : capabilities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$ModelInfoImpl implements _ModelInfo {
  const _$ModelInfoImpl(
      {required this.id,
      required this.name,
      required this.providerId,
      this.description = '',
      this.supportsStreaming = true,
      this.supportsFunctionCalling = false,
      this.supportsVision = false,
      this.maxContextLength = 4096,
      final List<String> capabilities = const [],
      final Map<String, dynamic> metadata = const {}})
      : _capabilities = capabilities,
        _metadata = metadata;

  /// Model ID
  @override
  final String id;

  /// Model name
  @override
  final String name;

  /// Provider ID
  @override
  final String providerId;

  /// Model description
  @override
  @JsonKey()
  final String description;

  /// Whether model supports streaming
  @override
  @JsonKey()
  final bool supportsStreaming;

  /// Whether model supports function calling
  @override
  @JsonKey()
  final bool supportsFunctionCalling;

  /// Whether model supports vision
  @override
  @JsonKey()
  final bool supportsVision;

  /// Maximum context length
  @override
  @JsonKey()
  final int maxContextLength;

  /// Model capabilities
  final List<String> _capabilities;

  /// Model capabilities
  @override
  @JsonKey()
  List<String> get capabilities {
    if (_capabilities is EqualUnmodifiableListView) return _capabilities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_capabilities);
  }

  /// Model metadata
  final Map<String, dynamic> _metadata;

  /// Model metadata
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'ModelInfo(id: $id, name: $name, providerId: $providerId, description: $description, supportsStreaming: $supportsStreaming, supportsFunctionCalling: $supportsFunctionCalling, supportsVision: $supportsVision, maxContextLength: $maxContextLength, capabilities: $capabilities, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.supportsStreaming, supportsStreaming) ||
                other.supportsStreaming == supportsStreaming) &&
            (identical(
                    other.supportsFunctionCalling, supportsFunctionCalling) ||
                other.supportsFunctionCalling == supportsFunctionCalling) &&
            (identical(other.supportsVision, supportsVision) ||
                other.supportsVision == supportsVision) &&
            (identical(other.maxContextLength, maxContextLength) ||
                other.maxContextLength == maxContextLength) &&
            const DeepCollectionEquality()
                .equals(other._capabilities, _capabilities) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      providerId,
      description,
      supportsStreaming,
      supportsFunctionCalling,
      supportsVision,
      maxContextLength,
      const DeepCollectionEquality().hash(_capabilities),
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of ModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModelInfoImplCopyWith<_$ModelInfoImpl> get copyWith =>
      __$$ModelInfoImplCopyWithImpl<_$ModelInfoImpl>(this, _$identity);
}

abstract class _ModelInfo implements ModelInfo {
  const factory _ModelInfo(
      {required final String id,
      required final String name,
      required final String providerId,
      final String description,
      final bool supportsStreaming,
      final bool supportsFunctionCalling,
      final bool supportsVision,
      final int maxContextLength,
      final List<String> capabilities,
      final Map<String, dynamic> metadata}) = _$ModelInfoImpl;

  /// Model ID
  @override
  String get id;

  /// Model name
  @override
  String get name;

  /// Provider ID
  @override
  String get providerId;

  /// Model description
  @override
  String get description;

  /// Whether model supports streaming
  @override
  bool get supportsStreaming;

  /// Whether model supports function calling
  @override
  bool get supportsFunctionCalling;

  /// Whether model supports vision
  @override
  bool get supportsVision;

  /// Maximum context length
  @override
  int get maxContextLength;

  /// Model capabilities
  @override
  List<String> get capabilities;

  /// Model metadata
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of ModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModelInfoImplCopyWith<_$ModelInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AssistantTemplate {
  /// Template ID
  String get id => throw _privateConstructorUsedError;

  /// Template name
  String get name => throw _privateConstructorUsedError;

  /// Template description
  String get description => throw _privateConstructorUsedError;

  /// Template category
  String get category => throw _privateConstructorUsedError;

  /// Template avatar
  String get avatar => throw _privateConstructorUsedError;

  /// Template system prompt
  String get systemPrompt => throw _privateConstructorUsedError;

  /// Template tags
  List<String> get tags => throw _privateConstructorUsedError;

  /// Default settings
  AssistantSettings get defaultSettings => throw _privateConstructorUsedError;

  /// Whether template is built-in
  bool get isBuiltIn => throw _privateConstructorUsedError;

  /// Template metadata
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Create a copy of AssistantTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssistantTemplateCopyWith<AssistantTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssistantTemplateCopyWith<$Res> {
  factory $AssistantTemplateCopyWith(
          AssistantTemplate value, $Res Function(AssistantTemplate) then) =
      _$AssistantTemplateCopyWithImpl<$Res, AssistantTemplate>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String category,
      String avatar,
      String systemPrompt,
      List<String> tags,
      AssistantSettings defaultSettings,
      bool isBuiltIn,
      Map<String, dynamic> metadata});

  $AssistantSettingsCopyWith<$Res> get defaultSettings;
}

/// @nodoc
class _$AssistantTemplateCopyWithImpl<$Res, $Val extends AssistantTemplate>
    implements $AssistantTemplateCopyWith<$Res> {
  _$AssistantTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssistantTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? category = null,
    Object? avatar = null,
    Object? systemPrompt = null,
    Object? tags = null,
    Object? defaultSettings = null,
    Object? isBuiltIn = null,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: null == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String,
      systemPrompt: null == systemPrompt
          ? _value.systemPrompt
          : systemPrompt // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      defaultSettings: null == defaultSettings
          ? _value.defaultSettings
          : defaultSettings // ignore: cast_nullable_to_non_nullable
              as AssistantSettings,
      isBuiltIn: null == isBuiltIn
          ? _value.isBuiltIn
          : isBuiltIn // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }

  /// Create a copy of AssistantTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AssistantSettingsCopyWith<$Res> get defaultSettings {
    return $AssistantSettingsCopyWith<$Res>(_value.defaultSettings, (value) {
      return _then(_value.copyWith(defaultSettings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AssistantTemplateImplCopyWith<$Res>
    implements $AssistantTemplateCopyWith<$Res> {
  factory _$$AssistantTemplateImplCopyWith(_$AssistantTemplateImpl value,
          $Res Function(_$AssistantTemplateImpl) then) =
      __$$AssistantTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String category,
      String avatar,
      String systemPrompt,
      List<String> tags,
      AssistantSettings defaultSettings,
      bool isBuiltIn,
      Map<String, dynamic> metadata});

  @override
  $AssistantSettingsCopyWith<$Res> get defaultSettings;
}

/// @nodoc
class __$$AssistantTemplateImplCopyWithImpl<$Res>
    extends _$AssistantTemplateCopyWithImpl<$Res, _$AssistantTemplateImpl>
    implements _$$AssistantTemplateImplCopyWith<$Res> {
  __$$AssistantTemplateImplCopyWithImpl(_$AssistantTemplateImpl _value,
      $Res Function(_$AssistantTemplateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AssistantTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? category = null,
    Object? avatar = null,
    Object? systemPrompt = null,
    Object? tags = null,
    Object? defaultSettings = null,
    Object? isBuiltIn = null,
    Object? metadata = null,
  }) {
    return _then(_$AssistantTemplateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: null == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String,
      systemPrompt: null == systemPrompt
          ? _value.systemPrompt
          : systemPrompt // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      defaultSettings: null == defaultSettings
          ? _value.defaultSettings
          : defaultSettings // ignore: cast_nullable_to_non_nullable
              as AssistantSettings,
      isBuiltIn: null == isBuiltIn
          ? _value.isBuiltIn
          : isBuiltIn // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$AssistantTemplateImpl implements _AssistantTemplate {
  const _$AssistantTemplateImpl(
      {required this.id,
      required this.name,
      this.description = '',
      this.category = 'General',
      this.avatar = '🤖',
      required this.systemPrompt,
      final List<String> tags = const [],
      this.defaultSettings = const AssistantSettings(),
      this.isBuiltIn = true,
      final Map<String, dynamic> metadata = const {}})
      : _tags = tags,
        _metadata = metadata;

  /// Template ID
  @override
  final String id;

  /// Template name
  @override
  final String name;

  /// Template description
  @override
  @JsonKey()
  final String description;

  /// Template category
  @override
  @JsonKey()
  final String category;

  /// Template avatar
  @override
  @JsonKey()
  final String avatar;

  /// Template system prompt
  @override
  final String systemPrompt;

  /// Template tags
  final List<String> _tags;

  /// Template tags
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  /// Default settings
  @override
  @JsonKey()
  final AssistantSettings defaultSettings;

  /// Whether template is built-in
  @override
  @JsonKey()
  final bool isBuiltIn;

  /// Template metadata
  final Map<String, dynamic> _metadata;

  /// Template metadata
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'AssistantTemplate(id: $id, name: $name, description: $description, category: $category, avatar: $avatar, systemPrompt: $systemPrompt, tags: $tags, defaultSettings: $defaultSettings, isBuiltIn: $isBuiltIn, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssistantTemplateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.systemPrompt, systemPrompt) ||
                other.systemPrompt == systemPrompt) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.defaultSettings, defaultSettings) ||
                other.defaultSettings == defaultSettings) &&
            (identical(other.isBuiltIn, isBuiltIn) ||
                other.isBuiltIn == isBuiltIn) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      category,
      avatar,
      systemPrompt,
      const DeepCollectionEquality().hash(_tags),
      defaultSettings,
      isBuiltIn,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of AssistantTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssistantTemplateImplCopyWith<_$AssistantTemplateImpl> get copyWith =>
      __$$AssistantTemplateImplCopyWithImpl<_$AssistantTemplateImpl>(
          this, _$identity);
}

abstract class _AssistantTemplate implements AssistantTemplate {
  const factory _AssistantTemplate(
      {required final String id,
      required final String name,
      final String description,
      final String category,
      final String avatar,
      required final String systemPrompt,
      final List<String> tags,
      final AssistantSettings defaultSettings,
      final bool isBuiltIn,
      final Map<String, dynamic> metadata}) = _$AssistantTemplateImpl;

  /// Template ID
  @override
  String get id;

  /// Template name
  @override
  String get name;

  /// Template description
  @override
  String get description;

  /// Template category
  @override
  String get category;

  /// Template avatar
  @override
  String get avatar;

  /// Template system prompt
  @override
  String get systemPrompt;

  /// Template tags
  @override
  List<String> get tags;

  /// Default settings
  @override
  AssistantSettings get defaultSettings;

  /// Whether template is built-in
  @override
  bool get isBuiltIn;

  /// Template metadata
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of AssistantTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssistantTemplateImplCopyWith<_$AssistantTemplateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AssistantUsageStats {
  /// Total usage count
  int get totalUsage => throw _privateConstructorUsedError;

  /// Usage this week
  int get weeklyUsage => throw _privateConstructorUsedError;

  /// Usage this month
  int get monthlyUsage => throw _privateConstructorUsedError;

  /// Last used timestamp
  DateTime? get lastUsed => throw _privateConstructorUsedError;

  /// Average session duration in minutes
  double get averageSessionDuration => throw _privateConstructorUsedError;

  /// Total tokens used
  int get totalTokens => throw _privateConstructorUsedError;

  /// Usage history (date -> count)
  Map<String, int> get usageHistory => throw _privateConstructorUsedError;

  /// Create a copy of AssistantUsageStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssistantUsageStatsCopyWith<AssistantUsageStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssistantUsageStatsCopyWith<$Res> {
  factory $AssistantUsageStatsCopyWith(
          AssistantUsageStats value, $Res Function(AssistantUsageStats) then) =
      _$AssistantUsageStatsCopyWithImpl<$Res, AssistantUsageStats>;
  @useResult
  $Res call(
      {int totalUsage,
      int weeklyUsage,
      int monthlyUsage,
      DateTime? lastUsed,
      double averageSessionDuration,
      int totalTokens,
      Map<String, int> usageHistory});
}

/// @nodoc
class _$AssistantUsageStatsCopyWithImpl<$Res, $Val extends AssistantUsageStats>
    implements $AssistantUsageStatsCopyWith<$Res> {
  _$AssistantUsageStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssistantUsageStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalUsage = null,
    Object? weeklyUsage = null,
    Object? monthlyUsage = null,
    Object? lastUsed = freezed,
    Object? averageSessionDuration = null,
    Object? totalTokens = null,
    Object? usageHistory = null,
  }) {
    return _then(_value.copyWith(
      totalUsage: null == totalUsage
          ? _value.totalUsage
          : totalUsage // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyUsage: null == weeklyUsage
          ? _value.weeklyUsage
          : weeklyUsage // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyUsage: null == monthlyUsage
          ? _value.monthlyUsage
          : monthlyUsage // ignore: cast_nullable_to_non_nullable
              as int,
      lastUsed: freezed == lastUsed
          ? _value.lastUsed
          : lastUsed // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      averageSessionDuration: null == averageSessionDuration
          ? _value.averageSessionDuration
          : averageSessionDuration // ignore: cast_nullable_to_non_nullable
              as double,
      totalTokens: null == totalTokens
          ? _value.totalTokens
          : totalTokens // ignore: cast_nullable_to_non_nullable
              as int,
      usageHistory: null == usageHistory
          ? _value.usageHistory
          : usageHistory // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssistantUsageStatsImplCopyWith<$Res>
    implements $AssistantUsageStatsCopyWith<$Res> {
  factory _$$AssistantUsageStatsImplCopyWith(_$AssistantUsageStatsImpl value,
          $Res Function(_$AssistantUsageStatsImpl) then) =
      __$$AssistantUsageStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalUsage,
      int weeklyUsage,
      int monthlyUsage,
      DateTime? lastUsed,
      double averageSessionDuration,
      int totalTokens,
      Map<String, int> usageHistory});
}

/// @nodoc
class __$$AssistantUsageStatsImplCopyWithImpl<$Res>
    extends _$AssistantUsageStatsCopyWithImpl<$Res, _$AssistantUsageStatsImpl>
    implements _$$AssistantUsageStatsImplCopyWith<$Res> {
  __$$AssistantUsageStatsImplCopyWithImpl(_$AssistantUsageStatsImpl _value,
      $Res Function(_$AssistantUsageStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of AssistantUsageStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalUsage = null,
    Object? weeklyUsage = null,
    Object? monthlyUsage = null,
    Object? lastUsed = freezed,
    Object? averageSessionDuration = null,
    Object? totalTokens = null,
    Object? usageHistory = null,
  }) {
    return _then(_$AssistantUsageStatsImpl(
      totalUsage: null == totalUsage
          ? _value.totalUsage
          : totalUsage // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyUsage: null == weeklyUsage
          ? _value.weeklyUsage
          : weeklyUsage // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyUsage: null == monthlyUsage
          ? _value.monthlyUsage
          : monthlyUsage // ignore: cast_nullable_to_non_nullable
              as int,
      lastUsed: freezed == lastUsed
          ? _value.lastUsed
          : lastUsed // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      averageSessionDuration: null == averageSessionDuration
          ? _value.averageSessionDuration
          : averageSessionDuration // ignore: cast_nullable_to_non_nullable
              as double,
      totalTokens: null == totalTokens
          ? _value.totalTokens
          : totalTokens // ignore: cast_nullable_to_non_nullable
              as int,
      usageHistory: null == usageHistory
          ? _value._usageHistory
          : usageHistory // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

/// @nodoc

class _$AssistantUsageStatsImpl implements _AssistantUsageStats {
  const _$AssistantUsageStatsImpl(
      {this.totalUsage = 0,
      this.weeklyUsage = 0,
      this.monthlyUsage = 0,
      this.lastUsed = null,
      this.averageSessionDuration = 0.0,
      this.totalTokens = 0,
      final Map<String, int> usageHistory = const {}})
      : _usageHistory = usageHistory;

  /// Total usage count
  @override
  @JsonKey()
  final int totalUsage;

  /// Usage this week
  @override
  @JsonKey()
  final int weeklyUsage;

  /// Usage this month
  @override
  @JsonKey()
  final int monthlyUsage;

  /// Last used timestamp
  @override
  @JsonKey()
  final DateTime? lastUsed;

  /// Average session duration in minutes
  @override
  @JsonKey()
  final double averageSessionDuration;

  /// Total tokens used
  @override
  @JsonKey()
  final int totalTokens;

  /// Usage history (date -> count)
  final Map<String, int> _usageHistory;

  /// Usage history (date -> count)
  @override
  @JsonKey()
  Map<String, int> get usageHistory {
    if (_usageHistory is EqualUnmodifiableMapView) return _usageHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_usageHistory);
  }

  @override
  String toString() {
    return 'AssistantUsageStats(totalUsage: $totalUsage, weeklyUsage: $weeklyUsage, monthlyUsage: $monthlyUsage, lastUsed: $lastUsed, averageSessionDuration: $averageSessionDuration, totalTokens: $totalTokens, usageHistory: $usageHistory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssistantUsageStatsImpl &&
            (identical(other.totalUsage, totalUsage) ||
                other.totalUsage == totalUsage) &&
            (identical(other.weeklyUsage, weeklyUsage) ||
                other.weeklyUsage == weeklyUsage) &&
            (identical(other.monthlyUsage, monthlyUsage) ||
                other.monthlyUsage == monthlyUsage) &&
            (identical(other.lastUsed, lastUsed) ||
                other.lastUsed == lastUsed) &&
            (identical(other.averageSessionDuration, averageSessionDuration) ||
                other.averageSessionDuration == averageSessionDuration) &&
            (identical(other.totalTokens, totalTokens) ||
                other.totalTokens == totalTokens) &&
            const DeepCollectionEquality()
                .equals(other._usageHistory, _usageHistory));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalUsage,
      weeklyUsage,
      monthlyUsage,
      lastUsed,
      averageSessionDuration,
      totalTokens,
      const DeepCollectionEquality().hash(_usageHistory));

  /// Create a copy of AssistantUsageStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssistantUsageStatsImplCopyWith<_$AssistantUsageStatsImpl> get copyWith =>
      __$$AssistantUsageStatsImplCopyWithImpl<_$AssistantUsageStatsImpl>(
          this, _$identity);
}

abstract class _AssistantUsageStats implements AssistantUsageStats {
  const factory _AssistantUsageStats(
      {final int totalUsage,
      final int weeklyUsage,
      final int monthlyUsage,
      final DateTime? lastUsed,
      final double averageSessionDuration,
      final int totalTokens,
      final Map<String, int> usageHistory}) = _$AssistantUsageStatsImpl;

  /// Total usage count
  @override
  int get totalUsage;

  /// Usage this week
  @override
  int get weeklyUsage;

  /// Usage this month
  @override
  int get monthlyUsage;

  /// Last used timestamp
  @override
  DateTime? get lastUsed;

  /// Average session duration in minutes
  @override
  double get averageSessionDuration;

  /// Total tokens used
  @override
  int get totalTokens;

  /// Usage history (date -> count)
  @override
  Map<String, int> get usageHistory;

  /// Create a copy of AssistantUsageStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssistantUsageStatsImplCopyWith<_$AssistantUsageStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
