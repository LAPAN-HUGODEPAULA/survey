/// Collects the demographic data required before starting the survey flow.
library;

import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/navigation/app_navigator.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/core/repositories/survey_repository.dart';
import 'package:survey_app/shared/widgets/assessment_flow_stepper.dart';
import 'package:survey_app/shared/widgets/screener_navigation_app_bar.dart';

class DemographicsPage extends StatefulWidget {
  const DemographicsPage({super.key});

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
          'Informe se a pessoa faz uso de medicação psiquiátrica.',
      additionalValidationItemsBuilder: _buildAdditionalValidationItems,
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

  List<DsValidationSummaryItem> _buildAdditionalValidationItems() {
    final settings = Provider.of<AppSettings>(context, listen: false);
    if (settings.selectedSurvey != null) {
      return const <DsValidationSummaryItem>[];
    }
    return const <DsValidationSummaryItem>[
      DsValidationSummaryItem(
        label: 'Questionário',
        message: 'Selecione um questionário antes de continuar.',
      ),
    ];
  }

  void _submitForm() {
    final submission = _demographicsController.submit(_formKey);
    if (submission == null) {
      return;
    }

    final settings = Provider.of<AppSettings>(context, listen: false);
    settings.setPatientData(
      name: submission.name,
      email: submission.email,
      birthDate: submission.birthDate,
      gender: submission.gender,
      ethnicity: submission.ethnicity,
      educationLevel: submission.educationLevel,
      profession: submission.profession,
      medication: submission.medication,
      diagnoses: submission.diagnoses,
    );

    AppNavigator.toClinical(context);
  }

  Future<List<String>> _searchMedications(String query) {
    return _surveyRepository.searchMedications(query);
  }

  Future<List<String>> _loadMedicationCatalog() {
    return _surveyRepository.fetchAllMedications();
  }

  Future<void> _persistManualMedication(String medication) {
    return _surveyRepository.persistManualMedication(medication);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final tone = DsEmotionalToneProvider.resolveTokens(context);

    return ListenableBuilder(
      listenable: _demographicsController,
      builder: (context, child) {
        return DsAsyncPage(
          isLoading: _demographicsController.isLoadingCatalogs,
          error: _demographicsController.catalogError,
          appBar: ScreenerNavigationAppBar(
            currentRoute: '/demographics',
            title: const Text('Avaliação do paciente'),
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AssessmentFlowStepper(
                        currentStep: AssessmentFlowStep.dadosPaciente,
                      ),
                      DsInlineMessage(
                        feedback: DsFeedbackMessage(
                          severity: DsStatusType.info,
                          title: 'Sessão profissional ativa',
                          message:
                              'Questionário em uso: ${settings.selectedSurveyName}. Você pode revisar os dados do paciente e seguir quando estiver pronto. ${tone.waitingSupportMessage}',
                          userName: settings.screenerDisplayName,
                          includeGreeting: true,
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                      ),
                      if (_demographicsController
                          .validationItems
                          .isNotEmpty) ...[
                        DsValidationSummary(
                          items: _demographicsController.validationItems,
                          description:
                              'Corrija os itens abaixo e os campos destacados antes de avançar.',
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (settings.isLockedAssessmentMode)
                        DsMessageBanner(
                          feedback: DsFeedbackMessage(
                            severity: DsStatusType.info,
                            title: 'Sessão preparada',
                            message:
                                'Este acesso foi preparado para ${settings.screenerDisplayName} e o questionário ${settings.selectedSurveyName}. As configurações estão protegidas durante esta sessão.',
                          ),
                        ),
                      DsPatientIdentitySection(
                        nameController: _demographicsController.nameController,
                        emailController:
                            _demographicsController.emailController,
                        birthDateController:
                            _demographicsController.birthDateController,
                        showEmail: true,
                        showBirthDate: true,
                        submitted: _demographicsController.hasSubmitted,
                      ),
                      const SizedBox(height: 16),
                      DsSurveyDemographicsSection(
                        catalogs: _demographicsController.catalogs,
                        professionController:
                            _demographicsController.professionController,
                        selectedMedications:
                            _demographicsController.selectedMedications,
                        searchMedications: _searchMedications,
                        loadMedicationCatalog: _loadMedicationCatalog,
                        persistManualMedication: _persistManualMedication,
                        onMedicationAdded:
                            _demographicsController.addMedication,
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
                        onDiagnosisChanged:
                            _demographicsController.updateDiagnosis,
                        submitted: _demographicsController.hasSubmitted,
                        usesMedicationErrorText:
                            _demographicsController.usesMedicationErrorText,
                        continueLabel: 'Continuar para Instruções',
                        onContinue: _submitForm,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
