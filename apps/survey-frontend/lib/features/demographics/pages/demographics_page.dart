/// Collects the demographic data required before starting the survey flow.
library;

import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/navigation/app_navigator.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/shared/widgets/screener_navigation_app_bar.dart';

class DemographicsPage extends StatefulWidget {
  const DemographicsPage({super.key});

  @override
  State<DemographicsPage> createState() => _DemographicsPageState();
}

class _DemographicsPageState extends State<DemographicsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _medicationNameController =
      TextEditingController();
  final DsDemographicsCatalogLoader _catalogLoader =
      DsDemographicsCatalogLoader();

  DsDemographicsCatalogs? _catalogs;
  String? _catalogError;
  bool _isLoadingCatalogs = true;
  List<String> _validationErrors = const <String>[];
  String? _selectedSex;
  String? _selectedRace;
  String? _selectedEducationLevel;
  String? _usesMedication;
  Map<String, bool> _selectedDiagnoses = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
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
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _professionController.dispose();
    _medicationNameController.dispose();
    super.dispose();
  }

  void _onSettingsChanged() {
    final settings = Provider.of<AppSettings>(context, listen: false);
    if (settings.patient.name.isEmpty) {
      _clearAllFields();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingCatalogs = true;
      _catalogError = null;
    });

    try {
      final catalogs = await _catalogLoader.loadAll();
      if (!mounted) {
        return;
      }
      setState(() {
        _catalogs = catalogs;
        _selectedDiagnoses = <String, bool>{
          for (final String diagnosis in catalogs.diagnoses) diagnosis: false,
        };
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _catalogError = 'Erro ao carregar dados do formulário: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingCatalogs = false);
      }
    }
  }

  void _clearAllFields() {
    _nameController.clear();
    _emailController.clear();
    _dobController.clear();
    _professionController.clear();
    _medicationNameController.clear();
    setState(() {
      _selectedSex = null;
      _selectedRace = null;
      _selectedEducationLevel = null;
      _usesMedication = null;
      _selectedDiagnoses = <String, bool>{
        for (final String diagnosis in _catalogs?.diagnoses ?? const <String>[])
          diagnosis: false,
      };
    });
  }

  void _formatDateInput(String value) {
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length > 8) {
      digitsOnly = digitsOnly.substring(0, 8);
    }
    var formatted = '';
    for (var index = 0; index < digitsOnly.length; index++) {
      if (index == 2 || index == 4) {
        formatted += '/';
      }
      formatted += digitsOnly[index];
    }
    if (formatted != _dobController.text) {
      _dobController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _submitForm() {
    final settings = Provider.of<AppSettings>(context, listen: false);
    final errors = <String>[];
    final isFormValid = _formKey.currentState!.validate();

    if (_usesMedication == null) {
      errors.add('Informe se a pessoa faz uso de medicação psiquiátrica.');
    }
    if (settings.selectedSurvey == null) {
      errors.add('Selecione um questionário antes de continuar.');
    }

    if (!isFormValid || errors.isNotEmpty) {
      setState(() => _validationErrors = errors);
      return;
    }

    setState(() => _validationErrors = const <String>[]);

    settings.setPatientData(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      birthDate: _dobController.text,
      gender: _selectedSex!,
      ethnicity: _selectedRace!,
      educationLevel: _selectedEducationLevel!,
      profession: _professionController.text.trim(),
      medication: _usesMedication == 'Sim'
          ? _medicationNameController.text.trim()
          : 'Não aplicável',
      diagnoses: _selectedDiagnoses.entries
          .where((MapEntry<String, bool> entry) => entry.value)
          .map((MapEntry<String, bool> entry) => entry.key)
          .toList(growable: false),
    );

    AppNavigator.toClinical(context);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return DsAsyncPage(
      isLoading: _isLoadingCatalogs,
      error: _catalogError,
      appBar: ScreenerNavigationAppBar(
        currentRoute: '/demographics',
        title: Image.asset('assets/images/lapan_logo_reduced.png', height: 40),
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
                  if (_validationErrors.isNotEmpty) ...[
                    DsValidationSummary(
                      errors: _validationErrors,
                      description:
                          'Corrija os itens abaixo e os campos destacados antes de avançar.',
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (settings.isLockedAssessmentMode)
                    DsFeedbackBanner(
                      feedback: DsFeedbackMessage(
                        severity: DsStatusType.info,
                        title: 'Sessão preparada',
                        message:
                            'Este acesso foi preparado para ${settings.screenerDisplayName} e o questionário ${settings.selectedSurveyName}. As configurações estão protegidas durante esta sessão.',
                      ),
                    ),
                  DsPatientIdentitySection(
                    nameController: _nameController,
                    emailController: _emailController,
                    birthDateController: _dobController,
                    onBirthDateChanged: _formatDateInput,
                    showEmail: true,
                    showBirthDate: true,
                  ),
                  const SizedBox(height: 16),
                  DsSurveyDemographicsSection(
                    catalogs:
                        _catalogs ??
                        const DsDemographicsCatalogs(
                          diagnoses: <String>[],
                          educationLevels: <String>[],
                          professions: <String>[],
                        ),
                    professionController: _professionController,
                    medicationNameController: _medicationNameController,
                    selectedDiagnoses: _selectedDiagnoses,
                    selectedSex: _selectedSex,
                    selectedRace: _selectedRace,
                    selectedEducationLevel: _selectedEducationLevel,
                    usesMedication: _usesMedication,
                    onSexChanged: (String? value) {
                      setState(() => _selectedSex = value);
                    },
                    onRaceChanged: (String? value) {
                      setState(() => _selectedRace = value);
                    },
                    onEducationChanged: (String? value) {
                      setState(() => _selectedEducationLevel = value);
                    },
                    onUsesMedicationChanged: (String? value) {
                      setState(() => _usesMedication = value);
                    },
                    onDiagnosisChanged: (String diagnosis, bool isSelected) {
                      setState(() {
                        _selectedDiagnoses[diagnosis] = isSelected;
                      });
                    },
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
  }
}
