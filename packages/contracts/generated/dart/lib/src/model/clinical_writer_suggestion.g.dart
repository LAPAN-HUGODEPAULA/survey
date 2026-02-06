// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_writer_suggestion.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClinicalWriterSuggestion extends ClinicalWriterSuggestion {
  @override
  final String? id;
  @override
  final String? text;
  @override
  final String? category;
  @override
  final num? confidence;

  factory _$ClinicalWriterSuggestion(
          [void Function(ClinicalWriterSuggestionBuilder)? updates]) =>
      (ClinicalWriterSuggestionBuilder()..update(updates))._build();

  _$ClinicalWriterSuggestion._(
      {this.id, this.text, this.category, this.confidence})
      : super._();
  @override
  ClinicalWriterSuggestion rebuild(
          void Function(ClinicalWriterSuggestionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClinicalWriterSuggestionBuilder toBuilder() =>
      ClinicalWriterSuggestionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClinicalWriterSuggestion &&
        id == other.id &&
        text == other.text &&
        category == other.category &&
        confidence == other.confidence;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, confidence.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClinicalWriterSuggestion')
          ..add('id', id)
          ..add('text', text)
          ..add('category', category)
          ..add('confidence', confidence))
        .toString();
  }
}

class ClinicalWriterSuggestionBuilder
    implements
        Builder<ClinicalWriterSuggestion, ClinicalWriterSuggestionBuilder> {
  _$ClinicalWriterSuggestion? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  String? _category;
  String? get category => _$this._category;
  set category(String? category) => _$this._category = category;

  num? _confidence;
  num? get confidence => _$this._confidence;
  set confidence(num? confidence) => _$this._confidence = confidence;

  ClinicalWriterSuggestionBuilder() {
    ClinicalWriterSuggestion._defaults(this);
  }

  ClinicalWriterSuggestionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _text = $v.text;
      _category = $v.category;
      _confidence = $v.confidence;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClinicalWriterSuggestion other) {
    _$v = other as _$ClinicalWriterSuggestion;
  }

  @override
  void update(void Function(ClinicalWriterSuggestionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClinicalWriterSuggestion build() => _build();

  _$ClinicalWriterSuggestion _build() {
    final _$result = _$v ??
        _$ClinicalWriterSuggestion._(
          id: id,
          text: text,
          category: category,
          confidence: confidence,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
