import 'package:patient_app/core/models/agent_response.dart';
import 'package:patient_app/core/models/patient.dart';

class SurveyResponse {
  const SurveyResponse({
    this.id,
    this.agentResponse,
    required this.surveyId,
    required this.creatorId,
    required this.testDate,
    required this.screenerId,
    this.patient,
    required this.answers,
  });

  final String? id;
  final AgentResponse? agentResponse;
  final String surveyId;
  final String creatorId;
  final DateTime testDate;
  final String screenerId;
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
      creatorId: json['creatorId']?.toString() ?? '',
      testDate: _parseDate(json['testDate']),
      screenerId: json['screenerId']?.toString() ?? '',
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
      'creatorId': creatorId,
      'testDate': testDate.toIso8601String(),
      'screenerId': screenerId,
      if (patient != null) 'patient': patient!.toJson(),
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }

  SurveyResponse copyWith({
    String? id,
    String? surveyId,
    String? creatorId,
    DateTime? testDate,
    String? screenerId,
    Patient? patient,
    List<Answer>? answers,
    AgentResponse? agentResponse,
  }) {
    return SurveyResponse(
      id: id ?? this.id,
      surveyId: surveyId ?? this.surveyId,
      creatorId: creatorId ?? this.creatorId,
      testDate: testDate ?? this.testDate,
      screenerId: screenerId ?? this.screenerId,
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
