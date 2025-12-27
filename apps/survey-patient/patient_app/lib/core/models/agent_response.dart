class AgentResponse {
  const AgentResponse({
    this.classification,
    this.medicalRecord,
    this.errorMessage,
  });

  final String? classification;
  final String? medicalRecord;
  final String? errorMessage;

  factory AgentResponse.fromJson(Map<String, dynamic> json) {
    return AgentResponse(
      classification: json['classification']?.toString(),
      medicalRecord: json['medicalRecord']?.toString() ?? json['medical_record']?.toString(),
      errorMessage: json['errorMessage']?.toString() ?? json['error_message']?.toString(),
    );
  }
}
