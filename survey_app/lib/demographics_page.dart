// lib/demographics_page.dart (versão atualizada)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/instructions_page.dart';
import 'package:survey_app/providers/app_settings.dart';
import 'package:survey_app/settings_page.dart'; // Importar a página de configurações

class DemographicsPage extends StatefulWidget {
  const DemographicsPage({super.key});

  @override
  State<DemographicsPage> createState() => _DemographicsPageState();
}

class _DemographicsPageState extends State<DemographicsPage> {
  // ... (todo o código do formulário permanece o mesmo)
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  String? _selectedSex;
  String? _selectedRace;
  final List<String> _diagnoses = [
    'Autismo',
    'TDAH',
    'Depressão',
    'Transtorno Bipolar',
    'Esquizofrenia',
  ];
  final Map<String, bool> _selectedDiagnoses = {};
  String? _usesMedication;

  @override
  void initState() {
    super.initState();
    for (var diagnosis in _diagnoses) {
      _selectedDiagnoses[diagnosis] = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Pega o questionário selecionado do Provider
      final settings = Provider.of<AppSettings>(context, listen: false);
      final surveyPath = settings.selectedSurveyPath;

      if (surveyPath == null) {
        // Mostra um alerta se nenhum questionário for encontrado ou selecionado
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

      // Navega para a próxima página, passando o caminho do questionário
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
        // Adicionando o botão de configurações
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
      // O corpo do Scaffold com o formulário permanece o mesmo de antes
      // ... (Cole aqui o Center -> Form -> ListView que já tínhamos)
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
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
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: 'Data de Nascimento (DD/MM/AAAA)',
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
                DropdownButtonFormField<String>(
                  value: _selectedSex,
                  decoration: const InputDecoration(
                    labelText: 'Sexo de Nascimento',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Masculino', 'Feminino']
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
                  value: _selectedRace,
                  decoration: const InputDecoration(
                    labelText: 'Raça ou Cor',
                    border: OutlineInputBorder(),
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
                const SizedBox(height: 24),
                const Text(
                  'Diagnóstico prévio de transtorno mental:',
                  style: TextStyle(fontSize: 16),
                ),
                ..._diagnoses
                    .map(
                      (diagnosis) => CheckboxListTile(
                        title: Text(diagnosis),
                        value: _selectedDiagnoses[diagnosis],
                        onChanged: (bool? value) => setState(
                          () => _selectedDiagnoses[diagnosis] = value!,
                        ),
                      ),
                    )
                    .toList(),
                const SizedBox(height: 24),
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
                      onChanged: (value) =>
                          setState(() => _usesMedication = value),
                    ),
                  ],
                ),
                if (_usesMedication == null &&
                    _formKey.currentState != null &&
                    !_formKey.currentState!.validate())
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, top: 5.0),
                    child: Text(
                      'Por favor, selecione uma opção.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Próximo', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
