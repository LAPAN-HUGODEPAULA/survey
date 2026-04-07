/// Collects demographic data before generating the patient report.
library;

import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:patient_app/core/models/survey/question.dart';
import 'package:patient_app/core/models/survey/survey.dart';
import 'package:patient_app/core/navigation/app_navigator.dart';
import 'package:patient_app/core/providers/app_settings.dart';
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
  bool _hasSubmitted = false;
  List<DsValidationSummaryItem> _validationItems =
      const <DsValidationSummaryItem>[];
  String? _selectedSex;
  String? _selectedRace;
  String? _selectedEducationLevel;
  String? _usesMedication;
  Map<String, bool> _selectedDiagnoses = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _nameController.addListener(_syncValidationSummary);
    _emailController.addListener(_syncValidationSummary);
    _dobController.addListener(_syncValidationSummary);
    _professionController.addListener(_syncValidationSummary);
    _medicationNameController.addListener(_syncValidationSummary);
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
    _nameController.removeListener(_syncValidationSummary);
    _emailController.removeListener(_syncValidationSummary);
    _dobController.removeListener(_syncValidationSummary);
    _professionController.removeListener(_syncValidationSummary);
    _medicationNameController.removeListener(_syncValidationSummary);
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
      _hasSubmitted = false;
      _validationItems = const <DsValidationSummaryItem>[];
      _selectedDiagnoses = <String, bool>{
        for (final String diagnosis in _catalogs?.diagnoses ?? const <String>[])
          diagnosis: false,
      };
    });
  }

  void _syncValidationSummary() {
    if (!_hasSubmitted || !mounted) {
      return;
    }
    setState(() {
      _validationItems = _buildValidationItems();
    });
  }

  List<DsValidationSummaryItem> _buildValidationItems() {
    final items = <DsValidationSummaryItem>[];

    void addItem(String label, String? message) {
      if (message == null || message.trim().isEmpty) {
        return;
      }
      items.add(DsValidationSummaryItem(label: label, message: message));
    }

    addItem(
      'Nome completo',
      DsFormValidators.validatePersonName(
        _nameController.text,
        context: 'patient',
      ),
    );
    addItem(
      'E-mail',
      DsFormValidators.validateEmail(_emailController.text, context: 'patient'),
    );
    addItem(
      'Data de nascimento',
      DsFormValidators.validateBirthDate(_dobController.text),
    );
    addItem(
      'Sexo',
      DsFormValidators.validateDropdownSelection(_selectedSex, 'Sexo'),
    );
    addItem(
      'Raça/Etnia',
      DsFormValidators.validateDropdownSelection(_selectedRace, 'Raça/Etnia'),
    );
    addItem(
      'Grau de escolaridade',
      DsFormValidators.validateDropdownSelection(
        _selectedEducationLevel,
        'Grau de Escolaridade',
      ),
    );
    addItem('Uso de medicação psiquiátrica', _validateUsesMedication());
    if (_usesMedication == 'Sim') {
      addItem(
        'Nome do(s) medicamento(s)',
        DsFormValidators.validateRequired(_medicationNameController.text),
      );
    }

    return items;
  }

  String? _validateUsesMedication() {
    if (_usesMedication == null) {
      return 'Informe se você faz uso de medicação psiquiátrica.';
    }
    return null;
  }

  void _submitForm() {
    final isFormValid = _formKey.currentState!.validate();
    final validationItems = _buildValidationItems();

    if (!isFormValid || validationItems.isNotEmpty) {
      setState(() {
        _hasSubmitted = true;
        _validationItems = validationItems;
      });
      return;
    }

    setState(() {
      _hasSubmitted = false;
      _validationItems = const <DsValidationSummaryItem>[];
    });

    Provider.of<AppSettings>(context, listen: false).setPatientData(
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

    AppNavigator.replaceWithReport(
      context,
      survey: widget.survey,
      surveyAnswers: widget.surveyAnswers,
      surveyQuestions: widget.surveyQuestions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.survey.surveyDisplayName.isNotEmpty
        ? widget.survey.surveyDisplayName
        : widget.survey.surveyName;

    return DsScaffold(
      isLoading: _isLoadingCatalogs,
      error: _catalogError,
      title: 'Informações demográficas',
      subtitle:
          'Complete os dados adicionais para enriquecer o relatório de $displayName.',
      scrollable: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_validationItems.isNotEmpty) ...[
                  DsValidationSummary(
                    items: _validationItems,
                    description:
                        'Corrija os itens abaixo e os campos destacados antes de continuar.',
                  ),
                  const SizedBox(height: 16),
                ],
                DsSection(
                  eyebrow: 'Paciente',
                  title: 'Identificação',
                  subtitle:
                      'Informe os dados essenciais para contextualizar a avaliação.',
                  child: DsPatientIdentitySection(
                    nameController: _nameController,
                    emailController: _emailController,
                    birthDateController: _dobController,
                    showEmail: true,
                    showBirthDate: true,
                    emailLabel: 'E-mail *',
                    submitted: _hasSubmitted,
                  ),
                ),
                const SizedBox(height: 16),
                DsSection(
                  eyebrow: 'Contexto clínico',
                  title: 'Dados complementares',
                  subtitle:
                      'Essas informações ajudam a montar um relatório mais completo.',
                  child: DsSurveyDemographicsSection(
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
                      setState(() {
                        _selectedSex = value;
                        if (_hasSubmitted) {
                          _validationItems = _buildValidationItems();
                        }
                      });
                    },
                    onRaceChanged: (String? value) {
                      setState(() {
                        _selectedRace = value;
                        if (_hasSubmitted) {
                          _validationItems = _buildValidationItems();
                        }
                      });
                    },
                    onEducationChanged: (String? value) {
                      setState(() {
                        _selectedEducationLevel = value;
                        if (_hasSubmitted) {
                          _validationItems = _buildValidationItems();
                        }
                      });
                    },
                    onUsesMedicationChanged: (String? value) {
                      setState(() {
                        _usesMedication = value;
                        if (_hasSubmitted) {
                          _validationItems = _buildValidationItems();
                        }
                      });
                    },
                    onDiagnosisChanged: (String diagnosis, bool isSelected) {
                      setState(() {
                        _selectedDiagnoses[diagnosis] = isSelected;
                      });
                    },
                    submitted: _hasSubmitted,
                    usesMedicationErrorText: _hasSubmitted
                        ? _validateUsesMedication()
                        : null,
                    continueLabel: 'Ver Resultados',
                    onContinue: _submitForm,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
