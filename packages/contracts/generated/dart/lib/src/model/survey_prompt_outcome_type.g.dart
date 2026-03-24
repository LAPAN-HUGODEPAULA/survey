// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_prompt_outcome_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SurveyPromptOutcomeType _$patientConditionOverview =
    const SurveyPromptOutcomeType._('patientConditionOverview');
const SurveyPromptOutcomeType _$clinicalDiagnosticReport =
    const SurveyPromptOutcomeType._('clinicalDiagnosticReport');
const SurveyPromptOutcomeType _$clinicalReferralLetter =
    const SurveyPromptOutcomeType._('clinicalReferralLetter');
const SurveyPromptOutcomeType _$parentalGuidance =
    const SurveyPromptOutcomeType._('parentalGuidance');
const SurveyPromptOutcomeType _$educationalSupportSummary =
    const SurveyPromptOutcomeType._('educationalSupportSummary');

SurveyPromptOutcomeType _$valueOf(String name) {
  switch (name) {
    case 'patientConditionOverview':
      return _$patientConditionOverview;
    case 'clinicalDiagnosticReport':
      return _$clinicalDiagnosticReport;
    case 'clinicalReferralLetter':
      return _$clinicalReferralLetter;
    case 'parentalGuidance':
      return _$parentalGuidance;
    case 'educationalSupportSummary':
      return _$educationalSupportSummary;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SurveyPromptOutcomeType> _$values =
    BuiltSet<SurveyPromptOutcomeType>(const <SurveyPromptOutcomeType>[
  _$patientConditionOverview,
  _$clinicalDiagnosticReport,
  _$clinicalReferralLetter,
  _$parentalGuidance,
  _$educationalSupportSummary,
]);

class _$SurveyPromptOutcomeTypeMeta {
  const _$SurveyPromptOutcomeTypeMeta();
  SurveyPromptOutcomeType get patientConditionOverview =>
      _$patientConditionOverview;
  SurveyPromptOutcomeType get clinicalDiagnosticReport =>
      _$clinicalDiagnosticReport;
  SurveyPromptOutcomeType get clinicalReferralLetter =>
      _$clinicalReferralLetter;
  SurveyPromptOutcomeType get parentalGuidance => _$parentalGuidance;
  SurveyPromptOutcomeType get educationalSupportSummary =>
      _$educationalSupportSummary;
  SurveyPromptOutcomeType valueOf(String name) => _$valueOf(name);
  BuiltSet<SurveyPromptOutcomeType> get values => _$values;
}

abstract class _$SurveyPromptOutcomeTypeMixin {
  // ignore: non_constant_identifier_names
  _$SurveyPromptOutcomeTypeMeta get SurveyPromptOutcomeType =>
      const _$SurveyPromptOutcomeTypeMeta();
}

Serializer<SurveyPromptOutcomeType> _$surveyPromptOutcomeTypeSerializer =
    _$SurveyPromptOutcomeTypeSerializer();

class _$SurveyPromptOutcomeTypeSerializer
    implements PrimitiveSerializer<SurveyPromptOutcomeType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'patientConditionOverview': 'patient_condition_overview',
    'clinicalDiagnosticReport': 'clinical_diagnostic_report',
    'clinicalReferralLetter': 'clinical_referral_letter',
    'parentalGuidance': 'parental_guidance',
    'educationalSupportSummary': 'educational_support_summary',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'patient_condition_overview': 'patientConditionOverview',
    'clinical_diagnostic_report': 'clinicalDiagnosticReport',
    'clinical_referral_letter': 'clinicalReferralLetter',
    'parental_guidance': 'parentalGuidance',
    'educational_support_summary': 'educationalSupportSummary',
  };

  @override
  final Iterable<Type> types = const <Type>[SurveyPromptOutcomeType];
  @override
  final String wireName = 'SurveyPromptOutcomeType';

  @override
  Object serialize(Serializers serializers, SurveyPromptOutcomeType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SurveyPromptOutcomeType deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SurveyPromptOutcomeType.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
