enum SurveyPromptOutcome {
  patientConditionOverview(
    'patient_condition_overview',
    'Visão geral da condição do paciente',
  ),
  clinicalDiagnosticReport(
    'clinical_diagnostic_report',
    'Relatório diagnóstico clínico',
  ),
  clinicalReferralLetter(
    'clinical_referral_letter',
    'Carta de encaminhamento clínico',
  ),
  parentalGuidance(
    'parental_guidance',
    'Orientações parentais',
  ),
  educationalSupportSummary(
    'educational_support_summary',
    'Resumo de apoio educacional',
  );

  const SurveyPromptOutcome(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static SurveyPromptOutcome fromApiValue(String value) {
    return SurveyPromptOutcome.values.firstWhere(
      (item) =>
          item.apiValue == value ||
          item.name == value ||
          item.name.toLowerCase() == value.toLowerCase(),
      orElse: () => SurveyPromptOutcome.patientConditionOverview,
    );
  }
}

class SurveyPromptDraft {
  SurveyPromptDraft({
    required this.promptKey,
    required this.name,
    required this.outcomeType,
    required this.promptText,
    this.createdAt,
    this.modifiedAt,
  });

  String promptKey;
  String name;
  SurveyPromptOutcome outcomeType;
  String promptText;
  DateTime? createdAt;
  DateTime? modifiedAt;

  SurveyPromptDraft copy() {
    return SurveyPromptDraft(
      promptKey: promptKey,
      name: name,
      outcomeType: outcomeType,
      promptText: promptText,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
    );
  }
}

class SurveyPromptAssociationDraft {
  SurveyPromptAssociationDraft({
    required this.promptKey,
    required this.name,
    required this.outcomeType,
  });

  String promptKey;
  String name;
  SurveyPromptOutcome outcomeType;

  SurveyPromptAssociationDraft copy() {
    return SurveyPromptAssociationDraft(
      promptKey: promptKey,
      name: name,
      outcomeType: outcomeType,
    );
  }
}
