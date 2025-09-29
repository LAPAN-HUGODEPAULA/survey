library;

import 'dart:convert';

import 'package:survey_app/core/models/survey/instructions.dart';
import 'package:survey_app/core/models/survey/question.dart';

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
/// Contém informações básicas do questionário, instruções e lista de perguntas.
/// Cada questionário pode ter múltiplas perguntas com diferentes opções de resposta.
///
/// Exemplo de uso:
/// ```dart
/// final survey = Survey(
///   id: "exemplo_01",
///   surveyName: "Questionário de Exemplo",
///   instructions: instructions,
///   questions: [question1, question2, question3]
/// );
/// ```
class Survey {
  /// Identificador único do questionário
  final String id;

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
  /// [id] - Identificador único do questionário
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
    required this.id,
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
  ///   "_id": "questionario_01",
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
    // Primary key is "_id"; accept legacy "surveyId" as fallback
    id: json["_id"] ?? json["surveyId"],
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
