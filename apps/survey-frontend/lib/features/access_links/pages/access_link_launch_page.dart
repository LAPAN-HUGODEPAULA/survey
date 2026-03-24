
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/core/repositories/screener_access_link_repository.dart';
import 'package:survey_app/features/access_links/pages/access_link_unavailable_page.dart';

class AccessLinkLaunchPage extends StatefulWidget {
  const AccessLinkLaunchPage({super.key, required this.token, this.repository});

  final String token;
  final ScreenerAccessLinkRepository? repository;

  @override
  State<AccessLinkLaunchPage> createState() => _AccessLinkLaunchPageState();
}

class _AccessLinkLaunchPageState extends State<AccessLinkLaunchPage> {
  late final ScreenerAccessLinkRepository _repository =
      widget.repository ?? ScreenerAccessLinkRepository();
  bool _isUnavailable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveLink());
  }

  Future<void> _resolveLink() async {
    try {
      final settings = context.read<AppSettings>();
      await settings.loadAvailableSurveys();
      final resolved = await _repository.resolve(widget.token);
      settings.applyPreparedAccessLink(resolved);
      if (!mounted) {
        return;
      }
      context.go('/demographics');
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isUnavailable = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUnavailable) {
      return const AccessLinkUnavailablePage();
    }

    return const DsScaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
