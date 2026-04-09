import 'package:design_system_flutter/widgets/ds_chip.dart';
import 'package:design_system_flutter/widgets/ds_feedback.dart';
import 'package:flutter/material.dart';

enum DsAIInsightType { suggestion, alert, hypothesis, confirmed }

class DsAIInsightCard extends StatelessWidget {
  const DsAIInsightCard({
    super.key,
    required this.message,
    this.type = DsAIInsightType.suggestion,
    this.title,
    this.supportingText,
    this.severityOverride,
    this.iconOverride,
    this.margin,
    this.liveRegion = false,
  });

  final DsAIInsightType type;
  final String? title;
  final String message;
  final String? supportingText;
  final DsStatusType? severityOverride;
  final IconData? iconOverride;
  final EdgeInsetsGeometry? margin;
  final bool liveRegion;

  DsStatusType get _severity {
    if (severityOverride != null) {
      return severityOverride!;
    }
    switch (type) {
      case DsAIInsightType.suggestion:
        return DsStatusType.info;
      case DsAIInsightType.alert:
      case DsAIInsightType.hypothesis:
        return DsStatusType.warning;
      case DsAIInsightType.confirmed:
        return DsStatusType.success;
    }
  }

  String get _defaultTitle {
    switch (type) {
      case DsAIInsightType.suggestion:
        return 'Sugestão do Assistente';
      case DsAIInsightType.alert:
        return 'Alerta Clínico';
      case DsAIInsightType.hypothesis:
        return 'Hipótese Clínica';
      case DsAIInsightType.confirmed:
        return 'Evidência Confirmada';
    }
  }

  IconData get _icon {
    if (iconOverride != null) {
      return iconOverride!;
    }
    switch (type) {
      case DsAIInsightType.suggestion:
        return Icons.lightbulb_outline;
      case DsAIInsightType.alert:
        return Icons.warning_amber_rounded;
      case DsAIInsightType.hypothesis:
        return Icons.psychology_alt_outlined;
      case DsAIInsightType.confirmed:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalizedTitle = title?.trim();
    final normalizedSupportingText = supportingText?.trim();

    return DsInlineMessage(
      feedback: DsFeedbackMessage(
        severity: _severity,
        title: normalizedTitle != null && normalizedTitle.isNotEmpty
            ? normalizedTitle
            : _defaultTitle,
        message: message,
        icon: _icon,
        liveRegion: liveRegion,
      ),
      margin: margin,
      footer: normalizedSupportingText != null &&
              normalizedSupportingText.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                normalizedSupportingText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            )
          : null,
    );
  }
}
