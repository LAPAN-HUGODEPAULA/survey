import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:patient_app/core/navigation/app_navigator.dart';
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:patient_app/shared/widgets/patient_journey_stepper.dart';
import 'package:provider/provider.dart';

class PatientIdentificationPage extends StatefulWidget {
  const PatientIdentificationPage({super.key});

  @override
  State<PatientIdentificationPage> createState() =>
      _PatientIdentificationPageState();
}

class _PatientIdentificationPageState extends State<PatientIdentificationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final patient = context.read<AppSettings>().patient;
    _nameController.text = patient.name;
    _emailController.text = patient.email;
    _birthDateController.text = patient.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final settings = context.read<AppSettings>();
    final existing = settings.patient;
    settings.setPatientData(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      gender: existing.gender,
      ethnicity: existing.ethnicity,
      educationLevel: existing.educationLevel,
      profession: existing.profession,
      medication: existing.medication,
      diagnoses: existing.diagnoses,
    );

    if (!mounted) {
      return;
    }
    await AppNavigator.replaceWithWelcome(context);
  }

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: 'Identificação do paciente',
      subtitle:
          'Informe nome, e-mail e data de nascimento antes de continuar para o questionário.',
      onBack: () => Navigator.of(context).pop(),
      backLabel: 'Voltar para aviso inicial',
      scrollable: true,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PatientJourneyStepper(
              currentStep: PatientJourneyStep.identificacao,
            ),
            DsSection(
              eyebrow: 'Paciente',
              title: 'Dados obrigatórios',
              subtitle:
                  'Esses dados são necessários para vincular o relatório à avaliação correta.',
              child: DsPatientIdentitySection(
                nameController: _nameController,
                emailController: _emailController,
                birthDateController: _birthDateController,
                showEmail: true,
                showBirthDate: true,
                submitted: _submitted,
                continueLabel: 'Continuar',
                onContinue: _continue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
