// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_response_with_agent.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SurveyResponseWithAgent extends SurveyResponseWithAgent {
  @override
  final AgentResponse? agentResponse;
  @override
  final BuiltList<AgentArtifactResponse>? agentResponses;
  @override
  final String? id;
  @override
  final String surveyId;
  @override
  final String creatorId;
  @override
  final DateTime? testDate;
  @override
  final String screenerId;
  @override
  final String? accessLinkToken;
  @override
  final String? accessPointKey;
  @override
  final String? promptKey;
  @override
  final String? personaSkillKey;
  @override
  final String? outputProfile;
  @override
  final Patient? patient;
  @override
  final BuiltList<Answer> answers;

  factory _$SurveyResponseWithAgent(
          [void Function(SurveyResponseWithAgentBuilder)? updates]) =>
      (SurveyResponseWithAgentBuilder()..update(updates))._build();

  _$SurveyResponseWithAgent._(
      {this.agentResponse,
      this.agentResponses,
      this.id,
      required this.surveyId,
      required this.creatorId,
      this.testDate,
      required this.screenerId,
      this.accessLinkToken,
      this.accessPointKey,
      this.promptKey,
      this.personaSkillKey,
      this.outputProfile,
      this.patient,
      required this.answers})
      : super._();
  @override
  SurveyResponseWithAgent rebuild(
          void Function(SurveyResponseWithAgentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SurveyResponseWithAgentBuilder toBuilder() =>
      SurveyResponseWithAgentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SurveyResponseWithAgent &&
        agentResponse == other.agentResponse &&
        agentResponses == other.agentResponses &&
        id == other.id &&
        surveyId == other.surveyId &&
        creatorId == other.creatorId &&
        testDate == other.testDate &&
        screenerId == other.screenerId &&
        accessLinkToken == other.accessLinkToken &&
        accessPointKey == other.accessPointKey &&
        promptKey == other.promptKey &&
        personaSkillKey == other.personaSkillKey &&
        outputProfile == other.outputProfile &&
        patient == other.patient &&
        answers == other.answers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, agentResponse.hashCode);
    _$hash = $jc(_$hash, agentResponses.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, surveyId.hashCode);
    _$hash = $jc(_$hash, creatorId.hashCode);
    _$hash = $jc(_$hash, testDate.hashCode);
    _$hash = $jc(_$hash, screenerId.hashCode);
    _$hash = $jc(_$hash, accessLinkToken.hashCode);
    _$hash = $jc(_$hash, accessPointKey.hashCode);
    _$hash = $jc(_$hash, promptKey.hashCode);
    _$hash = $jc(_$hash, personaSkillKey.hashCode);
    _$hash = $jc(_$hash, outputProfile.hashCode);
    _$hash = $jc(_$hash, patient.hashCode);
    _$hash = $jc(_$hash, answers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SurveyResponseWithAgent')
          ..add('agentResponse', agentResponse)
          ..add('agentResponses', agentResponses)
          ..add('id', id)
          ..add('surveyId', surveyId)
          ..add('creatorId', creatorId)
          ..add('testDate', testDate)
          ..add('screenerId', screenerId)
          ..add('accessLinkToken', accessLinkToken)
          ..add('accessPointKey', accessPointKey)
          ..add('promptKey', promptKey)
          ..add('personaSkillKey', personaSkillKey)
          ..add('outputProfile', outputProfile)
          ..add('patient', patient)
          ..add('answers', answers))
        .toString();
  }
}

class SurveyResponseWithAgentBuilder
    implements
        Builder<SurveyResponseWithAgent, SurveyResponseWithAgentBuilder>,
        SurveyResponseBuilder {
  _$SurveyResponseWithAgent? _$v;

  AgentResponse? _agentResponse;
  AgentResponse? get agentResponse => _$this._agentResponse;
  set agentResponse(covariant AgentResponse? agentResponse) =>
      _$this._agentResponse = agentResponse;

  ListBuilder<AgentArtifactResponse>? _agentResponses;
  ListBuilder<AgentArtifactResponse> get agentResponses =>
      _$this._agentResponses ??= ListBuilder<AgentArtifactResponse>();
  set agentResponses(
          covariant ListBuilder<AgentArtifactResponse>? agentResponses) =>
      _$this._agentResponses = agentResponses;

  String? _id;
  String? get id => _$this._id;
  set id(covariant String? id) => _$this._id = id;

  String? _surveyId;
  String? get surveyId => _$this._surveyId;
  set surveyId(covariant String? surveyId) => _$this._surveyId = surveyId;

  String? _creatorId;
  String? get creatorId => _$this._creatorId;
  set creatorId(covariant String? creatorId) => _$this._creatorId = creatorId;

  DateTime? _testDate;
  DateTime? get testDate => _$this._testDate;
  set testDate(covariant DateTime? testDate) => _$this._testDate = testDate;

  String? _screenerId;
  String? get screenerId => _$this._screenerId;
  set screenerId(covariant String? screenerId) =>
      _$this._screenerId = screenerId;

  String? _accessLinkToken;
  String? get accessLinkToken => _$this._accessLinkToken;
  set accessLinkToken(covariant String? accessLinkToken) =>
      _$this._accessLinkToken = accessLinkToken;

  String? _accessPointKey;
  String? get accessPointKey => _$this._accessPointKey;
  set accessPointKey(covariant String? accessPointKey) =>
      _$this._accessPointKey = accessPointKey;

  String? _promptKey;
  String? get promptKey => _$this._promptKey;
  set promptKey(covariant String? promptKey) => _$this._promptKey = promptKey;

  String? _personaSkillKey;
  String? get personaSkillKey => _$this._personaSkillKey;
  set personaSkillKey(covariant String? personaSkillKey) =>
      _$this._personaSkillKey = personaSkillKey;

  String? _outputProfile;
  String? get outputProfile => _$this._outputProfile;
  set outputProfile(covariant String? outputProfile) =>
      _$this._outputProfile = outputProfile;

  PatientBuilder? _patient;
  PatientBuilder get patient => _$this._patient ??= PatientBuilder();
  set patient(covariant PatientBuilder? patient) => _$this._patient = patient;

  ListBuilder<Answer>? _answers;
  ListBuilder<Answer> get answers => _$this._answers ??= ListBuilder<Answer>();
  set answers(covariant ListBuilder<Answer>? answers) =>
      _$this._answers = answers;

  SurveyResponseWithAgentBuilder() {
    SurveyResponseWithAgent._defaults(this);
  }

  SurveyResponseWithAgentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _agentResponse = $v.agentResponse;
      _agentResponses = $v.agentResponses?.toBuilder();
      _id = $v.id;
      _surveyId = $v.surveyId;
      _creatorId = $v.creatorId;
      _testDate = $v.testDate;
      _screenerId = $v.screenerId;
      _accessLinkToken = $v.accessLinkToken;
      _accessPointKey = $v.accessPointKey;
      _promptKey = $v.promptKey;
      _personaSkillKey = $v.personaSkillKey;
      _outputProfile = $v.outputProfile;
      _patient = $v.patient?.toBuilder();
      _answers = $v.answers.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant SurveyResponseWithAgent other) {
    _$v = other as _$SurveyResponseWithAgent;
  }

  @override
  void update(void Function(SurveyResponseWithAgentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SurveyResponseWithAgent build() => _build();

  _$SurveyResponseWithAgent _build() {
    _$SurveyResponseWithAgent _$result;
    try {
      _$result = _$v ??
          _$SurveyResponseWithAgent._(
            agentResponse: agentResponse,
            agentResponses: _agentResponses?.build(),
            id: id,
            surveyId: BuiltValueNullFieldError.checkNotNull(
                surveyId, r'SurveyResponseWithAgent', 'surveyId'),
            creatorId: BuiltValueNullFieldError.checkNotNull(
                creatorId, r'SurveyResponseWithAgent', 'creatorId'),
            testDate: testDate,
            screenerId: BuiltValueNullFieldError.checkNotNull(
                screenerId, r'SurveyResponseWithAgent', 'screenerId'),
            accessLinkToken: accessLinkToken,
            accessPointKey: accessPointKey,
            promptKey: promptKey,
            personaSkillKey: personaSkillKey,
            outputProfile: outputProfile,
            patient: _patient?.build(),
            answers: answers.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'agentResponses';
        _agentResponses?.build();

        _$failedField = 'patient';
        _patient?.build();
        _$failedField = 'answers';
        answers.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SurveyResponseWithAgent', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
