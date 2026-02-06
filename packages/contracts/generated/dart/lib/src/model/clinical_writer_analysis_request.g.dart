// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_writer_analysis_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClinicalWriterAnalysisRequest extends ClinicalWriterAnalysisRequest {
  @override
  final String? sessionId;
  @override
  final String? phase;
  @override
  final BuiltList<ClinicalWriterAnalysisMessage> messages;

  factory _$ClinicalWriterAnalysisRequest(
          [void Function(ClinicalWriterAnalysisRequestBuilder)? updates]) =>
      (ClinicalWriterAnalysisRequestBuilder()..update(updates))._build();

  _$ClinicalWriterAnalysisRequest._(
      {this.sessionId, this.phase, required this.messages})
      : super._();
  @override
  ClinicalWriterAnalysisRequest rebuild(
          void Function(ClinicalWriterAnalysisRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClinicalWriterAnalysisRequestBuilder toBuilder() =>
      ClinicalWriterAnalysisRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClinicalWriterAnalysisRequest &&
        sessionId == other.sessionId &&
        phase == other.phase &&
        messages == other.messages;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sessionId.hashCode);
    _$hash = $jc(_$hash, phase.hashCode);
    _$hash = $jc(_$hash, messages.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClinicalWriterAnalysisRequest')
          ..add('sessionId', sessionId)
          ..add('phase', phase)
          ..add('messages', messages))
        .toString();
  }
}

class ClinicalWriterAnalysisRequestBuilder
    implements
        Builder<ClinicalWriterAnalysisRequest,
            ClinicalWriterAnalysisRequestBuilder> {
  _$ClinicalWriterAnalysisRequest? _$v;

  String? _sessionId;
  String? get sessionId => _$this._sessionId;
  set sessionId(String? sessionId) => _$this._sessionId = sessionId;

  String? _phase;
  String? get phase => _$this._phase;
  set phase(String? phase) => _$this._phase = phase;

  ListBuilder<ClinicalWriterAnalysisMessage>? _messages;
  ListBuilder<ClinicalWriterAnalysisMessage> get messages =>
      _$this._messages ??= ListBuilder<ClinicalWriterAnalysisMessage>();
  set messages(ListBuilder<ClinicalWriterAnalysisMessage>? messages) =>
      _$this._messages = messages;

  ClinicalWriterAnalysisRequestBuilder() {
    ClinicalWriterAnalysisRequest._defaults(this);
  }

  ClinicalWriterAnalysisRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sessionId = $v.sessionId;
      _phase = $v.phase;
      _messages = $v.messages.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClinicalWriterAnalysisRequest other) {
    _$v = other as _$ClinicalWriterAnalysisRequest;
  }

  @override
  void update(void Function(ClinicalWriterAnalysisRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClinicalWriterAnalysisRequest build() => _build();

  _$ClinicalWriterAnalysisRequest _build() {
    _$ClinicalWriterAnalysisRequest _$result;
    try {
      _$result = _$v ??
          _$ClinicalWriterAnalysisRequest._(
            sessionId: sessionId,
            phase: phase,
            messages: messages.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'messages';
        messages.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ClinicalWriterAnalysisRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
