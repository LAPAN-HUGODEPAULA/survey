import 'package:design_system_flutter/widgets/ds_buttons.dart';
import 'package:design_system_flutter/widgets/ds_surface.dart';
import 'package:flutter/material.dart';

class DsEmptyState extends StatelessWidget {
  const DsEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.visual,
    this.actionLabel,
    this.onAction,
  });

  final Widget? visual;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: DsSection(
          tone: DsPanelTone.low,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              visual ??
                  Icon(
                    Icons.inbox_outlined,
                    size: 56,
                    color: colorScheme.onSurfaceVariant,
                  ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20),
                DsFilledButton(
                  label: actionLabel!,
                  icon: Icons.arrow_forward_rounded,
                  onPressed: onAction!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
