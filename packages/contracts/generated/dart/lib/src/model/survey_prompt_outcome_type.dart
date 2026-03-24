//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'survey_prompt_outcome_type.g.dart';

class SurveyPromptOutcomeType extends EnumClass {

  @BuiltValueEnumConst(wireName: r'patient_condition_overview')
  static const SurveyPromptOutcomeType patientConditionOverview = _$patientConditionOverview;
  @BuiltValueEnumConst(wireName: r'clinical_diagnostic_report')
  static const SurveyPromptOutcomeType clinicalDiagnosticReport = _$clinicalDiagnosticReport;
  @BuiltValueEnumConst(wireName: r'clinical_referral_letter')
  static const SurveyPromptOutcomeType clinicalReferralLetter = _$clinicalReferralLetter;
  @BuiltValueEnumConst(wireName: r'parental_guidance')
  static const SurveyPromptOutcomeType parentalGuidance = _$parentalGuidance;
  @BuiltValueEnumConst(wireName: r'educational_support_summary')
  static const SurveyPromptOutcomeType educationalSupportSummary = _$educationalSupportSummary;

  static Serializer<SurveyPromptOutcomeType> get serializer => _$surveyPromptOutcomeTypeSerializer;

  const SurveyPromptOutcomeType._(String name): super(name);

  static BuiltSet<SurveyPromptOutcomeType> get values => _$values;
  static SurveyPromptOutcomeType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class SurveyPromptOutcomeTypeMixin = Object with _$SurveyPromptOutcomeTypeMixin;

