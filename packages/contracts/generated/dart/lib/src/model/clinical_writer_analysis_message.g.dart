// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_writer_analysis_message.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClinicalWriterAnalysisMessage extends ClinicalWriterAnalysisMessage {
  @override
  final String role;
  @override
  final String content;
  @override
  final String messageType;

  factory _$ClinicalWriterAnalysisMessage(
          [void Function(ClinicalWriterAnalysisMessageBuilder)? updates]) =>
      (ClinicalWriterAnalysisMessageBuilder()..update(updates))._build();

  _$ClinicalWriterAnalysisMessage._(
      {required this.role, required this.content, required this.messageType})
      : super._();
  @override
  ClinicalWriterAnalysisMessage rebuild(
          void Function(ClinicalWriterAnalysisMessageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClinicalWriterAnalysisMessageBuilder toBuilder() =>
      ClinicalWriterAnalysisMessageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClinicalWriterAnalysisMessage &&
        role == other.role &&
        content == other.content &&
        messageType == other.messageType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, messageType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClinicalWriterAnalysisMessage')
          ..add('role', role)
          ..add('content', content)
          ..add('messageType', messageType))
        .toString();
  }
}

class ClinicalWriterAnalysisMessageBuilder
    implements
        Builder<ClinicalWriterAnalysisMessage,
            ClinicalWriterAnalysisMessageBuilder> {
  _$ClinicalWriterAnalysisMessage? _$v;

  String? _role;
  String? get role => _$this._role;
  set role(String? role) => _$this._role = role;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  String? _messageType;
  String? get messageType => _$this._messageType;
  set messageType(String? messageType) => _$this._messageType = messageType;

  ClinicalWriterAnalysisMessageBuilder() {
    ClinicalWriterAnalysisMessage._defaults(this);
  }

  ClinicalWriterAnalysisMessageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _role = $v.role;
      _content = $v.content;
      _messageType = $v.messageType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClinicalWriterAnalysisMessage other) {
    _$v = other as _$ClinicalWriterAnalysisMessage;
  }

  @override
  void update(void Function(ClinicalWriterAnalysisMessageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClinicalWriterAnalysisMessage build() => _build();

  _$ClinicalWriterAnalysisMessage _build() {
    final _$result = _$v ??
        _$ClinicalWriterAnalysisMessage._(
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'ClinicalWriterAnalysisMessage', 'role'),
          content: BuiltValueNullFieldError.checkNotNull(
              content, r'ClinicalWriterAnalysisMessage', 'content'),
          messageType: BuiltValueNullFieldError.checkNotNull(
              messageType, r'ClinicalWriterAnalysisMessage', 'messageType'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
