/// Página de coleta de informações demográficas do usuário.
library;

import 'package:clinical_narrative_app/core/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clinical_narrative_app/core/providers/app_settings.dart';
import 'package:clinical_narrative_app/core/utils/validator_sets.dart';

class DemographicsPage extends StatefulWidget {
  const DemographicsPage({super.key});

  @override
  State<DemographicsPage> createState() => _DemographicsPageState();
}

class _DemographicsPageState extends State<DemographicsPage> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _nameController = TextEditingController();
  final _medicalRecordIdController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _medicalRecordIdController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final settings = Provider.of<AppSettings>(context, listen: false);

      settings.setPatientData(
        name: _nameController.text.trim(),
        medicalRecordId: _medicalRecordIdController.text.trim(),
      );

      AppNavigator.toChat(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informações do Paciente'),
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
                validator: ValidatorSets.patientName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _medicalRecordIdController,
                decoration:
                    const InputDecoration(labelText: 'Número do prontuário *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Continuar para o Chat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
