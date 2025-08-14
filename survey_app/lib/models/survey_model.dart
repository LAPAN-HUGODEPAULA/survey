// lib/models/survey_model.dart

import 'dart:convert';

// Função para facilitar a decodificação
Survey surveyFromJson(String str) => Survey.fromJson(json.decode(str));

// Classe que representa o questionário completo
class Survey {
  final String name;
  final List<Question> questions;

  Survey({required this.name, required this.questions});

  factory Survey.fromJson(Map<String, dynamic> json) => Survey(
    name: json["name"],
    questions: List<Question>.from(
      json["questions"].map((x) => Question.fromJson(x)),
    ),
  );
}

// Classe que representa uma única pergunta
class Question {
  final int id;
  final String questionText;
  final List<String> answers;

  Question({
    required this.id,
    required this.questionText,
    required this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    id: json["id"],
    questionText: json["questionText"],
    answers: List<String>.from(json["answers"].map((x) => x)),
  );
}
