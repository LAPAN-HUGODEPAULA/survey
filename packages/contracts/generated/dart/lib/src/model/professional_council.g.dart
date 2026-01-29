// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'professional_council.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ProfessionalCouncilTypeEnum _$professionalCouncilTypeEnum_CFEP =
    const ProfessionalCouncilTypeEnum._('CFEP');
const ProfessionalCouncilTypeEnum _$professionalCouncilTypeEnum_CRP =
    const ProfessionalCouncilTypeEnum._('CRP');
const ProfessionalCouncilTypeEnum _$professionalCouncilTypeEnum_COREN =
    const ProfessionalCouncilTypeEnum._('COREN');
const ProfessionalCouncilTypeEnum _$professionalCouncilTypeEnum_CRM =
    const ProfessionalCouncilTypeEnum._('CRM');
const ProfessionalCouncilTypeEnum _$professionalCouncilTypeEnum_CREFITO =
    const ProfessionalCouncilTypeEnum._('CREFITO');
const ProfessionalCouncilTypeEnum _$professionalCouncilTypeEnum_CREFONO =
    const ProfessionalCouncilTypeEnum._('CREFONO');
const ProfessionalCouncilTypeEnum _$professionalCouncilTypeEnum_CRN =
    const ProfessionalCouncilTypeEnum._('CRN');
const ProfessionalCouncilTypeEnum _$professionalCouncilTypeEnum_none =
    const ProfessionalCouncilTypeEnum._('none');

ProfessionalCouncilTypeEnum _$professionalCouncilTypeEnumValueOf(String name) {
  switch (name) {
    case 'CFEP':
      return _$professionalCouncilTypeEnum_CFEP;
    case 'CRP':
      return _$professionalCouncilTypeEnum_CRP;
    case 'COREN':
      return _$professionalCouncilTypeEnum_COREN;
    case 'CRM':
      return _$professionalCouncilTypeEnum_CRM;
    case 'CREFITO':
      return _$professionalCouncilTypeEnum_CREFITO;
    case 'CREFONO':
      return _$professionalCouncilTypeEnum_CREFONO;
    case 'CRN':
      return _$professionalCouncilTypeEnum_CRN;
    case 'none':
      return _$professionalCouncilTypeEnum_none;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ProfessionalCouncilTypeEnum>
    _$professionalCouncilTypeEnumValues =
    BuiltSet<ProfessionalCouncilTypeEnum>(const <ProfessionalCouncilTypeEnum>[
  _$professionalCouncilTypeEnum_CFEP,
  _$professionalCouncilTypeEnum_CRP,
  _$professionalCouncilTypeEnum_COREN,
  _$professionalCouncilTypeEnum_CRM,
  _$professionalCouncilTypeEnum_CREFITO,
  _$professionalCouncilTypeEnum_CREFONO,
  _$professionalCouncilTypeEnum_CRN,
  _$professionalCouncilTypeEnum_none,
]);

Serializer<ProfessionalCouncilTypeEnum>
    _$professionalCouncilTypeEnumSerializer =
    _$ProfessionalCouncilTypeEnumSerializer();

class _$ProfessionalCouncilTypeEnumSerializer
    implements PrimitiveSerializer<ProfessionalCouncilTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'CFEP': 'CFEP',
    'CRP': 'CRP',
    'COREN': 'COREN',
    'CRM': 'CRM',
    'CREFITO': 'CREFITO',
    'CREFONO': 'CREFONO',
    'CRN': 'CRN',
    'none': 'none',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'CFEP': 'CFEP',
    'CRP': 'CRP',
    'COREN': 'COREN',
    'CRM': 'CRM',
    'CREFITO': 'CREFITO',
    'CREFONO': 'CREFONO',
    'CRN': 'CRN',
    'none': 'none',
  };

  @override
  final Iterable<Type> types = const <Type>[ProfessionalCouncilTypeEnum];
  @override
  final String wireName = 'ProfessionalCouncilTypeEnum';

  @override
  Object serialize(Serializers serializers, ProfessionalCouncilTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ProfessionalCouncilTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ProfessionalCouncilTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ProfessionalCouncil extends ProfessionalCouncil {
  @override
  final ProfessionalCouncilTypeEnum? type;
  @override
  final String? registrationNumber;

  factory _$ProfessionalCouncil(
          [void Function(ProfessionalCouncilBuilder)? updates]) =>
      (ProfessionalCouncilBuilder()..update(updates))._build();

  _$ProfessionalCouncil._({this.type, this.registrationNumber}) : super._();
  @override
  ProfessionalCouncil rebuild(
          void Function(ProfessionalCouncilBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProfessionalCouncilBuilder toBuilder() =>
      ProfessionalCouncilBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProfessionalCouncil &&
        type == other.type &&
        registrationNumber == other.registrationNumber;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, registrationNumber.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProfessionalCouncil')
          ..add('type', type)
          ..add('registrationNumber', registrationNumber))
        .toString();
  }
}

class ProfessionalCouncilBuilder
    implements Builder<ProfessionalCouncil, ProfessionalCouncilBuilder> {
  _$ProfessionalCouncil? _$v;

  ProfessionalCouncilTypeEnum? _type;
  ProfessionalCouncilTypeEnum? get type => _$this._type;
  set type(ProfessionalCouncilTypeEnum? type) => _$this._type = type;

  String? _registrationNumber;
  String? get registrationNumber => _$this._registrationNumber;
  set registrationNumber(String? registrationNumber) =>
      _$this._registrationNumber = registrationNumber;

  ProfessionalCouncilBuilder() {
    ProfessionalCouncil._defaults(this);
  }

  ProfessionalCouncilBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _registrationNumber = $v.registrationNumber;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProfessionalCouncil other) {
    _$v = other as _$ProfessionalCouncil;
  }

  @override
  void update(void Function(ProfessionalCouncilBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProfessionalCouncil build() => _build();

  _$ProfessionalCouncil _build() {
    final _$result = _$v ??
        _$ProfessionalCouncil._(
          type: type,
          registrationNumber: registrationNumber,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
