// lib/survey_page.dart (versão atualizada)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:survey_app/models/survey_model.dart'; // Importa nosso modelo
import 'package:survey_app/thank_you_page.dart';

class SurveyPage extends StatefulWidget {
  final String surveyPath; // Recebe o caminho do arquivo JSON
  const SurveyPage({super.key, required this.surveyPath});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  Survey? _survey; // Agora armazena o objeto Survey completo
  int _currentQuestionIndex = 0;
  final List<String> _answers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurveyQuestions();
  }

  Future<void> _loadSurveyQuestions() async {
    try {
      final String jsonString = await rootBundle.loadString(widget.surveyPath);
      setState(() {
        // Usa nosso modelo para decodificar o JSON
        _survey = surveyFromJson(jsonString);
        _isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar o questionário: $e");
      setState(() {
        _isLoading = false;
      });
      // Opcional: mostrar um erro na tela para o usuário
    }
  }

  void _answerQuestion(String answer) {
    _answers.add(answer);
    print('Respostas até agora: $_answers');

    if (_currentQuestionIndex < _survey!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ThankYouPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_survey == null) {
      return const Scaffold(
        body: Center(child: Text('Não foi possível carregar o questionário.')),
      );
    }

    final currentQuestion = _survey!.questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        // Usa o nome do questionário no título!
        title: Text(
          '${_survey!.name}: Pergunta ${_currentQuestionIndex + 1} de ${_survey!.questions.length}',
        ),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                currentQuestion.questionText,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ..._buildAnswerButtons(currentQuestion.answers),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAnswerButtons(List<String> answers) {
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
