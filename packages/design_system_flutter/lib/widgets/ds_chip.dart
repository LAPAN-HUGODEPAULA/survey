import 'package:flutter/material.dart';

enum DsStatusType { neutral, info, success, warning, error }

Color _chipBackground(BuildContext context, DsStatusType type) {
  final scheme = Theme.of(context).colorScheme;
  switch (type) {
    case DsStatusType.info:
      return scheme.secondaryContainer;
    case DsStatusType.success:
      return scheme.primaryContainer;
    case DsStatusType.warning:
      return scheme.tertiaryContainer;
    case DsStatusType.error:
      return scheme.errorContainer;
    case DsStatusType.neutral:
      return scheme.surfaceContainerHighest;
  }
}

Color _chipForeground(BuildContext context, DsStatusType type) {
  final scheme = Theme.of(context).colorScheme;
  switch (type) {
    case DsStatusType.info:
      return scheme.onSecondaryContainer;
    case DsStatusType.success:
      return scheme.onPrimaryContainer;
    case DsStatusType.warning:
      return scheme.onTertiaryContainer;
    case DsStatusType.error:
      return scheme.onErrorContainer;
    case DsStatusType.neutral:
      return scheme.onSurfaceVariant;
  }
}

class DsStatusChip extends StatelessWidget {
  const DsStatusChip({
    super.key,
    required this.label,
    this.type = DsStatusType.neutral,
    this.icon,
    this.semanticsLabel,
  });

  final String label;
  final DsStatusType type;
  final IconData? icon;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final background = _chipBackground(context, type);
    final foreground = _chipForeground(context, type);
    return Semantics(
      label: semanticsLabel ?? label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: foreground.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(icon, size: 16, color: foreground),
              ),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
