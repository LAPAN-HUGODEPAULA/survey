import 'package:clinical_narrative_app/core/providers/chat_provider.dart';
import 'package:design_system_flutter/widgets.dart';

class AssistantStatusViewModel {
  const AssistantStatusViewModel({
    required this.phaseKey,
    required this.phaseLabel,
    required this.currentMessage,
    required this.wayfindingMessage,
    required this.reassuranceMessage,
    required this.steps,
    required this.severity,
    required this.processing,
    required this.showRetry,
    required this.showCancel,
  });

  final String phaseKey;
  final String phaseLabel;
  final String currentMessage;
  final String wayfindingMessage;
  final String reassuranceMessage;
  final List<DsStepData> steps;
  final DsStatusType severity;
  final bool processing;
  final bool showRetry;
  final bool showCancel;

  String get announcement =>
      'Status do assistente: $phaseLabel. $currentMessage';
}

class AssistantStatusController {
  const AssistantStatusController();

  static const List<String> _orderedPhases = <String>[
    'intake',
    'assessment',
    'plan',
    'wrap_up',
  ];

  static const Map<String, String> _phaseLabelByKey = <String, String>{
    'intake': 'Anamnese',
    'assessment': 'Avaliação Clínica',
    'plan': 'Planejamento',
    'wrap_up': 'Encerramento',
  };

  static const Map<String, String> _phaseMessageByKey = <String, String>{
    'intake': 'Organizando a anamnese com os pontos principais',
    'assessment': 'Analisando sinais clínicos com foco no caso',
    'plan': 'Estruturando o plano clínico de forma objetiva',
    'wrap_up': 'Preparando o encerramento com um resumo claro',
  };

  String normalizePhase(String? phase) {
    final normalized = (phase ?? '').trim().toLowerCase();
    if (_phaseLabelByKey.containsKey(normalized)) {
      return normalized;
    }
    return 'intake';
  }

  String phaseLabel(String? phase) {
    final normalized = normalizePhase(phase);
    return _phaseLabelByKey[normalized] ?? 'Anamnese';
  }

  String phaseMessage(String? phase) {
    final normalized = normalizePhase(phase);
    return _phaseMessageByKey[normalized] ?? 'Organizando a anamnese';
  }

  AssistantStatusViewModel resolve({
    required ChatProvider provider,
    required bool isRecording,
    required bool isTranscribing,
    String? voiceError,
  }) {
    final phase = normalizePhase(
      provider.analysisPhase ?? provider.session?.phase,
    );
    final steps = _buildSteps(phase);

    final normalizedVoiceError = voiceError?.trim();
    if (normalizedVoiceError != null && normalizedVoiceError.isNotEmpty) {
      return AssistantStatusViewModel(
        phaseKey: phase,
        phaseLabel: 'Captura de voz',
        currentMessage: normalizedVoiceError,
        wayfindingMessage:
            'Ajuste as permissões do microfone para continuar com entrada de voz com segurança.',
        reassuranceMessage:
            'A conversa continua disponível para digitação manual.',
        steps: steps,
        severity: DsStatusType.error,
        processing: false,
        showRetry: false,
        showCancel: false,
      );
    }

    if (isRecording) {
      return AssistantStatusViewModel(
        phaseKey: phase,
        phaseLabel: 'Captura de voz',
        currentMessage: 'Captando áudio da conversa clínica',
        wayfindingMessage:
            'Finalize a gravação quando concluir o relato; você pode revisar antes de enviar.',
        reassuranceMessage:
            'A conversa permanece disponível enquanto o áudio é capturado.',
        steps: steps,
        severity: DsStatusType.info,
        processing: true,
        showRetry: false,
        showCancel: false,
      );
    }

    if (isTranscribing) {
      return AssistantStatusViewModel(
        phaseKey: phase,
        phaseLabel: 'Transcrição clínica',
        currentMessage: 'Convertendo áudio em texto clínico',
        wayfindingMessage:
            'Você pode revisar as mensagens já registradas enquanto concluímos a transcrição.',
        reassuranceMessage:
            'A transcrição pode levar alguns segundos dependendo da duração do áudio.',
        steps: steps,
        severity: DsStatusType.info,
        processing: true,
        showRetry: false,
        showCancel: false,
      );
    }

    if (provider.hasAssistantFailure) {
      return AssistantStatusViewModel(
        phaseKey: phase,
        phaseLabel: phaseLabel(phase),
        currentMessage:
            provider.assistantFailureMessage ??
            'A análise demorou mais do que o esperado.',
        wayfindingMessage:
            'O processamento automático não foi concluído nesta tentativa, mas você pode seguir com segurança.',
        reassuranceMessage:
            'Você pode tentar novamente ou continuar manualmente.',
        steps: steps,
        severity: _statusFromSeverity(provider.assistantFailureSeverity),
        processing: false,
        showRetry: provider.canRetryAssistant,
        showCancel: true,
      );
    }

    if (provider.isAssistantBusy) {
      return AssistantStatusViewModel(
        phaseKey: phase,
        phaseLabel: phaseLabel(phase),
        currentMessage: phaseMessage(phase),
        wayfindingMessage:
            'Acompanhe a etapa atual sem perder o contexto da conversa clínica.',
        reassuranceMessage:
            'Você pode continuar registrando informações enquanto processamos esta etapa.',
        steps: steps,
        severity: DsStatusType.info,
        processing: true,
        showRetry: false,
        showCancel: true,
      );
    }

    final notice = provider.assistantNoticeMessage?.trim();
    if (notice != null && notice.isNotEmpty) {
      return AssistantStatusViewModel(
        phaseKey: phase,
        phaseLabel: phaseLabel(phase),
        currentMessage: notice,
        wayfindingMessage:
            'O status foi atualizado conforme sua intervenção no processamento.',
        reassuranceMessage: 'Você pode continuar a conversa normalmente.',
        steps: steps,
        severity: DsStatusType.info,
        processing: false,
        showRetry: false,
        showCancel: false,
      );
    }

    return AssistantStatusViewModel(
      phaseKey: phase,
      phaseLabel: phaseLabel(phase),
      currentMessage: 'Assistente pronto para a próxima etapa clínica',
      wayfindingMessage:
          'Quando você enviar uma nova mensagem, o status será atualizado automaticamente.',
      reassuranceMessage: 'A conversa está disponível para entrada manual.',
      steps: steps,
      severity: DsStatusType.success,
      processing: false,
      showRetry: false,
      showCancel: false,
    );
  }

  List<DsStepData> _buildSteps(String activePhase) {
    final activeIndex = _orderedPhases.indexOf(activePhase);
    final resolvedActiveIndex = activeIndex < 0 ? 0 : activeIndex;

    return _orderedPhases
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final phase = entry.value;

          final state = index < resolvedActiveIndex
              ? DsStepState.done
              : index == resolvedActiveIndex
              ? DsStepState.active
              : DsStepState.todo;

          return DsStepData(
            label: _phaseLabelByKey[phase] ?? phase,
            state: state,
          );
        })
        .toList(growable: false);
  }

  DsStatusType _statusFromSeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
      case 'error':
        return DsStatusType.error;
      case 'success':
        return DsStatusType.success;
      case 'warning':
        return DsStatusType.warning;
      default:
        return DsStatusType.info;
    }
  }
}
