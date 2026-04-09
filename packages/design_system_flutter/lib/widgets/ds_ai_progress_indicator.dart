import 'package:design_system_flutter/theme/ds_tone_tokens.dart';
import 'package:design_system_flutter/widgets/ds_chip.dart';
import 'package:design_system_flutter/widgets/ds_emotional_tone_provider.dart';
import 'package:design_system_flutter/widgets/ds_feedback.dart';
import 'package:design_system_flutter/widgets/ds_surface.dart';
import 'package:flutter/material.dart';

class DsAIProgressContent {
  const DsAIProgressContent({
    required this.stage,
    required this.stageLabel,
    required this.message,
  });

  final String stage;
  final String stageLabel;
  final String message;
}

class DsAIProgressIndicator extends StatelessWidget {
  const DsAIProgressIndicator({
    super.key,
    required this.stage,
    this.severity = 'info',
    this.retryable = false,
    this.overrideMessage,
    this.onRetry,
    this.wayfindingMessage,
    this.userName,
  });

  final String stage;
  final String severity;
  final bool retryable;
  final String? overrideMessage;
  final VoidCallback? onRetry;
  final String? wayfindingMessage;
  final String? userName;

  List<DsAIProgressContent> _stagesForProfile(DsToneProfile profile) {
    switch (profile) {
      case DsToneProfile.patient:
        return const <DsAIProgressContent>[
          DsAIProgressContent(
            stage: 'organizing_data',
            stageLabel: 'Organizando seu contexto',
            message:
                'Estamos reunindo suas respostas e o contexto necessário para começar a análise.',
          ),
          DsAIProgressContent(
            stage: 'analyzing_signals',
            stageLabel: 'Analisando sinais',
            message:
                'Estamos analisando os sinais principais do seu caso para construir uma leitura inicial cuidadosa.',
          ),
          DsAIProgressContent(
            stage: 'writing_draft',
            stageLabel: 'Escrevendo rascunho',
            message:
                'Estamos escrevendo um rascunho claro para apoiar sua conversa clínica.',
          ),
          DsAIProgressContent(
            stage: 'reviewing_content',
            stageLabel: 'Revisando conteúdo',
            message:
                'Estamos revisando o conteúdo para garantir clareza e segurança antes da entrega.',
          ),
        ];
      case DsToneProfile.admin:
        return const <DsAIProgressContent>[
          DsAIProgressContent(
            stage: 'organizing_data',
            stageLabel: 'Preparando dados',
            message: 'Consolidando respostas e contexto do caso.',
          ),
          DsAIProgressContent(
            stage: 'analyzing_signals',
            stageLabel: 'Analisando sinais',
            message: 'Executando análise clínica dos sinais principais.',
          ),
          DsAIProgressContent(
            stage: 'writing_draft',
            stageLabel: 'Gerando rascunho',
            message: 'Montando o rascunho inicial do documento.',
          ),
          DsAIProgressContent(
            stage: 'reviewing_content',
            stageLabel: 'Validando conteúdo',
            message: 'Aplicando revisão final de consistência.',
          ),
        ];
      case DsToneProfile.professional:
        return const <DsAIProgressContent>[
          DsAIProgressContent(
            stage: 'organizing_data',
            stageLabel: 'Organizando dados do caso',
            message:
                'Estamos reunindo respostas e contexto clínico para iniciar a síntese.',
          ),
          DsAIProgressContent(
            stage: 'analyzing_signals',
            stageLabel: 'Analisando sinais clínicos',
            message:
                'Estamos analisando os sinais principais para uma leitura clínica consistente.',
          ),
          DsAIProgressContent(
            stage: 'writing_draft',
            stageLabel: 'Escrevendo rascunho clínico',
            message:
                'Estamos escrevendo a primeira versão do documento com linguagem técnica adequada.',
          ),
          DsAIProgressContent(
            stage: 'reviewing_content',
            stageLabel: 'Revisando para entrega',
            message:
                'Estamos revisando o conteúdo para garantir clareza e confiabilidade antes da entrega.',
          ),
        ];
    }
  }

  DsAIProgressContent _currentFrom(List<DsAIProgressContent> stages) {
    return stages.firstWhere(
      (item) => item.stage == stage,
      orElse: () => stages.first,
    );
  }

  int _currentIndexFrom(List<DsAIProgressContent> stages) {
    final idx = stages.indexWhere((item) => item.stage == stage);
    return idx < 0 ? 0 : idx;
  }

  DsStatusType get _feedbackSeverity {
    switch (severity) {
      case 'warning':
        return DsStatusType.warning;
      case 'critical':
        return DsStatusType.error;
      case 'success':
        return DsStatusType.success;
      default:
        return DsStatusType.info;
    }
  }

  String _feedbackTitle(DsToneProfile profile, DsAIProgressContent current) {
    if (severity == 'critical') {
      return 'Não foi possível concluir a geração automática agora';
    }
    if (severity == 'warning') {
      return 'Houve um atraso no processamento';
    }
    if (severity == 'success') {
      switch (profile) {
        case DsToneProfile.patient:
          return 'Resultado pronto';
        case DsToneProfile.professional:
          return 'Processamento concluído';
        case DsToneProfile.admin:
          return 'Concluído';
      }
    }
    return current.stageLabel;
  }

  String _feedbackMessage(DsAIProgressContent current, DsToneTokens tone) {
    final custom = overrideMessage?.trim();
    if (custom != null && custom.isNotEmpty) {
      return custom;
    }

    if (severity == 'success') {
      return tone.completionAcknowledgement;
    }

    final baseMessage = current.message;
    final resolvedName = userName?.trim();
    if (resolvedName == null || resolvedName.isEmpty) {
      return baseMessage;
    }
    final salutation = tone.salutationFor(resolvedName);
    return '$salutation $baseMessage';
  }

  String _wayfindingMessage(DsToneTokens tone) {
    final custom = wayfindingMessage?.trim();
    if (custom != null && custom.isNotEmpty) {
      return custom;
    }
    if (severity == 'critical') {
      return 'Você pode seguir com a revisão manual enquanto tentamos novamente.';
    }
    return tone.waitingSupportMessage;
  }

  @override
  Widget build(BuildContext context) {
    final profile = DsEmotionalToneProvider.resolveProfile(context);
    final tone = DsEmotionalToneProvider.resolveTokens(context);
    final stages = _stagesForProfile(profile);
    final current = _currentFrom(stages);
    final currentIndex = _currentIndexFrom(stages);
    final theme = Theme.of(context);

    return DsSection(
      eyebrow: 'Processamento de IA',
      title: profile == DsToneProfile.patient
          ? 'Preparando seu resultado'
          : 'Preparando resultado clínico',
      subtitle: _wayfindingMessage(tone),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < stages.length; index++)
            _VerticalAIStageTile(
              label: stages[index].stageLabel,
              isDone: index < currentIndex,
              isActive: index == currentIndex,
              isLast: index == stages.length - 1,
            ),
          const SizedBox(height: 12),
          DsInlineMessage(
            feedback: DsFeedbackMessage(
              severity: _feedbackSeverity,
              title: _feedbackTitle(profile, current),
              message: _feedbackMessage(current, tone),
              primaryAction: retryable && onRetry != null
                  ? DsFeedbackAction(
                      label: 'Tentar Novamente',
                      onPressed: onRetry!,
                      icon: Icons.refresh,
                    )
                  : null,
            ),
            margin: EdgeInsets.zero,
          ),
          if (severity == 'critical')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Você pode continuar sem o resultado automático e revisar as respostas originais.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VerticalAIStageTile extends StatelessWidget {
  const _VerticalAIStageTile({
    required this.label,
    required this.isDone,
    required this.isActive,
    required this.isLast,
  });

  final String label;
  final bool isDone;
  final bool isActive;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final activeColor = scheme.primary;
    final mutedColor = scheme.outlineVariant;
    final nodeColor = isDone || isActive ? activeColor : mutedColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone || isActive
                      ? activeColor.withValues(alpha: 0.18)
                      : Colors.transparent,
                  border: Border.all(
                    color: nodeColor,
                    width: isActive ? 2.5 : 1.5,
                  ),
                ),
                child: Icon(
                  isDone
                      ? Icons.check
                      : (isActive ? Icons.adjust : Icons.circle_outlined),
                  size: 14,
                  color: nodeColor,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 24,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  color: isDone ? activeColor : mutedColor,
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive
                        ? activeColor
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
