import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/models/persona_skill_draft.dart';
import 'package:survey_builder/core/repositories/persona_skill_repository.dart';

class PersonaSkillFormPage extends StatefulWidget {
  const PersonaSkillFormPage({
    super.key,
    this.initialDraft,
    this.repository,
    this.existingSkills = const <PersonaSkillDraft>[],
  });

  final PersonaSkillDraft? initialDraft;
  final PersonaSkillRepository? repository;
  final List<PersonaSkillDraft> existingSkills;

  @override
  State<PersonaSkillFormPage> createState() => _PersonaSkillFormPageState();
}

class _PersonaSkillFormPageState extends State<PersonaSkillFormPage> {
  static const String _detailsSectionId = 'details';
  static const String _instructionsSectionId = 'instructions';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _detailsSectionKey = GlobalKey();
  final GlobalKey _instructionsSectionKey = GlobalKey();

  late final PersonaSkillRepository _repository;
  late final bool _isEditing;
  late final TextEditingController _personaSkillKeyController;
  late final TextEditingController _nameController;
  late final TextEditingController _outputProfileController;
  late final TextEditingController _instructionsController;
  late List<PersonaSkillDraft> _existingSkills;
  bool _saving = false;
  bool _isDirty = false;
  bool _hasSubmitted = false;
  String? _personaSkillKeyConflictText;
  String? _outputProfileConflictText;
  DsFeedbackMessage? _feedback;
  String _currentSectionId = _detailsSectionId;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? PersonaSkillRepository();
    _isEditing = widget.initialDraft != null;
    _existingSkills = widget.existingSkills
        .map((PersonaSkillDraft skill) => skill.copy())
        .toList();

    final draft =
        widget.initialDraft ??
        PersonaSkillDraft(
          personaSkillKey: '',
          name: '',
          outputProfile: '',
          instructions: '',
        );
    _personaSkillKeyController = TextEditingController(
      text: draft.personaSkillKey,
    )..addListener(_handleFieldMutation);
    _nameController = TextEditingController(text: draft.name)
      ..addListener(_handleFieldMutation);
    _outputProfileController = TextEditingController(text: draft.outputProfile)
      ..addListener(_handleFieldMutation);
    _instructionsController = TextEditingController(text: draft.instructions)
      ..addListener(_handleFieldMutation);

    _scrollController.addListener(_handleSectionScroll);
  }

  @override
  void dispose() {
    _personaSkillKeyController.removeListener(_handleFieldMutation);
    _nameController.removeListener(_handleFieldMutation);
    _outputProfileController.removeListener(_handleFieldMutation);
    _instructionsController.removeListener(_handleFieldMutation);
    _personaSkillKeyController.dispose();
    _nameController.dispose();
    _outputProfileController.dispose();
    _instructionsController.dispose();
    _scrollController.removeListener(_handleSectionScroll);
    _scrollController.dispose();
    _repository.dispose();
    super.dispose();
  }

  void _handleFieldMutation() {
    _clearConflictMessages();
    if (!_isDirty) {
      setState(() => _isDirty = true);
    }
  }

  void _handleSectionScroll() {
    final activationOffset = 180.0;
    String nextSectionId = _detailsSectionId;

    final instructionsBox =
        _instructionsSectionKey.currentContext?.findRenderObject()
            as RenderBox?;

    if (instructionsBox != null) {
      final top = instructionsBox.localToGlobal(Offset.zero).dy;
      if (top <= activationOffset) {
        nextSectionId = _instructionsSectionId;
      }
    }

    if (nextSectionId != _currentSectionId && mounted) {
      setState(() => _currentSectionId = nextSectionId);
    }
  }

  void _jumpToSection(String sectionId) {
    final targetKey = sectionId == _detailsSectionId
        ? _detailsSectionKey
        : _instructionsSectionKey;
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

  void _clearConflictMessages() {
    if (_personaSkillKeyConflictText == null &&
        _outputProfileConflictText == null) {
      return;
    }
    setState(() {
      _personaSkillKeyConflictText = null;
      _outputProfileConflictText = null;
    });
  }

  PersonaSkillDraft _buildDraft() {
    return PersonaSkillDraft(
      personaSkillKey: DsKeyFieldSupport.normalizeKeyField(
        _personaSkillKeyController.text,
      ),
      name: DsKeyFieldSupport.normalizeTextField(_nameController.text),
      outputProfile: DsKeyFieldSupport.normalizeKeyField(
        _outputProfileController.text,
      ),
      instructions: DsKeyFieldSupport.normalizeTextField(
        _instructionsController.text,
      ),
    );
  }

  PersonaSkillDuplicateCheckResult _detectDuplicates(PersonaSkillDraft draft) {
    return PersonaSkillFormSupport.detectDuplicates(
      existingSkills: _existingSkills,
      personaSkillKey: draft.personaSkillKey,
      outputProfile: draft.outputProfile,
      currentPersonaSkillKey: widget.initialDraft?.personaSkillKey,
    );
  }

  void _applyDuplicateErrors(PersonaSkillDuplicateCheckResult duplicates) {
    setState(() {
      _personaSkillKeyConflictText = duplicates.personaSkillKeyConflict
          ? 'Esta chave de persona já está em uso.'
          : null;
      _outputProfileConflictText = duplicates.outputProfileConflict
          ? 'Este perfil de saída já está vinculado a outra persona.'
          : null;
      _feedback = const DsFeedbackMessage(
        severity: DsStatusType.warning,
        title: 'Conflito de cadastro',
        message: 'Revise os campos em conflito e salve novamente.',
      );
    });
  }

  List<DsValidationSummaryItem> _buildValidationItems() {
    final items = <DsValidationSummaryItem>[];
    void addItem(String label, String? message, GlobalKey targetKey) {
      if (message != null && message.isNotEmpty) {
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
    }

    addItem(
      'Chave da persona',
      DsKeyFieldSupport.validateRequired(_personaSkillKeyController.text),
      _detailsSectionKey,
    );
    addItem(
      'Nome da persona',
      DsKeyFieldSupport.validateRequired(_nameController.text),
      _detailsSectionKey,
    );
    addItem(
      'Perfil de saída',
      DsKeyFieldSupport.validateRequired(_outputProfileController.text),
      _detailsSectionKey,
    );
    addItem(
      'Instruções',
      DsKeyFieldSupport.validateRequired(_instructionsController.text),
      _instructionsSectionKey,
    );

    return items;
  }

  Future<void> _save() async {
    setState(() => _hasSubmitted = true);
    final state = _formKey.currentState;
    final validationItems = _buildValidationItems();

    if (state == null || !state.validate() || validationItems.isNotEmpty) {
      return;
    }

    final draft = _buildDraft();
    final duplicates = _detectDuplicates(draft);
    if (duplicates.hasConflict) {
      _applyDuplicateErrors(duplicates);
      return;
    }

    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await _repository.updatePersonaSkill(draft);
      } else {
        await _repository.createPersonaSkill(draft);
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on PersonaSkillConflictException catch (error) {
      try {
        _existingSkills = await _repository.listPersonaSkills();
      } on Exception {
        // Keep the backend conflict as the actionable message if a refresh fails.
      }
      final latestDuplicates = _detectDuplicates(draft);
      if (latestDuplicates.hasConflict) {
        _applyDuplicateErrors(latestDuplicates);
      } else if (mounted) {
        setState(() {
          _feedback = DsFeedbackMessage(
            severity: DsStatusType.error,
            title: 'Falha ao salvar persona',
            message: 'Falha ao salvar persona: $error',
          );
        });
      }
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _feedback = DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Falha ao salvar persona',
          message: 'Falha ao salvar persona: $error',
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
      title: _isEditing ? 'Editar persona' : 'Criar persona',
      subtitle: 'Configure personas e perfis de saída reutilizáveis.',
      breadcrumbs: [
        DsBreadcrumbItem(
          label: 'Personas de saída',
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsBreadcrumbItem(
          label: _isEditing ? 'Editar persona' : 'Criar persona',
          isCurrent: true,
        ),
      ],
      onBack: () => Navigator.of(context).pop(),
      backLabel: 'Voltar para personas',
      maxBodyWidth: 1920,
      scrollable: false,
      body: Form(
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
                label: 'Detalhes',
                targetKey: _detailsSectionKey,
              ),
              DsSectionalNavItem(
                label: 'Instruções',
                targetKey: _instructionsSectionKey,
              ),
            ],
            activeItem: _currentSectionId == _detailsSectionId
                ? DsSectionalNavItem(
                    label: 'Detalhes',
                    targetKey: _detailsSectionKey,
                  )
                : DsSectionalNavItem(
                    label: 'Instruções',
                    targetKey: _instructionsSectionKey,
                  ),
            onItemTap: (item) => _jumpToSection(
              item.targetKey == _detailsSectionKey
                  ? _detailsSectionId
                  : _instructionsSectionId,
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
                  description: 'Revise os campos destacados antes de salvar.',
                ),
                const SizedBox(height: 16),
              ],
              DsSection(
                key: _detailsSectionKey,
                title: 'Detalhes da persona',
                child: Column(
                  children: [
                    DsNormalizedKeyField(
                      controller: _personaSkillKeyController,
                      readOnly: _isEditing,
                      label: 'Chave da persona *',
                      helperText:
                          'Use letras minúsculas, números, ":" , "_" ou "-".',
                    ),
                    if (_personaSkillKeyConflictText != null)
                      DsInlineConflictMessage(
                        message: _personaSkillKeyConflictText!,
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da persona *',
                      ),
                      validator: DsKeyFieldSupport.validateRequired,
                    ),
                    const SizedBox(height: 12),
                    DsNormalizedKeyField(
                      controller: _outputProfileController,
                      label: 'Perfil de saída *',
                      helperText:
                          'Use letras minúsculas, números, ":" , "_" ou "-".',
                    ),
                    if (_outputProfileConflictText != null)
                      DsInlineConflictMessage(
                        message: _outputProfileConflictText!,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              DsSection(
                key: _instructionsSectionKey,
                title: 'Instruções da persona',
                child: TextFormField(
                  controller: _instructionsController,
                  minLines: 15,
                  maxLines: 25,
                  decoration: const InputDecoration(
                    labelText: 'Instruções *',
                    alignLabelWithHint: true,
                  ),
                  validator: DsKeyFieldSupport.validateRequired,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
