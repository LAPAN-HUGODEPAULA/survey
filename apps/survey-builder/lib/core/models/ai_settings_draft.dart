class GlobalAIConfigDraft {
  GlobalAIConfigDraft({
    this.primaryProvider = 'glm',
    this.primaryModel = '',
    this.fallbackProvider,
    this.fallbackModel,
    this.temperature = 0.0,
    this.reasoningEffort = 'low',
    this.enableCaching = true,
  });

  final String primaryProvider;
  final String primaryModel;
  final String? fallbackProvider;
  final String? fallbackModel;
  final double temperature;
  final String reasoningEffort;
  final bool enableCaching;

  GlobalAIConfigDraft copy() {
    return GlobalAIConfigDraft(
      primaryProvider: primaryProvider,
      primaryModel: primaryModel,
      fallbackProvider: fallbackProvider,
      fallbackModel: fallbackModel,
      temperature: temperature,
      reasoningEffort: reasoningEffort,
      enableCaching: enableCaching,
    );
  }
}
