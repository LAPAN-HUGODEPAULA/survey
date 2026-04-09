import 'package:design_system_flutter/widgets/ds_chip.dart';
import 'package:design_system_flutter/widgets/ds_feedback.dart';
import 'package:design_system_flutter/widgets/ds_surface.dart';
import 'package:flutter/material.dart';

class DsDialog extends StatelessWidget {
  const DsDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions = const [],
    this.severity = DsStatusType.neutral,
  });

  final String title;
  final Widget content;
  final List<Widget> actions;
  final DsStatusType severity;

  @override
  Widget build(BuildContext context) {
    final headerBackground = dsFeedbackBackgroundColor(context, severity);
    final headerForeground = dsFeedbackForegroundColor(context, severity);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: DsPanel(
        tone: DsPanelTone.glass,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              decoration: BoxDecoration(
                color: headerBackground,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    dsFeedbackIcon(severity),
                    color: headerForeground,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: headerForeground),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  content,
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 12,
                      runSpacing: 12,
                      children: actions,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
