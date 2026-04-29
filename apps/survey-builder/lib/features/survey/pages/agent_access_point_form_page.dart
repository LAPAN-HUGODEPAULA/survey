import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:runtime_agent_access_points/runtime_agent_access_points.dart';
import 'package:survey_builder/core/models/agent_access_point_draft.dart';
import 'package:survey_builder/core/models/persona_skill_draft.dart';
import 'package:survey_builder/core/models/survey_draft.dart';
import 'package:survey_builder/core/models/survey_prompt_draft.dart';
import 'package:survey_builder/core/repositories/agent_access_point_repository.dart';
import 'package:survey_builder/core/repositories/persona_skill_repository.dart';
import 'package:survey_builder/core/repositories/survey_prompt_repository.dart';
import 'package:survey_builder/core/repositories/survey_repository.dart';

class AgentAccessPointFormPage extends StatefulWidget {
  const AgentAccessPointFormPage({
    super.key,
    this.initialDraft,
    this.repository,
  });

  final AgentAccessPointDraft? initialDraft;
  final AgentAccessPointRepository? repository;

  @override
  State<AgentAccessPointFormPage> createState() =>
      _AgentAccessPointFormPageState();
}

class _AgentAccessPointFormPageState extends State<AgentAccessPointFormPage> {
  static const String _routingSectionId = 'routing';
  static const String _assignmentSectionId = 'assignment';
  static const List<(String, String)> _localPromptOptions = [
    ('default', 'Prompt local padrão'),
    ('consult', 'Prompt local de consulta'),
    ('survey7', 'Prompt local estruturado survey7'),
    ('full_intake', 'Prompt local de intake completo'),
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _routingSectionKey = GlobalKey();
  final GlobalKey _assignmentSectionKey = GlobalKey();
  late final AgentAccessPointRepository _repository;
  late final bool _isEditing;
  late final TextEditingController _nameController;
  late final TextEditingController _keyController;
  late final TextEditingController _flowKeyController;
  late final TextEditingController _descriptionController;
  String? _selectedInjectionPointKey;
  String _sourceApp = 'survey-patient';
  String? _surveyId;
  String? _promptKey;
  String? _personaSkillKey;
  bool _loadingCatalogs = true;
  bool _saving = false;
  bool _isDirty = false;
  bool _hasSubmitted = false;
  String _currentSectionId = _routingSectionId;
  String? _promptSelectionError;
  String? _personaSelectionError;
  DsFeedbackMessage? _feedback;
  List<SurveyDraft> _surveys = <SurveyDraft>[];
  List<SurveyPromptDraft> _prompts = <SurveyPromptDraft>[];
  List<PersonaSkillDraft> _personas = <PersonaSkillDraft>[];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? AgentAccessPointRepository();
    _isEditing = widget.initialDraft != null;
    final draft =
        widget.initialDraft ??
        AgentAccessPointDraft(
          accessPointKey: '',
          name: '',
          sourceApp: 'survey-patient',
          flowKey: 'thank_you.auto_analysis',
          promptKey: '',
          personaSkillKey: '',
          outputProfile: '',
        );
    _nameController = TextEditingController(text: draft.name)
      ..addListener(_handleMutation);
    _keyController = TextEditingController(text: draft.accessPointKey)
      ..addListener(_handleMutation);
    _flowKeyController = TextEditingController(text: draft.flowKey)
      ..addListener(_handleMutation);
    _descriptionController = TextEditingController(
      text: draft.description ?? '',
    )..addListener(_handleMutation);
    final configuredPoint = RuntimeAccessPointCatalog.byKey(
      draft.accessPointKey,
    );
    _selectedInjectionPointKey = configuredPoint?.isConfigurable == true
        ? configuredPoint!.accessPointKey
        : null;
    _sourceApp = draft.sourceApp;
    _surveyId = draft.surveyId;
    _promptKey = draft.promptKey.isEmpty ? null : draft.promptKey;
    _personaSkillKey = draft.personaSkillKey.isEmpty
        ? null
        : draft.personaSkillKey;
    _scrollController.addListener(_handleSectionScroll);
    _loadCatalogs();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleSectionScroll);
    _scrollController.dispose();
    _nameController.dispose();
    _keyController.dispose();
    _flowKeyController.dispose();
    _descriptionController.dispose();
    _repository.dispose();
    super.dispose();
  }

  void _handleMutation() {
    _clearSelectionErrors();
    if (!_isDirty) {
      setState(() => _isDirty = true);
    }
  }

  void _handleSectionScroll() {
    final activationOffset = 180.0;
    var nextSectionId = _routingSectionId;
    final assignmentBox =
        _assignmentSectionKey.currentContext?.findRenderObject() as RenderBox?;
    if (assignmentBox != null) {
      final top = assignmentBox.localToGlobal(Offset.zero).dy;
      if (top <= activationOffset) {
        nextSectionId = _assignmentSectionId;
      }
    }
    if (nextSectionId != _currentSectionId && mounted) {
      setState(() => _currentSectionId = nextSectionId);
    }
  }

  void _jumpToSection(String sectionId) {
    final targetKey = sectionId == _routingSectionId
        ? _routingSectionKey
        : _assignmentSectionKey;
    final context = targetKey.currentContext;
    if (context != null) {
      setState(() => _currentSectionId = sectionId);
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  void _clearSelectionErrors() {
    if (_promptSelectionError == null && _personaSelectionError == null) {
      return;
    }
    setState(() {
      _promptSelectionError = null;
      _personaSelectionError = null;
    });
  }

  RuntimeAccessPointDescriptor? get _selectedInjectionPoint =>
      RuntimeAccessPointCatalog.byKey(_selectedInjectionPointKey);

  void _handleInjectionPointChanged(String? accessPointKey) {
    final previous = _selectedInjectionPoint;
    final selected = RuntimeAccessPointCatalog.byKey(accessPointKey);
    final next = selected?.isConfigurable == true ? selected : null;

    if (next != null) {
      final currentName = _nameController.text.trim();
      final currentDescription = _descriptionController.text.trim();
      final shouldReplaceName =
          currentName.isEmpty || currentName == previous?.name;
      final shouldReplaceDescription =
          currentDescription.isEmpty ||
          currentDescription == previous?.description;

      _keyController.text = next.accessPointKey;
      _flowKeyController.text = next.flowKey;
      _sourceApp = next.sourceApp;
      if (shouldReplaceName) {
        _nameController.text = next.name;
      }
      if (shouldReplaceDescription) {
        _descriptionController.text = next.description;
      }
    }

    setState(() {
      _selectedInjectionPointKey = next?.accessPointKey;
      _isDirty = true;
    });
  }

  List<DsValidationSummaryItem> _buildValidationItems() {
    final items = <DsValidationSummaryItem>[];

    void addItem(String label, String? message, GlobalKey targetKey) {
      if (message == null || message.isEmpty) {
        return;
      }
      items.add(
        DsValidationSummaryItem(
          label: label,
          message: message,
          onTap: () => Scrollable.ensureVisible(
            targetKey.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.1,
          ),
        ),
      );
    }

    addItem(
      'Nome do ponto de acesso',
      DsKeyFieldSupport.validateRequired(_nameController.text),
      _routingSectionKey,
    );
    addItem(
      'Chave estável',
      _validateAccessPointKey(_keyController.text),
      _routingSectionKey,
    );
    addItem(
      'Fluxo de runtime',
      _validateAccessPointKey(_flowKeyController.text),
      _routingSectionKey,
    );
    addItem(
      'Prompt',
      _promptKey == null ? 'Selecione um prompt válido.' : null,
      _assignmentSectionKey,
    );
    addItem(
      'Persona',
      _personaSkillKey == null ? 'Selecione uma persona válida.' : null,
      _assignmentSectionKey,
    );
    return items;
  }

  String? _validateAccessPointKey(String? value) {
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

  Future<void> _loadCatalogs() async {
    setState(() {
      _loadingCatalogs = true;
      _feedback = null;
    });
    try {
      final surveyRepository = SurveyRepository();
      final promptRepository = SurveyPromptRepository();
      final personaRepository = PersonaSkillRepository();
      final surveys = await surveyRepository.listSurveys();
      final prompts = await promptRepository.listPrompts();
      final personas = await personaRepository.listPersonaSkills();
      surveyRepository.dispose();
      promptRepository.dispose();
      personaRepository.dispose();
      if (!mounted) {
        return;
      }
      setState(() {
        _surveys = surveys;
        _prompts = prompts;
        _personas = personas;
        _loadingCatalogs = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingCatalogs = false;
        _feedback = DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Falha ao carregar catálogos',
          message: 'Falha ao carregar dependências do formulário: $error',
        );
      });
    }
  }

  Future<void> _save() async {
    setState(() => _hasSubmitted = true);
    final form = _formKey.currentState;
    final validationItems = _buildValidationItems();
    if (form == null || !form.validate() || validationItems.isNotEmpty) {
      setState(() {
        _promptSelectionError = _promptKey == null
            ? 'Selecione um prompt válido.'
            : null;
        _personaSelectionError = _personaSkillKey == null
            ? 'Selecione uma persona válida.'
            : null;
      });
      return;
    }

    final persona = _personas.firstWhere(
      (item) => item.personaSkillKey == _personaSkillKey,
    );
    final draft = AgentAccessPointDraft(
      accessPointKey: _keyController.text.trim().toLowerCase(),
      name: _nameController.text.trim(),
      sourceApp: _sourceApp,
      flowKey: _flowKeyController.text.trim().toLowerCase(),
      promptKey: _promptKey!,
      personaSkillKey: _personaSkillKey!,
      outputProfile: persona.outputProfile,
      surveyId: _surveyId,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    setState(() => _saving = true);
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
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _feedback = DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Falha ao salvar ponto de acesso',
          message: 'Falha ao salvar ponto de acesso: $error',
        );
      });
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final validationItems = _hasSubmitted
        ? _buildValidationItems()
        : <DsValidationSummaryItem>[];
    return DsScaffold(
      title: _isEditing ? 'Editar ponto de acesso' : 'Criar ponto de acesso',
      subtitle: 'Mapeie um fluxo de runtime para prompt, persona e perfil.',
      breadcrumbs: [
        DsBreadcrumbItem(
          label: 'Pontos de acesso',
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsBreadcrumbItem(
          label: _isEditing
              ? 'Editar ponto de acesso'
              : 'Criar ponto de acesso',
          isCurrent: true,
        ),
      ],
      onBack: () => Navigator.of(context).pop(),
      backLabel: 'Voltar para pontos de acesso',
      maxBodyWidth: 1920,
      body: _loadingCatalogs
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: DsAdminFormShell(
                isSaving: _saving,
                hasUnsavedChanges: _isDirty,
                onCancel: () => Navigator.of(context).pop(),
                onSave: _save,
                scrollController: _scrollController,
                stickyFooter: const SizedBox.shrink(),
                sectionalNav: DsSectionalNav(
                  items: [
                    DsSectionalNavItem(
                      label: 'Roteamento',
                      targetKey: _routingSectionKey,
                    ),
                    DsSectionalNavItem(
                      label: 'Vinculações',
                      targetKey: _assignmentSectionKey,
                    ),
                  ],
                  activeItem: _currentSectionId == _routingSectionId
                      ? DsSectionalNavItem(
                          label: 'Roteamento',
                          targetKey: _routingSectionKey,
                        )
                      : DsSectionalNavItem(
                          label: 'Vinculações',
                          targetKey: _assignmentSectionKey,
                        ),
                  onItemTap: (item) => _jumpToSection(
                    item.label == 'Roteamento'
                        ? _routingSectionId
                        : _assignmentSectionId,
                  ),
                ),
                feedback: _feedback == null
                    ? null
                    : DsMessageBanner(
                        feedback: DsFeedbackMessage(
                          severity: _feedback!.severity,
                          title: _feedback!.title,
                          message: _feedback!.message,
                          dismissible: true,
                          onDismiss: () => setState(() => _feedback = null),
                        ),
                        margin: EdgeInsets.zero,
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (validationItems.isNotEmpty) ...[
                      DsValidationSummary(
                        items: validationItems,
                        description:
                            'Revise os campos destacados antes de salvar.',
                      ),
                      const SizedBox(height: 16),
                    ],
                    DsSection(
                      key: _routingSectionKey,
                      title: 'Roteamento do acesso',
                      subtitle:
                          'Escolha um ponto de injeção suportado para preencher automaticamente chave, superfície e fluxo com o menor esforço possível.',
                      child: Column(
                        children: [
                          DropdownButtonFormField<String?>(
                            initialValue: _selectedInjectionPointKey,
                            decoration: const InputDecoration(
                              labelText: 'Ponto de injeção suportado',
                              helperText:
                                  'Selecione um fluxo conhecido do runtime ou mantenha em Personalizado.',
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Personalizado'),
                              ),
                              ...RuntimeAccessPointCatalog.configurable.map(
                                (descriptor) => DropdownMenuItem<String?>(
                                  value: descriptor.accessPointKey,
                                  child: Text(descriptor.surfaceLabel),
                                ),
                              ),
                            ],
                            onChanged: _handleInjectionPointChanged,
                          ),
                          if (_selectedInjectionPoint != null) ...[
                            const SizedBox(height: 12),
                            DsInlineMessage(
                              feedback: DsFeedbackMessage(
                                severity: DsStatusType.info,
                                title: _selectedInjectionPoint!.name,
                                message: _selectedInjectionPoint!.description,
                              ),
                              margin: EdgeInsets.zero,
                            ),
                          ],
                          if (RuntimeAccessPointCatalog
                              .observedOnly
                              .isNotEmpty) ...[
                            const SizedBox(height: 12),
                            DsInlineMessage(
                              feedback: DsFeedbackMessage(
                                severity: DsStatusType.neutral,
                                title:
                                    'Pontos observados no runtime fora do catálogo configurável',
                                message: RuntimeAccessPointCatalog.observedOnly
                                    .map(
                                      (descriptor) =>
                                          '${descriptor.surfaceLabel}: ${descriptor.notes}',
                                    )
                                    .join('\n'),
                              ),
                              margin: EdgeInsets.zero,
                            ),
                          ],
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nome do ponto de acesso *',
                            ),
                            validator: DsKeyFieldSupport.validateRequired,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _keyController,
                            readOnly:
                                _isEditing || _selectedInjectionPoint != null,
                            decoration: const InputDecoration(
                              labelText: 'Chave estável *',
                              helperText:
                                  'Ex.: survey_patient.thank_you.auto_analysis',
                            ),
                            validator: _validateAccessPointKey,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _sourceApp,
                            decoration: const InputDecoration(
                              labelText: 'Superfície de origem *',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'survey-patient',
                                child: Text('survey-patient'),
                              ),
                              DropdownMenuItem(
                                value: 'survey-frontend',
                                child: Text('survey-frontend'),
                              ),
                              DropdownMenuItem(
                                value: 'clinical-narrative',
                                child: Text('clinical-narrative'),
                              ),
                            ],
                            onChanged: _selectedInjectionPoint != null
                                ? null
                                : (value) {
                                    if (value == null) {
                                      return;
                                    }
                                    setState(() {
                                      _sourceApp = value;
                                      _isDirty = true;
                                    });
                                  },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _flowKeyController,
                            readOnly: _selectedInjectionPoint != null,
                            decoration: const InputDecoration(
                              labelText: 'Fluxo de runtime *',
                              helperText: 'Ex.: thank_you.auto_analysis',
                            ),
                            validator: _validateAccessPointKey,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String?>(
                            initialValue: _surveyId,
                            decoration: const InputDecoration(
                              labelText: 'Survey associado',
                              helperText:
                                  'Opcional. Deixe vazio para uso global.',
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Global'),
                              ),
                              ..._surveys.map(
                                (survey) => DropdownMenuItem<String?>(
                                  value: survey.id,
                                  child: Text(survey.surveyDisplayName),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) {
                                setState(() {
                                  _surveyId = null;
                                  _isDirty = true;
                                });
                                return;
                              }
                              setState(() {
                                _surveyId = value;
                                _isDirty = true;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    DsSection(
                      key: _assignmentSectionKey,
                      title: 'Vinculações de IA',
                      subtitle:
                          'Associe o prompt e a persona usados por este ponto de acesso para produzir a saída esperada.',
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: _promptKey,
                            decoration: const InputDecoration(
                              labelText: 'Prompt do questionário *',
                            ),
                            items: [
                              ..._localPromptOptions.map(
                                (option) => DropdownMenuItem<String>(
                                  value: option.$1,
                                  child: Text('${option.$2} · ${option.$1}'),
                                ),
                              ),
                              ..._prompts
                                  .map(
                                    (prompt) => DropdownMenuItem<String>(
                                      value: prompt.promptKey,
                                      child: Text(prompt.name),
                                    ),
                                  )
                                  .where(
                                    (item) => !_localPromptOptions.any(
                                      (option) => option.$1 == item.value,
                                    ),
                                  ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _promptKey = value;
                                _promptSelectionError = null;
                                _isDirty = true;
                              });
                            },
                          ),
                          if (_promptSelectionError != null)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _promptSelectionError!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _personaSkillKey,
                            decoration: const InputDecoration(
                              labelText: 'Persona *',
                            ),
                            items: _personas
                                .map(
                                  (persona) => DropdownMenuItem<String>(
                                    value: persona.personaSkillKey,
                                    child: Text(
                                      '${persona.name} · ${persona.outputProfile}',
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: (value) {
                              setState(() {
                                _personaSkillKey = value;
                                _personaSelectionError = null;
                                _isDirty = true;
                              });
                            },
                          ),
                          if (_personaSelectionError != null)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _personaSelectionError!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Descrição operacional',
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
