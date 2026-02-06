// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_preview_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TemplatePreviewResponse extends TemplatePreviewResponse {
  @override
  final String html;
  @override
  final String title;
  @override
  final String body;
  @override
  final BuiltList<String> missingFields;
  @override
  final BuiltMap<String, JsonObject?>? metadata;

  factory _$TemplatePreviewResponse(
          [void Function(TemplatePreviewResponseBuilder)? updates]) =>
      (TemplatePreviewResponseBuilder()..update(updates))._build();

  _$TemplatePreviewResponse._(
      {required this.html,
      required this.title,
      required this.body,
      required this.missingFields,
      this.metadata})
      : super._();
  @override
  TemplatePreviewResponse rebuild(
          void Function(TemplatePreviewResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TemplatePreviewResponseBuilder toBuilder() =>
      TemplatePreviewResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TemplatePreviewResponse &&
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
    return (newBuiltValueToStringHelper(r'TemplatePreviewResponse')
          ..add('html', html)
          ..add('title', title)
          ..add('body', body)
          ..add('missingFields', missingFields)
          ..add('metadata', metadata))
        .toString();
  }
}

class TemplatePreviewResponseBuilder
    implements
        Builder<TemplatePreviewResponse, TemplatePreviewResponseBuilder> {
  _$TemplatePreviewResponse? _$v;

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

  MapBuilder<String, JsonObject?>? _metadata;
  MapBuilder<String, JsonObject?> get metadata =>
      _$this._metadata ??= MapBuilder<String, JsonObject?>();
  set metadata(MapBuilder<String, JsonObject?>? metadata) =>
      _$this._metadata = metadata;

  TemplatePreviewResponseBuilder() {
    TemplatePreviewResponse._defaults(this);
  }

  TemplatePreviewResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _html = $v.html;
      _title = $v.title;
      _body = $v.body;
      _missingFields = $v.missingFields.toBuilder();
      _metadata = $v.metadata?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TemplatePreviewResponse other) {
    _$v = other as _$TemplatePreviewResponse;
  }

  @override
  void update(void Function(TemplatePreviewResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TemplatePreviewResponse build() => _build();

  _$TemplatePreviewResponse _build() {
    _$TemplatePreviewResponse _$result;
    try {
      _$result = _$v ??
          _$TemplatePreviewResponse._(
            html: BuiltValueNullFieldError.checkNotNull(
                html, r'TemplatePreviewResponse', 'html'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'TemplatePreviewResponse', 'title'),
            body: BuiltValueNullFieldError.checkNotNull(
                body, r'TemplatePreviewResponse', 'body'),
            missingFields: missingFields.build(),
            metadata: _metadata?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'missingFields';
        missingFields.build();
        _$failedField = 'metadata';
        _metadata?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TemplatePreviewResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
