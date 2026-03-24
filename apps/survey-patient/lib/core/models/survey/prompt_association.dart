class SurveyPromptAssociation {
  const SurveyPromptAssociation({
    required this.promptKey,
    required this.name,
    required this.outcomeType,
  });

  factory SurveyPromptAssociation.fromJson(Map<String, dynamic> json) {
    return SurveyPromptAssociation(
      promptKey: json['promptKey']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      outcomeType: json['outcomeType']?.toString() ?? '',
    );
  }

  final String promptKey;
  final String name;
  final String outcomeType;

  String get outcomeLabel {
    switch (outcomeType) {
      case 'patient_condition_overview':
      case 'patientConditionOverview':
        return 'Visão geral da condição do paciente';
      case 'clinical_diagnostic_report':
      case 'clinicalDiagnosticReport':
        return 'Relatório diagnóstico clínico';
      case 'clinical_referral_letter':
      case 'clinicalReferralLetter':
        return 'Carta de encaminhamento clínico';
      case 'parental_guidance':
      case 'parentalGuidance':
        return 'Orientações parentais';
      case 'educational_support_summary':
      case 'educationalSupportSummary':
        return 'Resumo de apoio educacional';
      default:
        return name;
    }
  }
}
