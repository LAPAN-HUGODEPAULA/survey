class SurveyPromptDraft {
  SurveyPromptDraft({
    required this.promptKey,
    required this.name,
    required this.promptText,
    this.createdAt,
    this.modifiedAt,
  });

  String promptKey;
  String name;
  String promptText;
  DateTime? createdAt;
  DateTime? modifiedAt;

  SurveyPromptDraft copy() {
    return SurveyPromptDraft(
      promptKey: promptKey,
      name: name,
      promptText: promptText,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
    );
  }
}

class SurveyPromptReferenceDraft {
  SurveyPromptReferenceDraft({required this.promptKey, required this.name});

  String promptKey;
  String name;

  SurveyPromptReferenceDraft copy() {
    return SurveyPromptReferenceDraft(promptKey: promptKey, name: name);
  }
}
