import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/providers/api_provider.dart';
import 'package:survey_app/core/utils/form_validators.dart';
import 'package:survey_app/core/utils/validator_sets.dart';
import 'package:survey_app/shared/widgets/custom_text_form_field.dart';
import 'package:survey_app/shared/widgets/loading_button.dart';
import 'package:survey_app/shared/widgets/progress_indicator_modal.dart';
import 'package:survey_backend_api/survey_backend_api.dart'; // Generated client


class ScreenerRegistrationPage extends StatefulWidget {
  const ScreenerRegistrationPage({super.key});

  @override
  State<ScreenerRegistrationPage> createState() => _ScreenerRegistrationPageState();
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
  final _professionalCouncilRegistrationNumberController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _degreeController = TextEditingController();
  final _darvCourseYearController = TextEditingController();

  bool _isLoading = false; // State for loading indicator

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
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final apiProvider = Provider.of<ApiProvider>(context, listen: false);
      final api = apiProvider.api;

      try {
        final screenerRegister = ScreenerRegister((b) => b
          ..cpf = _cpfController.text.replaceAll('.', '').replaceAll('-', '')
          ..firstName = _firstNameController.text
          ..surname = _surnameController.text
          ..email = _emailController.text
          ..password = _passwordController.text
          ..phone = _phoneController.text
          ..address.postalCode = _postalCodeController.text
          ..address.street = _streetController.text
          ..address.number = _numberController.text
          ..address.complement = _complementController.text
          ..address.neighborhood = _neighborhoodController.text
          ..address.city = _cityController.text
          ..address.state = _stateController.text
          ..professionalCouncil.type = _professionalCouncilTypeController.text
          ..professionalCouncil.registrationNumber = _professionalCouncilRegistrationNumberController.text
          ..jobTitle = _jobTitleController.text
          ..degree = _degreeController.text
          ..darvCourseYear = int.tryParse(_darvCourseYearController.text));

        await api.getDefaultApi().registerScreener(screenerRegister: screenerRegister);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Screener registered successfully!')),
          );
          context.go('/login'); // Navigate to login page
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgressIndicatorModal(
      inAsyncCall: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registro de Screener'),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextFormField(
                    controller: _cpfController,
                    labelText: 'CPF',
                    keyboardType: TextInputType.number,
                    validator: FormValidators.compose([
                      ValidatorSets.required,
                      FormValidators.cpf,
                    ]),
                  ),
                  CustomTextFormField(
                    controller: _firstNameController,
                    labelText: 'Nome',
                    validator: ValidatorSets.required,
                  ),
                  CustomTextFormField(
                    controller: _surnameController,
                    labelText: 'Sobrenome',
                    validator: ValidatorSets.required,
                  ),
                  CustomTextFormField(
                    controller: _emailController,
                    labelText: 'E-mail',
                    keyboardType: TextInputType.emailAddress,
                    validator: FormValidators.compose([
                      ValidatorSets.required,
                      ValidatorSets.email,
                    ]),
                  ),
                  CustomTextFormField(
                    controller: _passwordController,
                    labelText: 'Senha',
                    obscureText: true,
                    validator: ValidatorSets.required,
                  ),
                  CustomTextFormField(
                    controller: _phoneController,
                    labelText: 'Telefone',
                    keyboardType: TextInputType.phone,
                    validator: ValidatorSets.required,
                  ),
                  // Address Fields
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Endereço Profissional', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  CustomTextFormField(
                    controller: _postalCodeController,
                    labelText: 'CEP',
                    keyboardType: TextInputType.number,
                    validator: ValidatorSets.required,
                  ),
                  CustomTextFormField(
                    controller: _streetController,
                    labelText: 'Rua',
                    validator: ValidatorSets.required,
                  ),
                  CustomTextFormField(
                    controller: _numberController,
                    labelText: 'Número',
                    keyboardType: TextInputType.number,
                    validator: ValidatorSets.required,
                  ),
                  CustomTextFormField(
                    controller: _complementController,
                    labelText: 'Complemento (Opcional)',
                  ),
                  CustomTextFormField(
                    controller: _neighborhoodController,
                    labelText: 'Bairro',
                    validator: ValidatorSets.required,
                  ),
                  CustomTextFormField(
                    controller: _cityController,
                    labelText: 'Cidade',
                    validator: ValidatorSets.required,
                  ),
                  CustomTextFormField(
                    controller: _stateController,
                    labelText: 'Estado (UF)',
                    validator: FormValidators.compose([
                      ValidatorSets.required,
                      FormValidators.maxLength(2), // Assuming UF is 2 letters
                    ]),
                  ),
                  // Professional Council Fields
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Conselho Profissional', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  CustomTextFormField(
                    controller: _professionalCouncilTypeController,
                    labelText: 'Tipo do Conselho (Ex: CRP, CRM)',
                    validator: ValidatorSets.required,
                  ),
                  CustomTextFormField(
                    controller: _professionalCouncilRegistrationNumberController,
                    labelText: 'Número de Registro no Conselho',
                    validator: ValidatorSets.required,
                  ),
                  CustomTextFormField(
                    controller: _jobTitleController,
                    labelText: 'Cargo/Profissão',
                    validator: ValidatorSets.required,
                  ),
                  CustomTextFormField(
                    controller: _degreeController,
                    labelText: 'Formação Acadêmica/Grau',
                    validator: ValidatorSets.required,
                  ),
                  CustomTextFormField(
                    controller: _darvCourseYearController,
                    labelText: 'Ano de Conclusão DARV (Opcional)',
                    keyboardType: TextInputType.number,
                    validator: FormValidators.compose([
                      FormValidators.numeric,
                      (value) {
                        if (value != null && value.isNotEmpty) {
                          final year = int.tryParse(value);
                          if (year != null && year < 2000) {
                            return 'Ano deve ser 2000 ou posterior.';
                          }
                        }
                        return null;
                      },
                    ]),
                  ),
                  const SizedBox(height: 16.0),
                  LoadingButton(
                    onPressed: _registerScreener,
                    isLoading: _isLoading,
                    text: 'Registrar',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
