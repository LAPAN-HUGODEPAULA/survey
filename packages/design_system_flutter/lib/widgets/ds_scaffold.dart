import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:design_system_flutter/components/legal/ds_legal_viewer.dart';
import 'package:design_system_flutter/components/legal/legal_content.dart';
import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:design_system_flutter/widgets/ds_buttons.dart';
import 'package:design_system_flutter/widgets/ds_empty_state.dart';
import 'package:design_system_flutter/widgets/ds_chip.dart';
import 'package:design_system_flutter/widgets/ds_emotional_tone_provider.dart';
import 'package:design_system_flutter/widgets/ds_feedback.dart';
import 'package:design_system_flutter/widgets/ds_surface.dart';
import 'package:design_system_flutter/widgets/ds_wayfinding.dart';

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
    this.breadcrumbs,
    this.onBack,
    this.backLabel = 'Voltar',
    this.leading,
    this.trailing,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final List<DsBreadcrumbItem>? breadcrumbs;
  final VoidCallback? onBack;
  final String backLabel;
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
                if (breadcrumbs != null && breadcrumbs!.isNotEmpty) ...[
                  DsBreadcrumbs(items: breadcrumbs!),
                  SizedBox(height: spacing?.sm ?? 8),
                ],
                if (onBack != null) ...[
                  DsTextButton(
                    label: backLabel,
                    icon: Icons.arrow_back_rounded,
                    size: DsButtonSize.small,
                    onPressed: onBack!,
                  ),
                  SizedBox(height: spacing?.sm ?? 8),
                ],
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

class DsScaffold extends StatefulWidget {
  const DsScaffold({
    super.key,
    required this.body,
    this.title,
    this.subtitle,
    this.breadcrumbs,
    this.onBack,
    this.backLabel = 'Voltar',
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
    this.floatingActionButton,
    this.bodyPadding = const EdgeInsets.all(24),
    this.maxBodyWidth = 1120,
    this.scrollable = false,
    this.userName,
    this.showAmbientGreeting = false,
    this.ambientGreeting,
  });

  final String? title;
  final String? subtitle;
  final List<DsBreadcrumbItem>? breadcrumbs;
  final VoidCallback? onBack;
  final String backLabel;
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
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry bodyPadding;
  final double maxBodyWidth;
  final bool scrollable;
  final String? userName;
  final bool showAmbientGreeting;
  final String? ambientGreeting;

  @override
  State<DsScaffold> createState() => _DsScaffoldState();
}

class _DsScaffoldState extends State<DsScaffold> {
  StreamSubscription<dynamic>? _connectivitySubscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _primeConnectivityStatus();
    _listenConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  bool _isConnectivityOffline(dynamic result) {
    if (result is ConnectivityResult) {
      return result == ConnectivityResult.none;
    }
    if (result is List<ConnectivityResult>) {
      return result.isEmpty ||
          result.every((entry) => entry == ConnectivityResult.none);
    }
    return false;
  }

  void _updateOfflineFlag(dynamic result) {
    final isOffline = _isConnectivityOffline(result);
    if (mounted && isOffline != _isOffline) {
      setState(() {
        _isOffline = isOffline;
      });
    }
  }

  Future<void> _primeConnectivityStatus() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateOfflineFlag(result);
    } catch (_) {
      // Ignore missing-plugin/platform failures in environments without
      // connectivity support (e.g., widget tests).
    }
  }

  void _listenConnectivity() {
    try {
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        _updateOfflineFlag,
        onError: (_) {
          // Keep current UI state when stream events fail.
        },
      );
    } catch (_) {
      // Ignore missing-plugin/platform failures in environments without
      // connectivity support (e.g., widget tests).
    }
  }

  String? _resolvedAmbientGreeting(BuildContext context) {
    if (!widget.showAmbientGreeting) {
      return null;
    }
    final customGreeting = widget.ambientGreeting?.trim();
    if (customGreeting != null && customGreeting.isNotEmpty) {
      return customGreeting;
    }
    final tone = DsEmotionalToneProvider.resolveTokens(context);
    return tone.greetingFor(widget.userName);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradients = Theme.of(context).extension<LapanGradientTokens>();
    final ambientGreeting = _resolvedAmbientGreeting(context);

    Widget resolvedBody;
    if (widget.isLoading) {
      resolvedBody = Center(child: widget.loading ?? const DsLoading());
    } else if (widget.error != null) {
      resolvedBody = Center(
        child: widget.errorWidget ?? DsError(message: widget.error!),
      );
    } else {
      resolvedBody = widget.body;
    }

    resolvedBody = DsPageFrame(
      maxWidth: widget.maxBodyWidth,
      padding: widget.bodyPadding,
      child: resolvedBody,
    );

    if (widget.scrollable) {
      resolvedBody =
          Scrollbar(child: SingleChildScrollView(child: resolvedBody));
    }

    final bodyContent = Column(
      children: [
        if (_isOffline)
          DsPageFrame(
            maxWidth: widget.maxBodyWidth,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: const DsMessageBanner(
              feedback: DsFeedbackMessage(
                severity: DsStatusType.warning,
                title: 'Você está offline',
                message:
                    'Você está offline. Suas alterações serão salvas localmente até a conexão voltar.',
              ),
              margin: EdgeInsets.zero,
            ),
          ),
        if (widget.header != null || widget.title != null)
          DsPageFrame(
            maxWidth: widget.maxBodyWidth,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: widget.header ??
                DsPageHeader(
                  title: widget.title!,
                  eyebrow: ambientGreeting,
                  subtitle: widget.subtitle,
                  breadcrumbs: widget.breadcrumbs,
                  onBack: widget.onBack,
                  backLabel: widget.backLabel,
                  actions: widget.actions,
                ),
          ),
        Expanded(child: resolvedBody),
      ],
    );

    final frame = DecoratedBox(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? colorScheme.surfaceContainerLowest,
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
          if (widget.useSafeArea) SafeArea(child: bodyContent) else bodyContent,
        ],
      ),
    );

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      appBar: widget.appBar,
      body: frame,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.footer ?? const DsStatusBar(),
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
  const DsEmpty({
    super.key,
    this.message = 'Nenhum conteúdo disponível.',
    this.actionLabel,
    this.onAction,
    this.visual,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? visual;

  @override
  Widget build(BuildContext context) {
    return DsEmptyState(
      title: 'Nenhum dado disponível',
      description: message,
      actionLabel: actionLabel,
      onAction: onAction,
      visual: visual,
    );
  }
}

class DsError extends StatelessWidget {
  const DsError({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 480,
        child: DsMessageBanner(
          feedback: DsFeedbackMessage(
            severity: DsStatusType.error,
            title: 'Não foi possível carregar este conteúdo',
            message: message,
            primaryAction: onRetry == null
                ? null
                : DsFeedbackAction(
                    label: 'Tentar Novamente',
                    onPressed: onRetry!,
                    icon: Icons.refresh,
                  ),
          ),
          margin: EdgeInsets.zero,
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
