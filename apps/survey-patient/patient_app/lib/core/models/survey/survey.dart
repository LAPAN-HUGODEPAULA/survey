library;

import 'dart:convert';

import 'package:patient_app/core/models/survey/instructions.dart';
import 'package:patient_app/core/models/survey/question.dart';

/// Função utilitária para deserializar um questionário a partir de JSON.
Survey surveyFromJson(String str) => Survey.fromJson(json.decode(str));

/// Modelo que representa um questionário completo.
class Survey {
  const Survey({
    required this.id,
    required this.surveyDisplayName,
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

  final String id;
  final String surveyDisplayName;
  final String surveyName;
  final String surveyDescription;
  final String creatorName;
  final String? creatorContact;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final Instructions instructions;
  final List<Question> questions;
  final String? finalNotes;

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['_id']?.toString() ?? '',
      surveyDisplayName: json['surveyDisplayName']?.toString() ?? '',
      surveyName: json['surveyName']?.toString() ?? '',
      surveyDescription: json['surveyDescription']?.toString() ?? '',
      creatorName: json['creatorName']?.toString() ?? '',
      creatorContact: json['creatorContact']?.toString(),
      createdAt: _parseDate(json['createdAt']),
      modifiedAt: _parseDate(json['modifiedAt']),
      instructions: Instructions.fromJson(
        (json['instructions'] as Map).cast<String, dynamic>(),
      ),
      questions: (json['questions'] as List<dynamic>)
          .map((entry) => Question.fromJson(entry as Map<String, dynamic>))
          .toList(growable: false),
      finalNotes: json['finalNotes']?.toString(),
    );
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw == null) {
      return DateTime.now();
    }
    final value = raw.toString();
    try {
      return DateTime.parse(
        value.contains('T') ? value : value.replaceAll(' ', 'T'),
      );
    } catch (_) {
      return DateTime.now();
    }
  }
}
