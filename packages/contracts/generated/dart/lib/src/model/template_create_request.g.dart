// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TemplateCreateRequest extends TemplateCreateRequest {
  @override
  final String name;
  @override
  final TemplateDocumentType documentType;
  @override
  final String body;
  @override
  final BuiltList<String>? placeholders;
  @override
  final BuiltList<JsonObject>? conditions;

  factory _$TemplateCreateRequest(
          [void Function(TemplateCreateRequestBuilder)? updates]) =>
      (TemplateCreateRequestBuilder()..update(updates))._build();

  _$TemplateCreateRequest._(
      {required this.name,
      required this.documentType,
      required this.body,
      this.placeholders,
      this.conditions})
      : super._();
  @override
  TemplateCreateRequest rebuild(
          void Function(TemplateCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TemplateCreateRequestBuilder toBuilder() =>
      TemplateCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TemplateCreateRequest &&
        name == other.name &&
        documentType == other.documentType &&
        body == other.body &&
        placeholders == other.placeholders &&
        conditions == other.conditions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, documentType.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, placeholders.hashCode);
    _$hash = $jc(_$hash, conditions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TemplateCreateRequest')
          ..add('name', name)
          ..add('documentType', documentType)
          ..add('body', body)
          ..add('placeholders', placeholders)
          ..add('conditions', conditions))
        .toString();
  }
}

class TemplateCreateRequestBuilder
    implements Builder<TemplateCreateRequest, TemplateCreateRequestBuilder> {
  _$TemplateCreateRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  TemplateDocumentType? _documentType;
  TemplateDocumentType? get documentType => _$this._documentType;
  set documentType(TemplateDocumentType? documentType) =>
      _$this._documentType = documentType;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  ListBuilder<String>? _placeholders;
  ListBuilder<String> get placeholders =>
      _$this._placeholders ??= ListBuilder<String>();
  set placeholders(ListBuilder<String>? placeholders) =>
      _$this._placeholders = placeholders;

  ListBuilder<JsonObject>? _conditions;
  ListBuilder<JsonObject> get conditions =>
      _$this._conditions ??= ListBuilder<JsonObject>();
  set conditions(ListBuilder<JsonObject>? conditions) =>
      _$this._conditions = conditions;

  TemplateCreateRequestBuilder() {
    TemplateCreateRequest._defaults(this);
  }

  TemplateCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _documentType = $v.documentType;
      _body = $v.body;
      _placeholders = $v.placeholders?.toBuilder();
      _conditions = $v.conditions?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TemplateCreateRequest other) {
    _$v = other as _$TemplateCreateRequest;
  }

  @override
  void update(void Function(TemplateCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TemplateCreateRequest build() => _build();

  _$TemplateCreateRequest _build() {
    _$TemplateCreateRequest _$result;
    try {
      _$result = _$v ??
          _$TemplateCreateRequest._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'TemplateCreateRequest', 'name'),
            documentType: BuiltValueNullFieldError.checkNotNull(
                documentType, r'TemplateCreateRequest', 'documentType'),
            body: BuiltValueNullFieldError.checkNotNull(
                body, r'TemplateCreateRequest', 'body'),
            placeholders: _placeholders?.build(),
            conditions: _conditions?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'placeholders';
        _placeholders?.build();
        _$failedField = 'conditions';
        _conditions?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TemplateCreateRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
