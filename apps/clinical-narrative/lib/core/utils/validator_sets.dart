library;

class ValidatorSets {
  ValidatorSets._();

  static String? validatePersonName(String? value, {String context = 'patient'}) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    if (value.length < 5) {
      return 'O nome deve ter no mínimo 5 caracteres';
    }
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(value)) {
      return 'O nome deve conter apenas letras e espaços';
    }
    return null;
  }

  static String? Function(String?) get patientName =>
      (value) => validatePersonName(value, context: 'patient');
}

