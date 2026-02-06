// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_template_document_types200_response_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListTemplateDocumentTypes200ResponseInner
    extends ListTemplateDocumentTypes200ResponseInner {
  @override
  final TemplateDocumentType? id;
  @override
  final String? label;

  factory _$ListTemplateDocumentTypes200ResponseInner(
          [void Function(ListTemplateDocumentTypes200ResponseInnerBuilder)?
              updates]) =>
      (ListTemplateDocumentTypes200ResponseInnerBuilder()..update(updates))
          ._build();

  _$ListTemplateDocumentTypes200ResponseInner._({this.id, this.label})
      : super._();
  @override
  ListTemplateDocumentTypes200ResponseInner rebuild(
          void Function(ListTemplateDocumentTypes200ResponseInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListTemplateDocumentTypes200ResponseInnerBuilder toBuilder() =>
      ListTemplateDocumentTypes200ResponseInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListTemplateDocumentTypes200ResponseInner &&
        id == other.id &&
        label == other.label;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'ListTemplateDocumentTypes200ResponseInner')
          ..add('id', id)
          ..add('label', label))
        .toString();
  }
}

class ListTemplateDocumentTypes200ResponseInnerBuilder
    implements
        Builder<ListTemplateDocumentTypes200ResponseInner,
            ListTemplateDocumentTypes200ResponseInnerBuilder> {
  _$ListTemplateDocumentTypes200ResponseInner? _$v;

  TemplateDocumentType? _id;
  TemplateDocumentType? get id => _$this._id;
  set id(TemplateDocumentType? id) => _$this._id = id;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  ListTemplateDocumentTypes200ResponseInnerBuilder() {
    ListTemplateDocumentTypes200ResponseInner._defaults(this);
  }

  ListTemplateDocumentTypes200ResponseInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _label = $v.label;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ListTemplateDocumentTypes200ResponseInner other) {
    _$v = other as _$ListTemplateDocumentTypes200ResponseInner;
  }

  @override
  void update(
      void Function(ListTemplateDocumentTypes200ResponseInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  ListTemplateDocumentTypes200ResponseInner build() => _build();

  _$ListTemplateDocumentTypes200ResponseInner _build() {
    final _$result = _$v ??
        _$ListTemplateDocumentTypes200ResponseInner._(
          id: id,
          label: label,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
