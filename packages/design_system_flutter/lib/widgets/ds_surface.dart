import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum DsPanelTone { floor, low, base, high, focus, glass }

Color _resolvePanelColor(
  BuildContext context,
  DsPanelTone tone,
) {
  final colorScheme = Theme.of(context).colorScheme;
  final surfaces = Theme.of(context).extension<LapanSurfaceTokens>();

  switch (tone) {
    case DsPanelTone.floor:
      return surfaces?.floor ?? colorScheme.surfaceContainerLowest;
    case DsPanelTone.low:
      return surfaces?.low ?? colorScheme.surfaceContainerLow;
    case DsPanelTone.base:
      return surfaces?.base ?? colorScheme.surfaceContainer;
    case DsPanelTone.high:
      return surfaces?.high ?? colorScheme.surfaceContainerHigh;
    case DsPanelTone.focus:
      return surfaces?.focusFrame ?? colorScheme.surfaceContainerHighest;
    case DsPanelTone.glass:
      return surfaces?.glass ?? colorScheme.surface.withValues(alpha: 0.8);
  }
}

class DsPanel extends StatelessWidget {
  const DsPanel({
    super.key,
    required this.child,
    this.tone = DsPanelTone.base,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(24),
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.outlineOpacity = 0.15,
    this.showOutline = true,
    this.clipBehavior = Clip.antiAlias,
    this.shadow,
    this.width,
    this.height,
    this.constraints,
  });

  final Widget child;
  final DsPanelTone tone;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry borderRadius;
  final double outlineOpacity;
  final bool showOutline;
  final Clip clipBehavior;
  final List<BoxShadow>? shadow;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorTokens = theme.extension<LapanColorTokens>();
    final color = backgroundColor ?? _resolvePanelColor(context, tone);
    final defaultShadow = tone == DsPanelTone.glass
        ? <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.24),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              blurRadius: 56,
              spreadRadius: -12,
            ),
          ]
        : const <BoxShadow>[];

    return Container(
      width: width,
      height: height,
      margin: margin,
      constraints: constraints,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: showOutline
            ? Border.all(
                color: (colorTokens?.ghostOutline ??
                        theme.colorScheme.outlineVariant)
                    .withValues(alpha: outlineOpacity),
              )
            : null,
        boxShadow: shadow ?? defaultShadow,
      ),
      clipBehavior: clipBehavior,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class DsSection extends StatelessWidget {
  const DsSection({
    super.key,
    required this.child,
    this.eyebrow,
    this.title,
    this.subtitle,
    this.action,
    this.tone = DsPanelTone.low,
    this.padding = const EdgeInsets.all(24),
    this.headerSpacing = 16,
  });

  final Widget child;
  final String? eyebrow;
  final String? title;
  final String? subtitle;
  final Widget? action;
  final DsPanelTone tone;
  final EdgeInsetsGeometry padding;
  final double headerSpacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasHeader =
        eyebrow != null || title != null || subtitle != null || action != null;

    return DsPanel(
      tone: tone,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasHeader)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (eyebrow != null)
                        Text(
                          eyebrow!,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      if (eyebrow != null && title != null)
                        const SizedBox(height: 8),
                      if (title != null)
                        Text(
                          title!,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(width: 16),
                  Flexible(child: action!),
                ],
              ],
            ),
          if (hasHeader) SizedBox(height: headerSpacing),
          child,
        ],
      ),
    );
  }
}

class DsFocusFrame extends StatelessWidget {
  const DsFocusFrame({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    return DsPanel(
      tone: DsPanelTone.focus,
      padding: padding,
      borderRadius: borderRadius,
      showOutline: false,
      child: child,
    );
  }
}

class DsFieldChrome extends StatelessWidget {
  const DsFieldChrome({
    super.key,
    required this.child,
    this.label,
    this.supportingText,
    this.errorText,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final String? label;
  final String? supportingText;
  final String? errorText;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final supporting = errorText ?? supportingText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DsFocusFrame(
          padding: padding,
          child: child,
        ),
        if (supporting != null) ...[
          const SizedBox(height: 8),
          Text(
            supporting,
            style: theme.textTheme.bodySmall?.copyWith(
              color: errorText != null
                  ? colorScheme.error
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
