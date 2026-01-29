// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AgentResponse extends AgentResponse {
  @override
  final bool? ok;
  @override
  final String? inputType;
  @override
  final String? promptVersion;
  @override
  final String? modelVersion;
  @override
  final JsonObject? report;
  @override
  final BuiltList<String>? warnings;
  @override
  final String? classification;
  @override
  final String? medicalRecord;
  @override
  final String? errorMessage;

  factory _$AgentResponse([void Function(AgentResponseBuilder)? updates]) =>
      (AgentResponseBuilder()..update(updates))._build();

  _$AgentResponse._(
      {this.ok,
      this.inputType,
      this.promptVersion,
      this.modelVersion,
      this.report,
      this.warnings,
      this.classification,
      this.medicalRecord,
      this.errorMessage})
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
        ok == other.ok &&
        inputType == other.inputType &&
        promptVersion == other.promptVersion &&
        modelVersion == other.modelVersion &&
        report == other.report &&
        warnings == other.warnings &&
        classification == other.classification &&
        medicalRecord == other.medicalRecord &&
        errorMessage == other.errorMessage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ok.hashCode);
    _$hash = $jc(_$hash, inputType.hashCode);
    _$hash = $jc(_$hash, promptVersion.hashCode);
    _$hash = $jc(_$hash, modelVersion.hashCode);
    _$hash = $jc(_$hash, report.hashCode);
    _$hash = $jc(_$hash, warnings.hashCode);
    _$hash = $jc(_$hash, classification.hashCode);
    _$hash = $jc(_$hash, medicalRecord.hashCode);
    _$hash = $jc(_$hash, errorMessage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AgentResponse')
          ..add('ok', ok)
          ..add('inputType', inputType)
          ..add('promptVersion', promptVersion)
          ..add('modelVersion', modelVersion)
          ..add('report', report)
          ..add('warnings', warnings)
          ..add('classification', classification)
          ..add('medicalRecord', medicalRecord)
          ..add('errorMessage', errorMessage))
        .toString();
  }
}

class AgentResponseBuilder
    implements Builder<AgentResponse, AgentResponseBuilder> {
  _$AgentResponse? _$v;

  bool? _ok;
  bool? get ok => _$this._ok;
  set ok(bool? ok) => _$this._ok = ok;

  String? _inputType;
  String? get inputType => _$this._inputType;
  set inputType(String? inputType) => _$this._inputType = inputType;

  String? _promptVersion;
  String? get promptVersion => _$this._promptVersion;
  set promptVersion(String? promptVersion) =>
      _$this._promptVersion = promptVersion;

  String? _modelVersion;
  String? get modelVersion => _$this._modelVersion;
  set modelVersion(String? modelVersion) => _$this._modelVersion = modelVersion;

  JsonObject? _report;
  JsonObject? get report => _$this._report;
  set report(JsonObject? report) => _$this._report = report;

  ListBuilder<String>? _warnings;
  ListBuilder<String> get warnings =>
      _$this._warnings ??= ListBuilder<String>();
  set warnings(ListBuilder<String>? warnings) => _$this._warnings = warnings;

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
      _ok = $v.ok;
      _inputType = $v.inputType;
      _promptVersion = $v.promptVersion;
      _modelVersion = $v.modelVersion;
      _report = $v.report;
      _warnings = $v.warnings?.toBuilder();
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
    _$AgentResponse _$result;
    try {
      _$result = _$v ??
          _$AgentResponse._(
            ok: ok,
            inputType: inputType,
            promptVersion: promptVersion,
            modelVersion: modelVersion,
            report: report,
            warnings: _warnings?.build(),
            classification: classification,
            medicalRecord: medicalRecord,
            errorMessage: errorMessage,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'warnings';
        _warnings?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AgentResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
