// lib/instructions_page.dart

import 'package:flutter/material.dart';
import 'package:survey_app/survey_page.dart';

class InstructionsPage extends StatefulWidget {
  const InstructionsPage({super.key});

  @override
  State<InstructionsPage> createState() => _InstructionsPageState();
}

class _InstructionsPageState extends State<InstructionsPage> {
  String? _comprehensionAnswer;
  final String _correctAnswer = 'Entendi, responderei honestamente.';
  bool _showError = false;

  void _startSurvey() {
    setState(() {
      if (_comprehensionAnswer == _correctAnswer) {
        _showError = false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SurveyPage()),
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
              const Text(
                'Instruções do Questionário',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'A seguir, você responderá a uma série de perguntas sobre seus sentimentos e pensamentos recentes. Por favor, leia cada pergunta com atenção e responda da forma mais honesta possível. Não há respostas certas ou erradas. Suas respostas são confidenciais e nos ajudarão a entender melhor suas experiências.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              const Text(
                'Pergunta de Compreensão:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Text(
                'Para garantir que você entendeu as instruções, por favor, selecione a opção correta abaixo:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ...[
                'Vou responder rapidamente sem ler.',
                'Entendi, responderei honestamente.',
                'Não sei como responder.'
              ].map((option) => RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _comprehensionAnswer,
                    onChanged: (value) {
                      setState(() {
                        _comprehensionAnswer = value;
                         if(_showError) _showError = false;
                      });
                    },
                  )),
              if (_showError)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Por favor, selecione a resposta correta para continuar.',
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startSurvey,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Iniciar Questionário', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

