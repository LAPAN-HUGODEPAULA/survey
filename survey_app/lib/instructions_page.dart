/// Página de instruções e verificação de compreensão.
///
/// Apresenta as instruções do questionário ao usuário e verifica
/// se ele compreendeu antes de permitir o início das perguntas.

import 'package:flutter/material.dart';
import 'package:survey_app/survey_page.dart';

/// Página que apresenta instruções do questionário e verifica compreensão.
///
/// Esta página é exibida após a coleta de dados demográficos e antes
/// do questionário principal. Garante que o usuário compreendeu as
/// instruções através de uma pergunta de verificação.
///
/// Só permite avançar quando o usuário seleciona a resposta correta
/// na pergunta de compreensão.
class InstructionsPage extends StatefulWidget {
  /// Caminho do arquivo JSON do questionário a ser aplicado
  final String surveyPath;

  /// Cria uma página de instruções.
  ///
  /// [surveyPath] - Caminho para o arquivo JSON do questionário
  const InstructionsPage({super.key, required this.surveyPath});

  @override
  State<InstructionsPage> createState() => _InstructionsPageState();
}

/// Estado da página de instruções.
///
/// Controla a seleção da pergunta de compreensão e a validação
/// antes de permitir o avanço para o questionário.
class _InstructionsPageState extends State<InstructionsPage> {
  /// Resposta selecionada pelo usuário na pergunta de compreensão
  String? _comprehensionAnswer;

  /// Resposta correta esperada para a pergunta de compreensão
  final String _correctAnswer = 'Entendi, responderei honestamente.';

  /// Flag que indica se deve mostrar mensagem de erro
  bool _showError = false;

  /// Inicia o questionário se a resposta de compreensão estiver correta.
  ///
  /// Valida se o usuário selecionou a resposta correta. Se sim,
  /// navega para [SurveyPage]. Se não, exibe mensagem de erro.
  void _startSurvey() {
    setState(() {
      if (_comprehensionAnswer == _correctAnswer) {
        _showError = false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SurveyPage(surveyPath: widget.surveyPath),
          ),
        );
      } else {
        _showError = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instruções'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título das instruções
              const Text(
                'Instruções do Questionário',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Texto das instruções
              const Text(
                'A seguir, você responderá a uma série de perguntas sobre seus '
                'sentimentos e pensamentos recentes. Por favor, leia cada pergunta '
                'com atenção e responda da forma mais honesta possível. Não há '
                'respostas certas ou erradas. Suas respostas são confidenciais '
                'e nos ajudarão a entender melhor suas experiências.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),

              // Pergunta de compreensão
              const Text(
                'Pergunta de Compreensão:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Text(
                'Para garantir que você entendeu as instruções, por favor, '
                'selecione a opção correta abaixo:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Opções de resposta
              ...[
                'Vou responder rapidamente sem ler.',
                'Entendi, responderei honestamente.',
                'Não sei como responder.',
              ].map(
                (option) => RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _comprehensionAnswer,
                  onChanged: (value) => setState(() {
                    _comprehensionAnswer = value;
                    if (_showError) _showError = false;
                  }),
                ),
              ),

              // Mensagem de erro
              if (_showError)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Por favor, selecione a resposta correta para continuar.',
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),

              const Spacer(),

              // Botão para iniciar questionário
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startSurvey,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Iniciar Questionário',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
