import 'package:design_system_flutter/report/report_models.dart';

class AIProgress {
  const AIProgress({
    required this.stage,
    this.stageLabel,
    this.percent = 0,
    this.status = 'processing',
    this.severity = 'info',
    this.retryable = false,
    this.userMessage,
    this.updatedAt,
  });

  factory AIProgress.fromJson(Map<String, dynamic> json) {
    return AIProgress(
      stage: json['stage']?.toString() ?? 'organizing_data',
      stageLabel:
          json['stageLabel']?.toString() ?? json['stage_label']?.toString(),
      percent: (json['percent'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'processing',
      severity: json['severity']?.toString() ?? 'info',
      retryable: json['retryable'] as bool? ?? false,
      userMessage:
          json['userMessage']?.toString() ?? json['user_message']?.toString(),
      updatedAt:
          json['updatedAt']?.toString() ?? json['updated_at']?.toString(),
    );
  }

  final String stage;
  final String? stageLabel;
  final int percent;
  final String status;
  final String severity;
  final bool retryable;
  final String? userMessage;
  final String? updatedAt;
}

class AgentResponse {
  const AgentResponse({
    this.ok,
    this.inputType,
    this.promptVersion,
    this.modelVersion,
    this.report,
    this.warnings = const [],
    this.classification,
    this.medicalRecord,
    this.errorMessage,
    this.aiProgress,
  });

  factory AgentResponse.fromJson(Map<String, dynamic> json) {
    final reportJson = json['report'];
    final warningsRaw = json['warnings'] as List<dynamic>? ?? const <dynamic>[];
    final medicalRecord =
        json['medicalRecord']?.toString() ?? json['medical_record']?.toString();

    return AgentResponse(
      ok: json['ok'] as bool?,
      inputType: json['input_type']?.toString(),
      promptVersion: json['prompt_version']?.toString(),
      modelVersion: json['model_version']?.toString(),
      report: reportJson is Map<String, dynamic>
          ? ReportDocument.fromJson(reportJson)
          : null,
      warnings: warningsRaw.map((item) => item.toString()).toList(),
      classification: json['classification']?.toString(),
      medicalRecord: medicalRecord,
      errorMessage:
          json['errorMessage']?.toString() ?? json['error_message']?.toString(),
      aiProgress: json['aiProgress'] is Map<String, dynamic>
          ? AIProgress.fromJson(json['aiProgress'] as Map<String, dynamic>)
          : json['ai_progress'] is Map<String, dynamic>
          ? AIProgress.fromJson(json['ai_progress'] as Map<String, dynamic>)
          : null,
    );
  }

  final bool? ok;
  final String? inputType;
  final String? promptVersion;
  final String? modelVersion;
  final ReportDocument? report;
  final List<String> warnings;
  final String? classification;
  final String? medicalRecord;
  final String? errorMessage;
  final AIProgress? aiProgress;
}
