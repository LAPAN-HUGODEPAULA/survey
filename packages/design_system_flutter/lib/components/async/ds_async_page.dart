import 'package:flutter/material.dart';
import 'package:design_system_flutter/widgets/ds_scaffold.dart';

class DsAsyncPage extends StatelessWidget {
  const DsAsyncPage({
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
    return DsScaffold(
      appBar: appBar,
      isLoading: isLoading,
      error: error,
      loading: loading,
      errorWidget: errorWidget,
      body: child,
    );
  }
}
