// lib/survey_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:survey_app/thank_you_page.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  List<dynamic> _questions = [];
  int _currentQuestionIndex = 0;
  final List<String> _answers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurveyQuestions();
  }

  // Função para carregar as perguntas do arquivo JSON
  Future<void> _loadSurveyQuestions() async {
    final String jsonString = await rootBundle.loadString('assets/survey.json');
    final List<dynamic> jsonResponse = json.decode(jsonString);
    setState(() {
      _questions = jsonResponse;
      _isLoading = false;
    });
  }

  // Função chamada quando uma resposta é selecionada
  void _answerQuestion(String answer) {
    _answers.add(answer); // Armazena a resposta
    print('Respostas até agora: $_answers');

    if (_currentQuestionIndex < _questions.length - 1) {
      // Se não for a última pergunta, avança para a próxima
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // Se for a última pergunta, navega para a página de agradecimento
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ThankYouPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Mostra um indicador de carregamento enquanto o JSON é lido
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Pega a pergunta atual
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Questionário: Pergunta ${_currentQuestionIndex + 1} de ${_questions.length}'),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false, // Remove o botão de voltar
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Texto da Pergunta
              Text(
                currentQuestion['questionText'],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Botões de Resposta
              ..._buildAnswerButtons(currentQuestion['answers']),
            ],
          ),
        ),
      ),
    );
  }

  // Função auxiliar para construir a lista de botões de resposta
  List<Widget> _buildAnswerButtons(List<dynamic> answers) {
    return answers.map((answer) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton(
          onPressed: () => _answerQuestion(answer),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.teal.shade100,
            foregroundColor: Colors.teal.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(answer, style: const TextStyle(fontSize: 16)),
        ),
      );
    }).toList();
  }
}
