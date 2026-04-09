import 'package:flutter/material.dart';
import 'package:design_system_flutter/widgets/ds_buttons.dart';

class DsAdminFormShell extends StatelessWidget {
  const DsAdminFormShell({
    super.key,
    required this.child,
    required this.onCancel,
    required this.onSave,
    this.isSaving = false,
    this.saveLabel = 'Salvar',
    this.cancelLabel = 'Cancelar',
    this.feedback,
    this.stickyHeader,
    this.scrollController,
  });

  final Widget child;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isSaving;
  final String saveLabel;
  final String cancelLabel;
  final Widget? feedback;
  final PreferredSizeWidget? stickyHeader;
  final ScrollController? scrollController;

  Widget _buildToolbar() {
    return Row(
      children: [
        const Spacer(),
        SizedBox(
          width: 140,
          child: DsOutlinedButton(
            label: cancelLabel,
            onPressed: isSaving ? null : onCancel,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 140,
          child: DsFilledButton(
            label: isSaving ? 'Salvando...' : saveLabel,
            onPressed: isSaving ? null : onSave,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final topContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToolbar(),
        const SizedBox(height: 16),
        if (feedback != null) ...[
          feedback!,
          const SizedBox(height: 16),
        ],
      ],
    );

    if (stickyHeader == null) {
      return SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            topContent,
            child,
          ],
        ),
      );
    }

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(child: topContent),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _DsStickyHeaderDelegate(
            header: stickyHeader!,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverToBoxAdapter(child: child),
        ),
      ],
    );
  }
}

class _DsStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _DsStickyHeaderDelegate({
    required this.header,
    required this.backgroundColor,
  });

  final PreferredSizeWidget header;
  final Color backgroundColor;

  @override
  double get minExtent => header.preferredSize.height + 12;

  @override
  double get maxExtent => header.preferredSize.height + 12;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: header,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _DsStickyHeaderDelegate oldDelegate) {
    return oldDelegate.header != header ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
