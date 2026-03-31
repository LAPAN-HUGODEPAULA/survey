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
  static final RegExp _allowedKeyPattern = RegExp(r'^[a-z0-9:_-]+$');

  static String normalizeKeyField(String value) {
    return value.trim().toLowerCase();
  }

  static String normalizeTextField(String value) {
    return value.trim();
  }

  static String? validateRequired(String? value) {
    if (normalizeTextField(value ?? '').isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  static String? validateKeyField(String? value) {
    final normalized = normalizeKeyField(value ?? '');
    if (normalized.isEmpty) {
      return 'Campo obrigatório';
    }
    if (!_allowedKeyPattern.hasMatch(normalized)) {
      return 'Use letras, números, ":" , "_" ou "-".';
    }
    return null;
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
