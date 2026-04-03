import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';

class AccessLinkUnavailablePage extends StatelessWidget {
  const AccessLinkUnavailablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: 'Link indisponivel',
      subtitle: 'O link preparado nao pode mais ser usado nesta sessao.',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: DsSection(
            eyebrow: 'Acesso',
            title: 'Este questionario preparado nao esta mais disponivel.',
            subtitle:
                'Entre em contato com o screener responsavel para solicitar um novo link.',
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 40),
                SizedBox(height: 16),
                Text(
                  'Se precisar de ajuda, envie uma mensagem para lapan.hugodepaula@gmail.com.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
