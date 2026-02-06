// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatMessageCreate extends ChatMessageCreate {
  @override
  final String role;
  @override
  final String messageType;
  @override
  final String content;
  @override
  final JsonObject? metadata;

  factory _$ChatMessageCreate(
          [void Function(ChatMessageCreateBuilder)? updates]) =>
      (ChatMessageCreateBuilder()..update(updates))._build();

  _$ChatMessageCreate._(
      {required this.role,
      required this.messageType,
      required this.content,
      this.metadata})
      : super._();
  @override
  ChatMessageCreate rebuild(void Function(ChatMessageCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatMessageCreateBuilder toBuilder() =>
      ChatMessageCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatMessageCreate &&
        role == other.role &&
        messageType == other.messageType &&
        content == other.content &&
        metadata == other.metadata;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, messageType.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatMessageCreate')
          ..add('role', role)
          ..add('messageType', messageType)
          ..add('content', content)
          ..add('metadata', metadata))
        .toString();
  }
}

class ChatMessageCreateBuilder
    implements Builder<ChatMessageCreate, ChatMessageCreateBuilder> {
  _$ChatMessageCreate? _$v;

  String? _role;
  String? get role => _$this._role;
  set role(String? role) => _$this._role = role;

  String? _messageType;
  String? get messageType => _$this._messageType;
  set messageType(String? messageType) => _$this._messageType = messageType;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  JsonObject? _metadata;
  JsonObject? get metadata => _$this._metadata;
  set metadata(JsonObject? metadata) => _$this._metadata = metadata;

  ChatMessageCreateBuilder() {
    ChatMessageCreate._defaults(this);
  }

  ChatMessageCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _role = $v.role;
      _messageType = $v.messageType;
      _content = $v.content;
      _metadata = $v.metadata;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatMessageCreate other) {
    _$v = other as _$ChatMessageCreate;
  }

  @override
  void update(void Function(ChatMessageCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatMessageCreate build() => _build();

  _$ChatMessageCreate _build() {
    final _$result = _$v ??
        _$ChatMessageCreate._(
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'ChatMessageCreate', 'role'),
          messageType: BuiltValueNullFieldError.checkNotNull(
              messageType, r'ChatMessageCreate', 'messageType'),
          content: BuiltValueNullFieldError.checkNotNull(
              content, r'ChatMessageCreate', 'content'),
          metadata: metadata,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
