import 'package:design_system_flutter/widgets/ds_chip.dart';
import 'package:design_system_flutter/widgets/ds_surface.dart';
import 'package:flutter/material.dart';

class DsFeedbackAction {
  const DsFeedbackAction({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
}

class DsValidationSummaryItem {
  const DsValidationSummaryItem({
    required this.message,
    this.label,
    this.onTap,
  });

  final String? label;
  final String message;
  final VoidCallback? onTap;

  String get displayText {
    final normalizedLabel = label?.trim();
    if (normalizedLabel == null || normalizedLabel.isEmpty) {
      return message;
    }
    return '$normalizedLabel: $message';
  }
}

class DsFeedbackMessage {
  const DsFeedbackMessage({
    required this.severity,
    required this.message,
    this.title,
    this.icon,
    this.primaryAction,
    this.secondaryAction,
    this.dismissible = false,
    this.onDismiss,
    this.liveRegion = true,
    this.semanticsLabel,
  });

  final DsStatusType severity;
  final String? title;
  final String message;
  final IconData? icon;
  final DsFeedbackAction? primaryAction;
  final DsFeedbackAction? secondaryAction;
  final bool dismissible;
  final VoidCallback? onDismiss;
  final bool liveRegion;
  final String? semanticsLabel;
}

IconData dsFeedbackIcon(DsStatusType severity) {
  switch (severity) {
    case DsStatusType.success:
      return Icons.check_circle_outline;
    case DsStatusType.warning:
      return Icons.warning_amber_rounded;
    case DsStatusType.error:
      return Icons.error_outline;
    case DsStatusType.info:
      return Icons.info_outline;
    case DsStatusType.neutral:
      return Icons.notifications_none_outlined;
  }
}

String dsFeedbackDefaultTitle(DsStatusType severity) {
  switch (severity) {
    case DsStatusType.success:
      return 'Sucesso';
    case DsStatusType.warning:
      return 'Atenção';
    case DsStatusType.error:
      return 'Erro';
    case DsStatusType.info:
      return 'Informação';
    case DsStatusType.neutral:
      return 'Atualização';
  }
}

String dsFeedbackSemanticLabel(DsStatusType severity) {
  switch (severity) {
    case DsStatusType.success:
      return 'Mensagem de confirmação';
    case DsStatusType.warning:
      return 'Mensagem de alerta';
    case DsStatusType.error:
      return 'Mensagem de erro';
    case DsStatusType.info:
      return 'Mensagem de informação';
    case DsStatusType.neutral:
      return 'Mensagem de status';
  }
}

Color dsFeedbackBackgroundColor(BuildContext context, DsStatusType severity) {
  final scheme = Theme.of(context).colorScheme;
  switch (severity) {
    case DsStatusType.success:
      return scheme.primaryContainer;
    case DsStatusType.warning:
      return scheme.tertiaryContainer;
    case DsStatusType.error:
      return scheme.errorContainer;
    case DsStatusType.info:
      return scheme.secondaryContainer;
    case DsStatusType.neutral:
      return scheme.surfaceContainerHighest;
  }
}

Color dsFeedbackForegroundColor(BuildContext context, DsStatusType severity) {
  final scheme = Theme.of(context).colorScheme;
  switch (severity) {
    case DsStatusType.success:
      return scheme.onPrimaryContainer;
    case DsStatusType.warning:
      return scheme.onTertiaryContainer;
    case DsStatusType.error:
      return scheme.onErrorContainer;
    case DsStatusType.info:
      return scheme.onSecondaryContainer;
    case DsStatusType.neutral:
      return scheme.onSurfaceVariant;
  }
}

class DsFeedbackBanner extends StatelessWidget {
  const DsFeedbackBanner({
    super.key,
    required this.feedback,
    this.margin = const EdgeInsets.only(bottom: 16),
    this.footer,
  });

  final DsFeedbackMessage feedback;
  final EdgeInsetsGeometry? margin;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return _DsFeedbackCard(
      feedback: feedback,
      margin: margin,
      tone: DsPanelTone.high,
      padding: const EdgeInsets.all(16),
      footer: footer,
    );
  }
}

class DsInlineFeedback extends StatelessWidget {
  const DsInlineFeedback({
    super.key,
    required this.feedback,
    this.margin,
    this.footer,
  });

  final DsFeedbackMessage feedback;
  final EdgeInsetsGeometry? margin;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return _DsFeedbackCard(
      feedback: feedback,
      margin: margin,
      tone: DsPanelTone.low,
      padding: const EdgeInsets.all(14),
      footer: footer,
    );
  }
}

class DsValidationSummary extends StatelessWidget {
  const DsValidationSummary({
    super.key,
    this.errors = const <String>[],
    this.items = const <DsValidationSummaryItem>[],
    this.title = 'Revise os campos obrigatórios',
    this.description,
    this.primaryAction,
    this.secondaryAction,
  });

  final List<String> errors;
  final List<DsValidationSummaryItem> items;
  final String title;
  final String? description;
  final DsFeedbackAction? primaryAction;
  final DsFeedbackAction? secondaryAction;

  @override
  Widget build(BuildContext context) {
    final resolvedItems = items.isNotEmpty
        ? items
        : errors
            .map((error) => DsValidationSummaryItem(message: error))
            .toList(growable: false);

    if (resolvedItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return DsFeedbackBanner(
      feedback: DsFeedbackMessage(
        severity: DsStatusType.error,
        title: title,
        message: description ?? 'Corrija os itens abaixo antes de continuar.',
        primaryAction: primaryAction,
        secondaryAction: secondaryAction,
      ),
      margin: EdgeInsets.zero,
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in resolvedItems)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: item.onTap == null
                        ? Text(item.displayText)
                        : InkWell(
                            onTap: item.onTap,
                            child: Text(item.displayText),
                          ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class DsSnackBarFeedbackContent extends StatelessWidget {
  const DsSnackBarFeedbackContent({
    super.key,
    required this.feedback,
  });

  final DsFeedbackMessage feedback;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: _DsFeedbackCard(
        feedback: feedback,
        tone: DsPanelTone.high,
        padding: const EdgeInsets.all(14),
        margin: EdgeInsets.zero,
      ),
    );
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
    showDsFeedbackSnackBar(
  BuildContext context, {
  required DsFeedbackMessage feedback,
  Duration duration = const Duration(seconds: 3),
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  return messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: duration,
      content: DsSnackBarFeedbackContent(feedback: feedback),
    ),
  );
}

class _DsFeedbackCard extends StatelessWidget {
  const _DsFeedbackCard({
    required this.feedback,
    required this.tone,
    required this.padding,
    this.margin,
    this.footer,
  });

  final DsFeedbackMessage feedback;
  final DsPanelTone tone;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final background = dsFeedbackBackgroundColor(context, feedback.severity);
    final foreground = dsFeedbackForegroundColor(context, feedback.severity);
    final title = feedback.title?.trim().isNotEmpty == true
        ? feedback.title!.trim()
        : dsFeedbackDefaultTitle(feedback.severity);
    final icon = feedback.icon ?? dsFeedbackIcon(feedback.severity);

    return Semantics(
      container: true,
      liveRegion: feedback.liveRegion,
      label: feedback.semanticsLabel ??
          '${dsFeedbackSemanticLabel(feedback.severity)}: $title. ${feedback.message}',
      child: DsPanel(
        tone: tone,
        margin: margin,
        padding: padding,
        backgroundColor: background,
        child: DefaultTextStyle.merge(
          style: TextStyle(color: foreground),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: foreground),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: foreground,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feedback.message,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: foreground),
                        ),
                      ],
                    ),
                  ),
                  if (feedback.dismissible && feedback.onDismiss != null)
                    IconButton(
                      tooltip: 'Fechar mensagem',
                      onPressed: feedback.onDismiss,
                      icon: Icon(Icons.close, color: foreground),
                    ),
                ],
              ),
              if (footer != null) ...[
                const SizedBox(height: 8),
                footer!,
              ],
              if (feedback.primaryAction != null ||
                  feedback.secondaryAction != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (feedback.primaryAction != null)
                      _DsFeedbackActionButton(
                        action: feedback.primaryAction!,
                        foreground: foreground,
                      ),
                    if (feedback.secondaryAction != null)
                      _DsFeedbackActionButton(
                        action: feedback.secondaryAction!,
                        foreground: foreground,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DsFeedbackActionButton extends StatelessWidget {
  const _DsFeedbackActionButton({
    required this.action,
    required this.foreground,
  });

  final DsFeedbackAction action;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final style = TextButton.styleFrom(foregroundColor: foreground);
    if (action.icon != null) {
      return TextButton.icon(
        onPressed: action.onPressed,
        style: style,
        icon: Icon(action.icon, size: 18),
        label: Text(action.label),
      );
    }
    return TextButton(
      onPressed: action.onPressed,
      style: style,
      child: Text(action.label),
    );
  }
}
