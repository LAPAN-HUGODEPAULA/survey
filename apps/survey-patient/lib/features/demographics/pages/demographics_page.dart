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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSex == null ||
        _selectedRace == null ||
        _selectedEducationLevel == null ||
        _usesMedication == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor, preencha todos os campos obrigatórios.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

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
      title: 'Informacoes Demograficas',
      subtitle:
          'Complete os dados adicionais para enriquecer o relatorio de $displayName.',
      scrollable: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DsSection(
                  eyebrow: 'Paciente',
                  title: 'Identificacao',
                  subtitle:
                      'Informe os dados essenciais para contextualizar a avaliacao.',
                  child: DsPatientIdentitySection(
                    nameController: _nameController,
                    emailController: _emailController,
                    birthDateController: _dobController,
                    onBirthDateChanged: _formatDateInput,
                    showEmail: true,
                    showBirthDate: true,
                    emailLabel: 'E-mail *',
                  ),
                ),
                const SizedBox(height: 16),
                DsSection(
                  eyebrow: 'Contexto clinico',
                  title: 'Dados complementares',
                  subtitle:
                      'Essas informacoes ajudam a montar um relatorio mais completo.',
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
