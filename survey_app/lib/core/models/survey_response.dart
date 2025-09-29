import 'package:survey_app/core/models/patient.dart';
import 'package:survey_app/core/models/screener.dart';

class SurveyResponse {
  final String surveyId; // Will be sourced from Survey.id ("_id" in JSON)
  final String creatorName;
  final String creatorContact;
  final DateTime testDate;
  final Screener screener;
  final Patient patient;
  final List<QuestionAnswer> questions;

  SurveyResponse({
    required this.surveyId,
    required this.creatorName,
    required this.creatorContact,
    required this.testDate,
    required this.screener,
    required this.patient,
    required this.questions,
  });

  factory SurveyResponse.fromJson(Map<String, dynamic> json) {
    return SurveyResponse(
      // Accept both legacy 'surveyId' and new '_id' for compatibility
      surveyId: json['_id'] ?? json['surveyId'],
      creatorName: json['creatorName'],
      creatorContact: json['creatorContact'],
      testDate: DateTime.parse(json['testDate']),
      screener: Screener.fromJson(json),
      patient: Patient.fromJson(json),
      questions: (json['questions'] as List)
          .map((q) => QuestionAnswer.fromJson(q))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Persist using new key name
      '_id': surveyId,
      'creatorName': creatorName,
      'creatorContact': creatorContact,
      'testDate': testDate.toIso8601String(),
      ...screener.toJson(),
      ...patient.toJson(),
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class QuestionAnswer {
  final int id;
  final String answer;

  QuestionAnswer({required this.id, required this.answer});

  factory QuestionAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionAnswer(id: json['id'], answer: json['answer']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'answer': answer};
  }
}
