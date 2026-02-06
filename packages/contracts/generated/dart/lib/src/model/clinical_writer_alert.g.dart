// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_writer_alert.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClinicalWriterAlert extends ClinicalWriterAlert {
  @override
  final String? id;
  @override
  final String? text;
  @override
  final String? severity;
  @override
  final String? evidence;

  factory _$ClinicalWriterAlert(
          [void Function(ClinicalWriterAlertBuilder)? updates]) =>
      (ClinicalWriterAlertBuilder()..update(updates))._build();

  _$ClinicalWriterAlert._({this.id, this.text, this.severity, this.evidence})
      : super._();
  @override
  ClinicalWriterAlert rebuild(
          void Function(ClinicalWriterAlertBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClinicalWriterAlertBuilder toBuilder() =>
      ClinicalWriterAlertBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClinicalWriterAlert &&
        id == other.id &&
        text == other.text &&
        severity == other.severity &&
        evidence == other.evidence;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jc(_$hash, severity.hashCode);
    _$hash = $jc(_$hash, evidence.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClinicalWriterAlert')
          ..add('id', id)
          ..add('text', text)
          ..add('severity', severity)
          ..add('evidence', evidence))
        .toString();
  }
}

class ClinicalWriterAlertBuilder
    implements Builder<ClinicalWriterAlert, ClinicalWriterAlertBuilder> {
  _$ClinicalWriterAlert? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  String? _severity;
  String? get severity => _$this._severity;
  set severity(String? severity) => _$this._severity = severity;

  String? _evidence;
  String? get evidence => _$this._evidence;
  set evidence(String? evidence) => _$this._evidence = evidence;

  ClinicalWriterAlertBuilder() {
    ClinicalWriterAlert._defaults(this);
  }

  ClinicalWriterAlertBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _text = $v.text;
      _severity = $v.severity;
      _evidence = $v.evidence;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClinicalWriterAlert other) {
    _$v = other as _$ClinicalWriterAlert;
  }

  @override
  void update(void Function(ClinicalWriterAlertBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClinicalWriterAlert build() => _build();

  _$ClinicalWriterAlert _build() {
    final _$result = _$v ??
        _$ClinicalWriterAlert._(
          id: id,
          text: text,
          severity: severity,
          evidence: evidence,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
