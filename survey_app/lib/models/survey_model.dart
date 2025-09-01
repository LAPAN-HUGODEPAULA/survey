// lib/models/survey_model.dart
///
/// Modelos de dados para representação de questionários e perguntas.
///
/// Este arquivo contém as classes que modelam a estrutura dos questionários
/// carregados a partir de arquivos JSON, incluindo métodos de deserialização.
library;


import 'dart:convert';

/// Função utilitária para deserializar um questionário a partir de JSON.
///
/// [str] - String JSON contendo os dados do questionário
///
/// Returns um objeto [Survey] deserializado
///
/// Throws [FormatException] se o JSON estiver malformado
Survey surveyFromJson(String str) => Survey.fromJson(json.decode(str));

/// Modelo que representa as instruções de um questionário.
///
/// Contém o preâmbulo em HTML, pergunta de compreensão e opções de resposta.
class Instructions {
  /// Preâmbulo em formato HTML explicando o questionário
  final String preamble;

  /// Texto da pergunta de compreensão
  final String questionText;

  /// Lista de opções de resposta para a pergunta de compreensão
  final List<String> answers;

  /// Cria uma nova instância de Instructions.
  ///
  /// [preamble] - Texto explicativo em HTML
  /// [questionText] - Pergunta de verificação de compreensão
  /// [answers] - Opções de resposta, sendo a última sempre a correta
  Instructions({
    required this.preamble,
    required this.questionText,
    required this.answers,
  });

  /// Cria Instructions a partir de um Map JSON.
  ///
  /// [json] - Map contendo os dados das instruções
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "preamble": "<p>Texto em HTML</p>",
  ///   "questionText": "Pergunta de compreensão?",
  ///   "answers": ["Opção 1", "Opção 2", "Resposta Correta"]
  /// }
  /// ```
  factory Instructions.fromJson(Map<String, dynamic> json) => Instructions(
    preamble: json["preamble"],
    questionText: json["questionText"],
    answers: List<String>.from(json["answers"].map((x) => x)),
  );

  /// Retorna a resposta correta (sempre a última da lista).
  String get correctAnswer => answers.last;
}

/// Modelo que representa um questionário completo.
///
/// Contém informações básicas do questionário, instruções e lista de perguntas.
/// Cada questionário pode ter múltiplas perguntas com diferentes opções de resposta.
///
/// Exemplo de uso:
/// ```dart
/// final survey = Survey(
///   surveyId: "exemplo_01",
///   surveyName: "Questionário de Exemplo",
///   instructions: instructions,
///   questions: [question1, question2, question3]
/// );
/// ```
class Survey {
  /// Identificador único do questionário
  final String surveyId;

  /// Nome do questionário
  final String surveyName;

  /// Descrição do questionário
  final String surveyDescription;

  /// Nome do criador do questionário
  final String creatorName;

  /// Contato do criador do questionário (email, telefone, etc.)
  final String? creatorContact;

  /// Data de criação
  final String createdAt;

  /// Data de modificação
  final String modifiedAt;

  /// Instruções do questionário
  final Instructions instructions;

  /// Lista de perguntas que compõem o questionário
  final List<Question> questions;

  /// Notas finais em HTML exibidas após completar o questionário
  final String? finalNotes;

  /// Cria uma nova instância de Survey.
  ///
  /// [surveyId] - Identificador único do questionário
  /// [surveyName] - Nome do questionário
  /// [surveyDescription] - Descrição do questionário
  /// [creatorName] - Nome do criador
  /// [creatorContact] - Contato do criador (opcional)
  /// [createdAt] - Data de criação
  /// [modifiedAt] - Data de modificação
  /// [instructions] - Instruções do questionário
  /// [questions] - Lista de perguntas do questionário
  /// [finalNotes] - Notas finais em HTML (opcional)
  Survey({
    required this.surveyId,
    required this.surveyName,
    required this.surveyDescription,
    required this.creatorName,
    this.creatorContact,
    required this.createdAt,
    required this.modifiedAt,
    required this.instructions,
    required this.questions,
    this.finalNotes,
  });

  /// Cria um Survey a partir de um Map JSON.
  ///
  /// [json] - Map contendo os dados do questionário
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "surveyId": "questionario_01",
  ///   "surveyName": "Nome do Questionário",
  ///   "surveyDescription": "Descrição...",
  ///   "creatorName": "Criador",
  ///   "creatorContact": "email@exemplo.com",
  ///   "createdAt": "2025-08-15 10:00:00",
  ///   "modifiedAt": "2025-08-15 10:00:00",
  ///   "instructions": {...},
  ///   "questions": [...],
  ///   "finalNotes": "<p>Notas finais em HTML</p>"
  /// }
  /// ```
  factory Survey.fromJson(Map<String, dynamic> json) => Survey(
    surveyId: json["surveyId"],
    surveyName: json["surveyName"],
    surveyDescription: json["surveyDescription"],
    creatorName: json["creatorName"],
    creatorContact: json["creatorContact"],
    createdAt: json["createdAt"],
    modifiedAt: json["modifiedAt"],
    instructions: Instructions.fromJson(json["instructions"]),
    questions: List<Question>.from(
      json["questions"].map((x) => Question.fromJson(x)),
    ),
    finalNotes: json["finalNotes"],
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
