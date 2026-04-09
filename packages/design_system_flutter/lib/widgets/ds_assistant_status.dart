import 'package:design_system_flutter/widgets/ds_buttons.dart';
import 'package:design_system_flutter/widgets/ds_chip.dart';
import 'package:design_system_flutter/widgets/ds_feedback.dart';
import 'package:design_system_flutter/widgets/ds_surface.dart';
import 'package:design_system_flutter/widgets/ds_wayfinding.dart';
import 'package:flutter/material.dart';

class DsAssistantStatus extends StatefulWidget {
  const DsAssistantStatus({
    super.key,
    required this.currentPhaseLabel,
    required this.currentMessage,
    this.steps = const <DsStepData>[],
    this.severity = DsStatusType.info,
    this.wayfindingMessage,
    this.reassuranceMessage,
    this.retryAction,
    this.cancelAction,
    this.processing = true,
    this.collapsible = true,
    this.initiallyExpanded = false,
    this.liveRegion = true,
  });

  final String currentPhaseLabel;
  final String currentMessage;
  final List<DsStepData> steps;
  final DsStatusType severity;
  final String? wayfindingMessage;
  final String? reassuranceMessage;
  final DsFeedbackAction? retryAction;
  final DsFeedbackAction? cancelAction;
  final bool processing;
  final bool collapsible;
  final bool initiallyExpanded;
  final bool liveRegion;

  @override
  State<DsAssistantStatus> createState() => _DsAssistantStatusState();
}

class _DsAssistantStatusState extends State<DsAssistantStatus> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded =
        !widget.collapsible || widget.initiallyExpanded || !_isProcessingState;
  }

  @override
  void didUpdateWidget(covariant DsAssistantStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.collapsible) {
      _expanded = true;
      return;
    }
    if (oldWidget.severity != widget.severity && !_isProcessingState) {
      _expanded = true;
    }
  }

  bool get _isProcessingState =>
      widget.processing &&
      widget.severity != DsStatusType.error &&
      widget.severity != DsStatusType.warning;

  String get _resolvedWayfindingMessage {
    final value = widget.wayfindingMessage?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
    return 'Acompanhe o que o assistente está fazendo sem perder o contexto da conversa.';
  }

  String get _resolvedReassuranceMessage {
    final value = widget.reassuranceMessage?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
    if (_isProcessingState) {
      return 'Você pode continuar registrando informações enquanto processamos esta etapa.';
    }
    if (widget.severity == DsStatusType.error ||
        widget.severity == DsStatusType.warning) {
      return 'Você pode tentar novamente ou continuar manualmente.';
    }
    return 'Assistente pronto para acompanhar a próxima etapa.';
  }

  String get _feedbackTitle {
    if (widget.severity == DsStatusType.error) {
      return 'Não foi possível concluir esta etapa da análise';
    }
    if (widget.severity == DsStatusType.warning) {
      return 'Assistente requer sua confirmação';
    }
    if (_isProcessingState) {
      return 'Assistente em processamento';
    }
    return 'Assistente pronto';
  }

  IconData get _feedbackIcon {
    switch (widget.severity) {
      case DsStatusType.success:
        return Icons.check_circle_outline;
      case DsStatusType.warning:
        return Icons.warning_amber_rounded;
      case DsStatusType.error:
        return Icons.error_outline;
      case DsStatusType.info:
        return Icons.auto_awesome;
      case DsStatusType.neutral:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasActions =
        widget.retryAction != null || widget.cancelAction != null;

    return Semantics(
      container: true,
      liveRegion: widget.liveRegion,
      label: 'Status do assistente. $_feedbackTitle. ${widget.currentMessage}',
      child: DsSection(
        eyebrow: 'Status do Assistente',
        title: widget.currentPhaseLabel,
        subtitle: _resolvedWayfindingMessage,
        tone: DsPanelTone.low,
        padding: const EdgeInsets.all(16),
        headerSpacing: 12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DsInlineMessage(
                    feedback: DsFeedbackMessage(
                      severity: widget.severity,
                      title: _feedbackTitle,
                      message: widget.currentMessage,
                      icon: _feedbackIcon,
                      liveRegion: widget.liveRegion,
                    ),
                    margin: EdgeInsets.zero,
                  ),
                ),
                if (widget.collapsible)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Semantics(
                      button: true,
                      label: _expanded
                          ? 'Recolher detalhes do assistente'
                          : 'Expandir detalhes do assistente',
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _expanded = !_expanded;
                          });
                        },
                        tooltip: _expanded
                            ? 'Recolher detalhes'
                            : 'Expandir detalhes',
                        icon: Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (_expanded && widget.steps.isNotEmpty) ...[
              const SizedBox(height: 12),
              _AssistantStepList(steps: widget.steps),
            ],
            if (_expanded) ...[
              const SizedBox(height: 12),
              Text(
                _resolvedReassuranceMessage,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            if (_expanded && hasActions) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (widget.retryAction != null)
                    DsOutlinedButton(
                      label: widget.retryAction!.label,
                      icon: widget.retryAction!.icon,
                      onPressed: widget.retryAction!.onPressed,
                    ),
                  if (widget.cancelAction != null)
                    DsTextButton(
                      label: widget.cancelAction!.label,
                      icon: widget.cancelAction!.icon,
                      onPressed: widget.cancelAction!.onPressed,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AssistantStepList extends StatelessWidget {
  const _AssistantStepList({required this.steps});

  final List<DsStepData> steps;

  Color _colorForState(BuildContext context, DsStepState state) {
    switch (state) {
      case DsStepState.done:
        return Theme.of(context).colorScheme.primary;
      case DsStepState.active:
        return Theme.of(context).colorScheme.tertiary;
      case DsStepState.todo:
        return Theme.of(context).colorScheme.outlineVariant;
    }
  }

  IconData _iconForState(DsStepState state) {
    switch (state) {
      case DsStepState.done:
        return Icons.check_rounded;
      case DsStepState.active:
        return Icons.adjust_rounded;
      case DsStepState.todo:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < steps.length; index++)
          _AssistantStepTile(
            label: steps[index].label,
            color: _colorForState(context, steps[index].state),
            icon: _iconForState(steps[index].state),
            isCurrent: steps[index].state == DsStepState.active,
            isLast: index == steps.length - 1,
          ),
      ],
    );
  }
}

class _AssistantStepTile extends StatelessWidget {
  const _AssistantStepTile({
    required this.label,
    required this.color,
    required this.icon,
    required this.isCurrent,
    required this.isLast,
  });

  final String label;
  final Color color;
  final IconData icon;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final mutedColor = Theme.of(context).colorScheme.outlineVariant;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 26,
          child: Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent
                      ? color.withValues(alpha: 0.18)
                      : Colors.transparent,
                  border: Border.all(
                    color: color,
                    width: isCurrent ? 2.2 : 1.4,
                  ),
                ),
                child: Icon(icon, size: 13, color: color),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 18,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  color: mutedColor,
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isCurrent
                        ? color
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
