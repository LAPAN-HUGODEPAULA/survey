class DsFormValidators {
  DsFormValidators._();

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

  static String? validateBirthDate(String? dateText) {
    final requiredError = validateRequired(
      dateText,
      customMessage: 'Por favor, insira sua data de nascimento',
    );
    if (requiredError != null) {
      return requiredError;
    }

    final trimmed = dateText!.trim();
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(trimmed)) {
      return 'Use o formato DD/MM/AAAA.';
    }

    final parts = trimmed.split('/');
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return 'Data inválida.';
    }

    DateTime parsedDate;
    try {
      parsedDate = DateTime(year, month, day);
    } catch (_) {
      return 'Data inválida.';
    }

    if (parsedDate.day != day ||
        parsedDate.month != month ||
        parsedDate.year != year) {
      return 'Data inválida.';
    }

    final now = DateTime.now();
    if (parsedDate.isAfter(now)) {
      return 'A data não pode estar no futuro.';
    }
    if (year < 1900) {
      return 'Ano inválido.';
    }
    return null;
  }

  static String? validateProfession(String? value, {int maxLength = 100}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed.length < 2) {
      return 'A profissão deve ter pelo menos 2 caracteres.';
    }
    if (trimmed.length > maxLength) {
      return 'A profissão deve ter no máximo $maxLength caracteres.';
    }
    return null;
  }

  static String? validateDropdownSelection(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  static String? validateMedicalRecordId(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Campo obrigatório';
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
}
