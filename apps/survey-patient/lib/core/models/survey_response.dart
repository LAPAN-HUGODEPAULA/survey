import 'package:patient_app/core/models/agent_response.dart';
import 'package:patient_app/core/models/patient.dart';
import 'package:patient_app/core/models/screener.dart';

class SurveyResponse {
  const SurveyResponse({
    this.id,
    this.agentResponse,
    required this.surveyId,
    required this.creatorName,
    required this.creatorContact,
    required this.testDate,
    required this.screener,
    this.patient,
    required this.answers,
  });

  final String? id;
  final AgentResponse? agentResponse;
  final String surveyId;
  final String creatorName;
  final String creatorContact;
  final DateTime testDate;
  final Screener screener;
  final Patient? patient;
  final List<Answer> answers;

  factory SurveyResponse.fromJson(Map<String, dynamic> json) {
    final answersRaw = json['answers'] as List<dynamic>? ?? const <dynamic>[];
    return SurveyResponse(
      id: json['_id']?.toString(),
      agentResponse: json['agentResponse'] is Map<String, dynamic>
          ? AgentResponse.fromJson(json['agentResponse'] as Map<String, dynamic>)
          : null,
      surveyId: json['surveyId']?.toString() ?? '',
      creatorName: json['creatorName']?.toString() ?? '',
      creatorContact: json['creatorContact']?.toString() ?? '',
      testDate: _parseDate(json['testDate']),
      screener: Screener.fromJson(json),
      patient: _parsePatient(json),
      answers: answersRaw
          .whereType<Map<String, dynamic>>()
          .map(Answer.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surveyId': surveyId,
      'creatorName': creatorName,
      'creatorContact': creatorContact,
      'testDate': testDate.toIso8601String(),
      'screenerName': screener.name,
      'screenerEmail': screener.email,
      if (patient != null) 'patient': patient!.toJson(),
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }

  SurveyResponse copyWith({
    String? id,
    String? surveyId,
    String? creatorName,
    String? creatorContact,
    DateTime? testDate,
    Screener? screener,
    Patient? patient,
    List<Answer>? answers,
    AgentResponse? agentResponse,
  }) {
    return SurveyResponse(
      id: id ?? this.id,
      surveyId: surveyId ?? this.surveyId,
      creatorName: creatorName ?? this.creatorName,
      creatorContact: creatorContact ?? this.creatorContact,
      testDate: testDate ?? this.testDate,
      screener: screener ?? this.screener,
      patient: patient ?? this.patient,
      answers: answers ?? this.answers,
      agentResponse: agentResponse ?? this.agentResponse,
    );
  }
}

class Answer {
  const Answer({required this.id, required this.answer});

  final int id;
  final String answer;

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      answer: json['answer']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'answer': answer,
    };
  }
}

DateTime _parseDate(dynamic raw) {
  if (raw == null) return DateTime.now();
  final value = raw.toString();
  if (value.isEmpty) return DateTime.now();
  try {
    final normalized = value.contains('T') ? value : value.replaceAll(' ', 'T');
    return DateTime.parse(normalized);
  } catch (_) {
    return DateTime.now();
  }
}

Patient? _parsePatient(Map<String, dynamic> json) {
  final rawPatient = json['patient'];
  if (rawPatient is Map<String, dynamic>) {
    return Patient.fromJson(rawPatient);
  }

  final fallback = Patient.fromJson(json);
  final hasData = fallback.name.isNotEmpty ||
      fallback.email.isNotEmpty ||
      fallback.birthDate.isNotEmpty ||
      fallback.gender.isNotEmpty ||
      fallback.ethnicity.isNotEmpty ||
      fallback.educationLevel.isNotEmpty ||
      fallback.profession.isNotEmpty ||
      fallback.medication.isNotEmpty ||
      fallback.diagnoses.isNotEmpty;

  return hasData ? fallback : null;
}
