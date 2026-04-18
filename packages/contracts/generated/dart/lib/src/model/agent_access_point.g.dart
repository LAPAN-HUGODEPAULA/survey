// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_access_point.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AgentAccessPoint extends AgentAccessPoint {
  @override
  final DateTime createdAt;
  @override
  final DateTime modifiedAt;
  @override
  final String accessPointKey;
  @override
  final String name;
  @override
  final String sourceApp;
  @override
  final String flowKey;
  @override
  final String promptKey;
  @override
  final String personaSkillKey;
  @override
  final String outputProfile;
  @override
  final String? surveyId;
  @override
  final String? description;

  factory _$AgentAccessPoint(
          [void Function(AgentAccessPointBuilder)? updates]) =>
      (AgentAccessPointBuilder()..update(updates))._build();

  _$AgentAccessPoint._(
      {required this.createdAt,
      required this.modifiedAt,
      required this.accessPointKey,
      required this.name,
      required this.sourceApp,
      required this.flowKey,
      required this.promptKey,
      required this.personaSkillKey,
      required this.outputProfile,
      this.surveyId,
      this.description})
      : super._();
  @override
  AgentAccessPoint rebuild(void Function(AgentAccessPointBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AgentAccessPointBuilder toBuilder() =>
      AgentAccessPointBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AgentAccessPoint &&
        createdAt == other.createdAt &&
        modifiedAt == other.modifiedAt &&
        accessPointKey == other.accessPointKey &&
        name == other.name &&
        sourceApp == other.sourceApp &&
        flowKey == other.flowKey &&
        promptKey == other.promptKey &&
        personaSkillKey == other.personaSkillKey &&
        outputProfile == other.outputProfile &&
        surveyId == other.surveyId &&
        description == other.description;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, modifiedAt.hashCode);
    _$hash = $jc(_$hash, accessPointKey.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, sourceApp.hashCode);
    _$hash = $jc(_$hash, flowKey.hashCode);
    _$hash = $jc(_$hash, promptKey.hashCode);
    _$hash = $jc(_$hash, personaSkillKey.hashCode);
    _$hash = $jc(_$hash, outputProfile.hashCode);
    _$hash = $jc(_$hash, surveyId.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AgentAccessPoint')
          ..add('createdAt', createdAt)
          ..add('modifiedAt', modifiedAt)
          ..add('accessPointKey', accessPointKey)
          ..add('name', name)
          ..add('sourceApp', sourceApp)
          ..add('flowKey', flowKey)
          ..add('promptKey', promptKey)
          ..add('personaSkillKey', personaSkillKey)
          ..add('outputProfile', outputProfile)
          ..add('surveyId', surveyId)
          ..add('description', description))
        .toString();
  }
}

class AgentAccessPointBuilder
    implements
        Builder<AgentAccessPoint, AgentAccessPointBuilder>,
        AgentAccessPointUpsertBuilder {
  _$AgentAccessPoint? _$v;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(covariant DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _modifiedAt;
  DateTime? get modifiedAt => _$this._modifiedAt;
  set modifiedAt(covariant DateTime? modifiedAt) =>
      _$this._modifiedAt = modifiedAt;

  String? _accessPointKey;
  String? get accessPointKey => _$this._accessPointKey;
  set accessPointKey(covariant String? accessPointKey) =>
      _$this._accessPointKey = accessPointKey;

  String? _name;
  String? get name => _$this._name;
  set name(covariant String? name) => _$this._name = name;

  String? _sourceApp;
  String? get sourceApp => _$this._sourceApp;
  set sourceApp(covariant String? sourceApp) => _$this._sourceApp = sourceApp;

  String? _flowKey;
  String? get flowKey => _$this._flowKey;
  set flowKey(covariant String? flowKey) => _$this._flowKey = flowKey;

  String? _promptKey;
  String? get promptKey => _$this._promptKey;
  set promptKey(covariant String? promptKey) => _$this._promptKey = promptKey;

  String? _personaSkillKey;
  String? get personaSkillKey => _$this._personaSkillKey;
  set personaSkillKey(covariant String? personaSkillKey) =>
      _$this._personaSkillKey = personaSkillKey;

  String? _outputProfile;
  String? get outputProfile => _$this._outputProfile;
  set outputProfile(covariant String? outputProfile) =>
      _$this._outputProfile = outputProfile;

  String? _surveyId;
  String? get surveyId => _$this._surveyId;
  set surveyId(covariant String? surveyId) => _$this._surveyId = surveyId;

  String? _description;
  String? get description => _$this._description;
  set description(covariant String? description) =>
      _$this._description = description;

  AgentAccessPointBuilder() {
    AgentAccessPoint._defaults(this);
  }

  AgentAccessPointBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _createdAt = $v.createdAt;
      _modifiedAt = $v.modifiedAt;
      _accessPointKey = $v.accessPointKey;
      _name = $v.name;
      _sourceApp = $v.sourceApp;
      _flowKey = $v.flowKey;
      _promptKey = $v.promptKey;
      _personaSkillKey = $v.personaSkillKey;
      _outputProfile = $v.outputProfile;
      _surveyId = $v.surveyId;
      _description = $v.description;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant AgentAccessPoint other) {
    _$v = other as _$AgentAccessPoint;
  }

  @override
  void update(void Function(AgentAccessPointBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AgentAccessPoint build() => _build();

  _$AgentAccessPoint _build() {
    final _$result = _$v ??
        _$AgentAccessPoint._(
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'AgentAccessPoint', 'createdAt'),
          modifiedAt: BuiltValueNullFieldError.checkNotNull(
              modifiedAt, r'AgentAccessPoint', 'modifiedAt'),
          accessPointKey: BuiltValueNullFieldError.checkNotNull(
              accessPointKey, r'AgentAccessPoint', 'accessPointKey'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'AgentAccessPoint', 'name'),
          sourceApp: BuiltValueNullFieldError.checkNotNull(
              sourceApp, r'AgentAccessPoint', 'sourceApp'),
          flowKey: BuiltValueNullFieldError.checkNotNull(
              flowKey, r'AgentAccessPoint', 'flowKey'),
          promptKey: BuiltValueNullFieldError.checkNotNull(
              promptKey, r'AgentAccessPoint', 'promptKey'),
          personaSkillKey: BuiltValueNullFieldError.checkNotNull(
              personaSkillKey, r'AgentAccessPoint', 'personaSkillKey'),
          outputProfile: BuiltValueNullFieldError.checkNotNull(
              outputProfile, r'AgentAccessPoint', 'outputProfile'),
          surveyId: surveyId,
          description: description,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
