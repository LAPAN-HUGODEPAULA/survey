import 'package:flutter/material.dart';
import 'package:design_system_flutter/widgets/ds_buttons.dart';
import 'package:design_system_flutter/widgets/ds_scaffold.dart';

class DsAdminCatalogShell<T> extends StatelessWidget {
  const DsAdminCatalogShell({
    super.key,
    required this.heading,
    required this.createLabel,
    required this.isLoading,
    required this.items,
    required this.itemBuilder,
    required this.onCreate,
    required this.onRefresh,
    required this.emptyMessage,
    this.error,
    this.onRetry,
  });

  final String heading;
  final String createLabel;
  final bool isLoading;
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final VoidCallback onCreate;
  final VoidCallback onRefresh;
  final String emptyMessage;
  final String? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  heading,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 16),
              DsFilledButton(
                label: createLabel,
                onPressed: onCreate,
              ),
              IconButton(
                tooltip: 'Atualizar',
                icon: const Icon(Icons.refresh),
                onPressed: isLoading ? null : onRefresh,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const DsLoading()
                : error != null
                    ? DsError(message: error!, onRetry: onRetry ?? onRefresh)
                    : items.isEmpty
                        ? DsEmpty(message: emptyMessage)
                        : ListView.separated(
                            itemCount: items.length,
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const SizedBox(height: 8),
                            itemBuilder: (BuildContext context, int index) =>
                                itemBuilder(context, items[index]),
                          ),
          ),
        ],
      ),
    );
  }
}
