// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_agent_route_ref.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AIAgentRouteRef extends AIAgentRouteRef {
  @override
  final String agentKey;
  @override
  final String? model;
  @override
  final double? temperature;
  @override
  final int? maxTokens;
  @override
  final bool? enabled;

  factory _$AIAgentRouteRef([void Function(AIAgentRouteRefBuilder)? updates]) =>
      (AIAgentRouteRefBuilder()..update(updates))._build();

  _$AIAgentRouteRef._(
      {required this.agentKey,
      this.model,
      this.temperature,
      this.maxTokens,
      this.enabled})
      : super._();
  @override
  AIAgentRouteRef rebuild(void Function(AIAgentRouteRefBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AIAgentRouteRefBuilder toBuilder() => AIAgentRouteRefBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AIAgentRouteRef &&
        agentKey == other.agentKey &&
        model == other.model &&
        temperature == other.temperature &&
        maxTokens == other.maxTokens &&
        enabled == other.enabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, agentKey.hashCode);
    _$hash = $jc(_$hash, model.hashCode);
    _$hash = $jc(_$hash, temperature.hashCode);
    _$hash = $jc(_$hash, maxTokens.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AIAgentRouteRef')
          ..add('agentKey', agentKey)
          ..add('model', model)
          ..add('temperature', temperature)
          ..add('maxTokens', maxTokens)
          ..add('enabled', enabled))
        .toString();
  }
}

class AIAgentRouteRefBuilder
    implements Builder<AIAgentRouteRef, AIAgentRouteRefBuilder> {
  _$AIAgentRouteRef? _$v;

  String? _agentKey;
  String? get agentKey => _$this._agentKey;
  set agentKey(String? agentKey) => _$this._agentKey = agentKey;

  String? _model;
  String? get model => _$this._model;
  set model(String? model) => _$this._model = model;

  double? _temperature;
  double? get temperature => _$this._temperature;
  set temperature(double? temperature) => _$this._temperature = temperature;

  int? _maxTokens;
  int? get maxTokens => _$this._maxTokens;
  set maxTokens(int? maxTokens) => _$this._maxTokens = maxTokens;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  AIAgentRouteRefBuilder() {
    AIAgentRouteRef._defaults(this);
  }

  AIAgentRouteRefBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _agentKey = $v.agentKey;
      _model = $v.model;
      _temperature = $v.temperature;
      _maxTokens = $v.maxTokens;
      _enabled = $v.enabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AIAgentRouteRef other) {
    _$v = other as _$AIAgentRouteRef;
  }

  @override
  void update(void Function(AIAgentRouteRefBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AIAgentRouteRef build() => _build();

  _$AIAgentRouteRef _build() {
    final _$result = _$v ??
        _$AIAgentRouteRef._(
          agentKey: BuiltValueNullFieldError.checkNotNull(
              agentKey, r'AIAgentRouteRef', 'agentKey'),
          model: model,
          temperature: temperature,
          maxTokens: maxTokens,
          enabled: enabled,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
