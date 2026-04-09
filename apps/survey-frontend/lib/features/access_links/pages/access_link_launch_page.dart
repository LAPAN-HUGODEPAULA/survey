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
  bool _isResolving = true;
  String? _failureMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveLink());
  }

  Future<void> _resolveLink() async {
    if (mounted) {
      setState(() {
        _isResolving = true;
        _failureMessage = null;
      });
    }

    try {
      final settings = context.read<AppSettings>();
      await settings.loadAvailableSurveys();
      final resolved = await _repository.resolve(widget.token);
      settings.applyPreparedAccessLink(resolved);
      if (!mounted) {
        return;
      }
      context.go('/demographics');
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isResolving = false;
        _failureMessage = DsErrorMapper.toUserMessage(
          error,
          fallbackMessage:
              'Não foi possível validar este link preparado agora. Tente novamente em alguns instantes.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failureMessage != null) {
      return AccessLinkUnavailablePage(
        errorMessage: _failureMessage,
        onRetry: _resolveLink,
      );
    }

    return DsScaffold(
      title: 'Validando link preparado',
      subtitle: 'Carregando o questionario e protegendo a sessao.',
      body: !_isResolving
          ? const SizedBox.shrink()
          : const Center(
              child: DsPanel(
                tone: DsPanelTone.low,
                child: SizedBox(
                  width: 240,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Preparando acesso...', textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
