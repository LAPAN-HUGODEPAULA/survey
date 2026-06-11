// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_agent_upsert.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AIAgentUpsertProviderTypeEnum
    _$aIAgentUpsertProviderTypeEnum_openaiCompatible =
    const AIAgentUpsertProviderTypeEnum._('openaiCompatible');
const AIAgentUpsertProviderTypeEnum _$aIAgentUpsertProviderTypeEnum_glm =
    const AIAgentUpsertProviderTypeEnum._('glm');
const AIAgentUpsertProviderTypeEnum _$aIAgentUpsertProviderTypeEnum_gemini =
    const AIAgentUpsertProviderTypeEnum._('gemini');

AIAgentUpsertProviderTypeEnum _$aIAgentUpsertProviderTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'openaiCompatible':
      return _$aIAgentUpsertProviderTypeEnum_openaiCompatible;
    case 'glm':
      return _$aIAgentUpsertProviderTypeEnum_glm;
    case 'gemini':
      return _$aIAgentUpsertProviderTypeEnum_gemini;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AIAgentUpsertProviderTypeEnum>
    _$aIAgentUpsertProviderTypeEnumValues = BuiltSet<
        AIAgentUpsertProviderTypeEnum>(const <AIAgentUpsertProviderTypeEnum>[
  _$aIAgentUpsertProviderTypeEnum_openaiCompatible,
  _$aIAgentUpsertProviderTypeEnum_glm,
  _$aIAgentUpsertProviderTypeEnum_gemini,
]);

Serializer<AIAgentUpsertProviderTypeEnum>
    _$aIAgentUpsertProviderTypeEnumSerializer =
    _$AIAgentUpsertProviderTypeEnumSerializer();

class _$AIAgentUpsertProviderTypeEnumSerializer
    implements PrimitiveSerializer<AIAgentUpsertProviderTypeEnum> {
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
  final Iterable<Type> types = const <Type>[AIAgentUpsertProviderTypeEnum];
  @override
  final String wireName = 'AIAgentUpsertProviderTypeEnum';

  @override
  Object serialize(
          Serializers serializers, AIAgentUpsertProviderTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AIAgentUpsertProviderTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AIAgentUpsertProviderTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

abstract class AIAgentUpsertBuilder {
  void replace(AIAgentUpsert other);
  void update(void Function(AIAgentUpsertBuilder) updates);
  String? get agentKey;
  set agentKey(String? agentKey);

  String? get name;
  set name(String? name);

  AIAgentUpsertProviderTypeEnum? get providerType;
  set providerType(AIAgentUpsertProviderTypeEnum? providerType);

  String? get baseUrl;
  set baseUrl(String? baseUrl);

  String? get apiKeyEnvVar;
  set apiKeyEnvVar(String? apiKeyEnvVar);

  String? get defaultModel;
  set defaultModel(String? defaultModel);

  bool? get enabled;
  set enabled(bool? enabled);

  bool? get supportsOpenAIChatCompletions;
  set supportsOpenAIChatCompletions(bool? supportsOpenAIChatCompletions);

  bool? get supportsResponseFormat;
  set supportsResponseFormat(bool? supportsResponseFormat);

  bool? get supportsRag;
  set supportsRag(bool? supportsRag);

  String? get notes;
  set notes(String? notes);
}

class _$$AIAgentUpsert extends $AIAgentUpsert {
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

  factory _$$AIAgentUpsert([void Function($AIAgentUpsertBuilder)? updates]) =>
      ($AIAgentUpsertBuilder()..update(updates))._build();

  _$$AIAgentUpsert._(
      {required this.agentKey,
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
  $AIAgentUpsert rebuild(void Function($AIAgentUpsertBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  $AIAgentUpsertBuilder toBuilder() => $AIAgentUpsertBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is $AIAgentUpsert &&
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
    return (newBuiltValueToStringHelper(r'$AIAgentUpsert')
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

class $AIAgentUpsertBuilder
    implements
        Builder<$AIAgentUpsert, $AIAgentUpsertBuilder>,
        AIAgentUpsertBuilder {
  _$$AIAgentUpsert? _$v;

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

  $AIAgentUpsertBuilder() {
    $AIAgentUpsert._defaults(this);
  }

  $AIAgentUpsertBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
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
  void replace(covariant $AIAgentUpsert other) {
    _$v = other as _$$AIAgentUpsert;
  }

  @override
  void update(void Function($AIAgentUpsertBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  $AIAgentUpsert build() => _build();

  _$$AIAgentUpsert _build() {
    final _$result = _$v ??
        _$$AIAgentUpsert._(
          agentKey: BuiltValueNullFieldError.checkNotNull(
              agentKey, r'$AIAgentUpsert', 'agentKey'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'$AIAgentUpsert', 'name'),
          providerType: BuiltValueNullFieldError.checkNotNull(
              providerType, r'$AIAgentUpsert', 'providerType'),
          baseUrl: baseUrl,
          apiKeyEnvVar: BuiltValueNullFieldError.checkNotNull(
              apiKeyEnvVar, r'$AIAgentUpsert', 'apiKeyEnvVar'),
          defaultModel: BuiltValueNullFieldError.checkNotNull(
              defaultModel, r'$AIAgentUpsert', 'defaultModel'),
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
