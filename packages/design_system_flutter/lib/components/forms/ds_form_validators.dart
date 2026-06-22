class DsFormValidators {
  DsFormValidators._();

  // =========================
  // BASIC VALIDATION HELPERS
  // =========================

  static String? validateRequired(
    String? value, {
    String? fieldName,
    String? customMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      if (customMessage != null) {
        return customMessage;
      }
      return fieldName != null
          ? '$fieldName é obrigatório'
          : 'Campo obrigatório';
    }
    return null;
  }

  static String? validateMinLength(
    String? value,
    int minLength, {
    String? fieldName,
  }) {
    if (value == null || value.trim().length < minLength) {
      return fieldName != null
          ? '$fieldName deve ter pelo menos $minLength caracteres'
          : 'Deve ter pelo menos $minLength caracteres';
    }
    return null;
  }

  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String? fieldName,
  }) {
    if (value != null && value.trim().length > maxLength) {
      return fieldName != null
          ? '$fieldName deve ter no máximo $maxLength caracteres'
          : 'Deve ter no máximo $maxLength caracteres';
    }
    return null;
  }

  // =========================
  // NAME VALIDATION
  // =========================

  static String? validatePersonName(String? name, {String? context}) {
    final requiredError = validateRequired(
      name,
      customMessage: context != null
          ? 'Por favor, insira ${_getPersonNamePrompt(context)}'
          : 'Por favor, insira o nome completo',
    );
    if (requiredError != null) {
      return requiredError;
    }

    final trimmed = name!.trim();
    if (trimmed.length < 5) {
      return 'O nome deve ter pelo menos 5 caracteres.';
    }
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(trimmed)) {
      return 'O nome deve conter apenas letras e espaços.';
    }
    return null;
  }

  static String _getPersonNamePrompt(String context) {
    switch (context.toLowerCase()) {
      case 'patient':
      case 'paciente':
        return 'seu nome completo';
      case 'screener':
      case 'responsavel':
      case 'responsável':
        return 'o nome completo do responsável';
      case 'clinician':
      case 'profissional':
        return 'o nome completo do profissional';
      default:
        return 'o nome completo';
    }
  }

  // =========================
  // EMAIL VALIDATION
  // =========================

  static String? validateEmail(String? email, {String? context}) {
    final requiredError = validateRequired(
      email,
      customMessage: context != null
          ? 'Por favor, insira ${_getEmailPrompt(context)}'
          : 'Por favor, insira um email válido',
    );
    if (requiredError != null) {
      return requiredError;
    }

    final emailTrimmed = email!.trim();
    if (!emailTrimmed.contains('@')) {
      return 'Email deve conter o símbolo @.';
    }
    if (emailTrimmed.split('@').length != 2) {
      return 'Email deve conter apenas um símbolo @.';
    }

    final parts = emailTrimmed.split('@');
    final localPart = parts.first;
    final domainPart = parts[1];
    if (localPart.isEmpty) {
      return 'Email deve ter texto antes do @.';
    }
    if (domainPart.isEmpty) {
      return 'Email deve ter um domínio depois do @.';
    }
    if (!domainPart.contains('.')) {
      return 'Domínio do email deve conter pelo menos um ponto.';
    }

    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );
    if (!emailRegex.hasMatch(emailTrimmed)) {
      return 'Por favor, insira um email válido (ex: usuario@exemplo.com).';
    }

    final domainParts = domainPart.split('.');
    if (domainParts.last.length < 2) {
      return 'O domínio do email deve ter pelo menos 2 caracteres após o ponto.';
    }
    return null;
  }

  static String _getEmailPrompt(String context) {
    switch (context.toLowerCase()) {
      case 'patient':
      case 'paciente':
        return 'seu email de contato';
      case 'screener':
      case 'responsavel':
      case 'responsável':
        return 'o email de contato do responsável';
      default:
        return 'um email de contato';
    }
  }

  // =========================
  // DATE VALIDATION
  // =========================

  static String? validateBirthDate(String? dateText) {
    final requiredError = validateRequired(
      dateText,
      customMessage: 'Por favor, insira sua data de nascimento.',
    );
    if (requiredError != null) {
      return requiredError;
    }

    final trimmed = dateText!.trim();
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(trimmed)) {
      return 'Use o formato DD/MM/AAAA (ex: 15/03/1990).';
    }

    try {
      final parts = trimmed.split('/');
      final day = int.parse(parts.first);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      if (day < 1 || day > 31) {
        return 'Dia deve estar entre 01 e 31.';
      }
      if (month < 1 || month > 12) {
        return 'Mês deve estar entre 01 e 12.';
      }
      if (year < 1900 || year > DateTime.now().year) {
        return 'Ano deve estar entre 1900 e ${DateTime.now().year}.';
      }

      final date = DateTime(year, month, day);
      if (date.day != day || date.month != month || date.year != year) {
        return 'Data inválida.';
      }
      if (date.isAfter(DateTime.now())) {
        return 'A data de nascimento não pode ser futura.';
      }
      return null;
    } catch (_) {
      return 'Data inválida. Use o formato DD/MM/AAAA.';
    }
  }

  static String? validateDate(
    String? dateText, {
    bool allowFuture = true,
    String? fieldName,
  }) {
    final fieldPrompt = fieldName ?? 'a data';
    if (dateText == null || dateText.isEmpty) {
      return 'Por favor, insira $fieldPrompt.';
    }

    final trimmed = dateText.trim();
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(trimmed)) {
      return 'Use o formato DD/MM/AAAA (ex: 15/03/1990).';
    }

    try {
      final parts = trimmed.split('/');
      final day = int.parse(parts.first);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      if (day < 1 || day > 31) {
        return 'Dia deve estar entre 01 e 31.';
      }
      if (month < 1 || month > 12) {
        return 'Mês deve estar entre 01 e 12.';
      }
      if (year < 1900 || year > 2100) {
        return 'Ano deve estar entre 1900 e 2100.';
      }

      final date = DateTime(year, month, day);
      if (date.day != day || date.month != month || date.year != year) {
        return 'Data inválida.';
      }
      if (!allowFuture && date.isAfter(DateTime.now())) {
        return 'A data não pode ser futura.';
      }
      return null;
    } catch (_) {
      return 'Data inválida. Use o formato DD/MM/AAAA.';
    }
  }

  // =========================
  // PROFESSION VALIDATION
  // =========================

  static String? validateProfession(
    String? profession, {
    int? maxLength,
    bool required = true,
  }) {
    final trimmed = profession?.trim() ?? '';
    if (trimmed.isEmpty) {
      return required ? 'Por favor, insira sua profissão.' : null;
    }
    if (trimmed.length < 2) {
      return 'A profissão deve ter pelo menos 2 caracteres.';
    }
    if (maxLength != null && trimmed.length > maxLength) {
      return 'A profissão deve ter no máximo $maxLength caracteres.';
    }
    return null;
  }

  // =========================
  // MEDICATION VALIDATION
  // =========================

  static String? validateMedicationList(String? medicationList) {
    if (medicationList == null || medicationList.isEmpty) {
      return 'Por favor, informe o(s) nome(s) do(s) medicamento(s).';
    }

    final medications = medicationList
        .split(',')
        .map((med) => med.trim())
        .where((med) => med.isNotEmpty)
        .toList();

    if (medications.isEmpty) {
      return 'Por favor, informe pelo menos um medicamento válido.';
    }

    for (final medication in medications) {
      final medicationRegex = RegExp(r'^[a-zA-Z0-9À-ÿ\s\-]+$');
      if (!medicationRegex.hasMatch(medication)) {
        return 'Medicamento "$medication" contém caracteres inválidos.\nUse apenas letras, números, espaços e hífen.';
      }
      if (medication.length < 2) {
        return 'Medicamento "$medication" deve ter pelo menos 2 caracteres.';
      }
      if (medication.length > 50) {
        return 'Medicamento "$medication" deve ter no máximo 50 caracteres.';
      }
    }
    return null;
  }

  // =========================
  // CLINICAL VALIDATION
  // =========================

  static String? validateMedicalRecordId(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  // =========================
  // DROPDOWN VALIDATION
  // =========================

  static String? validateDropdownSelection(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? '$fieldName é obrigatório'
          : 'Campo obrigatório';
    }
    return null;
  }

  // =========================
  // TEXT FIELD VALIDATION
  // =========================

  static String? validateTextField(
    String? value, {
    String? fieldName,
    bool required = true,
    int? minLength,
    int? maxLength,
    RegExp? pattern,
    String? patternErrorMessage,
  }) {
    if (required) {
      final requiredError = validateRequired(value, fieldName: fieldName);
      if (requiredError != null) return requiredError;
    }

    if (value == null || value.isEmpty) return null;

    final trimmed = value.trim();

    if (minLength != null) {
      final lengthError = validateMinLength(
        trimmed,
        minLength,
        fieldName: fieldName,
      );
      if (lengthError != null) return lengthError;
    }

    if (maxLength != null) {
      final lengthError = validateMaxLength(
        trimmed,
        maxLength,
        fieldName: fieldName,
      );
      if (lengthError != null) return lengthError;
    }

    if (pattern != null && !pattern.hasMatch(trimmed)) {
      return patternErrorMessage ??
          (fieldName != null
              ? '$fieldName contém caracteres inválidos'
              : 'Campo contém caracteres inválidos');
    }

    return null;
  }

  // =========================
  // COMPOSITE VALIDATORS
  // =========================

  static String? Function(String?) combineValidators(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
