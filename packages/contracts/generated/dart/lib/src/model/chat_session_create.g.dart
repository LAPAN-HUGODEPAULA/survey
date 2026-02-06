// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_session_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatSessionCreate extends ChatSessionCreate {
  @override
  final String? patientId;
  @override
  final String? phase;
  @override
  final JsonObject? metadata;

  factory _$ChatSessionCreate(
          [void Function(ChatSessionCreateBuilder)? updates]) =>
      (ChatSessionCreateBuilder()..update(updates))._build();

  _$ChatSessionCreate._({this.patientId, this.phase, this.metadata})
      : super._();
  @override
  ChatSessionCreate rebuild(void Function(ChatSessionCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatSessionCreateBuilder toBuilder() =>
      ChatSessionCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatSessionCreate &&
        patientId == other.patientId &&
        phase == other.phase &&
        metadata == other.metadata;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, patientId.hashCode);
    _$hash = $jc(_$hash, phase.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatSessionCreate')
          ..add('patientId', patientId)
          ..add('phase', phase)
          ..add('metadata', metadata))
        .toString();
  }
}

class ChatSessionCreateBuilder
    implements Builder<ChatSessionCreate, ChatSessionCreateBuilder> {
  _$ChatSessionCreate? _$v;

  String? _patientId;
  String? get patientId => _$this._patientId;
  set patientId(String? patientId) => _$this._patientId = patientId;

  String? _phase;
  String? get phase => _$this._phase;
  set phase(String? phase) => _$this._phase = phase;

  JsonObject? _metadata;
  JsonObject? get metadata => _$this._metadata;
  set metadata(JsonObject? metadata) => _$this._metadata = metadata;

  ChatSessionCreateBuilder() {
    ChatSessionCreate._defaults(this);
  }

  ChatSessionCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _patientId = $v.patientId;
      _phase = $v.phase;
      _metadata = $v.metadata;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatSessionCreate other) {
    _$v = other as _$ChatSessionCreate;
  }

  @override
  void update(void Function(ChatSessionCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatSessionCreate build() => _build();

  _$ChatSessionCreate _build() {
    final _$result = _$v ??
        _$ChatSessionCreate._(
          patientId: patientId,
          phase: phase,
          metadata: metadata,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
