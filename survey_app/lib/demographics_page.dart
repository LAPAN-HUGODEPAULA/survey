/// Página de coleta de informações demográficas do usuário.
///
/// Esta página é responsável por coletar dados pessoais do usuário antes
/// do início do questionário principal, incluindo informações como nome,
/// data de nascimento, sexo, raça, diagnósticos prévios e medicamentos.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/instructions_page.dart';
import 'package:survey_app/providers/app_settings.dart';
import 'package:survey_app/settings_page.dart';

/// Página que coleta informações demográficas do usuário.
///
/// Esta é a primeira página da aplicação, onde são coletados dados pessoais
/// básicos do participante da pesquisa. Os dados incluem informações
/// demográficas padrão e informações médicas relevantes.
///
/// A página valida todos os campos obrigatórios antes de permitir
/// o avanço para as instruções do questionário.
class DemographicsPage extends StatefulWidget {
  const DemographicsPage({super.key});

  @override
  State<DemographicsPage> createState() => _DemographicsPageState();
}

/// Estado da página de informações demográficas.
///
/// Gerencia todos os controladores de formulário, validação de dados
/// e carregamento dinâmico de diagnósticos médicos.
class _DemographicsPageState extends State<DemographicsPage> {
  /// Chave global para validação do formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores dos campos de texto
  /// Controlador para o campo nome completo
  final _nameController = TextEditingController();

  /// Controlador para o campo data de nascimento
  final _dobController = TextEditingController();

  /// Controlador para o campo nome do medicamento
  final _medicationNameController = TextEditingController();

  // Variáveis de seleção única
  /// Sexo selecionado pelo usuário
  String? _selectedSex;

  /// Raça/etnia selecionada pelo usuário
  String? _selectedRace;

  /// Indica se o usuário usa medicamento psiquiátrico
  String? _usesMedication;

  // Variáveis para diagnósticos dinâmicos
  /// Lista de diagnósticos carregados do arquivo JSON
  List<String> _diagnosesList = [];

  /// Map que controla quais diagnósticos foram selecionados
  Map<String, bool> _selectedDiagnoses = {};

  /// Indica se os diagnósticos ainda estão sendo carregados
  bool _isLoadingDiagnoses = true;

  @override
  void initState() {
    super.initState();
    _loadDiagnoses();
  }

  /// Carrega a lista de diagnósticos do arquivo assets/data/diagnoses.json.
  ///
  /// Popula [_diagnosesList] com os diagnósticos disponíveis e inicializa
  /// [_selectedDiagnoses] com todos os valores como false.
  ///
  /// Em caso de erro, define [_isLoadingDiagnoses] como false e exibe erro no console.
  Future<void> _loadDiagnoses() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/diagnoses.json',
      );
      final List<dynamic> data = json.decode(response);

      setState(() {
        _diagnosesList = data.cast<String>();
        // Inicializa todos os diagnósticos como não selecionados
        _selectedDiagnoses = {
          for (String diagnosis in _diagnosesList) diagnosis: false,
        };
        _isLoadingDiagnoses = false;
      });
    } catch (e) {
      print("Erro ao carregar diagnósticos: $e");
      setState(() {
        _isLoadingDiagnoses = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _medicationNameController.dispose();
    super.dispose();
  }

  /// Submete o formulário após validação.
  ///
  /// Valida todos os campos obrigatórios e, se válidos, navega para
  /// a página de instruções com o questionário selecionado.
  ///
  /// Exibe um SnackBar de erro se nenhum questionário estiver selecionado.
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final settings = Provider.of<AppSettings>(context, listen: false);
      final surveyPath = settings.selectedSurveyPath;

      if (surveyPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nenhum questionário selecionado. Verifique as configurações.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InstructionsPage(surveyPath: surveyPath),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informações Demográficas'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                // Campo Nome Completo
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Por favor, insira seu nome.'
                      : null,
                ),
                const SizedBox(height: 16),

                // Campo Data de Nascimento
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: 'Data de Nascimento',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      locale: const Locale('pt', 'BR'),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dobController.text =
                            "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                      });
                    }
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Por favor, selecione sua data de nascimento.'
                      : null,
                ),
                const SizedBox(height: 16),

                // Campo Sexo
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Sexo',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedSex,
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

                // Campo Raça/Etnia
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Raça/Etnia',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedRace,
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
                const SizedBox(height: 24),

                // Campo de diagnósticos dinâmico
                const Text(
                  'Diagnóstico prévio (selecione se aplicável):',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                _isLoadingDiagnoses
                    ? const Center(child: CircularProgressIndicator())
                    : Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: _diagnosesList.map((diagnosis) {
                          return ChoiceChip(
                            label: Text(diagnosis),
                            selected: _selectedDiagnoses[diagnosis] ?? false,
                            onSelected: (bool selected) {
                              setState(() {
                                _selectedDiagnoses[diagnosis] = selected;
                              });
                            },
                            selectedColor: Colors.teal.shade100,
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 24),

                // Campo de medicação condicional
                const Text(
                  'Faz uso de medicamento psiquiátrico?',
                  style: TextStyle(fontSize: 16),
                ),
                Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Sim'),
                      value: 'Sim',
                      groupValue: _usesMedication,
                      onChanged: (value) =>
                          setState(() => _usesMedication = value),
                    ),
                    RadioListTile<String>(
                      title: const Text('Não'),
                      value: 'Não',
                      groupValue: _usesMedication,
                      onChanged: (value) {
                        setState(() {
                          _usesMedication = value;
                          if (value == 'Não') {
                            _medicationNameController.clear();
                          }
                        });
                      },
                    ),
                  ],
                ),

                // Campo condicional para nome do medicamento
                if (_usesMedication == 'Sim')
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _medicationNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome do Medicamento',
                          border: OutlineInputBorder(),
                        ),
                        validator: _usesMedication == 'Sim'
                            ? (value) => value == null || value.isEmpty
                                  ? 'Por favor, informe o nome do medicamento.'
                                  : null
                            : null,
                      ),
                    ],
                  ),

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Continuar para Instruções',
                    style: TextStyle(fontSize: 18),
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
