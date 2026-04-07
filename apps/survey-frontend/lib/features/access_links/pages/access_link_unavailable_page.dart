import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';

class AccessLinkUnavailablePage extends StatelessWidget {
  const AccessLinkUnavailablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: 'Link indisponível',
      subtitle: 'O link preparado não pode mais ser usado nesta sessão.',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: DsSection(
            eyebrow: 'Acesso',
            title: 'Este questionário preparado não está mais disponível.',
            subtitle:
                'Entre em contato com a pessoa responsável pela triagem para solicitar um novo link.',
            child: const DsFeedbackBanner(
              feedback: DsFeedbackMessage(
                severity: DsStatusType.info,
                title: 'Link expirado ou já utilizado',
                message:
                    'Se precisar de ajuda, envie uma mensagem para lapan.hugodepaula@gmail.com.',
              ),
              margin: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }
}
