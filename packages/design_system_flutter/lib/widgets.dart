export 'widgets/survey_option_button.dart';
export 'widgets/survey_progress_indicator.dart';
export 'widgets/ds_buttons.dart';
export 'widgets/ds_chip.dart';
export 'widgets/ds_indicator.dart';
export 'widgets/ds_dialog.dart';
export 'widgets/ds_chat_bubble.dart';

import 'package:flutter/material.dart';

const dsSharedStatusBarText =
    'COPYRIGHT © 2026. Laboratório de Pesquisa Aplicada às Neurociências da Visão - Todos os direitos reservados.';

class DsStatusBar extends StatelessWidget {
  const DsStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            dsSharedStatusBarText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class DsScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final PreferredSizeWidget? appBar;
  final bool isLoading;
  final String? error;
  final Widget? loading;
  final Widget? errorWidget;
  final bool useSafeArea;
  final Color? backgroundColor;
  final Widget? footer;

  const DsScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.appBar,
    this.isLoading = false,
    this.error,
    this.loading,
    this.errorWidget,
    this.useSafeArea = false,
    this.backgroundColor,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    Widget resolvedBody;
    if (isLoading) {
      resolvedBody = Center(child: loading ?? const CircularProgressIndicator());
    } else if (error != null) {
      resolvedBody = Center(child: errorWidget ?? Text(error!));
    } else {
      resolvedBody = body;
    }

    if (useSafeArea) {
      resolvedBody = SafeArea(child: resolvedBody);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar ?? (title != null ? AppBar(title: Text(title!), actions: actions) : null),
      body: resolvedBody,
      bottomNavigationBar: footer ?? const DsStatusBar(),
    );
  }
}

class DsPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool loading;

  const DsPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

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
  final String message;
  const DsEmpty({super.key, this.message = 'Nothing here yet.'});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}

class DsError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const DsError({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: DsPrimaryButton(label: 'Retry', onPressed: onRetry!),
            ),
        ],
      ),
    );
  }
}

class DsLoading extends StatelessWidget {
  const DsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
