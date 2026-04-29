/// Collects demographic data before generating the patient report.
library;

import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:patient_app/core/models/survey/question.dart';
import 'package:patient_app/core/models/survey/survey.dart';
import 'package:patient_app/core/navigation/app_navigator.dart';
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:patient_app/core/repositories/survey_repository.dart';
import 'package:patient_app/shared/widgets/patient_journey_stepper.dart';
import 'package:provider/provider.dart';

class DemographicsPage extends StatefulWidget {
  const DemographicsPage({
    super.key,
    required this.survey,
    required this.surveyAnswers,
    required this.surveyQuestions,
  });

  final Survey survey;
  final List<String> surveyAnswers;
  final List<Question> surveyQuestions;

  @override
  State<DemographicsPage> createState() => _DemographicsPageState();
}

class _DemographicsPageState extends State<DemographicsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final DsDemographicsFormController _demographicsController;
  late final SurveyRepository _surveyRepository;

  @override
  void initState() {
    super.initState();
    _demographicsController = DsDemographicsFormController(
      usesMedicationRequiredMessage:
          'Informe se você faz uso de medicação psiquiátrica.',
      requireIdentityFields: false,
      requireSelectionFields: false,
      requireMedicationChoice: false,
      requireMedicationListWhenUsingMedication: false,
    );
    _surveyRepository = SurveyRepository();
    _demographicsController.loadInitialData();
    Provider.of<AppSettings>(
      context,
      listen: false,
    ).addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    Provider.of<AppSettings>(
      context,
      listen: false,
    ).removeListener(_onSettingsChanged);
    _demographicsController.dispose();
    _surveyRepository.dispose();
    super.dispose();
  }

  void _onSettingsChanged() {
    final settings = Provider.of<AppSettings>(context, listen: false);
    if (settings.patient.name.isEmpty) {
      _demographicsController.reset();
    }
  }

  void _submitForm() {
    final submission = _demographicsController.submit(_formKey);
    if (submission == null) {
      return;
    }

    final settings = Provider.of<AppSettings>(context, listen: false);
    final patient = settings.patient;
    settings.setPatientData(
      name: patient.name,
      email: patient.email,
      birthDate: patient.birthDate,
      gender: submission.gender,
      ethnicity: submission.ethnicity,
      educationLevel: submission.educationLevel,
      profession: submission.profession,
      medication: submission.medication,
      diagnoses: submission.diagnoses,
    );

    AppNavigator.toReport(
      context,
      survey: widget.survey,
      surveyAnswers: widget.surveyAnswers,
      surveyQuestions: widget.surveyQuestions,
      onRestartSurvey: _restartSurveyFlow,
    );
  }

  Future<void> _restartSurveyFlow() async {
    final appSettings = Provider.of<AppSettings>(context, listen: false);
    await appSettings.restartAssessmentFlow();
    if (!mounted) {
      return;
    }
    AppNavigator.replaceWithEntryGate(context);
  }

  Future<List<String>> _searchMedications(String query) {
    return _surveyRepository.searchMedications(query);
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.survey.surveyDisplayName.isNotEmpty
        ? widget.survey.surveyDisplayName
        : widget.survey.surveyName;

    return ListenableBuilder(
      listenable: _demographicsController,
      builder: (context, child) {
        return DsScaffold(
          isLoading: _demographicsController.isLoadingCatalogs,
          error: _demographicsController.catalogError,
          title: 'Informações demográficas',
          subtitle:
              'Os dados complementares são opcionais e podem enriquecer o relatório de $displayName.',
          onBack: () => Navigator.of(context).pop(),
          backLabel: 'Voltar para o resumo',
          scrollable: true,
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PatientJourneyStepper(
                  currentStep: PatientJourneyStep.relatorio,
                ),
                if (_demographicsController.validationItems.isNotEmpty) ...[
                  DsValidationSummary(
                    items: _demographicsController.validationItems,
                    description:
                        'Corrija os itens abaixo e os campos destacados antes de continuar.',
                  ),
                  const SizedBox(height: 16),
                ],
                DsSection(
                  eyebrow: 'Contexto clínico',
                  title: 'Dados complementares',
                  subtitle:
                      'Essas informações ajudam a montar um relatório mais completo.',
                  child: DsSurveyDemographicsSection(
                    catalogs: _demographicsController.catalogs,
                    professionController:
                        _demographicsController.professionController,
                    selectedMedications:
                        _demographicsController.selectedMedications,
                    searchMedications: _searchMedications,
                    onMedicationAdded: _demographicsController.addMedication,
                    onMedicationRemoved:
                        _demographicsController.removeMedication,
                    selectedDiagnoses:
                        _demographicsController.selectedDiagnoses,
                    selectedSex: _demographicsController.selectedSex,
                    selectedRace: _demographicsController.selectedRace,
                    selectedEducationLevel:
                        _demographicsController.selectedEducationLevel,
                    usesMedication: _demographicsController.usesMedication,
                    onSexChanged: _demographicsController.updateSex,
                    onRaceChanged: _demographicsController.updateRace,
                    onEducationChanged:
                        _demographicsController.updateEducationLevel,
                    onUsesMedicationChanged:
                        _demographicsController.updateUsesMedication,
                    onDiagnosisChanged: _demographicsController.updateDiagnosis,
                    submitted: _demographicsController.hasSubmitted,
                    usesMedicationErrorText:
                        _demographicsController.usesMedicationErrorText,
                    requireSelectionFields: false,
                    requireMedicationChoice: false,
                    requireMedicationListWhenUsingMedication: false,
                    continueLabel: 'Gerar relatório detalhado',
                    onContinue: _submitForm,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
