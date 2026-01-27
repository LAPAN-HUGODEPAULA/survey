/// Página de coleta de informações demográficas do usuário.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:patient_app/core/navigation/app_navigator.dart';
import 'package:patient_app/core/models/survey/question.dart';
import 'package:patient_app/core/models/survey/survey.dart';
import 'package:patient_app/core/services/demographics_data_service.dart';
import 'package:patient_app/core/utils/validator_sets.dart';

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
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _professionController = TextEditingController();
  final _medicationNameController = TextEditingController();

  // Dropdown values
  String? _selectedSex;
  String? _selectedRace;
  String? _selectedEducationLevel;
  String? _usesMedication;

  // Data for dropdowns
  List<String> _diagnosesList = [];
  List<String> _educationLevels = [];
  List<String> _professions = [];

  // Other state variables
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

  void _onSettingsChanged() {
    final settings = Provider.of<AppSettings>(context, listen: false);
    if (settings.patient.name.isEmpty) {
      _clearAllFields();
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
      _selectedDiagnoses = {
        for (var diagnosis in _diagnosesList) diagnosis: false,
      };
    });
  }

  Future<void> _loadInitialData() async {
    try {
      final dataService = DemographicsDataService.instance;
      final data = await dataService.loadAllData();

      setState(() {
        _diagnosesList = data.diagnoses;
        _educationLevels = data.educationLevels;
        _professions = data.professions;
        _selectedDiagnoses = {
          for (var diagnosis in _diagnosesList) diagnosis: false,
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final settings = Provider.of<AppSettings>(context, listen: false);

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

      AppNavigator.replaceWithReport(
        context,
        survey: widget.survey,
        surveyAnswers: widget.surveyAnswers,
        surveyQuestions: widget.surveyQuestions,
      );
    }
  }

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Informações Demográficas: ${widget.survey.surveyDisplayName.isNotEmpty ? widget.survey.surveyDisplayName : widget.survey.surveyName}',
        ),
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
                      (label) =>
                          DropdownMenuItem(value: label, child: Text(label)),
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
                decoration: const InputDecoration(labelText: 'Raça/Etnia *'),
                items:
                    ['Branca', 'Preta', 'Parda', 'Amarela', 'Indígena', 'Outra']
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
                      (label) =>
                          DropdownMenuItem(value: label, child: Text(label)),
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
                onChanged: (value) => setState(() => _usesMedication = value),
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
                    labelText: 'Nome dos Medicamentos',
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
    );
  }
}
