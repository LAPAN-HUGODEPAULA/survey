// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_artifact_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AgentArtifactResponse extends AgentArtifactResponse {
  @override
  final String? accessPointKey;
  @override
  final bool? ok;
  @override
  final String? inputType;
  @override
  final String? promptVersion;
  @override
  final String? questionnairePromptVersion;
  @override
  final String? personaSkillVersion;
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
  @override
  final AIProgress? aiProgress;

  factory _$AgentArtifactResponse(
          [void Function(AgentArtifactResponseBuilder)? updates]) =>
      (AgentArtifactResponseBuilder()..update(updates))._build();

  _$AgentArtifactResponse._(
      {this.accessPointKey,
      this.ok,
      this.inputType,
      this.promptVersion,
      this.questionnairePromptVersion,
      this.personaSkillVersion,
      this.modelVersion,
      this.report,
      this.warnings,
      this.classification,
      this.medicalRecord,
      this.errorMessage,
      this.aiProgress})
      : super._();
  @override
  AgentArtifactResponse rebuild(
          void Function(AgentArtifactResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AgentArtifactResponseBuilder toBuilder() =>
      AgentArtifactResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AgentArtifactResponse &&
        accessPointKey == other.accessPointKey &&
        ok == other.ok &&
        inputType == other.inputType &&
        promptVersion == other.promptVersion &&
        questionnairePromptVersion == other.questionnairePromptVersion &&
        personaSkillVersion == other.personaSkillVersion &&
        modelVersion == other.modelVersion &&
        report == other.report &&
        warnings == other.warnings &&
        classification == other.classification &&
        medicalRecord == other.medicalRecord &&
        errorMessage == other.errorMessage &&
        aiProgress == other.aiProgress;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accessPointKey.hashCode);
    _$hash = $jc(_$hash, ok.hashCode);
    _$hash = $jc(_$hash, inputType.hashCode);
    _$hash = $jc(_$hash, promptVersion.hashCode);
    _$hash = $jc(_$hash, questionnairePromptVersion.hashCode);
    _$hash = $jc(_$hash, personaSkillVersion.hashCode);
    _$hash = $jc(_$hash, modelVersion.hashCode);
    _$hash = $jc(_$hash, report.hashCode);
    _$hash = $jc(_$hash, warnings.hashCode);
    _$hash = $jc(_$hash, classification.hashCode);
    _$hash = $jc(_$hash, medicalRecord.hashCode);
    _$hash = $jc(_$hash, errorMessage.hashCode);
    _$hash = $jc(_$hash, aiProgress.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AgentArtifactResponse')
          ..add('accessPointKey', accessPointKey)
          ..add('ok', ok)
          ..add('inputType', inputType)
          ..add('promptVersion', promptVersion)
          ..add('questionnairePromptVersion', questionnairePromptVersion)
          ..add('personaSkillVersion', personaSkillVersion)
          ..add('modelVersion', modelVersion)
          ..add('report', report)
          ..add('warnings', warnings)
          ..add('classification', classification)
          ..add('medicalRecord', medicalRecord)
          ..add('errorMessage', errorMessage)
          ..add('aiProgress', aiProgress))
        .toString();
  }
}

class AgentArtifactResponseBuilder
    implements
        Builder<AgentArtifactResponse, AgentArtifactResponseBuilder>,
        AgentResponseBuilder {
  _$AgentArtifactResponse? _$v;

  String? _accessPointKey;
  String? get accessPointKey => _$this._accessPointKey;
  set accessPointKey(covariant String? accessPointKey) =>
      _$this._accessPointKey = accessPointKey;

  bool? _ok;
  bool? get ok => _$this._ok;
  set ok(covariant bool? ok) => _$this._ok = ok;

  String? _inputType;
  String? get inputType => _$this._inputType;
  set inputType(covariant String? inputType) => _$this._inputType = inputType;

  String? _promptVersion;
  String? get promptVersion => _$this._promptVersion;
  set promptVersion(covariant String? promptVersion) =>
      _$this._promptVersion = promptVersion;

  String? _questionnairePromptVersion;
  String? get questionnairePromptVersion => _$this._questionnairePromptVersion;
  set questionnairePromptVersion(
          covariant String? questionnairePromptVersion) =>
      _$this._questionnairePromptVersion = questionnairePromptVersion;

  String? _personaSkillVersion;
  String? get personaSkillVersion => _$this._personaSkillVersion;
  set personaSkillVersion(covariant String? personaSkillVersion) =>
      _$this._personaSkillVersion = personaSkillVersion;

  String? _modelVersion;
  String? get modelVersion => _$this._modelVersion;
  set modelVersion(covariant String? modelVersion) =>
      _$this._modelVersion = modelVersion;

  JsonObject? _report;
  JsonObject? get report => _$this._report;
  set report(covariant JsonObject? report) => _$this._report = report;

  ListBuilder<String>? _warnings;
  ListBuilder<String> get warnings =>
      _$this._warnings ??= ListBuilder<String>();
  set warnings(covariant ListBuilder<String>? warnings) =>
      _$this._warnings = warnings;

  String? _classification;
  String? get classification => _$this._classification;
  set classification(covariant String? classification) =>
      _$this._classification = classification;

  String? _medicalRecord;
  String? get medicalRecord => _$this._medicalRecord;
  set medicalRecord(covariant String? medicalRecord) =>
      _$this._medicalRecord = medicalRecord;

  String? _errorMessage;
  String? get errorMessage => _$this._errorMessage;
  set errorMessage(covariant String? errorMessage) =>
      _$this._errorMessage = errorMessage;

  AIProgressBuilder? _aiProgress;
  AIProgressBuilder get aiProgress =>
      _$this._aiProgress ??= AIProgressBuilder();
  set aiProgress(covariant AIProgressBuilder? aiProgress) =>
      _$this._aiProgress = aiProgress;

  AgentArtifactResponseBuilder() {
    AgentArtifactResponse._defaults(this);
  }

  AgentArtifactResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessPointKey = $v.accessPointKey;
      _ok = $v.ok;
      _inputType = $v.inputType;
      _promptVersion = $v.promptVersion;
      _questionnairePromptVersion = $v.questionnairePromptVersion;
      _personaSkillVersion = $v.personaSkillVersion;
      _modelVersion = $v.modelVersion;
      _report = $v.report;
      _warnings = $v.warnings?.toBuilder();
      _classification = $v.classification;
      _medicalRecord = $v.medicalRecord;
      _errorMessage = $v.errorMessage;
      _aiProgress = $v.aiProgress?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant AgentArtifactResponse other) {
    _$v = other as _$AgentArtifactResponse;
  }

  @override
  void update(void Function(AgentArtifactResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AgentArtifactResponse build() => _build();

  _$AgentArtifactResponse _build() {
    _$AgentArtifactResponse _$result;
    try {
      _$result = _$v ??
          _$AgentArtifactResponse._(
            accessPointKey: accessPointKey,
            ok: ok,
            inputType: inputType,
            promptVersion: promptVersion,
            questionnairePromptVersion: questionnairePromptVersion,
            personaSkillVersion: personaSkillVersion,
            modelVersion: modelVersion,
            report: report,
            warnings: _warnings?.build(),
            classification: classification,
            medicalRecord: medicalRecord,
            errorMessage: errorMessage,
            aiProgress: _aiProgress?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'warnings';
        _warnings?.build();

        _$failedField = 'aiProgress';
        _aiProgress?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AgentArtifactResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
