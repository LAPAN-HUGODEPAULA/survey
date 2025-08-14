// lib/models/survey_model.dart
///
/// Modelos de dados para representação de questionários e perguntas.
///
/// Este arquivo contém as classes que modelam a estrutura dos questionários
/// carregados a partir de arquivos JSON, incluindo métodos de deserialização.

import 'dart:convert';

/// Função utilitária para deserializar um questionário a partir de JSON.
///
/// [str] - String JSON contendo os dados do questionário
///
/// Returns um objeto [Survey] deserializado
///
/// Throws [FormatException] se o JSON estiver malformado
Survey surveyFromJson(String str) => Survey.fromJson(json.decode(str));

/// Modelo que representa um questionário completo.
///
/// Contém o nome do questionário e a lista de perguntas.
/// Cada questionário pode ter múltiplas perguntas com diferentes opções de resposta.
///
/// Exemplo de uso:
/// ```dart
/// final survey = Survey(
///   name: "Questionário de Exemplo",
///   questions: [question1, question2, question3]
/// );
/// ```
class Survey {
  /// Nome identificador do questionário
  final String name;

  /// Lista de perguntas que compõem o questionário
  final List<Question> questions;

  /// Cria uma nova instância de Survey.
  ///
  /// [name] - Nome do questionário
  /// [questions] - Lista de perguntas do questionário
  Survey({required this.name, required this.questions});

  /// Cria um Survey a partir de um Map JSON.
  ///
  /// [json] - Map contendo os dados do questionário
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "name": "Nome do Questionário",
  ///   "questions": [...]
  /// }
  /// ```
  factory Survey.fromJson(Map<String, dynamic> json) => Survey(
    name: json["name"],
    questions: List<Question>.from(
      json["questions"].map((x) => Question.fromJson(x)),
    ),
  );
}

/// Modelo que representa uma pergunta individual do questionário.
///
/// Cada pergunta possui um ID único, texto da pergunta e uma lista
/// de possíveis respostas que o usuário pode selecionar.
///
/// Exemplo de uso:
/// ```dart
/// final question = Question(
///   id: 1,
///   questionText: "Como você se sente hoje?",
///   answers: ["Bem", "Regular", "Mal"]
/// );
/// ```
class Question {
  /// Identificador único da pergunta
  final int id;

  /// Texto da pergunta apresentada ao usuário
  final String questionText;

  /// Lista de opções de resposta disponíveis
  final List<String> answers;

  /// Cria uma nova instância de Question.
  ///
  /// [id] - Identificador único da pergunta
  /// [questionText] - Texto da pergunta
  /// [answers] - Lista de opções de resposta
  Question({
    required this.id,
    required this.questionText,
    required this.answers,
  });

  /// Cria uma Question a partir de um Map JSON.
  ///
  /// [json] - Map contendo os dados da pergunta
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "id": 1,
  ///   "questionText": "Texto da pergunta",
  ///   "answers": ["Opção 1", "Opção 2", "Opção 3"]
  /// }
  /// ```
  factory Question.fromJson(Map<String, dynamic> json) => Question(
    id: json["id"],
    questionText: json["questionText"],
    answers: List<String>.from(json["answers"].map((x) => x)),
  );
}
