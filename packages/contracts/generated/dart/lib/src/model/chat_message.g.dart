// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatMessage extends ChatMessage {
  @override
  final String? id;
  @override
  final String sessionId;
  @override
  final String role;
  @override
  final String messageType;
  @override
  final String content;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final JsonObject? metadata;
  @override
  final BuiltList<JsonObject>? editHistory;

  factory _$ChatMessage([void Function(ChatMessageBuilder)? updates]) =>
      (ChatMessageBuilder()..update(updates))._build();

  _$ChatMessage._(
      {this.id,
      required this.sessionId,
      required this.role,
      required this.messageType,
      required this.content,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.metadata,
      this.editHistory})
      : super._();
  @override
  ChatMessage rebuild(void Function(ChatMessageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatMessageBuilder toBuilder() => ChatMessageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatMessage &&
        id == other.id &&
        sessionId == other.sessionId &&
        role == other.role &&
        messageType == other.messageType &&
        content == other.content &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt &&
        metadata == other.metadata &&
        editHistory == other.editHistory;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, sessionId.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, messageType.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jc(_$hash, editHistory.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatMessage')
          ..add('id', id)
          ..add('sessionId', sessionId)
          ..add('role', role)
          ..add('messageType', messageType)
          ..add('content', content)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('deletedAt', deletedAt)
          ..add('metadata', metadata)
          ..add('editHistory', editHistory))
        .toString();
  }
}

class ChatMessageBuilder implements Builder<ChatMessage, ChatMessageBuilder> {
  _$ChatMessage? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _sessionId;
  String? get sessionId => _$this._sessionId;
  set sessionId(String? sessionId) => _$this._sessionId = sessionId;

  String? _role;
  String? get role => _$this._role;
  set role(String? role) => _$this._role = role;

  String? _messageType;
  String? get messageType => _$this._messageType;
  set messageType(String? messageType) => _$this._messageType = messageType;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  JsonObject? _metadata;
  JsonObject? get metadata => _$this._metadata;
  set metadata(JsonObject? metadata) => _$this._metadata = metadata;

  ListBuilder<JsonObject>? _editHistory;
  ListBuilder<JsonObject> get editHistory =>
      _$this._editHistory ??= ListBuilder<JsonObject>();
  set editHistory(ListBuilder<JsonObject>? editHistory) =>
      _$this._editHistory = editHistory;

  ChatMessageBuilder() {
    ChatMessage._defaults(this);
  }

  ChatMessageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _sessionId = $v.sessionId;
      _role = $v.role;
      _messageType = $v.messageType;
      _content = $v.content;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _deletedAt = $v.deletedAt;
      _metadata = $v.metadata;
      _editHistory = $v.editHistory?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatMessage other) {
    _$v = other as _$ChatMessage;
  }

  @override
  void update(void Function(ChatMessageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatMessage build() => _build();

  _$ChatMessage _build() {
    _$ChatMessage _$result;
    try {
      _$result = _$v ??
          _$ChatMessage._(
            id: id,
            sessionId: BuiltValueNullFieldError.checkNotNull(
                sessionId, r'ChatMessage', 'sessionId'),
            role: BuiltValueNullFieldError.checkNotNull(
                role, r'ChatMessage', 'role'),
            messageType: BuiltValueNullFieldError.checkNotNull(
                messageType, r'ChatMessage', 'messageType'),
            content: BuiltValueNullFieldError.checkNotNull(
                content, r'ChatMessage', 'content'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'ChatMessage', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'ChatMessage', 'updatedAt'),
            deletedAt: deletedAt,
            metadata: metadata,
            editHistory: _editHistory?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'editHistory';
        _editHistory?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ChatMessage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
