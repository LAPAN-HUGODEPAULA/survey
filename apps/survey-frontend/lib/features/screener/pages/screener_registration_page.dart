import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/providers/api_provider.dart';

const _viaCepBaseUrlEnv = String.fromEnvironment(
  'VIACEP_BASE_URL',
  defaultValue: '',
);

class ScreenerRegistrationPage extends StatefulWidget {
  const ScreenerRegistrationPage({super.key});

  @override
  State<ScreenerRegistrationPage> createState() =>
      _ScreenerRegistrationPageState();
}

class _ScreenerRegistrationPageState extends State<ScreenerRegistrationPage> {
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
  bool _cpfEditing = false;
  int? _selectedDarvYear;

  bool _isLoading = false;

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

  Future<void> _registerScreener() async {
    _cpfEditing = false;
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    final dio = context.read<ApiProvider>().api.dio;

    try {
      final councilTypeRaw = _professionalCouncilTypeController.text.trim();
      final councilType = _normalizeCouncilType(councilTypeRaw);

      final phoneDigits = _digitsOnly(_phoneController.text);
      final payload = <String, dynamic>{
        'cpf': _digitsOnly(_cpfController.text),
        'firstName': _firstNameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'phone': phoneDigits,
        'address': {
          'postalCode': _digitsOnly(_postalCodeController.text),
          'street': _streetController.text.trim(),
          'number': _numberController.text.trim(),
          'complement': _complementController.text.trim(),
          'neighborhood': _neighborhoodController.text.trim(),
          'city': _cityController.text.trim(),
          'state': (_selectedState ?? _stateController.text).trim(),
        },
        'professionalCouncil': {
          'type': councilType,
          'registrationNumber':
              _professionalCouncilRegistrationNumberController.text.trim(),
        },
        'jobTitle': _jobTitleController.text.trim(),
        'degree': _degreeController.text.trim(),
        'darvCourseYear': _selectedDarvYear,
      };

      await dio.post('/screeners/register', data: payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avaliador registrado com sucesso!')),
      );
      context.go('/login');
    } on DioException catch (e) {
      if (!mounted) return;
      final message = _buildDioErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha no registro: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Avaliador')),
      body: Stack(
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                      validator: _cpfValidator,
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
                      validator: _emailValidator,
                    ),
                    _buildTextField(
                      controller: _passwordController,
                      wrapperKey: const ValueKey('screener-registration-password'),
                      label: 'Senha',
                      obscureText: true,
                    ),
                    _buildTextField(
                      controller: _phoneController,
                      wrapperKey: const ValueKey('screener-registration-phone'),
                      label: 'Telefone',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [_PhoneNumberInputFormatter()],
                    ),
                    const SizedBox(height: 12.0),
                    Text('Endereço', style: Theme.of(context).textTheme.titleLarge),
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
                      validator: _cepValidator,
                    ),
                    _buildTextField(
                      controller: _streetController,
                      wrapperKey: const ValueKey('screener-registration-street'),
                      label: 'Rua',
                    ),
                    _buildTextField(
                      controller: _numberController,
                      wrapperKey: const ValueKey('screener-registration-number'),
                      label: 'Número',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    _buildTextField(
                      controller: _complementController,
                      wrapperKey: const ValueKey('screener-registration-complement'),
                      label: 'Complemento (Opcional)',
                      required: false,
                    ),
                    _buildTextField(
                      controller: _neighborhoodController,
                      wrapperKey:
                          const ValueKey('screener-registration-neighborhood'),
                      label: 'Bairro',
                    ),
                    _buildTextField(
                      controller: _cityController,
                      wrapperKey: const ValueKey('screener-registration-city'),
                      label: 'Cidade',
                    ),
                    _buildStateDropdown(),
                    const SizedBox(height: 12.0),
                    Text(
                      'Informações Profissionais',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    _buildTextField(
                      controller: _professionalCouncilTypeController,
                      wrapperKey:
                          const ValueKey('screener-registration-council-type'),
                      label: 'Tipo de Conselho (ex: CRP, CRM) ou "Nenhum"',
                      required: false,
                      validator: _councilTypeValidator,
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
                      validator: _councilRegistrationValidator,
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
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _registerScreener,
                      child: const Text('Registrar'),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Já tem uma conta? Entre'),
                    ),
                  ],
                ),
              ),
            ),),
          ),
          if (_isLoading)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.1),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Campo obrigatório.';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Campo obrigatório.';
    if (!text.contains('@')) return 'E-mail inválido.';
    return null;
  }

  String? _cpfValidator(String? value) {
    if (_cpfEditing) return null;
    final digits = _digitsOnly(value ?? '');
    if (digits.isEmpty) return 'Campo obrigatório.';
    if (!_isValidCpf(digits)) return 'CPF inválido.';
    return null;
  }

  String? _cepValidator(String? value) {
    final digits = _digitsOnly(value ?? '');
    if (digits.isEmpty) return 'Campo obrigatório.';
    if (digits.length != 8) return 'CEP deve ter 8 dígitos.';
    return null;
  }

  String? _councilTypeValidator(String? value) {
    final normalized = _normalizeCouncilType((value ?? '').trim());
    if (normalized == 'none') return null;
    if (!_allowedCouncilTypes.contains(normalized)) {
      return 'Tipo de conselho inválido.';
    }
    return null;
  }

  String? _councilRegistrationValidator(String? value) {
    final normalizedType =
        _normalizeCouncilType(_professionalCouncilTypeController.text.trim());
    final registration = (value ?? '').trim();
    if (registration.isNotEmpty && normalizedType == 'none') {
      return 'Informe o tipo de conselho.';
    }
    if (registration.isEmpty && normalizedType != 'none') {
      return 'Informe o número de registro.';
    }
    return null;
  }

  String _buildDioErrorMessage(DioException error) {
    final response = error.response;
    final detail = _extractErrorDetail(response?.data);
    if (detail != null && detail.isNotEmpty) {
      return 'Falha no registro: $detail';
    }
    if (response?.statusCode != null) {
      return 'Falha no registro (HTTP ${response?.statusCode}).';
    }
    return 'Falha no registro: ${error.message ?? 'Erro de conexão.'}';
  }

  Uri _buildViaCepUri(String digits) {
    if (_viaCepBaseUrlEnv.isEmpty) {
      throw StateError('VIACEP_BASE_URL is not set.');
    }
    final baseUrl = _viaCepBaseUrlEnv.endsWith('/')
        ? _viaCepBaseUrlEnv
        : '$_viaCepBaseUrlEnv/';
    return Uri.parse(baseUrl).resolve('ws/$digits/json/');
  }

  Future<void> _lookupCep() async {
    final digits = _digitsOnly(_postalCodeController.text);
    if (digits.length != 8) return;

    try {
      final response = await Dio().getUri(
        _buildViaCepUri(digits),
        options: Options(responseType: ResponseType.json),
      );
      final data = response.data;
      if (data is! Map || data['erro'] == true) return;

      _streetController.text = (data['logradouro'] ?? '').toString();
      _neighborhoodController.text = (data['bairro'] ?? '').toString();
      _cityController.text = (data['localidade'] ?? '').toString();
      final uf = (data['uf'] ?? '').toString().toUpperCase();
      if (_brazilStates.contains(uf)) {
        setState(() {
          _selectedState = uf;
          _stateController.text = uf;
        });
      }
    } catch (_) {
      // Ignore lookup errors to avoid blocking the form.
    }
  }

  String _digitsOnly(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  bool _isValidCpf(String cpf) {
    if (cpf.length != 11) return false;
    if (RegExp(r'^(\d)\1+$').hasMatch(cpf)) return false;

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

  Widget _buildStateDropdown() {
    return Padding(
      key: const ValueKey('screener-registration-state'),
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        key: _stateFieldKey,
        initialValue: _selectedState,
        decoration: const InputDecoration(
          labelText: 'Estado (UF) *',
          border: OutlineInputBorder(),
        ),
        items: _brazilStates
            .map(
              (state) => DropdownMenuItem<String>(
                value: state,
                child: Text(state),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedState = value;
            _stateController.text = value ?? '';
          });
        },
        validator: (value) {
          if ((value ?? '').trim().isEmpty) return 'Campo obrigatório.';
          if (!_brazilStates.contains(value)) return 'UF inválida.';
          return null;
        },
      ),
    );
  }

  Widget _buildDarvYearDropdown() {
    final currentYear = DateTime.now().year;
    final years = [
      for (var year = currentYear; year >= 2001; year--) year,
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
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
            .toList(),
        onChanged: (value) {
          setState(() => _selectedDarvYear = value);
        },
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
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    AutovalidateMode? autovalidateMode,
  }) {
    final labelText = required ? '$label *' : label;
    return Padding(
      key: wrapperKey,
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        key: fieldKey,
        controller: controller,
        keyboardType: keyboardType,
        focusNode: focusNode,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        autovalidateMode: autovalidateMode,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
        validator: validator ?? (required ? _requiredValidator : null),
      ),
    );
  }
}

String? _extractErrorDetail(dynamic data) {
  if (data is Map<String, dynamic>) {
    final detail = data['detail'];
    if (detail is String) return detail;
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map<String, dynamic> && first['msg'] is String) {
        return first['msg'] as String;
      }
    }
  }
  return null;
}

String _normalizeCouncilType(String councilTypeRaw) {
  if (councilTypeRaw.isEmpty) return 'none';
  final lower = councilTypeRaw.toLowerCase();
  if (lower == 'nenhum' || lower == 'none') return 'none';
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
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      if (i == 7) buffer.write('-');
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
