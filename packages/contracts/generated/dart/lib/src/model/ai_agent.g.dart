// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_agent.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AIAgentProviderTypeEnum _$aIAgentProviderTypeEnum_openaiCompatible =
    const AIAgentProviderTypeEnum._('openaiCompatible');
const AIAgentProviderTypeEnum _$aIAgentProviderTypeEnum_glm =
    const AIAgentProviderTypeEnum._('glm');
const AIAgentProviderTypeEnum _$aIAgentProviderTypeEnum_gemini =
    const AIAgentProviderTypeEnum._('gemini');

AIAgentProviderTypeEnum _$aIAgentProviderTypeEnumValueOf(String name) {
  switch (name) {
    case 'openaiCompatible':
      return _$aIAgentProviderTypeEnum_openaiCompatible;
    case 'glm':
      return _$aIAgentProviderTypeEnum_glm;
    case 'gemini':
      return _$aIAgentProviderTypeEnum_gemini;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AIAgentProviderTypeEnum> _$aIAgentProviderTypeEnumValues =
    BuiltSet<AIAgentProviderTypeEnum>(const <AIAgentProviderTypeEnum>[
  _$aIAgentProviderTypeEnum_openaiCompatible,
  _$aIAgentProviderTypeEnum_glm,
  _$aIAgentProviderTypeEnum_gemini,
]);

Serializer<AIAgentProviderTypeEnum> _$aIAgentProviderTypeEnumSerializer =
    _$AIAgentProviderTypeEnumSerializer();

class _$AIAgentProviderTypeEnumSerializer
    implements PrimitiveSerializer<AIAgentProviderTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'openaiCompatible': 'openai_compatible',
    'glm': 'glm',
    'gemini': 'gemini',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'openai_compatible': 'openaiCompatible',
    'glm': 'glm',
    'gemini': 'gemini',
  };

  @override
  final Iterable<Type> types = const <Type>[AIAgentProviderTypeEnum];
  @override
  final String wireName = 'AIAgentProviderTypeEnum';

  @override
  Object serialize(Serializers serializers, AIAgentProviderTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AIAgentProviderTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AIAgentProviderTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AIAgent extends AIAgent {
  @override
  final DateTime createdAt;
  @override
  final DateTime modifiedAt;
  @override
  final String agentKey;
  @override
  final String name;
  @override
  final AIAgentUpsertProviderTypeEnum providerType;
  @override
  final String? baseUrl;
  @override
  final String apiKeyEnvVar;
  @override
  final String defaultModel;
  @override
  final bool? enabled;
  @override
  final bool? supportsOpenAIChatCompletions;
  @override
  final bool? supportsResponseFormat;
  @override
  final bool? supportsRag;
  @override
  final String? notes;

  factory _$AIAgent([void Function(AIAgentBuilder)? updates]) =>
      (AIAgentBuilder()..update(updates))._build();

  _$AIAgent._(
      {required this.createdAt,
      required this.modifiedAt,
      required this.agentKey,
      required this.name,
      required this.providerType,
      this.baseUrl,
      required this.apiKeyEnvVar,
      required this.defaultModel,
      this.enabled,
      this.supportsOpenAIChatCompletions,
      this.supportsResponseFormat,
      this.supportsRag,
      this.notes})
      : super._();
  @override
  AIAgent rebuild(void Function(AIAgentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AIAgentBuilder toBuilder() => AIAgentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AIAgent &&
        createdAt == other.createdAt &&
        modifiedAt == other.modifiedAt &&
        agentKey == other.agentKey &&
        name == other.name &&
        providerType == other.providerType &&
        baseUrl == other.baseUrl &&
        apiKeyEnvVar == other.apiKeyEnvVar &&
        defaultModel == other.defaultModel &&
        enabled == other.enabled &&
        supportsOpenAIChatCompletions == other.supportsOpenAIChatCompletions &&
        supportsResponseFormat == other.supportsResponseFormat &&
        supportsRag == other.supportsRag &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, modifiedAt.hashCode);
    _$hash = $jc(_$hash, agentKey.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, providerType.hashCode);
    _$hash = $jc(_$hash, baseUrl.hashCode);
    _$hash = $jc(_$hash, apiKeyEnvVar.hashCode);
    _$hash = $jc(_$hash, defaultModel.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, supportsOpenAIChatCompletions.hashCode);
    _$hash = $jc(_$hash, supportsResponseFormat.hashCode);
    _$hash = $jc(_$hash, supportsRag.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AIAgent')
          ..add('createdAt', createdAt)
          ..add('modifiedAt', modifiedAt)
          ..add('agentKey', agentKey)
          ..add('name', name)
          ..add('providerType', providerType)
          ..add('baseUrl', baseUrl)
          ..add('apiKeyEnvVar', apiKeyEnvVar)
          ..add('defaultModel', defaultModel)
          ..add('enabled', enabled)
          ..add('supportsOpenAIChatCompletions', supportsOpenAIChatCompletions)
          ..add('supportsResponseFormat', supportsResponseFormat)
          ..add('supportsRag', supportsRag)
          ..add('notes', notes))
        .toString();
  }
}

class AIAgentBuilder
    implements Builder<AIAgent, AIAgentBuilder>, AIAgentUpsertBuilder {
  _$AIAgent? _$v;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(covariant DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _modifiedAt;
  DateTime? get modifiedAt => _$this._modifiedAt;
  set modifiedAt(covariant DateTime? modifiedAt) =>
      _$this._modifiedAt = modifiedAt;

  String? _agentKey;
  String? get agentKey => _$this._agentKey;
  set agentKey(covariant String? agentKey) => _$this._agentKey = agentKey;

  String? _name;
  String? get name => _$this._name;
  set name(covariant String? name) => _$this._name = name;

  AIAgentUpsertProviderTypeEnum? _providerType;
  AIAgentUpsertProviderTypeEnum? get providerType => _$this._providerType;
  set providerType(covariant AIAgentUpsertProviderTypeEnum? providerType) =>
      _$this._providerType = providerType;

  String? _baseUrl;
  String? get baseUrl => _$this._baseUrl;
  set baseUrl(covariant String? baseUrl) => _$this._baseUrl = baseUrl;

  String? _apiKeyEnvVar;
  String? get apiKeyEnvVar => _$this._apiKeyEnvVar;
  set apiKeyEnvVar(covariant String? apiKeyEnvVar) =>
      _$this._apiKeyEnvVar = apiKeyEnvVar;

  String? _defaultModel;
  String? get defaultModel => _$this._defaultModel;
  set defaultModel(covariant String? defaultModel) =>
      _$this._defaultModel = defaultModel;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(covariant bool? enabled) => _$this._enabled = enabled;

  bool? _supportsOpenAIChatCompletions;
  bool? get supportsOpenAIChatCompletions =>
      _$this._supportsOpenAIChatCompletions;
  set supportsOpenAIChatCompletions(
          covariant bool? supportsOpenAIChatCompletions) =>
      _$this._supportsOpenAIChatCompletions = supportsOpenAIChatCompletions;

  bool? _supportsResponseFormat;
  bool? get supportsResponseFormat => _$this._supportsResponseFormat;
  set supportsResponseFormat(covariant bool? supportsResponseFormat) =>
      _$this._supportsResponseFormat = supportsResponseFormat;

  bool? _supportsRag;
  bool? get supportsRag => _$this._supportsRag;
  set supportsRag(covariant bool? supportsRag) =>
      _$this._supportsRag = supportsRag;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(covariant String? notes) => _$this._notes = notes;

  AIAgentBuilder() {
    AIAgent._defaults(this);
  }

  AIAgentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _createdAt = $v.createdAt;
      _modifiedAt = $v.modifiedAt;
      _agentKey = $v.agentKey;
      _name = $v.name;
      _providerType = $v.providerType;
      _baseUrl = $v.baseUrl;
      _apiKeyEnvVar = $v.apiKeyEnvVar;
      _defaultModel = $v.defaultModel;
      _enabled = $v.enabled;
      _supportsOpenAIChatCompletions = $v.supportsOpenAIChatCompletions;
      _supportsResponseFormat = $v.supportsResponseFormat;
      _supportsRag = $v.supportsRag;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant AIAgent other) {
    _$v = other as _$AIAgent;
  }

  @override
  void update(void Function(AIAgentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AIAgent build() => _build();

  _$AIAgent _build() {
    final _$result = _$v ??
        _$AIAgent._(
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'AIAgent', 'createdAt'),
          modifiedAt: BuiltValueNullFieldError.checkNotNull(
              modifiedAt, r'AIAgent', 'modifiedAt'),
          agentKey: BuiltValueNullFieldError.checkNotNull(
              agentKey, r'AIAgent', 'agentKey'),
          name: BuiltValueNullFieldError.checkNotNull(name, r'AIAgent', 'name'),
          providerType: BuiltValueNullFieldError.checkNotNull(
              providerType, r'AIAgent', 'providerType'),
          baseUrl: baseUrl,
          apiKeyEnvVar: BuiltValueNullFieldError.checkNotNull(
              apiKeyEnvVar, r'AIAgent', 'apiKeyEnvVar'),
          defaultModel: BuiltValueNullFieldError.checkNotNull(
              defaultModel, r'AIAgent', 'defaultModel'),
          enabled: enabled,
          supportsOpenAIChatCompletions: supportsOpenAIChatCompletions,
          supportsResponseFormat: supportsResponseFormat,
          supportsRag: supportsRag,
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
