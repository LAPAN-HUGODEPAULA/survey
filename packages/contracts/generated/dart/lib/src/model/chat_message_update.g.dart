// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatMessageUpdate extends ChatMessageUpdate {
  @override
  final String? content;
  @override
  final JsonObject? metadata;

  factory _$ChatMessageUpdate(
          [void Function(ChatMessageUpdateBuilder)? updates]) =>
      (ChatMessageUpdateBuilder()..update(updates))._build();

  _$ChatMessageUpdate._({this.content, this.metadata}) : super._();
  @override
  ChatMessageUpdate rebuild(void Function(ChatMessageUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatMessageUpdateBuilder toBuilder() =>
      ChatMessageUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatMessageUpdate &&
        content == other.content &&
        metadata == other.metadata;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatMessageUpdate')
          ..add('content', content)
          ..add('metadata', metadata))
        .toString();
  }
}

class ChatMessageUpdateBuilder
    implements Builder<ChatMessageUpdate, ChatMessageUpdateBuilder> {
  _$ChatMessageUpdate? _$v;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  JsonObject? _metadata;
  JsonObject? get metadata => _$this._metadata;
  set metadata(JsonObject? metadata) => _$this._metadata = metadata;

  ChatMessageUpdateBuilder() {
    ChatMessageUpdate._defaults(this);
  }

  ChatMessageUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content;
      _metadata = $v.metadata;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatMessageUpdate other) {
    _$v = other as _$ChatMessageUpdate;
  }

  @override
  void update(void Function(ChatMessageUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatMessageUpdate build() => _build();

  _$ChatMessageUpdate _build() {
    final _$result = _$v ??
        _$ChatMessageUpdate._(
          content: content,
          metadata: metadata,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
