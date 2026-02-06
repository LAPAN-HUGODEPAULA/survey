// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_writer_hypothesis.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClinicalWriterHypothesis extends ClinicalWriterHypothesis {
  @override
  final String? id;
  @override
  final String? label;
  @override
  final num? confidence;
  @override
  final String? evidence;

  factory _$ClinicalWriterHypothesis(
          [void Function(ClinicalWriterHypothesisBuilder)? updates]) =>
      (ClinicalWriterHypothesisBuilder()..update(updates))._build();

  _$ClinicalWriterHypothesis._(
      {this.id, this.label, this.confidence, this.evidence})
      : super._();
  @override
  ClinicalWriterHypothesis rebuild(
          void Function(ClinicalWriterHypothesisBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClinicalWriterHypothesisBuilder toBuilder() =>
      ClinicalWriterHypothesisBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClinicalWriterHypothesis &&
        id == other.id &&
        label == other.label &&
        confidence == other.confidence &&
        evidence == other.evidence;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, confidence.hashCode);
    _$hash = $jc(_$hash, evidence.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClinicalWriterHypothesis')
          ..add('id', id)
          ..add('label', label)
          ..add('confidence', confidence)
          ..add('evidence', evidence))
        .toString();
  }
}

class ClinicalWriterHypothesisBuilder
    implements
        Builder<ClinicalWriterHypothesis, ClinicalWriterHypothesisBuilder> {
  _$ClinicalWriterHypothesis? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  num? _confidence;
  num? get confidence => _$this._confidence;
  set confidence(num? confidence) => _$this._confidence = confidence;

  String? _evidence;
  String? get evidence => _$this._evidence;
  set evidence(String? evidence) => _$this._evidence = evidence;

  ClinicalWriterHypothesisBuilder() {
    ClinicalWriterHypothesis._defaults(this);
  }

  ClinicalWriterHypothesisBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _label = $v.label;
      _confidence = $v.confidence;
      _evidence = $v.evidence;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClinicalWriterHypothesis other) {
    _$v = other as _$ClinicalWriterHypothesis;
  }

  @override
  void update(void Function(ClinicalWriterHypothesisBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClinicalWriterHypothesis build() => _build();

  _$ClinicalWriterHypothesis _build() {
    final _$result = _$v ??
        _$ClinicalWriterHypothesis._(
          id: id,
          label: label,
          confidence: confidence,
          evidence: evidence,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
