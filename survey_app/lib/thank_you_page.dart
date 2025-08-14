// lib/thank_you_page.dart
///
/// Página de agradecimento exibida após completar o questionário.
///
/// Página final da aplicação, apresentada quando o usuário completa
/// todas as perguntas do questionário, confirmando que as respostas
/// foram registradas com sucesso.

import 'package:flutter/material.dart';

/// Página de agradecimento final do questionário.
///
/// Exibe uma mensagem de agradecimento ao usuário após completar
/// o questionário, confirmando que as respostas foram registradas
/// com sucesso. Esta é a página terminal do fluxo da aplicação.
///
/// A página não possui navegação de retorno, indicando que o
/// processo foi finalizado.
class ThankYouPage extends StatelessWidget {
  const ThankYouPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizado'),
        backgroundColor: Colors.teal,
        // Remove botão de voltar para indicar fim do processo
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone de confirmação
              Icon(Icons.check_circle_outline, color: Colors.green, size: 100),
              SizedBox(height: 24),

              // Mensagem principal de agradecimento
              Text(
                'Obrigado por responder!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              // Mensagem de confirmação
              Text(
                'Suas respostas foram registradas com sucesso.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
