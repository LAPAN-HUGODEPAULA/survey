import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final AgentAccessPointRepository _repository;
  late final bool _isEditing;
  late final TextEditingController _nameController;
  late final TextEditingController _keyController;
  late final TextEditingController _flowKeyController;
  late final TextEditingController _descriptionController;
  String _sourceApp = 'survey-patient';
  String? _surveyId;
  String? _promptKey;
  String? _personaSkillKey;
  bool _loadingCatalogs = true;
  bool _saving = false;
  bool _isDirty = false;
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
    _descriptionController = TextEditingController(text: draft.description ?? '')
      ..addListener(_handleMutation);
    _sourceApp = draft.sourceApp;
    _surveyId = draft.surveyId;
    _promptKey = draft.promptKey.isEmpty ? null : draft.promptKey;
    _personaSkillKey = draft.personaSkillKey.isEmpty ? null : draft.personaSkillKey;
    _loadCatalogs();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _keyController.dispose();
    _flowKeyController.dispose();
    _descriptionController.dispose();
    _repository.dispose();
    super.dispose();
  }

  void _handleMutation() {
    if (!_isDirty) {
      setState(() => _isDirty = true);
    }
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
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    if (_promptKey == null || _personaSkillKey == null) {
      setState(() {
        _feedback = const DsFeedbackMessage(
          severity: DsStatusType.warning,
          title: 'Campos obrigatórios',
          message: 'Selecione um prompt e uma persona válidos.',
        );
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
      if (_isEditing) {
        await _repository.updateAccessPoint(draft);
      } else {
        await _repository.createAccessPoint(draft);
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
    return DsScaffold(
      title: _isEditing
          ? 'Editar ponto de acesso'
          : 'Criar ponto de acesso',
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
      body: _loadingCatalogs
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: DsAdminFormShell(
                isSaving: _saving,
                hasUnsavedChanges: _isDirty,
                onCancel: () => Navigator.of(context).pop(),
                onSave: _save,
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
                  children: [
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
                      readOnly: _isEditing,
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
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _sourceApp = value;
                          _isDirty = true;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _flowKeyController,
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
                        helperText: 'Opcional. Deixe vazio para uso global.',
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
                        setState(() {
                          _surveyId = value;
                          _isDirty = true;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _promptKey,
                      decoration: const InputDecoration(
                        labelText: 'Prompt questionário *',
                      ),
                      items: _prompts
                          .map(
                            (prompt) => DropdownMenuItem<String>(
                              value: prompt.promptKey,
                              child: Text(prompt.name),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        setState(() {
                          _promptKey = value;
                          _isDirty = true;
                        });
                      },
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
                          _isDirty = true;
                        });
                      },
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
            ),
    );
  }
}
