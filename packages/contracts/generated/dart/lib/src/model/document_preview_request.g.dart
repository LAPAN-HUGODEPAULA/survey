// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_preview_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DocumentPreviewRequest extends DocumentPreviewRequest {
  @override
  final String sessionId;
  @override
  final String documentType;
  @override
  final String? title;
  @override
  final String? body;

  factory _$DocumentPreviewRequest(
          [void Function(DocumentPreviewRequestBuilder)? updates]) =>
      (DocumentPreviewRequestBuilder()..update(updates))._build();

  _$DocumentPreviewRequest._(
      {required this.sessionId,
      required this.documentType,
      this.title,
      this.body})
      : super._();
  @override
  DocumentPreviewRequest rebuild(
          void Function(DocumentPreviewRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DocumentPreviewRequestBuilder toBuilder() =>
      DocumentPreviewRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DocumentPreviewRequest &&
        sessionId == other.sessionId &&
        documentType == other.documentType &&
        title == other.title &&
        body == other.body;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sessionId.hashCode);
    _$hash = $jc(_$hash, documentType.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DocumentPreviewRequest')
          ..add('sessionId', sessionId)
          ..add('documentType', documentType)
          ..add('title', title)
          ..add('body', body))
        .toString();
  }
}

class DocumentPreviewRequestBuilder
    implements Builder<DocumentPreviewRequest, DocumentPreviewRequestBuilder> {
  _$DocumentPreviewRequest? _$v;

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

  DocumentPreviewRequestBuilder() {
    DocumentPreviewRequest._defaults(this);
  }

  DocumentPreviewRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sessionId = $v.sessionId;
      _documentType = $v.documentType;
      _title = $v.title;
      _body = $v.body;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DocumentPreviewRequest other) {
    _$v = other as _$DocumentPreviewRequest;
  }

  @override
  void update(void Function(DocumentPreviewRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DocumentPreviewRequest build() => _build();

  _$DocumentPreviewRequest _build() {
    final _$result = _$v ??
        _$DocumentPreviewRequest._(
          sessionId: BuiltValueNullFieldError.checkNotNull(
              sessionId, r'DocumentPreviewRequest', 'sessionId'),
          documentType: BuiltValueNullFieldError.checkNotNull(
              documentType, r'DocumentPreviewRequest', 'documentType'),
          title: title,
          body: body,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
