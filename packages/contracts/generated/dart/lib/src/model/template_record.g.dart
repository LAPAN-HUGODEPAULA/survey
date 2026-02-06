// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_record.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TemplateRecord extends TemplateRecord {
  @override
  final String? id;
  @override
  final String? templateGroupId;
  @override
  final String name;
  @override
  final TemplateDocumentType documentType;
  @override
  final String version;
  @override
  final String status;
  @override
  final String body;
  @override
  final BuiltList<String> placeholders;
  @override
  final BuiltList<JsonObject>? conditions;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? approvedAt;
  @override
  final String? createdBy;
  @override
  final String? updatedBy;
  @override
  final String? approvedBy;

  factory _$TemplateRecord([void Function(TemplateRecordBuilder)? updates]) =>
      (TemplateRecordBuilder()..update(updates))._build();

  _$TemplateRecord._(
      {this.id,
      this.templateGroupId,
      required this.name,
      required this.documentType,
      required this.version,
      required this.status,
      required this.body,
      required this.placeholders,
      this.conditions,
      required this.createdAt,
      required this.updatedAt,
      this.approvedAt,
      this.createdBy,
      this.updatedBy,
      this.approvedBy})
      : super._();
  @override
  TemplateRecord rebuild(void Function(TemplateRecordBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TemplateRecordBuilder toBuilder() => TemplateRecordBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TemplateRecord &&
        id == other.id &&
        templateGroupId == other.templateGroupId &&
        name == other.name &&
        documentType == other.documentType &&
        version == other.version &&
        status == other.status &&
        body == other.body &&
        placeholders == other.placeholders &&
        conditions == other.conditions &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        approvedAt == other.approvedAt &&
        createdBy == other.createdBy &&
        updatedBy == other.updatedBy &&
        approvedBy == other.approvedBy;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, templateGroupId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, documentType.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, placeholders.hashCode);
    _$hash = $jc(_$hash, conditions.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, approvedAt.hashCode);
    _$hash = $jc(_$hash, createdBy.hashCode);
    _$hash = $jc(_$hash, updatedBy.hashCode);
    _$hash = $jc(_$hash, approvedBy.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TemplateRecord')
          ..add('id', id)
          ..add('templateGroupId', templateGroupId)
          ..add('name', name)
          ..add('documentType', documentType)
          ..add('version', version)
          ..add('status', status)
          ..add('body', body)
          ..add('placeholders', placeholders)
          ..add('conditions', conditions)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('approvedAt', approvedAt)
          ..add('createdBy', createdBy)
          ..add('updatedBy', updatedBy)
          ..add('approvedBy', approvedBy))
        .toString();
  }
}

class TemplateRecordBuilder
    implements Builder<TemplateRecord, TemplateRecordBuilder> {
  _$TemplateRecord? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _templateGroupId;
  String? get templateGroupId => _$this._templateGroupId;
  set templateGroupId(String? templateGroupId) =>
      _$this._templateGroupId = templateGroupId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  TemplateDocumentType? _documentType;
  TemplateDocumentType? get documentType => _$this._documentType;
  set documentType(TemplateDocumentType? documentType) =>
      _$this._documentType = documentType;

  String? _version;
  String? get version => _$this._version;
  set version(String? version) => _$this._version = version;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

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

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DateTime? _approvedAt;
  DateTime? get approvedAt => _$this._approvedAt;
  set approvedAt(DateTime? approvedAt) => _$this._approvedAt = approvedAt;

  String? _createdBy;
  String? get createdBy => _$this._createdBy;
  set createdBy(String? createdBy) => _$this._createdBy = createdBy;

  String? _updatedBy;
  String? get updatedBy => _$this._updatedBy;
  set updatedBy(String? updatedBy) => _$this._updatedBy = updatedBy;

  String? _approvedBy;
  String? get approvedBy => _$this._approvedBy;
  set approvedBy(String? approvedBy) => _$this._approvedBy = approvedBy;

  TemplateRecordBuilder() {
    TemplateRecord._defaults(this);
  }

  TemplateRecordBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _templateGroupId = $v.templateGroupId;
      _name = $v.name;
      _documentType = $v.documentType;
      _version = $v.version;
      _status = $v.status;
      _body = $v.body;
      _placeholders = $v.placeholders.toBuilder();
      _conditions = $v.conditions?.toBuilder();
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _approvedAt = $v.approvedAt;
      _createdBy = $v.createdBy;
      _updatedBy = $v.updatedBy;
      _approvedBy = $v.approvedBy;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TemplateRecord other) {
    _$v = other as _$TemplateRecord;
  }

  @override
  void update(void Function(TemplateRecordBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TemplateRecord build() => _build();

  _$TemplateRecord _build() {
    _$TemplateRecord _$result;
    try {
      _$result = _$v ??
          _$TemplateRecord._(
            id: id,
            templateGroupId: templateGroupId,
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'TemplateRecord', 'name'),
            documentType: BuiltValueNullFieldError.checkNotNull(
                documentType, r'TemplateRecord', 'documentType'),
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'TemplateRecord', 'version'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'TemplateRecord', 'status'),
            body: BuiltValueNullFieldError.checkNotNull(
                body, r'TemplateRecord', 'body'),
            placeholders: placeholders.build(),
            conditions: _conditions?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'TemplateRecord', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'TemplateRecord', 'updatedAt'),
            approvedAt: approvedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            approvedBy: approvedBy,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'placeholders';
        placeholders.build();
        _$failedField = 'conditions';
        _conditions?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TemplateRecord', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
