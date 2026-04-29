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
    this.feedback,
    this.onSearchChanged,
    this.searchPlaceholder = 'Filtrar itens...',
    this.searchController,
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
  final Widget? feedback;
  final ValueChanged<String>? onSearchChanged;
  final String searchPlaceholder;
  final TextEditingController? searchController;

  @override
  Widget build(BuildContext context) {
    Widget buildContentState(Widget child) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: child,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: DsPageHeader(
              title: heading,
              eyebrow: 'Catálogo',
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
          ),
          if (feedback != null) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(child: feedback!),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          if (onSearchChanged != null || searchController != null) ...[
            SliverToBoxAdapter(
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: searchPlaceholder,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
          if (isLoading)
            buildContentState(const DsLoading())
          else if (error != null)
            buildContentState(
              DsError(message: error!, onRetry: onRetry ?? onRefresh),
            )
          else if (items.isEmpty)
            buildContentState(
              DsEmpty(
                message: emptyMessage,
                actionLabel: createLabel,
                onAction: onCreate,
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DsPanel(
                  tone: DsPanelTone.low,
                  child: Column(
                    children: [
                      for (var index = 0; index < items.length; index++) ...[
                        if (index > 0) const SizedBox(height: 12),
                        itemBuilder(context, items[index]),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
