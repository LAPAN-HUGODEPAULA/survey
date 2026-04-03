/// Collects the patient identity required before the chat workflow starts.
library;

import 'package:clinical_narrative_app/core/navigation/app_navigator.dart';
import 'package:clinical_narrative_app/core/providers/app_settings.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DemographicsPage extends StatefulWidget {
  const DemographicsPage({super.key});

  @override
  State<DemographicsPage> createState() => _DemographicsPageState();
}

class _DemographicsPageState extends State<DemographicsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _medicalRecordIdController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _medicalRecordIdController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Provider.of<AppSettings>(context, listen: false).setPatientData(
      name: _nameController.text.trim(),
      medicalRecordId: _medicalRecordIdController.text.trim(),
    );
    AppNavigator.toChat(context);
  }

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: 'Informacoes do paciente',
      subtitle:
          'Registre a identificacao basica antes de iniciar a conversa clinica.',
      scrollable: true,
      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: DsSection(
              eyebrow: 'Abertura',
              title: 'Identificacao inicial',
              subtitle:
                  'Esses dados acompanham a conversa e o prontuario gerado.',
              child: DsPatientIdentitySection(
                nameController: _nameController,
                medicalRecordIdController: _medicalRecordIdController,
                showMedicalRecordId: true,
                continueLabel: 'Continuar para o chat',
                onContinue: _submitForm,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
