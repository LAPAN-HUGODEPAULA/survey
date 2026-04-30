class AgentAccessPointDraft {
  AgentAccessPointDraft({
    required this.accessPointKey,
    required this.name,
    required this.sourceApp,
    required this.flowKey,
    required this.promptKey,
    required this.personaSkillKey,
    required this.outputProfile,
    this.aiProvider,
    this.glmModel,
    this.geminiModel,
    this.surveyId,
    this.description,
    this.createdAt,
    this.modifiedAt,
  });

  final String accessPointKey;
  final String name;
  final String sourceApp;
  final String flowKey;
  final String promptKey;
  final String personaSkillKey;
  final String outputProfile;
  final String? aiProvider;
  final String? glmModel;
  final String? geminiModel;
  final String? surveyId;
  final String? description;
  final DateTime? createdAt;
  final DateTime? modifiedAt;

  AgentAccessPointDraft copy() {
    return AgentAccessPointDraft(
      accessPointKey: accessPointKey,
      name: name,
      sourceApp: sourceApp,
      flowKey: flowKey,
      promptKey: promptKey,
      personaSkillKey: personaSkillKey,
      outputProfile: outputProfile,
      aiProvider: aiProvider,
      glmModel: glmModel,
      geminiModel: geminiModel,
      surveyId: surveyId,
      description: description,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
    );
  }
}
