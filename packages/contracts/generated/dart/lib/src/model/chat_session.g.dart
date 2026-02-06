// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_session.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatSession extends ChatSession {
  @override
  final String? id;
  @override
  final String status;
  @override
  final String phase;
  @override
  final String? patientId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? completedAt;
  @override
  final JsonObject? metadata;

  factory _$ChatSession([void Function(ChatSessionBuilder)? updates]) =>
      (ChatSessionBuilder()..update(updates))._build();

  _$ChatSession._(
      {this.id,
      required this.status,
      required this.phase,
      this.patientId,
      required this.createdAt,
      required this.updatedAt,
      this.completedAt,
      this.metadata})
      : super._();
  @override
  ChatSession rebuild(void Function(ChatSessionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatSessionBuilder toBuilder() => ChatSessionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatSession &&
        id == other.id &&
        status == other.status &&
        phase == other.phase &&
        patientId == other.patientId &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        completedAt == other.completedAt &&
        metadata == other.metadata;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, phase.hashCode);
    _$hash = $jc(_$hash, patientId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, completedAt.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatSession')
          ..add('id', id)
          ..add('status', status)
          ..add('phase', phase)
          ..add('patientId', patientId)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('completedAt', completedAt)
          ..add('metadata', metadata))
        .toString();
  }
}

class ChatSessionBuilder implements Builder<ChatSession, ChatSessionBuilder> {
  _$ChatSession? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _phase;
  String? get phase => _$this._phase;
  set phase(String? phase) => _$this._phase = phase;

  String? _patientId;
  String? get patientId => _$this._patientId;
  set patientId(String? patientId) => _$this._patientId = patientId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DateTime? _completedAt;
  DateTime? get completedAt => _$this._completedAt;
  set completedAt(DateTime? completedAt) => _$this._completedAt = completedAt;

  JsonObject? _metadata;
  JsonObject? get metadata => _$this._metadata;
  set metadata(JsonObject? metadata) => _$this._metadata = metadata;

  ChatSessionBuilder() {
    ChatSession._defaults(this);
  }

  ChatSessionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _phase = $v.phase;
      _patientId = $v.patientId;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _completedAt = $v.completedAt;
      _metadata = $v.metadata;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatSession other) {
    _$v = other as _$ChatSession;
  }

  @override
  void update(void Function(ChatSessionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatSession build() => _build();

  _$ChatSession _build() {
    final _$result = _$v ??
        _$ChatSession._(
          id: id,
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'ChatSession', 'status'),
          phase: BuiltValueNullFieldError.checkNotNull(
              phase, r'ChatSession', 'phase'),
          patientId: patientId,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'ChatSession', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'ChatSession', 'updatedAt'),
          completedAt: completedAt,
          metadata: metadata,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
