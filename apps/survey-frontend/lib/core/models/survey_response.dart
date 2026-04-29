import 'package:survey_app/core/models/agent_response.dart';
import 'package:survey_app/core/models/patient.dart';
import 'package:survey_responses_shared/answer.dart' as shared;

class SurveyResponse {
  const SurveyResponse({
    this.id,
    this.agentResponse,
    this.agentResponses = const [],
    this.accessLinkToken,
    this.accessPointKey,
    this.promptKey,
    required this.surveyId,
    required this.creatorId,
    required this.testDate,
    required this.screenerId,
    required this.patient,
    required this.answers,
  });

  factory SurveyResponse.fromJson(Map<String, dynamic> json) {
    final answersRaw = json['answers'] as List<dynamic>? ?? const <dynamic>[];
    return SurveyResponse(
      id: json['_id']?.toString(),
      agentResponse: json['agentResponse'] is Map<String, dynamic>
          ? AgentResponse.fromJson(
              json['agentResponse'] as Map<String, dynamic>,
            )
          : null,
      agentResponses:
          (json['agentResponses'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map<String, dynamic>>()
              .map(AgentResponse.fromJson)
              .toList(growable: false),
      surveyId: json['surveyId']?.toString() ?? '',
      creatorId:
          json['creatorId']?.toString() ??
          json['creatorName']?.toString() ??
          '',
      testDate: _parseDate(json['testDate']),
      screenerId: json['screenerId']?.toString() ?? '',
      accessLinkToken: json['accessLinkToken']?.toString(),
      accessPointKey: json['accessPointKey']?.toString(),
      promptKey: json['promptKey']?.toString(),
      patient: json['patient'] is Map<String, dynamic>
          ? Patient.fromJson(json['patient'] as Map<String, dynamic>)
          : Patient.fromJson(json),
      answers: answersRaw
          .whereType<Map<String, dynamic>>()
          .map(shared.Answer.fromJson)
          .toList(growable: false),
    );
  }

  final String? id;
  final AgentResponse? agentResponse;
  final List<AgentResponse> agentResponses;
  final String? accessLinkToken;
  final String? accessPointKey;
  final String? promptKey;
  final String surveyId;
  final String creatorId;
  final DateTime testDate;
  final String screenerId;
  final Patient patient;
  final List<shared.Answer> answers;

  Map<String, dynamic> toJson() {
    return {
      'surveyId': surveyId,
      'creatorId': creatorId,
      'testDate': testDate.toIso8601String(),
      'screenerId': screenerId,
      'accessLinkToken': accessLinkToken,
      'accessPointKey': accessPointKey,
      'promptKey': promptKey,
      'patient': patient.toJson(),
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }

  SurveyResponse copyWith({
    String? id,
    String? surveyId,
    String? creatorId,
    DateTime? testDate,
    String? screenerId,
    String? accessLinkToken,
    String? accessPointKey,
    String? promptKey,
    Patient? patient,
    List<shared.Answer>? answers,
    AgentResponse? agentResponse,
    List<AgentResponse>? agentResponses,
  }) {
    return SurveyResponse(
      id: id ?? this.id,
      surveyId: surveyId ?? this.surveyId,
      creatorId: creatorId ?? this.creatorId,
      testDate: testDate ?? this.testDate,
      screenerId: screenerId ?? this.screenerId,
      accessLinkToken: accessLinkToken ?? this.accessLinkToken,
      accessPointKey: accessPointKey ?? this.accessPointKey,
      promptKey: promptKey ?? this.promptKey,
      patient: patient ?? this.patient,
      answers: answers ?? this.answers,
      agentResponse: agentResponse ?? this.agentResponse,
      agentResponses: agentResponses ?? this.agentResponses,
    );
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
