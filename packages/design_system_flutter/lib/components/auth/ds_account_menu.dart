import 'package:flutter/material.dart';

class DsAccountMenuItem<T> {
  const DsAccountMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  final T value;
  final String label;
  final IconData? icon;
  final bool enabled;
}

class DsAccountMenuButton<T> extends StatelessWidget {
  const DsAccountMenuButton({
    super.key,
    required this.items,
    required this.onSelected,
    this.tooltip = 'Conta',
    this.icon = const Icon(Icons.person_outline),
  });

  final List<DsAccountMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final String tooltip;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final availableItems = items.where((item) => item.enabled).toList();
    if (availableItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<T>(
      tooltip: tooltip,
      icon: icon,
      onSelected: onSelected,
      itemBuilder: (context) => availableItems
          .map(
            (item) => PopupMenuItem<T>(
              value: item.value,
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    Icon(item.icon, size: 18),
                    const SizedBox(width: 12),
                  ],
                  Flexible(child: Text(item.label)),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
