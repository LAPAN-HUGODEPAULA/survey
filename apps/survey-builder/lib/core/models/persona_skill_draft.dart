import 'package:design_system_flutter/widgets.dart';

class PersonaSkillDraft {
  PersonaSkillDraft({
    required this.personaSkillKey,
    required this.name,
    required this.outputProfile,
    required this.instructions,
    this.createdAt,
    this.modifiedAt,
  });

  String personaSkillKey;
  String name;
  String outputProfile;
  String instructions;
  DateTime? createdAt;
  DateTime? modifiedAt;

  PersonaSkillDraft copy() {
    return PersonaSkillDraft(
      personaSkillKey: personaSkillKey,
      name: name,
      outputProfile: outputProfile,
      instructions: instructions,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
    );
  }
}

class PersonaSkillDuplicateCheckResult {
  const PersonaSkillDuplicateCheckResult({
    required this.personaSkillKeyConflict,
    required this.outputProfileConflict,
  });

  final bool personaSkillKeyConflict;
  final bool outputProfileConflict;

  bool get hasConflict => personaSkillKeyConflict || outputProfileConflict;
}

class PersonaSkillFormSupport {
  static String normalizeKeyField(String value) {
    return DsKeyFieldSupport.normalizeKeyField(value);
  }

  static String normalizeTextField(String value) {
    return DsKeyFieldSupport.normalizeTextField(value);
  }

  static String? validateRequired(String? value) {
    return DsKeyFieldSupport.validateRequired(value);
  }

  static String? validateKeyField(String? value) {
    return DsKeyFieldSupport.validateKeyField(value);
  }

  static PersonaSkillDuplicateCheckResult detectDuplicates({
    required Iterable<PersonaSkillDraft> existingSkills,
    required String personaSkillKey,
    required String outputProfile,
    String? currentPersonaSkillKey,
  }) {
    final normalizedCurrentKey = normalizeKeyField(
      currentPersonaSkillKey ?? '',
    );
    final normalizedKey = normalizeKeyField(personaSkillKey);
    final normalizedOutputProfile = normalizeKeyField(outputProfile);

    var personaSkillKeyConflict = false;
    var outputProfileConflict = false;

    for (final skill in existingSkills) {
      final skillKey = normalizeKeyField(skill.personaSkillKey);
      if (skillKey == normalizedCurrentKey) {
        continue;
      }

      if (normalizedKey.isNotEmpty && skillKey == normalizedKey) {
        personaSkillKeyConflict = true;
      }

      if (normalizedOutputProfile.isNotEmpty &&
          normalizeKeyField(skill.outputProfile) == normalizedOutputProfile) {
        outputProfileConflict = true;
      }
    }

    return PersonaSkillDuplicateCheckResult(
      personaSkillKeyConflict: personaSkillKeyConflict,
      outputProfileConflict: outputProfileConflict,
    );
  }
}
