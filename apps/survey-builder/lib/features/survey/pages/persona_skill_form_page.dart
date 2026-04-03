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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final PersonaSkillRepository _repository;
  late final bool _isEditing;
  late final TextEditingController _personaSkillKeyController;
  late final TextEditingController _nameController;
  late final TextEditingController _outputProfileController;
  late final TextEditingController _instructionsController;
  late List<PersonaSkillDraft> _existingSkills;
  bool _saving = false;
  String? _personaSkillKeyConflictText;
  String? _outputProfileConflictText;

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
    )..addListener(_clearConflictMessages);
    _nameController = TextEditingController(text: draft.name);
    _outputProfileController = TextEditingController(text: draft.outputProfile)
      ..addListener(_clearConflictMessages);
    _instructionsController = TextEditingController(text: draft.instructions);
  }

  @override
  void dispose() {
    _personaSkillKeyController.dispose();
    _nameController.dispose();
    _outputProfileController.dispose();
    _instructionsController.dispose();
    _repository.dispose();
    super.dispose();
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
    });
  }

  Future<void> _save() async {
    final state = _formKey.currentState;
    if (state == null || !state.validate()) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao salvar persona: $error')),
        );
      }
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao salvar persona: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: _isEditing ? 'Editar persona' : 'Criar persona',
      subtitle:
          'Configure personas e perfis de saida reutilizaveis para os relatos clinicos.',
      scrollable: true,
      body: Form(
        key: _formKey,
        child: DsAdminFormShell(
          isSaving: _saving,
          onCancel: () => Navigator.of(context).pop(),
          onSave: _save,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DsNormalizedKeyField(
                controller: _personaSkillKeyController,
                readOnly: _isEditing,
                label: 'Chave da persona *',
                helperText: 'Use letras minúsculas, números, ":" , "_" ou "-".',
              ),
              if (_personaSkillKeyConflictText != null)
                DsInlineConflictMessage(message: _personaSkillKeyConflictText!),
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
                helperText: 'Use letras minúsculas, números, ":" , "_" ou "-".',
              ),
              if (_outputProfileConflictText != null)
                DsInlineConflictMessage(message: _outputProfileConflictText!),
              const SizedBox(height: 12),
              TextFormField(
                controller: _instructionsController,
                minLines: 10,
                maxLines: 18,
                decoration: const InputDecoration(
                  labelText: 'Instruções *',
                  alignLabelWithHint: true,
                ),
                validator: DsKeyFieldSupport.validateRequired,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
