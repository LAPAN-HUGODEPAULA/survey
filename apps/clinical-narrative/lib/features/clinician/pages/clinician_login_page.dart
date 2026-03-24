
import 'package:clinical_narrative_app/core/navigation/app_navigator.dart';
import 'package:clinical_narrative_app/core/providers/app_settings.dart';
import 'package:clinical_narrative_app/core/utils/validator_sets.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClinicianLoginPage extends StatefulWidget {
  const ClinicianLoginPage({super.key});

  @override
  State<ClinicianLoginPage> createState() => _ClinicianLoginPageState();
}

class _ClinicianLoginPageState extends State<ClinicianLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _registrationController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _registrationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final settings = context.read<AppSettings>();
    settings.setClinicianData(
      name: _nameController.text.trim(),
      registrationNumber: _registrationController.text.trim(),
      email: _emailController.text.trim(),
    );
    AppNavigator.toDemographics(context);
  }

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      appBar: AppBar(
        title: const Text('Credenciais do Profissional'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome Completo *'),
                validator: ValidatorSets.clinicianName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _registrationController,
                decoration: const InputDecoration(
                  labelText: 'Registro Profissional (CRM/CRP) *',
                ),
                validator: ValidatorSets.clinicianRegistration,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email (opcional)',
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
