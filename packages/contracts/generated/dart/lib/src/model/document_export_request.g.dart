// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_export_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DocumentExportRequest extends DocumentExportRequest {
  @override
  final String sessionId;
  @override
  final String documentType;
  @override
  final String title;
  @override
  final String body;
  @override
  final JsonObject? metadata;

  factory _$DocumentExportRequest(
          [void Function(DocumentExportRequestBuilder)? updates]) =>
      (DocumentExportRequestBuilder()..update(updates))._build();

  _$DocumentExportRequest._(
      {required this.sessionId,
      required this.documentType,
      required this.title,
      required this.body,
      this.metadata})
      : super._();
  @override
  DocumentExportRequest rebuild(
          void Function(DocumentExportRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DocumentExportRequestBuilder toBuilder() =>
      DocumentExportRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DocumentExportRequest &&
        sessionId == other.sessionId &&
        documentType == other.documentType &&
        title == other.title &&
        body == other.body &&
        metadata == other.metadata;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sessionId.hashCode);
    _$hash = $jc(_$hash, documentType.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DocumentExportRequest')
          ..add('sessionId', sessionId)
          ..add('documentType', documentType)
          ..add('title', title)
          ..add('body', body)
          ..add('metadata', metadata))
        .toString();
  }
}

class DocumentExportRequestBuilder
    implements Builder<DocumentExportRequest, DocumentExportRequestBuilder> {
  _$DocumentExportRequest? _$v;

  String? _sessionId;
  String? get sessionId => _$this._sessionId;
  set sessionId(String? sessionId) => _$this._sessionId = sessionId;

  String? _documentType;
  String? get documentType => _$this._documentType;
  set documentType(String? documentType) => _$this._documentType = documentType;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  JsonObject? _metadata;
  JsonObject? get metadata => _$this._metadata;
  set metadata(JsonObject? metadata) => _$this._metadata = metadata;

  DocumentExportRequestBuilder() {
    DocumentExportRequest._defaults(this);
  }

  DocumentExportRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sessionId = $v.sessionId;
      _documentType = $v.documentType;
      _title = $v.title;
      _body = $v.body;
      _metadata = $v.metadata;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DocumentExportRequest other) {
    _$v = other as _$DocumentExportRequest;
  }

  @override
  void update(void Function(DocumentExportRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DocumentExportRequest build() => _build();

  _$DocumentExportRequest _build() {
    final _$result = _$v ??
        _$DocumentExportRequest._(
          sessionId: BuiltValueNullFieldError.checkNotNull(
              sessionId, r'DocumentExportRequest', 'sessionId'),
          documentType: BuiltValueNullFieldError.checkNotNull(
              documentType, r'DocumentExportRequest', 'documentType'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'DocumentExportRequest', 'title'),
          body: BuiltValueNullFieldError.checkNotNull(
              body, r'DocumentExportRequest', 'body'),
          metadata: metadata,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
