import 'dart:convert';

import 'package:survey_app/core/models/survey/instructions.dart';
import 'package:survey_app/core/models/survey/prompt_association.dart';
import 'package:survey_app/core/models/survey/question.dart';

/// Parses a backend JSON document into a [Survey] instance.
Survey surveyFromJson(String str) =>
    Survey.fromJson(jsonDecode(str) as Map<String, dynamic>);

/// Represents a complete survey definition delivered by the backend.
class Survey {
  const Survey({
    required this.id,
    required this.surveyDisplayName,
    required this.surveyName,
    required this.surveyDescription,
    required this.creatorId,
    required this.createdAt,
    required this.modifiedAt,
    required this.instructions,
    required this.questions,
    required this.prompt,
    this.finalNotes,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['_id']?.toString() ?? '',
      surveyDisplayName: json['surveyDisplayName']?.toString() ?? '',
      surveyName: json['surveyName']?.toString() ?? '',
      surveyDescription: json['surveyDescription']?.toString() ?? '',
      creatorId:
          json['creatorId']?.toString() ??
          json['creatorName']?.toString() ??
          '',
      createdAt: _parseDate(json['createdAt']),
      modifiedAt: _parseDate(json['modifiedAt']),
      instructions: Instructions.fromJson(
        Map<String, dynamic>.from(
          json['instructions'] as Map<Object?, Object?>? ?? const {},
        ),
      ),
      questions: (json['questions'] as List<dynamic>)
          .map((entry) => Question.fromJson(entry as Map<String, dynamic>))
          .toList(growable: false),
      prompt: json['prompt'] is Map<String, dynamic>
          ? SurveyPromptReference.fromJson(json['prompt'] as Map<String, dynamic>)
          : json['prompt'] is Map
          ? SurveyPromptReference.fromJson(
              Map<String, dynamic>.from(json['prompt'] as Map),
            )
          : null,
      finalNotes: json['finalNotes']?.toString(),
    );
  }

  final String id;
  final String surveyDisplayName;
  final String surveyName;
  final String surveyDescription;
  final String creatorId;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final Instructions instructions;
  final List<Question> questions;
  final SurveyPromptReference? prompt;
  final String? finalNotes;

  static DateTime _parseDate(dynamic raw) {
    // Some records omit the time separator, so normalize before parsing.
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
