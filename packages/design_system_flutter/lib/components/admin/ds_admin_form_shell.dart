import 'package:flutter/material.dart';
import 'package:design_system_flutter/widgets/ds_buttons.dart';

class DsAdminFormShell extends StatelessWidget {
  const DsAdminFormShell({
    super.key,
    required this.child,
    required this.onCancel,
    required this.onSave,
    this.isSaving = false,
    this.hasUnsavedChanges = false,
    this.saveLabel = 'Salvar',
    this.cancelLabel = 'Cancelar',
    this.feedback,
    this.stickyHeader,
    this.stickyFooter,
    this.sectionalNav,
    this.scrollController,
  });

  final Widget child;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isSaving;
  final bool hasUnsavedChanges;
  final String saveLabel;
  final String cancelLabel;
  final Widget? feedback;
  final PreferredSizeWidget? stickyHeader;
  final Widget? stickyFooter;
  final Widget? sectionalNav;
  final ScrollController? scrollController;

  Widget _buildToolbar(BuildContext context) {
    return Row(
      children: [
        if (hasUnsavedChanges && !isSaving) ...[
          Icon(
            Icons.info_outline,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Alterações não salvas',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
        if (isSaving) ...[
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            'Salvando...',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
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
    final theme = Theme.of(context);

    final formContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stickyFooter == null) ...[
          _buildToolbar(context),
          const SizedBox(height: 16),
        ],
        if (feedback != null) ...[
          feedback!,
          const SizedBox(height: 16),
        ],
        child,
      ],
    );

    Widget body;
    if (stickyHeader == null) {
      body = SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        child: formContent,
      );
    } else {
      body = CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, stickyFooter == null ? 0 : 16),
            sliver: SliverToBoxAdapter(
              child: stickyFooter == null ? _buildToolbar(context) : null,
            ),
          ),
          if (feedback != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(child: feedback),
            ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _DsStickyHeaderDelegate(
              header: stickyHeader!,
              backgroundColor: theme.scaffoldBackgroundColor,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverToBoxAdapter(child: child),
          ),
        ],
      );
    }

    final mainArea = sectionalNav == null
        ? body
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 240,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16),
                  child: sectionalNav,
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: body),
            ],
          );

    if (stickyFooter == null) {
      return mainArea;
    }

    return Column(
      children: [
        Expanded(child: mainArea),
        const Divider(height: 1),
        Container(
          padding: const EdgeInsets.all(16),
          color: theme.scaffoldBackgroundColor,
          child: SafeArea(
            top: false,
            child: _buildToolbar(context),
          ),
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
