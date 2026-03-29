// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persona_skill_upsert.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

abstract class PersonaSkillUpsertBuilder {
  void replace(PersonaSkillUpsert other);
  void update(void Function(PersonaSkillUpsertBuilder) updates);
  String? get personaSkillKey;
  set personaSkillKey(String? personaSkillKey);

  String? get name;
  set name(String? name);

  String? get outputProfile;
  set outputProfile(String? outputProfile);

  String? get instructions;
  set instructions(String? instructions);
}

class _$$PersonaSkillUpsert extends $PersonaSkillUpsert {
  @override
  final String personaSkillKey;
  @override
  final String name;
  @override
  final String outputProfile;
  @override
  final String instructions;

  factory _$$PersonaSkillUpsert(
          [void Function($PersonaSkillUpsertBuilder)? updates]) =>
      ($PersonaSkillUpsertBuilder()..update(updates))._build();

  _$$PersonaSkillUpsert._(
      {required this.personaSkillKey,
      required this.name,
      required this.outputProfile,
      required this.instructions})
      : super._();
  @override
  $PersonaSkillUpsert rebuild(
          void Function($PersonaSkillUpsertBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  $PersonaSkillUpsertBuilder toBuilder() =>
      $PersonaSkillUpsertBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is $PersonaSkillUpsert &&
        personaSkillKey == other.personaSkillKey &&
        name == other.name &&
        outputProfile == other.outputProfile &&
        instructions == other.instructions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, personaSkillKey.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, outputProfile.hashCode);
    _$hash = $jc(_$hash, instructions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'$PersonaSkillUpsert')
          ..add('personaSkillKey', personaSkillKey)
          ..add('name', name)
          ..add('outputProfile', outputProfile)
          ..add('instructions', instructions))
        .toString();
  }
}

class $PersonaSkillUpsertBuilder
    implements
        Builder<$PersonaSkillUpsert, $PersonaSkillUpsertBuilder>,
        PersonaSkillUpsertBuilder {
  _$$PersonaSkillUpsert? _$v;

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

  $PersonaSkillUpsertBuilder() {
    $PersonaSkillUpsert._defaults(this);
  }

  $PersonaSkillUpsertBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _personaSkillKey = $v.personaSkillKey;
      _name = $v.name;
      _outputProfile = $v.outputProfile;
      _instructions = $v.instructions;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant $PersonaSkillUpsert other) {
    _$v = other as _$$PersonaSkillUpsert;
  }

  @override
  void update(void Function($PersonaSkillUpsertBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  $PersonaSkillUpsert build() => _build();

  _$$PersonaSkillUpsert _build() {
    final _$result = _$v ??
        _$$PersonaSkillUpsert._(
          personaSkillKey: BuiltValueNullFieldError.checkNotNull(
              personaSkillKey, r'$PersonaSkillUpsert', 'personaSkillKey'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'$PersonaSkillUpsert', 'name'),
          outputProfile: BuiltValueNullFieldError.checkNotNull(
              outputProfile, r'$PersonaSkillUpsert', 'outputProfile'),
          instructions: BuiltValueNullFieldError.checkNotNull(
              instructions, r'$PersonaSkillUpsert', 'instructions'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
