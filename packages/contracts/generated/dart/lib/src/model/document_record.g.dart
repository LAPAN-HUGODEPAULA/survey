// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_record.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DocumentRecord extends DocumentRecord {
  @override
  final String? id;
  @override
  final String sessionId;
  @override
  final String documentType;
  @override
  final String title;
  @override
  final String body;
  @override
  final String html;
  @override
  final String status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final JsonObject? metadata;

  factory _$DocumentRecord([void Function(DocumentRecordBuilder)? updates]) =>
      (DocumentRecordBuilder()..update(updates))._build();

  _$DocumentRecord._(
      {this.id,
      required this.sessionId,
      required this.documentType,
      required this.title,
      required this.body,
      required this.html,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      this.metadata})
      : super._();
  @override
  DocumentRecord rebuild(void Function(DocumentRecordBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DocumentRecordBuilder toBuilder() => DocumentRecordBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DocumentRecord &&
        id == other.id &&
        sessionId == other.sessionId &&
        documentType == other.documentType &&
        title == other.title &&
        body == other.body &&
        html == other.html &&
        status == other.status &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        metadata == other.metadata;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, sessionId.hashCode);
    _$hash = $jc(_$hash, documentType.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, html.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DocumentRecord')
          ..add('id', id)
          ..add('sessionId', sessionId)
          ..add('documentType', documentType)
          ..add('title', title)
          ..add('body', body)
          ..add('html', html)
          ..add('status', status)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('metadata', metadata))
        .toString();
  }
}

class DocumentRecordBuilder
    implements Builder<DocumentRecord, DocumentRecordBuilder> {
  _$DocumentRecord? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

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

  String? _html;
  String? get html => _$this._html;
  set html(String? html) => _$this._html = html;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  JsonObject? _metadata;
  JsonObject? get metadata => _$this._metadata;
  set metadata(JsonObject? metadata) => _$this._metadata = metadata;

  DocumentRecordBuilder() {
    DocumentRecord._defaults(this);
  }

  DocumentRecordBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _sessionId = $v.sessionId;
      _documentType = $v.documentType;
      _title = $v.title;
      _body = $v.body;
      _html = $v.html;
      _status = $v.status;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _metadata = $v.metadata;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DocumentRecord other) {
    _$v = other as _$DocumentRecord;
  }

  @override
  void update(void Function(DocumentRecordBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DocumentRecord build() => _build();

  _$DocumentRecord _build() {
    final _$result = _$v ??
        _$DocumentRecord._(
          id: id,
          sessionId: BuiltValueNullFieldError.checkNotNull(
              sessionId, r'DocumentRecord', 'sessionId'),
          documentType: BuiltValueNullFieldError.checkNotNull(
              documentType, r'DocumentRecord', 'documentType'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'DocumentRecord', 'title'),
          body: BuiltValueNullFieldError.checkNotNull(
              body, r'DocumentRecord', 'body'),
          html: BuiltValueNullFieldError.checkNotNull(
              html, r'DocumentRecord', 'html'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'DocumentRecord', 'status'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'DocumentRecord', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'DocumentRecord', 'updatedAt'),
          metadata: metadata,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
