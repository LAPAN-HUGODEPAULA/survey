// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

abstract class SurveyResponseBuilder {
  void replace(SurveyResponse other);
  void update(void Function(SurveyResponseBuilder) updates);
  String? get id;
  set id(String? id);

  String? get surveyId;
  set surveyId(String? surveyId);

  String? get creatorId;
  set creatorId(String? creatorId);

  DateTime? get testDate;
  set testDate(DateTime? testDate);

  String? get screenerId;
  set screenerId(String? screenerId);

  String? get accessLinkToken;
  set accessLinkToken(String? accessLinkToken);

  String? get promptKey;
  set promptKey(String? promptKey);

  String? get personaSkillKey;
  set personaSkillKey(String? personaSkillKey);

  String? get outputProfile;
  set outputProfile(String? outputProfile);

  PatientBuilder get patient;
  set patient(PatientBuilder? patient);

  ListBuilder<Answer> get answers;
  set answers(ListBuilder<Answer>? answers);
}

class _$$SurveyResponse extends $SurveyResponse {
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
  final String? promptKey;
  @override
  final String? personaSkillKey;
  @override
  final String? outputProfile;
  @override
  final Patient? patient;
  @override
  final BuiltList<Answer> answers;

  factory _$$SurveyResponse([void Function($SurveyResponseBuilder)? updates]) =>
      ($SurveyResponseBuilder()..update(updates))._build();

  _$$SurveyResponse._(
      {this.id,
      required this.surveyId,
      required this.creatorId,
      this.testDate,
      required this.screenerId,
      this.accessLinkToken,
      this.promptKey,
      this.personaSkillKey,
      this.outputProfile,
      this.patient,
      required this.answers})
      : super._();
  @override
  $SurveyResponse rebuild(void Function($SurveyResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  $SurveyResponseBuilder toBuilder() => $SurveyResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is $SurveyResponse &&
        id == other.id &&
        surveyId == other.surveyId &&
        creatorId == other.creatorId &&
        testDate == other.testDate &&
        screenerId == other.screenerId &&
        accessLinkToken == other.accessLinkToken &&
        promptKey == other.promptKey &&
        personaSkillKey == other.personaSkillKey &&
        outputProfile == other.outputProfile &&
        patient == other.patient &&
        answers == other.answers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, surveyId.hashCode);
    _$hash = $jc(_$hash, creatorId.hashCode);
    _$hash = $jc(_$hash, testDate.hashCode);
    _$hash = $jc(_$hash, screenerId.hashCode);
    _$hash = $jc(_$hash, accessLinkToken.hashCode);
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
    return (newBuiltValueToStringHelper(r'$SurveyResponse')
          ..add('id', id)
          ..add('surveyId', surveyId)
          ..add('creatorId', creatorId)
          ..add('testDate', testDate)
          ..add('screenerId', screenerId)
          ..add('accessLinkToken', accessLinkToken)
          ..add('promptKey', promptKey)
          ..add('personaSkillKey', personaSkillKey)
          ..add('outputProfile', outputProfile)
          ..add('patient', patient)
          ..add('answers', answers))
        .toString();
  }
}

class $SurveyResponseBuilder
    implements
        Builder<$SurveyResponse, $SurveyResponseBuilder>,
        SurveyResponseBuilder {
  _$$SurveyResponse? _$v;

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

  $SurveyResponseBuilder() {
    $SurveyResponse._defaults(this);
  }

  $SurveyResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _surveyId = $v.surveyId;
      _creatorId = $v.creatorId;
      _testDate = $v.testDate;
      _screenerId = $v.screenerId;
      _accessLinkToken = $v.accessLinkToken;
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
  void replace(covariant $SurveyResponse other) {
    _$v = other as _$$SurveyResponse;
  }

  @override
  void update(void Function($SurveyResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  $SurveyResponse build() => _build();

  _$$SurveyResponse _build() {
    _$$SurveyResponse _$result;
    try {
      _$result = _$v ??
          _$$SurveyResponse._(
            id: id,
            surveyId: BuiltValueNullFieldError.checkNotNull(
                surveyId, r'$SurveyResponse', 'surveyId'),
            creatorId: BuiltValueNullFieldError.checkNotNull(
                creatorId, r'$SurveyResponse', 'creatorId'),
            testDate: testDate,
            screenerId: BuiltValueNullFieldError.checkNotNull(
                screenerId, r'$SurveyResponse', 'screenerId'),
            accessLinkToken: accessLinkToken,
            promptKey: promptKey,
            personaSkillKey: personaSkillKey,
            outputProfile: outputProfile,
            patient: _patient?.build(),
            answers: answers.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'patient';
        _patient?.build();
        _$failedField = 'answers';
        answers.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'$SurveyResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
