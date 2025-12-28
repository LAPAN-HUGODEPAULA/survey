// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AgentResponse extends AgentResponse {
  @override
  final String? classification;
  @override
  final String? medicalRecord;
  @override
  final String? errorMessage;

  factory _$AgentResponse([void Function(AgentResponseBuilder)? updates]) =>
      (AgentResponseBuilder()..update(updates))._build();

  _$AgentResponse._(
      {this.classification, this.medicalRecord, this.errorMessage})
      : super._();
  @override
  AgentResponse rebuild(void Function(AgentResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AgentResponseBuilder toBuilder() => AgentResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AgentResponse &&
        classification == other.classification &&
        medicalRecord == other.medicalRecord &&
        errorMessage == other.errorMessage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, classification.hashCode);
    _$hash = $jc(_$hash, medicalRecord.hashCode);
    _$hash = $jc(_$hash, errorMessage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AgentResponse')
          ..add('classification', classification)
          ..add('medicalRecord', medicalRecord)
          ..add('errorMessage', errorMessage))
        .toString();
  }
}

class AgentResponseBuilder
    implements Builder<AgentResponse, AgentResponseBuilder> {
  _$AgentResponse? _$v;

  String? _classification;
  String? get classification => _$this._classification;
  set classification(String? classification) =>
      _$this._classification = classification;

  String? _medicalRecord;
  String? get medicalRecord => _$this._medicalRecord;
  set medicalRecord(String? medicalRecord) =>
      _$this._medicalRecord = medicalRecord;

  String? _errorMessage;
  String? get errorMessage => _$this._errorMessage;
  set errorMessage(String? errorMessage) => _$this._errorMessage = errorMessage;

  AgentResponseBuilder() {
    AgentResponse._defaults(this);
  }

  AgentResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _classification = $v.classification;
      _medicalRecord = $v.medicalRecord;
      _errorMessage = $v.errorMessage;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AgentResponse other) {
    _$v = other as _$AgentResponse;
  }

  @override
  void update(void Function(AgentResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AgentResponse build() => _build();

  _$AgentResponse _build() {
    final _$result = _$v ??
        _$AgentResponse._(
          classification: classification,
          medicalRecord: medicalRecord,
          errorMessage: errorMessage,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
