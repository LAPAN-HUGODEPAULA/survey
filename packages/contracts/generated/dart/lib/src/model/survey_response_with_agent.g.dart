// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_response_with_agent.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SurveyResponseWithAgent extends SurveyResponseWithAgent {
  @override
  final AgentResponse? agentResponse;
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
  final Patient? patient;
  @override
  final BuiltList<Answer> answers;

  factory _$SurveyResponseWithAgent(
          [void Function(SurveyResponseWithAgentBuilder)? updates]) =>
      (SurveyResponseWithAgentBuilder()..update(updates))._build();

  _$SurveyResponseWithAgent._(
      {this.agentResponse,
      this.id,
      required this.surveyId,
      required this.creatorId,
      this.testDate,
      required this.screenerId,
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
        id == other.id &&
        surveyId == other.surveyId &&
        creatorId == other.creatorId &&
        testDate == other.testDate &&
        screenerId == other.screenerId &&
        patient == other.patient &&
        answers == other.answers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, agentResponse.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, surveyId.hashCode);
    _$hash = $jc(_$hash, creatorId.hashCode);
    _$hash = $jc(_$hash, testDate.hashCode);
    _$hash = $jc(_$hash, screenerId.hashCode);
    _$hash = $jc(_$hash, patient.hashCode);
    _$hash = $jc(_$hash, answers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SurveyResponseWithAgent')
          ..add('agentResponse', agentResponse)
          ..add('id', id)
          ..add('surveyId', surveyId)
          ..add('creatorId', creatorId)
          ..add('testDate', testDate)
          ..add('screenerId', screenerId)
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

  AgentResponseBuilder? _agentResponse;
  AgentResponseBuilder get agentResponse =>
      _$this._agentResponse ??= AgentResponseBuilder();
  set agentResponse(covariant AgentResponseBuilder? agentResponse) =>
      _$this._agentResponse = agentResponse;

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
      _agentResponse = $v.agentResponse?.toBuilder();
      _id = $v.id;
      _surveyId = $v.surveyId;
      _creatorId = $v.creatorId;
      _testDate = $v.testDate;
      _screenerId = $v.screenerId;
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
            agentResponse: _agentResponse?.build(),
            id: id,
            surveyId: BuiltValueNullFieldError.checkNotNull(
                surveyId, r'SurveyResponseWithAgent', 'surveyId'),
            creatorId: BuiltValueNullFieldError.checkNotNull(
                creatorId, r'SurveyResponseWithAgent', 'creatorId'),
            testDate: testDate,
            screenerId: BuiltValueNullFieldError.checkNotNull(
                screenerId, r'SurveyResponseWithAgent', 'screenerId'),
            patient: _patient?.build(),
            answers: answers.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'agentResponse';
        _agentResponse?.build();

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
