class AIAgentDraft {
  AIAgentDraft({
    required this.agentKey,
    required this.name,
    required this.providerType,
    this.baseUrl,
    this.apiKeyEnvVar,
    required this.defaultModel,
    this.enabled = true,
    this.supportsOpenAIChatCompletions = false,
    this.supportsResponseFormat = false,
    this.supportsRag = false,
    this.notes,
  });

  final String agentKey;
  final String name;
  final String providerType;
  final String? baseUrl;
  final String? apiKeyEnvVar;
  final String defaultModel;
  final bool enabled;
  final bool supportsOpenAIChatCompletions;
  final bool supportsResponseFormat;
  final bool supportsRag;
  final String? notes;

  AIAgentDraft copy() {
    return AIAgentDraft(
      agentKey: agentKey,
      name: name,
      providerType: providerType,
      baseUrl: baseUrl,
      apiKeyEnvVar: apiKeyEnvVar,
      defaultModel: defaultModel,
      enabled: enabled,
      supportsOpenAIChatCompletions: supportsOpenAIChatCompletions,
      supportsResponseFormat: supportsResponseFormat,
      supportsRag: supportsRag,
      notes: notes,
    );
  }
}
