// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_session_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatSessionUpdate extends ChatSessionUpdate {
  @override
  final String? status;
  @override
  final String? phase;
  @override
  final JsonObject? metadata;

  factory _$ChatSessionUpdate(
          [void Function(ChatSessionUpdateBuilder)? updates]) =>
      (ChatSessionUpdateBuilder()..update(updates))._build();

  _$ChatSessionUpdate._({this.status, this.phase, this.metadata}) : super._();
  @override
  ChatSessionUpdate rebuild(void Function(ChatSessionUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatSessionUpdateBuilder toBuilder() =>
      ChatSessionUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatSessionUpdate &&
        status == other.status &&
        phase == other.phase &&
        metadata == other.metadata;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, phase.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatSessionUpdate')
          ..add('status', status)
          ..add('phase', phase)
          ..add('metadata', metadata))
        .toString();
  }
}

class ChatSessionUpdateBuilder
    implements Builder<ChatSessionUpdate, ChatSessionUpdateBuilder> {
  _$ChatSessionUpdate? _$v;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _phase;
  String? get phase => _$this._phase;
  set phase(String? phase) => _$this._phase = phase;

  JsonObject? _metadata;
  JsonObject? get metadata => _$this._metadata;
  set metadata(JsonObject? metadata) => _$this._metadata = metadata;

  ChatSessionUpdateBuilder() {
    ChatSessionUpdate._defaults(this);
  }

  ChatSessionUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _phase = $v.phase;
      _metadata = $v.metadata;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatSessionUpdate other) {
    _$v = other as _$ChatSessionUpdate;
  }

  @override
  void update(void Function(ChatSessionUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatSessionUpdate build() => _build();

  _$ChatSessionUpdate _build() {
    final _$result = _$v ??
        _$ChatSessionUpdate._(
          status: status,
          phase: phase,
          metadata: metadata,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
