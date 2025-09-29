/// Comprehensive validation utilities for form fields across the application.
///
/// This library provides reusable validation functions for common form fields
/// including names, emails, dates, professions, medications, and more.
/// All validation functions follow the Flutter FormField validator signature.
library;

/// Static utility class containing all validation methods.
///
/// This class provides a centralized location for all form validation logic,
/// ensuring consistency across the application and making validators easily
/// testable and reusable.
class FormValidators {
  /// Private constructor to prevent instantiation
  FormValidators._();

  // =========================
  // BASIC VALIDATION HELPERS
  // =========================

  /// Validates that a field is not empty.
  ///
  /// [value] - The value to validate
  /// [fieldName] - Optional field name for error messages
  /// [customMessage] - Custom error message
  ///
  /// Returns error string if invalid, null if valid
  static String? validateRequired(
    String? value, {
    String? fieldName,
    String? customMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      if (customMessage != null) return customMessage;
      return fieldName != null
          ? '$fieldName é obrigatório'
          : 'Campo obrigatório';
    }
    return null;
  }

  /// Validates minimum length requirement.
  ///
  /// [value] - The value to validate
  /// [minLength] - Minimum required length
  /// [fieldName] - Optional field name for error messages
  ///
  /// Returns error string if invalid, null if valid
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

  /// Validates maximum length requirement.
  ///
  /// [value] - The value to validate
  /// [maxLength] - Maximum allowed length
  /// [fieldName] - Optional field name for error messages
  ///
  /// Returns error string if invalid, null if valid
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

  /// Validates personal names (patient, screener, etc.).
  ///
  /// This validator checks for:
  /// - Required field
  /// - Minimum 5 characters
  /// - Only letters, spaces, and accents allowed
  ///
  /// [name] - The name to validate
  /// [context] - Context for personalized error messages ('patient', 'screener', etc.)
  ///
  /// Returns error string if invalid, null if valid
  static String? validatePersonName(String? name, {String? context}) {
    // Check if required
    final requiredError = validateRequired(
      name,
      customMessage: context != null
          ? 'Por favor, insira ${_getPersonNamePrompt(context)}'
          : 'Por favor, insira o nome completo',
    );
    if (requiredError != null) return requiredError;

    final trimmed = name!.trim();

    // Check minimum length
    if (trimmed.length < 5) {
      return 'O nome deve ter pelo menos 5 caracteres.';
    }

    // Check character pattern (only letters, spaces, and accents)
    final nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s]+$');
    if (!nameRegex.hasMatch(trimmed)) {
      return 'O nome deve conter apenas letras e espaços.';
    }

    return null;
  }

  /// Helper method to get appropriate name prompt based on context.
  static String _getPersonNamePrompt(String context) {
    switch (context.toLowerCase()) {
      case 'patient':
      case 'paciente':
        return 'seu nome completo';
      case 'screener':
      case 'responsavel':
      case 'responsável':
        return 'o nome completo do responsável';
      default:
        return 'o nome completo';
    }
  }

  // =========================
  // EMAIL VALIDATION
  // =========================

  /// Validates email addresses with comprehensive checks.
  ///
  /// This validator performs:
  /// - Required field validation
  /// - Basic structure validation (@ symbol, domain, etc.)
  /// - RFC-compliant email regex validation
  /// - Domain extension validation
  ///
  /// [email] - The email to validate
  /// [context] - Context for personalized error messages
  ///
  /// Returns error string if invalid, null if valid
  static String? validateEmail(String? email, {String? context}) {
    // Check if required
    final requiredError = validateRequired(
      email,
      customMessage: context != null
          ? 'Por favor, insira ${_getEmailPrompt(context)}'
          : 'Por favor, insira um email válido',
    );
    if (requiredError != null) return requiredError;

    final emailTrimmed = email!.trim();

    // Basic structure validation
    if (!emailTrimmed.contains('@')) {
      return 'Email deve conter o símbolo @.';
    }

    if (emailTrimmed.split('@').length != 2) {
      return 'Email deve conter apenas um símbolo @.';
    }

    final parts = emailTrimmed.split('@');
    final localPart = parts[0];
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

    // RFC-compliant email validation
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );

    if (!emailRegex.hasMatch(emailTrimmed)) {
      return 'Por favor, insira um email válido (ex: usuario@exemplo.com).';
    }

    // Domain extension validation
    final domainParts = domainPart.split('.');
    final lastPart = domainParts.last;

    if (lastPart.length < 2) {
      return 'O domínio do email deve ter pelo menos 2 caracteres após o ponto.';
    }

    return null;
  }

  /// Helper method to get appropriate email prompt based on context.
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

  /// Validates birth dates in DD/MM/YYYY format.
  ///
  /// This validator checks for:
  /// - Required field
  /// - Correct DD/MM/YYYY format
  /// - Valid date values
  /// - Date not in the future
  /// - Reasonable date range (1900 to current year)
  ///
  /// [dateText] - The date string to validate
  ///
  /// Returns error string if invalid, null if valid
  static String? validateBirthDate(String? dateText) {
    if (dateText == null || dateText.isEmpty) {
      return 'Por favor, insira sua data de nascimento.';
    }

    // Format validation
    final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!dateRegex.hasMatch(dateText)) {
      return 'Use o formato DD/MM/AAAA (ex: 15/03/1990).';
    }

    try {
      final parts = dateText.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      // Basic range validation
      if (day < 1 || day > 31) {
        return 'Dia deve estar entre 01 e 31.';
      }
      if (month < 1 || month > 12) {
        return 'Mês deve estar entre 01 e 12.';
      }
      if (year < 1900 || year > DateTime.now().year) {
        return 'Ano deve estar entre 1900 e ${DateTime.now().year}.';
      }

      // Create date to validate it's real
      final date = DateTime(year, month, day);
      if (date.day != day || date.month != month || date.year != year) {
        return 'Data inválida.';
      }

      // Check if not in the future
      if (date.isAfter(DateTime.now())) {
        return 'A data de nascimento não pode ser futura.';
      }

      return null;
    } catch (e) {
      return 'Data inválida. Use o formato DD/MM/AAAA.';
    }
  }

  /// Validates general dates in DD/MM/YYYY format.
  ///
  /// Similar to birth date validation but allows future dates
  /// and has a more flexible date range.
  ///
  /// [dateText] - The date string to validate
  /// [allowFuture] - Whether to allow future dates
  /// [fieldName] - Optional field name for error messages
  ///
  /// Returns error string if invalid, null if valid
  static String? validateDate(
    String? dateText, {
    bool allowFuture = true,
    String? fieldName,
  }) {
    final fieldPrompt = fieldName ?? 'a data';

    if (dateText == null || dateText.isEmpty) {
      return 'Por favor, insira $fieldPrompt.';
    }

    final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!dateRegex.hasMatch(dateText)) {
      return 'Use o formato DD/MM/AAAA (ex: 15/03/1990).';
    }

    try {
      final parts = dateText.split('/');
      final day = int.parse(parts[0]);
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
    } catch (e) {
      return 'Data inválida. Use o formato DD/MM/AAAA.';
    }
  }

  // =========================
  // PROFESSION VALIDATION
  // =========================

  /// Validates profession/occupation fields.
  ///
  /// This validator checks for:
  /// - Required field
  /// - Minimum 2 characters
  /// - Optional maximum length
  ///
  /// [profession] - The profession to validate
  /// [maxLength] - Optional maximum length (default: no limit)
  ///
  /// Returns error string if invalid, null if valid
  static String? validateProfession(String? profession, {int? maxLength}) {
    if (profession == null || profession.isEmpty) {
      return 'Por favor, insira sua profissão.';
    }

    if (profession.trim().length < 2) {
      return 'A profissão deve ter pelo menos 2 caracteres.';
    }

    if (maxLength != null && profession.trim().length > maxLength) {
      return 'A profissão deve ter no máximo $maxLength caracteres.';
    }

    return null;
  }

  // =========================
  // MEDICATION VALIDATION
  // =========================

  /// Validates medication lists (comma-separated).
  ///
  /// This validator checks for:
  /// - Required field
  /// - Valid medication names (letters, numbers, spaces, hyphens)
  /// - Individual medication length constraints
  /// - Overall format validation
  ///
  /// [medicationList] - Comma-separated medication list
  ///
  /// Returns error string if invalid, null if valid
  static String? validateMedicationList(String? medicationList) {
    if (medicationList == null || medicationList.isEmpty) {
      return 'Por favor, informe o(s) nome(s) do(s) medicamento(s).';
    }

    // Split by comma and clean up
    final medications = medicationList
        .split(',')
        .map((med) => med.trim())
        .where((med) => med.isNotEmpty)
        .toList();

    if (medications.isEmpty) {
      return 'Por favor, informe pelo menos um medicamento válido.';
    }

    // Validate each medication
    for (final medication in medications) {
      // Character validation
      final medicationRegex = RegExp(r'^[a-zA-Z0-9À-ÿ\s\-]+$');
      if (!medicationRegex.hasMatch(medication)) {
        return 'Medicamento "$medication" contém caracteres inválidos.\nUse apenas letras, números, espaços e hífen.';
      }

      // Length validation
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
  // DROPDOWN VALIDATION
  // =========================

  /// Validates dropdown/selection fields.
  ///
  /// [value] - The selected value
  /// [fieldName] - Name of the field for error messages
  ///
  /// Returns error string if invalid, null if valid
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

  /// Validates general text fields with customizable constraints.
  ///
  /// [value] - The text to validate
  /// [fieldName] - Name of the field
  /// [required] - Whether the field is required
  /// [minLength] - Minimum length (optional)
  /// [maxLength] - Maximum length (optional)
  /// [pattern] - RegExp pattern to validate against (optional)
  /// [patternErrorMessage] - Custom error for pattern mismatch
  ///
  /// Returns error string if invalid, null if valid
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

  /// Combines multiple validators into a single validator function.
  ///
  /// [validators] - List of validator functions to apply
  ///
  /// Returns a validator function that runs all provided validators
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
