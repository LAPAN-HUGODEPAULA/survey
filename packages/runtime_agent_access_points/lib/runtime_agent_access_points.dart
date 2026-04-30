library;

enum RuntimeAccessPointAvailability { configurable, observedOnly }

class RuntimeAccessPointDescriptor {
  const RuntimeAccessPointDescriptor({
    required this.accessPointKey,
    required this.name,
    required this.sourceApp,
    required this.flowKey,
    required this.surfaceLabel,
    required this.description,
    required this.availability,
    this.notes,
  });

  final String accessPointKey;
  final String name;
  final String sourceApp;
  final String flowKey;
  final String surfaceLabel;
  final String description;
  final RuntimeAccessPointAvailability availability;
  final String? notes;

  bool get isConfigurable =>
      availability == RuntimeAccessPointAvailability.configurable;
}

class RuntimeAccessPointCatalog {
  static const surveyFrontendThankYouAutoAnalysis = RuntimeAccessPointDescriptor(
    accessPointKey: 'survey_frontend.thank_you.auto_analysis',
    name: 'Análise automática do questionário profissional',
    sourceApp: 'survey-frontend',
    flowKey: 'thank_you.auto_analysis',
    surfaceLabel: 'survey-frontend · Questionários · Tela final',
    description:
        'Gera automaticamente o relatório final após o envio do questionário pelo profissional usando a base de triagem de pacientes.',
    availability: RuntimeAccessPointAvailability.configurable,
  );

  static const surveyPatientThankYouAutoAnalysis = RuntimeAccessPointDescriptor(
    accessPointKey: 'survey_patient.thank_you.auto_analysis',
    name: 'Análise automática do questionário do paciente',
    sourceApp: 'survey-patient',
    flowKey: 'thank_you.auto_analysis',
    surfaceLabel: 'survey-patient · Questionários · Tela final',
    description:
        'Gera automaticamente a avaliação preliminar após o envio do questionário pelo paciente.',
    availability: RuntimeAccessPointAvailability.configurable,
  );

  static const surveyPatientReportDetailedAnalysis = RuntimeAccessPointDescriptor(
    accessPointKey: 'survey_patient.report.detailed_analysis',
    name: 'Relatório detalhado do questionário do paciente',
    sourceApp: 'survey-patient',
    flowKey: 'report.detailed_analysis',
    surfaceLabel: 'survey-patient · Questionários · Gerar relatório',
    description:
        'Gera o relatório clínico detalhado a partir das respostas do questionário do paciente.',
    availability: RuntimeAccessPointAvailability.configurable,
  );

  static const screenerReportDetailedAnalysis = RuntimeAccessPointDescriptor(
    accessPointKey: 'screener.report.detailed_analysis',
    name: 'Relatório clínico detalhado do paciente',
    sourceApp: 'survey-frontend',
    flowKey: 'report.detailed_analysis',
    surfaceLabel: 'survey-frontend · Questionários · Gerar relatório',
    description:
        'Gera um relatório clínico detalhado a partir das respostas registradas pelo profissional.',
    availability: RuntimeAccessPointAvailability.configurable,
  );

  static const screenerDocumentClinicalReferral = RuntimeAccessPointDescriptor(
    accessPointKey: 'screener.document.clinical_referral',
    name: 'Geração de carta de encaminhamento clínico',
    sourceApp: 'survey-frontend',
    flowKey: 'report.clinical_referral',
    surfaceLabel: 'survey-frontend · Relatório · Encaminhamento clínico',
    description:
        'Gera uma carta de encaminhamento clínico para continuidade do cuidado.',
    availability: RuntimeAccessPointAvailability.configurable,
  );

  static const screenerDocumentSchoolReferral = RuntimeAccessPointDescriptor(
    accessPointKey: 'screener.document.school_referral',
    name: 'Geração de carta de encaminhamento escolar',
    sourceApp: 'survey-frontend',
    flowKey: 'report.school_referral',
    surfaceLabel: 'survey-frontend · Relatório · Encaminhamento escolar',
    description:
        'Gera uma carta de encaminhamento escolar com foco em ajustes pedagógicos.',
    availability: RuntimeAccessPointAvailability.configurable,
  );

  static const screenerDocumentParentOrientation = RuntimeAccessPointDescriptor(
    accessPointKey: 'screener.document.parent_orientation',
    name: 'Geração de carta de orientação aos pais',
    sourceApp: 'survey-frontend',
    flowKey: 'report.parent_orientation',
    surfaceLabel: 'survey-frontend · Relatório · Orientação aos pais',
    description:
        'Gera uma carta de orientação para cuidadores com recomendações práticas.',
    availability: RuntimeAccessPointAvailability.configurable,
  );

  static const clinicalNarrativeGenerateReport = RuntimeAccessPointDescriptor(
    accessPointKey: 'clinical_narrative.narrative.generate_report',
    name: 'Geração de prontuário da narrativa clínica',
    sourceApp: 'clinical-narrative',
    flowKey: 'narrative.generate_report',
    surfaceLabel: 'clinical-narrative · Narrativa clínica · Gerar prontuário',
    description:
        'Gera o prontuário final a partir do rascunho clínico preparado pelo profissional.',
    availability: RuntimeAccessPointAvailability.configurable,
  );

  static const clinicalNarrativeChatAnalysis = RuntimeAccessPointDescriptor(
    accessPointKey: 'clinical_narrative.chat.analysis',
    name: 'Análise assistida da conversa clínica',
    sourceApp: 'clinical-narrative',
    flowKey: 'chat.analysis',
    surfaceLabel: 'clinical-narrative · Chat clínico · Avaliação assistida',
    description:
        'Atualiza hipóteses, alertas e sugestões durante a conversa clínica.',
    availability: RuntimeAccessPointAvailability.observedOnly,
    notes:
        'Observado no runtime, mas ainda não configurável por Acessos porque usa /clinical_writer/analysis.',
  );

  static const clinicalNarrativeVoiceTranscription = RuntimeAccessPointDescriptor(
    accessPointKey: 'clinical_narrative.chat.voice_transcription',
    name: 'Transcrição de voz da conversa clínica',
    sourceApp: 'clinical-narrative',
    flowKey: 'chat.voice_transcription',
    surfaceLabel: 'clinical-narrative · Chat clínico · Transcrição de voz',
    description:
        'Transcreve o áudio capturado durante a consulta antes do envio ao chat.',
    availability: RuntimeAccessPointAvailability.observedOnly,
    notes:
        'Observado no runtime, mas ainda não configurável por Acessos porque usa /voice/transcriptions.',
  );

  static const List<RuntimeAccessPointDescriptor> configurable = [
    surveyFrontendThankYouAutoAnalysis,
    surveyPatientThankYouAutoAnalysis,
    surveyPatientReportDetailedAnalysis,
    screenerReportDetailedAnalysis,
    screenerDocumentClinicalReferral,
    screenerDocumentSchoolReferral,
    screenerDocumentParentOrientation,
    clinicalNarrativeGenerateReport,
  ];

  static const List<RuntimeAccessPointDescriptor> observedOnly = [
    clinicalNarrativeChatAnalysis,
    clinicalNarrativeVoiceTranscription,
  ];

  static const List<RuntimeAccessPointDescriptor> all = [
    surveyFrontendThankYouAutoAnalysis,
    surveyPatientThankYouAutoAnalysis,
    surveyPatientReportDetailedAnalysis,
    screenerReportDetailedAnalysis,
    screenerDocumentClinicalReferral,
    screenerDocumentSchoolReferral,
    screenerDocumentParentOrientation,
    clinicalNarrativeGenerateReport,
    clinicalNarrativeChatAnalysis,
    clinicalNarrativeVoiceTranscription,
  ];

  static RuntimeAccessPointDescriptor? byKey(String? accessPointKey) {
    if (accessPointKey == null || accessPointKey.isEmpty) {
      return null;
    }
    for (final descriptor in all) {
      if (descriptor.accessPointKey == accessPointKey) {
        return descriptor;
      }
    }
    return null;
  }
}
