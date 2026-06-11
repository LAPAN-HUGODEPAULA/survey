import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/models/ai_agent_draft.dart';
import 'package:survey_builder/core/repositories/ai_agent_repository.dart';
import 'package:survey_builder/features/survey/controllers/authoring_form_controller.dart';
import 'package:survey_builder/features/survey/validators/survey_authoring_validators.dart';

class AIAgentFormController extends AuthoringFormController {
  AIAgentFormController({
    AIAgentDraft? initialDraft,
    AIAgentRepository? repository,
  }) : _repository = repository ?? AIAgentRepository(),
       _isEditing = initialDraft != null {
    final draft =
        initialDraft ??
        AIAgentDraft(
          agentKey: '',
          name: '',
          providerType: 'openai_compatible',
          baseUrl: '',
          apiKeyEnvVar: 'AI_API_KEY',
          defaultModel: '',
          enabled: true,
          supportsOpenAIChatCompletions: true,
        );

    agentKeyController = TextEditingController(text: draft.agentKey)
      ..addListener(markDirty);
    nameController = TextEditingController(text: draft.name)
      ..addListener(markDirty);
    baseUrlController = TextEditingController(text: draft.baseUrl ?? '')
      ..addListener(markDirty);
    apiKeyEnvVarController = TextEditingController(
      text: draft.apiKeyEnvVar ?? 'AI_API_KEY',
    )..addListener(markDirty);
    defaultModelController = TextEditingController(text: draft.defaultModel)
      ..addListener(markDirty);
    notesController = TextEditingController(text: draft.notes ?? '')
      ..addListener(markDirty);
    providerType = draft.providerType.isEmpty
        ? 'openai_compatible'
        : draft.providerType;
    enabled = draft.enabled;
    supportsOpenAIChatCompletions = draft.supportsOpenAIChatCompletions;
    supportsResponseFormat = draft.supportsResponseFormat;
    supportsRag = draft.supportsRag;
  }

  final AIAgentRepository _repository;
  final bool _isEditing;

  late final TextEditingController agentKeyController;
  late final TextEditingController nameController;
  late final TextEditingController baseUrlController;
  late final TextEditingController apiKeyEnvVarController;
  late final TextEditingController defaultModelController;
  late final TextEditingController notesController;

  String providerType = 'openai_compatible';
  bool enabled = true;
  bool supportsOpenAIChatCompletions = true;
  bool supportsResponseFormat = false;
  bool supportsRag = false;

  bool get isEditing => _isEditing;

  void setProviderType(String value) {
    providerType = value;
    supportsOpenAIChatCompletions =
        value == 'openai_compatible' || supportsOpenAIChatCompletions;
    markDirty();
    notifyListeners();
  }

  void setEnabled(bool value) {
    enabled = value;
    markDirty();
    notifyListeners();
  }

  void setSupportsOpenAIChatCompletions(bool value) {
    supportsOpenAIChatCompletions = value;
    markDirty();
    notifyListeners();
  }

  void setSupportsResponseFormat(bool value) {
    supportsResponseFormat = value;
    markDirty();
    notifyListeners();
  }

  void setSupportsRag(bool value) {
    supportsRag = value;
    markDirty();
    notifyListeners();
  }

  AIAgentDraft buildDraft() {
    return AIAgentDraft(
      agentKey: SurveyAuthoringValidators.normalizeKey(agentKeyController.text),
      name: SurveyAuthoringValidators.normalizeText(nameController.text),
      providerType: providerType,
      baseUrl: SurveyAuthoringValidators.normalizeText(baseUrlController.text),
      apiKeyEnvVar: apiKeyEnvVarController.text.trim(),
      defaultModel: SurveyAuthoringValidators.normalizeText(
        defaultModelController.text,
      ),
      enabled: enabled,
      supportsOpenAIChatCompletions: supportsOpenAIChatCompletions,
      supportsResponseFormat: supportsResponseFormat,
      supportsRag: supportsRag,
      notes: SurveyAuthoringValidators.normalizeText(notesController.text),
    );
  }

  List<DsValidationSummaryItem> buildValidationItems({
    required GlobalKey detailsSectionKey,
  }) {
    final items = <DsValidationSummaryItem>[];
    void addItem(String label, String? message) {
      if (message == null || message.isEmpty) {
        return;
      }
      items.add(
        DsValidationSummaryItem(
          label: label,
          message: message,
          onTap: () {
            final context = detailsSectionKey.currentContext;
            if (context == null) {
              return;
            }
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: 0.1,
            );
          },
        ),
      );
    }

    addItem(
      'Chave do agente',
      SurveyAuthoringValidators.required(agentKeyController.text),
    );
    addItem('Nome', SurveyAuthoringValidators.required(nameController.text));
    addItem(
      'Modelo padrão',
      SurveyAuthoringValidators.required(defaultModelController.text),
    );
    addItem(
      'Variável de API key',
      SurveyAuthoringValidators.required(apiKeyEnvVarController.text),
    );
    if (providerType == 'openai_compatible') {
      addItem(
        'Base URL',
        SurveyAuthoringValidators.required(baseUrlController.text),
      );
    }
    return items;
  }

  Future<bool> save({
    required FormState? formState,
    required List<DsValidationSummaryItem> validationItems,
  }) async {
    markSubmitted();
    if (formState == null ||
        !formState.validate() ||
        validationItems.isNotEmpty) {
      return false;
    }

    setSaving(true);
    try {
      final draft = buildDraft();
      if (_isEditing) {
        await _repository.updateAgent(draft);
      } else {
        await _repository.createAgent(draft);
      }
      clearDirty();
      return true;
    } on AIAgentConflictException catch (error) {
      setFeedback(
        DsFeedbackMessage(
          severity: DsStatusType.warning,
          title: 'Conflito de agente',
          message: error.toString(),
        ),
      );
      return false;
    } on Exception catch (error) {
      setFeedback(
        DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Falha ao salvar agente de IA',
          message: 'Falha ao salvar agente de IA: $error',
        ),
      );
      return false;
    } finally {
      setSaving(false);
    }
  }

  @override
  void dispose() {
    agentKeyController.dispose();
    nameController.dispose();
    baseUrlController.dispose();
    apiKeyEnvVarController.dispose();
    defaultModelController.dispose();
    notesController.dispose();
    _repository.dispose();
    super.dispose();
  }
}
