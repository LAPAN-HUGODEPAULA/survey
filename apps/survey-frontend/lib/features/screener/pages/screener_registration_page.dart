import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/providers/api_provider.dart';

class ScreenerRegistrationPage extends StatefulWidget {
  const ScreenerRegistrationPage({super.key});

  @override
  State<ScreenerRegistrationPage> createState() =>
      _ScreenerRegistrationPageState();
}

class _ScreenerRegistrationPageState extends State<ScreenerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
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
  final _darvCourseYearController = TextEditingController();

  bool _isLoading = false;

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
    _darvCourseYearController.dispose();
    super.dispose();
  }

  Future<void> _registerScreener() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    final dio = context.read<ApiProvider>().api.dio;

    try {
      final darvCourseYear = int.tryParse(_darvCourseYearController.text.trim());
      final councilTypeRaw = _professionalCouncilTypeController.text.trim();
      final councilType = councilTypeRaw.isEmpty ? 'none' : councilTypeRaw;

      final payload = <String, dynamic>{
        'cpf': _cpfController.text.replaceAll('.', '').replaceAll('-', ''),
        'firstName': _firstNameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'phone': _phoneController.text.trim(),
        'address': {
          'postalCode': _postalCodeController.text.trim(),
          'street': _streetController.text.trim(),
          'number': _numberController.text.trim(),
          'complement': _complementController.text.trim(),
          'neighborhood': _neighborhoodController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
        },
        'professionalCouncil': {
          'type': councilType,
          'registrationNumber':
              _professionalCouncilRegistrationNumberController.text.trim(),
        },
        'jobTitle': _jobTitleController.text.trim(),
        'degree': _degreeController.text.trim(),
        'darvCourseYear': darvCourseYear,
      };

      await dio.post('/screeners/register', data: payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Screener registrado com sucesso!')),
      );
      context.go('/login');
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
      appBar: AppBar(title: const Text('Registro de Screener')),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      controller: _cpfController,
                      label: 'CPF',
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(
                      controller: _firstNameController,
                      label: 'Primeiro Nome',
                    ),
                    _buildTextField(
                      controller: _surnameController,
                      label: 'Sobrenome',
                    ),
                    _buildTextField(
                      controller: _emailController,
                      label: 'E-mail',
                      keyboardType: TextInputType.emailAddress,
                      validator: _emailValidator,
                    ),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Senha',
                      obscureText: true,
                    ),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Telefone',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12.0),
                    Text('Endereço', style: Theme.of(context).textTheme.titleLarge),
                    _buildTextField(
                      controller: _postalCodeController,
                      label: 'CEP',
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(
                      controller: _streetController,
                      label: 'Rua',
                    ),
                    _buildTextField(
                      controller: _numberController,
                      label: 'Número',
                    ),
                    _buildTextField(
                      controller: _complementController,
                      label: 'Complemento (Opcional)',
                      required: false,
                    ),
                    _buildTextField(
                      controller: _neighborhoodController,
                      label: 'Bairro',
                    ),
                    _buildTextField(
                      controller: _cityController,
                      label: 'Cidade',
                    ),
                    _buildTextField(
                      controller: _stateController,
                      label: 'Estado (UF)',
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      'Informações Profissionais',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    _buildTextField(
                      controller: _professionalCouncilTypeController,
                      label: 'Tipo de Conselho (ex: CRP, CRM, none)',
                    ),
                    _buildTextField(
                      controller: _professionalCouncilRegistrationNumberController,
                      label: 'Número de Registro no Conselho',
                    ),
                    _buildTextField(
                      controller: _jobTitleController,
                      label: 'Cargo/Profissão',
                    ),
                    _buildTextField(
                      controller: _degreeController,
                      label: 'Formação Acadêmica/Grau',
                    ),
                    _buildTextField(
                      controller: _darvCourseYearController,
                      label: 'Ano de Conclusão do Curso DARV (Opcional)',
                      keyboardType: TextInputType.number,
                      required: false,
                      validator: _yearValidator,
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _registerScreener,
                      child: const Text('Registrar'),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Já tem uma conta? Faça login'),
                    ),
                  ],
                ),
              ),
            ),
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

  String? _yearValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = int.tryParse(text);
    if (parsed == null) return 'Informe um ano válido.';
    if (parsed < 2000) return 'Ano deve ser 2000 ou posterior.';
    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool required = true,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator ?? (required ? _requiredValidator : null),
      ),
    );
  }
}
