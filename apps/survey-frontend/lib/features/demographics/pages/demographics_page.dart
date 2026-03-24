/// Collects the demographic data required before starting the survey flow.
library;

import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/navigation/app_navigator.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/core/services/demographics_data_service.dart';
import 'package:survey_app/core/utils/validator_sets.dart';
import 'package:survey_app/shared/widgets/screener_navigation_app_bar.dart';

class DemographicsPage extends StatefulWidget {
  const DemographicsPage({super.key});

  @override
  State<DemographicsPage> createState() => _DemographicsPageState();
}

class _DemographicsPageState extends State<DemographicsPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers keep the form fields synchronized with reset operations.
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _professionController = TextEditingController();
  final _medicationNameController = TextEditingController();

  // Selected values for required categorical inputs.
  String? _selectedSex;
  String? _selectedRace;
  String? _selectedEducationLevel;
  String? _usesMedication;

  // Reference data loaded from bundled assets.
  List<String> _diagnosesList = [];
  List<String> _educationLevels = [];
  List<String> _professions = [];

  // Selection state for multi-select diagnoses.
  Map<String, bool> _selectedDiagnoses = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    Provider.of<AppSettings>(
      context,
      listen: false,
    ).addListener(_onSettingsChanged);
  }

  /// Clears the form when shared application state resets the patient profile.
  void _onSettingsChanged() {
    final settings = Provider.of<AppSettings>(context, listen: false);
    if (settings.patient.name.isEmpty) {
      _clearAllFields();
    }
  }

  /// Restores the form to an empty state after the shared patient data clears.
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
      _selectedDiagnoses = {
        for (final diagnosis in _diagnosesList) diagnosis: false,
      };
    });
  }

  /// Loads bundled demographic reference data used by dropdowns and checkboxes.
  Future<void> _loadInitialData() async {
    try {
      final dataService = DemographicsDataService.instance;
      final data = await dataService.loadAllData();

      setState(() {
        _diagnosesList = data.diagnoses;
        _educationLevels = data.educationLevels;
        _professions = data.professions;
        _selectedDiagnoses = {
          for (final diagnosis in _diagnosesList) diagnosis: false,
        };
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados do formulário: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
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

  /// Validates the form, stores the patient payload, and moves forward.
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final settings = Provider.of<AppSettings>(context, listen: false);

      if (_selectedSex == null ||
          _selectedRace == null ||
          _selectedEducationLevel == null ||
          _usesMedication == null ||
          settings.selectedSurvey == null) {
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

      final selectedDiagnosesList = _selectedDiagnoses.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

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
        diagnoses: selectedDiagnosesList,
      );

      AppNavigator.toClinical(context);
    }
  }

  /// Applies `dd/mm/yyyy` formatting while the user types the birth date.
  void _formatDateInput(String value) {
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length > 8) {
      digitsOnly = digitsOnly.substring(0, 8);
    }
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2 || i == 4) {
        formatted += '/';
      }
      formatted += digitsOnly[i];
    }
    if (formatted != _dobController.text) {
      _dobController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    return DsScaffold(
      appBar: ScreenerNavigationAppBar(
        currentRoute: '/demographics',
        title: Image.asset('assets/images/lapan_logo_reduced.png', height: 40),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (settings.isLockedAssessmentMode) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Este acesso foi preparado para ${settings.screenerDisplayName} e o questionário ${settings.selectedSurveyName}. As configurações estão protegidas durante esta sessão.',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo *',
                    ),
                    validator: ValidatorSets.patientName,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email *'),
                    validator: ValidatorSets.patientEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dobController,
                    decoration: const InputDecoration(
                      labelText: 'Data de Nascimento *',
                      hintText: 'DD/MM/AAAA',
                    ),
                    keyboardType: TextInputType.datetime,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    onChanged: _formatDateInput,
                    validator: ValidatorSets.patientBirthDate,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: const ValueKey('sex'), // Unique key
                    initialValue: _selectedSex,
                    decoration: const InputDecoration(labelText: 'Sexo *'),
                    items: ['Feminino', 'Masculino', 'Outro']
                        .map(
                          (label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _selectedSex = value),
                    validator: (value) =>
                        value == null ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: const ValueKey('race'), // Unique key
                    initialValue: _selectedRace,
                    decoration: const InputDecoration(
                      labelText: 'Raça/Etnia *',
                    ),
                    items:
                        [
                              'Branca',
                              'Preta',
                              'Parda',
                              'Amarela',
                              'Indígena',
                              'Outra',
                            ]
                            .map(
                              (label) => DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => setState(() => _selectedRace = value),
                    validator: (value) =>
                        value == null ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: const ValueKey('education'), // Unique key
                    initialValue: _selectedEducationLevel,
                    decoration: const InputDecoration(
                      labelText: 'Grau de Escolaridade *',
                    ),
                    items: _educationLevels
                        .map(
                          (label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedEducationLevel = value),
                    validator: (value) =>
                        value == null ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return _professions.where((String option) {
                        return option.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        );
                      });
                    },
                    onSelected: (String selection) {
                      _professionController.text = selection;
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: _professionController,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Profissão',
                            ),
                          );
                        },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Informações de Saúde',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Diagnósticos Prévios'),
                  Wrap(
                    spacing: 8.0,
                    children: _diagnosesList.map((diagnosis) {
                      return ChoiceChip(
                        label: Text(diagnosis),
                        selected: _selectedDiagnoses[diagnosis] ?? false,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedDiagnoses[diagnosis] = selected;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('Faz uso de medicamento psiquiátrico? *'),
                  RadioGroup<String>(
                    groupValue: _usesMedication,
                    onChanged: (value) =>
                        setState(() => _usesMedication = value),
                    child: Row(
                      children: const [
                        Radio<String>(value: 'Sim'),
                        Text('Sim'),
                        Radio<String>(value: 'Não'),
                        Text('Não'),
                      ],
                    ),
                  ),
                  if (_usesMedication == 'Sim')
                    TextFormField(
                      controller: _medicationNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do(s) medicamento(s)',
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Campo obrigatório'
                          : null,
                    ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Continuar para Instruções'),
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
