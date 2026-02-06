// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_preview.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DocumentPreview extends DocumentPreview {
  @override
  final String html;
  @override
  final String title;
  @override
  final String body;
  @override
  final BuiltList<String>? missingFields;
  @override
  final JsonObject? metadata;

  factory _$DocumentPreview([void Function(DocumentPreviewBuilder)? updates]) =>
      (DocumentPreviewBuilder()..update(updates))._build();

  _$DocumentPreview._(
      {required this.html,
      required this.title,
      required this.body,
      this.missingFields,
      this.metadata})
      : super._();
  @override
  DocumentPreview rebuild(void Function(DocumentPreviewBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DocumentPreviewBuilder toBuilder() => DocumentPreviewBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DocumentPreview &&
        html == other.html &&
        title == other.title &&
        body == other.body &&
        missingFields == other.missingFields &&
        metadata == other.metadata;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, html.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, missingFields.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DocumentPreview')
          ..add('html', html)
          ..add('title', title)
          ..add('body', body)
          ..add('missingFields', missingFields)
          ..add('metadata', metadata))
        .toString();
  }
}

class DocumentPreviewBuilder
    implements Builder<DocumentPreview, DocumentPreviewBuilder> {
  _$DocumentPreview? _$v;

  String? _html;
  String? get html => _$this._html;
  set html(String? html) => _$this._html = html;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  ListBuilder<String>? _missingFields;
  ListBuilder<String> get missingFields =>
      _$this._missingFields ??= ListBuilder<String>();
  set missingFields(ListBuilder<String>? missingFields) =>
      _$this._missingFields = missingFields;

  JsonObject? _metadata;
  JsonObject? get metadata => _$this._metadata;
  set metadata(JsonObject? metadata) => _$this._metadata = metadata;

  DocumentPreviewBuilder() {
    DocumentPreview._defaults(this);
  }

  DocumentPreviewBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _html = $v.html;
      _title = $v.title;
      _body = $v.body;
      _missingFields = $v.missingFields?.toBuilder();
      _metadata = $v.metadata;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DocumentPreview other) {
    _$v = other as _$DocumentPreview;
  }

  @override
  void update(void Function(DocumentPreviewBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DocumentPreview build() => _build();

  _$DocumentPreview _build() {
    _$DocumentPreview _$result;
    try {
      _$result = _$v ??
          _$DocumentPreview._(
            html: BuiltValueNullFieldError.checkNotNull(
                html, r'DocumentPreview', 'html'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'DocumentPreview', 'title'),
            body: BuiltValueNullFieldError.checkNotNull(
                body, r'DocumentPreview', 'body'),
            missingFields: _missingFields?.build(),
            metadata: metadata,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'missingFields';
        _missingFields?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DocumentPreview', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
