class AIAgentRouteRefDraft {
  AIAgentRouteRefDraft({
    required this.agentKey,
    this.model,
    this.temperature,
    this.maxTokens,
    this.enabled = true,
  });

  final String agentKey;
  final String? model;
  final double? temperature;
  final int? maxTokens;
  final bool enabled;

  AIAgentRouteRefDraft copy() {
    return AIAgentRouteRefDraft(
      agentKey: agentKey,
      model: model,
      temperature: temperature,
      maxTokens: maxTokens,
      enabled: enabled,
    );
  }
}

class AIConfigDraft {
  AIConfigDraft({
    required this.primaryProvider,
    required this.primaryModel,
    this.fallbackProvider,
    this.fallbackModel,
    this.agentRefs = const <AIAgentRouteRefDraft>[],
    this.temperature = 0.0,
    this.reasoningEffort = 'low',
    this.enableCaching = true,
  });

  final String primaryProvider;
  final String primaryModel;
  final String? fallbackProvider;
  final String? fallbackModel;
  final List<AIAgentRouteRefDraft> agentRefs;
  final double temperature;
  final String? reasoningEffort;
  final bool enableCaching;

  AIConfigDraft copy() {
    return AIConfigDraft(
      primaryProvider: primaryProvider,
      primaryModel: primaryModel,
      fallbackProvider: fallbackProvider,
      fallbackModel: fallbackModel,
      agentRefs: agentRefs.map((item) => item.copy()).toList(growable: false),
      temperature: temperature,
      reasoningEffort: reasoningEffort,
      enableCaching: enableCaching,
    );
  }
}

class AgentAccessPointDraft {
  AgentAccessPointDraft({
    required this.accessPointKey,
    required this.name,
    required this.sourceApp,
    required this.flowKey,
    required this.promptKey,
    required this.personaSkillKey,
    required this.outputProfile,
    this.aiConfig,
    this.systemPromptOverride,
    this.formatPromptOverride,
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
  final AIConfigDraft? aiConfig;
  final String? systemPromptOverride;
  final String? formatPromptOverride;
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
      aiConfig: aiConfig?.copy(),
      systemPromptOverride: systemPromptOverride,
      formatPromptOverride: formatPromptOverride,
      surveyId: surveyId,
      description: description,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
    );
  }
}
