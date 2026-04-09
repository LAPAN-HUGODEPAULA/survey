import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';

class AccessLinkUnavailablePage extends StatelessWidget {
  const AccessLinkUnavailablePage({super.key, this.errorMessage, this.onRetry});

  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: 'Link indisponível',
      subtitle: 'O link preparado não pode mais ser usado nesta sessão.',
      scrollable: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DsEmptyState(
                visual: Icon(
                  Icons.link_off_rounded,
                  size: 56,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                title: 'Este questionário preparado não está mais disponível.',
                description:
                    errorMessage ??
                    'Entre em contato com a pessoa responsável pela triagem para solicitar um novo link.',
                actionLabel: onRetry == null ? null : 'Tentar Novamente',
                onAction: onRetry,
              ),
              const SizedBox(height: 16),
              const DsMessageBanner(
                feedback: DsFeedbackMessage(
                  severity: DsStatusType.info,
                  title: 'Precisa de ajuda?',
                  message:
                      'Se precisar de ajuda, envie uma mensagem para lapan.hugodepaula@gmail.com.',
                ),
                margin: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
