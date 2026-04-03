import 'package:flutter/material.dart';
import 'package:design_system_flutter/widgets/ds_buttons.dart';
import 'package:design_system_flutter/widgets/ds_scaffold.dart';
import 'package:design_system_flutter/widgets/ds_surface.dart';

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DsPageHeader(
            title: heading,
            eyebrow: 'Catalogo',
            subtitle:
                'Gerencie itens administrativos usando o shell compartilhado.',
            actions: [
              DsFilledButton(
                label: createLabel,
                onPressed: onCreate,
              ),
              DsOutlinedButton(
                label: 'Atualizar',
                icon: Icons.refresh,
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
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: SingleChildScrollView(
                              child: DsPanel(
                                tone: DsPanelTone.low,
                                child: Column(
                                  children: [
                                    for (var index = 0;
                                        index < items.length;
                                        index++) ...[
                                      if (index > 0) const SizedBox(height: 12),
                                      itemBuilder(
                                        context,
                                        items[index],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
