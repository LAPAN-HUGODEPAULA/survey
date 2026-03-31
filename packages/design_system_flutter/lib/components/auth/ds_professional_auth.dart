import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system_flutter/widgets/ds_buttons.dart';

class DsAuthOperationResult {
  const DsAuthOperationResult._({
    required this.isSuccess,
    this.message,
  });

  const DsAuthOperationResult.success([String? message])
      : this._(isSuccess: true, message: message);

  const DsAuthOperationResult.error(String message)
      : this._(isSuccess: false, message: message);

  final bool isSuccess;
  final String? message;
}

class DsScreenerLoginData {
  const DsScreenerLoginData({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

class DsCepLookupResult {
  const DsCepLookupResult({
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
  });

  final String street;
  final String neighborhood;
  final String city;
  final String state;
}

class DsScreenerRegistrationData {
  const DsScreenerRegistrationData({
    required this.cpf,
    required this.firstName,
    required this.surname,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
    required this.professionalCouncil,
    required this.jobTitle,
    required this.degree,
    required this.darvCourseYear,
  });

  final String cpf;
  final String firstName;
  final String surname;
  final String email;
  final String password;
  final String phone;
  final DsScreenerAddressData address;
  final DsProfessionalCouncilData professionalCouncil;
  final String jobTitle;
  final String degree;
  final int? darvCourseYear;
}

class DsScreenerAddressData {
  const DsScreenerAddressData({
    required this.postalCode,
    required this.street,
    required this.number,
    required this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
  });

  final String postalCode;
  final String street;
  final String number;
  final String complement;
  final String neighborhood;
  final String city;
  final String state;
}

class DsProfessionalCouncilData {
  const DsProfessionalCouncilData({
    required this.type,
    required this.registrationNumber,
  });

  final String type;
  final String registrationNumber;
}

typedef DsLoginSubmitCallback = Future<DsAuthOperationResult?> Function(
    DsScreenerLoginData data);
typedef DsPasswordRecoveryCallback = Future<DsAuthOperationResult?> Function(
    String email);
typedef DsRegistrationSubmitCallback = Future<DsAuthOperationResult?> Function(
    DsScreenerRegistrationData data);
typedef DsCepLookupCallback = Future<DsCepLookupResult?> Function(String cep);

class DsProfessionalAuthPanel extends StatelessWidget {
  const DsProfessionalAuthPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.header,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (header != null) ...[
                Center(child: header!),
                const SizedBox(height: 24),
              ],
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colorScheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 24),
                      child,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DsProfessionalSignInCard extends StatefulWidget {
  const DsProfessionalSignInCard({
    super.key,
    required this.onSubmit,
    this.onForgotPassword,
    this.onShowSignUp,
    this.header,
    this.title = 'Entrar',
    this.subtitle =
        'Acesse com sua conta profissional cadastrada para continuar.',
  });

  final DsLoginSubmitCallback onSubmit;
  final DsPasswordRecoveryCallback? onForgotPassword;
  final VoidCallback? onShowSignUp;
  final Widget? header;
  final String title;
  final String subtitle;

  @override
  State<DsProfessionalSignInCard> createState() =>
      _DsProfessionalSignInCardState();
}

class _DsProfessionalSignInCardState extends State<DsProfessionalSignInCard> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSubmitting = false;
  String? _feedbackMessage;
  bool _feedbackIsError = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _feedbackMessage = null;
    });

    try {
      final result = await widget.onSubmit(
        DsScreenerLoginData(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
      if (!mounted || result == null || result.message == null) {
        return;
      }
      setState(() {
        _feedbackMessage = result.message;
        _feedbackIsError = !result.isSuccess;
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _recoverPassword() async {
    if (widget.onForgotPassword == null) {
      return;
    }

    final email = _emailController.text.trim();
    final validation = _validateEmail(email);
    if (validation != null) {
      setState(() {
        _feedbackMessage = validation;
        _feedbackIsError = true;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _feedbackMessage = null;
    });

    try {
      final result = await widget.onForgotPassword!(email);
      if (!mounted || result == null || result.message == null) {
        return;
      }
      setState(() {
        _feedbackMessage = result.message;
        _feedbackIsError = !result.isSuccess;
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Informe o e-mail.';
    }
    if (!text.contains('@')) {
      return 'E-mail inválido.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Informe a senha.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return DsProfessionalAuthPanel(
      header: widget.header,
      title: widget.title,
      subtitle: widget.subtitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DsFeedbackBanner(
              message: _feedbackMessage,
              isError: _feedbackIsError,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: _validatePassword,
            ),
            const SizedBox(height: 16),
            DsFilledButton(
              label: 'Entrar',
              onPressed: _submit,
              loading: _isSubmitting,
            ),
            if (widget.onShowSignUp != null)
              DsTextButton(
                label: 'Não tem uma conta? Registre-se',
                onPressed: _isSubmitting ? null : widget.onShowSignUp,
              ),
            if (widget.onForgotPassword != null)
              DsTextButton(
                label: 'Esqueceu a senha?',
                onPressed: _isSubmitting ? null : _recoverPassword,
              ),
          ],
        ),
      ),
    );
  }
}

class DsProfessionalSignUpCard extends StatefulWidget {
  const DsProfessionalSignUpCard({
    super.key,
    required this.onSubmit,
    this.onLookupCep,
    this.onShowSignIn,
    this.header,
    this.title = 'Criar conta profissional',
    this.subtitle =
        'Use seus dados profissionais cadastráveis na plataforma para acessar os fluxos protegidos.',
  });

  final DsRegistrationSubmitCallback onSubmit;
  final DsCepLookupCallback? onLookupCep;
  final VoidCallback? onShowSignIn;
  final Widget? header;
  final String title;
  final String subtitle;

  @override
  State<DsProfessionalSignUpCard> createState() =>
      _DsProfessionalSignUpCardState();
}

class _DsProfessionalSignUpCardState extends State<DsProfessionalSignUpCard> {
  final _formKey = GlobalKey<FormState>();
  final _cpfFieldKey = GlobalKey<FormFieldState<String>>();
  final _postalCodeFieldKey = GlobalKey<FormFieldState<String>>();
  final _stateFieldKey = GlobalKey<FormFieldState<String>>();
  final _cpfController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _professionalCouncilTypeController = TextEditingController();
  final _professionalCouncilRegistrationNumberController =
      TextEditingController();
  final _jobTitleController = TextEditingController();
  final _degreeController = TextEditingController();
  final _cpfFocusNode = FocusNode();
  final _postalCodeFocusNode = FocusNode();

  String? _selectedState;
  int? _selectedDarvYear;
  bool _cpfEditing = false;
  bool _isLoading = false;
  bool _isLookingUpCep = false;
  String? _lastLookedUpCep;
  String? _feedbackMessage;
  bool _feedbackIsError = true;

  @override
  void initState() {
    super.initState();
    _cpfFocusNode.addListener(() {
      if (_cpfFocusNode.hasFocus) {
        setState(() => _cpfEditing = true);
      } else {
        _cpfEditing = false;
        _cpfFieldKey.currentState?.validate();
      }
    });
    _postalCodeFocusNode.addListener(() {
      if (!_postalCodeFocusNode.hasFocus) {
        _postalCodeFieldKey.currentState?.validate();
        _lookupCep();
      }
    });
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _firstNameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _postalCodeController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _professionalCouncilTypeController.dispose();
    _professionalCouncilRegistrationNumberController.dispose();
    _jobTitleController.dispose();
    _degreeController.dispose();
    _cpfFocusNode.dispose();
    _postalCodeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _cpfEditing = false;
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _feedbackMessage = null;
    });

    try {
      final result = await widget.onSubmit(
        DsScreenerRegistrationData(
          cpf: _digitsOnly(_cpfController.text),
          firstName: _firstNameController.text.trim(),
          surname: _surnameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _digitsOnly(_phoneController.text),
          address: DsScreenerAddressData(
            postalCode: _digitsOnly(_postalCodeController.text),
            street: _streetController.text.trim(),
            number: _numberController.text.trim(),
            complement: _complementController.text.trim(),
            neighborhood: _neighborhoodController.text.trim(),
            city: _cityController.text.trim(),
            state: (_selectedState ?? _stateController.text).trim(),
          ),
          professionalCouncil: DsProfessionalCouncilData(
            type: _normalizeCouncilType(
              _professionalCouncilTypeController.text.trim(),
            ),
            registrationNumber:
                _professionalCouncilRegistrationNumberController.text.trim(),
          ),
          jobTitle: _jobTitleController.text.trim(),
          degree: _degreeController.text.trim(),
          darvCourseYear: _selectedDarvYear,
        ),
      );
      if (!mounted || result == null || result.message == null) {
        return;
      }
      setState(() {
        _feedbackMessage = result.message;
        _feedbackIsError = !result.isSuccess;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _lookupCep() async {
    final digits = _digitsOnly(_postalCodeController.text);
    if (widget.onLookupCep == null || digits.length != 8) {
      return;
    }
    if (_isLookingUpCep || _lastLookedUpCep == digits) {
      return;
    }

    setState(() => _isLookingUpCep = true);
    try {
      final result = await widget.onLookupCep!(digits);
      if (result == null || !mounted) {
        return;
      }
      _streetController.text = result.street;
      _neighborhoodController.text = result.neighborhood;
      _cityController.text = result.city;
      if (_brazilStates.contains(result.state)) {
        setState(() {
          _selectedState = result.state;
          _stateController.text = result.state;
        });
      }
      _lastLookedUpCep = digits;
    } finally {
      if (mounted) {
        setState(() => _isLookingUpCep = false);
      } else {
        _isLookingUpCep = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DsProfessionalAuthPanel(
      header: widget.header,
      title: widget.title,
      subtitle: widget.subtitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DsFeedbackBanner(
              message: _feedbackMessage,
              isError: _feedbackIsError,
            ),
            _buildTextField(
              fieldKey: _cpfFieldKey,
              controller: _cpfController,
              wrapperKey: const ValueKey('screener-registration-cpf'),
              label: 'CPF',
              keyboardType: TextInputType.number,
              focusNode: _cpfFocusNode,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: _validateCpf,
            ),
            _buildTextField(
              controller: _firstNameController,
              wrapperKey: const ValueKey('screener-registration-first-name'),
              label: 'Primeiro Nome',
            ),
            _buildTextField(
              controller: _surnameController,
              wrapperKey: const ValueKey('screener-registration-surname'),
              label: 'Sobrenome',
            ),
            _buildTextField(
              controller: _emailController,
              wrapperKey: const ValueKey('screener-registration-email'),
              label: 'E-mail',
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            _buildTextField(
              controller: _passwordController,
              wrapperKey: const ValueKey('screener-registration-password'),
              label: 'Senha',
              obscureText: true,
              validator: _validatePasswordLength,
            ),
            _buildTextField(
              controller: _phoneController,
              wrapperKey: const ValueKey('screener-registration-phone'),
              label: 'Telefone',
              keyboardType: TextInputType.phone,
              inputFormatters: [_PhoneNumberInputFormatter()],
            ),
            const SizedBox(height: 12),
            Text(
              'Endereço',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              fieldKey: _postalCodeFieldKey,
              controller: _postalCodeController,
              wrapperKey: const ValueKey('screener-registration-postal-code'),
              label: 'CEP',
              keyboardType: TextInputType.number,
              focusNode: _postalCodeFocusNode,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              validator: _validateCep,
              onChanged: (value) {
                final digits = _digitsOnly(value);
                if (digits.length != 8) {
                  _lastLookedUpCep = null;
                  return;
                }
                if (_lastLookedUpCep != digits) {
                  _lookupCep();
                }
              },
            ),
            _buildTextField(
              controller: _streetController,
              wrapperKey: const ValueKey('screener-registration-street'),
              label: 'Rua',
              readOnly: _isLookingUpCep,
            ),
            _buildTextField(
              controller: _numberController,
              wrapperKey: const ValueKey('screener-registration-number'),
              label: 'Número',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            _buildTextField(
              controller: _complementController,
              wrapperKey: const ValueKey('screener-registration-complement'),
              label: 'Complemento (Opcional)',
              required: false,
            ),
            _buildTextField(
              controller: _neighborhoodController,
              wrapperKey: const ValueKey('screener-registration-neighborhood'),
              label: 'Bairro',
              readOnly: _isLookingUpCep,
            ),
            _buildTextField(
              controller: _cityController,
              wrapperKey: const ValueKey('screener-registration-city'),
              label: 'Cidade',
              readOnly: _isLookingUpCep,
            ),
            _buildStateDropdown(),
            const SizedBox(height: 12),
            Text(
              'Informações Profissionais',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _professionalCouncilTypeController,
              wrapperKey: const ValueKey('screener-registration-council-type'),
              label: 'Tipo de Conselho (ex: CRP, CRM) ou "Nenhum"',
              required: false,
              validator: _validateCouncilType,
            ),
            _buildTextField(
              controller: _professionalCouncilRegistrationNumberController,
              wrapperKey: const ValueKey(
                'screener-registration-council-registration',
              ),
              label: 'Número de Registro no Conselho',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              required: false,
              validator: _validateCouncilRegistration,
            ),
            _buildTextField(
              controller: _jobTitleController,
              wrapperKey: const ValueKey('screener-registration-job-title'),
              label: 'Cargo/Profissão',
            ),
            _buildTextField(
              controller: _degreeController,
              wrapperKey: const ValueKey('screener-registration-degree'),
              label: 'Formação Acadêmica/Grau',
            ),
            _buildDarvYearDropdown(),
            const SizedBox(height: 16),
            DsFilledButton(
              label: 'Registrar',
              onPressed: _submit,
              loading: _isLoading,
            ),
            if (widget.onShowSignIn != null)
              DsTextButton(
                label: 'Já tem uma conta? Entre',
                onPressed: _isLoading ? null : widget.onShowSignIn,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    GlobalKey<FormFieldState<String>>? fieldKey,
    required TextEditingController controller,
    Key? wrapperKey,
    required String label,
    TextInputType? keyboardType,
    FocusNode? focusNode,
    bool obscureText = false,
    bool required = true,
    bool readOnly = false,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    AutovalidateMode? autovalidateMode,
    ValueChanged<String>? onChanged,
  }) {
    final labelText = required ? '$label *' : label;
    return Padding(
      key: wrapperKey,
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        key: fieldKey,
        controller: controller,
        keyboardType: keyboardType,
        focusNode: focusNode,
        obscureText: obscureText,
        readOnly: readOnly,
        inputFormatters: inputFormatters,
        autovalidateMode: autovalidateMode,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
        validator: validator ?? (required ? _validateRequired : null),
      ),
    );
  }

  Widget _buildStateDropdown() {
    return Padding(
      key: const ValueKey('screener-registration-state'),
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        key: _stateFieldKey,
        initialValue: _selectedState,
        decoration: const InputDecoration(
          labelText: 'Estado (UF) *',
          border: OutlineInputBorder(),
        ),
        items: _brazilStates
            .map(
              (state) =>
                  DropdownMenuItem<String>(value: state, child: Text(state)),
            )
            .toList(growable: false),
        onChanged: _isLookingUpCep
            ? null
            : (value) {
                setState(() {
                  _selectedState = value;
                  _stateController.text = value ?? '';
                });
              },
        validator: (value) {
          if ((value ?? '').trim().isEmpty) {
            return 'Campo obrigatório.';
          }
          if (!_brazilStates.contains(value)) {
            return 'UF inválida.';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDarvYearDropdown() {
    final currentYear = DateTime.now().year;
    final years = [for (var year = currentYear; year >= 2001; year--) year];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int>(
        initialValue: _selectedDarvYear,
        decoration: const InputDecoration(
          labelText: 'Ano de Conclusão do Curso DARV (Opcional)',
          border: OutlineInputBorder(),
        ),
        items: years
            .map(
              (year) => DropdownMenuItem<int>(
                value: year,
                child: Text(year.toString()),
              ),
            )
            .toList(growable: false),
        onChanged: (value) {
          setState(() => _selectedDarvYear = value);
        },
      ),
    );
  }

  String? _validateRequired(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Campo obrigatório.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Informe o e-mail.';
    }
    if (!text.contains('@')) {
      return 'E-mail inválido.';
    }
    return null;
  }

  String? _validatePasswordLength(String? value) {
    final text = value ?? '';
    if (text.isEmpty) {
      return 'Campo obrigatório.';
    }
    if (text.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres.';
    }
    return null;
  }

  String? _validateCpf(String? value) {
    if (_cpfEditing) {
      return null;
    }
    final digits = _digitsOnly(value ?? '');
    if (digits.isEmpty) {
      return 'Campo obrigatório.';
    }
    if (!_isValidCpf(digits)) {
      return 'CPF inválido.';
    }
    return null;
  }

  String? _validateCep(String? value) {
    final digits = _digitsOnly(value ?? '');
    if (digits.isEmpty) {
      return 'Campo obrigatório.';
    }
    if (digits.length != 8) {
      return 'CEP deve ter 8 dígitos.';
    }
    return null;
  }

  String? _validateCouncilType(String? value) {
    final normalized = _normalizeCouncilType((value ?? '').trim());
    if (normalized == 'none') {
      return null;
    }
    if (!_allowedCouncilTypes.contains(normalized)) {
      return 'Tipo de conselho inválido.';
    }
    return null;
  }

  String? _validateCouncilRegistration(String? value) {
    final normalizedType = _normalizeCouncilType(
      _professionalCouncilTypeController.text.trim(),
    );
    final registration = (value ?? '').trim();
    if (registration.isNotEmpty && normalizedType == 'none') {
      return 'Informe o tipo de conselho.';
    }
    if (registration.isEmpty && normalizedType != 'none') {
      return 'Informe o número de registro.';
    }
    return null;
  }

  String _digitsOnly(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  bool _isValidCpf(String cpf) {
    if (cpf.length != 11) {
      return false;
    }
    if (RegExp(r'^(\d)\1+$').hasMatch(cpf)) {
      return false;
    }

    int calcDigit(String base, int factor) {
      var sum = 0;
      for (var i = 0; i < base.length; i++) {
        sum += int.parse(base[i]) * (factor - i);
      }
      final remainder = sum % 11;
      return remainder < 2 ? 0 : 11 - remainder;
    }

    final digit1 = calcDigit(cpf.substring(0, 9), 10);
    final digit2 = calcDigit(cpf.substring(0, 9) + digit1.toString(), 11);
    return cpf.endsWith('$digit1$digit2');
  }
}

class _DsFeedbackBanner extends StatelessWidget {
  const _DsFeedbackBanner({
    required this.message,
    required this.isError,
  });

  final String? message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor =
        isError ? colorScheme.errorContainer : colorScheme.secondaryContainer;
    final foregroundColor = isError
        ? colorScheme.onErrorContainer
        : colorScheme.onSecondaryContainer;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message!,
        style: TextStyle(color: foregroundColor),
      ),
    );
  }
}

String _normalizeCouncilType(String councilTypeRaw) {
  if (councilTypeRaw.isEmpty) {
    return 'none';
  }
  final lower = councilTypeRaw.toLowerCase();
  if (lower == 'nenhum' || lower == 'none') {
    return 'none';
  }
  return councilTypeRaw.toUpperCase();
}

const Set<String> _allowedCouncilTypes = {
  'CFEP',
  'CRP',
  'COREN',
  'CRM',
  'CREFITO',
  'CREFONO',
  'CRN',
  'none',
};

class _PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;

    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      final digit = limited[i];
      if (i == 0) {
        buffer.write('(');
      }
      if (i == 2) {
        buffer.write(') ');
      }
      if (i == 7) {
        buffer.write('-');
      }
      buffer.write(digit);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

const List<String> _brazilStates = [
  'AC',
  'AL',
  'AP',
  'AM',
  'BA',
  'CE',
  'DF',
  'ES',
  'GO',
  'MA',
  'MT',
  'MS',
  'MG',
  'PA',
  'PB',
  'PR',
  'PE',
  'PI',
  'RJ',
  'RN',
  'RS',
  'RO',
  'RR',
  'SC',
  'SP',
  'SE',
  'TO',
];
