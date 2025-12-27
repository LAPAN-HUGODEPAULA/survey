/// Predefined validator sets for common form field scenarios.
///
/// This library provides convenient validator sets that combine multiple
/// validation rules for common use cases, reducing boilerplate code in forms.
library;

import 'form_validators.dart';

/// Predefined validator sets for common form scenarios.
///
/// This class provides static methods that return validator functions
/// configured for specific field types and contexts.
class ValidatorSets {
  /// Private constructor to prevent instantiation
  ValidatorSets._();

  // =========================
  // PATIENT-SPECIFIC VALIDATORS
  // =========================

  /// Validator for patient name fields.
  ///
  /// Validates:
  /// - Required field
  /// - Minimum 5 characters
  /// - Only letters, spaces, and accents
  static String? Function(String?) get patientName =>
      (value) => FormValidators.validatePersonName(value, context: 'patient');

  /// Validator for patient email fields.
  ///
  /// Validates:
  /// - Required field
  /// - Valid email format
  /// - Domain validation
  static String? Function(String?) get patientEmail =>
      (value) => FormValidators.validateEmail(value, context: 'patient');

  /// Validator for patient birth date fields.
  ///
  /// Validates:
  /// - Required field
  /// - DD/MM/YYYY format
  /// - Valid date
  /// - Not in future
  /// - Reasonable age range
  static String? Function(String?) get patientBirthDate =>
      FormValidators.validateBirthDate;

  /// Validator for patient profession fields.
  ///
  /// Validates:
  /// - Required field
  /// - Minimum 2 characters
  /// - Maximum 100 characters
  static String? Function(String?) get patientProfession =>
      (value) => FormValidators.validateProfession(value, maxLength: 100);

  // =========================
  // SCREENER-SPECIFIC VALIDATORS
  // =========================

  /// Validator for screener name fields.
  ///
  /// Validates:
  /// - Required field
  /// - Minimum 5 characters
  /// - Only letters, spaces, and accents
  static String? Function(String?) get screenerName =>
      (value) => FormValidators.validatePersonName(value, context: 'screener');

  /// Validator for screener email fields.
  ///
  /// Validates:
  /// - Required field
  /// - Valid email format
  /// - Domain validation
  static String? Function(String?) get screenerEmail =>
      (value) => FormValidators.validateEmail(value, context: 'screener');

  // =========================
  // MEDICAL-SPECIFIC VALIDATORS
  // =========================

  /// Validator for medication list fields.
  ///
  /// Validates:
  /// - Required field
  /// - Comma-separated format
  /// - Individual medication name validation
  /// - Character restrictions
  static String? Function(String?) get medicationList =>
      FormValidators.validateMedicationList;

  // =========================
  // COMMON DROPDOWN VALIDATORS
  // =========================

  /// Validator for gender selection dropdown.
  static String? Function(String?) get genderSelection =>
      (value) => FormValidators.validateDropdownSelection(value, 'Sexo');

  /// Validator for race/ethnicity selection dropdown.
  static String? Function(String?) get raceSelection =>
      (value) => FormValidators.validateDropdownSelection(value, 'Raça/Etnia');

  /// Validator for education level selection dropdown.
  static String? Function(String?) get educationLevelSelection =>
      (value) => FormValidators.validateDropdownSelection(
        value,
        'Grau de Escolaridade',
      );

  // =========================
  // CUSTOM VALIDATOR BUILDERS
  // =========================

  /// Creates a validator for text fields with custom requirements.
  ///
  /// [fieldName] - Display name for the field
  /// [required] - Whether the field is required
  /// [minLength] - Minimum character length
  /// [maxLength] - Maximum character length
  /// [allowOnlyLetters] - Whether to allow only letters and spaces
  ///
  /// Returns a configured validator function
  static String? Function(String?) customTextField({
    required String fieldName,
    bool required = true,
    int? minLength,
    int? maxLength,
    bool allowOnlyLetters = false,
  }) {
    return (String? value) {
      return FormValidators.validateTextField(
        value,
        fieldName: fieldName,
        required: required,
        minLength: minLength,
        maxLength: maxLength,
        pattern: allowOnlyLetters ? RegExp(r'^[a-zA-ZÀ-ÿ\s]+$') : null,
        patternErrorMessage: allowOnlyLetters
            ? '$fieldName deve conter apenas letras e espaços'
            : null,
      );
    };
  }

  /// Creates a validator for dropdown selection fields.
  ///
  /// [fieldName] - Display name for the field
  /// [customMessage] - Custom error message
  ///
  /// Returns a configured validator function
  static String? Function(String?) customDropdown({
    required String fieldName,
    String? customMessage,
  }) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return customMessage ?? '$fieldName é obrigatório';
      }
      return null;
    };
  }

  /// Creates a validator for optional text fields.
  ///
  /// [fieldName] - Display name for the field
  /// [maxLength] - Maximum character length
  ///
  /// Returns a configured validator function
  static String? Function(String?) optionalTextField({
    String? fieldName,
    int? maxLength,
  }) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) return null;

      if (maxLength != null && value.trim().length > maxLength) {
        return fieldName != null
            ? '$fieldName deve ter no máximo $maxLength caracteres'
            : 'Deve ter no máximo $maxLength caracteres';
      }

      return null;
    };
  }

  // =========================
  // VALIDATION UTILITIES
  // =========================

  /// Checks if a field should show validation errors.
  ///
  /// Useful for conditional validation display based on user interaction.
  ///
  /// [hasAttemptedSubmit] - Whether the user has attempted to submit the form
  /// [hasFocus] - Whether the field currently has focus
  /// [hasInteracted] - Whether the user has interacted with the field
  ///
  /// Returns true if validation errors should be shown
  static bool shouldShowValidationError({
    required bool hasAttemptedSubmit,
    bool hasFocus = false,
    bool hasInteracted = false,
  }) {
    // Show errors after submit attempt or after user has interacted and left the field
    return hasAttemptedSubmit || (hasInteracted && !hasFocus);
  }

  /// Creates a conditional validator that only validates under certain conditions.
  ///
  /// [validator] - The base validator function
  /// [condition] - Function that returns whether validation should occur
  ///
  /// Returns a conditional validator function
  static String? Function(String?) conditionalValidator(
    String? Function(String?) validator,
    bool Function() condition,
  ) {
    return (String? value) {
      if (condition()) {
        return validator(value);
      }
      return null;
    };
  }

  /// Creates a validator that only runs when a specific value is selected.
  ///
  /// Useful for conditional fields (e.g., medication name when "uses medication" is "Yes").
  ///
  /// [validator] - The base validator function
  /// [triggerValue] - The value that triggers validation
  /// [currentSelection] - The currently selected value
  ///
  /// Returns a conditional validator function
  static String? Function(String?) valueTriggeredValidator(
    String? Function(String?) validator,
    String triggerValue,
    String? currentSelection,
  ) {
    return (String? value) {
      if (currentSelection == triggerValue) {
        return validator(value);
      }
      return null;
    };
  }
}
