import 'package:flutter/material.dart';

enum DsChatRole { clinician, patient, system }

class DsChatBubble extends StatelessWidget {
  const DsChatBubble({
    super.key,
    required this.message,
    required this.role,
    this.label,
    this.isPending = false,
    this.hasError = false,
    this.deleted = false,
  });

  final String message;
  final DsChatRole role;
  final String? label;
  final bool isPending;
  final bool hasError;
  final bool deleted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isClinician = role == DsChatRole.clinician;
    final background = isClinician
        ? scheme.primaryContainer
        : role == DsChatRole.system
            ? scheme.surfaceContainerHighest
            : scheme.secondaryContainer;
    final foreground = isClinician ? scheme.onPrimaryContainer : scheme.onSurface;
    final opacity = deleted ? 0.5 : 1.0;
    final alignment = isClinician ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Opacity(
      opacity: opacity,
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: alignment,
              children: [
                if (label != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      label!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                    ),
                  ),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: foreground),
                ),
                if (isPending)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Sending...',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground),
                    ),
                  ),
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Failed to send',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: scheme.error),
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
