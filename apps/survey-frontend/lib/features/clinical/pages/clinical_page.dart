import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/navigation/app_navigator.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/shared/widgets/assessment_flow_stepper.dart';

/// Collects optional clinical notes before showing the survey instructions.
class ClinicalPage extends StatefulWidget {
  const ClinicalPage({super.key});

  @override
  State<ClinicalPage> createState() => _ClinicalPageState();
}

class _ClinicalPageState extends State<ClinicalPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _medicalHistoryController =
      TextEditingController();
  final TextEditingController _familyHistoryController =
      TextEditingController();
  final TextEditingController _socialDataController = TextEditingController();
  final TextEditingController _medicationHistoryController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Rehydrate previously entered notes when the user returns to this screen.
    final clinical = Provider.of<AppSettings>(
      context,
      listen: false,
    ).clinicalData;
    _medicalHistoryController.text = clinical.medicalHistory;
    _familyHistoryController.text = clinical.familyHistory;
    _socialDataController.text = clinical.socialData;
    _medicationHistoryController.text = clinical.medicationHistory;
  }

  @override
  void dispose() {
    _medicalHistoryController.dispose();
    _familyHistoryController.dispose();
    _socialDataController.dispose();
    _medicationHistoryController.dispose();
    super.dispose();
  }

  void _goNext() {
    final settings = Provider.of<AppSettings>(context, listen: false);

    // Persist optional notes so the report can include them later in the flow.
    settings.setClinicalData(
      medicalHistory: _medicalHistoryController.text.trim(),
      familyHistory: _familyHistoryController.text.trim(),
      socialData: _socialDataController.text.trim(),
      medicationHistory: _medicationHistoryController.text.trim(),
    );

    // The instructions screen still enforces the comprehension check.
    AppNavigator.toInstructions(context);
  }

  Widget _buildMultilineField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int minLines = 4,
    int maxLines = 8,
  }) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Opcional — $hint',
        alignLabelWithHint: true,
        helperText: hint,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    return DsScaffold(
      title: 'Dados clínicos',
      subtitle:
          'Registre observações complementares com clareza antes de iniciar o questionário.',
      onBack: () => Navigator.of(context).pop(),
      backLabel: 'Voltar para os dados do paciente',
      userName: settings.screenerDisplayName,
      showAmbientGreeting: true,
      scrollable: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              const AssessmentFlowStepper(
                currentStep: AssessmentFlowStep.contextoClinico,
              ),
              DsSection(
                eyebrow: 'Opcional',
                title: 'Contexto complementar',
                subtitle:
                    'Essas informações ajudam a contextualizar o atendimento, mas não bloqueiam o fluxo.',
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildMultilineField(
                        label: 'Histórico médico',
                        hint:
                            'Lista de condições e diagnósticos prévios/atuais do paciente.',
                        controller: _medicalHistoryController,
                      ),
                      const SizedBox(height: 16),
                      _buildMultilineField(
                        label: 'Histórico familiar',
                        hint:
                            'Informações de saúde de parentes biológicos (pais, irmãos, filhos).',
                        controller: _familyHistoryController,
                      ),
                      const SizedBox(height: 16),
                      _buildMultilineField(
                        label: 'Dados sociais',
                        hint:
                            'Informações não clínicas que impactam a saúde (tabagismo, álcool, ocupação, moradia, etc.).',
                        controller: _socialDataController,
                      ),
                      const SizedBox(height: 16),
                      _buildMultilineField(
                        label: 'Histórico de medicação',
                        hint:
                            'Lista de medicações atuais ou recentes, incluindo dose, frequência e via.',
                        controller: _medicationHistoryController,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: DsFilledButton(
                          label: 'Continuar para Instruções',
                          onPressed: _goNext,
                          size: DsButtonSize.large,
                        ),
                      ),
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
