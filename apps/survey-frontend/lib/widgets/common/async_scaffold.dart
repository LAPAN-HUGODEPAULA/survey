import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';

class AsyncScaffold extends StatelessWidget {
  const AsyncScaffold({
    super.key,
    required this.isLoading,
    required this.child,
    this.error,
    this.appBar,
    this.loading,
    this.errorWidget,
  });
  final bool isLoading;
  final String? error;
  final PreferredSizeWidget? appBar;
  final Widget? loading;
  final Widget? errorWidget;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DsAsyncPage(
      isLoading: isLoading,
      error: error,
      appBar: appBar,
      loading: loading,
      errorWidget: errorWidget,
      child: child,
    );
  }
}
