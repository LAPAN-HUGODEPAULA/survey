// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persona_skill.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PersonaSkill extends PersonaSkill {
  @override
  final DateTime createdAt;
  @override
  final DateTime modifiedAt;
  @override
  final String personaSkillKey;
  @override
  final String name;
  @override
  final String outputProfile;
  @override
  final String instructions;

  factory _$PersonaSkill([void Function(PersonaSkillBuilder)? updates]) =>
      (PersonaSkillBuilder()..update(updates))._build();

  _$PersonaSkill._(
      {required this.createdAt,
      required this.modifiedAt,
      required this.personaSkillKey,
      required this.name,
      required this.outputProfile,
      required this.instructions})
      : super._();
  @override
  PersonaSkill rebuild(void Function(PersonaSkillBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PersonaSkillBuilder toBuilder() => PersonaSkillBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PersonaSkill &&
        createdAt == other.createdAt &&
        modifiedAt == other.modifiedAt &&
        personaSkillKey == other.personaSkillKey &&
        name == other.name &&
        outputProfile == other.outputProfile &&
        instructions == other.instructions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, modifiedAt.hashCode);
    _$hash = $jc(_$hash, personaSkillKey.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, outputProfile.hashCode);
    _$hash = $jc(_$hash, instructions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PersonaSkill')
          ..add('createdAt', createdAt)
          ..add('modifiedAt', modifiedAt)
          ..add('personaSkillKey', personaSkillKey)
          ..add('name', name)
          ..add('outputProfile', outputProfile)
          ..add('instructions', instructions))
        .toString();
  }
}

class PersonaSkillBuilder
    implements
        Builder<PersonaSkill, PersonaSkillBuilder>,
        PersonaSkillUpsertBuilder {
  _$PersonaSkill? _$v;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(covariant DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _modifiedAt;
  DateTime? get modifiedAt => _$this._modifiedAt;
  set modifiedAt(covariant DateTime? modifiedAt) =>
      _$this._modifiedAt = modifiedAt;

  String? _personaSkillKey;
  String? get personaSkillKey => _$this._personaSkillKey;
  set personaSkillKey(covariant String? personaSkillKey) =>
      _$this._personaSkillKey = personaSkillKey;

  String? _name;
  String? get name => _$this._name;
  set name(covariant String? name) => _$this._name = name;

  String? _outputProfile;
  String? get outputProfile => _$this._outputProfile;
  set outputProfile(covariant String? outputProfile) =>
      _$this._outputProfile = outputProfile;

  String? _instructions;
  String? get instructions => _$this._instructions;
  set instructions(covariant String? instructions) =>
      _$this._instructions = instructions;

  PersonaSkillBuilder() {
    PersonaSkill._defaults(this);
  }

  PersonaSkillBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _createdAt = $v.createdAt;
      _modifiedAt = $v.modifiedAt;
      _personaSkillKey = $v.personaSkillKey;
      _name = $v.name;
      _outputProfile = $v.outputProfile;
      _instructions = $v.instructions;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant PersonaSkill other) {
    _$v = other as _$PersonaSkill;
  }

  @override
  void update(void Function(PersonaSkillBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PersonaSkill build() => _build();

  _$PersonaSkill _build() {
    final _$result = _$v ??
        _$PersonaSkill._(
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'PersonaSkill', 'createdAt'),
          modifiedAt: BuiltValueNullFieldError.checkNotNull(
              modifiedAt, r'PersonaSkill', 'modifiedAt'),
          personaSkillKey: BuiltValueNullFieldError.checkNotNull(
              personaSkillKey, r'PersonaSkill', 'personaSkillKey'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'PersonaSkill', 'name'),
          outputProfile: BuiltValueNullFieldError.checkNotNull(
              outputProfile, r'PersonaSkill', 'outputProfile'),
          instructions: BuiltValueNullFieldError.checkNotNull(
              instructions, r'PersonaSkill', 'instructions'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
