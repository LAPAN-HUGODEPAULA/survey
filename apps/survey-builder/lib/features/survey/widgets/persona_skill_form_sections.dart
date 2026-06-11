import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/features/survey/controllers/persona_skill_form_controller.dart';
import 'package:survey_builder/features/survey/validators/survey_authoring_validators.dart';

class PersonaSkillDetailsSection extends StatelessWidget {
  const PersonaSkillDetailsSection({
    super.key,
    required this.controller,
    required this.sectionKey,
  });

  final PersonaSkillFormController controller;
  final GlobalKey sectionKey;

  @override
  Widget build(BuildContext context) {
    return DsSection(
      key: sectionKey,
      title: 'Detalhes da persona',
      child: Column(
        children: [
          DsNormalizedKeyField(
            controller: controller.personaSkillKeyController,
            readOnly: controller.isEditing,
            label: 'Chave da persona *',
            helperText: 'Use letras minúsculas, números, ":" , "_" ou "-".',
          ),
          if (controller.personaSkillKeyConflictText != null)
            DsInlineConflictMessage(
              message: controller.personaSkillKeyConflictText!,
            ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.nameController,
            decoration: const InputDecoration(labelText: 'Nome da persona *'),
            validator: SurveyAuthoringValidators.required,
          ),
          const SizedBox(height: 12),
          DsNormalizedKeyField(
            controller: controller.outputProfileController,
            label: 'Perfil de saída *',
            helperText: 'Use letras minúsculas, números, ":" , "_" ou "-".',
          ),
          if (controller.outputProfileConflictText != null)
            DsInlineConflictMessage(
              message: controller.outputProfileConflictText!,
            ),
        ],
      ),
    );
  }
}

class PersonaSkillInstructionsSection extends StatelessWidget {
  const PersonaSkillInstructionsSection({
    super.key,
    required this.controller,
    required this.sectionKey,
  });

  final PersonaSkillFormController controller;
  final GlobalKey sectionKey;

  @override
  Widget build(BuildContext context) {
    return DsSection(
      key: sectionKey,
      title: 'Instruções da persona',
      child: TextFormField(
        controller: controller.instructionsController,
        minLines: 15,
        maxLines: 25,
        decoration: const InputDecoration(
          labelText: 'Instruções *',
          alignLabelWithHint: true,
        ),
        validator: SurveyAuthoringValidators.required,
      ),
    );
  }
}
