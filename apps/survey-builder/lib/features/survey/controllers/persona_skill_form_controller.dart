import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/models/persona_skill_draft.dart';
import 'package:survey_builder/core/repositories/persona_skill_repository.dart';
import 'package:survey_builder/features/survey/controllers/authoring_form_controller.dart';
import 'package:survey_builder/features/survey/validators/survey_authoring_validators.dart';

class PersonaSkillFormController extends AuthoringFormController {
  PersonaSkillFormController({
    PersonaSkillDraft? initialDraft,
    PersonaSkillRepository? repository,
    List<PersonaSkillDraft> existingSkills = const <PersonaSkillDraft>[],
  }) : _repository = repository ?? PersonaSkillRepository(),
       _initialDraft = initialDraft,
       _isEditing = initialDraft != null,
       _existingSkills = existingSkills
           .map((PersonaSkillDraft skill) => skill.copy())
           .toList() {
    final draft =
        initialDraft ??
        PersonaSkillDraft(
          personaSkillKey: '',
          name: '',
          outputProfile: '',
          instructions: '',
        );
    personaSkillKeyController = TextEditingController(
      text: draft.personaSkillKey,
    )..addListener(_handleFieldMutation);
    nameController = TextEditingController(text: draft.name)
      ..addListener(_handleFieldMutation);
    outputProfileController = TextEditingController(text: draft.outputProfile)
      ..addListener(_handleFieldMutation);
    instructionsController = TextEditingController(text: draft.instructions)
      ..addListener(_handleFieldMutation);
  }

  final PersonaSkillRepository _repository;
  final PersonaSkillDraft? _initialDraft;
  final bool _isEditing;
  List<PersonaSkillDraft> _existingSkills;

  late final TextEditingController personaSkillKeyController;
  late final TextEditingController nameController;
  late final TextEditingController outputProfileController;
  late final TextEditingController instructionsController;

  String? personaSkillKeyConflictText;
  String? outputProfileConflictText;

  bool get isEditing => _isEditing;

  void _handleFieldMutation() {
    clearConflictMessages();
    markDirty();
  }

  void clearConflictMessages() {
    if (personaSkillKeyConflictText == null &&
        outputProfileConflictText == null) {
      return;
    }
    personaSkillKeyConflictText = null;
    outputProfileConflictText = null;
    notifyListeners();
  }

  PersonaSkillDraft buildDraft() {
    return PersonaSkillDraft(
      personaSkillKey: SurveyAuthoringValidators.normalizeKey(
        personaSkillKeyController.text,
      ),
      name: SurveyAuthoringValidators.normalizeText(nameController.text),
      outputProfile: SurveyAuthoringValidators.normalizeKey(
        outputProfileController.text,
      ),
      instructions: SurveyAuthoringValidators.normalizeText(
        instructionsController.text,
      ),
    );
  }

  List<DsValidationSummaryItem> buildValidationItems({
    required GlobalKey detailsSectionKey,
    required GlobalKey instructionsSectionKey,
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
      'Chave da persona',
      SurveyAuthoringValidators.required(personaSkillKeyController.text),
      detailsSectionKey,
    );
    addItem(
      'Nome da persona',
      SurveyAuthoringValidators.required(nameController.text),
      detailsSectionKey,
    );
    addItem(
      'Perfil de saída',
      SurveyAuthoringValidators.required(outputProfileController.text),
      detailsSectionKey,
    );
    addItem(
      'Instruções',
      SurveyAuthoringValidators.required(instructionsController.text),
      instructionsSectionKey,
    );

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

    final draft = buildDraft();
    final duplicates = _detectDuplicates(draft);
    if (duplicates.hasConflict) {
      _applyDuplicateErrors(duplicates);
      return false;
    }

    setSaving(true);
    try {
      if (_isEditing) {
        await _repository.updatePersonaSkill(draft);
      } else {
        await _repository.createPersonaSkill(draft);
      }
      clearDirty();
      return true;
    } on PersonaSkillConflictException catch (error) {
      try {
        _existingSkills = await _repository.listPersonaSkills();
      } on Exception {
        // Keep the backend conflict as the actionable message if refresh fails.
      }
      final latestDuplicates = _detectDuplicates(draft);
      if (latestDuplicates.hasConflict) {
        _applyDuplicateErrors(latestDuplicates);
      } else {
        setFeedback(
          DsFeedbackMessage(
            severity: DsStatusType.error,
            title: 'Falha ao salvar persona',
            message: 'Falha ao salvar persona: $error',
          ),
        );
      }
      return false;
    } on Exception catch (error) {
      setFeedback(
        DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Falha ao salvar persona',
          message: 'Falha ao salvar persona: $error',
        ),
      );
      return false;
    } finally {
      setSaving(false);
    }
  }

  PersonaSkillDuplicateCheckResult _detectDuplicates(PersonaSkillDraft draft) {
    return PersonaSkillFormSupport.detectDuplicates(
      existingSkills: _existingSkills,
      personaSkillKey: draft.personaSkillKey,
      outputProfile: draft.outputProfile,
      currentPersonaSkillKey: _initialDraft?.personaSkillKey,
    );
  }

  void _applyDuplicateErrors(PersonaSkillDuplicateCheckResult duplicates) {
    personaSkillKeyConflictText = duplicates.personaSkillKeyConflict
        ? 'Esta chave de persona já está em uso.'
        : null;
    outputProfileConflictText = duplicates.outputProfileConflict
        ? 'Este perfil de saída já está vinculado a outra persona.'
        : null;
    setFeedback(
      const DsFeedbackMessage(
        severity: DsStatusType.warning,
        title: 'Conflito de cadastro',
        message: 'Revise os campos em conflito e salve novamente.',
      ),
    );
  }

  @override
  void dispose() {
    personaSkillKeyController.removeListener(_handleFieldMutation);
    nameController.removeListener(_handleFieldMutation);
    outputProfileController.removeListener(_handleFieldMutation);
    instructionsController.removeListener(_handleFieldMutation);
    personaSkillKeyController.dispose();
    nameController.dispose();
    outputProfileController.dispose();
    instructionsController.dispose();
    _repository.dispose();
    super.dispose();
  }
}
