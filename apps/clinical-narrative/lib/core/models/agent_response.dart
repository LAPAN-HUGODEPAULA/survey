import 'package:design_system_flutter/report/report_models.dart';

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
  });

  final bool? ok;
  final String? inputType;
  final String? promptVersion;
  final String? modelVersion;
  final ReportDocument? report;
  final List<String> warnings;
  final String? classification;
  final String? medicalRecord;
  final String? errorMessage;

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
    );
  }
}
