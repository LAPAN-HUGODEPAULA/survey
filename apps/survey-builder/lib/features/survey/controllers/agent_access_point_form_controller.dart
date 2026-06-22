import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:runtime_agent_access_points/runtime_agent_access_points.dart';
import 'package:survey_builder/core/models/agent_access_point_draft.dart';
import 'package:survey_builder/core/models/ai_agent_draft.dart';
import 'package:survey_builder/core/models/persona_skill_draft.dart';
import 'package:survey_builder/core/models/survey_draft.dart';
import 'package:survey_builder/core/models/survey_prompt_draft.dart';
import 'package:survey_builder/core/repositories/agent_access_point_repository.dart';
import 'package:survey_builder/core/repositories/ai_agent_repository.dart';
import 'package:survey_builder/core/repositories/persona_skill_repository.dart';
import 'package:survey_builder/core/repositories/survey_prompt_repository.dart';
import 'package:survey_builder/core/repositories/survey_repository.dart';
import 'package:survey_builder/features/survey/controllers/authoring_form_controller.dart';
import 'package:survey_builder/features/survey/validators/survey_authoring_validators.dart';

class AgentAccessPointFormController extends AuthoringFormController {
  AgentAccessPointFormController({
    AgentAccessPointDraft? initialDraft,
    AgentAccessPointRepository? repository,
  }) : _repository = repository ?? AgentAccessPointRepository(),
       _isEditing = initialDraft != null {
    final draft =
        initialDraft ??
        AgentAccessPointDraft(
          accessPointKey: '',
          name: '',
          sourceApp: 'survey-patient',
          flowKey: 'thank_you.auto_analysis',
          promptKey: '',
          personaSkillKey: '',
          outputProfile: '',
        );

    nameController = TextEditingController(text: draft.name)
      ..addListener(_handleMutation);
    keyController = TextEditingController(text: draft.accessPointKey)
      ..addListener(_handleMutation);
    flowKeyController = TextEditingController(text: draft.flowKey)
      ..addListener(_handleMutation);
    descriptionController = TextEditingController(text: draft.description ?? '')
      ..addListener(_handleMutation);
    primaryModelController = TextEditingController(
      text: draft.aiConfig?.primaryModel ?? '',
    )..addListener(_handleMutation);
    fallbackModelController = TextEditingController(
      text: draft.aiConfig?.fallbackModel ?? '',
    )..addListener(_handleMutation);
    systemPromptController = TextEditingController(
      text: draft.systemPromptOverride ?? '',
    )..addListener(_handleMutation);

    sourceApp = draft.sourceApp;
    primaryProvider = draft.aiConfig?.primaryProvider ?? 'glm';
    fallbackProvider =
        draft.aiConfig?.fallbackProvider ??
        (draft.aiConfig == null ? 'gemini' : null);
    temperature = draft.aiConfig?.temperature ?? 0.0;
    reasoningEffort = draft.aiConfig?.reasoningEffort ?? 'low';
    enableCaching = draft.aiConfig?.enableCaching ?? true;

    final configuredPoint = RuntimeAccessPointCatalog.byKey(
      draft.accessPointKey,
    );
    selectedInjectionPointKey = configuredPoint?.isConfigurable == true
        ? configuredPoint!.accessPointKey
        : null;

    surveyId = draft.surveyId;
    promptKey = draft.promptKey.isEmpty ? null : draft.promptKey;
    personaSkillKey = draft.personaSkillKey.isEmpty
        ? null
        : draft.personaSkillKey;
  }

  static const List<(String, String)> localPromptOptions = [
    ('default', 'Prompt local padrão'),
    ('consult', 'Prompt local de consulta'),
    ('survey7', 'Prompt local estruturado survey7'),
    ('full_intake', 'Prompt local de intake completo'),
  ];

  final AgentAccessPointRepository _repository;
  final bool _isEditing;

  late final TextEditingController nameController;
  late final TextEditingController keyController;
  late final TextEditingController flowKeyController;
  late final TextEditingController descriptionController;
  late final TextEditingController primaryModelController;
  late final TextEditingController fallbackModelController;
  late final TextEditingController systemPromptController;

  String? selectedInjectionPointKey;
  String sourceApp = 'survey-patient';
  String primaryProvider = 'glm';
  String? fallbackProvider = 'gemini';
  bool useGlobalAiSettings = false;
  double temperature = 0.0;
  String reasoningEffort = 'low';
  bool enableCaching = true;
  String? surveyId;
  String? promptKey;
  String? personaSkillKey;
  bool loadingCatalogs = true;
  String? promptSelectionError;
  String? personaSelectionError;
  List<SurveyDraft> surveys = <SurveyDraft>[];
  List<SurveyPromptDraft> prompts = <SurveyPromptDraft>[];
  List<PersonaSkillDraft> personas = <PersonaSkillDraft>[];
  List<AIAgentDraft> aiAgents = <AIAgentDraft>[];

  bool get isEditing => _isEditing;
  RuntimeAccessPointDescriptor? get selectedInjectionPoint =>
      RuntimeAccessPointCatalog.byKey(selectedInjectionPointKey);

  Future<void> loadCatalogs() async {
    loadingCatalogs = true;
    clearFeedback();
    notifyListeners();
    try {
      final surveyRepository = SurveyRepository();
      final promptRepository = SurveyPromptRepository();
      final personaRepository = PersonaSkillRepository();
      final aiAgentRepository = AIAgentRepository();
      final loadedSurveys = await surveyRepository.listSurveys();
      final loadedPrompts = await promptRepository.listPrompts();
      final loadedPersonas = await personaRepository.listPersonaSkills();
      final loadedAgents = await aiAgentRepository.listAgents();
      surveyRepository.dispose();
      promptRepository.dispose();
      personaRepository.dispose();
      aiAgentRepository.dispose();

      surveys = loadedSurveys;
      prompts = loadedPrompts;
      personas = loadedPersonas;
      aiAgents = loadedAgents
          .where((agent) => agent.enabled)
          .toList(growable: false);
      if (!_isEditing) {
        _applyDefaultAgents();
      }
      loadingCatalogs = false;
      notifyListeners();
    } catch (error) {
      loadingCatalogs = false;
      setFeedback(
        DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Falha ao carregar catálogos',
          message: 'Falha ao carregar dependências do formulário: $error',
        ),
      );
    }
  }

  void handleInjectionPointChanged(String? accessPointKey) {
    final previous = selectedInjectionPoint;
    final selected = RuntimeAccessPointCatalog.byKey(accessPointKey);
    final next = selected?.isConfigurable == true ? selected : null;

    if (next != null) {
      final currentName = nameController.text.trim();
      final currentDescription = descriptionController.text.trim();
      final shouldReplaceName =
          currentName.isEmpty || currentName == previous?.name;
      final shouldReplaceDescription =
          currentDescription.isEmpty ||
          currentDescription == previous?.description;

      keyController.text = next.accessPointKey;
      flowKeyController.text = next.flowKey;
      sourceApp = next.sourceApp;
      if (shouldReplaceName) {
        nameController.text = next.name;
      }
      if (shouldReplaceDescription) {
        descriptionController.text = next.description;
      }
    }

    selectedInjectionPointKey = next?.accessPointKey;
    markDirty();
    notifyListeners();
  }

  void setSourceApp(String value) {
    sourceApp = value;
    markDirty();
    notifyListeners();
  }

  void setSurveyId(String? value) {
    surveyId = value;
    if (value == null) {
      promptKey ??= localPromptOptions.first.$1;
      if (personaSkillKey == null && personas.isNotEmpty) {
        personaSkillKey = personas.first.personaSkillKey;
      }
    }
    markDirty();
    notifyListeners();
  }

  void setPromptKey(String? value) {
    promptKey = value;
    promptSelectionError = null;
    markDirty();
    notifyListeners();
  }

  void setPersonaSkillKey(String? value) {
    personaSkillKey = value;
    personaSelectionError = null;
    markDirty();
    notifyListeners();
  }

  void setPrimaryProvider(String value) {
    primaryProvider = value;
    final agent = findAgent(value);
    if (agent != null && primaryModelController.text.trim().isEmpty) {
      primaryModelController.text = agent.defaultModel;
    }
    markDirty();
    notifyListeners();
  }

  void setFallbackProvider(String? value) {
    fallbackProvider = value;
    final agent = findAgent(value);
    if (agent != null && fallbackModelController.text.trim().isEmpty) {
      fallbackModelController.text = agent.defaultModel;
    }
    markDirty();
    notifyListeners();
  }

  void setTemperature(double value) {
    temperature = value;
    markDirty();
    notifyListeners();
  }

  void setReasoningEffort(String value) {
    reasoningEffort = value;
    markDirty();
    notifyListeners();
  }

  void setEnableCaching(bool value) {
    enableCaching = value;
    markDirty();
    notifyListeners();
  }

  List<DsValidationSummaryItem> buildValidationItems({
    required GlobalKey routingSectionKey,
    required GlobalKey assignmentSectionKey,
  }) {
    final items = <DsValidationSummaryItem>[];

    void addItem(String label, String? message, GlobalKey targetKey) {
      if (message == null || message.isEmpty) {
        return;
      }
      items.add(
        DsValidationSummaryItem(
          label: label,
          message: message,
          onTap: () {
            final context = targetKey.currentContext;
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
      'Nome do ponto de acesso',
      SurveyAuthoringValidators.required(nameController.text),
      routingSectionKey,
    );
    addItem(
      'Chave estável',
      validateAccessPointKey(keyController.text),
      routingSectionKey,
    );
    addItem(
      'Fluxo de runtime',
      validateAccessPointKey(flowKeyController.text),
      routingSectionKey,
    );
    addItem(
      'Prompt',
      (promptKey == null && surveyId == null)
          ? 'Selecione um prompt ou associe um questionário para herança.'
          : null,
      assignmentSectionKey,
    );
    addItem(
      'Persona',
      (personaSkillKey == null && surveyId == null)
          ? 'Selecione uma persona ou associe um questionário para herança.'
          : null,
      assignmentSectionKey,
    );
    return items;
  }

  String? validateAccessPointKey(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'Campo obrigatório';
    }
    final pattern = RegExp(r'^[a-z0-9.:_-]+$');
    if (!pattern.hasMatch(normalized)) {
      return 'Use letras, números, "." , ":" , "_" ou "-".';
    }
    return null;
  }

  Future<bool> save({
    required FormState? formState,
    required List<DsValidationSummaryItem> validationItems,
  }) async {
    markSubmitted();
    if (formState == null ||
        !formState.validate() ||
        validationItems.isNotEmpty) {
      promptSelectionError = promptKey == null
          ? 'Selecione um prompt válido.'
          : null;
      personaSelectionError = personaSkillKey == null
          ? 'Selecione uma persona válida.'
          : null;
      notifyListeners();
      return false;
    }

    final draft = buildDraft();
    setSaving(true);
    try {
      var shouldUpdate = _isEditing;
      if (!shouldUpdate) {
        final existing = await _repository.getAccessPointByKey(
          draft.accessPointKey,
        );
        shouldUpdate = existing != null;
      }

      if (shouldUpdate) {
        await _repository.updateAccessPoint(draft);
      } else {
        try {
          await _repository.createAccessPoint(draft);
        } on AgentAccessPointConflictException {
          await _repository.updateAccessPoint(draft);
        }
      }
      clearDirty();
      return true;
    } on Exception catch (error) {
      setFeedback(
        DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Falha ao salvar ponto de acesso',
          message: 'Falha ao salvar ponto de acesso: $error',
        ),
      );
      return false;
    } finally {
      setSaving(false);
    }
  }

  AgentAccessPointDraft buildDraft() {
    PersonaSkillDraft? persona;
    for (final item in personas) {
      if (item.personaSkillKey == personaSkillKey) {
        persona = item;
        break;
      }
    }
    final primaryModel = primaryModelController.text.trim();
    final fallbackModel = fallbackModelController.text.trim();
    final agentRefs = <AIAgentRouteRefDraft>[
      AIAgentRouteRefDraft(
        agentKey: primaryProvider,
        model: primaryModel.isEmpty ? null : primaryModel,
        temperature: temperature,
        enabled: true,
      ),
      if (fallbackProvider != null)
        AIAgentRouteRefDraft(
          agentKey: fallbackProvider!,
          model: fallbackModel.isEmpty ? null : fallbackModel,
          temperature: temperature,
          enabled: true,
        ),
    ];
    return AgentAccessPointDraft(
      accessPointKey: keyController.text.trim().toLowerCase(),
      name: nameController.text.trim(),
      sourceApp: sourceApp,
      flowKey: flowKeyController.text.trim().toLowerCase(),
      promptKey: promptKey ?? '',
      personaSkillKey: personaSkillKey ?? '',
      outputProfile: persona?.outputProfile ?? '',
      aiConfig: useGlobalAiSettings
          ? null
          : AIConfigDraft(
              primaryProvider: primaryProvider,
              primaryModel: primaryModel,
              fallbackProvider: fallbackProvider,
              fallbackModel: fallbackModel.isEmpty ? null : fallbackModel,
              agentRefs: agentRefs,
              temperature: temperature,
              reasoningEffort: reasoningEffort,
              enableCaching: enableCaching,
            ),
      systemPromptOverride: systemPromptController.text.trim().isEmpty
          ? null
          : systemPromptController.text.trim(),
      surveyId: surveyId,
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
    );
  }

  AIAgentDraft? findAgent(String? agentKey) {
    if (agentKey == null || agentKey.isEmpty) {
      return null;
    }
    for (final agent in aiAgents) {
      if (agent.agentKey == agentKey) {
        return agent;
      }
    }
    return null;
  }

  List<DropdownMenuItem<String>> agentMenuItems({String? currentValue}) {
    final items = aiAgents
        .map(
          (agent) => DropdownMenuItem<String>(
            value: agent.agentKey,
            child: Text('${agent.name} (${agent.defaultModel})'),
          ),
        )
        .toList(growable: true);
    if (currentValue != null &&
        currentValue.isNotEmpty &&
        !items.any((item) => item.value == currentValue)) {
      items.add(
        DropdownMenuItem<String>(
          value: currentValue,
          child: Text(currentValue),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<String?>> fallbackAgentMenuItems() {
    final items = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(value: null, child: Text('Nenhum')),
    ];
    for (final agent in aiAgents) {
      items.add(
        DropdownMenuItem<String?>(
          value: agent.agentKey,
          child: Text('${agent.name} (${agent.defaultModel})'),
        ),
      );
    }
    final currentValue = fallbackProvider;
    if (currentValue != null &&
        currentValue.isNotEmpty &&
        !items.any((item) => item.value == currentValue)) {
      items.add(
        DropdownMenuItem<String?>(
          value: currentValue,
          child: Text(currentValue),
        ),
      );
    }
    return items;
  }

  void _handleMutation() {
    _clearSelectionErrors();
    markDirty();
  }

  void _clearSelectionErrors() {
    if (promptSelectionError == null && personaSelectionError == null) {
      return;
    }
    promptSelectionError = null;
    personaSelectionError = null;
    notifyListeners();
  }

  void _applyDefaultAgents() {
    final localQwen = findAgent('local_qwen');
    if (localQwen != null) {
      primaryProvider = localQwen.agentKey;
      if (primaryModelController.text.trim().isEmpty) {
        primaryModelController.text = localQwen.defaultModel;
      }
    }
    final gemini = findAgent('gemini');
    if (gemini != null) {
      fallbackProvider = gemini.agentKey;
      if (fallbackModelController.text.trim().isEmpty) {
        fallbackModelController.text = gemini.defaultModel;
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    keyController.dispose();
    flowKeyController.dispose();
    descriptionController.dispose();
    primaryModelController.dispose();
    fallbackModelController.dispose();
    systemPromptController.dispose();
    _repository.dispose();
    super.dispose();
  }
}
