import 'package:design_system_flutter/widgets/ds_buttons.dart';
import 'package:design_system_flutter/widgets/ds_indicator.dart';
import 'package:design_system_flutter/widgets/ds_surface.dart';
import 'package:flutter/material.dart';

enum DsHandoffStage { registered, analyzing, ready }

class DsHandoffCopy {
  static const String registeredLabel = 'Respostas registradas';
  static const String analyzingLabel = 'Análise preliminar em preparo';
  static const String readyLabel = 'Relatório disponível';

  static const String effortAcknowledgement =
      'Obrigado por sua colaboração. Suas respostas ajudam a construir um olhar mais cuidadoso para sua saúde.';

  static const String referenceIdContext =
      'Sua avaliação foi salva. Este código identifica o atendimento para futuras consultas:';

  static const String optionalEnrichmentGuidance =
      'Estas informações opcionais ajudam em pesquisas estatísticas, mas você pode pular esta etapa se preferir.';

  static String labelFor(DsHandoffStage stage) {
    switch (stage) {
      case DsHandoffStage.registered:
        return registeredLabel;
      case DsHandoffStage.analyzing:
        return analyzingLabel;
      case DsHandoffStage.ready:
        return readyLabel;
    }
  }
}

class DsClinicalContentCard extends StatelessWidget {
  const DsClinicalContentCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.footer,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DsPanel(
      tone: DsPanelTone.base,
      backgroundColor: scheme.surface,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(28),
      outlineOpacity: 0.28,
      shadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.18),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),
          child,
          if (footer != null) ...[
            const SizedBox(height: 16),
            footer!,
          ],
        ],
      ),
    );
  }
}

class DsHandoffForkAction {
  const DsHandoffForkAction({
    required this.title,
    required this.description,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
    this.icon,
  });

  final String title;
  final String description;
  final String primaryLabel;
  final VoidCallback onPrimaryPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;
  final IconData? icon;
}

class DsHandoffFork extends StatelessWidget {
  const DsHandoffFork({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actions,
    this.eyebrow,
  });

  final String title;
  final String subtitle;
  final List<DsHandoffForkAction> actions;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    return DsSection(
      eyebrow: eyebrow ?? 'Próximo passo',
      title: title,
      subtitle: subtitle,
      child: Column(
        children: actions
            .map(
              (action) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DsHandoffForkOption(action: action),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _DsHandoffForkOption extends StatelessWidget {
  const _DsHandoffForkOption({required this.action});

  final DsHandoffForkAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DsPanel(
      tone: DsPanelTone.high,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (action.icon != null) ...[
                Icon(action.icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      action.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DsFilledButton(
                label: action.primaryLabel,
                onPressed: action.onPrimaryPressed,
              ),
              if (action.secondaryLabel != null &&
                  action.onSecondaryPressed != null)
                DsOutlinedButton(
                  label: action.secondaryLabel!,
                  onPressed: action.onSecondaryPressed,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class DsHandoffStatusRow extends StatelessWidget {
  const DsHandoffStatusRow({
    super.key,
    required this.stage,
    this.liveRegion = false,
  });

  final DsHandoffStage stage;
  final bool liveRegion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (stage) {
      DsHandoffStage.registered => scheme.tertiary,
      DsHandoffStage.analyzing => scheme.primary,
      DsHandoffStage.ready => scheme.secondary,
    };

    return DsStatusIndicator(
      label: DsHandoffCopy.labelFor(stage),
      color: color,
      liveRegion: liveRegion,
    );
  }
}
