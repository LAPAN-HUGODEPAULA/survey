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
        'Gera automaticamente o relatório final após o envio do questionário pelo profissional.',
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
    clinicalNarrativeGenerateReport,
  ];

  static const List<RuntimeAccessPointDescriptor> observedOnly = [
    clinicalNarrativeChatAnalysis,
    clinicalNarrativeVoiceTranscription,
  ];

  static const List<RuntimeAccessPointDescriptor> all = [
    surveyFrontendThankYouAutoAnalysis,
    surveyPatientThankYouAutoAnalysis,
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
