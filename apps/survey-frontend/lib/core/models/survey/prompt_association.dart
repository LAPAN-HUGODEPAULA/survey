class SurveyPromptReference {
  const SurveyPromptReference({
    required this.promptKey,
    required this.name,
  });

  factory SurveyPromptReference.fromJson(Map<String, dynamic> json) {
    return SurveyPromptReference(
      promptKey: json['promptKey']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  final String promptKey;
  final String name;
}
