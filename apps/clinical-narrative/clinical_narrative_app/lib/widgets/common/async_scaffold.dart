library;

import 'package:flutter/material.dart';

class AsyncScaffold extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final PreferredSizeWidget? appBar;
  final Widget? loading;
  final Widget? errorWidget;
  final Widget child;

  const AsyncScaffold({
    super.key,
    required this.isLoading,
    required this.child,
    this.error,
    this.appBar,
    this.loading,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: appBar,
        body: Center(child: loading ?? const CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Scaffold(
        appBar: appBar,
        body: Center(child: errorWidget ?? Text(error!)),
      );
    }
    return Scaffold(appBar: appBar, body: child);
  }
}
