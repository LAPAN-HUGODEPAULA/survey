// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_writer_knowledge_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClinicalWriterKnowledgeItem extends ClinicalWriterKnowledgeItem {
  @override
  final String? id;
  @override
  final String? label;
  @override
  final String? source_;
  @override
  final String? reference;

  factory _$ClinicalWriterKnowledgeItem(
          [void Function(ClinicalWriterKnowledgeItemBuilder)? updates]) =>
      (ClinicalWriterKnowledgeItemBuilder()..update(updates))._build();

  _$ClinicalWriterKnowledgeItem._(
      {this.id, this.label, this.source_, this.reference})
      : super._();
  @override
  ClinicalWriterKnowledgeItem rebuild(
          void Function(ClinicalWriterKnowledgeItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClinicalWriterKnowledgeItemBuilder toBuilder() =>
      ClinicalWriterKnowledgeItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClinicalWriterKnowledgeItem &&
        id == other.id &&
        label == other.label &&
        source_ == other.source_ &&
        reference == other.reference;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, reference.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClinicalWriterKnowledgeItem')
          ..add('id', id)
          ..add('label', label)
          ..add('source_', source_)
          ..add('reference', reference))
        .toString();
  }
}

class ClinicalWriterKnowledgeItemBuilder
    implements
        Builder<ClinicalWriterKnowledgeItem,
            ClinicalWriterKnowledgeItemBuilder> {
  _$ClinicalWriterKnowledgeItem? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _source_;
  String? get source_ => _$this._source_;
  set source_(String? source_) => _$this._source_ = source_;

  String? _reference;
  String? get reference => _$this._reference;
  set reference(String? reference) => _$this._reference = reference;

  ClinicalWriterKnowledgeItemBuilder() {
    ClinicalWriterKnowledgeItem._defaults(this);
  }

  ClinicalWriterKnowledgeItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _label = $v.label;
      _source_ = $v.source_;
      _reference = $v.reference;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClinicalWriterKnowledgeItem other) {
    _$v = other as _$ClinicalWriterKnowledgeItem;
  }

  @override
  void update(void Function(ClinicalWriterKnowledgeItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClinicalWriterKnowledgeItem build() => _build();

  _$ClinicalWriterKnowledgeItem _build() {
    final _$result = _$v ??
        _$ClinicalWriterKnowledgeItem._(
          id: id,
          label: label,
          source_: source_,
          reference: reference,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
