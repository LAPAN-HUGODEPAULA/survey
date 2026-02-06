// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_writer_entity.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClinicalWriterEntity extends ClinicalWriterEntity {
  @override
  final String? type;
  @override
  final String? value;
  @override
  final num? confidence;

  factory _$ClinicalWriterEntity(
          [void Function(ClinicalWriterEntityBuilder)? updates]) =>
      (ClinicalWriterEntityBuilder()..update(updates))._build();

  _$ClinicalWriterEntity._({this.type, this.value, this.confidence})
      : super._();
  @override
  ClinicalWriterEntity rebuild(
          void Function(ClinicalWriterEntityBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClinicalWriterEntityBuilder toBuilder() =>
      ClinicalWriterEntityBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClinicalWriterEntity &&
        type == other.type &&
        value == other.value &&
        confidence == other.confidence;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jc(_$hash, confidence.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClinicalWriterEntity')
          ..add('type', type)
          ..add('value', value)
          ..add('confidence', confidence))
        .toString();
  }
}

class ClinicalWriterEntityBuilder
    implements Builder<ClinicalWriterEntity, ClinicalWriterEntityBuilder> {
  _$ClinicalWriterEntity? _$v;

  String? _type;
  String? get type => _$this._type;
  set type(String? type) => _$this._type = type;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  num? _confidence;
  num? get confidence => _$this._confidence;
  set confidence(num? confidence) => _$this._confidence = confidence;

  ClinicalWriterEntityBuilder() {
    ClinicalWriterEntity._defaults(this);
  }

  ClinicalWriterEntityBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _value = $v.value;
      _confidence = $v.confidence;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClinicalWriterEntity other) {
    _$v = other as _$ClinicalWriterEntity;
  }

  @override
  void update(void Function(ClinicalWriterEntityBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClinicalWriterEntity build() => _build();

  _$ClinicalWriterEntity _build() {
    final _$result = _$v ??
        _$ClinicalWriterEntity._(
          type: type,
          value: value,
          confidence: confidence,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
