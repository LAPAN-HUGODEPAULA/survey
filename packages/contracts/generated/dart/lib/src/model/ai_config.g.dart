// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_config.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AIConfigReasoningEffortEnum _$aIConfigReasoningEffortEnum_low =
    const AIConfigReasoningEffortEnum._('low');
const AIConfigReasoningEffortEnum _$aIConfigReasoningEffortEnum_medium =
    const AIConfigReasoningEffortEnum._('medium');
const AIConfigReasoningEffortEnum _$aIConfigReasoningEffortEnum_high =
    const AIConfigReasoningEffortEnum._('high');

AIConfigReasoningEffortEnum _$aIConfigReasoningEffortEnumValueOf(String name) {
  switch (name) {
    case 'low':
      return _$aIConfigReasoningEffortEnum_low;
    case 'medium':
      return _$aIConfigReasoningEffortEnum_medium;
    case 'high':
      return _$aIConfigReasoningEffortEnum_high;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AIConfigReasoningEffortEnum>
    _$aIConfigReasoningEffortEnumValues =
    BuiltSet<AIConfigReasoningEffortEnum>(const <AIConfigReasoningEffortEnum>[
  _$aIConfigReasoningEffortEnum_low,
  _$aIConfigReasoningEffortEnum_medium,
  _$aIConfigReasoningEffortEnum_high,
]);

Serializer<AIConfigReasoningEffortEnum>
    _$aIConfigReasoningEffortEnumSerializer =
    _$AIConfigReasoningEffortEnumSerializer();

class _$AIConfigReasoningEffortEnumSerializer
    implements PrimitiveSerializer<AIConfigReasoningEffortEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'low': 'low',
    'medium': 'medium',
    'high': 'high',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'low': 'low',
    'medium': 'medium',
    'high': 'high',
  };

  @override
  final Iterable<Type> types = const <Type>[AIConfigReasoningEffortEnum];
  @override
  final String wireName = 'AIConfigReasoningEffortEnum';

  @override
  Object serialize(Serializers serializers, AIConfigReasoningEffortEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AIConfigReasoningEffortEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AIConfigReasoningEffortEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AIConfig extends AIConfig {
  @override
  final BuiltList<AIAgentRouteRef>? agentRefs;
  @override
  final String? primaryProvider;
  @override
  final String? primaryModel;
  @override
  final String? fallbackProvider;
  @override
  final String? fallbackModel;
  @override
  final double? temperature;
  @override
  final AIConfigReasoningEffortEnum? reasoningEffort;
  @override
  final bool? enableCaching;

  factory _$AIConfig([void Function(AIConfigBuilder)? updates]) =>
      (AIConfigBuilder()..update(updates))._build();

  _$AIConfig._(
      {this.agentRefs,
      this.primaryProvider,
      this.primaryModel,
      this.fallbackProvider,
      this.fallbackModel,
      this.temperature,
      this.reasoningEffort,
      this.enableCaching})
      : super._();
  @override
  AIConfig rebuild(void Function(AIConfigBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AIConfigBuilder toBuilder() => AIConfigBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AIConfig &&
        agentRefs == other.agentRefs &&
        primaryProvider == other.primaryProvider &&
        primaryModel == other.primaryModel &&
        fallbackProvider == other.fallbackProvider &&
        fallbackModel == other.fallbackModel &&
        temperature == other.temperature &&
        reasoningEffort == other.reasoningEffort &&
        enableCaching == other.enableCaching;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, agentRefs.hashCode);
    _$hash = $jc(_$hash, primaryProvider.hashCode);
    _$hash = $jc(_$hash, primaryModel.hashCode);
    _$hash = $jc(_$hash, fallbackProvider.hashCode);
    _$hash = $jc(_$hash, fallbackModel.hashCode);
    _$hash = $jc(_$hash, temperature.hashCode);
    _$hash = $jc(_$hash, reasoningEffort.hashCode);
    _$hash = $jc(_$hash, enableCaching.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AIConfig')
          ..add('agentRefs', agentRefs)
          ..add('primaryProvider', primaryProvider)
          ..add('primaryModel', primaryModel)
          ..add('fallbackProvider', fallbackProvider)
          ..add('fallbackModel', fallbackModel)
          ..add('temperature', temperature)
          ..add('reasoningEffort', reasoningEffort)
          ..add('enableCaching', enableCaching))
        .toString();
  }
}

class AIConfigBuilder implements Builder<AIConfig, AIConfigBuilder> {
  _$AIConfig? _$v;

  ListBuilder<AIAgentRouteRef>? _agentRefs;
  ListBuilder<AIAgentRouteRef> get agentRefs =>
      _$this._agentRefs ??= ListBuilder<AIAgentRouteRef>();
  set agentRefs(ListBuilder<AIAgentRouteRef>? agentRefs) =>
      _$this._agentRefs = agentRefs;

  String? _primaryProvider;
  String? get primaryProvider => _$this._primaryProvider;
  set primaryProvider(String? primaryProvider) =>
      _$this._primaryProvider = primaryProvider;

  String? _primaryModel;
  String? get primaryModel => _$this._primaryModel;
  set primaryModel(String? primaryModel) => _$this._primaryModel = primaryModel;

  String? _fallbackProvider;
  String? get fallbackProvider => _$this._fallbackProvider;
  set fallbackProvider(String? fallbackProvider) =>
      _$this._fallbackProvider = fallbackProvider;

  String? _fallbackModel;
  String? get fallbackModel => _$this._fallbackModel;
  set fallbackModel(String? fallbackModel) =>
      _$this._fallbackModel = fallbackModel;

  double? _temperature;
  double? get temperature => _$this._temperature;
  set temperature(double? temperature) => _$this._temperature = temperature;

  AIConfigReasoningEffortEnum? _reasoningEffort;
  AIConfigReasoningEffortEnum? get reasoningEffort => _$this._reasoningEffort;
  set reasoningEffort(AIConfigReasoningEffortEnum? reasoningEffort) =>
      _$this._reasoningEffort = reasoningEffort;

  bool? _enableCaching;
  bool? get enableCaching => _$this._enableCaching;
  set enableCaching(bool? enableCaching) =>
      _$this._enableCaching = enableCaching;

  AIConfigBuilder() {
    AIConfig._defaults(this);
  }

  AIConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _agentRefs = $v.agentRefs?.toBuilder();
      _primaryProvider = $v.primaryProvider;
      _primaryModel = $v.primaryModel;
      _fallbackProvider = $v.fallbackProvider;
      _fallbackModel = $v.fallbackModel;
      _temperature = $v.temperature;
      _reasoningEffort = $v.reasoningEffort;
      _enableCaching = $v.enableCaching;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AIConfig other) {
    _$v = other as _$AIConfig;
  }

  @override
  void update(void Function(AIConfigBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AIConfig build() => _build();

  _$AIConfig _build() {
    _$AIConfig _$result;
    try {
      _$result = _$v ??
          _$AIConfig._(
            agentRefs: _agentRefs?.build(),
            primaryProvider: primaryProvider,
            primaryModel: primaryModel,
            fallbackProvider: fallbackProvider,
            fallbackModel: fallbackModel,
            temperature: temperature,
            reasoningEffort: reasoningEffort,
            enableCaching: enableCaching,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'agentRefs';
        _agentRefs?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AIConfig', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
