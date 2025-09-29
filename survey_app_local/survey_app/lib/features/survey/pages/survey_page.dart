// lib/survey_page.dart (versão atualizada)
/// Página principal do questionário onde as perguntas são apresentadas.
///
/// Gerencia a apresentação sequencial das perguntas, coleta das respostas
/// e navegação entre perguntas até completar o questionário.
library;

import 'package:flutter/material.dart';
import 'package:survey_app/core/models/survey/survey.dart';
import 'package:survey_app/core/navigation/app_navigator.dart';
import 'package:survey_app/core/repositories/survey_repository.dart';
import 'package:survey_app/widgets/common/async_scaffold.dart';

/// Página que apresenta as perguntas do questionário sequencialmente.
///
/// Carrega o questionário a partir de um arquivo JSON, apresenta uma
/// pergunta por vez e coleta as respostas do usuário. Ao final,
/// navega para a página de agradecimento.
///
/// O progresso é mostrado no AppBar com contador de perguntas.
class SurveyPage extends StatefulWidget {
  /// Caminho para o arquivo JSON contendo o questionário
  final String surveyPath;

  /// Cria uma página de questionário.
  ///
  /// [surveyPath] - Caminho para o arquivo JSON do questionário
  const SurveyPage({super.key, required this.surveyPath});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

/// Estado da página do questionário.
///
/// Controla o carregamento do questionário, navegação entre perguntas,
/// coleta de respostas e finalização do processo.
class _SurveyPageState extends State<SurveyPage> {
  /// Objeto Survey carregado do arquivo JSON
  Survey? _survey;

  /// Índice da pergunta atual (baseado em zero)
  int _currentQuestionIndex = 0;

  /// Lista das respostas coletadas do usuário
  final List<String> _answers = [];

  /// Flag que indica se o questionário ainda está carregando
  bool _isLoading = true;

  final SurveyRepository _surveyRepository = SurveyRepository();

  @override
  void initState() {
    super.initState();
    _loadSurveyQuestions();
  }

  /// Carrega o questionário do arquivo JSON especificado.
  ///
  /// Deserializa o arquivo JSON usando [surveyFromJson] e atualiza
  /// o estado da página. Em caso de erro, exibe mensagem no console.
  ///
  /// Throws [Exception] se não conseguir carregar ou deserializar o arquivo.
  Future<void> _loadSurveyQuestions() async {
    try {
      final loaded = await _surveyRepository.getByPath(widget.surveyPath);
      setState(() {
        _survey = loaded;
        _isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar o questionário: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Processa a resposta do usuário e avança para próxima pergunta.
  ///
  /// [answer] - Resposta selecionada pelo usuário
  ///
  /// Adiciona a resposta à lista de respostas coletadas. Se ainda há
  /// perguntas, avança para a próxima. Se foi a última pergunta,
  /// navega para a página de agradecimento com as notas finais.
  void _answerQuestion(String answer) {
    _answers.add(answer);

    if (_currentQuestionIndex < _survey!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // Chegou ao final do questionário
      AppNavigator.replaceWithThankYou(
        context,
        finalNotes: _survey?.finalNotes,
        surveyName: _survey?.surveyName,
        surveyId: _survey?.id,
        surveyAnswers: _answers,
        surveyQuestions: _survey!.questions,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _survey?.questions[_currentQuestionIndex];

    return AsyncScaffold(
      isLoading: _isLoading,
      error: _survey == null && !_isLoading
          ? 'Não foi possível carregar o questionário.'
          : null,
      appBar: AppBar(
        title: Text(
          _survey == null
              ? 'Carregando Questionário'
              : '${_survey!.surveyName}: Pergunta ${_currentQuestionIndex + 1} de ${_survey!.questions.length}',
        ),
        automaticallyImplyLeading: false,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Texto da pergunta
              Text(
                currentQuestion?.questionText ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Botões de resposta
              if (currentQuestion != null)
                ..._buildAnswerButtons(currentQuestion.answers),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói os botões de resposta para a pergunta atual.
  ///
  /// [answers] - Lista de opções de resposta da pergunta atual
  ///
  /// Returns lista de widgets ElevatedButton, um para cada opção de resposta.
  /// Cada botão chama [_answerQuestion] quando pressionado.
  List<Widget> _buildAnswerButtons(List<String> answers) {
    return answers.map((answer) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton(
          onPressed: () => _answerQuestion(answer),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
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
