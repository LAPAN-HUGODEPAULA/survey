// lib/demographics_page.dart

import 'package:flutter/material.dart';
import 'package:survey_app/instructions_page.dart';

class DemographicsPage extends StatefulWidget {
  const DemographicsPage({super.key});

  @override
  State<DemographicsPage> createState() => _DemographicsPageState();
}

class _DemographicsPageState extends State<DemographicsPage> {
  // Chave para validar o formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos de texto
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();

  // Variáveis para os campos de seleção
  String? _selectedSex;
  String? _selectedRace;
  final List<String> _diagnoses = [
    'Autismo',
    'TDAH',
    'Depressão',
    'Transtorno Bipolar',
    'Esquizofrenia'
  ];
  final Map<String, bool> _selectedDiagnoses = {};
  String? _usesMedication;

  @override
  void initState() {
    super.initState();
    // Inicializa o mapa de diagnósticos selecionados com 'false'
    for (var diagnosis in _diagnoses) {
      _selectedDiagnoses[diagnosis] = false;
    }
  }

  @override
  void dispose() {
    // Limpa os controladores quando o widget é descartado
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // Valida o formulário antes de prosseguir
    if (_formKey.currentState!.validate()) {
      // Coleta todas as informações (aqui você pode salvar em um modelo de dados)
      print('Nome: ${_nameController.text}');
      print('Data de Nascimento: ${_dobController.text}');
      print('Sexo: $_selectedSex');
      print('Raça/Cor: $_selectedRace');
      print('Diagnósticos: $_selectedDiagnoses');
      print('Usa medicação: $_usesMedication');

      // Navega para a próxima página
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const InstructionsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informações Demográficas'),
        backgroundColor: Colors.teal,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu nome.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Data de Nascimento
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: 'Data de Nascimento (DD/MM/AAAA)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true, // Impede a digitação direta
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
                   validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, selecione sua data de nascimento.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Sexo de Nascimento
                DropdownButtonFormField<String>(
                  value: _selectedSex,
                  decoration: const InputDecoration(
                    labelText: 'Sexo de Nascimento',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Masculino', 'Feminino']
                      .map((label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSex = value;
                    });
                  },
                   validator: (value) => value == null ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),

                // Campo Raça ou Cor
                DropdownButtonFormField<String>(
                  value: _selectedRace,
                  decoration: const InputDecoration(
                    labelText: 'Raça ou Cor',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Branca', 'Preta', 'Parda', 'Amarela', 'Indígena', 'Outra']
                      .map((label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRace = value;
                    });
                  },
                   validator: (value) => value == null ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 24),
                
                // Campo Diagnóstico Prévio
                const Text('Diagnóstico prévio de transtorno mental (selecione se aplicável):', style: TextStyle(fontSize: 16)),
                ..._diagnoses.map((diagnosis) {
                  return CheckboxListTile(
                    title: Text(diagnosis),
                    value: _selectedDiagnoses[diagnosis],
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedDiagnoses[diagnosis] = value!;
                      });
                    },
                  );
                }),
                const SizedBox(height: 24),

                // Campo Uso de Medicação
                const Text('Faz uso de medicamento psiquiátrico?', style: TextStyle(fontSize: 16)),
                 Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Sim'),
                      value: 'Sim',
                      groupValue: _usesMedication,
                      onChanged: (value) {
                        setState(() {
                          _usesMedication = value;
                        });
                      },
                    ),
                     RadioListTile<String>(
                      title: const Text('Não'),
                      value: 'Não',
                      groupValue: _usesMedication,
                      onChanged: (value) {
                        setState(() {
                          _usesMedication = value;
                        });
                      },
                    ),
                  ],
                ),
                 // Validador manual para o grupo de RadioButtons
                if (_usesMedication == null && _formKey.currentState != null && !_formKey.currentState!.validate())
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 5.0),
                  child: Text('Por favor, selecione uma opção.', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
                ),

                const SizedBox(height: 32),

                // Botão de Envio
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
