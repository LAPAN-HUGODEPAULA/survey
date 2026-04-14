import 'package:design_system_flutter/widgets/ds_surface.dart';
import 'package:flutter/material.dart';

enum DsStepState { todo, active, done }

class DsStepData {
  const DsStepData({
    required this.label,
    required this.state,
  });

  final String label;
  final DsStepState state;
}

class DsStepper extends StatelessWidget {
  const DsStepper({
    super.key,
    required this.steps,
    this.padding = const EdgeInsets.only(bottom: 24),
    this.compactBreakpoint = 720,
  });

  final List<DsStepData> steps;
  final EdgeInsetsGeometry padding;
  final double compactBreakpoint;

  int get _activeIndex {
    final activeIndex = steps.indexWhere(
      (DsStepData step) => step.state == DsStepState.active,
    );
    if (activeIndex >= 0) {
      return activeIndex;
    }
    final lastDoneIndex = steps.lastIndexWhere(
      (DsStepData step) => step.state == DsStepState.done,
    );
    if (lastDoneIndex >= 0) {
      return lastDoneIndex;
    }
    return 0;
  }

  Color _stepColor(BuildContext context, DsStepState state) {
    final scheme = Theme.of(context).colorScheme;
    switch (state) {
      case DsStepState.done:
        return scheme.primary;
      case DsStepState.active:
        return scheme.tertiary;
      case DsStepState.todo:
        return scheme.outlineVariant;
    }
  }

  IconData _stepIcon(DsStepState state) {
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
    if (steps.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentIndex = _activeIndex.clamp(0, steps.length - 1);
    final progressLabel = 'Progresso (${currentIndex + 1} de ${steps.length})';

    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth < compactBreakpoint) {
            return DsSection(
              eyebrow: progressLabel,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              headerSpacing: 10,
              child: LinearProgressIndicator(
                value: (currentIndex + 1) / steps.length,
                minHeight: 4,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
            );
          }

          return DsSection(
            eyebrow: progressLabel,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            headerSpacing: 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < steps.length; index++) ...[
                  Expanded(
                    child: _DsStepNode(
                      step: steps[index],
                      color: _stepColor(context, steps[index].state),
                      icon: _stepIcon(steps[index].state),
                    ),
                  ),
                  if (index < steps.length - 1)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Divider(
                          thickness: 3,
                          color: index < currentIndex
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DsStepNode extends StatelessWidget {
  const _DsStepNode({
    required this.step,
    required this.color,
    required this.icon,
  });

  final DsStepData step;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isCurrent = step.state == DsStepState.active;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: step.state == DsStepState.todo
                ? Colors.transparent
                : color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color, width: isCurrent ? 2.5 : 1.5),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          step.label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isCurrent ? color : theme.colorScheme.onSurfaceVariant,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class DsBreadcrumbItem {
  const DsBreadcrumbItem({
    required this.label,
    this.onPressed,
    this.isCurrent = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isCurrent;
}

class DsBreadcrumbs extends StatelessWidget {
  const DsBreadcrumbs({
    super.key,
    required this.items,
  });

  final List<DsBreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          if (index > 0)
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          if (items[index].onPressed != null && !items[index].isCurrent)
            TextButton(
              onPressed: items[index].onPressed,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(items[index].label),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                items[index].label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: items[index].isCurrent
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                  fontWeight: items[index].isCurrent
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class DsStickySectionItem {
  const DsStickySectionItem({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

class DsStickySectionHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const DsStickySectionHeader({
    super.key,
    required this.title,
    required this.sections,
    required this.currentSectionId,
    required this.onSectionSelected,
    this.summary,
    this.height = 116,
  });

  final String title;
  final List<DsStickySectionItem> sections;
  final String currentSectionId;
  final ValueChanged<String> onSectionSelected;
  final String? summary;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return DsPanel(
      tone: DsPanelTone.low,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.explore_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (summary != null)
                Flexible(
                  child: Text(
                    summary!,
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final DsStickySectionItem section in sections)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(section.label),
                      selected: section.id == currentSectionId,
                      showCheckmark: false,
                      onSelected: (_) => onSectionSelected(section.id),
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
