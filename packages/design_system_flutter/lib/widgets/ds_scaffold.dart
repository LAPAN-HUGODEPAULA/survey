import 'package:flutter/material.dart';
import 'package:design_system_flutter/components/legal/ds_legal_viewer.dart';
import 'package:design_system_flutter/components/legal/legal_content.dart';
import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:design_system_flutter/widgets/ds_surface.dart';

const dsSharedStatusBarText =
    'COPYRIGHT © 2026. Laboratório de Pesquisa Aplicada às Neurociências da Visão - Todos os direitos reservados.';

class DsStatusBar extends StatelessWidget {
  const DsStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = Theme.of(context).extension<LapanSpacingTokens>();

    return Material(
      color: colorScheme.surfaceContainerLow,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.15),
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing?.lg ?? 24,
              vertical: spacing?.md ?? 16,
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text(
                  dsSharedStatusBarText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.86,
                        ),
                      ),
                ),
                TextButton(
                  onPressed: () => showDsLegalDocumentDialog(
                    context,
                    documentType: DsLegalDocumentType.termsOfUse,
                  ),
                  child: const Text('Termo de Uso e Política de Privacidade'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DsPageHeader extends StatelessWidget {
  const DsPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.leading,
    this.trailing,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = Theme.of(context).extension<LapanSpacingTokens>();

    return DsPanel(
      tone: DsPanelTone.low,
      padding: EdgeInsets.all(spacing?.lg ?? 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: spacing?.md ?? 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null)
                  Text(
                    eyebrow!,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                  ),
                if (eyebrow != null) SizedBox(height: spacing?.sm ?? 8),
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                if (subtitle != null) ...[
                  SizedBox(height: spacing?.sm ?? 8),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if ((actions != null && actions!.isNotEmpty) || trailing != null) ...[
            SizedBox(width: spacing?.md ?? 16),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (trailing != null) trailing!,
                  if (trailing != null &&
                      actions != null &&
                      actions!.isNotEmpty)
                    SizedBox(height: spacing?.sm ?? 8),
                  if (actions != null && actions!.isNotEmpty)
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: spacing?.sm ?? 8,
                      runSpacing: spacing?.sm ?? 8,
                      children: actions!,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DsPageFrame extends StatelessWidget {
  const DsPageFrame({
    super.key,
    required this.child,
    this.maxWidth = 1120,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class DsScaffold extends StatelessWidget {
  const DsScaffold({
    super.key,
    required this.body,
    this.title,
    this.subtitle,
    this.actions,
    this.appBar,
    this.header,
    this.isLoading = false,
    this.error,
    this.loading,
    this.errorWidget,
    this.useSafeArea = false,
    this.backgroundColor,
    this.footer,
    this.bodyPadding = const EdgeInsets.all(24),
    this.maxBodyWidth = 1120,
    this.scrollable = false,
  });

  final String? title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;
  final PreferredSizeWidget? appBar;
  final Widget? header;
  final bool isLoading;
  final String? error;
  final Widget? loading;
  final Widget? errorWidget;
  final bool useSafeArea;
  final Color? backgroundColor;
  final Widget? footer;
  final EdgeInsetsGeometry bodyPadding;
  final double maxBodyWidth;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradients = Theme.of(context).extension<LapanGradientTokens>();

    Widget resolvedBody;
    if (isLoading) {
      resolvedBody = Center(child: loading ?? const DsLoading());
    } else if (error != null) {
      resolvedBody = Center(
        child: errorWidget ?? DsError(message: error!),
      );
    } else {
      resolvedBody = body;
    }

    resolvedBody = DsPageFrame(
      maxWidth: maxBodyWidth,
      padding: bodyPadding,
      child: resolvedBody,
    );

    if (scrollable) {
      resolvedBody = SingleChildScrollView(child: resolvedBody);
    }

    final bodyContent = Column(
      children: [
        if (header != null || title != null)
          DsPageFrame(
            maxWidth: maxBodyWidth,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: header ??
                DsPageHeader(
                  title: title!,
                  subtitle: subtitle,
                  actions: actions,
                ),
          ),
        Expanded(child: resolvedBody),
      ],
    );

    final frame = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerLowest,
        gradient: gradients?.heroGlow,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.18),
                      blurRadius: 120,
                      spreadRadius: 48,
                    ),
                  ],
                ),
                child: const SizedBox(width: 220, height: 220),
              ),
            ),
          ),
          if (useSafeArea) SafeArea(child: bodyContent) else bodyContent,
        ],
      ),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: frame,
      bottomNavigationBar: footer ?? const DsStatusBar(),
    );
  }
}

class DsPrimaryButton extends StatelessWidget {
  const DsPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}

class DsEmpty extends StatelessWidget {
  const DsEmpty({super.key, this.message = 'Nothing here yet.'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DsSection(
        title: 'Nenhum dado disponivel',
        subtitle: message,
        tone: DsPanelTone.low,
        child: const SizedBox.shrink(),
      ),
    );
  }
}

class DsError extends StatelessWidget {
  const DsError({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: DsPanel(
        tone: DsPanelTone.high,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: DsPrimaryButton(label: 'Retry', onPressed: onRetry!),
              ),
          ],
        ),
      ),
    );
  }
}

class DsLoading extends StatelessWidget {
  const DsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: DsFocusFrame(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }
}
