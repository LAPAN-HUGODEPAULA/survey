import 'package:flutter/material.dart';

class DsSectionalNavItem {
  const DsSectionalNavItem({
    required this.label,
    required this.targetKey,
  });

  final String label;
  final GlobalKey targetKey;
}

class DsSectionalNav extends StatelessWidget {
  const DsSectionalNav({
    super.key,
    required this.items,
    this.activeItem,
    this.onItemTap,
  });

  final List<DsSectionalNavItem> items;
  final DsSectionalNavItem? activeItem;
  final ValueChanged<DsSectionalNavItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            'SEÇÕES',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ),
        ...items.map((item) {
          final isActive = item == activeItem;
          return _DsSectionalNavItemWidget(
            item: item,
            isActive: isActive,
            onTap: () => onItemTap?.call(item),
          );
        }),
      ],
    );
  }
}

class _DsSectionalNavItemWidget extends StatelessWidget {
  const _DsSectionalNavItemWidget({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final DsSectionalNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isActive ? colorScheme.primary : Colors.transparent,
              width: 3,
            ),
          ),
          color: isActive ? colorScheme.primaryContainer.withOpacity(0.1) : null,
        ),
        child: Text(
          item.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? colorScheme.primary : colorScheme.onSurface,
              ),
        ),
      ),
    );
  }
}
